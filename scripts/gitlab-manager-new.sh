#!/bin/bash
# ============================================================================
# GITLAB MANAGER - SIMPLE VERSION
# ============================================================================
# Mô tả: Script quản lý GitLab đơn giản với các chức năng cơ bản
# Tác giả: NextFlow Team
# Phiên bản: 1.1.0
# ============================================================================

set -e

# Màu sắc
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Cấu hình
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
COMPOSE_FILE="$PROJECT_DIR/docker-compose.yml"
ENV_FILE="$PROJECT_DIR/.env"
GITLAB_CONTAINER="gitlab"
BACKUP_DIR="$PROJECT_DIR/gitlab/backups"

# Load environment variables
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
fi

# Hàm log đơn giản
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

# Kiểm tra Docker
check_docker() {
    if ! command -v docker > /dev/null 2>&1; then
        log_error "Docker không được cài đặt"
        log_info "Vui lòng cài đặt Docker Desktop và khởi động"
        exit 1
    fi

    if ! docker info > /dev/null 2>&1; then
        log_error "Docker daemon không chạy"
        log_info "Vui lòng khởi động Docker Desktop"
        exit 1
    fi

    log_info "Docker đã sẵn sàng"
}

# Cấu hình GitLab password policy đơn giản
configure_password_policy() {
    log_info "Cấu hình GitLab password policy đơn giản..."

    if ! docker ps | grep -q "$GITLAB_CONTAINER"; then
        log_error "GitLab container không chạy"
        return 1
    fi

    # Backup gitlab.rb hiện tại
    docker exec "$GITLAB_CONTAINER" cp /etc/gitlab/gitlab.rb /etc/gitlab/gitlab.rb.backup 2>/dev/null || true

    # Thêm cấu hình password policy vào gitlab.rb
    docker exec "$GITLAB_CONTAINER" bash -c "
    # Xóa cấu hình password cũ nếu có
    sed -i '/# NextFlow Password Policy/,/# End NextFlow Password Policy/d' /etc/gitlab/gitlab.rb

    # Thêm cấu hình mới
    cat >> /etc/gitlab/gitlab.rb << 'EOF'

# NextFlow Password Policy - Simple & User Friendly
gitlab_rails['password_authentication_enabled_for_web'] = true
gitlab_rails['password_authentication_enabled_for_git'] = true

# Disable strict password requirements
gitlab_rails['minimum_password_length'] = 8
gitlab_rails['password_complexity'] = false

# Allow simple passwords
gitlab_rails['password_blacklist_enabled'] = false
gitlab_rails['password_require_uppercase'] = false
gitlab_rails['password_require_lowercase'] = false
gitlab_rails['password_require_numbers'] = false
gitlab_rails['password_require_symbols'] = false

# End NextFlow Password Policy
EOF
    "

    log_info "Áp dụng cấu hình GitLab..."
    if docker exec "$GITLAB_CONTAINER" gitlab-ctl reconfigure; then
        log_success "Cấu hình password policy thành công!"
        log_info "GitLab hiện cho phép password đơn giản"
    else
        log_error "Lỗi cấu hình GitLab"
        return 1
    fi
}

# [CHECK] Kiểm tra GitLab images
check_images() {
    log_info "Kiểm tra GitLab images..."

    echo "=== GITLAB IMAGES ==="

    # Kiểm tra Docker trước
    if ! docker info > /dev/null 2>&1; then
        log_error "Docker daemon không chạy - không thể kiểm tra images"
        return 1
    fi

    # Kiểm tra custom image
    if docker images | grep -q "nextflow/gitlab-ce.*16.11.10-ce.0"; then
        log_success "Custom image tồn tại:"
        docker images | grep "nextflow/gitlab-ce.*16.11.10-ce.0"
    else
        log_warning "Custom image chưa được build (cần phiên bản 16.11.10-ce.0)"
    fi

    echo ""

    # Kiểm tra official image
    if docker images | grep -q "gitlab/gitlab-ce"; then
        log_info "Official images:"
        docker images | grep "gitlab/gitlab-ce"
    else
        log_warning "Chưa có official GitLab image"
    fi

    echo ""
    log_info "Để build custom image: ./scripts/gitlab-manager-new.sh build"
    echo ""
}

