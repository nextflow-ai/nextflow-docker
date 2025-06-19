#!/bin/bash

# GitLab Management Script - Tối ưu hóa v2.1
# Quản lý GitLab CE với shared infrastructure (PostgreSQL & Redis)
# Author: NextFlow Team
# Version: 2.1 - Tối ưu hóa hiệu suất và UX

set -euo pipefail

# === CẤU HÌNH CƠ BẢN ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Import utilities
source "$SCRIPT_DIR/utils/logging.sh"
source "$SCRIPT_DIR/utils/docker.sh"
source "$SCRIPT_DIR/utils/validation.sh"

# === BIẾN TOÀN CỤC ===
COMPOSE_FILE="${COMPOSE_FILE:-$PROJECT_ROOT/docker-compose.yml}"
GITLAB_PROFILE="gitlab"
GITLAB_DB="gitlabhq_production"
GITLAB_CONTAINER="gitlab"
ACTION=""
FOLLOW_LOGS=false

# Timeout cho các thao tác
STARTUP_TIMEOUT=300  # 5 phút
HEALTH_CHECK_INTERVAL=10  # 10 giây

# === HIỂN THỊ HƯỚNG DẪN ===
show_help() {
    show_banner "GITLAB MANAGEMENT v2.1"

    cat << EOF
Sử dụng: $0 [TÙYCHỌN]

Tùy chọn:
  --install       Cài đặt GitLab mới
  --start         Khởi động GitLab
  --stop          Dừng GitLab
  --restart       Khởi động lại
  --status        Kiểm tra trạng thái
  --logs          Xem logs
  --password      Lấy mật khẩu root
  --create-root   Tạo user root thủ công
  --cleanup       Xóa hoàn toàn (cẩn thận!)
  --follow        Theo dõi logs realtime
  --help          Hiển thị trợ giúp

Ví dụ:
  $0                    # Chế độ tương tác
  $0 --install          # Cài đặt mới
  $0 --create-root      # Tạo user root thủ công
  $0 --logs --follow    # Xem logs realtime
  $0 --status           # Kiểm tra trạng thái

Thông tin truy cập:
  🌐 Web UI:     http://localhost:8088
  📦 Registry:   http://localhost:5050
  👤 Username:   root
  🔐 Password:   Nex!tFlow@2025!
  🗄️ Database:   $GITLAB_DB (shared)
  🔴 Cache:      Redis (shared)
EOF
}

# === XỬ LÝ THAM SỐ DÒNG LỆNH ===
parse_arguments() {
    [[ $# -eq 0 ]] && ACTION="interactive" && return

    while [[ $# -gt 0 ]]; do
        case $1 in
            --install)      ACTION="install" ;;
            --start)        ACTION="start" ;;
            --stop)         ACTION="stop" ;;
            --restart)      ACTION="restart" ;;
            --status)       ACTION="status" ;;
            --logs)         ACTION="logs" ;;
            --password)     ACTION="password" ;;
            --create-root)  ACTION="create_root" ;;
            --cleanup)      ACTION="cleanup" ;;
            --follow|-f)    FOLLOW_LOGS=true ;;
            --help|-h)      show_help && exit 0 ;;
            *)
                log_error "Tùy chọn không hợp lệ: $1"
                show_help && exit 1
                ;;
        esac
        shift
    done
}

# === KIỂM TRA HỆ THỐNG ===
# Kiểm tra Docker có sẵn
check_docker() {
    command -v docker &>/dev/null || {
        log_error "Docker chưa cài đặt!"
        exit 1
    }
    
    docker info &>/dev/null || {
        log_error "Docker daemon không chạy!"
        exit 1
    }
}

# Kiểm tra Docker Compose
check_docker_compose() {
    command -v docker-compose &>/dev/null || {
        log_error "Docker Compose chưa cài đặt!"
        exit 1
    }
}

