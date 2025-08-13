#!/bin/bash
# ============================================================================
# NEXTFLOW GITLAB ENTRYPOINT
# ============================================================================
# Mô tả: Entry point tùy chỉnh cho GitLab NextFlow CRM-AI
# Chức năng: Kiểm tra dependencies và khởi tạo GitLab
# ============================================================================

set -e

# Logging functions (đơn giản)
log_info() {
    echo "[INFO] $1"
}

log_success() {
    echo "[SUCCESS] $1"
}

log_warning() {
    echo "[WARNING] $1"
}

log_error() {
    echo "[ERROR] $1"
}

# Kiểm tra PostgreSQL
check_database() {
    log_info "Kiểm tra PostgreSQL..."

    local max_attempts=30
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        if pg_isready -h "${GITLAB_DB_HOST:-postgres}" -p "${GITLAB_DB_PORT:-5432}" -U "${GITLAB_DB_USER:-nextflow}" >/dev/null 2>&1; then
            log_success "PostgreSQL sẵn sàng!"
            return 0
        fi

        log_warning "Đợi PostgreSQL... ($attempt/$max_attempts)"
        sleep 5
        attempt=$((attempt + 1))
    done

    log_error "PostgreSQL không sẵn sàng sau $max_attempts lần thử!"
    return 1
}

# Kiểm tra Redis
check_redis() {
    log_info "Kiểm tra Redis..."

    local max_attempts=30
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        if redis-cli -h "${GITLAB_REDIS_HOST:-redis}" -p "${GITLAB_REDIS_PORT:-6379}" ping >/dev/null 2>&1; then
            log_success "Redis sẵn sàng!"
            return 0
        fi

        log_warning "Đợi Redis... ($attempt/$max_attempts)"
        sleep 5
        attempt=$((attempt + 1))
    done

    log_error "Redis không sẵn sàng sau $max_attempts lần thử!"
    return 1
}

# Thiết lập cấu hình cơ bản
setup_gitlab_config() {
    log_info "Thiết lập cấu hình GitLab..."

    # Copy template nếu chưa có
    if [ ! -f "/etc/gitlab/gitlab.rb" ] && [ -f "/opt/nextflow/config/gitlab.rb.template" ]; then
        log_info "Tạo gitlab.rb từ template..."
        cp /opt/nextflow/config/gitlab.rb.template /etc/gitlab/gitlab.rb
        log_success "Đã tạo cấu hình GitLab!"
    fi
}

# Thiết lập quyền truy cập
setup_permissions() {
    log_info "Thiết lập quyền truy cập..."

    # Đảm bảo quyền cho thư mục chính
    chown -R git:git /var/opt/gitlab /var/log/gitlab 2>/dev/null || true
    chmod -R 755 /var/opt/gitlab /var/log/gitlab 2>/dev/null || true

    log_success "Đã thiết lập quyền truy cập!"
}

# Chạy NextFlow init script nếu có
run_nextflow_init() {
    if [ -f "/opt/nextflow/scripts/gitlab-init.sh" ]; then
        log_info "Chạy NextFlow init script..."
        /opt/nextflow/scripts/gitlab-init.sh &
    fi
}

# Main function
main() {
    log_info "🚀 Khởi động GitLab NextFlow CRM-AI..."

    # Kiểm tra dependencies
    check_database || exit 1
    check_redis || exit 1

    # Thiết lập cấu hình
    setup_gitlab_config
    setup_permissions

    # Chạy NextFlow init (background)
    run_nextflow_init

    log_success "🎉 GitLab NextFlow sẵn sàng khởi động!"
    log_info "📝 Truy cập: ${GITLAB_EXTERNAL_URL:-http://localhost:8088}"
    log_info "👤 Username: root | 🔑 Password: ${GITLAB_ROOT_PASSWORD:-Nex!tFlow@2025!}"

    # Chuyển control cho GitLab
    exec "$@"
}

# Chạy main function
main "$@"