# [BUILD] Build GitLab custom image
build_image() {
    log_info "Building GitLab custom image..."
    
    if [ ! -f "$PROJECT_DIR/gitlab/docker/Dockerfile" ]; then
        log_error "Dockerfile không tồn tại: $PROJECT_DIR/gitlab/docker/Dockerfile"
        exit 1
    fi
    
    cd "$PROJECT_DIR"
    
    log_info "Đang build image..."
    if docker build -f gitlab/docker/Dockerfile -t nextflow/gitlab-ce:16.11.10-ce.0 .; then
        log_success "Build image thành công!"
        log_info "Image được tag: nextflow/gitlab-ce:16.11.10-ce.0"
    else
        log_error "Build image thất bại"
        exit 1
    fi
}

# [INSTALL] Cài đặt GitLab
install_gitlab() {
    log_info "Cài đặt GitLab..."
    
    # Kiểm tra custom image
    if ! docker images | grep -q "nextflow/gitlab-ce.*16.11.10-ce.0"; then
        log_warning "Custom image phiên bản 16.11.10-ce.0 chưa tồn tại, đang build..."
        build_image
    fi
    
    # Tạo thư mục cần thiết
    mkdir -p "$PROJECT_DIR/gitlab/config"
    mkdir -p "$PROJECT_DIR/gitlab/logs"
    mkdir -p "$PROJECT_DIR/gitlab/data"
    mkdir -p "$BACKUP_DIR"
    
    cd "$PROJECT_DIR"
    
    # Khởi động dependencies trước
    log_info "Khởi động PostgreSQL và Redis..."
    docker-compose up -d postgres redis
    
    # Đợi PostgreSQL sẵn sàng
    log_info "Đợi PostgreSQL sẵn sàng..."
    sleep 10
    
    # Tạo database cho GitLab
    log_info "Tạo database GitLab..."
    docker exec postgres psql -U nextflow -c "CREATE DATABASE nextflow_gitlab;" 2>/dev/null || true
    
    # Khởi động GitLab
    log_info "Khởi động GitLab..."
    docker-compose up -d gitlab
    
    log_success "GitLab đang khởi động..."
    log_info "Đợi 5-10 phút để GitLab hoàn tất khởi động"
    log_info "Kiểm tra trạng thái: docker logs gitlab"
}

# [INFO] Xem thông tin truy cập
show_info() {
    echo "=== THÔNG TIN TRUY CẬP GITLAB ==="
    echo ""
    echo "🌐 URL: ${GITLAB_EXTERNAL_URL:-http://localhost:8088}"
    echo "👤 Username: root"
    echo "🔑 Password: ${GITLAB_ROOT_PASSWORD:-Nextflow@2025}"
    echo "📧 Email: ${GITLAB_ROOT_EMAIL:-nextflow.vn@gmail.com}"
    echo ""
    echo "🐳 Container Registry: ${GITLAB_REGISTRY_URL:-http://localhost:5050}"
    echo "🔗 SSH Git: ssh://git@localhost:${GITLAB_SSH_PORT:-2222}"
    echo ""

    # Kiểm tra trạng thái container (chỉ khi Docker chạy)
    if docker info > /dev/null 2>&1; then
        if docker ps | grep -q "$GITLAB_CONTAINER"; then
            log_success "GitLab container đang chạy"
        else
            log_warning "GitLab container không chạy"
        fi
    else
        log_warning "Docker daemon không chạy - không thể kiểm tra container"
    fi
}

