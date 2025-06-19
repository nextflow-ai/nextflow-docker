#!/bin/bash

# ============================================================================
# NEXTFLOW MAIL SERVER MANAGEMENT SCRIPT
# ============================================================================
# Mô tả: Script quản lý Stalwart Mail Server
# Tác giả: NextFlow Team
# Phiên bản: 1.0
# Cập nhật: 2025
# ============================================================================

# Xử lý lỗi nghiêm ngặt
set -euo pipefail

# Định nghĩa thư mục
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SCRIPTS_DIR="$PROJECT_ROOT/scripts"

# Import các script tiện ích
source "$SCRIPTS_DIR/utils/logging.sh"
source "$SCRIPTS_DIR/utils/docker.sh"
source "$SCRIPTS_DIR/utils/validation.sh"

# ============================================================================
# GLOBAL VARIABLES
# ============================================================================

# File cấu hình
COMPOSE_FILE="$PROJECT_ROOT/docker-compose.yml"
PROFILE="mail"
DB_NAME="stalwart_mail"
CONTAINER_NAME="stalwart-mail"

# Hành động
ACTION=""
FOLLOW_LOGS=false

# Timeout cho các thao tác
TIMEOUT_START=120
TIMEOUT_STOP=30

# ============================================================================
# FUNCTIONS
# ============================================================================

# Hiển thị hướng dẫn sử dụng
show_usage() {
    cat << EOF
🚀 NextFlow Mail Server Manager

Sử dụng: $0 [OPTION]

Các tùy chọn:
  install     Cài đặt và khởi động Mail Server lần đầu
  start       Khởi động Mail Server
  stop        Dừng Mail Server
  restart     Khởi động lại Mail Server
  status      Kiểm tra trạng thái Mail Server
  logs        Xem logs Mail Server
  backup      Backup dữ liệu Mail Server
  restore     Restore dữ liệu Mail Server
  users       Quản lý users
  domains     Quản lý domains
  test        Test Mail Server
  cleanup     Dọn dẹp dữ liệu Mail Server
  --follow    Theo dõi logs real-time (dùng với logs)
  --help      Hiển thị hướng dẫn này

Ví dụ:
  $0 install                    # Cài đặt Mail Server
  $0 start                      # Khởi động Mail Server
  $0 logs --follow              # Xem logs real-time
  $0 users add user@domain.com  # Thêm user mới
  $0 backup                     # Backup dữ liệu

Thông tin truy cập:
  🌐 Web Admin: http://localhost:8080
  📧 SMTP: localhost:587 (STARTTLS) hoặc localhost:465 (SSL)
  📬 IMAP: localhost:993 (SSL) hoặc localhost:143 (STARTTLS)
  📮 POP3: localhost:995 (SSL) hoặc localhost:110 (STARTTLS)

EOF
}

# Xử lý đối số dòng lệnh
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            install|start|stop|restart|status|logs|backup|restore|users|domains|test|cleanup)
                ACTION="$1"
                shift
                ;;
            --follow)
                FOLLOW_LOGS=true
                shift
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
            *)
                log_error "Tùy chọn không hợp lệ: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    if [ -z "$ACTION" ]; then
        log_error "Vui lòng chỉ định hành động"
        show_usage
        exit 1
    fi
}

# Kiểm tra yêu cầu
check_requirements() {
    validate_file_exists "$COMPOSE_FILE"
    check_docker_installation
    check_docker_compose_installation
}

# Cài đặt Mail Server
install_mail_server() {
    log_info "🚀 Cài đặt Stalwart Mail Server..."
    
    # Chạy script cài đặt
    if [ -f "$SCRIPTS_DIR/profiles/mail.sh" ]; then
        "$SCRIPTS_DIR/profiles/mail.sh"
    else
        log_error "Script cài đặt không tìm thấy: $SCRIPTS_DIR/profiles/mail.sh"
        exit 1
    fi
    
    log_success "✅ Cài đặt Mail Server hoàn tất!"
}

# Khởi động Mail Server
start_mail_server() {
    log_info "🚀 Khởi động Mail Server..."
    
    cd "$PROJECT_ROOT"
    
    # Khởi động services cơ bản trước
    if ! is_container_running "postgres"; then
        log_info "Khởi động PostgreSQL..."
        docker-compose --profile basic up -d postgres
        wait_for_container_healthy "postgres" 60
    fi
    
    if ! is_container_running "redis"; then
        log_info "Khởi động Redis..."
        docker-compose --profile basic up -d redis
        wait_for_container_healthy "redis" 30
    fi
    
    # Khởi động Mail Server
    docker-compose --profile "$PROFILE" up -d
    
    # Chờ Mail Server sẵn sàng
    wait_for_container_healthy "$CONTAINER_NAME" "$TIMEOUT_START"
    
    log_success "✅ Mail Server đã khởi động!"
    show_access_info
}