# === ĐẢM BẢO DỊCH VỤ CHIA SẺ ===
# Khởi động PostgreSQL (shared)
ensure_postgres() {
    log_info "Kiểm tra PostgreSQL..."

    if ! is_container_running "postgres"; then
        log_warning "PostgreSQL chưa chạy, đang khởi động..."
        log_loading "Khởi động PostgreSQL..."
        
        $DOCKER_COMPOSE -f "$COMPOSE_FILE" up -d postgres
        
        if wait_for_container_health "postgres" 30; then
            log_success "PostgreSQL đã sẵn sàng"
        else
            log_error "PostgreSQL không khởi động được (timeout 30s)"
            exit 1
        fi
    else
        log_success "PostgreSQL đã chạy"
    fi
}

# Khởi động Redis (shared)
ensure_redis() {
    log_info "Kiểm tra Redis..."

    if ! is_container_running "redis"; then
        log_warning "Redis chưa chạy, đang khởi động..."
        log_loading "Khởi động Redis..."
        
        $DOCKER_COMPOSE -f "$COMPOSE_FILE" up -d redis
        
        if wait_for_container_health "redis" 15; then
            log_success "Redis đã sẵn sàng"
        else
            log_error "Redis không khởi động được (timeout 15s)"
            exit 1
        fi
    else
        log_success "Redis đã chạy"
    fi
}

# Tạo database GitLab
ensure_gitlab_database() {
    log_info "Kiểm tra database GitLab..."
    
    local db_exists=$(docker exec postgres psql -U "${POSTGRES_USER:-nextflow}" -lqt | cut -d \| -f 1 | grep -w "$GITLAB_DB" || true)
    
    if [[ -n "$db_exists" ]]; then
        log_success "Database $GITLAB_DB đã tồn tại"
    else
        log_info "Tạo database $GITLAB_DB..."
        docker exec postgres psql -U "${POSTGRES_USER:-nextflow}" -c "CREATE DATABASE $GITLAB_DB;"
        log_success "Database $GITLAB_DB đã tạo"
    fi
}

# Tạo file cấu hình gitlab.rb
create_gitlab_config() {
    local config_file="./gitlab/config/gitlab.rb"
    
    log_info "Tạo file cấu hình gitlab.rb..."
    
    cat > "$config_file" << 'EOF'
# GitLab Configuration File
# Generated by NextFlow GitLab Management Script
# Cấu hình này phải khớp với GITLAB_OMNIBUS_CONFIG trong docker-compose.yml

# === CẤU HÌNH CƠ BẢN ===
# URL truy cập GitLab
external_url 'http://localhost:8088'

# Tắt GitLab KAS (Kubernetes Agent Server) - không cần thiết cho môi trường dev
gitlab_kas['enable'] = false

# Cấu hình tài khoản root
gitlab_rails['initial_root_password'] = "nextflow@2025"

# === CẤU HÌNH DATABASE ===
# Tắt PostgreSQL tích hợp và sử dụng external PostgreSQL
postgresql['enable'] = false
gitlab_rails['db_adapter'] = 'postgresql'
gitlab_rails['db_encoding'] = 'utf8'
gitlab_rails['db_host'] = 'postgres'
gitlab_rails['db_port'] = 5432
gitlab_rails['db_username'] = 'nextflow'
gitlab_rails['db_password'] = 'nextflow@2025'
gitlab_rails['db_database'] = 'gitlabhq_production'

# === CẤU HÌNH REDIS ===
# Tắt Redis tích hợp và sử dụng external Redis
redis['enable'] = false
gitlab_rails['redis_host'] = 'redis'
gitlab_rails['redis_port'] = 6379
gitlab_rails['redis_password'] = 'nextflow@2025'

# === CẤU HÌNH SSH ===
gitlab_rails['gitlab_shell_ssh_port'] = 2222

# === CẤU HÌNH TIMEZONE ===
gitlab_rails['time_zone'] = 'Asia/Ho_Chi_Minh'

# === CẤU HÌNH CONTAINER REGISTRY ===
registry_external_url 'http://localhost:5050'
gitlab_rails['registry_enabled'] = true
registry_nginx['listen_port'] = 5050

# === TẮT MONITORING TÍCH HỢP ===
prometheus_monitoring['enable'] = false

# === CẤU HÌNH EMAIL (TẠM THỜI TẮT) ===
gitlab_rails['smtp_enable'] = false
# Uncomment và cấu hình khi cần sử dụng email
# gitlab_rails['smtp_address'] = "smtp.gmail.com"
# gitlab_rails['smtp_port'] = 587
# gitlab_rails['smtp_user_name'] = "your_email@gmail.com"
# gitlab_rails['smtp_password'] = "your_app_password"
# gitlab_rails['smtp_domain'] = "smtp.gmail.com"
# gitlab_rails['smtp_authentication'] = "login"
# gitlab_rails['smtp_enable_starttls_auto'] = true
# gitlab_rails['smtp_tls'] = false
# gitlab_rails['gitlab_email_from'] = 'your_email@gmail.com'
# gitlab_rails['gitlab_email_display_name'] = 'GitLab NextFlow'
# gitlab_rails['gitlab_email_reply_to'] = 'noreply@example.com'

# === CẤU HÌNH BACKUP ===
gitlab_rails['backup_path'] = "/var/opt/gitlab/backups"
gitlab_rails['backup_keep_time'] = 604800  # 7 ngày

# === TỐI ƯU HIỆU NĂNG ===
puma['worker_processes'] = 2

# === CẤU HÌNH TÍNH NĂNG MẶC ĐỊNH ===
gitlab_rails['gitlab_default_projects_features_issues'] = true
gitlab_rails['gitlab_default_projects_features_merge_requests'] = true
gitlab_rails['gitlab_default_projects_features_wiki'] = true
gitlab_rails['gitlab_default_projects_features_snippets'] = true
gitlab_rails['gitlab_default_projects_features_builds'] = true
gitlab_rails['gitlab_default_projects_features_container_registry'] = true

# === GHI CHÚ ===
# File này được tạo tự động bởi script gitlab.sh
# Để thay đổi cấu hình, hãy sửa đổi GITLAB_OMNIBUS_CONFIG trong docker-compose.yml
# hoặc chỉnh sửa trực tiếp file này và restart GitLab
EOF

    log_success "Đã tạo file cấu hình: $config_file"
}