# Test function để kiểm tra script
test_script() {
    log_info "Testing GitLab Manager Script..."
    echo ""

    log_info "1. Kiểm tra cấu hình..."
    echo "   Project Dir: $PROJECT_DIR"
    echo "   Compose File: $COMPOSE_FILE"
    echo "   Env File: $ENV_FILE"
    echo "   Backup Dir: $BACKUP_DIR"
    echo ""

    log_info "2. Kiểm tra files..."
    if [ -f "$COMPOSE_FILE" ]; then
        log_success "docker-compose.yml tồn tại"
    else
        log_warning "docker-compose.yml không tồn tại"
    fi

    if [ -f "$ENV_FILE" ]; then
        log_success ".env file tồn tại"
    else
        log_warning ".env file không tồn tại"
    fi

    if [ -d "$PROJECT_DIR/gitlab/docker" ]; then
        log_success "GitLab docker directory tồn tại"
    else
        log_warning "GitLab docker directory không tồn tại"
    fi

    echo ""
    log_info "3. Hiển thị thông tin truy cập..."
    show_info

    echo ""
    log_success "Script test hoàn tất!"
}

# [BACKUP] Sao lưu GitLab
backup_gitlab() {
    log_info "Tạo backup GitLab..."
    
    if ! docker ps | grep -q "$GITLAB_CONTAINER"; then
        log_error "GitLab container không chạy"
        exit 1
    fi
    
    # Tạo thư mục backup
    mkdir -p "$BACKUP_DIR"
    
    # Tạo backup
    log_info "Đang tạo backup..."
    if docker exec "$GITLAB_CONTAINER" gitlab-backup create; then
        log_success "Backup được tạo thành công!"
        
        # Hiển thị backup files
        log_info "Backup files:"
        ls -la "$BACKUP_DIR"
    else
        log_error "Tạo backup thất bại"
        exit 1
    fi
}

# [RESTORE] Khôi phục GitLab từ backup
restore_gitlab() {
    log_info "Khôi phục GitLab từ backup..."
    
    if ! docker ps | grep -q "$GITLAB_CONTAINER"; then
        log_error "GitLab container không chạy"
        exit 1
    fi
    
    # Liệt kê backup files
    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
        log_error "Không tìm thấy backup files trong $BACKUP_DIR"
        exit 1
    fi
    
    echo "=== BACKUP FILES ==="
    ls -la "$BACKUP_DIR"
    echo ""
    
    read -p "Nhập tên backup file (không cần đường dẫn): " backup_file
    
    if [ ! -f "$BACKUP_DIR/$backup_file" ]; then
        log_error "Backup file không tồn tại: $backup_file"
        exit 1
    fi
    
    # Xác nhận restore
    echo ""
    log_warning "CẢNH BÁO: Restore sẽ ghi đè tất cả dữ liệu hiện tại!"
    read -p "Bạn có chắc chắn muốn restore? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        log_info "Hủy restore"
        exit 0
    fi
    
    # Thực hiện restore
    backup_timestamp=$(echo "$backup_file" | grep -o '[0-9]\{10\}_[0-9]\{4\}_[0-9]\{2\}_[0-9]\{2\}_[0-9]\{2\}\.[0-9]\{2\}\.[0-9]\{2\}')
    
    log_info "Đang restore backup: $backup_timestamp"
    if docker exec "$GITLAB_CONTAINER" gitlab-backup restore BACKUP="$backup_timestamp"; then
        log_success "Restore thành công!"
        log_info "Khởi động lại GitLab..."
        docker restart "$GITLAB_CONTAINER"
    else
        log_error "Restore thất bại"
        exit 1
    fi
}

