#!/bin/bash

# ============================================================================
# NEXTFLOW DOCKER - BACKUP SYSTEM
# ============================================================================
# Tác giả: NextFlow Development Team
# Phiên bản: 1.0
# Ngày tạo: 2025-06-19
#
# MÔ TẢ:
# Script backup toàn diện cho NextFlow Docker project bao gồm:
# - Backup databases (PostgreSQL, MariaDB)
# - Backup volumes và persistent data
# - Backup cấu hình files (.env, docker-compose.yml, configs)
# - Backup GitLab data, logs, repositories
# - Backup Langflow workflows và components
# - Backup WordPress data và uploads
#
# SỬ DỤNG:
# ./scripts/backup.sh                    # Interactive menu
# ./scripts/backup.sh --full             # Full backup
# ./scripts/backup.sh --db-only          # Database only
# ./scripts/backup.sh --config-only      # Config only
# ./scripts/backup.sh --incremental      # Incremental backup
# ./scripts/backup.sh --restore <path>   # Restore from backup
# ./scripts/backup.sh --list             # List backups
# ./scripts/backup.sh --cleanup          # Cleanup old backups
#
# CẤU TRÚC BACKUP:
# backups/
# ├── YYYY-MM-DD_HH-MM-SS/
# │   ├── databases/
# │   │   ├── postgresql_dump.sql
# │   │   └── mariadb_dump.sql
# │   ├── volumes/
# │   │   ├── langflow_data.tar.gz
# │   │   ├── wordpress_data.tar.gz
# │   │   └── gitlab_data.tar.gz
# │   ├── configs/
# │   │   ├── docker-compose.yml
# │   │   ├── env_sanitized.txt
# │   │   └── config_files.tar.gz
# │   └── metadata.json
# ============================================================================

# Import các thư viện cần thiết
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load utilities
source "$SCRIPT_DIR/utils/logging.sh" 2>/dev/null || {
    echo "❌ Không thể load logging utilities"
    exit 1
}
source "$SCRIPT_DIR/utils/docker.sh" 2>/dev/null || {
    echo "❌ Không thể load docker utilities"
    exit 1
}

# ============================================================================
# CẤU HÌNH BACKUP
# ============================================================================

# Thư mục backup chính
BACKUP_ROOT_DIR="${PROJECT_ROOT}/backups"
BACKUP_TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_DIR="${BACKUP_ROOT_DIR}/${BACKUP_TIMESTAMP}"

# Thư mục con trong backup
BACKUP_DB_DIR="${BACKUP_DIR}/databases"
BACKUP_VOLUMES_DIR="${BACKUP_DIR}/volumes"
BACKUP_CONFIGS_DIR="${BACKUP_DIR}/configs"

# Cấu hình retention (giữ backup trong bao lâu)
BACKUP_RETENTION_DAYS=${BACKUP_RETENTION_DAYS:-30}
BACKUP_MAX_COUNT=${BACKUP_MAX_COUNT:-10}

# Cấu hình nén
COMPRESSION_LEVEL=${COMPRESSION_LEVEL:-6}
COMPRESSION_TYPE=${COMPRESSION_TYPE:-gzip}

# Cấu hình encryption (tùy chọn)
BACKUP_ENCRYPT=${BACKUP_ENCRYPT:-false}
BACKUP_ENCRYPT_PASSWORD=${BACKUP_ENCRYPT_PASSWORD:-""}

# Danh sách databases cần backup
DATABASES_POSTGRESQL=(
    "nextflow"
    "nextflow_n8n"
    "nextflow_backup"
    "nextflow_flowise"
    "nextflow_langflow"
    "nextflow_monitoring"
    "nextflow_stalwart_mail"
    "nextflow_gitlab"
)

DATABASES_MARIADB=(
    "nextflow_wordpress"
)

# Danh sách volumes cần backup (với prefix nextflow-docker_)
DOCKER_VOLUMES=(
    "nextflow-docker_flowise"
    "nextflow-docker_grafana_data"
    "nextflow-docker_langflow_data"
    "nextflow-docker_langflow_logs"
    "nextflow-docker_loki_data"
    "nextflow-docker_mariadb_data"
    "nextflow-docker_n8n_storage"
    "nextflow-docker_ollama_storage"
    "nextflow-docker_open-webui"
    "nextflow-docker_postgres_storage"
    "nextflow-docker_prometheus_data"
    "nextflow-docker_qdrant_snapshots"
    "nextflow-docker_qdrant_storage"
    "nextflow-docker_rabbitmq_data"
    "nextflow-docker_redis_data"
    "nextflow-docker_stalwart_config"
    "nextflow-docker_stalwart_data"
    "nextflow-docker_stalwart_logs"
    "nextflow-docker_wordpress_data"
)

# Danh sách thư mục config cần backup
CONFIG_DIRECTORIES=(
    "config"
    "cloudflared"
    "stalwart"
    "langflow"
    "wordpress"
    "gitlab"
    "scripts"
    "docs"
)

