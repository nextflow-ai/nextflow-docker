#!/bin/bash

# ============================================================================
# NEXTFLOW DOCKER - PROFILE LANGFLOW
# ============================================================================
# Tác giả: NextFlow Development Team
# Phiên bản: 2.0
# Ngày cập nhật: 2025-06-17
#
# MÔ TẢ:
# Profile này chỉ triển khai Langflow - Platform low-code/no-code để xây dựng
# và triển khai AI workflows phức tạp. Tích hợp với LangChain, OpenAI,
# và các AI frameworks khác.
#
# ĐIỀU KIỆN TIÊN QUYẾT:
# - Profile 'basic' phải được triển khai trước (PostgreSQL + Redis)
# - Các dependencies sẽ được kiểm tra nhưng KHÔNG được cài đặt lại
#
# DỊCH VỤ TRIỂN KHAI:
# - Langflow (AI workflow platform) - Cổng 7860
# - Database: nextflow_langflow (PostgreSQL)
# - Cloudflare Tunnel AI (truy cập từ xa) - Tùy chọn
#
# DỊCH VỤ DEPENDENCIES (chỉ kiểm tra):
# - PostgreSQL: 5432 (từ profile basic)
# - Redis: 6379 (từ profile basic - optional)
# ============================================================================

# Import các thư viện cần thiết
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/logging.sh"
source "$SCRIPT_DIR/../utils/docker.sh"
source "$SCRIPT_DIR/../utils/validation.sh"

# ============================================================================
# CẤU HÌNH PROFILE LANGFLOW - CHỈ TRIỂN KHAI LANGFLOW
# ============================================================================

# Tên profile
PROFILE_NAME="langflow"

# Danh sách services cần triển khai (chỉ Langflow và tunnel)
LANGFLOW_SERVICES=(
    "langflow"
)

# Danh sách services tùy chọn (sử dụng tunnel chính)
LANGFLOW_OPTIONAL_SERVICES=(
    "cloudflare-tunnel"
)

# Danh sách services dependencies (chỉ kiểm tra, KHÔNG triển khai)
LANGFLOW_DEPENDENCIES=(
    "postgres"
    "redis"
)

# Cổng dịch vụ Langflow
LANGFLOW_PORT="7860"

# Thư mục dữ liệu Langflow
LANGFLOW_DIRECTORIES=(
    "langflow/flows"
    "langflow/components"
    "langflow/logs"
    "shared"
)

# ============================================================================
# FUNCTIONS KIỂM TRA VÀ VALIDATION
# ============================================================================