# [CREATE-ROOT] Tạo/quản lý root user
create_root_user() {
    log_info "Tạo/quản lý root user..."

    if ! docker ps | grep -q "$GITLAB_CONTAINER"; then
        log_error "GitLab container không chạy"
        exit 1
    fi

    # Kiểm tra GitLab có sẵn sàng không
    log_info "Kiểm tra trạng thái GitLab..."
    if ! docker exec "$GITLAB_CONTAINER" gitlab-ctl status >/dev/null 2>&1; then
        log_warning "GitLab services chưa sẵn sàng"
        log_info "Vui lòng đợi GitLab hoàn tất khởi động (5-10 phút)"
        return 1
    fi

    log_info "Kiểm tra root user hiện tại..."

    # Kiểm tra user đơn giản
    if docker exec "$GITLAB_CONTAINER" gitlab-rails runner "exit(User.where(username: 'root').exists? ? 0 : 1)" 2>/dev/null; then
        log_success "Root user đã tồn tại"

        # Hiển thị thông tin user
        log_info "Thông tin root user:"
        docker exec "$GITLAB_CONTAINER" gitlab-rails runner "
        user = User.find_by(username: 'root')
        puts \"  👤 Username: #{user.username}\"
        puts \"  📧 Email: #{user.email}\"
        puts \"  🔑 Admin: #{user.admin}\"
        puts \"  ✅ State: #{user.state}\"
        " 2>/dev/null

        echo "  🔑 Password: ${GITLAB_ROOT_PASSWORD:-Nextflow@2025}"
        echo "  🌐 URL: ${GITLAB_EXTERNAL_URL:-http://localhost:8088}"
    else
        log_warning "Root user chưa tồn tại, đang tạo bằng GitLab seed..."

        # Cấu hình password policy trước khi tạo user
        log_info "Cấu hình password policy cho phép password đơn giản..."
        configure_password_policy

        # Sử dụng GitLab seed_fu với environment variables
        log_info "Chạy GitLab database seeding..."
        if docker exec "$GITLAB_CONTAINER" gitlab-rake db:seed_fu GITLAB_ROOT_PASSWORD="${GITLAB_ROOT_PASSWORD:-Nextflow@2025}" GITLAB_ROOT_EMAIL="${GITLAB_ROOT_EMAIL:-nextflow.vn@gmail.com}"; then
            log_success "✅ Database seeding thành công"
            log_info "Root user đã được tạo!"
            log_info "Thông tin truy cập:"
            echo "  👤 Username: root"
            echo "  🔑 Password: ${GITLAB_ROOT_PASSWORD:-Nextflow@2025}"
            echo "  📧 Email: ${GITLAB_ROOT_EMAIL:-nextflow.vn@gmail.com}"
            echo "  🌐 URL: ${GITLAB_EXTERNAL_URL:-http://localhost:8088}"
        else
            log_warning "⚠️ Database seeding có vấn đề - thử phương pháp backup"

            # Fallback: Tạo user trực tiếp
            log_info "Thử tạo user trực tiếp..."
            if docker exec "$GITLAB_CONTAINER" gitlab-rails runner "
            puts 'Creating root user...'
            user = User.create!(
              username: 'root',
              email: '${GITLAB_ROOT_EMAIL:-nextflow.vn@gmail.com}',
              name: 'Administrator',
              password: '${GITLAB_ROOT_PASSWORD:-Nextflow@2025}',
              password_confirmation: '${GITLAB_ROOT_PASSWORD:-Nextflow@2025}',
              admin: true,
              confirmed_at: Time.current,
              state: 'active'
            )
            user.skip_confirmation!
            puts 'Root user created successfully!'
            "; then
                log_success "Root user được tạo thành công bằng fallback method!"
                log_info "Thông tin truy cập:"
                echo "  👤 Username: root"
                echo "  🔑 Password: ${GITLAB_ROOT_PASSWORD:-Nextflow@2025}"
                echo "  📧 Email: ${GITLAB_ROOT_EMAIL:-nextflow.vn@gmail.com}"
                echo "  🌐 URL: ${GITLAB_EXTERNAL_URL:-http://localhost:8088}"
            else
                log_error "Không thể tạo root user"
            fi
        fi
    fi
}