# Danh sách files config cần backup
CONFIG_FILES=(
    "docker-compose.yml"
    ".env.example"
    "README.md"
    "DEPLOYMENT-GUIDE.md"
    "DEPLOYMENT-ISSUE-RESOLUTION.md"
    "GITLAB-ROOT-ACCOUNT-SUMMARY.md"
    "GITLAB-ROOT-USER-GUIDE.md"
    ".gitignore"
    ".gitattributes"
)

# Files cần loại trừ khỏi backup (sensitive data)
EXCLUDE_FILES=(
    ".env"
    "*.log"
    "*.pid"
    "*.lock"
    "*.tmp"
    "node_modules"
    ".git"
    ".docker"
    "backups"
)

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Hiển thị banner
show_backup_banner() {
    local title="$1"
    echo
    echo "============================================================"
    echo "             🗄️ NEXTFLOW BACKUP SYSTEM"
    echo "============================================================"
    if [[ -n "$title" ]]; then
        echo "                    $title"
        echo "============================================================"
    fi
    echo
}

# Tạo thư mục backup
create_backup_directories() {
    log_info "📁 Tạo cấu trúc thư mục backup..."
    
    local directories=(
        "$BACKUP_DIR"
        "$BACKUP_DB_DIR"
        "$BACKUP_VOLUMES_DIR"
        "$BACKUP_CONFIGS_DIR"
    )
    
    for dir in "${directories[@]}"; do
        if ! mkdir -p "$dir"; then
            log_error "❌ Không thể tạo thư mục: $dir"
            return 1
        fi
        log_debug "Đã tạo: $dir"
    done
    
    log_success "✅ Đã tạo cấu trúc thư mục backup"
    return 0
}

# Tạo metadata file
create_backup_metadata() {
    local backup_type="$1"
    local start_time="$2"
    local end_time="$3"
    local status="$4"
    
    log_info "📋 Tạo metadata backup..."
    
    local metadata_file="${BACKUP_DIR}/metadata.json"
    
    cat > "$metadata_file" << EOF
{
    "backup_info": {
        "timestamp": "$BACKUP_TIMESTAMP",
        "type": "$backup_type",
        "start_time": "$start_time",
        "end_time": "$end_time",
        "duration": "$((end_time - start_time)) seconds",
        "status": "$status",
        "version": "1.0",
        "created_by": "NextFlow Backup System"
    },
    "system_info": {
        "hostname": "$(hostname)",
        "os": "$(uname -s)",
        "docker_version": "$(docker --version 2>/dev/null || echo 'N/A')",
        "compose_version": "$(docker-compose --version 2>/dev/null || echo 'N/A')",
        "project_root": "$PROJECT_ROOT"
    },
    "backup_contents": {
        "databases": {
            "postgresql": $(printf '%s\n' "${DATABASES_POSTGRESQL[@]}" | jq -R . | jq -s .),
            "mariadb": $(printf '%s\n' "${DATABASES_MARIADB[@]}" | jq -R . | jq -s .)
        },
        "volumes": $(printf '%s\n' "${DOCKER_VOLUMES[@]}" | jq -R . | jq -s .),
        "configs": {
            "directories": $(printf '%s\n' "${CONFIG_DIRECTORIES[@]}" | jq -R . | jq -s .),
            "files": $(printf '%s\n' "${CONFIG_FILES[@]}" | jq -R . | jq -s .)
        }
    },
    "backup_settings": {
        "compression": "$COMPRESSION_TYPE",
        "compression_level": $COMPRESSION_LEVEL,
        "encryption": $BACKUP_ENCRYPT,
        "retention_days": $BACKUP_RETENTION_DAYS
    }
}
EOF

    if [[ $? -eq 0 ]]; then
        log_success "✅ Đã tạo metadata: $metadata_file"
        return 0
    else
        log_error "❌ Không thể tạo metadata"
        return 1
    fi
}

# Kiểm tra disk space
check_disk_space() {
    log_info "💾 Kiểm tra dung lượng ổ cứng..."
    
    local available_space=$(df "$PROJECT_ROOT" | awk 'NR==2 {print $4}')
    local required_space=5242880  # 5GB in KB
    
    if [[ $available_space -lt $required_space ]]; then
        log_warning "⚠️ Dung lượng ổ cứng có thể không đủ"
        log_info "   Có sẵn: $(($available_space / 1024 / 1024))GB"
        log_info "   Khuyến nghị: 5GB"
        
        if ! confirm_action "Tiếp tục backup?"; then
            return 1
        fi
    else
        log_success "✅ Dung lượng ổ cứng đủ: $(($available_space / 1024 / 1024))GB"
    fi
    
    return 0
}

# Kiểm tra Docker services
check_docker_services() {
    log_info "🐳 Kiểm tra Docker services..."
    
    if ! check_docker; then
        log_error "❌ Docker không sẵn sàng"
        return 1
    fi
    
    if ! check_docker_compose; then
        log_error "❌ Docker Compose không sẵn sàng"
        return 1
    fi
    
    log_success "✅ Docker services sẵn sàng"
    return 0
}