# === CÀI ĐẶT GITLAB ===
install_gitlab() {
    show_banner "CÀI ĐẶT GITLAB"

    # Kiểm tra container hiện có
    if docker ps -a | grep -q "$GITLAB_CONTAINER"; then
        log_warning "GitLab container đã tồn tại!"
        
        local options=("Xóa và cài lại" "Chỉ khởi động" "Hủy bỏ")
        show_menu "Lựa chọn" "${options[@]}"
        read -r choice

        case $choice in
            1)
                log_info "Xóa GitLab hiện tại..."
                $DOCKER_COMPOSE stop $GITLAB_CONTAINER 2>/dev/null || true
                $DOCKER_COMPOSE rm -f $GITLAB_CONTAINER 2>/dev/null || true

                read -p "Xóa tất cả data GitLab? (y/N): " delete_volumes
                if [[ "$delete_volumes" =~ ^[Yy]$ ]]; then
                    log_info "Xóa GitLab volumes..."
                    docker volume rm nextflow-docker_gitlab_{config,data,logs} 2>/dev/null || true
                    log_success "Đã xóa volumes"
                fi
                ;;
            2)
                start_gitlab && return ;;
            3)
                log_info "Hủy cài đặt" && return ;;
            *)
                log_error "Lựa chọn không hợp lệ!" && return ;;
        esac
    fi

    # Chuẩn bị môi trường
    log_info "Chuẩn bị môi trường..."
    ensure_postgres
    ensure_redis
    ensure_gitlab_database

    # Tạo thư mục
    log_info "Tạo thư mục..."
    mkdir -p ./gitlab/{config,logs,data,backups}
    
    # Tạo file cấu hình gitlab.rb
    create_gitlab_config

    # Pull image và khởi động
    log_info "Pull GitLab image..."
    docker pull gitlab/gitlab-ce:16.11.3-ce.0

    log_info "Khởi động GitLab..."
    $DOCKER_COMPOSE up -d $GITLAB_CONTAINER

    # Thông báo hoàn thành
    log_success "GitLab đang khởi động (5-10 phút)..."

    echo ""
    log_info "📋 Hướng dẫn tiếp theo:"
    log_info "• Theo dõi: $0 --logs --follow"
    log_info "• Trạng thái: $0 --status"
    log_info "• Tạo user root: $0 --create-root (sau khi GitLab sẵn sàng)"

    echo ""
    log_warning "⏳ Đợi GitLab khởi động hoàn toàn trước khi tạo user root"
    log_info "💡 Sử dụng '$0 --create-root' để tạo user root với mật khẩu: Nex!tFlow@2025!"

    show_access_info
}