# Hàm kiểm tra điều kiện tiên quyết cho Langflow (tối ưu)
check_langflow_prerequisites() {
    log_info "🔍 Kiểm tra điều kiện tiên quyết cho Langflow..."

    local errors=0

    # 1. Kiểm tra Docker và Docker Compose
    if ! check_docker || ! check_docker_compose; then
        log_error "❌ Docker hoặc Docker Compose không sẵn sàng"
        ((errors++))
    fi

    # 2. Kiểm tra file .env
    if [[ ! -f ".env" ]]; then
        log_error "❌ Không tìm thấy file .env"
        ((errors++))
    else
        # Kiểm tra các biến môi trường cần thiết cho Langflow
        local required_vars=(
            "LANGFLOW_SECRET_KEY"
            "LANGFLOW_JWT_SECRET"
            "LANGFLOW_SUPERUSER_PASSWORD"
            "LANGFLOW_DATABASE_URL"
            "LANGFLOW_DB"
        )

        for var in "${required_vars[@]}"; do
            if ! grep -q "^${var}=" .env; then
                log_warning "⚠️ Biến môi trường '$var' chưa được định nghĩa trong .env"
            fi
        done

        # Kiểm tra format của LANGFLOW_DATABASE_URL
        if grep -q "^LANGFLOW_DATABASE_URL=" .env; then
            local db_url=$(grep "^LANGFLOW_DATABASE_URL=" .env | cut -d'=' -f2-)
            if [[ "$db_url" == *"postgresql://"* ]]; then
                log_success "✅ LANGFLOW_DATABASE_URL format hợp lệ"
            else
                log_warning "⚠️ LANGFLOW_DATABASE_URL không phải PostgreSQL format"
            fi
        fi
    fi

    # 3. Kiểm tra cổng Langflow (cho phép nếu đang được sử dụng bởi Langflow hoặc TIME_WAIT)
    if is_port_in_use "$LANGFLOW_PORT"; then
        # Kiểm tra xem có phải Langflow đang sử dụng port này không
        if is_container_running "langflow" && docker port langflow | grep -q "$LANGFLOW_PORT"; then
            log_success "✅ Cổng $LANGFLOW_PORT đang được sử dụng bởi Langflow (OK)"
        else
            # Kiểm tra xem có phải TIME_WAIT state không
            if netstat -ano | grep "$LANGFLOW_PORT" | grep -q "TIME_WAIT"; then
                log_info "ℹ️ Cổng $LANGFLOW_PORT trong trạng thái TIME_WAIT (sẽ được giải phóng)"
            else
                log_warning "⚠️ Cổng $LANGFLOW_PORT đang được sử dụng bởi service khác"
                if [[ "${1:-false}" != "true" ]]; then
                    ((errors++))
                fi
            fi
        fi
    fi

    # 4. Kiểm tra dung lượng ổ cứng (tối thiểu 1GB cho Langflow)
    local available_space=$(df . | awk 'NR==2 {print $4}')
    local required_space=1048576  # 1GB in KB

    if [[ $available_space -lt $required_space ]]; then
        log_warning "⚠️ Dung lượng ổ cứng có thể không đủ (khuyến nghị ít nhất 1GB)"
    fi

    if [[ $errors -gt 0 ]]; then
        log_error "❌ Tìm thấy $errors lỗi trong quá trình kiểm tra"
        return 1
    fi

    log_success "✅ Điều kiện tiên quyết đã được đáp ứng"
    return 0
}

# Hàm tạo thư mục cần thiết
create_langflow_directories() {
    log_info "📁 Đang tạo thư mục cần thiết cho Langflow..."
    
    for dir in "${LANGFLOW_DIRECTORIES[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            log_debug "Đã tạo thư mục: $dir"
        else
            log_debug "Thư mục đã tồn tại: $dir"
        fi
    done
    
    # Thiết lập quyền truy cập
    chmod -R 755 langflow/ 2>/dev/null || true
    chmod -R 755 shared/ 2>/dev/null || true
    
    log_success "✅ Đã tạo tất cả thư mục cần thiết"
}

# ============================================================================
# FUNCTIONS TRIỂN KHAI
# ============================================================================

# Hàm kiểm tra và chuẩn bị cơ sở dữ liệu PostgreSQL
check_and_prepare_database() {
    log_info "🗄️ Đang kiểm tra cơ sở dữ liệu PostgreSQL cho Langflow..."

    # Kiểm tra PostgreSQL đã chạy chưa
    if ! is_container_running "postgres"; then
        log_error "❌ PostgreSQL chưa chạy. Vui lòng triển khai profile 'basic' trước."
        log_info "💡 Chạy: ./scripts/deploy.sh --profile basic"
        return 1
    fi

    # Chờ PostgreSQL sẵn sàng
    log_info "⏳ Đang kiểm tra PostgreSQL..."
    local max_attempts=10
    local attempt=0

    while [[ $attempt -lt $max_attempts ]]; do
        if docker exec postgres pg_isready -U "${POSTGRES_USER:-nextflow}" >/dev/null 2>&1; then
            log_success "✅ PostgreSQL đã sẵn sàng"
            break
        fi

        ((attempt++))
        log_debug "Thử lần $attempt/$max_attempts..."
        sleep 2
    done

    if [[ $attempt -eq $max_attempts ]]; then
        log_error "❌ PostgreSQL không phản hồi"
        return 1
    fi

    # Tạo database cho Langflow nếu chưa tồn tại
    log_info "🔧 Đang kiểm tra/tạo database cho Langflow..."
    local db_name="${LANGFLOW_DB:-nextflow_langflow}"
    docker exec postgres psql -U "${POSTGRES_USER:-nextflow}" -c "SELECT 1 FROM pg_database WHERE datname = '$db_name';" | grep -q 1 || {
        log_info "📝 Tạo database $db_name..."
        docker exec postgres psql -U "${POSTGRES_USER:-nextflow}" -c "CREATE DATABASE $db_name;"
    }

    log_success "✅ Database $db_name đã sẵn sàng"
    return 0
}

