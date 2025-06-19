#!/bin/bash

# ============================================================================
# NEXTFLOW DOCKER - SCRIPT TRIỂN KHAI TỐI ƯU HÓA
# ============================================================================
# Tác giả: NextFlow Development Team
# Phiên bản: 2.1 - Tối ưu hóa với khôi phục lỗi, rollback và giám sát
# Ngày tạo: 2025
# 
# MÔ TẢ:
# Script này được thiết kế để triển khai hệ thống NextFlow Docker một cách
# tự động và an toàn. Bao gồm các tính năng nâng cao như:
# - Khôi phục tự động khi có lỗi
# - Tạo checkpoint và rollback
# - Giám sát quá trình triển khai
# - Ghi log chi tiết
# 
# CÁCH SỬ DỤNG:
# ./scripts/deploy.sh [TÙY_CHỌN]
# 
# CÁC TÙY CHỌN CHÍNH:
#   --profile <tên_profile>     Triển khai một profile cụ thể
#   --profiles <danh_sách>      Triển khai nhiều profiles (cách nhau bởi dấu phẩy)
#   --stop                      Dừng tất cả dịch vụ
#   --restart                   Khởi động lại tất cả dịch vụ
#   --status                    Hiển thị trạng thái các dịch vụ
#   --logs <tên_service>        Xem logs của một service cụ thể
#   --update                    Cập nhật tất cả Docker images
#   --cleanup                   Dọn dẹp tài nguyên Docker
#   --checkpoint [tên]          Tạo điểm khôi phục
#   --rollback [tên]            Khôi phục về điểm trước đó
#   --hooks                     Bật pre/post deployment hooks
#   --dry-run                   Chỉ hiển thị những gì sẽ được triển khai
#   --help                      Hiển thị hướng dẫn sử dụng
# 
# VÍ DỤ SỬ DỤNG:
#   ./deploy.sh --profile basic                    # Triển khai profile cơ bản
#   ./deploy.sh --profiles basic,monitoring        # Triển khai nhiều profiles
#   ./deploy.sh --checkpoint backup-20250101       # Tạo checkpoint
#   ./deploy.sh --rollback backup-20250101         # Khôi phục từ checkpoint
#   ./deploy.sh --dry-run --profile ai             # Xem trước triển khai AI
# ============================================================================

# Thiết lập bash để dừng khi có lỗi và báo lỗi biến không tồn tại
set -euo pipefail

# ============================================================================
# PHẦN 1: CẤU HÌNH VÀ BIẾN TOÀN CỤC
# ============================================================================

# Xác định thư mục script và thư mục gốc của dự án
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Import các thư viện tiện ích
source "$SCRIPT_DIR/utils/logging.sh"      # Thư viện ghi log với màu sắc
source "$SCRIPT_DIR/utils/docker.sh"       # Thư viện thao tác Docker
source "$SCRIPT_DIR/utils/validation.sh"   # Thư viện kiểm tra và xác thực

# Cấu hình mặc định
COMPOSE_FILE="${COMPOSE_FILE:-$PROJECT_ROOT/docker-compose.yml}"  # File docker-compose
DEFAULT_PROFILE="basic"                     # Profile mặc định khi không chỉ định
DEPLOYMENT_LOG_FILE=""                      # File log triển khai
CHECKPOINT_DIR="backups/deployments"        # Thư mục lưu checkpoint
HOOKS_DIR="$SCRIPT_DIR/hooks"              # Thư mục chứa deployment hooks

# Cờ điều khiển tính năng (có thể bật/tắt qua biến môi trường)
ENABLE_CHECKPOINTS="${ENABLE_CHECKPOINTS:-true}"    # Bật/tắt tạo checkpoint tự động
ENABLE_HOOKS="${ENABLE_HOOKS:-false}"               # Bật/tắt deployment hooks
DRY_RUN="${DRY_RUN:-false}"                        # Chế độ xem trước (không thực thi)
AUTO_RECOVERY="${AUTO_RECOVERY:-true}"              # Bật/tắt khôi phục tự động
FORCE_DEPLOY="${FORCE_DEPLOY:-false}"               # Bỏ qua port conflicts và validation

# Biến toàn cục lưu trạng thái
PROFILES_TO_DEPLOY=()                      # Danh sách profiles sẽ triển khai
ACTION=""                                  # Hành động sẽ thực hiện
SERVICE_NAME=""                            # Tên service (cho lệnh logs)
CHECKPOINT_NAME=""                         # Tên checkpoint
CURRENT_CHECKPOINT=""                      # Checkpoint hiện tại

# ============================================================================
# PHẦN 2: KHÁM PHÁ VÀ QUẢN LÝ PROFILES
# ============================================================================

