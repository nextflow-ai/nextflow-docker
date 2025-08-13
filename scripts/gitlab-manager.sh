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

# Hàm kiểm tra yêu cầu hệ thống
check_requirements() {
    log_info "Kiểm tra yêu cầu hệ thống..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker chưa được cài đặt!"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose chưa được cài đặt!"
        exit 1
    fi
    
    if [ ! -f "$COMPOSE_FILE" ]; then
        log_error "Không tìm thấy file docker-compose.yml"
        exit 1
    fi
    
    log_success "Yêu cầu hệ thống đã đủ!"
}

# Hàm kiểm tra trạng thái GitLab
check_gitlab_status() {
    if docker ps --format "table {{.Names}}" | grep -q "^${GITLAB_CONTAINER}$"; then
        return 0  # GitLab đang chạy
    else
        return 1  # GitLab không chạy
    fi
}

# Hàm đợi GitLab sẵn sàng
wait_for_gitlab() {
    local max_attempts=60
    local attempt=1
    
    log_info "Đợi GitLab khởi động hoàn toàn (có thể mất 5-10 phút)..."
    
    while [ $attempt -le $max_attempts ]; do
        if docker exec "$GITLAB_CONTAINER" gitlab-ctl status > /dev/null 2>&1; then
            if curl -f -s "http://localhost:8088/-/health" > /dev/null 2>&1; then
                log_success "GitLab đã sẵn sàng!"
                return 0
            fi
        fi
        
        echo -ne "\r[WAIT] Lần thử $attempt/$max_attempts - Đợi GitLab khởi động..."
        sleep 10
        attempt=$((attempt + 1))
    done
    
    echo ""
    log_error "GitLab không khởi động được sau $max_attempts lần thử!"
    return 1
}

# Kiểm tra GitLab images có sẵn
check_gitlab_images() {
    log_header "KIỂM TRA GITLAB IMAGES"
    
    log_info "Kiểm tra GitLab images có sẵn..."
    echo ""
    
    local has_custom=false
    local has_official=false
    
    # Kiểm tra custom image
    if docker images nextflow/gitlab-ce:latest --format "{{.Repository}}" | grep -q "nextflow/gitlab-ce"; then
        has_custom=true
        custom_info=$(docker images nextflow/gitlab-ce:latest --format "{{.ID}} {{.Size}}" | head -1)
        echo "   [OK] Custom Image: nextflow/gitlab-ce:latest"
        echo "        ID: $(echo $custom_info | cut -d' ' -f1)"
        echo "        Size: $(echo $custom_info | cut -d' ' -f2)"
    fi
    
    # Kiểm tra official image
    if docker images gitlab/gitlab-ce --format "{{.Repository}}" | grep -q "gitlab/gitlab-ce"; then
        has_official=true
        official_info=$(docker images gitlab/gitlab-ce --format "{{.Tag}} {{.ID}} {{.Size}}" | head -1)
        echo "   [OK] Official Image: gitlab/gitlab-ce:$(echo $official_info | cut -d' ' -f1)"
        echo "        ID: $(echo $official_info | cut -d' ' -f2)"
        echo "        Size: $(echo $official_info | cut -d' ' -f3)"
    fi
    
    echo ""
    
    if [ "$has_custom" = false ] && [ "$has_official" = false ]; then
        log_error "Không tìm thấy GitLab image nào!"
        return 1
    fi
    
    return 0
}

# CHỨC NĂNG BUILD GITLAB IMAGE
build_gitlab() {
    log_header "BUILD GITLAB CUSTOM IMAGE"
    
    check_requirements
    
    # Kiểm tra Dockerfile
    if [ ! -f "$PROJECT_DIR/gitlab/docker/Dockerfile" ]; then
        log_error "Không tìm thấy Dockerfile tại: $PROJECT_DIR/gitlab/docker/Dockerfile"
        exit 1
    fi
    
    log_info "Build GitLab custom image (Version: ${GITLAB_VERSION:-16.11.10-ce.0})..."
    log_info "Context: $PROJECT_DIR/gitlab/docker"
    
    # Build image với docker-compose
    if docker-compose -f "$COMPOSE_FILE" build gitlab; then
        log_success "Build GitLab image thành công!"
        
        # Hiển thị thông tin image
        image_info=$(docker images nextflow/gitlab-ce:latest --format "{{.ID}} {{.Size}}" | head -1)
        if [ -n "$image_info" ]; then
            image_id=$(echo "$image_info" | cut -d' ' -f1)
            image_size=$(echo "$image_info" | cut -d' ' -f2)
            log_info "Image ID: $image_id"
            log_info "Image Size: $image_size"
        fi
    else
        log_error "Build GitLab image thất bại!"
        exit 1
    fi
}

# 1. CHỨC NĂNG CÀI ĐẶT GITLAB
install_gitlab() {
    log_header "CÀI ĐẶT GITLAB NEXTFLOW"
    
    check_requirements
    
    # Kiểm tra xem GitLab đã chạy chưa
    if check_gitlab_status; then
        log_warning "GitLab đã đang chạy!"
        read -p "Bạn có muốn khởi động lại không? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "Khởi động lại GitLab..."
            docker-compose -f "$COMPOSE_FILE" restart gitlab
        fi
        return 0
    fi
    
    # Kiểm tra image có sẵn
    has_custom_image=false
    has_official_image=false
    
    if docker images nextflow/gitlab-ce:latest --format "{{.Repository}}" | grep -q "nextflow/gitlab-ce"; then
        has_custom_image=true
        log_success "Tìm thấy custom image: nextflow/gitlab-ce:latest"
    fi
    
    if docker images gitlab/gitlab-ce --format "{{.Repository}}" | grep -q "gitlab/gitlab-ce"; then
        has_official_image=true
        log_success "Tìm thấy official image: gitlab/gitlab-ce"
    fi
    
    # Nếu không có image nào
    if [ "$has_custom_image" = false ] && [ "$has_official_image" = false ]; then
        log_error "Không tìm thấy GitLab image nào!"
        log_info "Hãy pull image official hoặc build custom image"
        exit 1
    fi
    
    # Nếu chỉ có official image, hỏi có muốn build custom không
    if [ "$has_custom_image" = false ] && [ "$has_official_image" = true ]; then
        log_warning "Chỉ có official image gitlab/gitlab-ce"
        log_info "Custom image sẽ có thêm NextFlow scripts và cấu hình tối ưu"
        read -p "Bạn có muốn build custom image không? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            build_gitlab
        else
            log_info "Sẽ sử dụng official image gitlab/gitlab-ce"
            log_warning "Lưu ý: Sẽ thiếu một số tính năng NextFlow custom"
        fi
    fi
    
    # Tạo thư mục cần thiết
    log_info "Tạo thư mục GitLab..."
    mkdir -p "$PROJECT_DIR/gitlab/"{config,logs,data,backups}
    
    # Khởi động dependencies trước
    log_info "Khởi động PostgreSQL và Redis..."
    docker-compose -f "$COMPOSE_FILE" up -d postgres redis
    
    # Đợi dependencies sẵn sàng
    log_info "Đợi PostgreSQL và Redis sẵn sàng..."
    sleep 15
    
    # Tạo database cho GitLab
    log_info "Tạo database cho GitLab..."
    docker exec postgres psql -U nextflow -c "SELECT 1 FROM pg_database WHERE datname = 'gitlabhq_production';" | grep -q 1 || \
    docker exec postgres psql -U nextflow -c "CREATE DATABASE gitlabhq_production;" || true
    
    # Khởi động GitLab
    log_info "Khởi động GitLab..."
    docker-compose -f "$COMPOSE_FILE" --profile gitlab up -d gitlab
    
    # Đợi GitLab sẵn sàng
    if wait_for_gitlab; then
        log_success "GitLab đã được cài đặt thành công!"
        echo ""
        log_info "Thông tin truy cập:"
        echo "   URL: ${GITLAB_EXTERNAL_URL:-http://localhost:8088}"
        echo "   Username: ${GITLAB_ROOT_USERNAME:-root}"
        echo "   Password: ${GITLAB_ROOT_PASSWORD:-nextflow@2025}"
        echo "   Email: ${GITLAB_ROOT_EMAIL:-admin@nextflow.local}"
        echo ""
        log_info "Container Registry: ${GITLAB_REGISTRY_URL:-http://localhost:5050}"
        log_info "SSH Git: ssh://git@localhost:2222"
    else
        log_error "Cài đặt GitLab thất bại!"
        exit 1
    fi
}

# 2. CHỨC NĂNG BACKUP GITLAB
backup_gitlab() {
    log_header "BACKUP GITLAB"

    check_requirements

    if ! check_gitlab_status; then
        log_error "GitLab không đang chạy!"
        exit 1
    fi

    # Tạo thư mục backup
    mkdir -p "$BACKUP_DIR"

    timestamp=$(date +%Y%m%d_%H%M%S)

    log_info "Bắt đầu backup GitLab..."
    log_info "Timestamp: $timestamp"

    # Tạo backup GitLab
    log_info "Tạo backup dữ liệu GitLab..."
    docker exec "$GITLAB_CONTAINER" gitlab-backup create BACKUP="$timestamp" STRATEGY=copy

    # Kiểm tra xem backup file có được tạo không
    if docker exec "$GITLAB_CONTAINER" ls -la "/var/opt/gitlab/backups/${timestamp}_gitlab_backup.tar" > /dev/null 2>&1; then
        log_success "Backup dữ liệu thành công!"
        log_warning "Lưu ý: Có thể có warning về database version nhưng backup vẫn hoàn thành"
    else
        log_error "Backup dữ liệu thất bại!"
        exit 1
    fi

    # Backup cấu hình
    log_info "Backup cấu hình GitLab..."
    config_backup="$BACKUP_DIR/config_$timestamp.tar.gz"

    if tar -czf "$config_backup" -C "$PROJECT_DIR/gitlab" config 2>/dev/null; then
        log_success "Backup cấu hình thành công: $(basename "$config_backup")"
    else
        log_warning "Backup cấu hình thất bại!"
    fi

    # Hiển thị thông tin backup
    log_success "Backup hoàn thành!"
    echo ""
    log_info "Thư mục backup: $BACKUP_DIR"
    log_info "File backup chính: ${timestamp}_gitlab_backup.tar"
    log_info "File backup cấu hình: config_${timestamp}.tar.gz"

    # Dọn dẹp backup cũ (giữ 7 ngày)
    log_info "Dọn dẹp backup cũ (giữ 7 ngày)..."
    find "$BACKUP_DIR" -name "*_gitlab_backup.tar" -mtime +7 -delete 2>/dev/null || true
    find "$BACKUP_DIR" -name "config_*.tar.gz" -mtime +7 -delete 2>/dev/null || true

    log_success "Dọn dẹp backup cũ hoàn thành!"
}

