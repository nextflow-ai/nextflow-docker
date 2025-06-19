#!/bin/bash

# Basic profile deployment for NextFlow Docker
# Author: Augment Agent
# Version: 1.0
#
# Services included:
# - n8n (workflow automation)
# - Flowise (AI orchestration)
# - PostgreSQL (database)
# - Redis (cache)
# - Qdrant (vector database)
# - RabbitMQ (message queue)
# - WordPress + MariaDB (landing page)

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Load environment variables
if [[ -f "$PROJECT_ROOT/.env" ]]; then
    source "$PROJECT_ROOT/.env"
else
    echo "❌ File .env không tồn tại tại: $PROJECT_ROOT/.env"
    exit 1
fi

source "$SCRIPT_DIR/../utils/logging.sh"
source "$SCRIPT_DIR/../utils/docker.sh"
source "$SCRIPT_DIR/../utils/validation.sh"

# Profile configuration
PROFILE_NAME="basic"
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.yml}"

# Services in basic profile
BASIC_SERVICES=(
    "postgres"
    "redis"
    "redis-commander"
    "qdrant"
    "rabbitmq"
    "mariadb"
    "wordpress"
    "n8n"
    "flowise"
)

# Cloudflare tunnel for basic profile
BASIC_TUNNEL_SERVICE="cloudflare-tunnel"
BASIC_TUNNEL_CREDENTIALS="cloudflared/credentials/credentials.json"
BASIC_TUNNEL_CONFIG="cloudflared/config/cloudflared-config.yml"

# ============================================================================
# CHUẨN HÓA PORT MAPPING - ĐÃ TỐI ƯU HÓA VÀ ĐỒNG BỘ
# ============================================================================
# Tất cả ports đã được chuẩn hóa để đồng bộ với docker-compose.yml và Cloudflare tunnels
BASIC_PORTS=(
    "5432:PostgreSQL"
    "6379:Redis"
    "6101:Redis Commander"      # CHUẨN HÓA: Port 6101 cho Redis web interface
    "6333:Qdrant HTTP"
    "6334:Qdrant gRPC"
    "5672:RabbitMQ AMQP"
    "15672:RabbitMQ Management"
    "3306:MariaDB"
    "8080:WordPress"            # CHUẨN HÓA: Port 8080 cho WordPress landing page
    "8003:n8n"                  # CHUẨN HÓA: Port 8003 cho n8n automation
    "8001:Flowise"              # CHUẨN HÓA: Port 8001 cho Flowise AI
)