# === QUẢN LÝ GITLAB ===
# Khởi động GitLab
start_gitlab() {
    show_banner "KHỞI ĐỘNG GITLAB"

    # Kiểm tra cài đặt
    if ! docker ps -a | grep -q "$GITLAB_CONTAINER"; then
        log_warning "GitLab chưa cài đặt!"
        read -p "Cài đặt ngay? (Y/n): " install_choice
        [[ ! "$install_choice" =~ ^[Nn]$ ]] && install_gitlab || log_info "Hủy khởi động"
        return
    fi

    # Chuẩn bị môi trường
    ensure_postgres
    ensure_redis
    ensure_gitlab_database

    # Tạo thư mục và cấu hình
    mkdir -p ./gitlab/{config,logs,data,backups}
    create_gitlab_config
    
    log_info "Khởi động GitLab..."
    $DOCKER_COMPOSE up -d $GITLAB_CONTAINER

    log_success "GitLab đang khởi động (3-5 phút)..."
    log_info "Theo dõi: $0 --logs --follow"
    show_access_info
}

# Dừng GitLab
stop_gitlab() {
    show_banner "DỪNG GITLAB"

    if docker ps | grep -q "$GITLAB_CONTAINER"; then
        log_info "Dừng GitLab..."
        $DOCKER_COMPOSE stop $GITLAB_CONTAINER
        $DOCKER_COMPOSE rm -f $GITLAB_CONTAINER
        log_success "GitLab đã dừng"
    else
        log_warning "GitLab không chạy"
    fi
    show_status
}

# Khởi tạo môi trường
initialize_environment() {
    log_info "Khởi tạo môi trường..."
    cd "$PROJECT_ROOT"

    # Kiểm tra Docker
    check_docker
    check_docker_compose

    # Thiết lập DOCKER_COMPOSE
    [[ -z "${DOCKER_COMPOSE:-}" ]] && {
        DOCKER_COMPOSE=$(detect_docker_compose)
        export DOCKER_COMPOSE
    }

    # Validate compose file
    validate_docker_compose_file "$COMPOSE_FILE" || {
        log_error "File docker-compose không hợp lệ!"
        exit 1
    }

    log_success "Môi trường sẵn sàng!"
}

# Khởi động lại GitLab
restart_gitlab() {
    show_banner "KHỞI ĐỘNG LẠI GITLAB"
    log_info "Khởi động lại..."
    stop_gitlab
    sleep 3
    start_gitlab
}

# === HIỂN THỊ THÔNG TIN ===
# Kiểm tra trạng thái
show_status() {
    show_banner "TRẠNG THÁI GITLAB"

    local services=(
        "🦊 GitLab:$GITLAB_CONTAINER"
        "🗄️ PostgreSQL:postgres:(shared)"
        "🔴 Redis:redis:(shared)"
    )

    echo ""
    for service in "${services[@]}"; do
        IFS=':' read -r icon name extra <<< "$service"
        if docker ps | grep -q "$name"; then
            echo "$icon ✅ Đang chạy $extra"
            # Hiển thị health cho GitLab
            [[ "$name" == "$GITLAB_CONTAINER" ]] && {
                local health=$(docker inspect --format='{{.State.Health.Status}}' "$name" 2>/dev/null || echo "unknown")
                echo "   Health: $health"
            }
        else
            echo "$icon ❌ Đã dừng $extra"
        fi
    done
    echo ""
}