# Hàm tự động khám phá các profiles có sẵn
# Quét thư mục profiles/ và tìm các file .sh có function deploy_<tên_profile>
discover_available_profiles() {
    local profiles=()
    
    log_debug "Đang quét thư mục profiles để tìm các profile có sẵn..."
    
    # Duyệt qua tất cả file .sh trong thư mục profiles
    for file in "$SCRIPT_DIR/profiles"/*.sh; do
        if [[ -f "$file" ]]; then
            local profile_name=$(basename "$file" .sh)
            
            # Kiểm tra xem file có chứa function deploy_<tên_profile> không
            # Xử lý đặc biệt cho gpu-nvidia (dấu gạch ngang thành gạch dưới)
            local function_name="deploy_${profile_name//-/_}"
            if grep -q "$function_name" "$file" 2>/dev/null; then
                profiles+=("$profile_name")
                log_debug "Tìm thấy profile hợp lệ: $profile_name"
            else
                log_debug "Bỏ qua profile không hợp lệ: $profile_name (thiếu function deploy)"
            fi
        fi
    done
    
    # Nếu không tìm thấy profile nào, sử dụng fallback
    if [[ ${#profiles[@]} -eq 0 ]]; then
        log_warning "Không tìm thấy profile hợp lệ nào trong $SCRIPT_DIR/profiles/"
        profiles=("basic")  # Profile dự phòng
    fi
    
    echo "${profiles[@]}"
}

# Khởi tạo danh sách profiles có sẵn (tự động khám phá)
AVAILABLE_PROFILES=($(discover_available_profiles))

# ============================================================================
# PHẦN 3: HIỂN THỊ HƯỚNG DẪN SỬ DỤNG
# ============================================================================

# Hàm hiển thị hướng dẫn sử dụng chi tiết
show_help() {
    show_banner "NEXTFLOW DOCKER - HƯỚNG DẪN SỬ DỤNG"
    
    echo "Cách sử dụng: $0 [TÙY_CHỌN]"
    echo
    echo "📋 TÙY CHỌN TRIỂN KHAI:"
    echo "  --profile <tên>         Triển khai một profile cụ thể"
    echo "  --profiles <danh_sách>  Triển khai nhiều profiles (cách nhau bởi dấu phẩy)"
    echo "  --dry-run               Chỉ hiển thị những gì sẽ được triển khai"
    echo "  --force                 Bỏ qua port conflicts và validation"
    echo
    echo "🔧 TÙY CHỌN QUẢN LÝ:"
    echo "  --stop                  Dừng tất cả dịch vụ (graceful)"
    echo "  --force-stop            Force stop tất cả dịch vụ (ngay lập tức)"
    echo "  --restart               Khởi động lại tất cả dịch vụ"
    echo "  --status                Hiển thị trạng thái các dịch vụ"
    echo "  --logs <service>        Xem logs của một service cụ thể"
    echo "  --update                Cập nhật tất cả Docker images"
    echo "  --cleanup               Dọn dẹp tài nguyên Docker"
    echo
    echo "💾 TÙY CHỌN BACKUP & KHÔI PHỤC:"
    echo "  --checkpoint [tên]      Tạo điểm khôi phục (checkpoint)"
    echo "  --rollback [tên]        Khôi phục về điểm trước đó"
    echo
    echo "⚙️ TÙY CHỌN NÂNG CAO:"
    echo "  --hooks                 Bật pre/post deployment hooks"
    echo "  --validate              Chỉ kiểm tra cấu hình (không triển khai)"
    echo "  --help                  Hiển thị hướng dẫn này"
    echo
    echo "📂 Profiles có sẵn:"
    for profile in "${AVAILABLE_PROFILES[@]}"; do
        echo "  • $profile"
    done
    echo
    echo "💡 Ví dụ sử dụng:"
    echo "  $0 --profile basic                    # Triển khai profile cơ bản"
    echo "  $0 --profiles basic,monitoring        # Triển khai nhiều profiles"
    echo "  $0 --checkpoint backup-$(date +%Y%m%d) # Tạo checkpoint với tên tùy chỉnh"
    echo "  $0 --rollback backup-20250101         # Khôi phục từ checkpoint"
    echo "  $0 --dry-run --profile ai             # Xem trước triển khai AI"
    echo "  $0 --hooks --profile basic            # Triển khai với hooks"
    echo
    echo "🌍 Biến môi trường:"
    echo "  DEBUG=true              Bật chế độ debug chi tiết"
    echo "  ENABLE_CHECKPOINTS=true Bật tạo checkpoint tự động"
    echo "  ENABLE_HOOKS=true       Bật deployment hooks"
    echo "  DRY_RUN=true           Bật chế độ xem trước"
    echo
    echo "📝 Ghi chú:"
    echo "  • Tất cả logs được lưu trong thư mục logs/"
    echo "  • Checkpoints được lưu trong backups/deployments/"
    echo "  • Hooks được tìm trong scripts/hooks/"
    echo "  • Sử dụng Ctrl+C để dừng quá trình bất kỳ lúc nào"
}

# ============================================================================
# PHẦN 4: XỬ LÝ THAM SỐ DÒNG LỆNH
# ============================================================================

# Hàm phân tích và xử lý các tham số dòng lệnh
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --profile)
                # Triển khai một profile cụ thể
                if [[ -n "${2:-}" ]]; then
                    PROFILES_TO_DEPLOY=("$2")
                    ACTION="deploy"
                    shift 2
                else
                    log_error "Tùy chọn --profile cần một giá trị (tên profile)"
                    exit 1
                fi
                ;;
            --profiles)
                # Triển khai nhiều profiles (cách nhau bởi dấu phẩy)
                if [[ -n "${2:-}" ]]; then
                    IFS=',' read -ra PROFILES_TO_DEPLOY <<< "$2"
                    ACTION="deploy"
                    shift 2
                else
                    log_error "Tùy chọn --profiles cần một giá trị (danh sách profiles)"
                    exit 1
                fi
                ;;
            --checkpoint)
                # Tạo checkpoint
                ACTION="checkpoint"
                CHECKPOINT_NAME="${2:-}"
                # Kiểm tra xem tham số tiếp theo có phải là option khác không
                if [[ -n "${2:-}" && ! "$2" =~ ^-- ]]; then
                    shift 2
                else
                    shift
                fi
                ;;
            --rollback)
                # Khôi phục từ checkpoint
                ACTION="rollback"
                CHECKPOINT_NAME="${2:-}"
                if [[ -n "${2:-}" && ! "$2" =~ ^-- ]]; then
                    shift 2
                else
                    shift
                fi
                ;;
            --hooks)
                # Bật deployment hooks
                ENABLE_HOOKS="true"
                shift
                ;;
            --dry-run)
                # Chế độ xem trước (không thực thi)
                DRY_RUN="true"
                shift
                ;;
            --force)
                # Bỏ qua port conflicts và validation
                FORCE_DEPLOY="true"
                shift
                ;;
            --stop)
                ACTION="stop"
                shift
                ;;
            --force-stop)
                ACTION="force-stop"
                shift
                ;;
            --restart)
                ACTION="restart"
                shift
                ;;
            --restart-cloudflare)
                ACTION="restart-cloudflare"
                shift
                ;;
            --status)
                ACTION="status"
                shift
                ;;
            --logs)
                # Xem logs của một service cụ thể
                if [[ -n "${2:-}" ]]; then
                    ACTION="logs"
                    SERVICE_NAME="$2"
                    shift 2
                else
                    log_error "Tùy chọn --logs cần tên service"
                    exit 1
                fi
                ;;
            --update)
                ACTION="update"
                shift
                ;;
            --cleanup)
                ACTION="cleanup"
                shift
                ;;
            --validate)
                ACTION="validate"
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Tùy chọn không hợp lệ: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Nếu không có tham số nào, chạy chế độ tương tác
    if [[ -z "$ACTION" ]]; then
        ACTION="interactive"
    fi
}

# ============================================================================
# PHẦN 5: KIỂM TRA VÀ XÁC THỰC
# ============================================================================

# Hàm kiểm tra tính hợp lệ của một profile
validate_profile() {
    local profile="$1"

    # Kiểm tra profile có trong danh sách profiles có sẵn không
    for available_profile in "${AVAILABLE_PROFILES[@]}"; do
        if [[ "$profile" == "$available_profile" ]]; then
            return 0
        fi
    done

    # Nếu không tìm thấy, hiển thị lỗi và gợi ý
    log_error "Profile không hợp lệ: $profile"
    log_info "Các profile có sẵn: ${AVAILABLE_PROFILES[*]}"

    # Gợi ý các profile tương tự (fuzzy matching đơn giản)
    log_info "Có thể bạn muốn sử dụng:"
    for available_profile in "${AVAILABLE_PROFILES[@]}"; do
        if [[ "$available_profile" == *"$profile"* ]] || [[ "$profile" == *"$available_profile"* ]]; then
            log_info "  • $available_profile"
        fi
    done

    return 1
}

# Hàm kiểm tra tất cả profiles trong danh sách triển khai
validate_profiles() {
    for profile in "${PROFILES_TO_DEPLOY[@]}"; do
        if ! validate_profile "$profile"; then
            return 1
        fi
    done
    return 0
}

# ============================================================================
# PHẦN 6: QUẢN LÝ LOGS VÀ GIÁM SÁT
# ============================================================================

# Hàm thiết lập hệ thống ghi log cho quá trình triển khai
setup_deployment_logging() {
    local log_dir="logs/deployments"
    local log_file="$log_dir/deployment-$(date +%Y%m%d_%H%M%S).log"

    # Tạo thư mục logs nếu chưa tồn tại
    mkdir -p "$log_dir"

    # Thiết lập file log toàn cục
    export DEPLOYMENT_LOG_FILE="$log_file"

    log_info "Đã bật ghi log triển khai: $log_file"

    # Ghi sự kiện bắt đầu triển khai
    log_deployment_event "deployment_started" "${PROFILES_TO_DEPLOY[*]}"
}

# Hàm ghi log sự kiện triển khai theo định dạng JSON có cấu trúc
log_deployment_event() {
    local event="$1"        # Loại sự kiện (ví dụ: deployment_started)
    local data="$2"         # Dữ liệu kèm theo
    local timestamp=$(date -Iseconds)           # Thời gian theo chuẩn ISO
    local user="${USER:-unknown}"               # Người dùng thực hiện
    local hostname="${HOSTNAME:-unknown}"       # Tên máy chủ

    # Tạo entry log theo định dạng JSON
    local log_entry="{\"timestamp\":\"$timestamp\",\"event\":\"$event\",\"data\":\"$data\",\"user\":\"$user\",\"hostname\":\"$hostname\",\"pid\":$$}"

    # Ghi vào file log nếu đã được thiết lập
    if [[ -n "${DEPLOYMENT_LOG_FILE:-}" ]]; then
        echo "$log_entry" >> "$DEPLOYMENT_LOG_FILE"
    fi

    # Hiển thị trên console nếu bật chế độ debug
    if [[ "${DEBUG:-false}" == "true" ]]; then
        log_debug "Sự kiện: $event | Dữ liệu: $data"
    fi
}

# ============================================================================
# PHẦN 7: QUẢN LÝ CHECKPOINT VÀ ROLLBACK
# ============================================================================

# Hàm tạo checkpoint (điểm khôi phục) trước khi triển khai
create_deployment_checkpoint() {
    local checkpoint_name="${1:-pre-deploy-$(date +%Y%m%d_%H%M%S)}"

    # Kiểm tra xem tính năng checkpoint có được bật không
    if [[ "$ENABLE_CHECKPOINTS" != "true" ]]; then
        log_debug "Tính năng checkpoint bị tắt, bỏ qua..."
        return 0
    fi

    # Tạo thư mục checkpoint nếu chưa tồn tại
    mkdir -p "$CHECKPOINT_DIR"

    log_info "Đang tạo checkpoint: $checkpoint_name"

    # Lưu trạng thái hiện tại của các container
    if $DOCKER_COMPOSE -f "$COMPOSE_FILE" ps --format json > "$CHECKPOINT_DIR/${checkpoint_name}-containers.json" 2>/dev/null; then
        log_debug "Đã lưu trạng thái containers"
    fi

    # Sao lưu file môi trường (.env)
    if cp .env "$CHECKPOINT_DIR/${checkpoint_name}.env" 2>/dev/null; then
        log_debug "Đã sao lưu file môi trường"
    fi

    # Sao lưu file docker-compose
    if cp "$COMPOSE_FILE" "$CHECKPOINT_DIR/${checkpoint_name}-compose.yml" 2>/dev/null; then
        log_debug "Đã sao lưu file docker-compose"
    fi

    # Tạo file metadata chứa thông tin checkpoint
    cat > "$CHECKPOINT_DIR/${checkpoint_name}-metadata.json" << EOF
{
    "timestamp": "$(date -Iseconds)",
    "profiles": [$(printf '"%s",' "${PROFILES_TO_DEPLOY[@]}" | sed 's/,$//')]
    "user": "${USER:-unknown}",
    "hostname": "${HOSTNAME:-unknown}",
    "compose_file": "$COMPOSE_FILE",
    "description": "Checkpoint được tạo tự động trước khi triển khai"
}
EOF

    log_success "Đã tạo checkpoint thành công: $checkpoint_name"
    log_deployment_event "checkpoint_created" "$checkpoint_name"

    echo "$checkpoint_name"
}

# Hàm khôi phục hệ thống từ một checkpoint
rollback_deployment() {
    local checkpoint_name="$1"

    # Nếu không chỉ định checkpoint, hiển thị danh sách có sẵn
    if [[ -z "$checkpoint_name" ]]; then
        echo "📋 Danh sách checkpoints có sẵn:"
        if [[ -d "$CHECKPOINT_DIR" ]]; then
            ls -1 "$CHECKPOINT_DIR"/*-metadata.json 2>/dev/null | while read -r file; do
                local name=$(basename "$file" "-metadata.json")
                local timestamp=$(jq -r '.timestamp' "$file" 2>/dev/null || echo "không rõ")
                local profiles=$(jq -r '.profiles | join(", ")' "$file" 2>/dev/null || echo "không rõ")
                echo "  • $name"
                echo "    Thời gian: $timestamp"
                echo "    Profiles: $profiles"
                echo
            done
        else
            log_warning "Không tìm thấy thư mục checkpoints"
            return 1
        fi

        read -p "Nhập tên checkpoint để khôi phục: " checkpoint_name
    fi

    # Kiểm tra checkpoint có tồn tại không
    if [[ ! -f "$CHECKPOINT_DIR/${checkpoint_name}-metadata.json" ]]; then
        log_error "Không tìm thấy checkpoint: $checkpoint_name"
        return 1
    fi

    log_info "Đang khôi phục từ checkpoint: $checkpoint_name"
    log_deployment_event "rollback_started" "$checkpoint_name"

    # Xác nhận với người dùng
    if ! confirm_action "Thao tác này sẽ dừng các dịch vụ hiện tại và khôi phục trạng thái trước đó. Tiếp tục?"; then
        log_info "Đã hủy thao tác rollback"
        return 0
    fi

    # Dừng tất cả dịch vụ hiện tại
    log_info "Đang dừng các dịch vụ hiện tại..."
    stop_all_services

    # Khôi phục file môi trường
    if [[ -f "$CHECKPOINT_DIR/${checkpoint_name}.env" ]]; then
        cp "$CHECKPOINT_DIR/${checkpoint_name}.env" .env
        log_info "Đã khôi phục file môi trường"
    fi

    # Khôi phục và triển khai lại các profiles
    local profiles=($(jq -r '.profiles[]' "$CHECKPOINT_DIR/${checkpoint_name}-metadata.json" 2>/dev/null))
    if [[ ${#profiles[@]} -gt 0 ]]; then
        log_info "Đang khôi phục các profiles: ${profiles[*]}"
        PROFILES_TO_DEPLOY=("${profiles[@]}")
        deploy_profiles
    fi

    log_success "Đã hoàn tất rollback!"
    log_deployment_event "rollback_completed" "$checkpoint_name"
}

# ============================================================================
# PHẦN 8: XỬ LÝ LỖI VÀ KHÔI PHỤC TỰ ĐỘNG
# ============================================================================

# Hàm xử lý lỗi triển khai với các tùy chọn khôi phục
handle_deployment_error() {
    local profile="$1"              # Profile bị lỗi
    local error_code="${2:-1}"      # Mã lỗi (mặc định là 1)

    log_error "Triển khai profile '$profile' thất bại (mã lỗi: $error_code)"
    log_deployment_event "deployment_error" "$profile:$error_code"

    # Thu thập thông tin chẩn đoán
    collect_deployment_diagnostics "$profile"

    # Nếu bật khôi phục tự động, hiển thị các tùy chọn
    if [[ "$AUTO_RECOVERY" == "true" ]]; then
        offer_recovery_options "$profile"
    else
        log_error "Khôi phục tự động bị tắt. Đang thoát..."
        exit "$error_code"
    fi
}

# Hàm thu thập thông tin chẩn đoán khi có lỗi
collect_deployment_diagnostics() {
    local profile="$1"
    local diag_dir="logs/diagnostics/$(date +%Y%m%d_%H%M%S)"

    log_info "Đang thu thập thông tin chẩn đoán..."
    mkdir -p "$diag_dir"

    # Thu thập thông tin hệ thống
    {
        echo "=== THÔNG TIN HỆ THỐNG ==="
        uname -a
        echo
        echo "=== THÔNG TIN DOCKER ==="
        docker system df
        echo
        echo "=== THỐNG KÊ DOCKER ==="
        docker stats --no-stream
        echo
        echo "=== SỬ DỤNG Ổ CỨNG ==="
        df -h
        echo
        echo "=== SỬ DỤNG BỘ NHỚ ==="
        if command -v free &> /dev/null; then
            free -h
        elif command -v wmic &> /dev/null; then
            # Windows memory info
            wmic OS get TotalVisibleMemorySize,FreePhysicalMemory /format:list 2>/dev/null || echo "Không thể lấy thông tin bộ nhớ"
        else
            echo "Không thể lấy thông tin bộ nhớ (thiếu free/wmic command)"
        fi
        echo
        echo "=== GIAO DIỆN MẠNG ==="
        ip addr show 2>/dev/null || ifconfig 2>/dev/null || echo "Không thể lấy thông tin mạng"
    } > "$diag_dir/system-info.txt"

    # Thu thập logs Docker Compose
    if [[ -f "$COMPOSE_FILE" ]]; then
        $DOCKER_COMPOSE -f "$COMPOSE_FILE" logs > "$diag_dir/compose-logs.txt" 2>&1
    fi

    # Thu thập logs của từng service trong profile bị lỗi
    if [[ -n "$profile" ]]; then
        local profile_services=()
        case "$profile" in
            "basic")
                profile_services=("postgres" "redis" "n8n" "flowise" "wordpress" "mariadb")
                ;;
            "ai")
                profile_services=("ollama" "open-webui")
                ;;
            "langflow")
                profile_services=("postgres" "redis" "langflow" "cloudflare-tunnel-ai")
                ;;
            "monitoring")
                profile_services=("prometheus" "grafana" "loki")
                ;;
            "gitlab")
                profile_services=("postgres" "redis" "gitlab")
                ;;
            "mail")
                profile_services=("postgres" "redis" "stalwart-mail")
                ;;
            "cpu")
                profile_services=("ollama" "ollama-pull-llama")
                ;;
            "gpu-nvidia")
                profile_services=("ollama" "ollama-pull-llama")
                ;;
            "messaging")
                profile_services=("rabbitmq")
                ;;
            "auth")
                profile_services=("postgres" "keycloak")
                ;;
            "tracing")
                profile_services=("jaeger")
                ;;
        esac

        for service in "${profile_services[@]}"; do
            if docker ps -a --format "{{.Names}}" | grep -q "^${service}$"; then
                docker logs "$service" > "$diag_dir/${service}-logs.txt" 2>&1
            fi
        done
    fi

    # Sao lưu cấu hình môi trường và docker-compose
    cp .env "$diag_dir/environment.env" 2>/dev/null || echo "Không có file .env" > "$diag_dir/environment.env"
    cp "$COMPOSE_FILE" "$diag_dir/docker-compose.yml" 2>/dev/null

    log_info "Thông tin chẩn đoán đã được lưu tại: $diag_dir"
    echo "$diag_dir"
}

# Hàm hiển thị các tùy chọn khôi phục khi có lỗi
offer_recovery_options() {
    local profile="$1"

    while true; do
        echo
        log_info "🔧 Các tùy chọn khôi phục cho profile '$profile':"
        echo "1. Thử lại triển khai profile này"
        echo "2. Bỏ qua profile này và tiếp tục với các profile khác"
        echo "3. Rollback về checkpoint trước đó"
        echo "4. Xem logs chi tiết"
        echo "5. Thu thập và xem thông tin chẩn đoán"
        echo "6. Thoát khỏi quá trình triển khai"

        read -p "Chọn tùy chọn khôi phục (1-6): " recovery_choice

        case $recovery_choice in
            1)
                log_info "Đang thử lại triển khai profile '$profile'..."
                deploy_single_profile "$profile"
                return $?
                ;;
            2)
                log_warning "Bỏ qua profile: $profile"
                return 0
                ;;
            3)
                rollback_deployment
                return $?
                ;;
            4)
                show_detailed_logs "$profile"
                # Continue loop để hiển thị lại menu
                ;;
            5)
                local diag_dir=$(collect_deployment_diagnostics "$profile")
                log_info "Đang mở thư mục chẩn đoán: $diag_dir"
                # Thử mở bằng các editor có sẵn
                if command -v code &> /dev/null; then
                    code "$diag_dir"
                elif command -v nano &> /dev/null; then
                    nano "$diag_dir/system-info.txt"
                else
                    cat "$diag_dir/system-info.txt"
                fi
                # Continue loop để hiển thị lại menu
                ;;
            6)
                log_info "Đang thoát khỏi quá trình triển khai..."
                exit 1
                ;;
            *)
                log_error "Lựa chọn không hợp lệ. Vui lòng chọn từ 1-6."
                # Continue loop để hiển thị lại menu
                ;;
        esac
    done
}

# Hàm hiển thị logs chi tiết để troubleshooting
show_detailed_logs() {
    local profile="$1"

    log_info "📋 Hiển thị logs chi tiết cho profile: $profile"

    # Hiển thị logs Docker Compose
    echo "=== LOGS DOCKER COMPOSE ==="
    $DOCKER_COMPOSE -f "$COMPOSE_FILE" logs --tail=50

    echo
    echo "=== CÁC CONTAINER BỊ LỖI ==="
    docker ps -a --filter "status=exited" --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"

    echo
    read -p "Nhấn Enter để tiếp tục..."
}

# ============================================================================
# PHẦN 9: QUẢN LÝ DEPLOYMENT HOOKS
# ============================================================================

# Hàm chạy pre-deployment hooks (trước khi triển khai)
run_pre_deployment_hooks() {
    local profile="$1"

    # Kiểm tra xem hooks có được bật không
    if [[ "$ENABLE_HOOKS" != "true" ]]; then
        return 0
    fi

    local hook_file="$HOOKS_DIR/pre-deploy-${profile}.sh"

    if [[ -f "$hook_file" ]]; then
        log_info "🔄 Đang chạy pre-deployment hook cho profile '$profile'..."
        log_deployment_event "pre_hook_started" "$profile"

        if bash "$hook_file"; then
            log_success "✅ Pre-deployment hook hoàn thành cho profile '$profile'"
            log_deployment_event "pre_hook_completed" "$profile"
        else
            log_error "❌ Pre-deployment hook thất bại cho profile '$profile'"
            log_deployment_event "pre_hook_failed" "$profile"
            return 1
        fi
    else
        log_debug "Không tìm thấy pre-deployment hook cho profile '$profile'"
    fi
}

# Hàm chạy post-deployment hooks (sau khi triển khai)
run_post_deployment_hooks() {
    local profile="$1"

    # Kiểm tra xem hooks có được bật không
    if [[ "$ENABLE_HOOKS" != "true" ]]; then
        return 0
    fi

    local hook_file="$HOOKS_DIR/post-deploy-${profile}.sh"

    if [[ -f "$hook_file" ]]; then
        log_info "🔄 Đang chạy post-deployment hook cho profile '$profile'..."
        log_deployment_event "post_hook_started" "$profile"

        if bash "$hook_file"; then
            log_success "✅ Post-deployment hook hoàn thành cho profile '$profile'"
            log_deployment_event "post_hook_completed" "$profile"
        else
            log_warning "⚠️ Post-deployment hook thất bại cho profile '$profile' (không nghiêm trọng)"
            log_deployment_event "post_hook_failed" "$profile"
        fi
    else
        log_debug "Không tìm thấy post-deployment hook cho profile '$profile'"
    fi
}

# ============================================================================
# PHẦN 10: TRIỂN KHAI PROFILES
# ============================================================================

# Hàm triển khai một profile cụ thể với xử lý lỗi nâng cao
deploy_single_profile() {
    local profile="$1"

    log_info "🚀 Đang triển khai profile: $profile"
    log_deployment_event "profile_deployment_started" "$profile"

    # Chạy pre-deployment hooks
    if ! run_pre_deployment_hooks "$profile"; then
        log_error "Pre-deployment hook thất bại cho profile '$profile'"
        handle_deployment_error "$profile" 2
        return 1
    fi

    # Triển khai dựa trên loại profile
    local deploy_success=false

    case "$profile" in
        "basic")
            if [[ -f "$SCRIPT_DIR/profiles/basic.sh" ]]; then
                source "$SCRIPT_DIR/profiles/basic.sh"
                if deploy_basic "$FORCE_DEPLOY"; then
                    deploy_success=true
                fi
            else
                log_error "Không tìm thấy script profile: basic.sh"
            fi
            ;;
        "monitoring")
            if [[ -f "$SCRIPT_DIR/profiles/monitoring.sh" ]]; then
                source "$SCRIPT_DIR/profiles/monitoring.sh"
                if deploy_monitoring "$FORCE_DEPLOY"; then
                    deploy_success=true
                fi
            else
                log_error "Không tìm thấy script profile: monitoring.sh"
            fi
            ;;
        "ai")
            if [[ -f "$SCRIPT_DIR/profiles/ai.sh" ]]; then
                source "$SCRIPT_DIR/profiles/ai.sh"
                if deploy_ai "$FORCE_DEPLOY"; then
                    deploy_success=true
                fi
            else
                log_error "Không tìm thấy script profile: ai.sh"
            fi
            ;;
        "gitlab")
            if [[ -f "$SCRIPT_DIR/profiles/gitlab.sh" ]]; then
                source "$SCRIPT_DIR/profiles/gitlab.sh"
                if deploy_gitlab "$FORCE_DEPLOY"; then
                    deploy_success=true
                fi
            else
                log_error "Không tìm thấy script profile: gitlab.sh"
            fi
            ;;
        "mail")
            if [[ -f "$SCRIPT_DIR/profiles/mail.sh" ]]; then
                source "$SCRIPT_DIR/profiles/mail.sh"
                if deploy_mail "$FORCE_DEPLOY"; then
                    deploy_success=true
                fi
            else
                log_error "Không tìm thấy script profile: mail.sh"
            fi
            ;;
        "langflow")
            if [[ -f "$SCRIPT_DIR/profiles/langflow.sh" ]]; then
                source "$SCRIPT_DIR/profiles/langflow.sh"
                if deploy_langflow "$FORCE_DEPLOY"; then
                    deploy_success=true
                fi
            else
                log_error "Không tìm thấy script profile: langflow.sh"
            fi
            ;;
        "gpu-nvidia")
            if [[ -f "$SCRIPT_DIR/profiles/gpu-nvidia.sh" ]]; then
                source "$SCRIPT_DIR/profiles/gpu-nvidia.sh"
                if deploy_gpu_nvidia "$FORCE_DEPLOY"; then
                    deploy_success=true
                fi
            else
                log_error "Không tìm thấy script profile: gpu-nvidia.sh"
            fi
            ;;
        *)
            log_error "Profile không được hỗ trợ: $profile"
            log_info "Các profile có sẵn: ${AVAILABLE_PROFILES[*]}"
            return 1
            ;;
    esac

    # Kiểm tra kết quả triển khai
    if [[ "$deploy_success" == "true" ]]; then
        log_success "✅ Profile '$profile' đã được triển khai thành công!"
        log_deployment_event "profile_deployment_success" "$profile"

        # Chạy post-deployment hooks
        run_post_deployment_hooks "$profile"

        return 0
    else
        log_error "❌ Triển khai profile '$profile' thất bại!"
        log_deployment_event "profile_deployment_failed" "$profile"
        handle_deployment_error "$profile" 1
        return 1
    fi
}

# Hàm triển khai nhiều profiles với giám sát tiến trình
deploy_profiles() {
    show_banner "🚀 TRIỂN KHAI PROFILES (ENHANCED)"

    # Thiết lập hệ thống ghi log
    setup_deployment_logging

    log_info "📋 Profiles sẽ được triển khai: ${PROFILES_TO_DEPLOY[*]}"

    # Kiểm tra tính hợp lệ của tất cả profiles
    if ! validate_profiles; then
        exit 1
    fi

    # Tạo checkpoint trước khi triển khai
    if [[ "$ENABLE_CHECKPOINTS" == "true" ]]; then
        CURRENT_CHECKPOINT=$(create_deployment_checkpoint)
    fi

    # Chế độ dry run (xem trước)
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "🔍 CHẾ ĐỘ XEM TRƯỚC - Hiển thị những gì sẽ được triển khai:"
        for profile in "${PROFILES_TO_DEPLOY[@]}"; do
            echo "  📦 Profile: $profile"
            echo "    🔧 Pre-hook: $HOOKS_DIR/pre-deploy-${profile}.sh"
            echo "    📜 Deploy script: $SCRIPT_DIR/profiles/${profile}.sh"
            echo "    ✅ Post-hook: $HOOKS_DIR/post-deploy-${profile}.sh"
        done
        log_info "Xem trước hoàn tất. Sử dụng lệnh không có --dry-run để thực thi."
        return 0
    fi

    # Triển khai từng profile với theo dõi tiến trình
    local total_profiles=${#PROFILES_TO_DEPLOY[@]}
    local current_profile=0
    local failed_profiles=()

    for profile in "${PROFILES_TO_DEPLOY[@]}"; do
        current_profile=$((current_profile + 1))

        log_info "📊 Tiến trình: $current_profile/$total_profiles"
        show_progress $current_profile $total_profiles

        if deploy_single_profile "$profile"; then
            log_success "✅ Profile '$profile' hoàn thành thành công"
        else
            log_error "❌ Profile '$profile' thất bại"
            failed_profiles+=("$profile")

            # Hỏi người dùng có muốn tiếp tục với các profile còn lại không
            if [[ $current_profile -lt $total_profiles ]]; then
                if ! confirm_action "Tiếp tục với các profiles còn lại?"; then
                    log_info "Quá trình triển khai đã được dừng bởi người dùng"
                    break
                fi
            fi
        fi
    done

    # Hiển thị tổng kết cuối cùng
    show_enhanced_deployment_summary "${failed_profiles[@]}"

    # Trả về mã thoát phù hợp
    if [[ ${#failed_profiles[@]} -eq 0 ]]; then
        log_deployment_event "deployment_completed_success" "${PROFILES_TO_DEPLOY[*]}"
        return 0
    else
        log_deployment_event "deployment_completed_with_failures" "${failed_profiles[*]}"
        return 1
    fi
}

# ============================================================================
# PHẦN 11: HIỂN THỊ TỔNG KẾT VÀ THÔNG TIN
# ============================================================================

# Hàm hiển thị tổng kết triển khai nâng cao
show_enhanced_deployment_summary() {
    local failed_profiles=("$@")

    show_banner "📊 TỔNG KẾT TRIỂN KHAI"

    if [[ ${#failed_profiles[@]} -eq 0 ]]; then
        log_success "🎉 Tất cả profiles đã được triển khai thành công!"
    else
        log_warning "⚠️ Triển khai hoàn tất với một số lỗi"
        echo "❌ Profiles thất bại: ${failed_profiles[*]}"
    fi

    echo
    log_info "📋 Profiles đã triển khai: ${PROFILES_TO_DEPLOY[*]}"
    echo

    # Hiển thị trạng thái hiện tại
    log_info "📈 Trạng thái hiện tại của các dịch vụ:"
    $DOCKER_COMPOSE -f "$COMPOSE_FILE" ps
    echo

    # Hiển thị thông tin checkpoint
    if [[ -n "$CURRENT_CHECKPOINT" ]]; then
        log_info "💾 Checkpoint đã được tạo: $CURRENT_CHECKPOINT"
        echo "  🔄 Để rollback: $0 --rollback $CURRENT_CHECKPOINT"
    fi

    # Hiển thị các lệnh quản lý
    log_info "🔧 Các lệnh quản lý hữu ích:"
    echo "  📋 Xem logs: $0 --logs <tên_service>"
    echo "  ⏹️  Dừng tất cả: $0 --stop"
    echo "  📊 Xem trạng thái: $0 --status"
    echo "  🔄 Cập nhật: $0 --update"
    echo "  ↩️  Rollback: $0 --rollback"

    # Hiển thị vị trí file log
    if [[ -n "$DEPLOYMENT_LOG_FILE" ]]; then
        echo
        log_info "📝 Log triển khai: $DEPLOYMENT_LOG_FILE"
    fi

    # Hiển thị URLs truy cập các dịch vụ
    echo
    log_info "🌐 URLs truy cập các dịch vụ chính:"
    echo "  🏠 WordPress (Landing Page): http://localhost:8080"
    echo "  🤖 Flowise AI: http://localhost:8001"
    echo "  🔗 n8n Automation: http://localhost:8003"
    echo "  🌊 Langflow AI Workflow: http://localhost:7860 (admin/nextflow@2025)"
    echo "  🤖 Open-WebUI (Ollama): http://localhost:8002"
    echo "  📊 Grafana Monitoring: http://localhost:9001"
    echo "  💾 Redis Commander: http://localhost:6101"
    echo "  📧 Stalwart Mail Admin: http://localhost:8005"
    echo "  🦊 GitLab: http://localhost:8004 (root/Nex!tFlow@2025!)"
}

# ============================================================================
# PHẦN 12: KHỞI TẠO MÔI TRƯỜNG VÀ CÁC FUNCTIONS QUẢN LÝ
# ============================================================================

# Hàm khởi tạo môi trường triển khai nâng cao
initialize_environment() {
    log_info "🔧 Đang khởi tạo môi trường triển khai..."

    # Chuyển đến thư mục gốc của dự án
    cd "$PROJECT_ROOT"

    # Tạo các thư mục cần thiết
    mkdir -p logs/deployments logs/diagnostics "$CHECKPOINT_DIR" "$HOOKS_DIR"

    # Kiểm tra Docker và Docker Compose
    if ! check_docker || ! check_docker_compose; then
        log_error "Docker hoặc Docker Compose không sẵn sàng!"
        log_info "Vui lòng cài đặt Docker và Docker Compose trước khi tiếp tục."
        exit 1
    fi

    # Kiểm tra file docker-compose
    if ! validate_docker_compose_file "$COMPOSE_FILE"; then
        log_error "File docker-compose không hợp lệ: $COMPOSE_FILE"
        exit 1
    fi

    # Kiểm tra file .env
    validate_env_file

    # Hiển thị cấu hình hiện tại
    log_info "⚙️ Cấu hình hiện tại:"
    echo "  📄 File Compose: $COMPOSE_FILE"
    echo "  📦 Profiles có sẵn: ${AVAILABLE_PROFILES[*]}"
    echo "  💾 Checkpoints: $ENABLE_CHECKPOINTS"
    echo "  🔗 Hooks: $ENABLE_HOOKS"
    echo "  👁️  Dry run: $DRY_RUN"
    echo "  🔄 Auto recovery: $AUTO_RECOVERY"

    log_success "✅ Môi trường đã sẵn sàng!"
}

# Hàm dừng tất cả dịch vụ nâng cao
stop_all_services() {
    show_banner "⏹️ DỪNG TẤT CẢ DỊCH VỤ"

    log_info "🛑 Đang dừng tất cả containers..."
    log_deployment_event "stop_all_started" "all"

    # Lấy danh sách tất cả containers đang chạy từ docker-compose
    local running_containers
    running_containers=$(docker ps --format "{{.Names}}" | grep -E "(postgres|redis|mariadb|wordpress|n8n|flowise|langflow|ollama|open-webui|cloudflare-tunnel|cloudflare-tunnel-ai|gitlab|stalwart|qdrant|rabbitmq|redis-commander)" 2>/dev/null || true)

    if [[ -n "$running_containers" ]]; then
        log_info "📋 Containers đang chạy:"
        echo "$running_containers" | while read -r container; do
            echo "  - $container"
        done
        echo

        # Dừng từng container một cách graceful
        echo "$running_containers" | while read -r container; do
            if [[ -n "$container" ]]; then
                log_info "⏹️ Đang dừng container: $container"
                docker stop "$container" 2>/dev/null || true
                docker rm "$container" 2>/dev/null || true
            fi
        done
    fi

    # Dừng tất cả profiles một cách graceful (sử dụng danh sách profiles có sẵn)
    local profiles_to_stop=("${AVAILABLE_PROFILES[@]}")

    for profile in "${profiles_to_stop[@]}"; do
        log_info "⏹️ Đang dừng profile: $profile"
        $DOCKER_COMPOSE -f "$COMPOSE_FILE" --profile "$profile" down --remove-orphans 2>/dev/null || true
    done

    # Dừng tất cả containers còn lại từ docker-compose
    log_info "🧹 Dọn dẹp containers còn lại..."
    $DOCKER_COMPOSE -f "$COMPOSE_FILE" down --remove-orphans 2>/dev/null || true

    # Kiểm tra và dừng bất kỳ containers nào còn sót lại
    local remaining_containers
    remaining_containers=$(docker ps --format "{{.Names}}" | grep -E "(postgres|redis|mariadb|wordpress|n8n|flowise|langflow|ollama|open-webui|cloudflare-tunnel|cloudflare-tunnel-ai|gitlab|stalwart|qdrant|rabbitmq|redis-commander)" 2>/dev/null || true)

    if [[ -n "$remaining_containers" ]]; then
        log_warning "⚠️ Vẫn còn containers đang chạy, force stop..."
        echo "$remaining_containers" | while read -r container; do
            if [[ -n "$container" ]]; then
                log_info "🔨 Force stop: $container"
                docker kill "$container" 2>/dev/null || true
                docker rm "$container" 2>/dev/null || true
            fi
        done
    fi

    # Kiểm tra kết quả cuối cùng
    local final_check
    final_check=$(docker ps --format "{{.Names}}" | grep -E "(postgres|redis|mariadb|wordpress|n8n|flowise|langflow|ollama|open-webui|cloudflare-tunnel|cloudflare-tunnel-ai|gitlab|stalwart|qdrant|rabbitmq|redis-commander)" 2>/dev/null || true)

    if [[ -z "$final_check" ]]; then
        log_success "✅ Tất cả dịch vụ đã được dừng thành công!"
    else
        log_warning "⚠️ Một số containers vẫn đang chạy:"
        echo "$final_check"
    fi

    log_deployment_event "stop_all_completed" "all"
}

# Hàm force stop tất cả containers NextFlow
force_stop_all_services() {
    show_banner "🔨 FORCE STOP TẤT CẢ DỊCH VỤ"

    log_warning "⚠️ Đang force stop tất cả containers NextFlow..."

    # Lấy tất cả containers liên quan đến NextFlow
    local all_containers
    all_containers=$(docker ps -a --format "{{.Names}}" | grep -E "(postgres|redis|mariadb|wordpress|n8n|flowise|langflow|ollama|open-webui|cloudflare-tunnel|cloudflare-tunnel-ai|gitlab|stalwart|qdrant|rabbitmq|redis-commander)" 2>/dev/null || true)

    if [[ -n "$all_containers" ]]; then
        log_info "📋 Tất cả containers NextFlow:"
        echo "$all_containers" | while read -r container; do
            echo "  - $container"
        done
        echo

        # Force kill và remove tất cả
        echo "$all_containers" | while read -r container; do
            if [[ -n "$container" ]]; then
                log_info "🔨 Force kill: $container"
                docker kill "$container" 2>/dev/null || true
                docker rm -f "$container" 2>/dev/null || true
            fi
        done

        # Dọn dẹp networks
        log_info "🧹 Dọn dẹp networks..."
        docker network prune -f 2>/dev/null || true

        # Dọn dẹp volumes (tùy chọn)
        if confirm_action "🗑️ Xóa tất cả volumes (dữ liệu sẽ mất)?"; then
            log_warning "⚠️ Đang xóa volumes..."
            docker volume prune -f 2>/dev/null || true
        fi

        log_success "✅ Force stop hoàn tất!"
    else
        log_info "ℹ️ Không có containers NextFlow nào đang chạy."
    fi
}

# Hàm khởi động lại tất cả dịch vụ
restart_all_services() {
    show_banner "🔄 KHỞI ĐỘNG LẠI TẤT CẢ DỊCH VỤ"

    log_info "🔄 Đang khởi động lại tất cả dịch vụ..."
    log_deployment_event "restart_started" "all"

    # Dừng trước
    stop_all_services

    # Chờ một chút để đảm bảo tất cả đã dừng hoàn toàn
    log_info "⏳ Chờ 5 giây để đảm bảo tất cả dịch vụ đã dừng..."
    sleep 5

    # Triển khai lại với profile mặc định hoặc profiles đã chỉ định
    if [[ ${#PROFILES_TO_DEPLOY[@]} -eq 0 ]]; then
        PROFILES_TO_DEPLOY=("$DEFAULT_PROFILE")
    fi

    deploy_profiles
    log_deployment_event "restart_completed" "all"
}

# Hàm restart Cloudflare tunnel
restart_cloudflare_tunnel() {
    show_banner "☁️ RESTART CLOUDFLARE TUNNEL"

    log_info "🔄 Đang restart Cloudflare tunnel..."
    log_deployment_event "restart_cloudflare_started" "cloudflare-tunnel"

    cd "$PROJECT_ROOT"

    # Kiểm tra xem có tunnel nào đang chạy không
    local tunnels_found=false
    local tunnel_containers=("cloudflare-tunnel" "cloudflare-tunnel-ai")

    for tunnel in "${tunnel_containers[@]}"; do
        if is_container_running "$tunnel"; then
            log_info "🔄 Restart container: $tunnel"
            if docker restart "$tunnel"; then
                log_success "✅ Đã restart $tunnel thành công!"
                tunnels_found=true
            else
                log_error "❌ Restart $tunnel thất bại!"
            fi
        else
            log_info "ℹ️ Container $tunnel không đang chạy"
        fi
    done

    if [[ "$tunnels_found" == "false" ]]; then
        log_warning "⚠️ Không tìm thấy Cloudflare tunnel nào đang chạy"
        log_info "🚀 Khởi động Cloudflare tunnels..."

        # Thử khởi động tunnels
        for tunnel in "${tunnel_containers[@]}"; do
            log_info "🚀 Khởi động $tunnel..."
            if $DOCKER_COMPOSE up -d "$tunnel" 2>/dev/null; then
                log_success "✅ Đã khởi động $tunnel thành công!"
                tunnels_found=true
            else
                log_info "ℹ️ $tunnel không có trong cấu hình hiện tại"
            fi
        done
    fi

    if [[ "$tunnels_found" == "true" ]]; then
        log_success "✅ Cloudflare tunnel operations hoàn tất!"
        log_deployment_event "restart_cloudflare_completed" "success"

        # Hiển thị trạng thái tunnels
        log_info "📊 Trạng thái Cloudflare tunnels:"
        for tunnel in "${tunnel_containers[@]}"; do
            if is_container_running "$tunnel"; then
                log_success "  ✅ $tunnel: Đang chạy"
            else
                log_info "  ⏹️ $tunnel: Không chạy"
            fi
        done
    else
        log_warning "⚠️ Không có Cloudflare tunnel nào được khởi động"
        log_deployment_event "restart_cloudflare_failed" "no_tunnels"
    fi
}

# Hàm hiển thị trạng thái nâng cao
show_status() {
    show_banner "📊 TRẠNG THÁI DỊCH VỤ"

    log_info "📋 Trạng thái containers:"
    $DOCKER_COMPOSE -f "$COMPOSE_FILE" ps

    echo
    log_info "💻 Sử dụng tài nguyên:"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"

    echo
    log_info "🖥️ Tài nguyên hệ thống:"
    echo "💾 Sử dụng ổ cứng: $(df -h / | awk 'NR==2 {print $5 " đã sử dụng / " $2 " tổng cộng"}')"
    if command -v free &> /dev/null; then
        echo "🧠 Sử dụng bộ nhớ: $(free -h | awk 'NR==2 {print $3 " đã sử dụng / " $2 " tổng cộng"}')"
    else
        echo "🧠 Sử dụng bộ nhớ: Không thể lấy thông tin (thiếu free command)"
    fi

    # Hiển thị các sự kiện triển khai gần đây
    if [[ -f "$DEPLOYMENT_LOG_FILE" ]]; then
        echo
        log_info "📝 Sự kiện triển khai gần đây:"
        tail -5 "$DEPLOYMENT_LOG_FILE" | jq -r '"\(.timestamp) - \(.event): \(.data)"' 2>/dev/null || echo "Không có sự kiện gần đây"
    fi
}

# Hàm hiển thị logs của service
show_service_logs() {
    local service="$1"

    show_banner "📋 LOGS CỦA SERVICE: $service"

    if is_container_running "$service"; then
        log_info "📺 Hiển thị logs trực tiếp cho '$service' (nhấn Ctrl+C để thoát):"
        docker logs -f --tail=100 "$service"
    else
        log_warning "⚠️ Service '$service' không đang chạy."
        log_info "📜 Hiển thị 100 dòng logs cuối cùng:"
        docker logs --tail 100 "$service" 2>/dev/null || log_error "Không thể lấy logs cho '$service'"
    fi
}

# Hàm cập nhật images nâng cao
update_images() {
    show_banner "🔄 CẬP NHẬT DOCKER IMAGES"

    log_info "📥 Đang cập nhật tất cả Docker images..."
    log_deployment_event "update_started" "all"

    # Tạo checkpoint trước khi cập nhật
    local update_checkpoint=""
    if [[ "$ENABLE_CHECKPOINTS" == "true" ]]; then
        update_checkpoint=$(create_deployment_checkpoint "pre-update-$(date +%Y%m%d_%H%M%S)")
    fi

    if pull_images "$COMPOSE_FILE"; then
        log_success "✅ Images đã được cập nhật thành công!"
        log_deployment_event "update_completed" "success"

        if confirm_action "🔄 Khởi động lại containers để sử dụng images mới?"; then
            restart_all_services
        fi
    else
        log_error "❌ Cập nhật images thất bại!"
        log_deployment_event "update_failed" "error"

        if [[ -n "$update_checkpoint" ]]; then
            if confirm_action "↩️ Rollback về trạng thái trước đó?"; then
                rollback_deployment "$update_checkpoint"
            fi
        fi
        exit 1
    fi
}

# ============================================================================
# PHẦN 13: CHẾ ĐỘ TƯƠNG TÁC (INTERACTIVE MODE)
# ============================================================================

# Hàm chế độ tương tác nâng cao
interactive_mode() {
    show_banner "🎮 NEXTFLOW DOCKER - CHẾ ĐỘ TƯƠNG TÁC"

    local options=(
        "🚀 Triển khai Profile Basic (Cơ bản)"
        "📊 Triển khai Profile Monitoring (Giám sát)"
        "🤖 Triển khai Profile AI (Trí tuệ nhân tạo)"
        "🔗 Triển khai Profile Langflow (AI Workflow Platform)"
        "🦊 Triển khai Profile GitLab (Quản lý mã nguồn)"
        "📧 Triển khai Profile Mail (Stalwart Mail Server)"
        "🎮 Triển khai Profile GPU-NVIDIA (Ollama GPU)"
        "📦 Triển khai Nhiều Profiles"
        "📈 Xem Trạng thái Dịch vụ"
        "⏹️ Dừng Tất cả Dịch vụ"
        "🔨 Force Stop Tất cả Dịch vụ"
        "🔄 Restart Tất cả Dịch vụ"
        "☁️ Restart Cloudflare Tunnel"
        "🔄 Cập nhật Images"
        "🧹 Dọn dẹp Tài nguyên Docker"
        "💾 Tạo Checkpoint"
        "↩️ Rollback Triển khai"
        "📝 Xem Logs Triển khai"
        "❌ Thoát"
    )

    while true; do
        echo
        show_menu "🎯 MENU TRIỂN KHAI NÂNG CAO" "${options[@]}"
        read -r choice

        case $choice in
            1)
                PROFILES_TO_DEPLOY=("basic")
                deploy_profiles
                ;;
            2)
                PROFILES_TO_DEPLOY=("monitoring")
                deploy_profiles
                ;;
            3)
                PROFILES_TO_DEPLOY=("ai")
                deploy_profiles
                ;;
            4)
                PROFILES_TO_DEPLOY=("langflow")
                deploy_profiles
                ;;
            5)
                PROFILES_TO_DEPLOY=("gitlab")
                deploy_profiles
                ;;
            6)
                PROFILES_TO_DEPLOY=("mail")
                deploy_profiles
                ;;
            7)
                PROFILES_TO_DEPLOY=("gpu-nvidia")
                deploy_profiles
                ;;
            8)
                echo "📝 Nhập các profiles (cách nhau bởi dấu phẩy): "
                echo "Ví dụ: basic,monitoring,ai,langflow,gitlab,mail,gpu-nvidia"
                echo "Profiles có sẵn: ${AVAILABLE_PROFILES[*]}"
                read -r profiles_input
                IFS=',' read -ra PROFILES_TO_DEPLOY <<< "$profiles_input"
                deploy_profiles
                ;;
            9)
                show_status
                ;;
            10)
                stop_all_services
                ;;
            11)
                force_stop_all_services
                ;;
            12)
                restart_all_services
                ;;
            13)
                restart_cloudflare_tunnel
                ;;
            14)
                update_images
                ;;
            15)
                docker_cleanup
                ;;
            16)
                read -p "📝 Nhập tên checkpoint (tùy chọn): " checkpoint_name
                create_deployment_checkpoint "$checkpoint_name"
                ;;
            17)
                rollback_deployment
                ;;
            18)
                if [[ -f "$DEPLOYMENT_LOG_FILE" ]]; then
                    log_info "📝 Các sự kiện triển khai gần đây:"
                    tail -20 "$DEPLOYMENT_LOG_FILE" | jq -r '"\(.timestamp) - \(.event): \(.data)"' 2>/dev/null || cat "$DEPLOYMENT_LOG_FILE"
                else
                    log_warning "⚠️ Không tìm thấy file log triển khai"
                fi
                ;;
            19)
                log_info "👋 Tạm biệt! Cảm ơn bạn đã sử dụng NextFlow Docker!"
                break
                ;;
            *)
                log_error "❌ Lựa chọn không hợp lệ! Vui lòng chọn từ 1-19."
                ;;
        esac
    done
}

# ============================================================================
# PHẦN 14: MAIN FUNCTION - ĐIỂM VÀO CHÍNH CỦA SCRIPT
# ============================================================================

# Hàm main - điểm vào chính của script
main() {
    # Phân tích các tham số dòng lệnh
    parse_arguments "$@"

    # Khởi tạo môi trường
    initialize_environment

    # Thực thi hành động được yêu cầu
    case "$ACTION" in
        "deploy")
            deploy_profiles
            ;;
        "stop")
            stop_all_services
            ;;
        "force-stop")
            force_stop_all_services
            ;;
        "restart")
            restart_all_services
            ;;
        "restart-cloudflare")
            restart_cloudflare_tunnel
            ;;
        "status")
            show_status
            ;;
        "logs")
            show_service_logs "$SERVICE_NAME"
            ;;
        "update")
            update_images
            ;;
        "cleanup")
            docker_cleanup
            ;;
        "checkpoint")
            create_deployment_checkpoint "$CHECKPOINT_NAME"
            ;;
        "rollback")
            rollback_deployment "$CHECKPOINT_NAME"
            ;;
        "validate")
            log_success "✅ Cấu hình hợp lệ!"
            ;;
        "interactive")
            interactive_mode
            ;;
        *)
            log_error "❌ Hành động không hợp lệ: $ACTION"
            exit 1
            ;;
    esac
}

# ============================================================================
# THỰC THI SCRIPT
# ============================================================================

# Chạy hàm main với tất cả tham số được truyền vào
main "$@"

# ============================================================================
# KẾT THÚC SCRIPT
# ============================================================================