# Dừng Mail Server
stop_mail_server() {
    log_info "🛑 Dừng Mail Server..."
    
    cd "$PROJECT_ROOT"
    docker-compose stop "$CONTAINER_NAME"
    
    log_success "✅ Mail Server đã dừng!"
}

# Khởi động lại Mail Server
restart_mail_server() {
    log_info "🔄 Khởi động lại Mail Server..."
    
    stop_mail_server
    sleep 5
    start_mail_server
}

# Kiểm tra trạng thái
check_status() {
    log_info "📊 Trạng thái Mail Server:"
    
    cd "$PROJECT_ROOT"
    
    # Kiểm tra container
    if is_container_running "$CONTAINER_NAME"; then
        log_success "✅ Container: Đang chạy"
        
        # Kiểm tra health
        local health_status
        health_status=$(docker inspect --format='{{.State.Health.Status}}' "$CONTAINER_NAME" 2>/dev/null || echo "unknown")
        
        case $health_status in
            "healthy")
                log_success "✅ Health: Khỏe mạnh"
                ;;
            "unhealthy")
                log_error "❌ Health: Không khỏe mạnh"
                ;;
            "starting")
                log_warning "⏳ Health: Đang khởi động"
                ;;
            *)
                log_warning "❓ Health: Không xác định"
                ;;
        esac
        
        # Kiểm tra ports
        log_info "🔌 Kiểm tra ports:"
        local ports=(25 587 465 143 993 110 995 4190 8080)
        for port in "${ports[@]}"; do
            if nc -z localhost "$port" 2>/dev/null; then
                log_success "  ✅ Port $port: Mở"
            else
                log_warning "  ❌ Port $port: Đóng"
            fi
        done
        
        # Hiển thị thông tin truy cập
        show_access_info
    else
        log_error "❌ Container: Không chạy"
    fi
    
    # Kiểm tra database
    if is_container_running "postgres"; then
        log_info "🗄️ Kiểm tra database..."
        if docker exec postgres psql -U stalwart -d "$DB_NAME" -c "SELECT 1;" >/dev/null 2>&1; then
            log_success "✅ Database: Kết nối thành công"
        else
            log_error "❌ Database: Không thể kết nối"
        fi
    else
        log_error "❌ PostgreSQL: Không chạy"
    fi
}

# Xem logs
show_logs() {
    log_info "📋 Logs Mail Server:"
    
    cd "$PROJECT_ROOT"
    
    if [ "$FOLLOW_LOGS" = true ]; then
        log_info "Theo dõi logs real-time (Ctrl+C để thoát)..."
        docker-compose logs -f "$CONTAINER_NAME"
    else
        docker-compose logs --tail=100 "$CONTAINER_NAME"
    fi
}

# Backup dữ liệu
backup_mail_server() {
    log_info "💾 Backup Mail Server..."
    
    local backup_dir="$PROJECT_ROOT/stalwart/backups"
    local date=$(date +%Y%m%d_%H%M%S)
    
    # Tạo thư mục backup
    mkdir -p "$backup_dir"
    
    # Backup database
    log_info "Backup database..."
    docker exec postgres pg_dump -U stalwart "$DB_NAME" > "$backup_dir/stalwart_mail_$date.sql"
    
    # Backup configuration
    log_info "Backup configuration..."
    tar -czf "$backup_dir/stalwart_config_$date.tar.gz" -C "$PROJECT_ROOT" stalwart/config/
    
    # Backup data
    log_info "Backup data..."
    if [ -d "$PROJECT_ROOT/stalwart/data" ]; then
        tar -czf "$backup_dir/stalwart_data_$date.tar.gz" -C "$PROJECT_ROOT" stalwart/data/
    fi
    
    log_success "✅ Backup hoàn tất: $backup_dir/stalwart_*_$date.*"
}