# Xem logs
show_logs() {
    local follow_flag=""
    [[ "$FOLLOW_LOGS" == "true" ]] && {
        follow_flag="-f"
        log_info "Theo dõi logs (Ctrl+C thoát)..."
    } || log_info "Hiển thị logs..."

    docker ps | grep -q "$GITLAB_CONTAINER" || {
        log_error "GitLab không chạy"
        exit 1
    }

    $DOCKER_COMPOSE --profile $GITLAB_PROFILE logs $follow_flag $GITLAB_CONTAINER
}

# Lấy mật khẩu root
get_password() {
    show_banner "GITLAB PASSWORD"

    docker ps | grep -q "$GITLAB_CONTAINER" || {
        log_error "GitLab không chạy"
        exit 1
    }

    log_info "Lấy mật khẩu root..."
    echo ""
    docker exec $GITLAB_CONTAINER grep 'Password:' /etc/gitlab/initial_root_password 2>/dev/null || {
        log_warning "Không lấy được mật khẩu. GitLab có thể chưa khởi động xong."
        log_info "Thử lại sau vài phút hoặc xem logs"
    }
    echo ""
}

# Tạo user root thủ công với mật khẩu tùy chỉnh
create_root_user() {
    show_banner "TẠO USER ROOT THỦ CÔNG"

    docker ps | grep -q "$GITLAB_CONTAINER" || {
        log_error "GitLab không chạy"
        exit 1
    }

    # Kiểm tra GitLab đã sẵn sàng chưa
    log_info "Kiểm tra trạng thái GitLab..."
    local health_status=$(docker inspect --format='{{.State.Health.Status}}' "$GITLAB_CONTAINER" 2>/dev/null || echo "unknown")

    if [[ "$health_status" != "healthy" ]]; then
        log_warning "GitLab chưa sẵn sàng (trạng thái: $health_status)"
        log_info "Vui lòng đợi GitLab khởi động hoàn toàn trước khi tạo user root"
        return 1
    fi

    # Lấy thông tin từ environment variables
    local root_password="${GITLAB_ROOT_PASSWORD:-Nex!tFlow@2025!}"
    local root_email="${GITLAB_ROOT_EMAIL:-nextflow.vn@gmail.com}"
    local root_name="${GITLAB_ROOT_NAME:-NextFlow Administrator}"

    log_info "Thông tin user root:"
    echo "  👤 Username: root"
    echo "  📧 Email: $root_email"
    echo "  👨‍💼 Name: $root_name"
    echo "  🔐 Password: $root_password"
    echo ""

    read -p "Xác nhận tạo user root với thông tin trên? (Y/n): " confirm
    [[ "$confirm" =~ ^[Nn]$ ]] && {
        log_info "Hủy tạo user root"
        return 0
    }

    log_info "Đang kiểm tra và tạo user root..."

    # Kiểm tra số lượng users hiện tại và tạo user root
    local ruby_script="
puts '=== KIỂM TRA VÀ TẠO USER ROOT ==='

# Kiểm tra số lượng users hiện tại
total_users = User.count
puts \"Tổng số users hiện tại: #{total_users}\"

# Kiểm tra user root có tồn tại không
existing_root = User.find_by(username: 'root')

if existing_root
  puts 'User root đã tồn tại, đang cập nhật thông tin...'
  existing_root.password = '$root_password'
  existing_root.password_confirmation = '$root_password'
  existing_root.email = '$root_email'
  existing_root.name = '$root_name'
  existing_root.admin = true
  existing_root.confirmed_at = Time.current if existing_root.confirmed_at.nil?
  existing_root.confirmation_token = nil

  if existing_root.save
    puts '✅ User root đã được cập nhật thành công!'
    puts \"ID: #{existing_root.id}\"
    puts \"Username: #{existing_root.username}\"
    puts \"Email: #{existing_root.email}\"
    puts \"Name: #{existing_root.name}\"
    puts \"Admin: #{existing_root.admin}\"
    puts \"Confirmed: #{existing_root.confirmed?}\"
  else
    puts '❌ Lỗi khi cập nhật user root:'
    puts existing_root.errors.full_messages.join(', ')
  end
else
  puts 'User root chưa tồn tại, đang tạo mới...'

  begin
    # Tạo user root mới
    new_user = User.create!(
      username: 'root',
      email: '$root_email',
      name: '$root_name',
      password: '$root_password',
      password_confirmation: '$root_password',
      admin: true,
      confirmed_at: Time.current
    )

    puts '✅ User root đã được tạo thành công!'
    puts \"ID: #{new_user.id}\"
    puts \"Username: #{new_user.username}\"
    puts \"Email: #{new_user.email}\"
    puts \"Name: #{new_user.name}\"
    puts \"Admin: #{new_user.admin}\"
    puts \"Confirmed: #{new_user.confirmed?}\"

  rescue => e
    puts '❌ Lỗi khi tạo user root:'
    puts e.message

    # Thử cách khác nếu cách đầu tiên thất bại
    puts 'Thử phương pháp khác...'
    user = User.new(
      username: 'root',
      email: '$root_email',
      name: '$root_name',
      password: '$root_password',
      password_confirmation: '$root_password',
      admin: true,
      confirmed_at: Time.current,
      confirmation_token: nil
    )

    # Tạo namespace cho user
    user.build_namespace(
      name: 'root',
      path: 'root'
    )

    if user.save
      puts '✅ User root đã được tạo thành công (phương pháp 2)!'
      puts \"ID: #{user.id}\"
      puts \"Username: #{user.username}\"
      puts \"Email: #{user.email}\"
      puts \"Name: #{user.name}\"
      puts \"Admin: #{user.admin}\"
      puts \"Confirmed: #{user.confirmed?}\"
    else
      puts '❌ Vẫn lỗi khi tạo user root:'
      puts user.errors.full_messages.join(', ')
    end
  end
end

puts '=== HOÀN THÀNH ==='
"

    # Thực thi script trong GitLab Rails console
    log_info "Thực thi script tạo user root..."
    echo ""

    if docker exec "$GITLAB_CONTAINER" gitlab-rails runner "$ruby_script"; then
        echo ""
        log_success "✅ Quá trình tạo/cập nhật user root đã hoàn thành!"
        echo ""
        log_info "🎯 THÔNG TIN ĐĂNG NHẬP:"
        echo "  🌐 URL: http://localhost:8088"
        echo "  👤 Username: root"
        echo "  🔐 Password: $root_password"
        echo "  📧 Email: $root_email"
        echo ""
        log_info "💡 Bạn có thể đăng nhập ngay bây giờ!"

        # Hiển thị thêm thông tin hữu ích
        echo ""
        log_info "📋 Các bước tiếp theo:"
        echo "  1. Truy cập http://localhost:8088"
        echo "  2. Đăng nhập với username: root"
        echo "  3. Sử dụng password: $root_password"
        echo "  4. Tạo projects và repositories"
        echo ""

    else
        echo ""
        log_error "❌ Có lỗi xảy ra khi tạo user root"
        log_info "Vui lòng kiểm tra logs GitLab: $0 --logs"
        return 1
    fi
}