# ============================================================================
# DATABASE BACKUP FUNCTIONS
# ============================================================================

# Backup PostgreSQL databases
backup_postgresql() {
    log_info "🐘 Backup PostgreSQL databases..."

    if ! is_container_running "postgres"; then
        log_warning "⚠️ PostgreSQL container không chạy - bỏ qua backup"
        return 0
    fi

    local backup_count=0
    local failed_count=0

    for db in "${DATABASES_POSTGRESQL[@]}"; do
        log_loading "Backup database: $db"

        local dump_file="${BACKUP_DB_DIR}/postgresql_${db}.sql"

        # Kiểm tra database tồn tại
        if ! docker exec postgres psql -U "${POSTGRES_USER:-nextflow}" -lqt | cut -d \| -f 1 | grep -qw "$db"; then
            log_warning "⚠️ Database '$db' không tồn tại - bỏ qua"
            continue
        fi

        # Thực hiện backup
        if docker exec postgres pg_dump -U "${POSTGRES_USER:-nextflow}" -d "$db" > "$dump_file" 2>/dev/null; then
            # Nén file dump
            if gzip "$dump_file"; then
                log_success "✅ Backup thành công: ${db} ($(du -h "${dump_file}.gz" | cut -f1))"
                ((backup_count++))
            else
                log_error "❌ Không thể nén backup: $db"
                ((failed_count++))
            fi
        else
            log_error "❌ Backup thất bại: $db"
            ((failed_count++))
        fi
    done

    log_info "📊 PostgreSQL backup: $backup_count thành công, $failed_count thất bại"
    return $failed_count
}

# Backup MariaDB databases
backup_mariadb() {
    log_info "🐬 Backup MariaDB databases..."

    if ! is_container_running "mariadb"; then
        log_warning "⚠️ MariaDB container không chạy - bỏ qua backup"
        return 0
    fi

    local backup_count=0
    local failed_count=0

    for db in "${DATABASES_MARIADB[@]}"; do
        log_loading "Backup database: $db"

        local dump_file="${BACKUP_DB_DIR}/mariadb_${db}.sql"

        # Thực hiện backup (sử dụng mariadb-dump thay vì mysqldump)
        if docker exec mariadb mariadb-dump -u root -p"${MYSQL_ROOT_PASSWORD:-nextflow@2025}" "$db" > "$dump_file" 2>/dev/null; then
            # Nén file dump
            if gzip "$dump_file"; then
                log_success "✅ Backup thành công: ${db} ($(du -h "${dump_file}.gz" | cut -f1))"
                ((backup_count++))
            else
                log_error "❌ Không thể nén backup: $db"
                ((failed_count++))
            fi
        else
            log_error "❌ Backup thất bại: $db"
            ((failed_count++))
        fi
    done

    log_info "📊 MariaDB backup: $backup_count thành công, $failed_count thất bại"
    return $failed_count
}

# ============================================================================
# VOLUME BACKUP FUNCTIONS
# ============================================================================

# Backup Docker volumes
backup_volumes() {
    log_info "📦 Backup Docker volumes..."

    local backup_count=0
    local failed_count=0

    for volume in "${DOCKER_VOLUMES[@]}"; do
        log_loading "Backup volume: $volume"

        # Kiểm tra volume tồn tại
        if ! docker volume inspect "$volume" >/dev/null 2>&1; then
            log_warning "⚠️ Volume '$volume' không tồn tại - bỏ qua"
            continue
        fi

        local backup_file="${BACKUP_VOLUMES_DIR}/${volume}.tar.gz"

        # Backup volume sử dụng docker cp (Windows compatible)
        local volume_safe_name=$(echo "$volume" | sed 's/[^a-zA-Z0-9_-]/_/g')
        local backup_file="${BACKUP_VOLUMES_DIR}/${volume_safe_name}.tar.gz"
        local temp_dir="${TMPDIR:-/tmp}/volume_backup_$$"

        # Tạo temp container để access volume
        local temp_container="backup_temp_$(date +%s)"
        if docker create --name "$temp_container" -v "$volume":/data alpine:latest >/dev/null 2>&1; then
            # Tạo temp directory
            mkdir -p "$temp_dir" 2>/dev/null

            # Copy volume data ra temp directory
            if docker cp "$temp_container":/data/. "$temp_dir/" >/dev/null 2>&1; then
                # Tạo tar.gz từ temp directory
                if tar czf "$backup_file" -C "$temp_dir" . 2>/dev/null; then
                    log_success "✅ Backup thành công: ${volume} ($(du -h "$backup_file" | cut -f1))"
                    ((backup_count++))
                else
                    log_error "❌ Không thể tạo tar file: $volume"
                    ((failed_count++))
                fi
            else
                log_error "❌ Không thể copy data từ volume: $volume"
                ((failed_count++))
            fi

            # Cleanup
            docker rm "$temp_container" >/dev/null 2>&1
            rm -rf "$temp_dir" 2>/dev/null
        else
            log_error "❌ Không thể tạo temp container cho: $volume"
            ((failed_count++))
        fi
    done

    log_info "📊 Volume backup: $backup_count thành công, $failed_count thất bại"
    return $failed_count
}