# Restore dữ liệu
restore_mail_server() {
    log_info "📥 Restore Mail Server..."
    
    local backup_dir="$PROJECT_ROOT/stalwart/backups"
    
    # Liệt kê các backup có sẵn
    log_info "Các backup có sẵn:"
    ls -la "$backup_dir"/*.sql 2>/dev/null || {
        log_error "Không tìm thấy backup nào"
        exit 1
    }
    
    echo
    read -p "Nhập tên file backup (.sql): " backup_file
    
    if [ ! -f "$backup_dir/$backup_file" ]; then
        log_error "File backup không tồn tại: $backup_dir/$backup_file"
        exit 1
    fi
    
    # Xác nhận
    log_warning "⚠️  CẢNH BÁO: Thao tác này sẽ ghi đè dữ liệu hiện tại!"
    read -p "Bạn có chắc chắn muốn restore? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Hủy bỏ restore"
        exit 0
    fi
    
    # Dừng mail server
    log_info "Dừng Mail Server..."
    docker-compose stop "$CONTAINER_NAME"
    
    # Restore database
    log_info "Restore database..."
    docker exec -i postgres psql -U stalwart "$DB_NAME" < "$backup_dir/$backup_file"
    
    # Khởi động lại
    log_info "Khởi động lại Mail Server..."
    docker-compose start "$CONTAINER_NAME"
    
    log_success "✅ Restore hoàn tất!"
}

# Quản lý users
manage_users() {
    log_info "👥 Quản lý Users:"
    
    cat << EOF
Các lệnh quản lý users:
  $0 users list                    # Liệt kê users
  $0 users add <email> <password>  # Thêm user
  $0 users delete <email>          # Xóa user
  $0 users password <email>        # Đổi password

Ví dụ:
  $0 users add user@domain.com mypassword
  $0 users delete user@domain.com
EOF
}

# Quản lý domains
manage_domains() {
    log_info "🌐 Quản lý Domains:"
    
    cat << EOF
Các lệnh quản lý domains:
  $0 domains list           # Liệt kê domains
  $0 domains add <domain>   # Thêm domain
  $0 domains delete <domain> # Xóa domain

Ví dụ:
  $0 domains add example.com
  $0 domains delete example.com
EOF
}

# Test Mail Server
test_mail_server() {
    log_info "🧪 Test Mail Server..."
    
    # Test SMTP
    log_info "Test SMTP (port 587)..."
    if nc -z localhost 587; then
        log_success "✅ SMTP: OK"
    else
        log_error "❌ SMTP: FAIL"
    fi
    
    # Test IMAP
    log_info "Test IMAP (port 993)..."
    if nc -z localhost 993; then
        log_success "✅ IMAP: OK"
    else
        log_error "❌ IMAP: FAIL"
    fi
    
    # Test Web Admin
    log_info "Test Web Admin (port 8080)..."
    if nc -z localhost 8080; then
        log_success "✅ Web Admin: OK"
    else
        log_error "❌ Web Admin: FAIL"
    fi
    
    # Test database connection
    log_info "Test Database connection..."
    if docker exec postgres psql -U stalwart -d "$DB_NAME" -c "SELECT 1;" >/dev/null 2>&1; then
        log_success "✅ Database: OK"
    else
        log_error "❌ Database: FAIL"
    fi
}

# Dọn dẹp
cleanup_mail_server() {
    log_warning "🧹 Dọn dẹp Mail Server..."
    log_warning "⚠️  CẢNH BÁO: Thao tác này sẽ xóa TẤT CẢ dữ liệu Mail Server!"
    
    read -p "Bạn có chắc chắn muốn dọn dẹp? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Hủy bỏ dọn dẹp"
        exit 0
    fi
    
    cd "$PROJECT_ROOT"
    
    # Dừng container
    docker-compose stop "$CONTAINER_NAME" || true
    docker-compose rm -f "$CONTAINER_NAME" || true
    
    # Xóa volumes
    docker volume rm nextflow-docker_stalwart_config || true
    docker volume rm nextflow-docker_stalwart_data || true
    docker volume rm nextflow-docker_stalwart_logs || true
    
    # Xóa database
    docker exec postgres psql -U postgres -c "DROP DATABASE IF EXISTS $DB_NAME;" || true
    docker exec postgres psql -U postgres -c "DROP USER IF EXISTS stalwart;" || true
    
    log_success "✅ Dọn dẹp hoàn tất!"
}

# Hiển thị thông tin truy cập
show_access_info() {
    echo
    log_info "=== THÔNG TIN TRUY CẬP MAIL SERVER ==="
    echo
    log_info "🌐 Web Admin Interface:"
    echo "   URL: http://localhost:8080"
    echo "   Username: admin"
    echo "   Password: [xem trong file .env]"
    echo
    log_info "📧 SMTP Configuration:"
    echo "   Server: localhost"
    echo "   Port: 587 (STARTTLS) hoặc 465 (SSL)"
    echo "   Authentication: Required"
    echo
    log_info "📬 IMAP Configuration:"
    echo "   Server: localhost"
    echo "   Port: 143 (STARTTLS) hoặc 993 (SSL)"
    echo
    log_info "📮 POP3 Configuration:"
    echo "   Server: localhost"
    echo "   Port: 110 (STARTTLS) hoặc 995 (SSL)"
    echo
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    # Parse arguments
    parse_arguments "$@"
    
    # Check requirements
    check_requirements
    
    # Execute action
    case $ACTION in
        install)
            install_mail_server
            ;;
        start)
            start_mail_server
            ;;
        stop)
            stop_mail_server
            ;;
        restart)
            restart_mail_server
            ;;
        status)
            check_status
            ;;
        logs)
            show_logs
            ;;
        backup)
            backup_mail_server
            ;;
        restore)
            restore_mail_server
            ;;
        users)
            manage_users
            ;;
        domains)
            manage_domains
            ;;
        test)
            test_mail_server
            ;;
        cleanup)
            cleanup_mail_server
            ;;
        *)
            log_error "Hành động không hợp lệ: $ACTION"
            show_usage
            exit 1
            ;;
    esac
}

# Chạy script nếu được gọi trực tiếp
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi