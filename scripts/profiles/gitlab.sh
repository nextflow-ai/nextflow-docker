#!/bin/bash

# ============================================================================
# NEXTFLOW GITLAB DEPLOYMENT SCRIPT
# ============================================================================
# Mô tả: Script triển khai GitLab CE với đầy đủ tính năng CI/CD
# Tác giả: NextFlow Team
# Phiên bản: 1.0
# Cập nhật: 2025
# 
# Tính năng:
# - GitLab CE với Container Registry
# - Kết nối PostgreSQL và Redis shared
# - Cấu hình SSH, HTTP, HTTPS
# - Backup tự động
# - Health checks
# ============================================================================

# Xử lý lỗi nghiêm ngặt
set -euo pipefail

# Định nghĩa thư mục
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPTS_DIR="$PROJECT_ROOT/scripts"

# Import các script tiện ích
source "$SCRIPTS_DIR/utils/logging.sh"
source "$SCRIPTS_DIR/utils/docker.sh"
source "$SCRIPTS_DIR/utils/validation.sh"

# Load environment variables
if [[ -f "$PROJECT_ROOT/.env" ]]; then
    source "$PROJECT_ROOT/.env"
else
    log_error "File .env không tồn tại!"
    exit 1
fi

# ============================================================================
# CẤU HÌNH GITLAB
# ============================================================================

# Danh sách services cho gitlab profile
GITLAB_SERVICES=(
    "postgres"          # Database chính (shared)
    "redis"             # Cache và session (shared)
    "gitlab"            # GitLab CE server
)

# === CHUẨN HÓA PORT MAPPING ===
# Ports cần thiết cho GitLab (đã tối ưu hóa)
REQUIRED_PORTS=(
    8088    # HTTP Web Interface
    8443    # HTTPS (nếu cấu hình SSL)
    2222    # SSH Git operations
    5050    # Container Registry
)

# Cấu hình GitLab từ environment variables
GITLAB_HTTP_PORT="${GITLAB_HTTP_PORT:-8088}"
GITLAB_HTTPS_PORT="${GITLAB_HTTPS_PORT:-8443}"
GITLAB_SSH_PORT="${GITLAB_SSH_PORT:-2222}"
GITLAB_REGISTRY_PORT="${GITLAB_REGISTRY_PORT:-5050}"
GITLAB_DATABASE="${GITLAB_DATABASE:-nextflow_gitlab}"

# Thông tin GitLab từ .env
GITLAB_ROOT_USERNAME="${GITLAB_ROOT_USERNAME:-root}"
GITLAB_ROOT_PASSWORD="${GITLAB_ROOT_PASSWORD:-Nex!tFlow@2025!}"
GITLAB_ROOT_EMAIL="${GITLAB_ROOT_EMAIL:-nextflow.vn@gmail.com}"
GITLAB_ROOT_NAME="${GITLAB_ROOT_NAME:-NextFlow Administrator}"

# ============================================================================
# FUNCTIONS
# ============================================================================

# Hiển thị banner GitLab - TỐI ƯU HÓA
show_gitlab_banner() {
    show_banner "🦊 TRIỂN KHAI GITLAB CE - TỐI ƯU HÓA"

    log_info "GitLab Community Edition - Hệ thống quản lý mã nguồn và CI/CD"
    echo "  🌐 Web Interface: http://localhost:${GITLAB_HTTP_PORT}"
    echo "  🔒 HTTPS Interface: https://localhost:${GITLAB_HTTPS_PORT}"
    echo "  🔑 SSH Git: ssh://git@localhost:${GITLAB_SSH_PORT}"
    echo "  📦 Container Registry: http://localhost:${GITLAB_REGISTRY_PORT}"
    echo "  🗄️ Database: ${GITLAB_DATABASE}"
    echo "  👤 Root Username: ${GITLAB_ROOT_USERNAME}"
    echo "  🔐 Root Password: ${GITLAB_ROOT_PASSWORD}"
    echo "  📧 Root Email: ${GITLAB_ROOT_EMAIL}"
    echo "  👨‍💼 Root Name: ${GITLAB_ROOT_NAME}"
    echo
}

# Kiểm tra yêu cầu hệ thống cho GitLab
check_gitlab_requirements() {
    log_info "Kiểm tra yêu cầu hệ thống cho GitLab..."
    
    # Kiểm tra Docker và Docker Compose
    if ! check_docker || ! check_docker_compose; then
        log_error "Docker hoặc Docker Compose không sẵn sàng!"
        exit 1
    fi
    
    # Kiểm tra file cấu hình
    if [[ ! -f "$PROJECT_ROOT/docker-compose.yml" ]]; then
        log_error "File docker-compose.yml không tồn tại!"
        exit 1
    fi
    
    if [[ ! -f "$PROJECT_ROOT/.env" ]]; then
        log_error "File .env không tồn tại!"
        exit 1
    fi
    
    # === KIỂM TRA RAM - TỐI ƯU HÓA CHO DEVELOPMENT ===
    # Giảm yêu cầu RAM từ 4GB xuống 3GB cho development environment
    if command -v free >/dev/null 2>&1; then
        local total_ram=$(free -m | awk 'NR==2{printf "%.0f", $2/1024}')
        if [[ $total_ram -lt 3 ]]; then
            log_warning "GitLab development khuyến nghị ít nhất 3GB RAM. Hiện tại: ${total_ram}GB"
            log_info "Cấu hình đã được tối ưu để sử dụng ít tài nguyên hơn"
            if ! confirm_action "Tiếp tục triển khai với cấu hình tối ưu?"; then
                exit 1
            fi
        else
            log_success "RAM đủ yêu cầu cho development: ${total_ram}GB"
        fi
    else
        log_info "Không thể kiểm tra RAM trên Windows, giả định đủ yêu cầu"
        log_warning "Đảm bảo hệ thống có ít nhất 3GB RAM cho GitLab development"
    fi
    
    # Kiểm tra disk space (GitLab cần ít nhất 10GB)
    local available_space=$(df -BG "$PROJECT_ROOT" | awk 'NR==2 {print $4}' | sed 's/G//')
    if [[ $available_space -lt 10 ]]; then
        log_warning "GitLab khuyến nghị ít nhất 10GB dung lượng trống. Hiện tại: ${available_space}GB"
        if ! confirm_action "Tiếp tục triển khai?"; then
            exit 1
        fi
    else
        log_success "Dung lượng đĩa đủ yêu cầu: ${available_space}GB"
    fi
    
    log_success "Tất cả yêu cầu hệ thống đã được đáp ứng"
}

# Kiểm tra xung đột port
check_gitlab_port_conflicts() {
    log_info "Kiểm tra xung đột port cho GitLab..."
    
    local conflicts_found=false
    local conflicted_ports=()
    
    for port in "${REQUIRED_PORTS[@]}"; do
        if netstat -tuln 2>/dev/null | grep -q ":$port "; then
            log_warning "Port $port đang được sử dụng"
            conflicts_found=true
            conflicted_ports+=("$port")
        fi
    done
    
    if [[ "$conflicts_found" == "true" ]]; then
        log_warning "Phát hiện xung đột port: ${conflicted_ports[*]}"
        log_info "Các port này cần thiết cho GitLab:"
        echo "  • $GITLAB_HTTP_PORT: Web Interface"
        echo "  • $GITLAB_SSH_PORT: SSH Git operations"
        echo "  • $GITLAB_REGISTRY_PORT: Container Registry"
        echo
        
        if ! confirm_action "Bạn có muốn tiếp tục? (Có thể gây lỗi)"; then
            log_error "Hủy bỏ triển khai do xung đột port"
            exit 1
        fi
    else
        log_success "Không có xung đột port"
    fi
}

