#!/bin/bash
# ============================================================================
# GITLAB BACKUP SCRIPT
# ============================================================================
# Mô tả: Script tự động backup GitLab data
# Chức năng: Backup repositories, database, uploads, CI artifacts
# ============================================================================

set -e

# Màu sắc cho log
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[BACKUP]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[BACKUP]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[BACKUP]${NC} $1"
}

log_error() {
    echo -e "${RED}[BACKUP]${NC} $1"
}

# Cấu hình backup
BACKUP_DIR="/var/opt/gitlab/backups"
BACKUP_KEEP_DAYS=${BACKUP_KEEP_DAYS:-7}
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Hàm tạo backup GitLab
create_gitlab_backup() {
    log_info "Bắt đầu backup GitLab..."
    
    # Tạo backup
    gitlab-backup create BACKUP=${TIMESTAMP} STRATEGY=copy
    
    if [ $? -eq 0 ]; then
        log_success "Backup GitLab thành công: ${TIMESTAMP}_gitlab_backup.tar"
    else
        log_error "Backup GitLab thất bại!"
        return 1
    fi
}

# Hàm backup cấu hình GitLab
backup_gitlab_config() {
    log_info "Backup cấu hình GitLab..."
    
    # Tạo thư mục backup config
    CONFIG_BACKUP_DIR="${BACKUP_DIR}/config_${TIMESTAMP}"
    mkdir -p "${CONFIG_BACKUP_DIR}"
    
    # Copy các file cấu hình quan trọng
    cp -r /etc/gitlab/gitlab.rb "${CONFIG_BACKUP_DIR}/" 2>/dev/null || log_warning "Không tìm thấy gitlab.rb"
    cp -r /etc/gitlab/gitlab-secrets.json "${CONFIG_BACKUP_DIR}/" 2>/dev/null || log_warning "Không tìm thấy gitlab-secrets.json"
    cp -r /etc/gitlab/ssl "${CONFIG_BACKUP_DIR}/" 2>/dev/null || log_warning "Không tìm thấy thư mục ssl"
    
    # Tạo archive
    cd "${BACKUP_DIR}"
    tar -czf "config_${TIMESTAMP}.tar.gz" "config_${TIMESTAMP}"
    rm -rf "config_${TIMESTAMP}"
    
    log_success "Backup cấu hình thành công: config_${TIMESTAMP}.tar.gz"
}

# Hàm dọn dẹp backup cũ
cleanup_old_backups() {
    log_info "Dọn dẹp backup cũ (giữ ${BACKUP_KEEP_DAYS} ngày)..."
    
    # Xóa backup GitLab cũ
    find "${BACKUP_DIR}" -name "*_gitlab_backup.tar" -mtime +${BACKUP_KEEP_DAYS} -delete
    
    # Xóa backup config cũ
    find "${BACKUP_DIR}" -name "config_*.tar.gz" -mtime +${BACKUP_KEEP_DAYS} -delete
    
    log_success "Đã dọn dẹp backup cũ"
}

# Hàm kiểm tra dung lượng
check_disk_space() {
    log_info "Kiểm tra dung lượng đĩa..."
    
    # Lấy thông tin dung lượng
    AVAILABLE_SPACE=$(df "${BACKUP_DIR}" | awk 'NR==2 {print $4}')
    REQUIRED_SPACE=1048576  # 1GB in KB
    
    if [ "${AVAILABLE_SPACE}" -lt "${REQUIRED_SPACE}" ]; then
        log_warning "Dung lượng đĩa thấp! Có sẵn: ${AVAILABLE_SPACE}KB, Cần: ${REQUIRED_SPACE}KB"
        return 1
    else
        log_success "Dung lượng đĩa đủ: ${AVAILABLE_SPACE}KB có sẵn"
        return 0
    fi
}

# Hàm gửi thông báo backup
send_notification() {
    local status=$1
    local message=$2
    
    log_info "Gửi thông báo backup..."
    
    # Ghi log vào file
    echo "[$(date)] ${status}: ${message}" >> "${BACKUP_DIR}/backup.log"
    
    # Có thể thêm webhook notification ở đây
    # curl -X POST "${WEBHOOK_URL}" -d "{\"text\":\"GitLab Backup ${status}: ${message}\"}"
}

# Hàm verify backup
verify_backup() {
    local backup_file="${BACKUP_DIR}/${TIMESTAMP}_gitlab_backup.tar"
    
    log_info "Kiểm tra tính toàn vẹn backup..."
    
    if [ -f "${backup_file}" ]; then
        # Kiểm tra file có thể đọc được
        if tar -tf "${backup_file}" > /dev/null 2>&1; then
            log_success "Backup file hợp lệ"
            return 0
        else
            log_error "Backup file bị lỗi!"
            return 1
        fi
    else
        log_error "Không tìm thấy backup file!"
        return 1
    fi
}

# Main function
main() {
    log_info "🚀 Bắt đầu quá trình backup GitLab NextFlow..."
    
    # Kiểm tra dung lượng
    if ! check_disk_space; then
        log_error "Không đủ dung lượng để backup!"
        send_notification "FAILED" "Không đủ dung lượng đĩa"
        exit 1
    fi
    
    # Tạo backup
    if create_gitlab_backup; then
        # Backup cấu hình
        backup_gitlab_config
        
        # Verify backup
        if verify_backup; then
            # Dọn dẹp backup cũ
            cleanup_old_backups
            
            log_success "🎉 Backup hoàn thành thành công!"
            send_notification "SUCCESS" "Backup completed: ${TIMESTAMP}"
        else
            log_error "❌ Backup verification failed!"
            send_notification "FAILED" "Backup verification failed: ${TIMESTAMP}"
            exit 1
        fi
    else
        log_error "❌ Backup thất bại!"
        send_notification "FAILED" "Backup creation failed: ${TIMESTAMP}"
        exit 1
    fi
}

# Chỉ chạy nếu được gọi trực tiếp
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi
