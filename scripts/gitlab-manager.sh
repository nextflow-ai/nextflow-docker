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
    local custom_image="nextflow/gitlab-ce:${GITLAB_VERSION:-16.11.10-ce.0}"
    if docker images "$custom_image" --format "{{.Repository}}" | grep -q "nextflow/gitlab-ce"; then
        has_custom=true
        custom_info=$(docker images "$custom_image" --format "{{.ID}} {{.Size}}" | head -1)
        echo "   [OK] Custom Image: $custom_image"
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
        local custom_image="nextflow/gitlab-ce:${GITLAB_VERSION:-16.11.10-ce.0}"
        image_info=$(docker images "$custom_image" --format "{{.ID}} {{.Size}}" | head -1)
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
    
    local custom_image="nextflow/gitlab-ce:${GITLAB_VERSION:-16.11.10-ce.0}"
    if docker images "$custom_image" --format "{{.Repository}}" | grep -q "nextflow/gitlab-ce"; then
        has_custom_image=true
        log_success "Tìm thấy custom image: $custom_image"
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
    docker exec postgres psql -U nextflow -c "SELECT 1 FROM pg_database WHERE datname = 'nextflow_gitlab';" | grep -q 1 || \
    docker exec postgres psql -U nextflow -c "CREATE DATABASE nextflow_gitlab;" || true
    
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
        echo "   Password: ${GITLAB_ROOT_PASSWORD:-Nex!tFlow@2025!}"
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
        echo "   4. [INFO] Xem thông tin truy cập"
        echo ""
        echo "   🔧 TROUBLESHOOTING & FIX:"
        echo "   5. [STATUS] Kiểm tra trạng thái tổng thể"
        echo "   6. [CHECK-DB] Kiểm tra database"
        echo "   7. [CREATE-ROOT] Tạo root user mới"
        echo "   8. [RESET-ROOT] Reset root user"
        echo "   9. [CLEAN-DB] Xóa database cũ"
        echo "   10. [MIGRATE] Migrate database"
        echo "   11. [RESET-ALL] Reset toàn bộ GitLab"
        echo ""
        echo "   0. [EXIT] Thoát"
        echo ""
        echo "================================================================"
        echo ""

        read -p "Nhập lựa chọn (0-10): " choice
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
                check_gitlab_status
                read -p "Nhấn Enter để tiếp tục..." -r
                ;;
            6)
                check_databases
                read -p "Nhấn Enter để tiếp tục..." -r
                ;;
            7)
                create_root_user
                read -p "Nhấn Enter để tiếp tục..." -r
                ;;
            8)
                reset_root_user
                read -p "Nhấn Enter để tiếp tục..." -r
                ;;
            9)
                clean_old_databases
                read -p "Nhấn Enter để tiếp tục..." -r
                ;;
            10)
                migrate_database
                read -p "Nhấn Enter để tiếp tục..." -r
                ;;
            11)
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

# Kiểm tra GitLab container đang chạy
check_gitlab_container() {
    # Kiểm tra container có tồn tại không
    if ! docker ps -a | grep -q "gitlab"; then
        log_error "GitLab container không tồn tại!"
        log_info "Tạo GitLab: docker-compose up -d gitlab"
        exit 1
    fi

    # Kiểm tra container có đang chạy không
    if ! docker ps | grep -q "gitlab"; then
        log_warning "GitLab container đã dừng!"
        log_info "Khởi động GitLab: docker-compose up -d gitlab"
        exit 1
    fi

    # Kiểm tra health status
    HEALTH_STATUS=$(docker inspect gitlab --format='{{.State.Health.Status}}' 2>/dev/null || echo "unknown")
    if [ "$HEALTH_STATUS" != "healthy" ]; then
        log_warning "GitLab container chưa healthy (status: $HEALTH_STATUS)"
        log_info "Đợi GitLab khởi động hoàn tất..."
    fi
}

# Kiểm tra trạng thái tổng thể GitLab
check_gitlab_status() {
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
        status)
            check_gitlab_status
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