# [RESET-ROOT] Reset password root user
reset_root_password() {
    log_info "Reset password root user..."

    if ! docker ps | grep -q "$GITLAB_CONTAINER"; then
        log_error "GitLab container không chạy"
        exit 1
    fi

    # Kiểm tra GitLab có sẵn sàng không
    log_info "Kiểm tra trạng thái GitLab..."
    if ! docker exec "$GITLAB_CONTAINER" gitlab-ctl status >/dev/null 2>&1; then
        log_warning "GitLab services chưa sẵn sàng"
        log_info "Vui lòng đợi GitLab hoàn tất khởi động"
        return 1
    fi

    # Kiểm tra root user có tồn tại không
    log_info "Kiểm tra root user..."
    user_count=$(docker exec "$GITLAB_CONTAINER" gitlab-rails runner "puts User.where(username: 'root').count" 2>/dev/null || echo "0")

    if [ "$user_count" -eq 0 ]; then
        log_error "Root user không tồn tại!"
        log_info "Vui lòng tạo root user trước: ./scripts/gitlab-manager-new.sh create-root"
        return 1
    fi

    # Nhập password mới
    echo ""
    read -s -p "Nhập password mới cho root (Enter để dùng mặc định): " new_password
    echo ""

    if [ -z "$new_password" ]; then
        new_password="${GITLAB_ROOT_PASSWORD:-Nextflow@2025@dev}"
        log_info "Sử dụng password mặc định"
    fi

    # Xác nhận reset
    echo ""
    log_warning "Bạn có chắc chắn muốn reset password cho root user?"
    read -p "Nhập 'yes' để xác nhận: " confirm

    if [ "$confirm" != "yes" ]; then
        log_info "Hủy reset password"
        return 0
    fi

    # Tạo seed file để reset password
    log_info "Tạo password reset seed..."
    docker exec "$GITLAB_CONTAINER" bash -c "mkdir -p /opt/gitlab/embedded/service/gitlab-rails/db/fixtures/production"

    docker exec "$GITLAB_CONTAINER" bash -c "cat > /opt/gitlab/embedded/service/gitlab-rails/db/fixtures/production/002_reset_root_password.rb << 'EOF'
# GitLab Root Password Reset Seed
puts 'Resetting root user password...'

# Find root user
root_user = User.find_by(username: 'root')
unless root_user
  puts '✗ Root user không tồn tại!'
  exit 1
end

puts \"Đang reset password cho user: #{root_user.email}\"

begin
  # Update password using proper GitLab methods
  root_user.password = '$new_password'
  root_user.password_confirmation = '$new_password'
  root_user.password_automatically_set = false
  root_user.password_expires_at = nil

  # Save with validation
  if root_user.save!
    puts \"✅ Password đã được reset thành công!\"
    puts \"   Username: #{root_user.username}\"
    puts \"   Email: #{root_user.email}\"
    puts \"   New password: $new_password\"
    puts \"   Admin: #{root_user.admin}\"
    puts \"   State: #{root_user.state}\"
  else
    puts \"✗ Lỗi validation: #{root_user.errors.full_messages.join(', ')}\"
    exit 1
  end

rescue => e
  puts \"✗ Lỗi reset password: #{e.message}\"
  puts \"   Backtrace: #{e.backtrace.first(3).join(', ')}\"
  exit 1
end
EOF"

    # Sử dụng rails runner trực tiếp (đã test thành công)
    log_info "Thực hiện reset password bằng Rails runner..."
    if docker exec "$GITLAB_CONTAINER" gitlab-rails runner "
    user = User.find_by(username: 'root')
    unless user
      puts '✗ Root user không tồn tại!'
      exit 1
    end

    puts \"Đang reset password cho user: #{user.email}\"

    # Update password với bypass validation
    user.password = '$new_password'
    user.password_confirmation = '$new_password'
    user.password_automatically_set = false

    if user.save(validate: false)
      puts '✅ Password đã được reset thành công!'
      puts \"   Username: #{user.username}\"
      puts \"   Email: #{user.email}\"
      puts \"   New password: $new_password\"
      puts \"   Password hash updated: #{user.reload.encrypted_password[0..20]}...\"
    else
      puts '✗ Lỗi reset password!'
      exit 1
    end
    "; then
        log_success "✅ Reset password thành công!"
        log_info "Thông tin truy cập mới:"
        echo "  👤 Username: root"
        echo "  🔑 New Password: $new_password"
        echo "  📧 Email: nextflow.vn@gmail.com"
        echo "  🌐 URL: ${GITLAB_EXTERNAL_URL:-http://localhost:8088}"
    else
        log_warning "⚠️ Rails runner có vấn đề - thử GitLab rake task..."

        # Fallback: Thử GitLab rake task (có thể cần manual input)
        log_info "Thử reset bằng GitLab rake task..."
        log_warning "Lưu ý: Task này có thể yêu cầu nhập password manual"

        if echo "$new_password" | docker exec -i "$GITLAB_CONTAINER" gitlab-rake "gitlab:password:reset[root]"; then
            log_success "Password được reset bằng GitLab rake!"
            log_info "Thông tin truy cập mới:"
            echo "  👤 Username: root"
            echo "  🔑 New Password: $new_password"
            echo "  📧 Email: nextflow.vn@gmail.com"
            echo "  🌐 URL: ${GITLAB_EXTERNAL_URL:-http://localhost:8088}"
        else
            log_error "Không thể reset password bằng cả 2 phương pháp"
            log_info "Vui lòng thử reset manual qua GitLab console:"
            echo "  docker exec -it gitlab gitlab-rails console"
            echo "  user = User.find_by(username: 'root')"
            echo "  user.password = '$new_password'"
            echo "  user.password_confirmation = '$new_password'"
            echo "  user.save(validate: false)"
        fi
    fi
}