# Hiển thị thông tin truy cập
show_access_info() {
    local root_password="${GITLAB_ROOT_PASSWORD:-Nex!tFlow@2025!}"

    cat << EOF

🎯 THÔNG TIN TRUY CẬP GITLAB
============================
🌐 Web UI:     http://localhost:8088
📦 Registry:   http://localhost:5050
👤 Username:   root
🔐 Password:   $root_password
📧 Email:      ${GITLAB_ROOT_EMAIL:-nextflow.vn@gmail.com}
🗄️ Database:   $GITLAB_DB (shared)
🔴 Cache:      Redis (shared)

⚠️  LƯU Ý:
• GitLab cần 3-5 phút khởi động hoàn toàn
• Sử dụng PostgreSQL & Redis shared
• Nếu chưa có user root: $0 --create-root
• Kiểm tra logs: $0 --logs --follow

📋 CÁC LỆNH HỮU ÍCH:
• Tạo user root: $0 --create-root
• Xem mật khẩu: $0 --password
• Kiểm tra trạng thái: $0 --status
• Khởi động lại: $0 --restart
EOF
}

# === XÓA HOÀN TOÀN GITLAB ===
cleanup_gitlab() {
    show_banner "CLEANUP GITLAB"

    cat << EOF
⚠️  CẢNH BÁO: Xóa hoàn toàn GitLab và tất cả dữ liệu!

Bao gồm:
• GitLab container
• GitLab volumes (config, data, logs)
• GitLab database ($GITLAB_DB)
• GitLab directories

EOF

    read -p "Xác nhận xóa hoàn toàn? (yes/no): " confirm
    [[ "$confirm" != "yes" ]] && {
        log_info "Hủy cleanup"
        return
    }

    log_info "Bắt đầu cleanup..."

    # Sử dụng script chuyên dụng nếu có
    if [[ -f "./scripts/cleanup-gitlab-db.sh" ]]; then
        log_info "Sử dụng script cleanup chuyên dụng..."
        ./scripts/cleanup-gitlab-db.sh
        return
    fi

    # Cleanup thủ công
    log_info "Cleanup thủ công..."

    # Dừng container
    docker ps | grep -q "$GITLAB_CONTAINER" && {
        log_info "Dừng GitLab..."
        $DOCKER_COMPOSE stop $GITLAB_CONTAINER
        $DOCKER_COMPOSE rm -f $GITLAB_CONTAINER
    }

    # Xóa database
    log_info "Xóa database $GITLAB_DB..."
    docker exec postgres psql -U "${POSTGRES_USER:-nextflow}" -d postgres -c "
        SELECT pg_terminate_backend(pid)
        FROM pg_stat_activity
        WHERE datname = '$GITLAB_DB' AND pid <> pg_backend_pid();
        DROP DATABASE IF EXISTS $GITLAB_DB;
    " 2>/dev/null || true

    # Xóa volumes
    log_info "Xóa volumes..."
    docker volume rm nextflow-docker_gitlab_{config,data,logs} 2>/dev/null || true

    # Xóa thư mục
    [[ -d "./gitlab" ]] && {
        rm -rf ./gitlab
        log_success "Đã xóa thư mục ./gitlab"
    }

    log_success "🎉 Cleanup hoàn tất!"
    log_info "Có thể cài đặt lại bằng: $0 --install"
}