# Tạo thư mục cần thiết cho GitLab
create_gitlab_directories() {
    log_info "Tạo thư mục cần thiết cho GitLab..."
    
    local directories=(
        "$PROJECT_ROOT/gitlab/config"
        "$PROJECT_ROOT/gitlab/logs"
        "$PROJECT_ROOT/gitlab/data"
        "$PROJECT_ROOT/gitlab/backups"
        "$PROJECT_ROOT/gitlab/ssl"
    )
    
    for dir in "${directories[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            log_info "Đã tạo thư mục: $dir"
        fi
    done
    
    # Set proper permissions
    chmod 755 "$PROJECT_ROOT/gitlab"
    chmod -R 755 "$PROJECT_ROOT/gitlab"/*
    
    log_success "Đã tạo tất cả thư mục cần thiết cho GitLab"
}

# Kiểm tra và khởi động services cơ bản
check_basic_services() {
    log_info "Kiểm tra trạng thái services cơ bản..."
    
    cd "$PROJECT_ROOT"
    
    # Kiểm tra PostgreSQL
    if ! is_container_running "postgres"; then
        log_info "PostgreSQL chưa chạy, khởi động services cơ bản..."
        $DOCKER_COMPOSE up -d postgres redis
        
        # Chờ services sẵn sàng
        wait_for_container_health "postgres" 60
        wait_for_container_health "redis" 30
    else
        log_success "Services cơ bản đã sẵn sàng"
    fi
}

# Tạo và kiểm tra database cho GitLab - TỐI ƯU HÓA
setup_gitlab_database() {
    log_info "Thiết lập và kiểm tra database cho GitLab..."

    # Kiểm tra biến môi trường
    if [[ -z "${POSTGRES_USER_GITLAB:-}" ]] || [[ -z "${POSTGRES_PASSWORD_GITLAB:-}" ]]; then
        log_error "Biến môi trường GitLab database chưa được cấu hình!"
        log_info "Cần thiết lập trong .env:"
        echo "  POSTGRES_USER_GITLAB=nextflow"
        echo "  POSTGRES_PASSWORD_GITLAB=nextflow@2025"
        echo "  GITLAB_DATABASE=nextflow_gitlab"
        exit 1
    fi

    # === KIỂM TRA VÀ TẠO DATABASE ===
    log_info "Kiểm tra database ${GITLAB_DATABASE}..."
    if docker exec postgres psql -U nextflow -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='${GITLAB_DATABASE}';" | grep -q "1"; then
        log_success "✅ Database ${GITLAB_DATABASE} đã tồn tại"
    else
        log_info "Tạo database mới cho GitLab..."

        # Tạo database
        docker exec postgres psql -U nextflow -d postgres -c "CREATE DATABASE ${GITLAB_DATABASE} OWNER nextflow;"

        # Cấp quyền cho user GitLab (nếu khác user chính)
        if [[ "${POSTGRES_USER_GITLAB}" != "nextflow" ]]; then
            docker exec postgres psql -U nextflow -d postgres -c "CREATE USER ${POSTGRES_USER_GITLAB} WITH PASSWORD '${POSTGRES_PASSWORD_GITLAB}';"
            docker exec postgres psql -U nextflow -d postgres -c "GRANT ALL PRIVILEGES ON DATABASE ${GITLAB_DATABASE} TO ${POSTGRES_USER_GITLAB};"
        fi

        log_success "✅ Đã tạo database ${GITLAB_DATABASE}"
    fi

    # === KIỂM TRA KẾT NỐI DATABASE ===
    log_info "Kiểm tra kết nối database..."
    if docker exec postgres psql -U nextflow -d "${GITLAB_DATABASE}" -c "SELECT version();" >/dev/null 2>&1; then
        log_success "✅ Kết nối database thành công"
    else
        log_error "❌ Không thể kết nối database"
        log_info "Thử tạo lại database..."

        # Thử tạo lại database nếu cần
        docker exec postgres psql -U nextflow -d postgres -c "DROP DATABASE IF EXISTS ${GITLAB_DATABASE};" || true
        docker exec postgres psql -U nextflow -d postgres -c "CREATE DATABASE ${GITLAB_DATABASE} OWNER nextflow;"

        if docker exec postgres psql -U nextflow -d "${GITLAB_DATABASE}" -c "SELECT version();" >/dev/null 2>&1; then
            log_success "✅ Đã tạo lại database thành công"
        else
            log_error "❌ Vẫn không thể kết nối database"
            exit 1
        fi
    fi

    # === KIỂM TRA THÔNG TIN DATABASE ===
    log_info "Thông tin database ${GITLAB_DATABASE}:"
    local db_size=$(docker exec postgres psql -U nextflow -d "${GITLAB_DATABASE}" -tAc "SELECT pg_size_pretty(pg_database_size('${GITLAB_DATABASE}'));" 2>/dev/null || echo "Unknown")
    local db_encoding=$(docker exec postgres psql -U nextflow -d "${GITLAB_DATABASE}" -tAc "SELECT pg_encoding_to_char(encoding) FROM pg_database WHERE datname='${GITLAB_DATABASE}';" 2>/dev/null || echo "Unknown")
    echo "  • Database size: $db_size"
    echo "  • Encoding: $db_encoding"
    echo "  • Owner: nextflow"
    echo "  • Connection: OK"
}

# Kiểm tra GitLab containers để tránh dừng không cần thiết
check_existing_gitlab_containers() {
    log_info "🔍 Kiểm tra GitLab containers đang chạy..."

    cd "$PROJECT_ROOT"

    # Kiểm tra GitLab container
    if is_container_running "gitlab"; then
        log_success "✅ GitLab đang chạy - sẽ được giữ nguyên"

        # Kiểm tra GitLab health
        if docker exec gitlab gitlab-ctl status >/dev/null 2>&1; then
            log_success "✅ GitLab services đang hoạt động tốt"
            return 0
        else
            log_warning "⚠️ GitLab container chạy nhưng services có vấn đề - sẽ restart"
            return 1
        fi
    else
        log_info "📦 GitLab chưa chạy - sẽ được triển khai"
        return 1
    fi
}

# Dừng GitLab containers chỉ khi cần thiết
stop_gitlab_if_needed() {
    log_info "🛑 Dừng GitLab container do có vấn đề..."

    cd "$PROJECT_ROOT"

    # Dừng GitLab container
    if is_container_running "gitlab"; then
        log_info "Dừng container: gitlab"
        docker stop "gitlab" 2>/dev/null || true
        docker rm "gitlab" 2>/dev/null || true
    fi

    # Dừng GitLab service bằng docker-compose
    $DOCKER_COMPOSE --profile gitlab stop gitlab 2>/dev/null || true
    $DOCKER_COMPOSE --profile gitlab rm -f gitlab 2>/dev/null || true

    log_success "Đã dừng GitLab container"
}

# Triển khai GitLab
deploy_gitlab_container() {
    log_info "Triển khai GitLab CE..."

    cd "$PROJECT_ROOT"

    # Khởi động GitLab với profile
    log_info "Khởi động GitLab container..."
    $DOCKER_COMPOSE --profile gitlab up -d gitlab

    log_success "Đã khởi động GitLab container"
}

# Chờ GitLab sẵn sàng
wait_for_gitlab_ready() {
    log_info "Chờ GitLab khởi động hoàn toàn..."
    log_warning "⏳ GitLab cần 5-10 phút để khởi động lần đầu, vui lòng kiên nhẫn..."
    
    # Chờ container healthy (có thể mất rất lâu)
    local max_attempts=60  # 60 * 30s = 30 phút
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        if docker exec gitlab gitlab-ctl status >/dev/null 2>&1; then
            log_success "GitLab services đã khởi động!"
            break
        fi
        
        log_info "Chờ GitLab khởi động... (lần thử $attempt/$max_attempts)"
        show_progress $attempt $max_attempts
        sleep 30
        ((attempt++))
    done
    
    if [[ $attempt -gt $max_attempts ]]; then
        log_error "GitLab không thể khởi động sau $((max_attempts * 30 / 60)) phút"
        log_info "Kiểm tra logs: docker logs gitlab"
        return 1
    fi
    
    # Kiểm tra web interface
    log_info "Kiểm tra web interface..."
    local web_attempts=20
    local web_attempt=1
    
    while [[ $web_attempt -le $web_attempts ]]; do
        if curl -s -o /dev/null -w "%{http_code}" "http://localhost:${GITLAB_HTTP_PORT}" | grep -qE "^(200|302)$"; then
            log_success "GitLab web interface đã sẵn sàng!"
            return 0
        fi
        
        log_info "Chờ web interface... (lần thử $web_attempt/$web_attempts)"
        sleep 15
        ((web_attempt++))
    done
    
    log_warning "Web interface có thể chưa sẵn sàng hoàn toàn, nhưng GitLab đã khởi động"
    return 0
}

# Hiển thị thông tin truy cập GitLab
show_gitlab_access_info() {
    show_banner "🦊 THÔNG TIN TRUY CẬP GITLAB"

    log_info "🌐 Web Interface:"
    echo "   URL: http://localhost:${GITLAB_HTTP_PORT}"
    echo "   Username: ${GITLAB_ROOT_USERNAME}"
    echo "   Password: ${GITLAB_ROOT_PASSWORD}"
    echo "   Email: ${GITLAB_ROOT_EMAIL}"
    echo "   Full Name: ${GITLAB_ROOT_NAME}"
    echo

    log_info "🔑 Git SSH Access:"
    echo "   SSH URL: ssh://git@localhost:${GITLAB_SSH_PORT}/username/repository.git"
    echo "   Example: git clone ssh://git@localhost:${GITLAB_SSH_PORT}/root/my-project.git"
    echo

    log_info "🌐 Git HTTPS Access:"
    echo "   HTTPS URL: http://localhost:${GITLAB_HTTP_PORT}/username/repository.git"
    echo "   Example: git clone http://localhost:${GITLAB_HTTP_PORT}/root/my-project.git"
    echo

    log_info "📦 Container Registry:"
    echo "   Registry URL: localhost:${GITLAB_REGISTRY_PORT}"
    echo "   Login: docker login localhost:${GITLAB_REGISTRY_PORT}"
    echo "   Push: docker push localhost:${GITLAB_REGISTRY_PORT}/group/project/image:tag"
    echo

    log_info "🗄️ Database Information:"
    echo "   Database: ${GITLAB_DATABASE}"
    echo "   User: ${POSTGRES_USER_GITLAB:-nextflow}"
    echo "   Host: postgres:5432"
    echo

    log_info "📊 Monitoring & Management:"
    echo "   GitLab Health: http://localhost:${GITLAB_HTTP_PORT}/-/health_check"
    echo "   Admin Area: http://localhost:${GITLAB_HTTP_PORT}/admin"
    echo "   Container logs: docker logs gitlab"
    echo

    log_warning "⚠️ Lưu ý quan trọng:"
    echo "   • Thay đổi mật khẩu root mặc định sau khi đăng nhập lần đầu"
    echo "   • Cấu hình SSH keys cho Git operations"
    echo "   • Thiết lập backup định kỳ"
    echo "   • Cấu hình SSL certificates cho production"
    echo "   • Thiết lập email notifications"
    echo "   • Cấu hình CI/CD runners nếu cần"
    echo

    log_info "🔧 Useful Commands:"
    echo "   • Restart GitLab: docker restart gitlab"
    echo "   • GitLab console: docker exec -it gitlab gitlab-rails console"
    echo "   • Backup: docker exec gitlab gitlab-backup create"
    echo "   • Check status: docker exec gitlab gitlab-ctl status"
    echo "   • Reconfigure: docker exec gitlab gitlab-ctl reconfigure"
}

# Triển khai Cloudflare tunnel cho GitLab (tùy chọn)
deploy_gitlab_tunnel() {
    if [[ -f "$SCRIPTS_DIR/cloudflare/setup-tunnels.sh" ]]; then
        log_info "Triển khai Cloudflare tunnel cho GitLab..."

        # Gọi script setup tunnel với cấu hình GitLab
        "$SCRIPTS_DIR/cloudflare/setup-tunnels.sh" --service gitlab

        log_success "Đã triển khai Cloudflare tunnel cho GitLab"
    else
        log_warning "Script Cloudflare tunnel không tìm thấy, bỏ qua bước này"
    fi
}

# Kiểm tra GitLab database tables - THÊM MỚI
check_gitlab_database_tables() {
    log_info "Kiểm tra GitLab database tables..."

    # Chờ GitLab migration hoàn thành
    log_info "Chờ GitLab database migration hoàn thành..."
    local max_attempts=10
    local attempt=1

    while [[ $attempt -le $max_attempts ]]; do
        # Kiểm tra xem GitLab đã tạo tables chưa
        local table_count=$(docker exec postgres psql -U nextflow -d "${GITLAB_DATABASE}" -tAc "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null || echo "0")

        if [[ $table_count -gt 50 ]]; then
            log_success "✅ GitLab database tables đã được tạo ($table_count tables)"
            break
        elif [[ $table_count -gt 0 ]]; then
            log_info "GitLab đang tạo database tables... ($table_count tables, lần thử $attempt/$max_attempts)"
        else
            log_info "Chờ GitLab bắt đầu tạo database tables... (lần thử $attempt/$max_attempts)"
        fi

        sleep 30
        ((attempt++))
    done

    if [[ $attempt -gt $max_attempts ]]; then
        log_warning "⚠️ GitLab database tables có thể chưa được tạo hoàn toàn"
        return 1
    fi

    # Kiểm tra một số tables quan trọng của GitLab
    log_info "Kiểm tra các tables quan trọng của GitLab..."
    local important_tables=("users" "projects" "namespaces" "merge_requests" "issues" "ci_builds" "application_settings")
    local missing_tables=()

    for table in "${important_tables[@]}"; do
        if docker exec postgres psql -U nextflow -d "${GITLAB_DATABASE}" -tAc "SELECT 1 FROM information_schema.tables WHERE table_name = '$table';" 2>/dev/null | grep -q "1"; then
            log_success "  ✅ Table '$table' exists"
        else
            log_warning "  ⚠️ Table '$table' missing"
            missing_tables+=("$table")
        fi
    done

    if [[ ${#missing_tables[@]} -eq 0 ]]; then
        log_success "✅ Tất cả tables quan trọng đã được tạo"
    else
        log_warning "⚠️ Một số tables quan trọng chưa được tạo: ${missing_tables[*]}"
        log_info "GitLab có thể vẫn đang trong quá trình migration"
    fi

    # Hiển thị thống kê database
    log_info "Thống kê GitLab database:"
    local total_tables=$(docker exec postgres psql -U nextflow -d "${GITLAB_DATABASE}" -tAc "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null || echo "0")
    local total_indexes=$(docker exec postgres psql -U nextflow -d "${GITLAB_DATABASE}" -tAc "SELECT COUNT(*) FROM pg_indexes WHERE schemaname = 'public';" 2>/dev/null || echo "0")
    local db_size=$(docker exec postgres psql -U nextflow -d "${GITLAB_DATABASE}" -tAc "SELECT pg_size_pretty(pg_database_size('${GITLAB_DATABASE}'));" 2>/dev/null || echo "Unknown")

    echo "  • Total tables: $total_tables"
    echo "  • Total indexes: $total_indexes"
    echo "  • Database size: $db_size"

    return 0
}

# Chạy post-deployment checks - TỐI ƯU HÓA
run_gitlab_health_checks() {
    log_info "Chạy health checks cho GitLab..."

    # Kiểm tra GitLab services
    log_info "Kiểm tra GitLab internal services..."
    if docker exec gitlab gitlab-ctl status | grep -q "run:"; then
        log_success "✅ GitLab internal services đang chạy"
    else
        log_warning "⚠️ Một số GitLab services có thể chưa sẵn sàng"
    fi

    # Kiểm tra database connection
    log_info "Kiểm tra kết nối database từ GitLab..."
    if docker exec gitlab gitlab-rails runner "puts ActiveRecord::Base.connection.active?" 2>/dev/null | grep -q "true"; then
        log_success "✅ GitLab kết nối database thành công"

        # Kiểm tra database tables nếu kết nối thành công
        check_gitlab_database_tables
    else
        log_warning "⚠️ GitLab kết nối database có vấn đề"
    fi

    # Kiểm tra Redis connection
    log_info "Kiểm tra kết nối Redis từ GitLab..."
    if docker exec gitlab gitlab-rails runner "puts Gitlab::Redis::Cache.with { |redis| redis.ping }" 2>/dev/null | grep -q "PONG"; then
        log_success "✅ GitLab kết nối Redis thành công"
    else
        log_warning "⚠️ GitLab kết nối Redis có vấn đề"
    fi

    # Kiểm tra web interface
    log_info "Kiểm tra web interface..."
    local http_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${GITLAB_HTTP_PORT}" || echo "000")
    if [[ "$http_code" =~ ^(200|302)$ ]]; then
        log_success "✅ Web interface hoạt động (HTTP $http_code)"
    else
        log_warning "⚠️ Web interface có vấn đề (HTTP $http_code)"
    fi

    # Kiểm tra SSH
    log_info "Kiểm tra SSH service..."
    if nc -z localhost "$GITLAB_SSH_PORT" 2>/dev/null; then
        log_success "✅ SSH service hoạt động (port $GITLAB_SSH_PORT)"
    else
        log_warning "⚠️ SSH service có vấn đề (port $GITLAB_SSH_PORT)"
    fi

    # Kiểm tra Container Registry
    log_info "Kiểm tra Container Registry..."
    if nc -z localhost "$GITLAB_REGISTRY_PORT" 2>/dev/null; then
        log_success "✅ Container Registry hoạt động (port $GITLAB_REGISTRY_PORT)"
    else
        log_warning "⚠️ Container Registry có vấn đề (port $GITLAB_REGISTRY_PORT)"
    fi
}

# ============================================================================
# MAIN DEPLOYMENT FUNCTION
# ============================================================================

# Hàm triển khai GitLab chính
deploy_gitlab_main() {
    local force_deploy="${1:-false}"

    # Hiển thị banner
    show_gitlab_banner

    # Kiểm tra yêu cầu hệ thống
    check_gitlab_requirements

    # Kiểm tra xung đột port (skip if force deploy)
    if [[ "$force_deploy" != "true" ]]; then
        check_gitlab_port_conflicts
    else
        log_info "Bỏ qua kiểm tra port conflicts (force mode)"
    fi

    # Tạo thư mục cần thiết
    create_gitlab_directories

    # Kiểm tra GitLab containers hiện tại
    if check_existing_gitlab_containers; then
        log_success "🎯 Tối ưu: GitLab đang chạy tốt - bỏ qua triển khai"
        # Vẫn kiểm tra database và hiển thị thông tin
        check_basic_services
        show_gitlab_access_info
        log_success "🎉 GitLab đã sẵn sàng!"
        return 0
    else
        log_info "📦 Cần triển khai GitLab mới hoặc restart do có vấn đề"
        stop_gitlab_if_needed
    fi

    # Kiểm tra services cơ bản
    check_basic_services

    # Thiết lập database
    setup_gitlab_database

    # Triển khai GitLab
    deploy_gitlab_container

    # Chờ GitLab sẵn sàng
    if wait_for_gitlab_ready; then
        log_success "✅ GitLab đã khởi động thành công!"
    else
        log_error "❌ GitLab gặp vấn đề khi khởi động"
        log_info "Kiểm tra logs: docker logs gitlab"
        return 1
    fi

    # Chạy health checks
    run_gitlab_health_checks

    # Triển khai tunnel (tùy chọn)
    deploy_gitlab_tunnel

    # Hiển thị thông tin truy cập
    show_gitlab_access_info

    log_success "🎉 Triển khai GitLab hoàn tất!"

    return 0
}

# ============================================================================
# SCRIPT EXECUTION
# ============================================================================

# Alias function để tương thích với discovery system
deploy_gitlab() {
    deploy_gitlab_main "$@"
}

# Chạy script nếu được gọi trực tiếp
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    deploy_gitlab_main "$@"
fi