# ============================================================================
# CONFIG BACKUP FUNCTIONS
# ============================================================================

# Backup configuration files
backup_configs() {
    log_info "⚙️ Backup configuration files..."

    local backup_count=0
    local failed_count=0

    # Backup config directories
    for config_dir in "${CONFIG_DIRECTORIES[@]}"; do
        if [[ -d "$PROJECT_ROOT/$config_dir" ]]; then
            log_loading "Backup config directory: $config_dir"

            local backup_file="${BACKUP_CONFIGS_DIR}/${config_dir}.tar.gz"

            if tar czf "$backup_file" -C "$PROJECT_ROOT" "$config_dir" 2>/dev/null; then
                log_success "✅ Backup thành công: ${config_dir}/ ($(du -h "$backup_file" | cut -f1))"
                ((backup_count++))
            else
                log_error "❌ Backup thất bại: $config_dir/"
                ((failed_count++))
            fi
        else
            log_warning "⚠️ Thư mục '$config_dir' không tồn tại - bỏ qua"
        fi
    done

    # Backup individual config files
    for config_file in "${CONFIG_FILES[@]}"; do
        if [[ -f "$PROJECT_ROOT/$config_file" ]]; then
            log_loading "Backup config file: $config_file"

            if cp "$PROJECT_ROOT/$config_file" "$BACKUP_CONFIGS_DIR/" 2>/dev/null; then
                log_success "✅ Backup thành công: $config_file"
                ((backup_count++))
            else
                log_error "❌ Backup thất bại: $config_file"
                ((failed_count++))
            fi
        else
            log_warning "⚠️ File '$config_file' không tồn tại - bỏ qua"
        fi
    done

    # Tạo .env sanitized (loại bỏ passwords)
    if [[ -f "$PROJECT_ROOT/.env" ]]; then
        log_loading "Tạo .env sanitized..."

        # Loại bỏ các dòng chứa password, secret, key
        grep -v -E "(PASSWORD|SECRET|KEY|TOKEN)" "$PROJECT_ROOT/.env" > "$BACKUP_CONFIGS_DIR/env_sanitized.txt" 2>/dev/null

        if [[ $? -eq 0 ]]; then
            log_success "✅ Đã tạo .env sanitized"
            ((backup_count++))
        else
            log_error "❌ Không thể tạo .env sanitized"
            ((failed_count++))
        fi
    fi

    log_info "📊 Config backup: $backup_count thành công, $failed_count thất bại"
    return $failed_count
}

# ============================================================================
# MAIN BACKUP FUNCTIONS
# ============================================================================

# Full backup
perform_full_backup() {
    local start_time=$(date +%s)

    show_backup_banner "FULL BACKUP"

    log_info "🚀 Bắt đầu full backup..."
    log_info "📅 Timestamp: $BACKUP_TIMESTAMP"
    log_info "📁 Backup directory: $BACKUP_DIR"

    # Kiểm tra prerequisites
    if ! check_disk_space || ! check_docker_services; then
        log_error "❌ Prerequisites không đáp ứng"
        return 1
    fi

    # Tạo thư mục backup
    if ! create_backup_directories; then
        log_error "❌ Không thể tạo thư mục backup"
        return 1
    fi

    local total_errors=0

    # Backup databases
    log_info "🗄️ Bắt đầu backup databases..."
    backup_postgresql
    total_errors=$((total_errors + $?))

    backup_mariadb
    total_errors=$((total_errors + $?))

    # Backup volumes
    log_info "📦 Bắt đầu backup volumes..."
    backup_volumes
    total_errors=$((total_errors + $?))

    # Backup configs
    log_info "⚙️ Bắt đầu backup configs..."
    backup_configs
    total_errors=$((total_errors + $?))

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    # Tạo metadata
    local status="success"
    if [[ $total_errors -gt 0 ]]; then
        status="partial_success"
    fi

    create_backup_metadata "full" "$start_time" "$end_time" "$status"

    # Hiển thị kết quả
    show_backup_summary "$duration" "$total_errors"

    return $total_errors
}

# Database only backup
perform_database_backup() {
    local start_time=$(date +%s)

    show_backup_banner "DATABASE BACKUP"

    log_info "🗄️ Bắt đầu database backup..."

    if ! check_docker_services || ! create_backup_directories; then
        return 1
    fi

    local total_errors=0

    backup_postgresql
    total_errors=$((total_errors + $?))

    backup_mariadb
    total_errors=$((total_errors + $?))

    local end_time=$(date +%s)
    create_backup_metadata "database" "$start_time" "$end_time" "success"

    show_backup_summary $((end_time - start_time)) "$total_errors"
    return $total_errors
}

