#!/bin/bash
# ============================================================================
# GITLAB MANAGER SCRIPT FOR NEXTFLOW CRM-AI (FIXED VERSION)
# ============================================================================
# Mô tả: Script quản lý GitLab với menu tương tác đơn giản
# Tác giả: NextFlow Team
# Phiên bản: 1.1.0 (Fixed encoding issues)
# Sử dụng: ./scripts/gitlab-manager-fixed.sh [install|update|backup|restore]
# ============================================================================

set -euo pipefail

# Màu sắc cho output (đơn giản)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Cấu hình
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
COMPOSE_FILE="$PROJECT_DIR/docker-compose.yml"
ENV_FILE="$PROJECT_DIR/.env"
GITLAB_CONTAINER="gitlab"
BACKUP_DIR="$PROJECT_DIR/gitlab/backups"
GITLAB_SCRIPTS_DIR="$PROJECT_DIR/gitlab/scripts"

# Load environment variables
if [ -f "$ENV_FILE" ]; then
    set -a
    source "$ENV_FILE"
    set +a
fi

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_header() {
    echo "================================"
    echo "$1"
    echo "================================"
}

# Hàm kiểm tra yêu cầu hệ thống - ĐÃ TỐI ƯU
check_requirements() {
    log_info "Đang kiểm tra yêu cầu hệ thống..."

    # Kiểm tra Docker có cài đặt không
    if ! command -v docker &> /dev/null; then
        log_error "Docker chưa được cài đặt!"
        log_info "Hướng dẫn cài đặt:"
        echo "  • Windows: Tải Docker Desktop từ docker.com"
        echo "  • Linux: curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh"
        exit 1
    fi

    # Kiểm tra phiên bản Docker
    DOCKER_VERSION=$(docker --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    log_info "Phiên bản Docker: $DOCKER_VERSION"

    # Kiểm tra Docker có chạy không
    if ! docker info &> /dev/null; then
        log_error "Docker daemon không chạy!"
        log_info "Khắc phục:"
        echo "  • Windows: Khởi động Docker Desktop"
        echo "  • Linux: sudo systemctl start docker"
        exit 1
    fi

    # Kiểm tra quyền truy cập Docker
    if ! docker ps &> /dev/null; then
        log_error "Không có quyền truy cập Docker!"
        log_info "Khắc phục:"
        echo "  • Linux: sudo usermod -aG docker \$USER && newgrp docker"
        echo "  • Windows: Chạy terminal với quyền Administrator"
        exit 1
    fi

    # Kiểm tra Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose chưa được cài đặt!"
        log_info "Hướng dẫn cài đặt:"
        echo "  • Thường đi kèm với Docker Desktop"
        echo "  • Linux: sudo apt install docker-compose-plugin"
        exit 1
    fi

    # Kiểm tra phiên bản Docker Compose
    COMPOSE_VERSION=$(docker-compose --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    log_info "Phiên bản Docker Compose: $COMPOSE_VERSION"

    # Kiểm tra file cấu hình
    if [ ! -f "$COMPOSE_FILE" ]; then
        log_error "Không tìm thấy file docker-compose.yml tại: $COMPOSE_FILE"
        log_info "Đảm bảo bạn đang chạy script từ thư mục gốc dự án"
        exit 1
    fi

    if [ ! -f "$ENV_FILE" ]; then
        log_error "Không tìm thấy file .env tại: $ENV_FILE"
        log_info "Tạo file .env từ .env.example hoặc chạy script setup"
        exit 1
    fi

    # Kiểm tra dung lượng đĩa (cần ít nhất 10GB cho GitLab)
    AVAILABLE_SPACE=$(df -BG "$PROJECT_DIR" 2>/dev/null | awk 'NR==2 {print $4}' | sed 's/G//' || echo "0")
    if [ "$AVAILABLE_SPACE" -lt 10 ]; then
        log_warning "Dung lượng đĩa thấp: ${AVAILABLE_SPACE}GB (khuyến nghị ít nhất 10GB)"
        log_info "GitLab cần nhiều dung lượng để lưu trữ repositories và artifacts"
        read -p "Tiếp tục với dung lượng thấp? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        log_success "Dung lượng đĩa đủ: ${AVAILABLE_SPACE}GB"
    fi

    # Kiểm tra RAM (GitLab cần ít nhất 4GB)
    if command -v free >/dev/null 2>&1; then
        TOTAL_RAM=$(free -m | awk 'NR==2{printf "%.0f", $2/1024}')
        if [ "$TOTAL_RAM" -lt 4 ]; then
            log_warning "RAM thấp: ${TOTAL_RAM}GB (khuyến nghị ít nhất 4GB cho GitLab)"
            log_info "GitLab có thể chạy chậm hoặc không ổn định với RAM thấp"
            read -p "Tiếp tục với RAM thấp? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        else
            log_success "RAM đủ yêu cầu: ${TOTAL_RAM}GB"
        fi
    else
        log_info "Không thể kiểm tra RAM trên hệ thống này"
    fi

    log_success "Tất cả yêu cầu hệ thống đã được đáp ứng!"
}

# Hàm kiểm tra trạng thái GitLab - ĐÃ TỐI ƯU
check_gitlab_status() {
    # Kiểm tra container có tồn tại không
    if ! docker ps -a --format "table {{.Names}}" | grep -q "^${GITLAB_CONTAINER}$"; then
        log_info "Container GitLab chưa được tạo"
        return 2  # Container chưa tồn tại
    fi

    # Kiểm tra container có đang chạy không
    if docker ps --format "table {{.Names}}" | grep -q "^${GITLAB_CONTAINER}$"; then
        # Kiểm tra health status nếu có
        HEALTH_STATUS=$(docker inspect "$GITLAB_CONTAINER" --format='{{.State.Health.Status}}' 2>/dev/null || echo "no-health-check")

        case "$HEALTH_STATUS" in
            "healthy")
                log_success "GitLab đang chạy và khỏe mạnh"
                return 0  # Đang chạy và khỏe mạnh
                ;;
            "unhealthy")
                log_warning "GitLab đang chạy nhưng không khỏe mạnh"
                return 3  # Đang chạy nhưng có vấn đề
                ;;
            "starting")
                log_info "GitLab đang trong quá trình khởi động"
                return 4  # Đang khởi động
                ;;
            "no-health-check")
                log_info "GitLab đang chạy (không có health check)"
                return 0  # Đang chạy nhưng không có health check
                ;;
            *)
                log_warning "GitLab có trạng thái không xác định: $HEALTH_STATUS"
                return 3  # Trạng thái không rõ
                ;;
        esac
    else
        log_info "Container GitLab đã dừng"
        return 1  # Container đã dừng
    fi
}

# Hàm kiểm tra trạng thái GitLab với thông tin chi tiết
check_gitlab_status_verbose() {
    log_info "Đang kiểm tra trạng thái GitLab chi tiết..."

    local status_code
    check_gitlab_status
    status_code=$?

    case $status_code in
        0)
            echo "✅ GitLab đang hoạt động bình thường"
            # Kiểm tra thêm web interface
            if curl -s -o /dev/null -w "%{http_code}" "http://localhost:8088" | grep -qE "^(200|302)$"; then
                echo "🌐 Web interface có thể truy cập"
            else
                echo "⚠️ Web interface chưa sẵn sàng"
            fi
            ;;
        1)
            echo "🔴 GitLab container đã dừng"
            echo "💡 Khởi động: docker-compose --profile gitlab up -d gitlab"
            ;;
        2)
            echo "❌ GitLab container chưa được tạo"
            echo "💡 Cài đặt: chọn option [3] INSTALL trong menu"
            ;;
        3)
            echo "⚠️ GitLab có vấn đề về sức khỏe"
            echo "💡 Kiểm tra logs: docker logs gitlab"
            ;;
        4)
            echo "⏳ GitLab đang khởi động, vui lòng đợi..."
            ;;
        *)
            echo "❓ Không thể xác định trạng thái GitLab"
            ;;
    esac

    return $status_code
}

# Hàm đợi GitLab sẵn sàng - ĐÃ TỐI ƯU
wait_for_gitlab() {
    local max_attempts=60  # 60 * 30s = 30 phút
    local attempt=1
    local start_time=$(date +%s)

    log_info "⏳ Đợi GitLab khởi động hoàn toàn..."
    log_warning "Lần đầu khởi động có thể mất 5-15 phút, vui lòng kiên nhẫn..."
    echo ""

    # Hiển thị progress bar
    local progress_chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    local progress_index=0

    while [ $attempt -le $max_attempts ]; do
        # Kiểm tra container có đang chạy không
        if ! docker ps --format "{{.Names}}" | grep -q "^${GITLAB_CONTAINER}$"; then
            echo ""
            log_error "❌ GitLab container đã dừng bất ngờ!"
            log_info "Kiểm tra logs: docker logs gitlab"
            return 1
        fi

        # Kiểm tra GitLab services
        local gitlab_services_ready=false
        if docker exec "$GITLAB_CONTAINER" gitlab-ctl status >/dev/null 2>&1; then
            gitlab_services_ready=true
        fi

        # Kiểm tra web interface
        local web_ready=false
        local http_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8088" 2>/dev/null || echo "000")
        if [[ "$http_code" =~ ^(200|302)$ ]]; then
            web_ready=true
        fi

        # Nếu cả hai đều ready
        if [ "$gitlab_services_ready" = true ] && [ "$web_ready" = true ]; then
            echo ""
            log_success "🎉 GitLab đã sẵn sàng!"

            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            local minutes=$((duration / 60))
            local seconds=$((duration % 60))
            log_info "⏱️ Thời gian khởi động: ${minutes}m ${seconds}s"

            return 0
        fi

        # Hiển thị progress với thông tin chi tiết
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        local elapsed_minutes=$((elapsed / 60))
        local elapsed_seconds=$((elapsed % 60))

        local progress_char=${progress_chars:$progress_index:1}
        progress_index=$(((progress_index + 1) % ${#progress_chars}))

        local status_msg=""
        if [ "$gitlab_services_ready" = true ]; then
            status_msg="Services: ✅ | Web: ⏳"
        else
            status_msg="Services: ⏳ | Web: ⏳"
        fi

        echo -ne "\r  $progress_char Đợi GitLab... ${elapsed_minutes}m ${elapsed_seconds}s | $status_msg | Lần thử: $attempt/$max_attempts"

        sleep 30
        ((attempt++))
    done

    echo ""
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    local minutes=$((duration / 60))

    log_error "❌ GitLab không khởi động được sau ${minutes} phút!"
    echo ""
    log_info "🔍 Các bước khắc phục:"
    echo "  1. Kiểm tra logs: docker logs gitlab"
    echo "  2. Kiểm tra tài nguyên hệ thống (RAM, CPU, Disk)"
    echo "  3. Restart container: docker restart gitlab"
    echo "  4. Kiểm tra dependencies: docker ps | grep -E '(postgres|redis)'"
    echo "  5. Sử dụng option [7] STATUS để chẩn đoán chi tiết"

    return 1
}

# Hàm kiểm tra GitLab images có sẵn - ĐÃ TỐI ƯU
check_gitlab_images() {
    log_header "KIỂM TRA GITLAB IMAGES"

    log_info "Đang quét tất cả GitLab images có sẵn..."
    echo ""

    local has_custom=false
    local has_official=false
    local custom_image="nextflow/gitlab-ce:${GITLAB_VERSION:-16.11.10-ce.0}"

    # Kiểm tra custom image NextFlow
    log_info "🔍 Tìm kiếm NextFlow custom image..."
    if docker images "$custom_image" --format "{{.Repository}}" | grep -q "nextflow/gitlab-ce"; then
        has_custom=true
        local custom_info=$(docker images "$custom_image" --format "{{.ID}} {{.Size}} {{.CreatedAt}}" | head -1)
        local image_id=$(echo "$custom_info" | cut -d' ' -f1)
        local image_size=$(echo "$custom_info" | cut -d' ' -f2)
        local created_date=$(echo "$custom_info" | cut -d' ' -f3-)

        echo "   ✅ NextFlow Custom Image: $custom_image"
        echo "      📦 Image ID: $image_id"
        echo "      💾 Kích thước: $image_size"
        echo "      📅 Tạo lúc: $created_date"
        echo "      🎯 Tính năng: Tối ưu cho NextFlow CRM-AI"
        echo ""
    else
        echo "   ❌ NextFlow Custom Image: Chưa có"
        echo "      💡 Có thể build bằng option [2] BUILD"
        echo ""
    fi

    # Kiểm tra official image
    log_info "🔍 Tìm kiếm GitLab official images..."
    local official_images=$(docker images gitlab/gitlab-ce --format "{{.Tag}} {{.ID}} {{.Size}} {{.CreatedAt}}" 2>/dev/null)

    if [ -n "$official_images" ]; then
        has_official=true
        echo "   ✅ GitLab Official Images:"

        # Hiển thị tối đa 3 images gần nhất
        local count=0
        while IFS= read -r line && [ $count -lt 3 ]; do
            if [ -n "$line" ]; then
                local tag=$(echo "$line" | cut -d' ' -f1)
                local id=$(echo "$line" | cut -d' ' -f2)
                local size=$(echo "$line" | cut -d' ' -f3)
                local created=$(echo "$line" | cut -d' ' -f4-)

                echo "      📦 gitlab/gitlab-ce:$tag"
                echo "         ID: $id | Size: $size | Created: $created"
                ((count++))
            fi
        done <<< "$official_images"

        local total_official=$(echo "$official_images" | wc -l)
        if [ $total_official -gt 3 ]; then
            echo "      ... và $((total_official - 3)) images khác"
        fi
        echo ""
    else
        echo "   ❌ GitLab Official Images: Chưa có"
        echo "      💡 Có thể pull bằng: docker pull gitlab/gitlab-ce:latest"
        echo ""
    fi

    # Tổng kết và khuyến nghị
    log_info "📊 Tổng kết:"
    if [ "$has_custom" = true ] && [ "$has_official" = true ]; then
        echo "   🎉 Có cả custom và official images"
        echo "   💡 Khuyến nghị: Sử dụng NextFlow custom image để có tính năng tối ưu"
    elif [ "$has_custom" = true ]; then
        echo "   ✅ Có NextFlow custom image (đủ để sử dụng)"
        echo "   💡 Tùy chọn: Có thể pull official image để backup"
    elif [ "$has_official" = true ]; then
        echo "   ⚠️ Chỉ có official image"
        echo "   💡 Khuyến nghị: Build NextFlow custom image để có tính năng tối ưu"
    else
        echo "   ❌ Không có image nào"
        echo "   🚨 Cần thiết: Pull official hoặc build custom image"
        log_error "Không tìm thấy GitLab image nào!"
        echo ""
        log_info "Các bước khắc phục:"
        echo "   1. Pull official image: docker pull gitlab/gitlab-ce:latest"
        echo "   2. Hoặc build custom image: chọn option [2] BUILD"
        echo "   3. Hoặc cài đặt tự động: chọn option [3] INSTALL"
        return 1
    fi

    echo ""
    return 0
}

# Hàm build GitLab custom image - ĐÃ TỐI ƯU
build_gitlab() {
    log_header "BUILD GITLAB CUSTOM IMAGE"

    # Kiểm tra yêu cầu hệ thống trước
    check_requirements

    # Kiểm tra Dockerfile và context
    local dockerfile_path="$PROJECT_DIR/gitlab/docker/Dockerfile"
    local build_context="$PROJECT_DIR/gitlab/docker"

    if [ ! -f "$dockerfile_path" ]; then
        log_error "Không tìm thấy Dockerfile!"
        log_info "Đường dẫn mong đợi: $dockerfile_path"
        log_info "Vui lòng kiểm tra cấu trúc thư mục dự án"
        return 1
    fi

    if [ ! -d "$build_context" ]; then
        log_error "Không tìm thấy build context!"
        log_info "Thư mục mong đợi: $build_context"
        return 1
    fi

    # Kiểm tra các file cần thiết trong build context
    log_info "Kiểm tra build context..."
    local required_files=("Dockerfile")
    local missing_files=()

    for file in "${required_files[@]}"; do
        if [ ! -f "$build_context/$file" ]; then
            missing_files+=("$file")
        fi
    done

    if [ ${#missing_files[@]} -gt 0 ]; then
        log_error "Thiếu các file cần thiết trong build context:"
        for file in "${missing_files[@]}"; do
            echo "  ❌ $file"
        done
        return 1
    fi

    # Hiển thị thông tin build
    local custom_image="nextflow/gitlab-ce:${GITLAB_VERSION:-16.11.10-ce.0}"
    log_info "Thông tin build:"
    echo "  📦 Image name: $custom_image"
    echo "  📁 Build context: $build_context"
    echo "  🐳 Dockerfile: $dockerfile_path"
    echo "  🏷️ GitLab version: ${GITLAB_VERSION:-16.11.10-ce.0}"
    echo ""

    # Kiểm tra image cũ
    if docker images "$custom_image" --format "{{.Repository}}" | grep -q "nextflow/gitlab-ce"; then
        log_warning "Image cũ đã tồn tại!"
        local old_info=$(docker images "$custom_image" --format "{{.ID}} {{.Size}} {{.CreatedAt}}" | head -1)
        echo "  🗂️ Image cũ: $(echo "$old_info" | cut -d' ' -f1)"
        echo "  💾 Size: $(echo "$old_info" | cut -d' ' -f2)"
        echo "  📅 Created: $(echo "$old_info" | cut -d' ' -f3-)"
        echo ""

        read -p "Bạn có muốn rebuild image mới? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Hủy build, sử dụng image hiện tại"
            return 0
        fi
    fi

    # Bắt đầu build process
    log_info "🔨 Bắt đầu build GitLab custom image..."
    log_warning "⏳ Quá trình này có thể mất 10-20 phút, vui lòng kiên nhẫn..."
    echo ""

    # Build image với docker-compose và hiển thị progress
    local build_start_time=$(date +%s)

    if docker-compose -f "$COMPOSE_FILE" build --no-cache gitlab; then
        local build_end_time=$(date +%s)
        local build_duration=$((build_end_time - build_start_time))
        local build_minutes=$((build_duration / 60))
        local build_seconds=$((build_duration % 60))

        log_success "🎉 Build GitLab custom image thành công!"
        echo "  ⏱️ Thời gian build: ${build_minutes}m ${build_seconds}s"
        echo ""

        # Hiển thị thông tin image mới
        log_info "📊 Thông tin image vừa build:"
        local new_image_info=$(docker images "$custom_image" --format "{{.ID}} {{.Size}} {{.CreatedAt}}" | head -1)
        if [ -n "$new_image_info" ]; then
            local image_id=$(echo "$new_image_info" | cut -d' ' -f1)
            local image_size=$(echo "$new_image_info" | cut -d' ' -f2)
            local created_time=$(echo "$new_image_info" | cut -d' ' -f3-)

            echo "  🆔 Image ID: $image_id"
            echo "  💾 Kích thước: $image_size"
            echo "  📅 Thời gian tạo: $created_time"
            echo "  🏷️ Tag: $custom_image"
        fi

        # Dọn dẹp dangling images
        log_info "🧹 Dọn dẹp dangling images..."
        local dangling_count=$(docker images -f "dangling=true" -q | wc -l)
        if [ "$dangling_count" -gt 0 ]; then
            docker image prune -f >/dev/null 2>&1
            log_success "Đã dọn dẹp $dangling_count dangling images"
        else
            log_info "Không có dangling images cần dọn dẹp"
        fi

        echo ""
        log_success "✅ GitLab custom image đã sẵn sàng sử dụng!"
        log_info "💡 Bước tiếp theo: Chọn option [3] INSTALL để cài đặt GitLab"

        return 0
    else
        local build_end_time=$(date +%s)
        local build_duration=$((build_end_time - build_start_time))
        local build_minutes=$((build_duration / 60))
        local build_seconds=$((build_duration % 60))

        log_error "❌ Build GitLab image thất bại!"
        echo "  ⏱️ Thời gian thử build: ${build_minutes}m ${build_seconds}s"
        echo ""
        log_info "🔍 Các bước khắc phục:"
        echo "  1. Kiểm tra kết nối internet"
        echo "  2. Kiểm tra dung lượng đĩa (cần ít nhất 5GB trống)"
        echo "  3. Kiểm tra Docker daemon có đủ tài nguyên"
        echo "  4. Xem logs chi tiết ở trên để tìm lỗi cụ thể"
        echo "  5. Thử build lại sau khi khắc phục"

        return 1
    fi
}

# Hàm quản lý GitLab images - CHỨC NĂNG MỚI
manage_gitlab_images() {
    log_header "QUẢN LÝ GITLAB IMAGES"

    while true; do
        echo ""
        echo "Chọn thao tác với GitLab images:"
        echo ""
        echo "   1. [LIST] Liệt kê tất cả images"
        echo "   2. [PULL] Pull official image mới nhất"
        echo "   3. [BUILD] Build NextFlow custom image"
        echo "   4. [CLEAN] Dọn dẹp images cũ"
        echo "   5. [COMPARE] So sánh images"
        echo "   0. [BACK] Quay lại menu chính"
        echo ""

        read -p "Nhập lựa chọn (0-5): " choice
        echo ""

        case $choice in
            1)
                check_gitlab_images
                ;;
            2)
                pull_official_gitlab_image
                ;;
            3)
                build_gitlab
                ;;
            4)
                clean_old_gitlab_images
                ;;
            5)
                compare_gitlab_images
                ;;
            0)
                return 0
                ;;
            *)
                log_error "Lựa chọn không hợp lệ!"
                sleep 1
                ;;
        esac

        if [ "$choice" != "0" ]; then
            echo ""
            read -p "Nhấn Enter để tiếp tục..." -r
        fi
    done
}