# Menu chính
show_menu() {
    echo ""
    echo "=== GITLAB MANAGER - SIMPLE VERSION ==="
    echo ""
    echo "1. [CHECK] Kiểm tra GitLab images"
    echo "2. [BUILD] Build GitLab custom image"
    echo "3. [INSTALL] Cài đặt GitLab"
    echo "4. [INFO] Xem thông tin truy cập"
    echo "5. [BACKUP] Sao lưu GitLab"
    echo "6. [RESTORE] Khôi phục GitLab từ backup"
    echo "7. [CREATE-ROOT] Tạo/quản lý root user"
    echo "8. [RESET-ROOT] Reset password root user"
    echo "9. [CONFIG] Cấu hình password policy đơn giản"
    echo "10. Thoát"
    echo ""
}

# Xử lý tham số command line
case "${1:-}" in
    "check"|"images")
        check_docker
        check_images
        ;;
    "test-check")
        # Test check images mà không cần Docker chạy
        check_images
        ;;
    "build")
        check_docker
        build_image
        ;;
    "install")
        check_docker
        install_gitlab
        ;;
    "info")
        show_info
        ;;
    "backup")
        check_docker
        backup_gitlab
        ;;
    "restore")
        check_docker
        restore_gitlab
        ;;
    "create-root")
        check_docker
        create_root_user
        ;;
    "reset-root")
        check_docker
        reset_root_password
        ;;
    "config")
        check_docker
        configure_password_policy
        ;;
    "")
        # Menu tương tác
        while true; do
            show_menu
            read -p "Chọn chức năng (1-10): " choice
            
            case $choice in
                1)
                    check_docker
                    check_images
                    ;;
                2)
                    check_docker
                    build_image
                    ;;
                3)
                    check_docker
                    install_gitlab
                    ;;
                4)
                    show_info
                    ;;
                5)
                    check_docker
                    backup_gitlab
                    ;;
                6)
                    check_docker
                    restore_gitlab
                    ;;
                7)
                    check_docker
                    create_root_user
                    ;;
                8)
                    check_docker
                    reset_root_password
                    ;;
                9)
                    check_docker
                    configure_password_policy
                    ;;
                10)
                    log_info "Thoát chương trình"
                    exit 0
                    ;;
                *)
                    log_error "Lựa chọn không hợp lệ"
                    ;;
            esac
            
            echo ""
            read -p "Nhấn Enter để tiếp tục..."
        done
        ;;
    *)
        echo "Sử dụng: $0 [check|build|install|info|backup|restore|create-root|reset-root|config]"
        echo "Hoặc chạy không tham số để vào menu tương tác"
        exit 1
        ;;
esac