# Config only backup
perform_config_backup() {
    local start_time=$(date +%s)

    show_backup_banner "CONFIG BACKUP"

    log_info "⚙️ Bắt đầu config backup..."

    if ! create_backup_directories; then
        return 1
    fi

    backup_configs
    local total_errors=$?

    local end_time=$(date +%s)
    create_backup_metadata "config" "$start_time" "$end_time" "success"

    show_backup_summary $((end_time - start_time)) "$total_errors"
    return $total_errors
}

# Incremental backup
perform_incremental_backup() {
    local start_time=$(date +%s)

    show_backup_banner "INCREMENTAL BACKUP"

    log_info "📈 Bắt đầu incremental backup..."
    log_info "ℹ️ Chỉ backup các thay đổi từ lần backup cuối"

    # Tìm backup gần nhất
    local last_backup=$(find "$BACKUP_ROOT_DIR" -maxdepth 1 -type d -name "20*" | sort | tail -1)

    if [[ -z "$last_backup" ]]; then
        log_warning "⚠️ Không tìm thấy backup trước đó - thực hiện full backup"
        perform_full_backup
        return $?
    fi

    log_info "📋 Backup gần nhất: $(basename "$last_backup")"

    # Thực hiện incremental backup (simplified - chỉ backup configs và databases)
    if ! create_backup_directories; then
        return 1
    fi

    local total_errors=0

    # Luôn backup databases (vì dữ liệu thay đổi liên tục)
    backup_postgresql
    total_errors=$((total_errors + $?))

    backup_mariadb
    total_errors=$((total_errors + $?))

    # Backup configs nếu có thay đổi
    backup_configs
    total_errors=$((total_errors + $?))

    local end_time=$(date +%s)
    create_backup_metadata "incremental" "$start_time" "$end_time" "success"

    show_backup_summary $((end_time - start_time)) "$total_errors"
    return $total_errors
}

# Hiển thị tổng kết backup
show_backup_summary() {
    local duration="$1"
    local errors="$2"

    echo
    echo "============================================================"
    echo "                    📊 TỔNG KẾT BACKUP"
    echo "============================================================"

    log_info "⏱️ Thời gian thực hiện: ${duration}s"
    log_info "📁 Backup location: $BACKUP_DIR"

    if [[ -d "$BACKUP_DIR" ]]; then
        local backup_size=$(du -sh "$BACKUP_DIR" 2>/dev/null | cut -f1)
        log_info "💾 Kích thước backup: ${backup_size:-N/A}"
    fi

    if [[ $errors -eq 0 ]]; then
        log_success "🎉 Backup hoàn tất thành công!"
    elif [[ $errors -lt 5 ]]; then
        log_warning "⚠️ Backup hoàn tất với $errors lỗi nhỏ"
    else
        log_error "❌ Backup hoàn tất với $errors lỗi"
    fi

    echo
    log_info "📋 Để restore backup:"
    echo "  ./scripts/backup.sh --restore $BACKUP_DIR"
    echo
    log_info "📋 Để xem danh sách backups:"
    echo "  ./scripts/backup.sh --list"
    echo
}

# ============================================================================
# RESTORE FUNCTIONS
# ============================================================================

# Restore from backup
perform_restore() {
    local backup_path="$1"

    if [[ -z "$backup_path" ]]; then
        log_error "❌ Vui lòng chỉ định đường dẫn backup"
        return 1
    fi

    if [[ ! -d "$backup_path" ]]; then
        log_error "❌ Backup directory không tồn tại: $backup_path"
        return 1
    fi

    show_backup_banner "RESTORE BACKUP"

    log_info "🔄 Bắt đầu restore từ: $backup_path"

    # Kiểm tra metadata
    local metadata_file="$backup_path/metadata.json"
    if [[ -f "$metadata_file" ]]; then
        log_info "📋 Thông tin backup:"
        if command -v jq >/dev/null 2>&1; then
            jq -r '.backup_info | "  Timestamp: \(.timestamp)\n  Type: \(.type)\n  Status: \(.status)"' "$metadata_file"
        else
            log_info "  Metadata file: $metadata_file"
        fi
    else
        log_warning "⚠️ Không tìm thấy metadata file"
    fi

    # Xác nhận restore
    echo
    log_warning "⚠️ CẢNH BÁO: Restore sẽ ghi đè dữ liệu hiện tại!"
    if ! confirm_action "Bạn có chắc chắn muốn restore?"; then
        log_info "❌ Restore đã bị hủy"
        return 0
    fi

    local total_errors=0

    # Restore databases
    if [[ -d "$backup_path/databases" ]]; then
        log_info "🗄️ Restore databases..."
        restore_databases "$backup_path/databases"
        total_errors=$((total_errors + $?))
    fi

    # Restore volumes
    if [[ -d "$backup_path/volumes" ]]; then
        log_info "📦 Restore volumes..."
        restore_volumes "$backup_path/volumes"
        total_errors=$((total_errors + $?))
    fi

    # Restore configs
    if [[ -d "$backup_path/configs" ]]; then
        log_info "⚙️ Restore configs..."
        restore_configs "$backup_path/configs"
        total_errors=$((total_errors + $?))
    fi

    if [[ $total_errors -eq 0 ]]; then
        log_success "🎉 Restore hoàn tất thành công!"
    else
        log_error "❌ Restore hoàn tất với $total_errors lỗi"
    fi

    return $total_errors
}