# Hàm pull official GitLab image
pull_official_gitlab_image() {
    log_info "🔄 Pull GitLab official image..."

    local gitlab_version="${GITLAB_VERSION:-latest}"
    local official_image="gitlab/gitlab-ce:$gitlab_version"

    log_info "Đang pull image: $official_image"
    log_warning "⏳ Quá trình này có thể mất 5-15 phút tùy vào tốc độ mạng..."

    if docker pull "$official_image"; then
        log_success "✅ Pull image thành công!"

        # Hiển thị thông tin image vừa pull
        local image_info=$(docker images "$official_image" --format "{{.ID}} {{.Size}} {{.CreatedAt}}" | head -1)
        if [ -n "$image_info" ]; then
            echo "  🆔 Image ID: $(echo "$image_info" | cut -d' ' -f1)"
            echo "  💾 Kích thước: $(echo "$image_info" | cut -d' ' -f2)"
            echo "  📅 Thời gian tạo: $(echo "$image_info" | cut -d' ' -f3-)"
        fi
    else
        log_error "❌ Pull image thất bại!"
        log_info "Kiểm tra kết nối internet và thử lại"
        return 1
    fi
}

# Hàm dọn dẹp images cũ
clean_old_gitlab_images() {
    log_info "🧹 Dọn dẹp GitLab images cũ..."

    # Liệt kê tất cả GitLab images
    local all_gitlab_images=$(docker images --format "{{.Repository}}:{{.Tag}} {{.ID}} {{.Size}} {{.CreatedAt}}" | grep -E "(gitlab|nextflow)" | grep -v "<none>")

    if [ -z "$all_gitlab_images" ]; then
        log_info "Không có GitLab images nào để dọn dẹp"
        return 0
    fi

    echo "📋 Danh sách GitLab images hiện tại:"
    echo "$all_gitlab_images" | nl -w2 -s'. '
    echo ""

    # Tìm dangling images
    local dangling_images=$(docker images -f "dangling=true" -q)
    local dangling_count=$(echo "$dangling_images" | grep -c . 2>/dev/null || echo "0")

    if [ "$dangling_count" -gt 0 ]; then
        log_warning "Tìm thấy $dangling_count dangling images"
        read -p "Xóa dangling images? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker image prune -f
            log_success "Đã xóa dangling images"
        fi
    else
        log_info "Không có dangling images"
    fi

    # Hỏi có muốn xóa images cũ không
    echo ""
    log_warning "⚠️ Cảnh báo: Chỉ xóa images không sử dụng"
    read -p "Bạn có muốn xóa images cũ không sử dụng? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker image prune -a -f --filter "label!=keep"
        log_success "Đã dọn dẹp images cũ"
    fi
}

# Hàm so sánh GitLab images
compare_gitlab_images() {
    log_info "📊 So sánh GitLab images..."

    local custom_image="nextflow/gitlab-ce:${GITLAB_VERSION:-16.11.10-ce.0}"
    local official_image="gitlab/gitlab-ce:${GITLAB_VERSION:-latest}"

    echo ""
    echo "🔍 Thông tin chi tiết:"
    echo ""

    # So sánh custom image
    if docker images "$custom_image" --format "{{.Repository}}" | grep -q "nextflow/gitlab-ce"; then
        local custom_info=$(docker images "$custom_image" --format "{{.ID}} {{.Size}} {{.CreatedAt}}" | head -1)
        echo "✅ NextFlow Custom Image:"
        echo "   📦 Name: $custom_image"
        echo "   🆔 ID: $(echo "$custom_info" | cut -d' ' -f1)"
        echo "   💾 Size: $(echo "$custom_info" | cut -d' ' -f2)"
        echo "   📅 Created: $(echo "$custom_info" | cut -d' ' -f3-)"
        echo "   🎯 Features: NextFlow optimized, custom scripts"
    else
        echo "❌ NextFlow Custom Image: Chưa có"
    fi

    echo ""

    # So sánh official image
    if docker images "gitlab/gitlab-ce" --format "{{.Repository}}" | grep -q "gitlab/gitlab-ce"; then
        local official_info=$(docker images "gitlab/gitlab-ce" --format "{{.Tag}} {{.ID}} {{.Size}} {{.CreatedAt}}" | head -1)
        echo "✅ GitLab Official Image:"
        echo "   📦 Name: gitlab/gitlab-ce:$(echo "$official_info" | cut -d' ' -f1)"
        echo "   🆔 ID: $(echo "$official_info" | cut -d' ' -f2)"
        echo "   💾 Size: $(echo "$official_info" | cut -d' ' -f3)"
        echo "   📅 Created: $(echo "$official_info" | cut -d' ' -f4-)"
        echo "   🎯 Features: Standard GitLab CE"
    else
        echo "❌ GitLab Official Image: Chưa có"
    fi

    echo ""
    echo "💡 Khuyến nghị:"
    echo "   • NextFlow Custom: Tối ưu cho dự án NextFlow CRM-AI"
    echo "   • Official Image: Phiên bản gốc, ổn định"
    echo "   • Nên có cả hai để backup và testing"
}

# 1. CHỨC NĂNG CÀI ĐẶT GITLAB - ĐÃ TỐI ƯU
install_gitlab() {
    log_header "CÀI ĐẶT GITLAB NEXTFLOW"

    # Bước 1: Kiểm tra yêu cầu hệ thống
    log_info "🔍 Bước 1/7: Kiểm tra yêu cầu hệ thống..."
    check_requirements
    check_environment_variables
    check_network_connectivity

    # Bước 2: Kiểm tra trạng thái GitLab hiện tại
    log_info "🔍 Bước 2/7: Kiểm tra trạng thái GitLab hiện tại..."
    local gitlab_status
    check_gitlab_status
    gitlab_status=$?

    case $gitlab_status in
        0)
            log_success "GitLab đã đang chạy và khỏe mạnh!"
            echo ""
            log_info "Các tùy chọn:"
            echo "   1. Giữ nguyên GitLab hiện tại"
            echo "   2. Khởi động lại GitLab"
            echo "   3. Cài đặt lại hoàn toàn"
            echo ""
            read -p "Chọn tùy chọn (1-3): " choice

            case $choice in
                1)
                    log_info "Giữ nguyên GitLab hiện tại"
                    show_gitlab_access_info
                    return 0
                    ;;
                2)
                    log_info "Khởi động lại GitLab..."
                    docker-compose -f "$COMPOSE_FILE" restart gitlab
                    if wait_for_gitlab; then
                        log_success "GitLab đã khởi động lại thành công!"
                        show_gitlab_access_info
                        return 0
                    else
                        log_error "Khởi động lại GitLab thất bại!"
                        return 1
                    fi
                    ;;
                3)
                    log_warning "Sẽ cài đặt lại GitLab hoàn toàn..."
                    read -p "Bạn có chắc chắn? Dữ liệu hiện tại sẽ bị mất! (y/N): " -n 1 -r
                    echo
                    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                        log_info "Hủy cài đặt lại"
                        return 0
                    fi
                    # Tiếp tục với cài đặt mới
                    ;;
                *)
                    log_error "Lựa chọn không hợp lệ!"
                    return 1
                    ;;
            esac
            ;;
        1)
            log_info "GitLab container đã dừng, sẽ khởi động lại"
            ;;
        2)
            log_info "GitLab container chưa được tạo, sẽ cài đặt mới"
            ;;
        3|4)
            log_warning "GitLab có vấn đề, sẽ cài đặt lại"
            ;;
    esac

    # Bước 3: Kiểm tra và chuẩn bị images
    log_info "🔍 Bước 3/7: Kiểm tra và chuẩn bị GitLab images..."
    prepare_gitlab_images

    # Bước 4: Chuẩn bị môi trường
    log_info "🔍 Bước 4/7: Chuẩn bị môi trường GitLab..."
    prepare_gitlab_environment

    # Bước 5: Khởi động dependencies
    log_info "🔍 Bước 5/7: Khởi động dependencies (PostgreSQL, Redis)..."
    start_gitlab_dependencies

    # Bước 6: Cài đặt GitLab
    log_info "🔍 Bước 6/7: Cài đặt và khởi động GitLab..."
    deploy_gitlab_service

    # Bước 7: Kiểm tra và hoàn tất
    log_info "🔍 Bước 7/7: Kiểm tra cài đặt và hoàn tất..."
    if verify_gitlab_installation; then
        log_success "🎉 GitLab đã được cài đặt thành công!"
        show_gitlab_access_info
        return 0
    else
        log_error "❌ Cài đặt GitLab thất bại!"
        show_installation_troubleshooting
        return 1
    fi
}

# Hàm chuẩn bị GitLab images
prepare_gitlab_images() {
    local has_custom_image=false
    local has_official_image=false
    local custom_image="nextflow/gitlab-ce:${GITLAB_VERSION:-16.11.10-ce.0}"

    # Kiểm tra custom image
    if docker images "$custom_image" --format "{{.Repository}}" | grep -q "nextflow/gitlab-ce"; then
        has_custom_image=true
        log_success "✅ Tìm thấy NextFlow custom image: $custom_image"
    fi

    # Kiểm tra official image
    if docker images gitlab/gitlab-ce --format "{{.Repository}}" | grep -q "gitlab/gitlab-ce"; then
        has_official_image=true
        log_success "✅ Tìm thấy GitLab official image"
    fi

    # Xử lý trường hợp không có image nào
    if [ "$has_custom_image" = false ] && [ "$has_official_image" = false ]; then
        log_error "❌ Không tìm thấy GitLab image nào!"
        echo ""
        log_info "Các tùy chọn:"
        echo "   1. Build NextFlow custom image (khuyến nghị)"
        echo "   2. Pull GitLab official image"
        echo "   3. Hủy cài đặt"
        echo ""
        read -p "Chọn tùy chọn (1-3): " choice

        case $choice in
            1)
                log_info "Build NextFlow custom image..."
                if build_gitlab; then
                    log_success "Build custom image thành công!"
                else
                    log_error "Build custom image thất bại!"
                    return 1
                fi
                ;;
            2)
                log_info "Pull GitLab official image..."
                if pull_official_gitlab_image; then
                    log_success "Pull official image thành công!"
                else
                    log_error "Pull official image thất bại!"
                    return 1
                fi
                ;;
            3)
                log_info "Hủy cài đặt"
                return 1
                ;;
            *)
                log_error "Lựa chọn không hợp lệ!"
                return 1
                ;;
        esac
    elif [ "$has_custom_image" = false ] && [ "$has_official_image" = true ]; then
        # Chỉ có official image
        log_warning "⚠️ Chỉ có GitLab official image"
        log_info "NextFlow custom image có thêm scripts và cấu hình tối ưu"
        echo ""
        read -p "Bạn có muốn build NextFlow custom image không? (Y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            if build_gitlab; then
                log_success "Build custom image thành công!"
            else
                log_warning "Build custom image thất bại, sẽ sử dụng official image"
            fi
        else
            log_info "Sẽ sử dụng GitLab official image"
            log_warning "Lưu ý: Sẽ thiếu một số tính năng NextFlow custom"
        fi
    else
        log_success "✅ Images đã sẵn sàng"
    fi

    return 0
}