# Hàm kiểm tra Redis cache
check_redis_availability() {
    log_info "🔴 Đang kiểm tra Redis cache cho Langflow..."

    # Kiểm tra Redis đã chạy chưa
    if ! is_container_running "redis"; then
        log_error "❌ Redis chưa chạy. Vui lòng triển khai profile 'basic' trước."
        log_info "💡 Chạy: ./scripts/deploy.sh --profile basic"
        return 1
    fi

    # Kiểm tra Redis hoạt động
    log_info "⏳ Đang kiểm tra Redis..."
    local max_attempts=5
    local attempt=0

    while [[ $attempt -lt $max_attempts ]]; do
        if docker exec redis redis-cli ping >/dev/null 2>&1; then
            log_success "✅ Redis đã sẵn sàng"
            return 0
        fi

        ((attempt++))
        log_debug "Thử lần $attempt/$max_attempts..."
        sleep 1
    done

    log_error "❌ Redis không phản hồi"
    return 1
}

# Hàm triển khai Langflow chính (tối ưu - tránh gián đoạn)
deploy_langflow_main() {
    log_info "🤖 Triển khai Langflow AI Platform..."

    # Kiểm tra Langflow đang chạy để tránh gián đoạn
    if is_container_running "langflow"; then
        log_info "✅ Langflow đang chạy - sẽ apply cấu hình mới mà không dừng"
        log_info "🔄 Cập nhật Langflow container với cấu hình mới..."

        # Sử dụng docker-compose up -d để apply cấu hình mới mà không dừng
        if ! $DOCKER_COMPOSE --profile "$PROFILE_NAME" up -d langflow; then
            log_error "❌ Không thể cập nhật Langflow"
            return 1
        fi

        log_success "✅ Đã apply cấu hình mới cho Langflow"
    else
        log_info "📦 Langflow chưa chạy - sẽ khởi động mới"

        # Khởi động Langflow với profile
        log_info "🚀 Khởi động Langflow container..."
        if ! $DOCKER_COMPOSE --profile "$PROFILE_NAME" up -d langflow; then
            log_error "❌ Không thể khởi động Langflow"
            return 1
        fi
    fi

    # Chờ Langflow sẵn sàng với timeout tối ưu
    log_info "⏳ Chờ Langflow khởi động (có thể mất 1-2 phút)..."
    local max_attempts=40  # Giảm từ 60 xuống 40 (2 phút)
    local attempt=0

    while [[ $attempt -lt $max_attempts ]]; do
        # Kiểm tra container đang chạy
        if ! is_container_running "langflow"; then
            log_error "❌ Langflow container đã dừng bất ngờ"
            return 1
        fi

        # Kiểm tra web interface (thay vì /health endpoint)
        if curl -s http://localhost:$LANGFLOW_PORT >/dev/null 2>&1; then
            log_success "✅ Langflow đã sẵn sàng"
            return 0
        fi

        ((attempt++))
        log_debug "Thử lần $attempt/$max_attempts..."
        sleep 3
    done

    log_warning "⚠️ Langflow container đã khởi động nhưng có thể chưa hoàn toàn sẵn sàng"
    log_info "💡 Kiểm tra logs: docker logs langflow"
    return 0
}

# Hàm triển khai Cloudflare Tunnel cho Langflow
deploy_langflow_tunnel() {
    log_info "🌐 Đang triển khai Cloudflare Tunnel cho Langflow..."

    # Kiểm tra Cloudflare tunnel đang chạy
    if is_container_running "cloudflare-tunnel"; then
        log_info "✅ Cloudflare tunnel đang chạy - sẽ apply cấu hình mới"
        log_info "🔄 Restart cloudflare-tunnel để áp dụng cấu hình mới..."
        docker restart cloudflare-tunnel
    else
        log_info "📦 Cloudflare tunnel chưa chạy - sẽ khởi động"

        # Khởi động Cloudflare Tunnel chính
        if ! $DOCKER_COMPOSE up -d cloudflare-tunnel; then
            log_warning "⚠️ Không thể khởi động Cloudflare Tunnel (có thể do thiếu credentials)"
            log_info "💡 Để cấu hình Cloudflare tunnel:"
            log_info "  1. Kiểm tra credentials trong cloudflared/credentials/"
            log_info "  2. Cập nhật config trong cloudflared/config/cloudflared-config.yml"
            return 0  # Không phải lỗi nghiêm trọng
        fi
    fi

    log_success "✅ Cloudflare Tunnel đã được triển khai"
    return 0
}

# ============================================================================
# FUNCTIONS KIỂM TRA TRẠNG THÁI
# ============================================================================

# Hàm kiểm tra trạng thái Langflow (tối ưu)
check_langflow_status() {
    log_info "📊 Kiểm tra trạng thái Langflow và dependencies..."

    local all_healthy=true

    # 1. Kiểm tra Langflow service chính
    if is_container_running "langflow"; then
        log_success "✅ Langflow container: Đang chạy"

        # Kiểm tra web interface
        if curl -s http://localhost:$LANGFLOW_PORT >/dev/null 2>&1; then
            log_success "✅ Langflow Web Interface: Truy cập OK"
        else
            log_warning "⚠️ Langflow Web Interface: Chưa sẵn sàng (đang khởi động)"
        fi
    else
        log_error "❌ Langflow container: Không chạy"
        all_healthy=false
    fi

    # 2. Kiểm tra Cloudflare Tunnel (tùy chọn)
    for service in "${LANGFLOW_OPTIONAL_SERVICES[@]}"; do
        if is_container_running "$service"; then
            log_success "✅ $service: Đang chạy"
        else
            log_info "ℹ️ $service: Không chạy (tùy chọn)"
        fi
    done

    # 3. Kiểm tra dependencies (từ profile basic)
    for service in "${LANGFLOW_DEPENDENCIES[@]}"; do
        if is_container_running "$service"; then
            log_success "✅ $service (dependency): Đang chạy"

            # Kiểm tra kết nối cụ thể
            case "$service" in
                "postgres")
                    if docker exec postgres pg_isready -U "${POSTGRES_USER:-nextflow}" >/dev/null 2>&1; then
                        log_success "✅ PostgreSQL: Kết nối OK"

                        # Kiểm tra database Langflow
                        local db_name="${LANGFLOW_DB:-nextflow_langflow}"
                        if docker exec postgres psql -U "${POSTGRES_USER:-nextflow}" -d "$db_name" -c "\dt" 2>/dev/null | grep -q "user\|flow"; then
                            log_success "✅ Database $db_name: Tables đã được tạo"
                        else
                            log_info "ℹ️ Database $db_name: Chưa có tables (sẽ được tạo khi Langflow khởi động)"
                        fi
                    else
                        log_error "❌ PostgreSQL: Không thể kết nối"
                        all_healthy=false
                    fi
                    ;;
                "redis")
                    if docker exec redis redis-cli ping >/dev/null 2>&1; then
                        log_success "✅ Redis: Kết nối OK"
                    else
                        log_error "❌ Redis: Không thể kết nối"
                        all_healthy=false
                    fi
                    ;;
            esac
        else
            log_error "❌ $service (dependency): Không chạy - Cần triển khai profile 'basic' trước"
            all_healthy=false
        fi
    done

    # Kết quả cuối cùng
    if [[ "$all_healthy" == "true" ]]; then
        log_success "🎉 Langflow và tất cả dependencies hoạt động bình thường!"
        return 0
    else
        log_error "❌ Một số services có vấn đề"
        return 1
    fi
}

# Hàm hiển thị thông tin truy cập
show_langflow_access_info() {
    log_info "🌐 Thông tin truy cập Langflow:"
    echo
    echo "📱 Langflow Web Interface:"
    echo "   🔗 Local: http://localhost:${LANGFLOW_PORT:-7860}"
    echo "   👤 Username: admin"
    echo "   🔑 Password: ${LANGFLOW_SUPERUSER_PASSWORD:-nextflow@2025}"
    echo
    echo "🗄️ Cơ sở dữ liệu PostgreSQL:"
    echo "   🏠 Host: localhost:5432"
    echo "   👤 User: ${POSTGRES_USER:-nextflow}"
    echo "   🗃️ Database: ${LANGFLOW_DB:-nextflow_langflow}"
    echo
    echo "🔴 Redis Cache:"
    echo "   🏠 Host: localhost:6379"
    echo "   🗃️ Database: 1 (cho Langflow)"
    echo
    echo "📁 Thư mục dữ liệu:"
    echo "   📂 Flows: ./langflow/flows/"
    echo "   🧩 Components: ./langflow/components/"
    echo "   📤 Shared: ./shared/"
    echo
}