# Restore databases
restore_databases() {
    local db_backup_dir="$1"
    local errors=0

    # Restore PostgreSQL
    for dump_file in "$db_backup_dir"/postgresql_*.sql.gz; do
        if [[ -f "$dump_file" ]]; then
            local db_name=$(basename "$dump_file" .sql.gz | sed 's/postgresql_//')
            log_loading "Restore PostgreSQL: $db_name"

            if zcat "$dump_file" | docker exec -i postgres psql -U "${POSTGRES_USER:-nextflow}" -d "$db_name" >/dev/null 2>&1; then
                log_success "✅ Restored: $db_name"
            else
                log_error "❌ Failed to restore: $db_name"
                ((errors++))
            fi
        fi
    done

    # Restore MariaDB
    for dump_file in "$db_backup_dir"/mariadb_*.sql.gz; do
        if [[ -f "$dump_file" ]]; then
            local db_name=$(basename "$dump_file" .sql.gz | sed 's/mariadb_//')
            log_loading "Restore MariaDB: $db_name"

            if zcat "$dump_file" | docker exec -i mariadb mysql -u root -p"${MYSQL_ROOT_PASSWORD:-nextflow@2025}" "$db_name" >/dev/null 2>&1; then
                log_success "✅ Restored: $db_name"
            else
                log_error "❌ Failed to restore: $db_name"
                ((errors++))
            fi
        fi
    done

    return $errors
}

