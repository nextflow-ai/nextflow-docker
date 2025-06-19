#!/bin/bash

# ============================================================================
# NEXTFLOW DOCKER - SCRIPT KHỞI TẠO DATABASES
# ============================================================================
# Tác giả: NextFlow Development Team
# Mục đích: Tự động tạo các databases cần thiết trong PostgreSQL
# Sử dụng: ./scripts/init-databases.sh
# ============================================================================

set -euo pipefail

# Import thư viện logging
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils/logging.sh"

# ============================================================================
# CẤU HÌNH
# ============================================================================

# Thông tin kết nối PostgreSQL
POSTGRES_CONTAINER="postgres"
POSTGRES_USER="nextflow"
POSTGRES_HOST="localhost"
POSTGRES_PORT="5432"

# Danh sách databases cần tạo
DATABASES=(
    "nextflow_n8n:Database cho n8n automation platform"
    "nextflow_flowise:Database cho Flowise AI chatbot"
    "nextflow_langflow:Database cho Langflow AI workflows"
    "nextflow_monitoring:Database cho monitoring và metrics"
    "nextflow_backup:Database cho backup metadata"
)

# ============================================================================
# FUNCTIONS
# ============================================================================

# Hàm kiểm tra PostgreSQL container có đang chạy không
check_postgres_container() {
    if ! docker ps --format "{{.Names}}" | grep -q "^${POSTGRES_CONTAINER}$"; then
        log_error "Container PostgreSQL '$POSTGRES_CONTAINER' không đang chạy!"
        log_info "Vui lòng khởi động PostgreSQL trước khi chạy script này:"
        log_info "  docker-compose up -d postgres"
        exit 1
    fi
    
    log_success "Container PostgreSQL đang chạy"
}

# Hàm kiểm tra kết nối PostgreSQL
check_postgres_connection() {
    log_info "Kiểm tra kết nối PostgreSQL..."
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if docker exec "$POSTGRES_CONTAINER" pg_isready -U "$POSTGRES_USER" -d postgres >/dev/null 2>&1; then
            log_success "Kết nối PostgreSQL thành công!"
            return 0
        fi
        
        log_info "Lần thử $attempt/$max_attempts - Đợi PostgreSQL sẵn sàng..."
        sleep 2
        ((attempt++))
    done
    
    log_error "Không thể kết nối PostgreSQL sau $max_attempts lần thử!"
    exit 1
}

# Hàm kiểm tra database có tồn tại không
database_exists() {
    local db_name="$1"
    
    local result=$(docker exec "$POSTGRES_CONTAINER" psql -U "$POSTGRES_USER" -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$db_name';" 2>/dev/null || echo "")
    
    if [[ "$result" == "1" ]]; then
        return 0  # Database tồn tại
    else
        return 1  # Database không tồn tại
    fi
}

# Hàm tạo database
create_database() {
    local db_name="$1"
    local description="$2"
    
    log_info "Đang tạo database: $db_name"
    log_debug "Mô tả: $description"
    
    if database_exists "$db_name"; then
        log_warning "Database '$db_name' đã tồn tại, bỏ qua..."
        return 0
    fi
    
    # Tạo database
    if docker exec "$POSTGRES_CONTAINER" psql -U "$POSTGRES_USER" -d postgres -c "CREATE DATABASE $db_name OWNER $POSTGRES_USER;" >/dev/null 2>&1; then
        log_success "✅ Đã tạo database: $db_name"
        
        # Thêm comment cho database
        docker exec "$POSTGRES_CONTAINER" psql -U "$POSTGRES_USER" -d postgres -c "COMMENT ON DATABASE $db_name IS '$description';" >/dev/null 2>&1 || true
        
        return 0
    else
        log_error "❌ Lỗi khi tạo database: $db_name"
        return 1
    fi
}

# Hàm hiển thị danh sách databases
show_databases() {
    log_info "📋 Danh sách databases hiện tại:"
    echo
    
    docker exec "$POSTGRES_CONTAINER" psql -U "$POSTGRES_USER" -d postgres -c "
        SELECT 
            datname as \"Database\",
            pg_size_pretty(pg_database_size(datname)) as \"Size\",
            obj_description(oid, 'pg_database') as \"Description\"
        FROM pg_database 
        WHERE datname NOT IN ('template0', 'template1')
        ORDER BY datname;
    " 2>/dev/null || {
        log_warning "Không thể hiển thị thông tin chi tiết, hiển thị danh sách cơ bản:"
        docker exec "$POSTGRES_CONTAINER" psql -U "$POSTGRES_USER" -d postgres -c "\l"
    }
}

# Hàm tạo user và phân quyền
setup_database_permissions() {
    local db_name="$1"
    
    log_debug "Thiết lập quyền cho database: $db_name"
    
    # Đảm bảo user nextflow có đầy đủ quyền
    docker exec "$POSTGRES_CONTAINER" psql -U "$POSTGRES_USER" -d "$db_name" -c "
        GRANT ALL PRIVILEGES ON DATABASE $db_name TO $POSTGRES_USER;
        GRANT ALL PRIVILEGES ON SCHEMA public TO $POSTGRES_USER;
        GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO $POSTGRES_USER;
        GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO $POSTGRES_USER;
        GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO $POSTGRES_USER;
    " >/dev/null 2>&1 || true
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    show_banner "🗄️ KHỞI TẠO DATABASES POSTGRESQL"
    
    # Kiểm tra container PostgreSQL
    check_postgres_container
    
    # Kiểm tra kết nối
    check_postgres_connection
    
    # Hiển thị databases hiện tại
    show_databases
    
    echo
    log_info "🚀 Bắt đầu tạo databases cần thiết..."
    
    local created_count=0
    local failed_count=0
    
    # Tạo từng database
    for db_info in "${DATABASES[@]}"; do
        IFS=':' read -r db_name description <<< "$db_info"
        
        if create_database "$db_name" "$description"; then
            setup_database_permissions "$db_name"
            ((created_count++))
        else
            ((failed_count++))
        fi
    done
    
    echo
    log_info "📊 Tổng kết:"
    log_info "  ✅ Databases đã tạo: $created_count"
    if [[ $failed_count -gt 0 ]]; then
        log_warning "  ❌ Databases thất bại: $failed_count"
    fi
    
    echo
    log_info "📋 Danh sách databases sau khi tạo:"
    show_databases
    
    echo
    log_success "🎉 Hoàn tất khởi tạo databases!"
    
    # Hướng dẫn sử dụng
    echo
    log_info "💡 Hướng dẫn tiếp theo:"
    log_info "  • Khởi động lại các services để áp dụng databases mới:"
    log_info "    docker-compose restart n8n flowise"
    log_info "  • Kiểm tra logs để đảm bảo kết nối thành công:"
    log_info "    docker logs n8n"
    log_info "    docker logs flowise"
}

# Chạy script
main "$@"