# Hàm chuẩn bị môi trường GitLab
prepare_gitlab_environment() {
    log_info "Tạo thư mục cần thiết cho GitLab..."

    local directories=(
        "$PROJECT_DIR/gitlab/config"
        "$PROJECT_DIR/gitlab/logs"
        "$PROJECT_DIR/gitlab/data"
        "$PROJECT_DIR/gitlab/backups"
        "$PROJECT_DIR/gitlab/ssl"
    )

    for dir in "${directories[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            log_info "  📁 Tạo thư mục: $(basename "$dir")"
        else
            log_info "  ✅ Thư mục đã có: $(basename "$dir")"
        fi
    done

    # Thiết lập quyền truy cập
    chmod 755 "$PROJECT_DIR/gitlab"
    chmod -R 755 "$PROJECT_DIR/gitlab"/*

    log_success "✅ Môi trường GitLab đã sẵn sàng"
    return 0
}

# Hàm khởi động dependencies
start_gitlab_dependencies() {
    log_info "Kiểm tra và khởi động PostgreSQL..."

    # Kiểm tra PostgreSQL
    if ! docker ps --format "{{.Names}}" | grep -q "^postgres$"; then
        log_info "Khởi động PostgreSQL..."
        docker-compose -f "$COMPOSE_FILE" up -d postgres

        # Đợi PostgreSQL sẵn sàng
        local max_attempts=30
        local attempt=1

        while [ $attempt -le $max_attempts ]; do
            if docker exec postgres pg_isready -U nextflow >/dev/null 2>&1; then
                log_success "✅ PostgreSQL đã sẵn sàng"
                break
            fi

            echo -ne "\r  ⏳ Đợi PostgreSQL... ($attempt/$max_attempts)"
            sleep 2
            ((attempt++))
        done
        echo ""

        if [ $attempt -gt $max_attempts ]; then
            log_error "❌ PostgreSQL không khởi động được"
            return 1
        fi
    else
        log_success "✅ PostgreSQL đã đang chạy"
    fi

    log_info "Kiểm tra và khởi động Redis..."

    # Kiểm tra Redis
    if ! docker ps --format "{{.Names}}" | grep -q "^redis$"; then
        log_info "Khởi động Redis..."
        docker-compose -f "$COMPOSE_FILE" up -d redis

        # Đợi Redis sẵn sàng
        local max_attempts=15
        local attempt=1

        while [ $attempt -le $max_attempts ]; do
            if docker exec redis redis-cli ping >/dev/null 2>&1; then
                log_success "✅ Redis đã sẵn sàng"
                break
            fi

            echo -ne "\r  ⏳ Đợi Redis... ($attempt/$max_attempts)"
            sleep 1
            ((attempt++))
        done
        echo ""

        if [ $attempt -gt $max_attempts ]; then
            log_error "❌ Redis không khởi động được"
            return 1
        fi
    else
        log_success "✅ Redis đã đang chạy"
    fi

    # Tạo database cho GitLab
    log_info "Chuẩn bị database cho GitLab..."
    local gitlab_db="${GITLAB_DATABASE:-nextflow_gitlab}"

    if docker exec postgres psql -U nextflow -c "SELECT 1 FROM pg_database WHERE datname = '$gitlab_db';" | grep -q 1; then
        log_success "✅ Database '$gitlab_db' đã tồn tại"
    else
        log_info "Tạo database '$gitlab_db'..."
        if docker exec postgres psql -U nextflow -c "CREATE DATABASE $gitlab_db;"; then
            log_success "✅ Đã tạo database '$gitlab_db'"
        else
            log_error "❌ Không thể tạo database '$gitlab_db'"
            return 1
        fi
    fi

    return 0
}

# Hàm deploy GitLab service
deploy_gitlab_service() {
    log_info "Khởi động GitLab container..."

    # Dừng GitLab cũ nếu có
    if docker ps -a --format "{{.Names}}" | grep -q "^gitlab$"; then
        log_info "Dừng GitLab container cũ..."
        docker-compose -f "$COMPOSE_FILE" --profile gitlab stop gitlab 2>/dev/null || true
        docker-compose -f "$COMPOSE_FILE" --profile gitlab rm -f gitlab 2>/dev/null || true
    fi

    # Khởi động GitLab mới
    log_info "Khởi động GitLab container mới..."
    if docker-compose -f "$COMPOSE_FILE" --profile gitlab up -d gitlab; then
        log_success "✅ GitLab container đã được khởi động"
        return 0
    else
        log_error "❌ Không thể khởi động GitLab container"
        return 1
    fi
}

# Hàm kiểm tra cài đặt GitLab
verify_gitlab_installation() {
    log_info "Đợi GitLab khởi động hoàn toàn..."

    if wait_for_gitlab; then
        log_success "✅ GitLab đã khởi động thành công"

        # Kiểm tra thêm các services
        log_info "Kiểm tra GitLab services..."
        if docker exec gitlab gitlab-ctl status >/dev/null 2>&1; then
            log_success "✅ GitLab internal services đang hoạt động"
        else
            log_warning "⚠️ Một số GitLab services có thể chưa sẵn sàng"
        fi

        # Kiểm tra web interface
        log_info "Kiểm tra web interface..."
        local max_attempts=10
        local attempt=1

        while [ $attempt -le $max_attempts ]; do
            local http_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8088" 2>/dev/null || echo "000")
            if [[ "$http_code" =~ ^(200|302)$ ]]; then
                log_success "✅ Web interface có thể truy cập"
                return 0
            fi

            echo -ne "\r  ⏳ Kiểm tra web interface... ($attempt/$max_attempts)"
            sleep 10
            ((attempt++))
        done
        echo ""

        log_warning "⚠️ Web interface chưa sẵn sàng hoàn toàn, nhưng GitLab đã khởi động"
        return 0
    else
        log_error "❌ GitLab không khởi động được"
        return 1
    fi
}

# Hàm hiển thị troubleshooting khi cài đặt lỗi
show_installation_troubleshooting() {
    log_header "HƯỚNG DẪN KHẮC PHỤC LỖI CÀI ĐẶT"

    echo "🔍 Các bước kiểm tra và khắc phục:"
    echo ""
    echo "1. 📋 Kiểm tra logs GitLab:"
    echo "   docker logs gitlab"
    echo ""
    echo "2. 💾 Kiểm tra tài nguyên hệ thống:"
    echo "   • RAM: Cần ít nhất 4GB"
    echo "   • Disk: Cần ít nhất 10GB trống"
    echo "   • CPU: Cần ít nhất 2 cores"
    echo ""
    echo "3. 🔌 Kiểm tra kết nối dependencies:"
    echo "   docker exec gitlab ping postgres"
    echo "   docker exec gitlab ping redis"
    echo ""
    echo "4. 🗄️ Kiểm tra database:"
    echo "   docker exec postgres psql -U nextflow -l"
    echo ""
    echo "5. 🔄 Thử khởi động lại:"
    echo "   docker restart gitlab"
    echo ""
    echo "6. 🧹 Reset hoàn toàn (nếu cần):"
    echo "   Sử dụng option [13] RESET-ALL trong menu"
    echo ""

    log_info "💡 Nếu vẫn gặp vấn đề, hãy sử dụng option [7] STATUS để chẩn đoán chi tiết"
}

# 2. CHỨC NĂNG BACKUP GITLAB - ĐÃ TỐI ƯU
backup_gitlab() {
    log_header "BACKUP GITLAB"

    # Bước 1: Kiểm tra yêu cầu và trạng thái
    log_info "🔍 Bước 1/6: Kiểm tra yêu cầu hệ thống..."
    check_requirements

    log_info "🔍 Kiểm tra trạng thái GitLab..."
    local gitlab_status
    check_gitlab_status
    gitlab_status=$?

    if [ $gitlab_status -ne 0 ]; then
        log_error "❌ GitLab không đang chạy hoặc có vấn đề!"
        log_info "Trạng thái GitLab cần phải healthy để backup an toàn"
        log_info "Sử dụng option [7] STATUS để kiểm tra chi tiết"
        return 1
    fi

    # Bước 2: Chuẩn bị backup
    log_info "🔍 Bước 2/6: Chuẩn bị backup..."
    prepare_backup_environment

    # Bước 3: Pre-backup checks
    log_info "🔍 Bước 3/6: Kiểm tra trước khi backup..."
    if ! pre_backup_checks; then
        log_error "❌ Pre-backup checks thất bại!"
        return 1
    fi

    # Bước 4: Thực hiện backup
    log_info "🔍 Bước 4/6: Thực hiện backup dữ liệu..."
    local timestamp=$(date +%Y%m%d_%H%M%S)
    if ! perform_gitlab_backup "$timestamp"; then
        log_error "❌ Backup dữ liệu thất bại!"
        return 1
    fi

    # Bước 5: Backup cấu hình
    log_info "🔍 Bước 5/6: Backup cấu hình..."
    if ! backup_gitlab_config "$timestamp"; then
        log_warning "⚠️ Backup cấu hình thất bại, nhưng backup dữ liệu đã thành công"
    fi

    # Bước 6: Post-backup tasks
    log_info "🔍 Bước 6/6: Hoàn tất và dọn dẹp..."
    post_backup_tasks "$timestamp"

    log_success "🎉 Backup GitLab hoàn thành!"
    show_backup_summary "$timestamp"
    return 0
}

# Hàm chuẩn bị môi trường backup
prepare_backup_environment() {
    # Tạo thư mục backup
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        log_info "📁 Tạo thư mục backup: $BACKUP_DIR"
    fi

    # Kiểm tra quyền ghi
    if [ ! -w "$BACKUP_DIR" ]; then
        log_error "❌ Không có quyền ghi vào thư mục backup: $BACKUP_DIR"
        return 1
    fi

    # Kiểm tra dung lượng đĩa
    local available_space=$(df -BG "$BACKUP_DIR" 2>/dev/null | awk 'NR==2 {print $4}' | sed 's/G//' || echo "0")
    if [ "$available_space" -lt 5 ]; then
        log_warning "⚠️ Dung lượng đĩa thấp: ${available_space}GB"
        log_info "Backup GitLab có thể cần 2-5GB tùy vào kích thước dữ liệu"
        read -p "Tiếp tục backup? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
    else
        log_success "✅ Dung lượng đĩa đủ: ${available_space}GB"
    fi

    return 0
}

# Hàm kiểm tra trước backup
pre_backup_checks() {
    log_info "Kiểm tra GitLab services..."

    # Kiểm tra GitLab services đang chạy
    if ! docker exec "$GITLAB_CONTAINER" gitlab-ctl status >/dev/null 2>&1; then
        log_error "❌ GitLab services không hoạt động bình thường"
        return 1
    fi

    # Kiểm tra database connection
    if ! docker exec "$GITLAB_CONTAINER" gitlab-rails runner "ActiveRecord::Base.connection.current_database" >/dev/null 2>&1; then
        log_error "❌ Không thể kết nối database"
        return 1
    fi

    # Kiểm tra backup directory trong container
    if ! docker exec "$GITLAB_CONTAINER" test -d "/var/opt/gitlab/backups"; then
        log_error "❌ Thư mục backup trong container không tồn tại"
        return 1
    fi

    # Kiểm tra quyền backup trong container
    if ! docker exec "$GITLAB_CONTAINER" test -w "/var/opt/gitlab/backups"; then
        log_error "❌ Không có quyền ghi backup trong container"
        return 1
    fi

    log_success "✅ Tất cả pre-backup checks đã pass"
    return 0
}

# Hàm thực hiện backup GitLab
perform_gitlab_backup() {
    local timestamp="$1"
    local backup_start_time=$(date +%s)

    log_info "💾 Bắt đầu backup GitLab..."
    log_info "📅 Timestamp: $timestamp"
    log_warning "⏳ Quá trình này có thể mất 5-30 phút tùy vào kích thước dữ liệu..."
    echo ""

    # Tạo backup với progress monitoring
    local backup_pid
    docker exec "$GITLAB_CONTAINER" gitlab-backup create BACKUP="$timestamp" STRATEGY=copy &
    backup_pid=$!

    # Monitor backup progress
    local attempt=1
    local max_attempts=180  # 180 * 10s = 30 phút
    local progress_chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    local progress_index=0

    while kill -0 $backup_pid 2>/dev/null && [ $attempt -le $max_attempts ]; do
        local current_time=$(date +%s)
        local elapsed=$((current_time - backup_start_time))
        local elapsed_minutes=$((elapsed / 60))
        local elapsed_seconds=$((elapsed % 60))

        local progress_char=${progress_chars:$progress_index:1}
        progress_index=$(((progress_index + 1) % ${#progress_chars}))

        echo -ne "\r  $progress_char Đang backup... ${elapsed_minutes}m ${elapsed_seconds}s | Lần thử: $attempt/$max_attempts"

        sleep 10
        ((attempt++))
    done
    echo ""

    # Đợi process hoàn thành
    wait $backup_pid
    local backup_exit_code=$?

    local backup_end_time=$(date +%s)
    local backup_duration=$((backup_end_time - backup_start_time))
    local backup_minutes=$((backup_duration / 60))
    local backup_seconds=$((backup_duration % 60))

    if [ $backup_exit_code -eq 0 ]; then
        # Kiểm tra file backup có được tạo không
        if docker exec "$GITLAB_CONTAINER" test -f "/var/opt/gitlab/backups/${timestamp}_gitlab_backup.tar"; then
            local backup_size=$(docker exec "$GITLAB_CONTAINER" du -h "/var/opt/gitlab/backups/${timestamp}_gitlab_backup.tar" | cut -f1)
            log_success "✅ Backup dữ liệu thành công!"
            echo "  ⏱️ Thời gian backup: ${backup_minutes}m ${backup_seconds}s"
            echo "  💾 Kích thước backup: $backup_size"
            return 0
        else
            log_error "❌ File backup không được tạo!"
            return 1
        fi
    else
        log_error "❌ Backup process thất bại (exit code: $backup_exit_code)!"
        echo "  ⏱️ Thời gian thử backup: ${backup_minutes}m ${backup_seconds}s"
        return 1
    fi
}

# Hàm backup cấu hình GitLab
backup_gitlab_config() {
    local timestamp="$1"
    local config_backup="$BACKUP_DIR/config_$timestamp.tar.gz"

    log_info "📋 Backup cấu hình GitLab..."

    # Kiểm tra thư mục config có tồn tại không
    if [ ! -d "$PROJECT_DIR/gitlab/config" ]; then
        log_warning "⚠️ Thư mục config không tồn tại, bỏ qua backup config"
        return 0
    fi

    # Tạo backup config
    if tar -czf "$config_backup" -C "$PROJECT_DIR/gitlab" config 2>/dev/null; then
        local config_size=$(du -h "$config_backup" | cut -f1)
        log_success "✅ Backup cấu hình thành công!"
        echo "  📁 File: $(basename "$config_backup")"
        echo "  💾 Kích thước: $config_size"
        return 0
    else
        log_error "❌ Backup cấu hình thất bại!"
        return 1
    fi
}

# Hàm post-backup tasks
post_backup_tasks() {
    local timestamp="$1"

    # Copy backup file từ container ra host (nếu cần)
    log_info "📤 Copy backup file ra host..."
    local backup_file="${timestamp}_gitlab_backup.tar"
    local host_backup_path="$BACKUP_DIR/$backup_file"

    if docker cp "$GITLAB_CONTAINER:/var/opt/gitlab/backups/$backup_file" "$host_backup_path" 2>/dev/null; then
        log_success "✅ Đã copy backup file ra host"

        # Verify backup file integrity
        if [ -f "$host_backup_path" ] && [ -s "$host_backup_path" ]; then
            local host_backup_size=$(du -h "$host_backup_path" | cut -f1)
            log_info "  📁 File: $backup_file"
            log_info "  💾 Kích thước: $host_backup_size"
        else
            log_warning "⚠️ Backup file trên host có vấn đề"
        fi
    else
        log_warning "⚠️ Không thể copy backup file ra host"
        log_info "Backup vẫn có sẵn trong container tại: /var/opt/gitlab/backups/$backup_file"
    fi

    # Dọn dẹp backup cũ
    cleanup_old_backups
}

# Hàm dọn dẹp backup cũ
cleanup_old_backups() {
    log_info "🧹 Dọn dẹp backup cũ..."

    # Cấu hình retention
    local retention_days=7
    local retention_count=10

    # Dọn dẹp theo ngày
    log_info "Xóa backup cũ hơn $retention_days ngày..."
    local deleted_files=0

    # Dọn dẹp backup files
    if command -v find >/dev/null 2>&1; then
        deleted_files=$(find "$BACKUP_DIR" -name "*_gitlab_backup.tar" -mtime +$retention_days -delete -print 2>/dev/null | wc -l)
        find "$BACKUP_DIR" -name "config_*.tar.gz" -mtime +$retention_days -delete 2>/dev/null
    fi

    if [ "$deleted_files" -gt 0 ]; then
        log_success "✅ Đã xóa $deleted_files backup files cũ"
    else
        log_info "📋 Không có backup files cũ cần xóa"
    fi

    # Dọn dẹp theo số lượng (giữ tối đa 10 backup gần nhất)
    local backup_count=$(ls -1 "$BACKUP_DIR"/*_gitlab_backup.tar 2>/dev/null | wc -l)
    if [ "$backup_count" -gt "$retention_count" ]; then
        log_info "Giữ $retention_count backup gần nhất, xóa $(($backup_count - $retention_count)) backup cũ..."
        ls -1t "$BACKUP_DIR"/*_gitlab_backup.tar 2>/dev/null | tail -n +$((retention_count + 1)) | xargs rm -f
        ls -1t "$BACKUP_DIR"/config_*.tar.gz 2>/dev/null | tail -n +$((retention_count + 1)) | xargs rm -f
        log_success "✅ Đã dọn dẹp theo số lượng"
    fi

    # Dọn dẹp backup trong container
    log_info "Dọn dẹp backup cũ trong container..."
    docker exec "$GITLAB_CONTAINER" find /var/opt/gitlab/backups -name "*_gitlab_backup.tar" -mtime +$retention_days -delete 2>/dev/null || true
}

# Hàm hiển thị tổng kết backup
show_backup_summary() {
    local timestamp="$1"

    log_header "TỔng KẾT BACKUP"

    echo "📊 Thông tin backup:"
    echo "  🕐 Thời gian: $(date -d "${timestamp:0:8} ${timestamp:9:2}:${timestamp:11:2}:${timestamp:13:2}" "+%d/%m/%Y %H:%M:%S" 2>/dev/null || echo "$timestamp")"
    echo "  📁 Thư mục: $BACKUP_DIR"
    echo ""

    echo "📋 Danh sách files đã tạo:"

    # Backup chính
    local main_backup="$BACKUP_DIR/${timestamp}_gitlab_backup.tar"
    if [ -f "$main_backup" ]; then
        local size=$(du -h "$main_backup" | cut -f1)
        echo "  ✅ ${timestamp}_gitlab_backup.tar ($size)"
    else
        echo "  ⚠️ ${timestamp}_gitlab_backup.tar (chỉ có trong container)"
    fi

    # Config backup
    local config_backup="$BACKUP_DIR/config_${timestamp}.tar.gz"
    if [ -f "$config_backup" ]; then
        local size=$(du -h "$config_backup" | cut -f1)
        echo "  ✅ config_${timestamp}.tar.gz ($size)"
    else
        echo "  ❌ config_${timestamp}.tar.gz (thất bại)"
    fi

    echo ""
    echo "💡 Lưu ý quan trọng:"
    echo "  • Backup được giữ trong $retention_days ngày"
    echo "  • Tối đa $retention_count backup gần nhất được giữ lại"
    echo "  • Backup trong container: /var/opt/gitlab/backups/"
    echo "  • Để restore: sử dụng option [6] RESTORE"
    echo ""

    # Hiển thị tổng số backup hiện có
    local total_backups=$(ls -1 "$BACKUP_DIR"/*_gitlab_backup.tar 2>/dev/null | wc -l)
    echo "📈 Tổng số backup hiện có: $total_backups"

    if [ "$total_backups" -gt 0 ]; then
        echo ""
        echo "📋 5 backup gần nhất:"
        ls -1t "$BACKUP_DIR"/*_gitlab_backup.tar 2>/dev/null | head -5 | while read backup_file; do
            local filename=$(basename "$backup_file")
            local backup_date=$(echo "$filename" | grep -o '[0-9]\{8\}_[0-9]\{6\}')
            local formatted_date=$(date -d "${backup_date:0:8} ${backup_date:9:2}:${backup_date:11:2}:${backup_date:13:2}" "+%d/%m/%Y %H:%M:%S" 2>/dev/null || echo "$backup_date")
            local size=$(du -h "$backup_file" | cut -f1)
            echo "    📦 $filename ($size) - $formatted_date"
        done
    fi
}

# 3. CHỨC NĂNG RESTORE GITLAB - ĐÃ TỐI ƯU
restore_gitlab() {
    log_header "RESTORE GITLAB"

    # Bước 1: Kiểm tra yêu cầu và trạng thái
    log_info "🔍 Bước 1/7: Kiểm tra yêu cầu hệ thống..."
    check_requirements

    log_info "🔍 Kiểm tra trạng thái GitLab..."
    local gitlab_status
    check_gitlab_status
    gitlab_status=$?

    if [ $gitlab_status -eq 2 ]; then
        log_error "❌ GitLab container chưa được tạo!"
        log_info "Vui lòng cài đặt GitLab trước khi restore"
        log_info "Sử dụng option [3] INSTALL để cài đặt GitLab"
        return 1
    fi

    # Bước 2: Liệt kê và chọn backup
    log_info "🔍 Bước 2/7: Liệt kê backup có sẵn..."
    local selected_backup
    local backup_timestamp
    if ! select_backup_file selected_backup backup_timestamp; then
        return 1
    fi

    # Bước 3: Kiểm tra backup
    log_info "🔍 Bước 3/7: Kiểm tra backup được chọn..."
    if ! validate_backup_file "$selected_backup" "$backup_timestamp"; then
        return 1
    fi

    # Bước 4: Xác nhận restore
    log_info "🔍 Bước 4/7: Xác nhận restore..."
    if ! confirm_restore_operation "$selected_backup"; then
        return 1
    fi

    # Bước 5: Chuẩn bị restore
    log_info "🔍 Bước 5/7: Chuẩn bị restore..."
    if ! prepare_restore_environment "$selected_backup" "$backup_timestamp"; then
        return 1
    fi

    # Bước 6: Thực hiện restore
    log_info "🔍 Bước 6/7: Thực hiện restore..."
    if ! perform_gitlab_restore "$backup_timestamp"; then
        log_error "❌ Restore thất bại!"
        return 1
    fi

    # Bước 7: Kiểm tra và hoàn tất
    log_info "🔍 Bước 7/7: Kiểm tra và hoàn tất restore..."
    if verify_restore_success; then
        log_success "🎉 Restore GitLab thành công!"
        show_restore_summary "$selected_backup"
        return 0
    else
        log_error "❌ Restore có vấn đề!"
        show_restore_troubleshooting
        return 1
    fi
}

# Hàm chọn backup file
select_backup_file() {
    local -n selected_backup_ref=$1
    local -n backup_timestamp_ref=$2

    log_info "📋 Tìm kiếm backup files..."

    # Tìm backup trong thư mục host
    local host_backups=($(find "$BACKUP_DIR" -name "*_gitlab_backup.tar" -printf "%f\n" 2>/dev/null | sort -r))

    # Tìm backup trong container
    local container_backups=()
    if docker exec "$GITLAB_CONTAINER" test -d "/var/opt/gitlab/backups" 2>/dev/null; then
        mapfile -t container_backups < <(docker exec "$GITLAB_CONTAINER" find /var/opt/gitlab/backups -name "*_gitlab_backup.tar" -printf "%f\n" 2>/dev/null | sort -r)
    fi

    # Kết hợp và loại bỏ duplicate
    local all_backups=()
    for backup in "${host_backups[@]}" "${container_backups[@]}"; do
        if [[ ! " ${all_backups[@]} " =~ " ${backup} " ]]; then
            all_backups+=("$backup")
        fi
    done

    if [ ${#all_backups[@]} -eq 0 ]; then
        log_error "❌ Không tìm thấy backup nào!"
        echo ""
        log_info "💡 Các vị trí tìm kiếm:"
        echo "  • Host: $BACKUP_DIR"
        echo "  • Container: /var/opt/gitlab/backups"
        echo ""
        log_info "Để tạo backup mới, sử dụng option [5] BACKUP"
        return 1
    fi

    echo ""
    log_success "✅ Tìm thấy ${#all_backups[@]} backup files:"
    echo ""

    # Hiển thị danh sách backup với thông tin chi tiết
    for i in "${!all_backups[@]}"; do
        local backup_file="${all_backups[$i]}"
        local backup_date=$(echo "$backup_file" | grep -o '[0-9]\{8\}_[0-9]\{6\}')
        local formatted_date=$(date -d "${backup_date:0:8} ${backup_date:9:2}:${backup_date:11:2}:${backup_date:13:2}" "+%d/%m/%Y %H:%M:%S" 2>/dev/null || echo "$backup_date")

        # Kiểm tra vị trí file
        local location=""
        if [[ " ${host_backups[@]} " =~ " ${backup_file} " ]]; then
            local size=$(du -h "$BACKUP_DIR/$backup_file" 2>/dev/null | cut -f1 || echo "N/A")
            location="Host ($size)"
        fi
        if [[ " ${container_backups[@]} " =~ " ${backup_file} " ]]; then
            if [ -n "$location" ]; then
                location="$location + Container"
            else
                location="Container"
            fi
        fi

        echo "   $((i+1)). $backup_file"
        echo "      📅 Ngày tạo: $formatted_date"
        echo "      📍 Vị trí: $location"
        echo ""
    done

    read -p "Chọn backup để restore (1-${#all_backups[@]}): " choice

    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#all_backups[@]} ]; then
        log_error "❌ Lựa chọn không hợp lệ!"
        return 1
    fi

    selected_backup_ref="${all_backups[$((choice-1))]}"
    backup_timestamp_ref=$(echo "$selected_backup_ref" | grep -o '[0-9]\{8\}_[0-9]\{6\}')

    log_success "✅ Đã chọn backup: $selected_backup_ref"
    return 0
}

# Menu tương tác
show_interactive_menu() {
    while true; do
        clear
        log_header "GITLAB MANAGER - NEXTFLOW CRM-AI"
        echo ""
        echo "Chọn chức năng:"
        echo ""
        echo "   1. [CHECK] Kiểm tra GitLab images"
        echo "   2. [BUILD] Build GitLab custom image"
        echo "   3. [INSTALL] Cài đặt GitLab (auto-build nếu cần)"
        echo "   4. [INFO] Xem thông tin truy cập"
        echo ""
        echo "   💾 BACKUP & RESTORE:"
        echo "   5. [BACKUP] Sao lưu GitLab"
        echo "   6. [RESTORE] Khôi phục GitLab"
        echo ""
        echo "   🔧 TROUBLESHOOTING & FIX:"
        echo "   7. [STATUS] Kiểm tra trạng thái tổng thể"
        echo "   8. [CHECK-DB] Kiểm tra database"
        echo "   9. [CREATE-ROOT] Tạo root user mới"
        echo "   10. [RESET-ROOT] Reset root user"
        echo "   11. [CLEAN-DB] Xóa database cũ"
        echo "   12. [MIGRATE] Migrate database"
        echo "   13. [RESET-ALL] Reset toàn bộ GitLab"
        echo ""
        echo "   0. [EXIT] Thoát"
        echo ""
        echo "================================================================"
        echo ""

        read -p "Nhập lựa chọn (0-13): " choice
        echo ""

        case $choice in
            1)
                check_gitlab_images
                read -p "Nhấn Enter để tiếp tục..." -r
                ;;
            2)
                build_gitlab
                read -p "Nhấn Enter để tiếp tục..." -r
                ;;
            3)
                install_gitlab
                read -p "Nhấn Enter để tiếp tục..." -r
                ;;
            4)
                show_access_info
                read -p "Nhấn Enter để tiếp tục..." -r
                ;;
            5)
                backup_gitlab
                read -p "Nhấn Enter để tiếp tục..." -r
                ;;
            6)
                restore_gitlab
                read -p "Nhấn Enter để tiếp tục..." -r
                ;;
            7)
                check_gitlab_status_detailed
                read -p "Nhấn Enter để tiếp tục..." -r
                ;;
            8)
                check_databases
                read -p "Nhấn Enter để tiếp tục..." -r
                ;;
            9)
                create_root_user
                read -p "Nhấn Enter để tiếp tục..." -r
                ;;
            10)
                reset_root_user
                read -p "Nhấn Enter để tiếp tục..." -r
                ;;
            11)
                clean_old_databases
                read -p "Nhấn Enter để tiếp tục..." -r
                ;;
            12)
                migrate_database
                read -p "Nhấn Enter để tiếp tục..." -r
                ;;
            13)
                reset_all_gitlab
                read -p "Nhấn Enter để tiếp tục..." -r
                ;;
            0)
                log_info "Tạm biệt!"
                exit 0
                ;;
            *)
                log_error "Lựa chọn không hợp lệ! Vui lòng chọn từ 0-10."
                sleep 2
                ;;
        esac
    done
}

# Hiển thị thông tin truy cập
show_access_info() {
    log_header "THÔNG TIN TRUY CẬP GITLAB"
    echo ""
    log_info "Thông tin truy cập GitLab:"
    echo "   URL: ${GITLAB_EXTERNAL_URL:-http://localhost:8088}"
    echo "   Username: ${GITLAB_ROOT_USERNAME:-root}"
    echo "   Password: ${GITLAB_ROOT_PASSWORD:-Nex!tFlow@2025!}"
    echo "   Email: ${GITLAB_ROOT_EMAIL:-admin@nextflow.local}"
    echo ""
    log_info "Container Registry:"
    echo "   URL: ${GITLAB_REGISTRY_URL:-http://localhost:5050}"
    echo ""
    log_info "SSH Git Access:"
    echo "   SSH: ssh://git@localhost:${GITLAB_SSH_PORT:-2222}"
    echo ""
    log_info "Trạng thái GitLab:"
    if check_gitlab_status; then
        echo "   [OK] GitLab đang chạy"
    else
        echo "   [ERROR] GitLab không chạy"
    fi
    echo ""
    log_info "Version cố định: ${GITLAB_VERSION:-16.11.10-ce.0}"
}

# ============================================================================
# FIX & TROUBLESHOOTING FUNCTIONS
# ============================================================================

# Hàm kiểm tra GitLab container - ĐÃ TỐI ƯU
check_gitlab_container() {
    log_info "Đang kiểm tra GitLab container..."

    # Kiểm tra container có tồn tại không
    if ! docker ps -a --format "{{.Names}}" | grep -q "^${GITLAB_CONTAINER}$"; then
        log_error "GitLab container không tồn tại!"
        log_info "Các bước khắc phục:"
        echo "  1. Kiểm tra file docker-compose.yml có đúng không"
        echo "  2. Chạy: docker-compose --profile gitlab up -d gitlab"
        echo "  3. Hoặc sử dụng option [3] INSTALL trong menu"
        return 1
    fi

    # Kiểm tra container có đang chạy không
    if ! docker ps --format "{{.Names}}" | grep -q "^${GITLAB_CONTAINER}$"; then
        log_warning "GitLab container đã dừng!"
        log_info "Các bước khắc phục:"
        echo "  1. Khởi động: docker-compose --profile gitlab up -d gitlab"
        echo "  2. Kiểm tra logs: docker logs gitlab"
        echo "  3. Hoặc sử dụng option [3] INSTALL trong menu"
        return 1
    fi

    # Kiểm tra health status chi tiết
    local health_status=$(docker inspect "$GITLAB_CONTAINER" --format='{{.State.Health.Status}}' 2>/dev/null || echo "no-health-check")
    local container_state=$(docker inspect "$GITLAB_CONTAINER" --format='{{.State.Status}}' 2>/dev/null || echo "unknown")

    log_info "Trạng thái container: $container_state"

    case "$health_status" in
        "healthy")
            log_success "GitLab container đang khỏe mạnh"
            return 0
            ;;
        "unhealthy")
            log_error "GitLab container không khỏe mạnh!"
            log_info "Các bước khắc phục:"
            echo "  1. Kiểm tra logs: docker logs gitlab"
            echo "  2. Kiểm tra tài nguyên hệ thống (RAM, CPU, disk)"
            echo "  3. Restart container: docker restart gitlab"
            return 1
            ;;
        "starting")
            log_warning "GitLab đang trong quá trình khởi động..."
            log_info "Vui lòng đợi 5-10 phút để GitLab khởi động hoàn tất"
            return 2
            ;;
        "no-health-check")
            log_info "Container đang chạy (không có health check)"
            # Kiểm tra thêm bằng cách ping GitLab service
            if docker exec "$GITLAB_CONTAINER" gitlab-ctl status >/dev/null 2>&1; then
                log_success "GitLab services đang hoạt động"
                return 0
            else
                log_warning "GitLab services chưa sẵn sàng"
                return 2
            fi
            ;;
        *)
            log_warning "Trạng thái health không xác định: $health_status"
            return 2
            ;;
    esac
}

# Hàm kiểm tra kết nối mạng
check_network_connectivity() {
    log_info "Kiểm tra kết nối mạng..."

    # Kiểm tra Docker network
    if ! docker network ls | grep -q "demo"; then
        log_warning "Docker network 'demo' không tồn tại"
        log_info "Network sẽ được tạo tự động khi khởi động services"
    else
        log_success "Docker network 'demo' đã sẵn sàng"
    fi

    # Kiểm tra port conflicts
    local ports_to_check=(8088 2222 5050)
    local conflicted_ports=()

    for port in "${ports_to_check[@]}"; do
        if netstat -tuln 2>/dev/null | grep -q ":$port " || ss -tuln 2>/dev/null | grep -q ":$port "; then
            conflicted_ports+=("$port")
        fi
    done

    if [ ${#conflicted_ports[@]} -gt 0 ]; then
        log_warning "Phát hiện xung đột port: ${conflicted_ports[*]}"
        log_info "Các port này cần thiết cho GitLab:"
        echo "  • 8088: Web interface"
        echo "  • 2222: SSH Git operations"
        echo "  • 5050: Container Registry"
        echo ""
        echo "Khắc phục:"
        echo "  • Dừng services đang sử dụng các port này"
        echo "  • Hoặc thay đổi port trong file .env"
        return 1
    else
        log_success "Không có xung đột port"
        return 0
    fi
}

# Hàm kiểm tra biến môi trường
check_environment_variables() {
    log_info "Kiểm tra biến môi trường..."

    local required_vars=(
        "GITLAB_ROOT_PASSWORD"
        "GITLAB_ROOT_EMAIL"
        "GITLAB_DATABASE"
        "POSTGRES_USER"
        "POSTGRES_PASSWORD"
    )

    local missing_vars=()

    for var in "${required_vars[@]}"; do
        if [ -z "${!var:-}" ]; then
            missing_vars+=("$var")
        fi
    done

    if [ ${#missing_vars[@]} -gt 0 ]; then
        log_error "Thiếu các biến môi trường quan trọng:"
        for var in "${missing_vars[@]}"; do
            echo "  ❌ $var"
        done
        log_info "Vui lòng kiểm tra file .env và đảm bảo các biến này được thiết lập"
        return 1
    else
        log_success "Tất cả biến môi trường cần thiết đã được thiết lập"
        return 0
    fi
}

# Kiểm tra trạng thái tổng thể GitLab
check_gitlab_status_detailed() {
    echo "============================================"
    log_info "KIỂM TRA TRẠNG THÁI GITLAB TỔNG THỂ"
    echo "============================================"

    # 1. Kiểm tra container
    log_info "1. Container Status:"
    if docker ps | grep -q "gitlab"; then
        HEALTH_STATUS=$(docker inspect gitlab --format='{{.State.Health.Status}}' 2>/dev/null || echo "unknown")
        log_success "  ✓ Container đang chạy (health: $HEALTH_STATUS)"
    else
        log_error "  ✗ Container không chạy"
        return 1
    fi

    # 2. Kiểm tra database connection
    log_info "2. Database Connection:"
    if docker exec gitlab gitlab-rails runner "ActiveRecord::Base.connection.current_database" >/dev/null 2>&1; then
        DB_NAME=$(docker exec gitlab gitlab-rails runner "puts ActiveRecord::Base.connection.current_database" 2>/dev/null)
        log_success "  ✓ Kết nối database: $DB_NAME"
    else
        log_error "  ✗ Không kết nối được database"
    fi

    # 3. Chạy GitLab status script
    log_info "3. GitLab Status Report:"
    if [ -f "$GITLAB_SCRIPTS_DIR/gitlab_status.rb" ]; then
        docker cp "$GITLAB_SCRIPTS_DIR/gitlab_status.rb" gitlab:/tmp/
        docker exec gitlab gitlab-rails runner /tmp/gitlab_status.rb 2>/dev/null || log_warning "  ⚠ Không thể chạy status script"
        docker exec gitlab rm -f /tmp/gitlab_status.rb 2>/dev/null
    else
        # Fallback to simple check
        USER_COUNT=$(docker exec gitlab gitlab-rails runner "puts User.count" 2>/dev/null || echo "0")
        if [ "$USER_COUNT" -gt 0 ]; then
            log_success "  ✓ Có $USER_COUNT users"

            # Kiểm tra root user
            ROOT_EXISTS=$(docker exec gitlab gitlab-rails runner "puts User.find_by(username: 'root') ? 'true' : 'false'" 2>/dev/null || echo "false")
            if [ "$ROOT_EXISTS" = "true" ]; then
                log_success "  ✓ Root user đã tồn tại"
            else
                log_warning "  ⚠ Root user chưa tồn tại"
            fi
        else
            log_warning "  ⚠ Chưa có users nào (cần tạo root user)"
        fi
    fi

    # 4. Kiểm tra web access
    log_info "4. Web Access:"
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8088 | grep -q "200\|302"; then
        log_success "  ✓ Web interface accessible: http://localhost:8088"
    else
        log_warning "  ⚠ Web interface không accessible"
    fi

    echo ""
    log_info "Thông tin truy cập:"
    echo "  URL: ${GITLAB_EXTERNAL_URL:-http://localhost:8088}"
    echo "  Username: root"
    echo "  Password: ${GITLAB_ROOT_PASSWORD:-Nex!tFlow@2025!}"
    echo "  Email: ${GITLAB_ROOT_EMAIL:-nextflow.vn@gmail.com}"
}

# Kiểm tra databases
check_databases() {
    echo "============================================"
    log_info "KIỂM TRA CÁC DATABASE GITLAB"
    echo "============================================"

    log_info "Danh sách database hiện tại:"
    docker exec postgres psql -U nextflow -c "SELECT datname FROM pg_database WHERE datname LIKE '%gitlab%' OR datname LIKE '%partition%';"

    echo ""
    log_info "Kiểm tra database chính:"
    if docker exec postgres psql -U nextflow -c "SELECT 1 FROM pg_database WHERE datname = '${GITLAB_DATABASE:-nextflow_gitlab}';" | grep -q 1; then
        log_success "Database ${GITLAB_DATABASE:-nextflow_gitlab} tồn tại"

        # Kiểm tra có tables không
        table_count=$(docker exec postgres psql -U nextflow -d "${GITLAB_DATABASE:-nextflow_gitlab}" -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" -t | xargs)
        log_info "Số lượng tables: $table_count"

        if [ "$table_count" -gt 0 ]; then
            log_success "Database có dữ liệu"
        else
            log_warning "Database trống - cần migrate"
        fi
    else
        log_error "Database ${GITLAB_DATABASE:-nextflow_gitlab} không tồn tại"
    fi

    echo ""
    log_info "Kiểm tra database cũ:"
    if docker exec postgres psql -U nextflow -c "SELECT 1 FROM pg_database WHERE datname = 'gitlabhq_production';" | grep -q 1; then
        log_warning "Database cũ 'gitlabhq_production' vẫn tồn tại"
        old_table_count=$(docker exec postgres psql -U nextflow -d "gitlabhq_production" -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" -t | xargs)
        log_info "Số lượng tables trong DB cũ: $old_table_count"

        if [ "$old_table_count" -eq 0 ]; then
            log_info "Database cũ trống - có thể xóa an toàn"
        else
            log_warning "Database cũ có dữ liệu - cần backup trước khi xóa"
        fi
    else
        log_success "Không có database cũ"
    fi
}

# Xóa database cũ và partitions không dùng
clean_old_databases() {
    echo "============================================"
    log_info "XÓA DATABASE CŨ VÀ PARTITIONS"
    echo "============================================"

    # Xóa database cũ nếu trống
    if docker exec postgres psql -U nextflow -c "SELECT 1 FROM pg_database WHERE datname = 'gitlabhq_production';" | grep -q 1; then
        old_table_count=$(docker exec postgres psql -U nextflow -d "gitlabhq_production" -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" -t | xargs)

        if [ "$old_table_count" -eq 0 ]; then
            log_info "Xóa database cũ trống 'gitlabhq_production'..."
            docker exec postgres psql -U nextflow -c "DROP DATABASE IF EXISTS gitlabhq_production;" || true
            log_success "Đã xóa database cũ"
        else
            log_warning "Database cũ có dữ liệu - không xóa tự động"
            log_info "Để xóa thủ công: docker exec postgres psql -U nextflow -c \"DROP DATABASE gitlabhq_production;\""
        fi
    fi

    # Xóa các database partitions không dùng
    for db in gitlab_partitions_dynamic gitlab_partitions_static; do
        if docker exec postgres psql -U nextflow -c "SELECT 1 FROM pg_database WHERE datname = '$db';" | grep -q 1; then
            log_info "Xóa database partition không dùng: $db"
            docker exec postgres psql -U nextflow -c "DROP DATABASE IF EXISTS $db;" || true
            log_success "Đã xóa $db"
        fi
    done
}

# Reset root user
reset_root_user() {
    echo "============================================"
    log_info "RESET ROOT USER GITLAB"
    echo "============================================"

    check_gitlab_container

    log_info "Đang reset root user..."

    # Tạo script reset root
    cat > /tmp/reset_root.rb << 'EOF'
# Tìm user root
user = User.find_by(username: 'root')

if user.nil?
  puts "User root không tồn tại. Tạo user root bằng GitLab rake task..."
  puts "Chạy: docker exec gitlab gitlab-rake \"gitlab:setup\" để tạo user root"
  exit 1
else
  puts "User root đã tồn tại - đang reset password..."

  # Reset password và thông tin
  user.email = ENV['GITLAB_ROOT_EMAIL'] || 'nextflow.vn@gmail.com'
  user.password = ENV['GITLAB_ROOT_PASSWORD'] || 'Nex!tFlow@2025!'
  user.password_confirmation = ENV['GITLAB_ROOT_PASSWORD'] || 'Nex!tFlow@2025!'
  user.admin = true

  # Confirm user nếu chưa confirm
  unless user.confirmed?
    user.confirmed_at = Time.current
    user.skip_confirmation!
  end

  # Save user
  if user.save
    puts "Đã reset user root thành công!"
  else
    puts "Lỗi khi save user: #{user.errors.full_messages.join(', ')}"
    exit 1
  end
end

puts ""
puts "Root user info:"
puts "Username: #{user.username}"
puts "Email: #{user.email}"
puts "Admin: #{user.admin}"
puts "Confirmed: #{user.confirmed?}"
puts "Password đã được reset"
EOF

    # Chạy script trong GitLab
    docker cp /tmp/reset_root.rb gitlab:/tmp/reset_root.rb
    docker exec gitlab bash -c "cd /opt/gitlab && gitlab-rails runner /tmp/reset_root.rb"

    # Cleanup
    rm -f /tmp/reset_root.rb
    docker exec gitlab rm -f /tmp/reset_root.rb

    log_success "Đã reset root user thành công!"
    echo ""
    log_info "Thông tin đăng nhập:"
    echo "  URL: ${GITLAB_EXTERNAL_URL:-http://localhost:8088}"
    echo "  Username: root"
    echo "  Password: ${GITLAB_ROOT_PASSWORD:-Nex!tFlow@2025!}"
    echo "  Email: ${GITLAB_ROOT_EMAIL:-nextflow.vn@gmail.com}"
}

# Migrate database
migrate_database() {
    echo "============================================"
    log_info "MIGRATE DATABASE GITLAB"
    echo "============================================"

    check_gitlab_container

    log_info "Đang chạy database migration..."
    docker exec gitlab gitlab-rake db:migrate

    log_success "Database migration hoàn thành!"
}

# Reset toàn bộ GitLab
reset_all_gitlab() {
    echo "============================================"
    log_info "RESET TOÀN BỘ GITLAB"
    echo "============================================"

    log_warning "Thao tác này sẽ:"
    echo "  - Xóa database cũ và partitions"
    echo "  - Migrate database mới"
    echo "  - Reset root user"
    echo "  - Reconfigure GitLab"
    echo ""

    read -p "Bạn có chắc chắn muốn tiếp tục? (y/N): " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        log_info "Hủy thao tác"
        exit 0
    fi

    clean_old_databases
    migrate_database
    reset_root_user

    log_info "Reconfigure GitLab..."
    docker exec gitlab gitlab-ctl reconfigure

    log_success "Reset toàn bộ GitLab hoàn thành!"
}

# Tạo root user bằng rake task
create_root_user() {
    echo "============================================"
    log_info "TẠO ROOT USER GITLAB"
    echo "============================================"

    check_gitlab_container

    # Lấy password từ .env
    ROOT_PASSWORD="${GITLAB_ROOT_PASSWORD:-Nex!tFlow@2025!}"
    ROOT_EMAIL="${GITLAB_ROOT_EMAIL:-nextflow.vn@gmail.com}"

    log_info "Kiểm tra root user hiện tại..."

    # Kiểm tra xem root user đã tồn tại chưa
    USER_COUNT=$(docker exec gitlab gitlab-rails runner "puts User.count" 2>/dev/null || echo "0")

    if [ "$USER_COUNT" -gt 0 ]; then
        log_warning "Database đã có users. Kiểm tra root user..."
        ROOT_EXISTS=$(docker exec gitlab gitlab-rails runner "puts User.find_by(username: 'root') ? 'true' : 'false'" 2>/dev/null || echo "false")

        if [ "$ROOT_EXISTS" = "true" ]; then
            log_success "Root user đã tồn tại!"
            docker exec gitlab gitlab-rails runner "
                user = User.find_by(username: 'root')
                puts \"Username: #{user.username}\"
                puts \"Email: #{user.email}\"
                puts \"Admin: #{user.admin}\"
            " 2>/dev/null || log_warning "Không thể lấy thông tin root user"
            return 0
        fi
    fi

    log_info "Tạo root user..."
    log_info "Sử dụng email: $ROOT_EMAIL"

    # Thử sử dụng script Ruby trước
    if [ -f "$GITLAB_SCRIPTS_DIR/create_root_user.rb" ]; then
        log_info "Sử dụng script Ruby để tạo root user..."
        docker cp "$GITLAB_SCRIPTS_DIR/create_root_user.rb" gitlab:/tmp/
        if docker exec gitlab bash -c "GITLAB_ROOT_PASSWORD='$ROOT_PASSWORD' GITLAB_ROOT_EMAIL='$ROOT_EMAIL' gitlab-rails runner /tmp/create_root_user.rb"; then
            docker exec gitlab rm -f /tmp/create_root_user.rb 2>/dev/null
            log_success "Root user đã được tạo thành công!"
        else
            docker exec gitlab rm -f /tmp/create_root_user.rb 2>/dev/null
            log_warning "Script Ruby thất bại, thử seed data..."

            # Fallback to seed_fu
            if docker exec gitlab gitlab-rake db:seed_fu GITLAB_ROOT_PASSWORD="$ROOT_PASSWORD" GITLAB_ROOT_EMAIL="$ROOT_EMAIL"; then
                log_success "Seed data hoàn thành!"
            else
                log_error "Cả hai phương pháp đều thất bại"
                return 1
            fi
        fi
    else
        # Sử dụng db:seed_fu nếu không có script
        log_info "Sử dụng GitLab seed data..."
        if docker exec gitlab gitlab-rake db:seed_fu GITLAB_ROOT_PASSWORD="$ROOT_PASSWORD" GITLAB_ROOT_EMAIL="$ROOT_EMAIL"; then
            log_success "Seed data hoàn thành!"
        else
            log_error "Lỗi khi chạy seed data"
            return 1
        fi
    fi

    # Kiểm tra kết quả bằng script check
    log_info "Kiểm tra root user đã được tạo..."
    if [ -f "$GITLAB_SCRIPTS_DIR/check_root_user.rb" ]; then
        docker cp "$GITLAB_SCRIPTS_DIR/check_root_user.rb" gitlab:/tmp/
        docker exec gitlab gitlab-rails runner /tmp/check_root_user.rb
        docker exec gitlab rm -f /tmp/check_root_user.rb 2>/dev/null
    fi

    echo ""
    log_info "Thông tin đăng nhập:"
    echo "  URL: ${GITLAB_EXTERNAL_URL:-http://localhost:8088}"
    echo "  Username: root"
    echo "  Password: $ROOT_PASSWORD"
    echo "  Email: $ROOT_EMAIL"
}

# Main function
main() {
    # Nếu không có tham số, hiển thị menu tương tác
    if [ $# -eq 0 ]; then
        show_interactive_menu
        return
    fi

    # Xử lý tham số dòng lệnh
    case "${1}" in
        images)
            check_gitlab_images
            ;;
        build)
            build_gitlab
            ;;
        install)
            install_gitlab
            ;;
        info)
            show_access_info
            ;;
        backup)
            backup_gitlab
            ;;
        restore)
            restore_gitlab
            ;;
        status)
            check_gitlab_status_detailed
            ;;
        check-db)
            check_databases
            ;;
        create-root)
            create_root_user
            ;;
        reset-root)
            reset_root_user
            ;;
        clean-db)
            clean_old_databases
            ;;
        migrate)
            migrate_database
            ;;
        reset-all)
            reset_all_gitlab
            ;;
        help|*)
            echo "GitLab Manager - NextFlow CRM-AI"
            echo ""
            echo "Sử dụng: $0 [COMMAND]"
            echo ""
            echo "Commands:"
            echo "  images      - Kiểm tra GitLab images có sẵn"
            echo "  build       - Build GitLab custom image"
            echo "  install     - Cài đặt GitLab"
            echo "  info        - Xem thông tin truy cập"
            echo ""
            echo "  💾 Backup & Restore:"
            echo "  backup      - Sao lưu dữ liệu GitLab"
            echo "  restore     - Khôi phục dữ liệu GitLab từ backup"
            echo ""
            echo "  🔧 Troubleshooting & Fix:"
            echo "  status      - Kiểm tra trạng thái tổng thể GitLab"
            echo "  check-db    - Kiểm tra trạng thái database"
            echo "  create-root - Tạo root user mới (khi chưa có root)"
            echo "  reset-root  - Reset root user và password"
            echo "  clean-db    - Xóa database cũ và partitions không dùng"
            echo "  migrate     - Chạy database migration"
            echo "  reset-all   - Reset toàn bộ GitLab"
            echo ""
            echo "  help        - Hiển thị help này"
            echo ""
            echo "Chạy không tham số để vào menu tương tác: $0"
            ;;
    esac
}

# Chạy main function
main "$@"