# Deploy basic profile
deploy_basic() {
    local force_deploy="${1:-false}"

    show_banner "TRIỂN KHAI PROFILE BASIC"

    log_info "Profile Basic bao gồm các dịch vụ cốt lõi:"
    for service in "${BASIC_SERVICES[@]}"; do
        log_info "  ✓ $service"
    done
    echo

    # Validate requirements
    if ! validate_profile_requirements "$PROFILE_NAME"; then
        log_warning "Một số yêu cầu không được đáp ứng, nhưng sẽ tiếp tục triển khai..."
    fi

    # Check ports (skip if force deploy)
    if [[ "$force_deploy" != "true" ]]; then
        log_info "Kiểm tra các port cần thiết..."
        local port_conflicts=()
        for port_service in "${BASIC_PORTS[@]}"; do
            local port="${port_service%:*}"
            local service="${port_service#*:}"
            if ! validate_port_available "$port" "$service"; then
                port_conflicts+=("$port ($service)")
            fi
        done

        if [[ ${#port_conflicts[@]} -gt 0 ]]; then
            log_warning "Các port bị xung đột:"
            for conflict in "${port_conflicts[@]}"; do
                log_warning "  - $conflict"
            done

            if ! confirm_action "Tiếp tục triển khai dù có xung đột port?"; then
                log_info "Hủy triển khai."
                return 1
            fi
        fi
    else
        log_info "Bỏ qua kiểm tra port conflicts (force mode)"
    fi

    # Create necessary directories
    create_basic_directories

    # Deploy services in order
    deploy_basic_services

    # Wait for services to be ready
    wait_for_basic_services

    # Deploy Cloudflare tunnel automatically
    deploy_basic_tunnel

    # Show deployment summary
    show_basic_summary
}

# Create necessary directories
create_basic_directories() {
    log_info "Tạo các thư mục cần thiết..."

    local directories=(
        "backups/postgres"
        "backups/mariadb"
        "backups/n8n/workflows"
        "backups/n8n/credentials"
        "backups/wordpress"
        "shared"
        "n8n/backup"
        "wordpress/themes"
        "wordpress/plugins"
    )

    for dir in "${directories[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            log_debug "Tạo thư mục: $dir"
        fi
    done

    log_success "Đã tạo các thư mục cần thiết!"
}

# Deploy Cloudflare tunnel for basic profile
deploy_basic_tunnel() {
    log_info "🌐 Triển khai Cloudflare tunnel cho basic services..."

    # Kiểm tra xem cloudflare-tunnel đã chạy chưa
    if is_container_running "cloudflare-tunnel"; then
        log_info "🔄 Restart cloudflare-tunnel để áp dụng cấu hình mới..."
        docker restart cloudflare-tunnel
    else
        log_info "🚀 Khởi động cloudflare-tunnel..."
        if ! $DOCKER_COMPOSE -f "$COMPOSE_FILE" up -d cloudflare-tunnel; then
            log_warning "⚠️ Không thể khởi động cloudflare-tunnel (có thể do thiếu credentials)"
            log_info "💡 Để cấu hình Cloudflare tunnel:"
            log_info "  1. Tạo tunnel trên Cloudflare dashboard"
            log_info "  2. Tải credentials và đặt vào cloudflared/credentials/"
            log_info "  3. Cập nhật config trong cloudflared/config/"
            return 0
        fi
    fi

    # Chờ tunnel kết nối
    log_info "⏳ Chờ Cloudflare tunnel kết nối..."
    sleep 15

    # Kiểm tra logs để đảm bảo tunnel hoạt động
    if docker logs cloudflare-tunnel 2>&1 | grep -q -E "(Connection.*registered|connected to cloudflare)"; then
        log_success "✅ Cloudflare tunnel đã kết nối thành công!"

        # Hiển thị thông tin domains - ĐÃ TỐI ƯU HÓA
        log_info "🌐 Các domains có sẵn qua Cloudflare tunnel:"
        echo "  🏠 WordPress (Landing): https://nextflow.vn, https://www.nextflow.vn"
        echo "  🦊 GitLab (Source Code): https://gitlab.nextflow.vn"
        echo "  📧 Mail Server: https://mail.nextflow.vn"
        echo ""
        echo "  🤖 AI Services (tunnel riêng):"
        echo "    • n8n Automation: https://n8n.nextflow.vn"
        echo "    • Flowise AI: https://flowise.nextflow.vn"
        echo "    • Langflow: https://langflow.nextflow.vn"
        echo "    • Chat AI: https://chat.nextflow.vn"

        return 0
    else
        log_warning "⚠️ Cloudflare tunnel đang chạy nhưng có thể chưa kết nối hoàn toàn"
        log_info "📋 Kiểm tra logs: docker logs cloudflare-tunnel"
        log_info "🔧 Kiểm tra cấu hình: cloudflared/config/cloudflared-config.yml"
        return 0
    fi
}

# Deploy basic services
deploy_basic_services() {
    log_info "Triển khai các dịch vụ basic..."

    # Kiểm tra services nào đang chạy để KHÔNG dừng chúng
    log_info "🔍 Kiểm tra services đang chạy để tránh dừng không cần thiết..."
    local running_services=()
    local services_to_deploy=()

    for service in "${BASIC_SERVICES[@]}"; do
        if is_container_running "$service"; then
            running_services+=("$service")
            log_info "✅ $service đang chạy - sẽ được giữ nguyên"
        else
            services_to_deploy+=("$service")
            log_info "📦 $service chưa chạy - sẽ được triển khai"
        fi
    done

    # Chỉ thông báo nếu có services đang chạy
    if [[ ${#running_services[@]} -gt 0 ]]; then
        log_success "🎯 Tối ưu: Giữ nguyên ${#running_services[@]} services đang chạy: ${running_services[*]}"
    fi

    # Quyết định cách xử lý services
    if [[ ${#services_to_deploy[@]} -eq 0 ]]; then
        log_success "🎉 Tất cả basic services đã đang chạy!"
        log_info "🔄 Vẫn sẽ apply cấu hình mới cho tất cả services..."
        # Apply cấu hình mới cho services đang chạy
        services_to_deploy=("${BASIC_SERVICES[@]}")
    else
        log_info "📦 Sẽ triển khai ${#services_to_deploy[@]} services mới: ${services_to_deploy[*]}"
    fi

    # Deploy infrastructure services first
    log_info "🚀 Khởi động/cập nhật các dịch vụ hạ tầng..."

    # PostgreSQL first (database) - luôn apply cấu hình mới
    log_loading "Khởi động/cập nhật PostgreSQL..."
    $DOCKER_COMPOSE -f "$COMPOSE_FILE" up -d postgres
    wait_for_container_health "postgres" 30

    # Initialize PostgreSQL databases after PostgreSQL is ready
    log_info "Khởi tạo PostgreSQL databases cần thiết..."
    if [[ -f "$SCRIPT_DIR/../init-databases.sh" ]]; then
        bash "$SCRIPT_DIR/../init-databases.sh" || {
            log_warning "Không thể chạy script khởi tạo databases tự động"
            log_info "Tạo databases thủ công..."

            # Tạo databases cần thiết thủ công
            local databases=("nextflow_n8n" "nextflow_flowise" "nextflow_langflow")
            for db in "${databases[@]}"; do
                log_info "Tạo database: $db"
                docker exec postgres psql -U nextflow -d postgres -c "CREATE DATABASE $db OWNER nextflow;" 2>/dev/null || {
                    log_debug "Database $db có thể đã tồn tại"
                }
            done
        }
    else
        log_warning "Script init-databases.sh không tồn tại, tạo databases thủ công..."
        # Tạo databases cần thiết thủ công
        local databases=("nextflow_n8n" "nextflow_flowise" "nextflow_langflow")
        for db in "${databases[@]}"; do
            log_info "Tạo database: $db"
            docker exec postgres psql -U nextflow -d postgres -c "CREATE DATABASE $db OWNER nextflow;" 2>/dev/null || {
                log_debug "Database $db có thể đã tồn tại"
            }
        done
    fi

    # Redis (cache) - luôn apply cấu hình mới
    log_loading "Khởi động/cập nhật Redis..."
    $DOCKER_COMPOSE -f "$COMPOSE_FILE" up -d redis
    wait_for_container_health "redis" 15

    # Redis Commander (Redis web interface) - luôn apply cấu hình mới
    log_loading "Khởi động/cập nhật Redis Commander..."
    $DOCKER_COMPOSE -f "$COMPOSE_FILE" up -d redis-commander
    sleep 5

    # Qdrant (vector database) - luôn apply cấu hình mới
    log_loading "Khởi động/cập nhật Qdrant..."
    $DOCKER_COMPOSE -f "$COMPOSE_FILE" up -d qdrant
    sleep 5

    # RabbitMQ (message queue) - luôn apply cấu hình mới
    log_loading "Khởi động/cập nhật RabbitMQ..."
    $DOCKER_COMPOSE -f "$COMPOSE_FILE" up -d rabbitmq
    wait_for_container_health "rabbitmq" 30

    # MariaDB (for WordPress) - luôn apply cấu hình mới
    log_loading "Khởi động/cập nhật MariaDB..."
    $DOCKER_COMPOSE -f "$COMPOSE_FILE" up -d mariadb
    sleep 10

    # Initialize MariaDB database and user for WordPress
    log_info "Khởi tạo database và user cho WordPress..."
    local max_attempts=30
    local attempt=1

    # Wait for MariaDB to be ready
    while [ $attempt -le $max_attempts ]; do
        if docker exec mariadb mariadb -u root -p"${MYSQL_ROOT_PASSWORD}" -e "SELECT 1;" >/dev/null 2>&1; then
            log_success "MariaDB đã sẵn sàng!"
            break
        fi
        log_debug "Lần thử $attempt/$max_attempts - Đợi MariaDB sẵn sàng..."
        sleep 2
        ((attempt++))
    done

    if [ $attempt -gt $max_attempts ]; then
        log_error "MariaDB không sẵn sàng sau $max_attempts lần thử!"
        return 1
    fi

    # Create WordPress database and user
    log_info "Tạo database WordPress..."
    docker exec mariadb mariadb -u root -p"${MYSQL_ROOT_PASSWORD}" -e "
        CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
        CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
        FLUSH PRIVILEGES;
    " 2>/dev/null || {
        log_warning "Không thể tạo database/user WordPress tự động"
        log_info "Có thể database và user đã tồn tại"
    }

    # Verify database creation
    if docker exec mariadb mariadb -u root -p"${MYSQL_ROOT_PASSWORD}" -e "SHOW DATABASES LIKE '${MYSQL_DATABASE}';" 2>/dev/null | grep -q "${MYSQL_DATABASE}"; then
        log_success "✅ Database WordPress đã được tạo: ${MYSQL_DATABASE}"
    else
        log_error "❌ Không thể tạo database WordPress"
    fi

    # Application services - luôn apply cấu hình mới
    log_info "🚀 Khởi động/cập nhật các dịch vụ ứng dụng..."

    # WordPress - luôn apply cấu hình mới
    log_loading "Khởi động/cập nhật WordPress..."
    $DOCKER_COMPOSE -f "$COMPOSE_FILE" up -d wordpress
    sleep 5

    # n8n (depends on PostgreSQL and Redis) - luôn apply cấu hình mới
    log_loading "Khởi động/cập nhật n8n..."
    $DOCKER_COMPOSE -f "$COMPOSE_FILE" up -d n8n
    sleep 10

    # Flowise (depends on Redis) - luôn apply cấu hình mới
    log_loading "Khởi động/cập nhật Flowise..."
    $DOCKER_COMPOSE -f "$COMPOSE_FILE" up -d flowise
    sleep 5

    # Deploy Cloudflare tunnel if configured
    deploy_basic_tunnel

    # Final database check and setup
    log_info "Kiểm tra và cập nhật databases cuối cùng..."
    if [[ -f "$SCRIPT_DIR/../check-databases.sh" ]]; then
        bash "$SCRIPT_DIR/../check-databases.sh" --check || {
            log_warning "Script kiểm tra databases gặp vấn đề, nhưng tiếp tục triển khai"
        }
    else
        log_warning "Script check-databases.sh không tồn tại"
    fi

    log_success "Đã triển khai tất cả các dịch vụ basic!"
}

# Wait for basic services
wait_for_basic_services() {
    log_info "Đợi các dịch vụ sẵn sàng..."

    local services_to_check=(
        "postgres:30"
        "redis:15"
        "rabbitmq:30"
        "mariadb:20"
        "wordpress:15"
        "n8n:20"
        "flowise:15"
    )

    for service_timeout in "${services_to_check[@]}"; do
        local service="${service_timeout%:*}"
        local timeout="${service_timeout#*:}"

        log_loading "Kiểm tra $service..."
        if wait_for_container_health "$service" "$timeout"; then
            log_success "$service đã sẵn sàng!"
        else
            log_warning "$service có thể chưa sẵn sàng hoàn toàn."
        fi
    done
}

# Show deployment summary
show_basic_summary() {
    show_banner "TỔNG KẾT TRIỂN KHAI BASIC"

    log_success "Profile Basic đã được triển khai thành công!"
    echo

    # ============================================================================
    # HIỂN THỊ THÔNG TIN DỊCH VỤ - ĐÃ CHUẨN HÓA PORT
    # ============================================================================
    log_info "Các dịch vụ đã triển khai (ports đã chuẩn hóa):"
    echo
    echo "🔧 Hạ tầng cơ sở:"
    echo "  • PostgreSQL      : localhost:5432"
    echo "  • Redis           : localhost:6379"
    echo "  • Redis Commander : http://localhost:6101 (admin/nextflow@2025)"
    echo "  • Qdrant Vector DB: http://localhost:6333"
    echo "  • RabbitMQ        : http://localhost:15672 (admin/nextflow@2025)"
    echo "  • MariaDB         : localhost:3306"
    echo
    echo "🚀 Ứng dụng chính:"
    echo "  • WordPress       : http://localhost:8080 (Landing Page)"
    echo "  • n8n Automation  : http://localhost:8003"
    echo "  • Flowise AI      : http://localhost:8001"
    echo

    # Show Cloudflare tunnel info if running
    if is_container_running "$BASIC_TUNNEL_SERVICE"; then
        echo "🌐 Cloudflare Tunnel:"
        echo "  • Status        : ✅ Đang chạy"
        if [[ -n "${CLOUDFLARE_TUNNEL_ID:-}" ]]; then
            echo "  • Tunnel ID     : ${CLOUDFLARE_TUNNEL_ID}"
        fi
        echo "  • External URLs : Xem trong Cloudflare Dashboard"
        echo
    else
        echo "🌐 Cloudflare Tunnel:"
        echo "  • Status        : ❌ Chưa khởi động"
        echo "  • Setup         : ./scripts/update-cloudflare-config.sh"
        echo
    fi

    # ============================================================================
    # THÔNG TIN ĐĂNG NHẬP - ĐÃ CHUẨN HÓA PASSWORD
    # ============================================================================
    log_info "Thông tin đăng nhập mặc định (password thống nhất: nextflow@2025):"
    echo "  • RabbitMQ Management : admin/nextflow@2025"
    echo "  • Redis Commander     : admin/nextflow@2025"
    echo "  • Flowise AI          : admin/nextflow@2025"
    echo "  • WordPress           : Thiết lập qua giao diện web lần đầu"
    echo "  • n8n Automation      : Thiết lập qua giao diện web lần đầu"
    echo

    # Check service status
    log_info "Trạng thái các container:"
    $DOCKER_COMPOSE -f "$COMPOSE_FILE" ps
    echo

    log_info "Để xem logs của một service cụ thể:"
    echo "  docker-compose logs <service_name>"
    echo
    log_info "Để dừng tất cả services:"
    echo "  ./scripts/deploy.sh --stop"
    echo

    # Check for any failed services
    local failed_services=()
    for service in "${BASIC_SERVICES[@]}"; do
        if ! is_container_running "$service"; then
            failed_services+=("$service")
        fi
    done

    if [[ ${#failed_services[@]} -gt 0 ]]; then
        log_warning "Các service sau có thể chưa khởi động thành công:"
        for service in "${failed_services[@]}"; do
            log_warning "  - $service"
        done
        echo
        log_info "Kiểm tra logs để xem chi tiết:"
        for service in "${failed_services[@]}"; do
            echo "  docker-compose logs $service"
        done
    fi
}

# Stop basic services
stop_basic() {
    show_banner "DỪNG PROFILE BASIC"

    log_info "Dừng các dịch vụ basic..."

    # Stop in reverse order
    local services_reverse=(
        "flowise"
        "n8n"
        "wordpress"
        "mariadb"
        "rabbitmq"
        "qdrant"
        "redis"
        "postgres"
    )

    for service in "${services_reverse[@]}"; do
        if is_container_running "$service"; then
            log_loading "Dừng $service..."
            docker stop "$service" 2>/dev/null || true
            docker rm "$service" 2>/dev/null || true
        fi
    done

    # Stop basic services using docker-compose
    log_info "Dừng basic services bằng docker-compose..."
    for service in "${services_reverse[@]}"; do
        $DOCKER_COMPOSE -f "$COMPOSE_FILE" stop "$service" 2>/dev/null || true
        $DOCKER_COMPOSE -f "$COMPOSE_FILE" rm -f "$service" 2>/dev/null || true
    done

    log_success "Đã dừng tất cả các dịch vụ basic!"
}

# Restart basic services
restart_basic() {
    show_banner "KHỞI ĐỘNG LẠI PROFILE BASIC"

    log_info "Khởi động lại các dịch vụ basic..."

    stop_basic
    sleep 5
    deploy_basic
}

# Check basic services status
status_basic() {
    show_banner "TRẠNG THÁI PROFILE BASIC"

    log_info "Kiểm tra trạng thái các dịch vụ basic..."

    for service in "${BASIC_SERVICES[@]}"; do
        if is_container_running "$service"; then
            log_success "$service: Đang chạy"
        else
            log_error "$service: Không chạy"
        fi
    done

    echo
    log_info "Chi tiết trạng thái:"
    $DOCKER_COMPOSE -f "$COMPOSE_FILE" ps
}

# Export functions
export -f deploy_basic stop_basic restart_basic status_basic
export -f create_basic_directories deploy_basic_services
export -f wait_for_basic_services show_basic_summary