# === CHẾ ĐỘ TƯƠNG TÁC ===
interactive_mode() {
    show_banner "GITLAB MANAGEMENT"

    local options=(
        "Cài đặt GitLab"
        "Khởi động GitLab"
        "Dừng GitLab"
        "Khởi động lại GitLab"
        "Kiểm tra trạng thái"
        "Xem logs GitLab"
        "Xem logs (follow)"
        "Lấy initial password"
        "Tạo user root thủ công"
        "Hiển thị thông tin truy cập"
        "Cleanup GitLab (xóa hoàn toàn)"
        "Thoát"
    )

    while true; do
        echo
        show_menu "GITLAB MENU" "${options[@]}"
        read -r choice

        case $choice in
            1) install_gitlab ;;
            2) start_gitlab ;;
            3) stop_gitlab ;;
            4) restart_gitlab ;;
            5) show_status ;;
            6) FOLLOW_LOGS=false; show_logs ;;
            7) FOLLOW_LOGS=true; show_logs ;;
            8) get_password ;;
            9) create_root_user ;;
            10) show_access_info ;;
            11) cleanup_gitlab ;;
            12) log_info "Tạm biệt!"; break ;;
            *) log_error "Lựa chọn không hợp lệ!" ;;
        esac
    done
}

# === HÀM CHÍNH ===
main() {
    parse_arguments "$@"     # Phân tích tham số
    initialize_environment   # Khởi tạo môi trường

    # Thực thi hành động
    case "$ACTION" in
        "install") install_gitlab ;;
        "start") start_gitlab ;;
        "stop") stop_gitlab ;;
        "restart") restart_gitlab ;;
        "status") show_status ;;
        "logs") show_logs ;;
        "password") get_password ;;
        "create_root") create_root_user ;;
        "cleanup") cleanup_gitlab ;;
        "interactive") interactive_mode ;;
        *) log_error "Action không hợp lệ: $ACTION"; exit 1 ;;
    esac
}

# === KHỞI CHẠY SCRIPT ===
main "$@"