# ============================================================================
# FUNCTION CHÍNH - TRIỂN KHAI LANGFLOW
# ============================================================================

# Hàm chính triển khai Langflow (tối ưu - chỉ cài Langflow)
deploy_langflow() {
    local force_deploy="${1:-false}"

    show_banner "🤖 TRIỂN KHAI LANGFLOW AI PLATFORM"

    log_info "🚀 Bắt đầu triển khai Langflow (chỉ Langflow, không cài dependencies)..."

    # 1. Kiểm tra điều kiện tiên quyết
    if ! check_langflow_prerequisites "$force_deploy"; then
        if [[ "$force_deploy" != "true" ]]; then
            log_error "❌ Điều kiện tiên quyết không được đáp ứng"
            return 1
        else
            log_warning "⚠️ Bỏ qua lỗi điều kiện tiên quyết (force deploy)"
        fi
    fi

    # 2. Tạo thư mục cần thiết cho Langflow
    create_langflow_directories

    # 3. Kiểm tra dependencies thông minh (KHÔNG cài đặt, chỉ kiểm tra)
    log_info "🔍 Kiểm tra dependencies từ profile basic..."

    local missing_deps=()

    # Kiểm tra PostgreSQL
    if ! is_container_running "postgres"; then
        missing_deps+=("PostgreSQL")
        log_warning "⚠️ PostgreSQL chưa chạy"
    else
        log_success "✅ PostgreSQL đang chạy"
        # Vẫn kiểm tra và chuẩn bị database
        if ! check_and_prepare_database; then
            log_warning "⚠️ PostgreSQL có vấn đề kết nối"
        fi
    fi

    # Kiểm tra Redis
    if ! is_container_running "redis"; then
        missing_deps+=("Redis")
        log_warning "⚠️ Redis chưa chạy"
    else
        log_success "✅ Redis đang chạy"
        # Vẫn kiểm tra kết nối
        if ! check_redis_availability; then
            log_warning "⚠️ Redis có vấn đề kết nối"
        fi
    fi

    # Nếu có dependencies thiếu, đề xuất giải pháp
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "❌ Dependencies thiếu: ${missing_deps[*]}"
        log_info "💡 Giải pháp:"
        log_info "   1. Chạy profile 'basic' trước: ./scripts/deploy.sh --profile basic"
        log_info "   2. Hoặc chạy force deploy: ./scripts/deploy.sh --profile langflow --force"

        if [[ "$force_deploy" != "true" ]]; then
            return 1
        else
            log_warning "⚠️ Force deploy - bỏ qua dependencies thiếu"
        fi
    fi

    # 4. Triển khai chỉ Langflow
    log_info "📦 Triển khai Langflow (không cài PostgreSQL/Redis)..."

    if ! deploy_langflow_main; then
        log_error "❌ Triển khai Langflow thất bại"
        return 1
    fi

    # 5. Triển khai Cloudflare Tunnel (tùy chọn)
    deploy_langflow_tunnel

    # 6. Kiểm tra trạng thái cuối cùng
    log_info "🔍 Kiểm tra trạng thái triển khai..."
    sleep 5  # Chờ services ổn định

    if check_langflow_status; then
        log_success "🎉 Triển khai Langflow hoàn tất thành công!"
        show_langflow_access_info
        return 0
    else
        log_error "❌ Triển khai có một số vấn đề"
        log_info "💡 Kiểm tra logs để biết thêm chi tiết:"
        log_info "   docker logs langflow"
        return 1
    fi
}

# ============================================================================
# EXPORT FUNCTIONS
# ============================================================================

# Export các functions để có thể sử dụng từ bên ngoài
export -f deploy_langflow
export -f check_langflow_status
export -f show_langflow_access_info