# 3. CHỨC NĂNG RESTORE GITLAB
restore_gitlab() {
    log_header "RESTORE GITLAB"

    check_requirements

    if ! check_gitlab_status; then
        log_error "GitLab không đang chạy! Hãy cài đặt trước."
        exit 1
    fi

    # Liệt kê backup có sẵn
    log_info "Danh sách backup có sẵn:"
    echo ""

    backups=($(find "$BACKUP_DIR" -name "*_gitlab_backup.tar" -printf "%f\n" 2>/dev/null | sort -r))

    if [ ${#backups[@]} -eq 0 ]; then
        log_error "Không tìm thấy backup nào!"
        exit 1
    fi

    # Hiển thị danh sách backup
    for i in "${!backups[@]}"; do
        backup_file="${backups[$i]}"
        backup_date=$(echo "$backup_file" | grep -o '[0-9]\{8\}_[0-9]\{6\}')
        formatted_date=$(date -d "${backup_date:0:8} ${backup_date:9:2}:${backup_date:11:2}:${backup_date:13:2}" "+%d/%m/%Y %H:%M:%S" 2>/dev/null || echo "$backup_date")
        echo "   $((i+1)). $backup_file (${formatted_date})"
    done

    echo ""
    read -p "Chọn backup để restore (1-${#backups[@]}): " choice

    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#backups[@]} ]; then
        log_error "Lựa chọn không hợp lệ!"
        exit 1
    fi

    selected_backup="${backups[$((choice-1))]}"
    backup_timestamp=$(echo "$selected_backup" | grep -o '[0-9]\{8\}_[0-9]\{6\}')

    log_warning "CẢNH BÁO: Restore sẽ ghi đè dữ liệu hiện tại!"
    read -p "Bạn có chắc chắn muốn restore backup '$selected_backup'? (y/N): " -n 1 -r
    echo

    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Hủy restore."
        exit 0
    fi

    # Dừng GitLab services
    log_info "Dừng GitLab services để restore..."
    docker exec "$GITLAB_CONTAINER" gitlab-ctl stop unicorn 2>/dev/null || true
    docker exec "$GITLAB_CONTAINER" gitlab-ctl stop puma 2>/dev/null || true
    docker exec "$GITLAB_CONTAINER" gitlab-ctl stop sidekiq 2>/dev/null || true

    # Restore backup
    log_info "Restore backup: $selected_backup"
    if docker exec "$GITLAB_CONTAINER" gitlab-backup restore BACKUP="$backup_timestamp" force=yes; then
        log_success "Restore dữ liệu thành công!"
    else
        log_error "Restore dữ liệu thất bại!"
        exit 1
    fi

    # Khởi động lại GitLab
    log_info "Khởi động lại GitLab..."
    docker exec "$GITLAB_CONTAINER" gitlab-ctl restart

    # Đợi GitLab sẵn sàng
    if wait_for_gitlab; then
        log_success "Restore GitLab thành công!"
        log_info "Kiểm tra dữ liệu tại: http://localhost:8088"
    else
        log_error "GitLab không khởi động được sau restore!"
        exit 1
    fi
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
        echo "   4. [UPDATE] Cập nhật GitLab"
        echo "   5. [BACKUP] Backup GitLab"
        echo "   6. [RESTORE] Restore GitLab"
        echo "   7. [INFO] Xem thông tin truy cập"
        echo "   0. [EXIT] Thoát"
        echo ""
        echo "================================================================"
        echo ""

        read -p "Nhập lựa chọn (0-7): " choice
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
                echo "Chức năng update sẽ được thêm..."
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
                show_access_info
                read -p "Nhấn Enter để tiếp tục..." -r
                ;;
            0)
                log_info "Tạm biệt!"
                exit 0
                ;;
            *)
                log_error "Lựa chọn không hợp lệ! Vui lòng chọn từ 0-7."
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
    echo "   Password: ${GITLAB_ROOT_PASSWORD:-nextflow@2025}"
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
        help|*)
            echo "GitLab Manager - NextFlow CRM-AI"
            echo ""
            echo "Sử dụng: $0 [COMMAND]"
            echo ""
            echo "Commands:"
            echo "  images    - Kiểm tra GitLab images có sẵn"
            echo "  build     - Build GitLab custom image"
            echo "  install   - Cài đặt GitLab"
            echo "  info      - Xem thông tin truy cập"
            echo "  help      - Hiển thị help này"
            echo ""
            echo "Chạy không tham số để vào menu tương tác: $0"
            ;;
    esac
}

# Chạy main function
main "$@"