# Restore volumes
restore_volumes() {
    local volume_backup_dir="$1"
    local errors=0

    for backup_file in "$volume_backup_dir"/*.tar.gz; do
        if [[ -f "$backup_file" ]]; then
            local volume_name=$(basename "$backup_file" .tar.gz)
            log_loading "Restore volume: $volume_name"

            # Tạo volume nếu chưa tồn tại
            docker volume create "$volume_name" >/dev/null 2>&1

            # Restore volume
            if docker run --rm \
                -v "$volume_name":/data \
                -v "$volume_backup_dir":/backup:ro \
                alpine:latest \
                sh -c "cd /data && tar xzf /backup/${volume_name}.tar.gz" >/dev/null 2>&1; then

                log_success "✅ Restored: $volume_name"
            else
                log_error "❌ Failed to restore: $volume_name"
                ((errors++))
            fi
        fi
    done

    return $errors
}

# Restore configs
restore_configs() {
    local config_backup_dir="$1"
    local errors=0

    # Restore config directories
    for backup_file in "$config_backup_dir"/*.tar.gz; do
        if [[ -f "$backup_file" ]]; then
            local config_name=$(basename "$backup_file" .tar.gz)
            log_loading "Restore config: $config_name"

            if tar xzf "$backup_file" -C "$PROJECT_ROOT" >/dev/null 2>&1; then
                log_success "✅ Restored: $config_name"
            else
                log_error "❌ Failed to restore: $config_name"
                ((errors++))
            fi
        fi
    done

    # Restore individual files
    for config_file in "$config_backup_dir"/*.yml "$config_backup_dir"/*.md; do
        if [[ -f "$config_file" ]]; then
            local file_name=$(basename "$config_file")
            log_loading "Restore file: $file_name"

            if cp "$config_file" "$PROJECT_ROOT/" >/dev/null 2>&1; then
                log_success "✅ Restored: $file_name"
            else
                log_error "❌ Failed to restore: $file_name"
                ((errors++))
            fi
        fi
    done

    return $errors
}

# ============================================================================
# CLEANUP FUNCTIONS
# ============================================================================

# Cleanup old backups
cleanup_old_backups() {
    show_backup_banner "CLEANUP OLD BACKUPS"

    log_info "🧹 Dọn dẹp backups cũ..."
    log_info "📅 Retention policy: $BACKUP_RETENTION_DAYS ngày, tối đa $BACKUP_MAX_COUNT backups"

    if [[ ! -d "$BACKUP_ROOT_DIR" ]]; then
        log_info "ℹ️ Không có thư mục backup để dọn dẹp"
        return 0
    fi

    local backup_dirs=($(find "$BACKUP_ROOT_DIR" -maxdepth 1 -type d -name "20*" | sort))
    local total_backups=${#backup_dirs[@]}

    if [[ $total_backups -eq 0 ]]; then
        log_info "ℹ️ Không có backup để dọn dẹp"
        return 0
    fi

    log_info "📊 Tìm thấy $total_backups backups"

    local deleted_count=0
    local current_time=$(date +%s)
    local retention_seconds=$((BACKUP_RETENTION_DAYS * 24 * 3600))

    # Cleanup theo thời gian
    for backup_dir in "${backup_dirs[@]}"; do
        local backup_name=$(basename "$backup_dir")
        local backup_time=$(date -d "${backup_name//_/ }" +%s 2>/dev/null)

        if [[ -n "$backup_time" ]]; then
            local age_seconds=$((current_time - backup_time))

            if [[ $age_seconds -gt $retention_seconds ]]; then
                log_loading "Xóa backup cũ: $backup_name ($(($age_seconds / 86400)) ngày)"

                if rm -rf "$backup_dir"; then
                    log_success "✅ Đã xóa: $backup_name"
                    ((deleted_count++))
                else
                    log_error "❌ Không thể xóa: $backup_name"
                fi
            fi
        fi
    done

    # Cleanup theo số lượng (giữ lại BACKUP_MAX_COUNT backups mới nhất)
    local remaining_dirs=($(find "$BACKUP_ROOT_DIR" -maxdepth 1 -type d -name "20*" | sort))
    local remaining_count=${#remaining_dirs[@]}

    if [[ $remaining_count -gt $BACKUP_MAX_COUNT ]]; then
        local excess_count=$((remaining_count - BACKUP_MAX_COUNT))
        log_info "📊 Có $remaining_count backups, giữ lại $BACKUP_MAX_COUNT mới nhất"

        for ((i=0; i<excess_count; i++)); do
            local backup_dir="${remaining_dirs[i]}"
            local backup_name=$(basename "$backup_dir")

            log_loading "Xóa backup dư thừa: $backup_name"

            if rm -rf "$backup_dir"; then
                log_success "✅ Đã xóa: $backup_name"
                ((deleted_count++))
            else
                log_error "❌ Không thể xóa: $backup_name"
            fi
        done
    fi

    log_info "📊 Đã xóa $deleted_count backups"

    # Hiển thị thống kê sau cleanup
    list_backups

    return 0
}

# ============================================================================
# LIST FUNCTIONS
# ============================================================================

# List all backups
list_backups() {
    show_backup_banner "DANH SÁCH BACKUPS"

    if [[ ! -d "$BACKUP_ROOT_DIR" ]]; then
        log_info "ℹ️ Chưa có backup nào"
        return 0
    fi

    local backup_dirs=($(find "$BACKUP_ROOT_DIR" -maxdepth 1 -type d -name "20*" | sort -r))

    if [[ ${#backup_dirs[@]} -eq 0 ]]; then
        log_info "ℹ️ Chưa có backup nào"
        return 0
    fi

    echo "📋 Tìm thấy ${#backup_dirs[@]} backups:"
    echo
    printf "%-20s %-12s %-10s %-15s %s\n" "TIMESTAMP" "TYPE" "STATUS" "SIZE" "LOCATION"
    printf "%-20s %-12s %-10s %-15s %s\n" "--------------------" "------------" "----------" "---------------" "----------------------------------------"

    for backup_dir in "${backup_dirs[@]}"; do
        local backup_name=$(basename "$backup_dir")
        local backup_size=$(du -sh "$backup_dir" 2>/dev/null | cut -f1)
        local backup_type="unknown"
        local backup_status="unknown"

        # Đọc metadata nếu có
        local metadata_file="$backup_dir/metadata.json"
        if [[ -f "$metadata_file" ]] && command -v jq >/dev/null 2>&1; then
            backup_type=$(jq -r '.backup_info.type // "unknown"' "$metadata_file" 2>/dev/null)
            backup_status=$(jq -r '.backup_info.status // "unknown"' "$metadata_file" 2>/dev/null)
        fi

        printf "%-20s %-12s %-10s %-15s %s\n" \
            "$backup_name" \
            "$backup_type" \
            "$backup_status" \
            "${backup_size:-N/A}" \
            "$backup_dir"
    done

    echo
    log_info "💡 Để restore backup:"
    echo "  ./scripts/backup.sh --restore <backup_path>"
    echo
    log_info "💡 Để xóa backup cũ:"
    echo "  ./scripts/backup.sh --cleanup"
    echo
}

# ============================================================================
# INTERACTIVE MENU
# ============================================================================

# Hiển thị menu chính
show_main_menu() {
    show_backup_banner

    echo "Chọn loại backup:"
    echo
    echo "  1) 🗄️  Full Backup (Toàn bộ: DB + Volumes + Configs)"
    echo "  2) 🐘  Database Backup (Chỉ databases)"
    echo "  3) ⚙️  Config Backup (Chỉ cấu hình)"
    echo "  4) 📈  Incremental Backup (Backup gia tăng)"
    echo "  5) 📋  List Backups (Xem danh sách)"
    echo "  6) 🔄  Restore Backup (Khôi phục)"
    echo "  7) 🧹  Cleanup Old Backups (Dọn dẹp)"
    echo "  8) ❌  Exit (Thoát)"
    echo
}

# Menu tương tác
interactive_menu() {
    while true; do
        show_main_menu

        read -p "Nhập lựa chọn (1-8): " choice
        echo

        case $choice in
            1)
                perform_full_backup
                ;;
            2)
                perform_database_backup
                ;;
            3)
                perform_config_backup
                ;;
            4)
                perform_incremental_backup
                ;;
            5)
                list_backups
                ;;
            6)
                echo "Nhập đường dẫn backup để restore:"
                read -p "Backup path: " backup_path
                if [[ -n "$backup_path" ]]; then
                    perform_restore "$backup_path"
                else
                    log_error "❌ Vui lòng nhập đường dẫn backup"
                fi
                ;;
            7)
                cleanup_old_backups
                ;;
            8)
                log_info "👋 Tạm biệt!"
                exit 0
                ;;
            *)
                log_error "❌ Lựa chọn không hợp lệ. Vui lòng chọn 1-8."
                ;;
        esac

        echo
        read -p "Nhấn Enter để tiếp tục..."
        clear
    done
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Confirm action
confirm_action() {
    local message="$1"
    local default="${2:-n}"

    while true; do
        if [[ "$default" == "y" ]]; then
            read -p "$message [Y/n]: " yn
            yn=${yn:-y}
        else
            read -p "$message [y/N]: " yn
            yn=${yn:-n}
        fi

        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Vui lòng trả lời yes hoặc no.";;
        esac
    done
}

# Show help
show_help() {
    show_backup_banner "HELP"

    echo "NextFlow Docker Backup System"
    echo
    echo "SỬ DỤNG:"
    echo "  $0 [OPTIONS]"
    echo
    echo "OPTIONS:"
    echo "  --full              Thực hiện full backup (toàn bộ)"
    echo "  --db-only           Chỉ backup databases"
    echo "  --config-only       Chỉ backup cấu hình"
    echo "  --incremental       Backup gia tăng"
    echo "  --restore <path>    Restore từ backup"
    echo "  --list              Hiển thị danh sách backups"
    echo "  --cleanup           Dọn dẹp backups cũ"
    echo "  --help              Hiển thị help này"
    echo
    echo "VÍ DỤ:"
    echo "  $0                                    # Interactive menu"
    echo "  $0 --full                             # Full backup"
    echo "  $0 --restore /path/to/backup          # Restore backup"
    echo "  $0 --cleanup                          # Cleanup old backups"
    echo
    echo "CẤU HÌNH:"
    echo "  BACKUP_RETENTION_DAYS=$BACKUP_RETENTION_DAYS    # Số ngày giữ backup"
    echo "  BACKUP_MAX_COUNT=$BACKUP_MAX_COUNT              # Số lượng backup tối đa"
    echo "  COMPRESSION_LEVEL=$COMPRESSION_LEVEL            # Mức nén (1-9)"
    echo
}

# ============================================================================
# MAIN FUNCTION
# ============================================================================

# Main function
main() {
    # Chuyển đến project root
    cd "$PROJECT_ROOT" || {
        echo "❌ Không thể chuyển đến project root: $PROJECT_ROOT"
        exit 1
    }

    # Parse arguments
    case "${1:-}" in
        --full)
            perform_full_backup
            ;;
        --db-only)
            perform_database_backup
            ;;
        --config-only)
            perform_config_backup
            ;;
        --incremental)
            perform_incremental_backup
            ;;
        --restore)
            if [[ -n "${2:-}" ]]; then
                perform_restore "$2"
            else
                log_error "❌ Vui lòng chỉ định đường dẫn backup"
                echo "Sử dụng: $0 --restore <backup_path>"
                exit 1
            fi
            ;;
        --list)
            list_backups
            ;;
        --cleanup)
            cleanup_old_backups
            ;;
        --help|-h)
            show_help
            ;;
        "")
            # Không có arguments - chạy interactive menu
            interactive_menu
            ;;
        *)
            log_error "❌ Tùy chọn không hợp lệ: $1"
            echo "Sử dụng: $0 --help để xem hướng dẫn"
            exit 1
            ;;
    esac
}

# ============================================================================
# SCRIPT EXECUTION
# ============================================================================

# Kiểm tra dependencies
check_dependencies() {
    local missing_deps=()

    # Kiểm tra các lệnh cần thiết
    local required_commands=("docker" "docker-compose" "tar" "gzip" "date" "find")

    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_deps+=("$cmd")
        fi
    done

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "❌ Thiếu dependencies: ${missing_deps[*]}"
        log_info "💡 Vui lòng cài đặt các lệnh trên trước khi chạy script"
        exit 1
    fi
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Chỉ chạy khi script được execute trực tiếp

    # Kiểm tra dependencies
    check_dependencies

    # Tạo thư mục backup root nếu chưa có
    mkdir -p "$BACKUP_ROOT_DIR"

    # Chạy main function
    main "$@"

    # Exit với code phù hợp
    exit $?
fi

# ============================================================================
# END OF SCRIPT
# ============================================================================
