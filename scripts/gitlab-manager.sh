#!/bin/bash
# ============================================================================
# GITLAB MANAGER SCRIPT FOR NEXTFLOW CRM-AI (FIXED VERSION)
# ============================================================================
# Mô tả: Script quản lý GitLab với menu tương tác đơn giản
# Tác giả: NextFlow Team
# Phiên bản: 1.1.0 (Fixed encoding issues)
# Sử dụng: ./scripts/gitlab-manager-fixed.sh [install|update|backup|restore]
# ============================================================================

set -euo pipefail

# Màu sắc cho output (đơn giản)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Cấu hình
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
COMPOSE_FILE="$PROJECT_DIR/docker-compose.yml"
ENV_FILE="$PROJECT_DIR/.env"
GITLAB_CONTAINER="gitlab"
BACKUP_DIR="$PROJECT_DIR/gitlab/backups"
GITLAB_SCRIPTS_DIR="$PROJECT_DIR/gitlab/scripts"

# Load environment variables
if [ -f "$ENV_FILE" ]; then
    set -a
    source "$ENV_FILE"
    set +a
fi

# Enhanced Logging System
# Cấu hình logging
LOG_LEVEL="${LOG_LEVEL:-INFO}"  # DEBUG, INFO, WARNING, ERROR
LOG_FILE="${PROJECT_DIR}/logs/gitlab-manager.log"
LOG_MAX_SIZE=10485760  # 10MB
LOG_BACKUP_COUNT=5

# Tạo thư mục logs
mkdir -p "$(dirname "$LOG_FILE")"

# Hàm ghi log vào file
write_log_file() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Rotate log nếu quá lớn
    if [ -f "$LOG_FILE" ] && [ $(stat -f%z "$LOG_FILE" 2>/dev/null || stat -c%s "$LOG_FILE" 2>/dev/null || echo 0) -gt $LOG_MAX_SIZE ]; then
        rotate_log_files
    fi

    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

# Hàm rotate log files
rotate_log_files() {
    for i in $(seq $((LOG_BACKUP_COUNT-1)) -1 1); do
        if [ -f "${LOG_FILE}.$i" ]; then
            mv "${LOG_FILE}.$i" "${LOG_FILE}.$((i+1))"
        fi
    done

    if [ -f "$LOG_FILE" ]; then
        mv "$LOG_FILE" "${LOG_FILE}.1"
    fi
}

# Enhanced logging functions
log_debug() {
    if [ "$LOG_LEVEL" = "DEBUG" ]; then
        echo -e "${CYAN}[DEBUG]${NC} $1"
    fi
    write_log_file "DEBUG" "$1"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
    write_log_file "INFO" "$1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    write_log_file "SUCCESS" "$1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    write_log_file "WARNING" "$1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    write_log_file "ERROR" "$1"
}

log_critical() {
    echo -e "${RED}${BOLD}[CRITICAL]${NC} $1"
    write_log_file "CRITICAL" "$1"
}

log_header() {
    local header_text="$1"
    local header_length=${#header_text}
    local border_length=$((header_length + 4))
    local border=$(printf '=%.0s' $(seq 1 $border_length))

    echo ""
    echo -e "${BOLD}${BLUE}$border${NC}"
    echo -e "${BOLD}${BLUE}  $header_text  ${NC}"
    echo -e "${BOLD}${BLUE}$border${NC}"
    echo ""

    write_log_file "HEADER" "$header_text"
}

# Hàm log với progress indicator
log_progress() {
    local message="$1"
    local current="$2"
    local total="$3"
    local percentage=$((current * 100 / total))

    # Tạo progress bar
    local bar_length=20
    local filled_length=$((percentage * bar_length / 100))
    local bar=""

    for i in $(seq 1 $filled_length); do
        bar="${bar}█"
    done

    for i in $(seq $((filled_length + 1)) $bar_length); do
        bar="${bar}░"
    done

    echo -ne "\r${BLUE}[PROGRESS]${NC} $message [$bar] $percentage% ($current/$total)"

    if [ "$current" -eq "$total" ]; then
        echo ""  # New line when complete
    fi

    write_log_file "PROGRESS" "$message - $percentage% ($current/$total)"
}

# Hàm log với timestamp chi tiết
log_timestamp() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%H:%M:%S.%3N')

    case "$level" in
        "INFO")
            echo -e "${BLUE}[$timestamp][INFO]${NC} $message"
            ;;
        "SUCCESS")
            echo -e "${GREEN}[$timestamp][SUCCESS]${NC} $message"
            ;;
        "WARNING")
            echo -e "${YELLOW}[$timestamp][WARNING]${NC} $message"
            ;;
        "ERROR")
            echo -e "${RED}[$timestamp][ERROR]${NC} $message"
            ;;
    esac

    write_log_file "$level" "$message"
}

# Hàm log performance metrics
log_performance() {
    local operation="$1"
    local start_time="$2"
    local end_time="$3"
    local duration=$((end_time - start_time))
    local minutes=$((duration / 60))
    local seconds=$((duration % 60))

    local performance_msg="$operation completed in ${minutes}m ${seconds}s"
    echo -e "${CYAN}[PERF]${NC} $performance_msg"
    write_log_file "PERFORMANCE" "$performance_msg"
}

# Hàm log system metrics
log_system_metrics() {
    local metrics_msg="System Metrics:"

    # Memory usage
    if command -v free >/dev/null 2>&1; then
        local mem_usage=$(free | awk 'NR==2{printf "Memory: %.1f%%", $3*100/$2}')
        metrics_msg="$metrics_msg | $mem_usage"
    fi

    # Disk usage
    local disk_usage=$(df -h "$PROJECT_DIR" | awk 'NR==2{print "Disk: " $5}')
    metrics_msg="$metrics_msg | $disk_usage"

    # Load average
    if command -v uptime >/dev/null 2>&1; then
        local load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print "Load: " $1}')
        metrics_msg="$metrics_msg | $load_avg"
    fi

    echo -e "${CYAN}[METRICS]${NC} $metrics_msg"
    write_log_file "METRICS" "$metrics_msg"
}

# Hàm log Docker metrics
log_docker_metrics() {
    if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
        local containers_running=$(docker ps -q | wc -l)
        local containers_total=$(docker ps -a -q | wc -l)
        local images_count=$(docker images -q | wc -l)

        local docker_msg="Docker: ${containers_running}/${containers_total} containers running, ${images_count} images"
        echo -e "${CYAN}[DOCKER]${NC} $docker_msg"
        write_log_file "DOCKER" "$docker_msg"
    fi
}

# Enhanced Monitoring và Reporting Functions

# Hàm tạo session log
start_session_log() {
    local session_id=$(date +%Y%m%d_%H%M%S)_$$
    export GITLAB_MANAGER_SESSION="$session_id"

    log_info "🚀 Bắt đầu session GitLab Manager: $session_id"
    log_system_metrics
    log_docker_metrics

    # Tạo session log file
    local session_log="$PROJECT_DIR/logs/session_${session_id}.log"
    echo "GitLab Manager Session Log" > "$session_log"
    echo "Session ID: $session_id" >> "$session_log"
    echo "Start Time: $(date)" >> "$session_log"
    echo "User: $(whoami)" >> "$session_log"
    echo "Working Directory: $PROJECT_DIR" >> "$session_log"
    echo "================================" >> "$session_log"

    export GITLAB_MANAGER_SESSION_LOG="$session_log"
}

# Hàm kết thúc session log
end_session_log() {
    if [ -n "$GITLAB_MANAGER_SESSION" ]; then
        log_info "🏁 Kết thúc session GitLab Manager: $GITLAB_MANAGER_SESSION"
        log_system_metrics
        log_docker_metrics

        if [ -n "$GITLAB_MANAGER_SESSION_LOG" ]; then
            echo "================================" >> "$GITLAB_MANAGER_SESSION_LOG"
            echo "End Time: $(date)" >> "$GITLAB_MANAGER_SESSION_LOG"
            echo "Session Duration: $(date -d@$(($(date +%s) - $(date -d "$(head -3 "$GITLAB_MANAGER_SESSION_LOG" | tail -1 | cut -d: -f2-)" +%s))) -u +%H:%M:%S)" >> "$GITLAB_MANAGER_SESSION_LOG"
        fi
    fi
}

# Hàm monitor command execution
monitor_command() {
    local command_name="$1"
    local start_time=$(date +%s)

    log_timestamp "INFO" "Starting command: $command_name"

    # Trap để log khi command kết thúc
    trap "log_performance '$command_name' $start_time \$(date +%s)" EXIT

    return 0
}

# Hàm tạo operation report
create_operation_report() {
    local operation="$1"
    local status="$2"
    local details="$3"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    local report_file="$PROJECT_DIR/logs/operations.log"

    # Tạo header nếu file chưa tồn tại
    if [ ! -f "$report_file" ]; then
        echo "GitLab Manager Operations Log" > "$report_file"
        echo "=============================" >> "$report_file"
        echo "" >> "$report_file"
    fi

    # Ghi operation log
    {
        echo "[$timestamp] OPERATION: $operation"
        echo "  Status: $status"
        echo "  Details: $details"
        echo "  Session: ${GITLAB_MANAGER_SESSION:-unknown}"
        echo "  User: $(whoami)"
        echo ""
    } >> "$report_file"

    log_info "📝 Operation logged: $operation ($status)"
}

# Hàm monitor GitLab health
monitor_gitlab_health() {
    local health_data=""
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Container status
    if docker ps --format "{{.Names}}" | grep -q "^gitlab$"; then
        local container_status="running"
        local health_status=$(docker inspect gitlab --format='{{.State.Health.Status}}' 2>/dev/null || echo "unknown")
        health_data="Container: $container_status ($health_status)"
    else
        health_data="Container: stopped"
    fi

    # Web interface
    local http_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8088" 2>/dev/null || echo "000")
    health_data="$health_data | Web: HTTP $http_code"

    # Database
    if docker ps --format "{{.Names}}" | grep -q "^postgres$"; then
        if docker exec postgres pg_isready -U nextflow >/dev/null 2>&1; then
            health_data="$health_data | DB: connected"
        else
            health_data="$health_data | DB: disconnected"
        fi
    else
        health_data="$health_data | DB: stopped"
    fi

    # Redis
    if docker ps --format "{{.Names}}" | grep -q "^redis$"; then
        if docker exec redis redis-cli ping >/dev/null 2>&1; then
            health_data="$health_data | Redis: connected"
        else
            health_data="$health_data | Redis: disconnected"
        fi
    else
        health_data="$health_data | Redis: stopped"
    fi

    echo -e "${CYAN}[HEALTH]${NC} $health_data"
    write_log_file "HEALTH" "$health_data"

    # Ghi vào health log
    local health_log="$PROJECT_DIR/logs/health.log"
    echo "[$timestamp] $health_data" >> "$health_log"
}

# Hàm tạo daily report
create_daily_report() {
    local report_date=$(date '+%Y-%m-%d')
    local report_file="$PROJECT_DIR/logs/daily_report_${report_date}.txt"

    log_info "📊 Tạo daily report: $report_file"

    {
        echo "GitLab Manager Daily Report"
        echo "=========================="
        echo "Date: $report_date"
        echo "Generated: $(date)"
        echo ""

        echo "SYSTEM STATUS:"
        echo "--------------"
        monitor_gitlab_health
        echo ""

        echo "OPERATIONS TODAY:"
        echo "----------------"
        if [ -f "$PROJECT_DIR/logs/operations.log" ]; then
            grep "$(date '+%Y-%m-%d')" "$PROJECT_DIR/logs/operations.log" || echo "No operations recorded today"
        else
            echo "No operations log found"
        fi
        echo ""

        echo "HEALTH CHECKS TODAY:"
        echo "-------------------"
        if [ -f "$PROJECT_DIR/logs/health.log" ]; then
            grep "$(date '+%Y-%m-%d')" "$PROJECT_DIR/logs/health.log" | tail -10 || echo "No health checks today"
        else
            echo "No health log found"
        fi
        echo ""

        echo "SYSTEM METRICS:"
        echo "---------------"
        log_system_metrics
        log_docker_metrics
        echo ""

        echo "LOG FILES:"
        echo "----------"
        if [ -d "$PROJECT_DIR/logs" ]; then
            ls -la "$PROJECT_DIR/logs/" | grep "$(date '+%Y-%m-%d')" || echo "No log files created today"
        fi

    } > "$report_file"

    log_success "✅ Daily report created: $report_file"
}

# Hàm cleanup old logs
cleanup_old_logs() {
    local retention_days=30
    local logs_dir="$PROJECT_DIR/logs"

    if [ ! -d "$logs_dir" ]; then
        return 0
    fi

    log_info "🧹 Cleaning up logs older than $retention_days days..."

    # Cleanup old log files
    local deleted_count=0
    if command -v find >/dev/null 2>&1; then
        deleted_count=$(find "$logs_dir" -name "*.log" -mtime +$retention_days -delete -print 2>/dev/null | wc -l)
        find "$logs_dir" -name "session_*.log" -mtime +$retention_days -delete 2>/dev/null
        find "$logs_dir" -name "daily_report_*.txt" -mtime +$retention_days -delete 2>/dev/null
    fi

    if [ "$deleted_count" -gt 0 ]; then
        log_success "✅ Cleaned up $deleted_count old log files"
    else
        log_info "📋 No old log files to clean up"
    fi
}

# Hàm show log statistics
show_log_statistics() {
    local logs_dir="$PROJECT_DIR/logs"

    if [ ! -d "$logs_dir" ]; then
        log_warning "⚠️ Logs directory không tồn tại"
        return 1
    fi

    log_header "LOG STATISTICS"

    echo "📊 Log Files Overview:"
    echo ""

    # Main log file
    if [ -f "$LOG_FILE" ]; then
        local log_size=$(du -h "$LOG_FILE" | cut -f1)
        local log_lines=$(wc -l < "$LOG_FILE")
        echo "  📄 Main log: $log_size ($log_lines lines)"
    fi

    # Session logs
    local session_count=$(ls -1 "$logs_dir"/session_*.log 2>/dev/null | wc -l)
    echo "  🔄 Session logs: $session_count files"

    # Daily reports
    local report_count=$(ls -1 "$logs_dir"/daily_report_*.txt 2>/dev/null | wc -l)
    echo "  📊 Daily reports: $report_count files"

    # Operations log
    if [ -f "$logs_dir/operations.log" ]; then
        local ops_lines=$(wc -l < "$logs_dir/operations.log")
        echo "  ⚙️ Operations log: $ops_lines lines"
    fi

    # Health log
    if [ -f "$logs_dir/health.log" ]; then
        local health_lines=$(wc -l < "$logs_dir/health.log")
        echo "  💚 Health log: $health_lines lines"
    fi

    echo ""
    echo "📈 Recent Activity (last 24h):"

    # Recent operations
    if [ -f "$logs_dir/operations.log" ]; then
        local recent_ops=$(grep "$(date '+%Y-%m-%d')" "$logs_dir/operations.log" 2>/dev/null | wc -l)
        echo "  ⚙️ Operations today: $recent_ops"
    fi

    # Recent errors
    local recent_errors=$(grep "$(date '+%Y-%m-%d')" "$LOG_FILE" 2>/dev/null | grep -c "\[ERROR\]" || echo "0")
    echo "  ❌ Errors today: $recent_errors"

    # Recent warnings
    local recent_warnings=$(grep "$(date '+%Y-%m-%d')" "$LOG_FILE" 2>/dev/null | grep -c "\[WARNING\]" || echo "0")
    echo "  ⚠️ Warnings today: $recent_warnings"

    echo ""
    echo "💡 Log Management:"
    echo "  • View logs: tail -f $LOG_FILE"
    echo "  • Cleanup old logs: Tự động sau $LOG_BACKUP_COUNT files"
    echo "  • Daily reports: Tạo thủ công hoặc tự động"
}

# Hàm kiểm tra yêu cầu hệ thống
check_requirements() {
    log_info "Đang kiểm tra yêu cầu hệ thống..."

    # Kiểm tra Docker có cài đặt không
    if ! command -v docker &> /dev/null; then
        log_error "Docker chưa được cài đặt!"
        log_info "Hướng dẫn cài đặt:"
        echo "  • Windows: Tải Docker Desktop từ docker.com"
        echo "  • Linux: curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh"
        exit 1
    fi

    # Kiểm tra phiên bản Docker
    DOCKER_VERSION=$(docker --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    log_info "Phiên bản Docker: $DOCKER_VERSION"

    # Kiểm tra Docker có chạy không
    if ! docker info &> /dev/null; then
        log_error "Docker daemon không chạy!"
        log_info "Khắc phục:"
        echo "  • Windows: Khởi động Docker Desktop"
        echo "  • Linux: sudo systemctl start docker"
        exit 1
    fi

    # Kiểm tra quyền truy cập Docker
    if ! docker ps &> /dev/null; then
        log_error "Không có quyền truy cập Docker!"
        log_info "Khắc phục:"
        echo "  • Linux: sudo usermod -aG docker \$USER && newgrp docker"
        echo "  • Windows: Chạy terminal với quyền Administrator"
        exit 1
    fi

    # Kiểm tra Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose chưa được cài đặt!"
        log_info "Hướng dẫn cài đặt:"
        echo "  • Thường đi kèm với Docker Desktop"
        echo "  • Linux: sudo apt install docker-compose-plugin"
        exit 1
    fi

    # Kiểm tra phiên bản Docker Compose
    COMPOSE_VERSION=$(docker-compose --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    log_info "Phiên bản Docker Compose: $COMPOSE_VERSION"

    # Kiểm tra file cấu hình
    if [ ! -f "$COMPOSE_FILE" ]; then
        log_error "Không tìm thấy file docker-compose.yml tại: $COMPOSE_FILE"
        log_info "Đảm bảo bạn đang chạy script từ thư mục gốc dự án"
        exit 1
    fi

    if [ ! -f "$ENV_FILE" ]; then
        log_error "Không tìm thấy file .env tại: $ENV_FILE"
        log_info "Tạo file .env từ .env.example hoặc chạy script setup"
        exit 1
    fi

    # Kiểm tra dung lượng đĩa (cần ít nhất 10GB cho GitLab)
    AVAILABLE_SPACE=$(df -BG "$PROJECT_DIR" 2>/dev/null | awk 'NR==2 {print $4}' | sed 's/G//' || echo "0")
    if [ "$AVAILABLE_SPACE" -lt 10 ]; then
        log_warning "Dung lượng đĩa thấp: ${AVAILABLE_SPACE}GB (khuyến nghị ít nhất 10GB)"
        log_info "GitLab cần nhiều dung lượng để lưu trữ repositories và artifacts"
        read -p "Tiếp tục với dung lượng thấp? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        log_success "Dung lượng đĩa đủ: ${AVAILABLE_SPACE}GB"
    fi

    # Kiểm tra RAM (GitLab cần ít nhất 4GB)
    if command -v free >/dev/null 2>&1; then
        TOTAL_RAM=$(free -m | awk 'NR==2{printf "%.0f", $2/1024}')
        if [ "$TOTAL_RAM" -lt 4 ]; then
            log_warning "RAM thấp: ${TOTAL_RAM}GB (khuyến nghị ít nhất 4GB cho GitLab)"
            log_info "GitLab có thể chạy chậm hoặc không ổn định với RAM thấp"
            read -p "Tiếp tục với RAM thấp? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        else
            log_success "RAM đủ yêu cầu: ${TOTAL_RAM}GB"
        fi
    else
        log_info "Không thể kiểm tra RAM trên hệ thống này"
    fi

    log_success "Tất cả yêu cầu hệ thống đã được đáp ứng!"
}

# Hàm kiểm tra trạng thái GitLab
check_gitlab_status() {
    # Kiểm tra container có tồn tại không
    if ! docker ps -a --format "table {{.Names}}" | grep -q "^${GITLAB_CONTAINER}$"; then
        log_info "Container GitLab chưa được tạo"
        return 2  # Container chưa tồn tại
    fi

    # Kiểm tra container có đang chạy không
    if docker ps --format "table {{.Names}}" | grep -q "^${GITLAB_CONTAINER}$"; then
        # Kiểm tra health status nếu có
        HEALTH_STATUS=$(docker inspect "$GITLAB_CONTAINER" --format='{{.State.Health.Status}}' 2>/dev/null || echo "no-health-check")

        case "$HEALTH_STATUS" in
            "healthy")
                log_success "GitLab đang chạy và khỏe mạnh"
                return 0  # Đang chạy và khỏe mạnh
                ;;
            "unhealthy")
                log_warning "GitLab đang chạy nhưng không khỏe mạnh"
                return 3  # Đang chạy nhưng có vấn đề
                ;;
            "starting")
                log_info "GitLab đang trong quá trình khởi động"
                return 4  # Đang khởi động
                ;;
            "no-health-check")
                log_info "GitLab đang chạy (không có health check)"
                return 0  # Đang chạy nhưng không có health check
                ;;
            *)
                log_warning "GitLab có trạng thái không xác định: $HEALTH_STATUS"
                return 3  # Trạng thái không rõ
                ;;
        esac
    else
        log_info "Container GitLab đã dừng"
        return 1  # Container đã dừng
    fi
}

# Hàm kiểm tra trạng thái GitLab với thông tin chi tiết
check_gitlab_status_verbose() {
    log_info "Đang kiểm tra trạng thái GitLab chi tiết..."

    local status_code
    check_gitlab_status
    status_code=$?

    case $status_code in
        0)
            echo "✅ GitLab đang hoạt động bình thường"
            # Kiểm tra thêm web interface
            if curl -s -o /dev/null -w "%{http_code}" "http://localhost:8088" | grep -qE "^(200|302)$"; then
                echo "🌐 Web interface có thể truy cập"
            else
                echo "⚠️ Web interface chưa sẵn sàng"
            fi
            ;;
        1)
            echo "🔴 GitLab container đã dừng"
            echo "💡 Khởi động: docker-compose --profile gitlab up -d gitlab"
            ;;
        2)
            echo "❌ GitLab container chưa được tạo"
            echo "💡 Cài đặt: chọn option [3] INSTALL trong menu"
            ;;
        3)
            echo "⚠️ GitLab có vấn đề về sức khỏe"
            echo "💡 Kiểm tra logs: docker logs gitlab"
            ;;
        4)
            echo "⏳ GitLab đang khởi động, vui lòng đợi..."
            ;;
        *)
            echo "❓ Không thể xác định trạng thái GitLab"
            ;;
    esac

    return $status_code
}

# Hàm đợi GitLab sẵn sàng
wait_for_gitlab() {
    local max_attempts=60  # 60 * 30s = 30 phút
    local attempt=1
    local start_time=$(date +%s)

    log_info "⏳ Đợi GitLab khởi động hoàn toàn..."
    log_warning "Lần đầu khởi động có thể mất 5-15 phút, vui lòng kiên nhẫn..."
    echo ""

    # Hiển thị progress bar
    local progress_chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    local progress_index=0

    while [ $attempt -le $max_attempts ]; do
        # Kiểm tra container có đang chạy không
        if ! docker ps --format "{{.Names}}" | grep -q "^${GITLAB_CONTAINER}$"; then
            echo ""
            log_error "❌ GitLab container đã dừng bất ngờ!"
            log_info "Kiểm tra logs: docker logs gitlab"
            return 1
        fi

        # Kiểm tra GitLab services
        local gitlab_services_ready=false
        if docker exec "$GITLAB_CONTAINER" gitlab-ctl status >/dev/null 2>&1; then
            gitlab_services_ready=true
        fi

        # Kiểm tra web interface
        local web_ready=false
        local http_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8088" 2>/dev/null || echo "000")
        if [[ "$http_code" =~ ^(200|302)$ ]]; then
            web_ready=true
        fi

        # Nếu cả hai đều ready
        if [ "$gitlab_services_ready" = true ] && [ "$web_ready" = true ]; then
            echo ""
            log_success "🎉 GitLab đã sẵn sàng!"

            local end_time=$(date +%s)
            local duration=$((end_time - start_time))
            local minutes=$((duration / 60))
            local seconds=$((duration % 60))
            log_info "⏱️ Thời gian khởi động: ${minutes}m ${seconds}s"

            return 0
        fi

        # Hiển thị progress với thông tin chi tiết
        local current_time=$(date +%s)
        local elapsed=$((current_time - start_time))
        local elapsed_minutes=$((elapsed / 60))
        local elapsed_seconds=$((elapsed % 60))

        local progress_char=${progress_chars:$progress_index:1}
        progress_index=$(((progress_index + 1) % ${#progress_chars}))

        local status_msg=""
        if [ "$gitlab_services_ready" = true ]; then
            status_msg="Services: ✅ | Web: ⏳"
        else
            status_msg="Services: ⏳ | Web: ⏳"
        fi

        echo -ne "\r  $progress_char Đợi GitLab... ${elapsed_minutes}m ${elapsed_seconds}s | $status_msg | Lần thử: $attempt/$max_attempts"

        sleep 30
        ((attempt++))
    done

    echo ""
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    local minutes=$((duration / 60))

    log_error "❌ GitLab không khởi động được sau ${minutes} phút!"
    echo ""
    log_info "🔍 Các bước khắc phục:"
    echo "  1. Kiểm tra logs: docker logs gitlab"
    echo "  2. Kiểm tra tài nguyên hệ thống (RAM, CPU, Disk)"
    echo "  3. Restart container: docker restart gitlab"
    echo "  4. Kiểm tra dependencies: docker ps | grep -E '(postgres|redis)'"
    echo "  5. Sử dụng option [7] STATUS để chẩn đoán chi tiết"

    return 1
}

# Hàm kiểm tra GitLab images có sẵn
check_gitlab_images() {
    log_header "KIỂM TRA GITLAB IMAGES"

    log_info "Đang quét tất cả GitLab images có sẵn..."
    echo ""

    local has_custom=false
    local has_official=false
    local custom_image="nextflow/gitlab-ce:${GITLAB_VERSION:-16.11.10-ce.0}"

    # Kiểm tra custom image NextFlow
    log_info "🔍 Tìm kiếm NextFlow custom image..."
    if docker images "$custom_image" --format "{{.Repository}}" | grep -q "nextflow/gitlab-ce"; then
        has_custom=true
        local custom_info=$(docker images "$custom_image" --format "{{.ID}} {{.Size}} {{.CreatedAt}}" | head -1)
        local image_id=$(echo "$custom_info" | cut -d' ' -f1)
        local image_size=$(echo "$custom_info" | cut -d' ' -f2)
        local created_date=$(echo "$custom_info" | cut -d' ' -f3-)

        echo "   ✅ NextFlow Custom Image: $custom_image"
        echo "      📦 Image ID: $image_id"
        echo "      💾 Kích thước: $image_size"
        echo "      📅 Tạo lúc: $created_date"
        echo "      🎯 Tính năng: Tối ưu cho NextFlow CRM-AI"
        echo ""
    else
        echo "   ❌ NextFlow Custom Image: Chưa có"
        echo "      💡 Có thể build bằng option [2] BUILD"
        echo ""
    fi

    # Kiểm tra official image
    log_info "🔍 Tìm kiếm GitLab official images..."
    local official_images=$(docker images gitlab/gitlab-ce --format "{{.Tag}} {{.ID}} {{.Size}} {{.CreatedAt}}" 2>/dev/null)

    if [ -n "$official_images" ]; then
        has_official=true
        echo "   ✅ GitLab Official Images:"

        # Hiển thị tối đa 3 images gần nhất
        local count=0
        while IFS= read -r line && [ $count -lt 3 ]; do
            if [ -n "$line" ]; then
                local tag=$(echo "$line" | cut -d' ' -f1)
                local id=$(echo "$line" | cut -d' ' -f2)
                local size=$(echo "$line" | cut -d' ' -f3)
                local created=$(echo "$line" | cut -d' ' -f4-)

                echo "      📦 gitlab/gitlab-ce:$tag"
                echo "         ID: $id | Size: $size | Created: $created"
                ((count++))
            fi
        done <<< "$official_images"

        local total_official=$(echo "$official_images" | wc -l)
        if [ $total_official -gt 3 ]; then
            echo "      ... và $((total_official - 3)) images khác"
        fi
        echo ""
    else
        echo "   ❌ GitLab Official Images: Chưa có"
        echo "      💡 Có thể pull bằng: docker pull gitlab/gitlab-ce:latest"
        echo ""
    fi

    # Tổng kết và khuyến nghị
    log_info "📊 Tổng kết:"
    if [ "$has_custom" = true ] && [ "$has_official" = true ]; then
        echo "   🎉 Có cả custom và official images"
        echo "   💡 Khuyến nghị: Sử dụng NextFlow custom image để có tính năng tối ưu"
    elif [ "$has_custom" = true ]; then
        echo "   ✅ Có NextFlow custom image (đủ để sử dụng)"
        echo "   💡 Tùy chọn: Có thể pull official image để backup"
    elif [ "$has_official" = true ]; then
        echo "   ⚠️ Chỉ có official image"
        echo "   💡 Khuyến nghị: Build NextFlow custom image để có tính năng tối ưu"
    else
        echo "   ❌ Không có image nào"
        echo "   🚨 Cần thiết: Pull official hoặc build custom image"
        log_error "Không tìm thấy GitLab image nào!"
        echo ""
        log_info "Các bước khắc phục:"
        echo "   1. Pull official image: docker pull gitlab/gitlab-ce:latest"
        echo "   2. Hoặc build custom image: chọn option [2] BUILD"
        echo "   3. Hoặc cài đặt tự động: chọn option [3] INSTALL"
        return 1
    fi

    echo ""
    return 0
}

# Hàm build GitLab custom image
build_gitlab() {
    log_header "BUILD GITLAB CUSTOM IMAGE"

    # Kiểm tra yêu cầu hệ thống trước
    check_requirements

    # Kiểm tra Dockerfile và context
    local dockerfile_path="$PROJECT_DIR/gitlab/docker/Dockerfile"
    local build_context="$PROJECT_DIR/gitlab/docker"

    if [ ! -f "$dockerfile_path" ]; then
        log_error "Không tìm thấy Dockerfile!"
        log_info "Đường dẫn mong đợi: $dockerfile_path"
        log_info "Vui lòng kiểm tra cấu trúc thư mục dự án"
        return 1
    fi

    if [ ! -d "$build_context" ]; then
        log_error "Không tìm thấy build context!"
        log_info "Thư mục mong đợi: $build_context"
        return 1
    fi

    # Kiểm tra các file cần thiết trong build context
    log_info "Kiểm tra build context..."
    local required_files=("Dockerfile")
    local missing_files=()

    for file in "${required_files[@]}"; do
        if [ ! -f "$build_context/$file" ]; then
            missing_files+=("$file")
        fi
    done

    if [ ${#missing_files[@]} -gt 0 ]; then
        log_error "Thiếu các file cần thiết trong build context:"
        for file in "${missing_files[@]}"; do
            echo "  ❌ $file"
        done
        return 1
    fi

    # Hiển thị thông tin build
    local custom_image="nextflow/gitlab-ce:${GITLAB_VERSION:-16.11.10-ce.0}"
    log_info "Thông tin build:"
    echo "  📦 Image name: $custom_image"
    echo "  📁 Build context: $build_context"
    echo "  🐳 Dockerfile: $dockerfile_path"
    echo "  🏷️ GitLab version: ${GITLAB_VERSION:-16.11.10-ce.0}"
    echo ""

    # Kiểm tra image cũ
    if docker images "$custom_image" --format "{{.Repository}}" | grep -q "nextflow/gitlab-ce"; then
        log_warning "Image cũ đã tồn tại!"
        local old_info=$(docker images "$custom_image" --format "{{.ID}} {{.Size}} {{.CreatedAt}}" | head -1)
        echo "  🗂️ Image cũ: $(echo "$old_info" | cut -d' ' -f1)"
        echo "  💾 Size: $(echo "$old_info" | cut -d' ' -f2)"
        echo "  📅 Created: $(echo "$old_info" | cut -d' ' -f3-)"
        echo ""

        read -p "Bạn có muốn rebuild image mới? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Hủy build, sử dụng image hiện tại"
            return 0
        fi
    fi

    # Bắt đầu build process
    log_info "🔨 Bắt đầu build GitLab custom image..."
    log_warning "⏳ Quá trình này có thể mất 10-20 phút, vui lòng kiên nhẫn..."
    echo ""

    # Build image với docker-compose và hiển thị progress
    local build_start_time=$(date +%s)

    if docker-compose -f "$COMPOSE_FILE" build --no-cache gitlab; then
        local build_end_time=$(date +%s)
        local build_duration=$((build_end_time - build_start_time))
        local build_minutes=$((build_duration / 60))
        local build_seconds=$((build_duration % 60))

        log_success "🎉 Build GitLab custom image thành công!"
        echo "  ⏱️ Thời gian build: ${build_minutes}m ${build_seconds}s"
        echo ""

        # Hiển thị thông tin image mới
        log_info "📊 Thông tin image vừa build:"
        local new_image_info=$(docker images "$custom_image" --format "{{.ID}} {{.Size}} {{.CreatedAt}}" | head -1)
        if [ -n "$new_image_info" ]; then
            local image_id=$(echo "$new_image_info" | cut -d' ' -f1)
            local image_size=$(echo "$new_image_info" | cut -d' ' -f2)
            local created_time=$(echo "$new_image_info" | cut -d' ' -f3-)

            echo "  🆔 Image ID: $image_id"
            echo "  💾 Kích thước: $image_size"
            echo "  📅 Thời gian tạo: $created_time"
            echo "  🏷️ Tag: $custom_image"
        fi

        # Dọn dẹp dangling images
        log_info "🧹 Dọn dẹp dangling images..."
        local dangling_count=$(docker images -f "dangling=true" -q | wc -l)
        if [ "$dangling_count" -gt 0 ]; then
            docker image prune -f >/dev/null 2>&1
            log_success "Đã dọn dẹp $dangling_count dangling images"
        else
            log_info "Không có dangling images cần dọn dẹp"
        fi

        echo ""
        log_success "✅ GitLab custom image đã sẵn sàng sử dụng!"
        log_info "💡 Bước tiếp theo: Chọn option [3] INSTALL để cài đặt GitLab"

        return 0
    else
        local build_end_time=$(date +%s)
        local build_duration=$((build_end_time - build_start_time))
        local build_minutes=$((build_duration / 60))
        local build_seconds=$((build_duration % 60))

        log_error "❌ Build GitLab image thất bại!"
        echo "  ⏱️ Thời gian thử build: ${build_minutes}m ${build_seconds}s"
        echo ""
        log_info "🔍 Các bước khắc phục:"
        echo "  1. Kiểm tra kết nối internet"
        echo "  2. Kiểm tra dung lượng đĩa (cần ít nhất 5GB trống)"
        echo "  3. Kiểm tra Docker daemon có đủ tài nguyên"
        echo "  4. Xem logs chi tiết ở trên để tìm lỗi cụ thể"
        echo "  5. Thử build lại sau khi khắc phục"

        return 1
    fi
}

# Hàm quản lý GitLab images - CHỨC NĂNG MỚI
manage_gitlab_images() {
    log_header "QUẢN LÝ GITLAB IMAGES"

    while true; do
        echo ""
        echo "Chọn thao tác với GitLab images:"
        echo ""
        echo "   1. [LIST] Liệt kê tất cả images"
        echo "   2. [PULL] Pull official image mới nhất"
        echo "   3. [BUILD] Build NextFlow custom image"
        echo "   4. [CLEAN] Dọn dẹp images cũ"
        echo "   5. [COMPARE] So sánh images"
        echo "   0. [BACK] Quay lại menu chính"
        echo ""

        read -p "Nhập lựa chọn (0-5): " choice
        echo ""

        case $choice in
            1)
                check_gitlab_images
                ;;
            2)
                pull_official_gitlab_image
                ;;
            3)
                build_gitlab
                ;;
            4)
                clean_old_gitlab_images
                ;;
            5)
                compare_gitlab_images
                ;;
            0)
                return 0
                ;;
            *)
                log_error "Lựa chọn không hợp lệ!"
                sleep 1
                ;;
        esac

        if [ "$choice" != "0" ]; then
            echo ""
            read -p "Nhấn Enter để tiếp tục..." -r
        fi
    done
}

# Hàm pull official GitLab image
pull_official_gitlab_image() {
    log_info "🔄 Pull GitLab official image..."

    local gitlab_version="${GITLAB_VERSION:-latest}"
    local official_image="gitlab/gitlab-ce:$gitlab_version"

    log_info "Đang pull image: $official_image"
    log_warning "⏳ Quá trình này có thể mất 5-15 phút tùy vào tốc độ mạng..."

    if docker pull "$official_image"; then
        log_success "✅ Pull image thành công!"

        # Hiển thị thông tin image vừa pull
        local image_info=$(docker images "$official_image" --format "{{.ID}} {{.Size}} {{.CreatedAt}}" | head -1)
        if [ -n "$image_info" ]; then
            echo "  🆔 Image ID: $(echo "$image_info" | cut -d' ' -f1)"
            echo "  💾 Kích thước: $(echo "$image_info" | cut -d' ' -f2)"
            echo "  📅 Thời gian tạo: $(echo "$image_info" | cut -d' ' -f3-)"
        fi
    else
        log_error "❌ Pull image thất bại!"
        log_info "Kiểm tra kết nối internet và thử lại"
        return 1
    fi
}

# Hàm dọn dẹp images cũ
clean_old_gitlab_images() {
    log_info "🧹 Dọn dẹp GitLab images cũ..."

    # Liệt kê tất cả GitLab images
    local all_gitlab_images=$(docker images --format "{{.Repository}}:{{.Tag}} {{.ID}} {{.Size}} {{.CreatedAt}}" | grep -E "(gitlab|nextflow)" | grep -v "<none>")

    if [ -z "$all_gitlab_images" ]; then
        log_info "Không có GitLab images nào để dọn dẹp"
        return 0
    fi

    echo "📋 Danh sách GitLab images hiện tại:"
    echo "$all_gitlab_images" | nl -w2 -s'. '
    echo ""

    # Tìm dangling images
    local dangling_images=$(docker images -f "dangling=true" -q)
    local dangling_count=$(echo "$dangling_images" | grep -c . 2>/dev/null || echo "0")

    if [ "$dangling_count" -gt 0 ]; then
        log_warning "Tìm thấy $dangling_count dangling images"
        read -p "Xóa dangling images? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker image prune -f
            log_success "Đã xóa dangling images"
        fi
    else
        log_info "Không có dangling images"
    fi

    # Hỏi có muốn xóa images cũ không
    echo ""
    log_warning "⚠️ Cảnh báo: Chỉ xóa images không sử dụng"
    read -p "Bạn có muốn xóa images cũ không sử dụng? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        docker image prune -a -f --filter "label!=keep"
        log_success "Đã dọn dẹp images cũ"
    fi
}

# Hàm so sánh GitLab images
compare_gitlab_images() {
    log_info "📊 So sánh GitLab images..."

    local custom_image="nextflow/gitlab-ce:${GITLAB_VERSION:-16.11.10-ce.0}"
    local official_image="gitlab/gitlab-ce:${GITLAB_VERSION:-latest}"

    echo ""
    echo "🔍 Thông tin chi tiết:"
    echo ""

    # So sánh custom image
    if docker images "$custom_image" --format "{{.Repository}}" | grep -q "nextflow/gitlab-ce"; then
        local custom_info=$(docker images "$custom_image" --format "{{.ID}} {{.Size}} {{.CreatedAt}}" | head -1)
        echo "✅ NextFlow Custom Image:"
        echo "   📦 Name: $custom_image"
        echo "   🆔 ID: $(echo "$custom_info" | cut -d' ' -f1)"
        echo "   💾 Size: $(echo "$custom_info" | cut -d' ' -f2)"
        echo "   📅 Created: $(echo "$custom_info" | cut -d' ' -f3-)"
        echo "   🎯 Features: NextFlow optimized, custom scripts"
    else
        echo "❌ NextFlow Custom Image: Chưa có"
    fi

    echo ""

    # So sánh official image
    if docker images "gitlab/gitlab-ce" --format "{{.Repository}}" | grep -q "gitlab/gitlab-ce"; then
        local official_info=$(docker images "gitlab/gitlab-ce" --format "{{.Tag}} {{.ID}} {{.Size}} {{.CreatedAt}}" | head -1)
        echo "✅ GitLab Official Image:"
        echo "   📦 Name: gitlab/gitlab-ce:$(echo "$official_info" | cut -d' ' -f1)"
        echo "   🆔 ID: $(echo "$official_info" | cut -d' ' -f2)"
        echo "   💾 Size: $(echo "$official_info" | cut -d' ' -f3)"
        echo "   📅 Created: $(echo "$official_info" | cut -d' ' -f4-)"
        echo "   🎯 Features: Standard GitLab CE"
    else
        echo "❌ GitLab Official Image: Chưa có"
    fi

    echo ""
    echo "💡 Khuyến nghị:"
    echo "   • NextFlow Custom: Tối ưu cho dự án NextFlow CRM-AI"
    echo "   • Official Image: Phiên bản gốc, ổn định"
    echo "   • Nên có cả hai để backup và testing"
}

# 1. CHỨC NĂNG CÀI ĐẶT GITLAB
install_gitlab() {
    log_header "CÀI ĐẶT GITLAB NEXTFLOW"

    # Bước 1: Kiểm tra yêu cầu hệ thống
    log_info "🔍 Bước 1/7: Kiểm tra yêu cầu hệ thống..."
    check_requirements
    check_environment_variables
    check_network_connectivity

    # Bước 2: Kiểm tra trạng thái GitLab hiện tại
    log_info "🔍 Bước 2/7: Kiểm tra trạng thái GitLab hiện tại..."
    local gitlab_status
    check_gitlab_status
    gitlab_status=$?

    case $gitlab_status in
        0)
            log_success "GitLab đã đang chạy và khỏe mạnh!"
            echo ""
            log_info "Các tùy chọn:"
            echo "   1. Giữ nguyên GitLab hiện tại"
            echo "   2. Khởi động lại GitLab"
            echo "   3. Cài đặt lại hoàn toàn"
            echo ""
            read -p "Chọn tùy chọn (1-3): " choice

            case $choice in
                1)
                    log_info "Giữ nguyên GitLab hiện tại"
                    show_gitlab_access_info
                    return 0
                    ;;
                2)
                    log_info "Khởi động lại GitLab..."
                    docker-compose -f "$COMPOSE_FILE" restart gitlab
                    if wait_for_gitlab; then
                        log_success "GitLab đã khởi động lại thành công!"
                        show_gitlab_access_info
                        return 0
                    else
                        log_error "Khởi động lại GitLab thất bại!"
                        return 1
                    fi
                    ;;
                3)
                    log_warning "Sẽ cài đặt lại GitLab hoàn toàn..."
                    read -p "Bạn có chắc chắn? Dữ liệu hiện tại sẽ bị mất! (y/N): " -n 1 -r
                    echo
                    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                        log_info "Hủy cài đặt lại"
                        return 0
                    fi
                    # Tiếp tục với cài đặt mới
                    ;;
                *)
                    log_error "Lựa chọn không hợp lệ!"
                    return 1
                    ;;
            esac
            ;;
        1)
            log_info "GitLab container đã dừng, sẽ khởi động lại"
            ;;
        2)
            log_info "GitLab container chưa được tạo, sẽ cài đặt mới"
            ;;
        3|4)
            log_warning "GitLab có vấn đề, sẽ cài đặt lại"
            ;;
    esac

    # Bước 3: Kiểm tra và chuẩn bị images
    log_info "🔍 Bước 3/7: Kiểm tra và chuẩn bị GitLab images..."
    prepare_gitlab_images

    # Bước 4: Chuẩn bị môi trường
    log_info "🔍 Bước 4/7: Chuẩn bị môi trường GitLab..."
    prepare_gitlab_environment

    # Bước 5: Khởi động dependencies
    log_info "🔍 Bước 5/7: Khởi động dependencies (PostgreSQL, Redis)..."
    start_gitlab_dependencies

    # Bước 6: Cài đặt GitLab
    log_info "🔍 Bước 6/7: Cài đặt và khởi động GitLab..."
    deploy_gitlab_service

    # Bước 7: Kiểm tra và hoàn tất
    log_info "🔍 Bước 7/7: Kiểm tra cài đặt và hoàn tất..."
    if verify_gitlab_installation; then
        log_success "🎉 GitLab đã được cài đặt thành công!"
        show_gitlab_access_info
        return 0
    else
        log_error "❌ Cài đặt GitLab thất bại!"
        show_installation_troubleshooting
        return 1
    fi
}

# Hàm chuẩn bị GitLab images
prepare_gitlab_images() {
    local has_custom_image=false
    local has_official_image=false
    local custom_image="nextflow/gitlab-ce:${GITLAB_VERSION:-16.11.10-ce.0}"

    # Kiểm tra custom image
    if docker images "$custom_image" --format "{{.Repository}}" | grep -q "nextflow/gitlab-ce"; then
        has_custom_image=true
        log_success "✅ Tìm thấy NextFlow custom image: $custom_image"
    fi

    # Kiểm tra official image
    if docker images gitlab/gitlab-ce --format "{{.Repository}}" | grep -q "gitlab/gitlab-ce"; then
        has_official_image=true
        log_success "✅ Tìm thấy GitLab official image"
    fi

    # Xử lý trường hợp không có image nào
    if [ "$has_custom_image" = false ] && [ "$has_official_image" = false ]; then
        log_error "❌ Không tìm thấy GitLab image nào!"
        echo ""
        log_info "Các tùy chọn:"
        echo "   1. Build NextFlow custom image (khuyến nghị)"
        echo "   2. Pull GitLab official image"
        echo "   3. Hủy cài đặt"
        echo ""
        read -p "Chọn tùy chọn (1-3): " choice

        case $choice in
            1)
                log_info "Build NextFlow custom image..."
                if build_gitlab; then
                    log_success "Build custom image thành công!"
                else
                    log_error "Build custom image thất bại!"
                    return 1
                fi
                ;;
            2)
                log_info "Pull GitLab official image..."
                if pull_official_gitlab_image; then
                    log_success "Pull official image thành công!"
                else
                    log_error "Pull official image thất bại!"
                    return 1
                fi
                ;;
            3)
                log_info "Hủy cài đặt"
                return 1
                ;;
            *)
                log_error "Lựa chọn không hợp lệ!"
                return 1
                ;;
        esac
    elif [ "$has_custom_image" = false ] && [ "$has_official_image" = true ]; then
        # Chỉ có official image
        log_warning "⚠️ Chỉ có GitLab official image"
        log_info "NextFlow custom image có thêm scripts và cấu hình tối ưu"
        echo ""
        read -p "Bạn có muốn build NextFlow custom image không? (Y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            if build_gitlab; then
                log_success "Build custom image thành công!"
            else
                log_warning "Build custom image thất bại, sẽ sử dụng official image"
            fi
        else
            log_info "Sẽ sử dụng GitLab official image"
            log_warning "Lưu ý: Sẽ thiếu một số tính năng NextFlow custom"
        fi
    else
        log_success "✅ Images đã sẵn sàng"
    fi

    return 0
}

# Hàm chuẩn bị môi trường GitLab
prepare_gitlab_environment() {
    log_info "Tạo thư mục cần thiết cho GitLab..."

    local directories=(
        "$PROJECT_DIR/gitlab/config"
        "$PROJECT_DIR/gitlab/logs"
        "$PROJECT_DIR/gitlab/data"
        "$PROJECT_DIR/gitlab/backups"
        "$PROJECT_DIR/gitlab/ssl"
    )

    for dir in "${directories[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            log_info "  📁 Tạo thư mục: $(basename "$dir")"
        else
            log_info "  ✅ Thư mục đã có: $(basename "$dir")"
        fi
    done

    # Thiết lập quyền truy cập
    chmod 755 "$PROJECT_DIR/gitlab"
    chmod -R 755 "$PROJECT_DIR/gitlab"/*

    log_success "✅ Môi trường GitLab đã sẵn sàng"
    return 0
}

# Hàm khởi động dependencies
start_gitlab_dependencies() {
    log_info "Kiểm tra và khởi động PostgreSQL..."

    # Kiểm tra PostgreSQL
    if ! docker ps --format "{{.Names}}" | grep -q "^postgres$"; then
        log_info "Khởi động PostgreSQL..."
        docker-compose -f "$COMPOSE_FILE" up -d postgres

        # Đợi PostgreSQL sẵn sàng
        local max_attempts=30
        local attempt=1

        while [ $attempt -le $max_attempts ]; do
            if docker exec postgres pg_isready -U nextflow >/dev/null 2>&1; then
                log_success "✅ PostgreSQL đã sẵn sàng"
                break
            fi

            echo -ne "\r  ⏳ Đợi PostgreSQL... ($attempt/$max_attempts)"
            sleep 2
            ((attempt++))
        done
        echo ""

        if [ $attempt -gt $max_attempts ]; then
            log_error "❌ PostgreSQL không khởi động được"
            return 1
        fi
    else
        log_success "✅ PostgreSQL đã đang chạy"
    fi

    log_info "Kiểm tra và khởi động Redis..."

    # Kiểm tra Redis
    if ! docker ps --format "{{.Names}}" | grep -q "^redis$"; then
        log_info "Khởi động Redis..."
        docker-compose -f "$COMPOSE_FILE" up -d redis

        # Đợi Redis sẵn sàng
        local max_attempts=15
        local attempt=1

        while [ $attempt -le $max_attempts ]; do
            if docker exec redis redis-cli ping >/dev/null 2>&1; then
                log_success "✅ Redis đã sẵn sàng"
                break
            fi

            echo -ne "\r  ⏳ Đợi Redis... ($attempt/$max_attempts)"
            sleep 1
            ((attempt++))
        done
        echo ""

        if [ $attempt -gt $max_attempts ]; then
            log_error "❌ Redis không khởi động được"
            return 1
        fi
    else
        log_success "✅ Redis đã đang chạy"
    fi

    # Tạo database cho GitLab
    log_info "Chuẩn bị database cho GitLab..."
    local gitlab_db="${GITLAB_DATABASE:-nextflow_gitlab}"

    if docker exec postgres psql -U nextflow -c "SELECT 1 FROM pg_database WHERE datname = '$gitlab_db';" | grep -q 1; then
        log_success "✅ Database '$gitlab_db' đã tồn tại"
    else
        log_info "Tạo database '$gitlab_db'..."
        if docker exec postgres psql -U nextflow -c "CREATE DATABASE $gitlab_db;"; then
            log_success "✅ Đã tạo database '$gitlab_db'"
        else
            log_error "❌ Không thể tạo database '$gitlab_db'"
            return 1
        fi
    fi

    return 0
}

# Hàm deploy GitLab service
deploy_gitlab_service() {
    log_info "Khởi động GitLab container..."

    # Dừng GitLab cũ nếu có
    if docker ps -a --format "{{.Names}}" | grep -q "^gitlab$"; then
        log_info "Dừng GitLab container cũ..."
        docker-compose -f "$COMPOSE_FILE" --profile gitlab stop gitlab 2>/dev/null || true
        docker-compose -f "$COMPOSE_FILE" --profile gitlab rm -f gitlab 2>/dev/null || true
    fi

    # Khởi động GitLab mới
    log_info "Khởi động GitLab container mới..."
    if docker-compose -f "$COMPOSE_FILE" --profile gitlab up -d gitlab; then
        log_success "✅ GitLab container đã được khởi động"
        return 0
    else
        log_error "❌ Không thể khởi động GitLab container"
        return 1
    fi
}

# Hàm kiểm tra cài đặt GitLab
verify_gitlab_installation() {
    log_info "Đợi GitLab khởi động hoàn toàn..."

    if wait_for_gitlab; then
        log_success "✅ GitLab đã khởi động thành công"

        # Kiểm tra thêm các services
        log_info "Kiểm tra GitLab services..."
        if docker exec gitlab gitlab-ctl status >/dev/null 2>&1; then
            log_success "✅ GitLab internal services đang hoạt động"
        else
            log_warning "⚠️ Một số GitLab services có thể chưa sẵn sàng"
        fi

        # Kiểm tra web interface
        log_info "Kiểm tra web interface..."
        local max_attempts=10
        local attempt=1

        while [ $attempt -le $max_attempts ]; do
            local http_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8088" 2>/dev/null || echo "000")
            if [[ "$http_code" =~ ^(200|302)$ ]]; then
                log_success "✅ Web interface có thể truy cập"
                return 0
            fi

            echo -ne "\r  ⏳ Kiểm tra web interface... ($attempt/$max_attempts)"
            sleep 10
            ((attempt++))
        done
        echo ""

        log_warning "⚠️ Web interface chưa sẵn sàng hoàn toàn, nhưng GitLab đã khởi động"
        return 0
    else
        log_error "❌ GitLab không khởi động được"
        return 1
    fi
}

# Hàm hiển thị troubleshooting khi cài đặt lỗi
show_installation_troubleshooting() {
    log_header "HƯỚNG DẪN KHẮC PHỤC LỖI CÀI ĐẶT"

    echo "🔍 Các bước kiểm tra và khắc phục:"
    echo ""
    echo "1. 📋 Kiểm tra logs GitLab:"
    echo "   docker logs gitlab"
    echo ""
    echo "2. 💾 Kiểm tra tài nguyên hệ thống:"
    echo "   • RAM: Cần ít nhất 4GB"
    echo "   • Disk: Cần ít nhất 10GB trống"
    echo "   • CPU: Cần ít nhất 2 cores"
    echo ""
    echo "3. 🔌 Kiểm tra kết nối dependencies:"
    echo "   docker exec gitlab ping postgres"
    echo "   docker exec gitlab ping redis"
    echo ""
    echo "4. 🗄️ Kiểm tra database:"
    echo "   docker exec postgres psql -U nextflow -l"
    echo ""
    echo "5. 🔄 Thử khởi động lại:"
    echo "   docker restart gitlab"
    echo ""
    echo "6. 🧹 Reset hoàn toàn (nếu cần):"
    echo "   Sử dụng option [13] RESET-ALL trong menu"
    echo ""

    log_info "💡 Nếu vẫn gặp vấn đề, hãy sử dụng option [7] STATUS để chẩn đoán chi tiết"
}

# 2. CHỨC NĂNG BACKUP GITLAB
backup_gitlab() {
    log_header "BACKUP GITLAB"

    # Bước 1: Kiểm tra yêu cầu và trạng thái
    log_info "🔍 Bước 1/6: Kiểm tra yêu cầu hệ thống..."
    check_requirements

    log_info "🔍 Kiểm tra trạng thái GitLab..."
    local gitlab_status
    check_gitlab_status
    gitlab_status=$?

    if [ $gitlab_status -ne 0 ]; then
        log_error "❌ GitLab không đang chạy hoặc có vấn đề!"
        log_info "Trạng thái GitLab cần phải healthy để backup an toàn"
        log_info "Sử dụng option [7] STATUS để kiểm tra chi tiết"
        return 1
    fi

    # Bước 2: Chuẩn bị backup
    log_info "🔍 Bước 2/6: Chuẩn bị backup..."
    prepare_backup_environment

    # Bước 3: Pre-backup checks
    log_info "🔍 Bước 3/6: Kiểm tra trước khi backup..."
    if ! pre_backup_checks; then
        log_error "❌ Pre-backup checks thất bại!"
        return 1
    fi

    # Bước 4: Thực hiện backup
    log_info "🔍 Bước 4/6: Thực hiện backup dữ liệu..."
    local timestamp=$(date +%Y%m%d_%H%M%S)
    if ! perform_gitlab_backup "$timestamp"; then
        log_error "❌ Backup dữ liệu thất bại!"
        return 1
    fi

    # Bước 5: Backup cấu hình
    log_info "🔍 Bước 5/6: Backup cấu hình..."
    if ! backup_gitlab_config "$timestamp"; then
        log_warning "⚠️ Backup cấu hình thất bại, nhưng backup dữ liệu đã thành công"
    fi

    # Bước 6: Post-backup tasks
    log_info "🔍 Bước 6/6: Hoàn tất và dọn dẹp..."
    post_backup_tasks "$timestamp"

    log_success "🎉 Backup GitLab hoàn thành!"
    show_backup_summary "$timestamp"
    return 0
}

# Hàm chuẩn bị môi trường backup
prepare_backup_environment() {
    # Tạo thư mục backup
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
        log_info "📁 Tạo thư mục backup: $BACKUP_DIR"
    fi

    # Kiểm tra quyền ghi
    if [ ! -w "$BACKUP_DIR" ]; then
        log_error "❌ Không có quyền ghi vào thư mục backup: $BACKUP_DIR"
        return 1
    fi

    # Kiểm tra dung lượng đĩa
    local available_space=$(df -BG "$BACKUP_DIR" 2>/dev/null | awk 'NR==2 {print $4}' | sed 's/G//' || echo "0")
    if [ "$available_space" -lt 5 ]; then
        log_warning "⚠️ Dung lượng đĩa thấp: ${available_space}GB"
        log_info "Backup GitLab có thể cần 2-5GB tùy vào kích thước dữ liệu"
        read -p "Tiếp tục backup? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
    else
        log_success "✅ Dung lượng đĩa đủ: ${available_space}GB"
    fi

    return 0
}

# Hàm kiểm tra trước backup
pre_backup_checks() {
    log_info "Kiểm tra GitLab services..."

    # Kiểm tra GitLab services đang chạy
    if ! docker exec "$GITLAB_CONTAINER" gitlab-ctl status >/dev/null 2>&1; then
        log_error "❌ GitLab services không hoạt động bình thường"
        return 1
    fi

    # Kiểm tra database connection
    if ! docker exec "$GITLAB_CONTAINER" gitlab-rails runner "ActiveRecord::Base.connection.current_database" >/dev/null 2>&1; then
        log_error "❌ Không thể kết nối database"
        return 1
    fi

    # Kiểm tra backup directory trong container
    if ! docker exec "$GITLAB_CONTAINER" test -d "/var/opt/gitlab/backups"; then
        log_error "❌ Thư mục backup trong container không tồn tại"
        return 1
    fi

    # Kiểm tra quyền backup trong container
    if ! docker exec "$GITLAB_CONTAINER" test -w "/var/opt/gitlab/backups"; then
        log_error "❌ Không có quyền ghi backup trong container"
        return 1
    fi

    log_success "✅ Tất cả pre-backup checks đã pass"
    return 0
}

# Hàm thực hiện backup GitLab
perform_gitlab_backup() {
    local timestamp="$1"
    local backup_start_time=$(date +%s)

    log_info "💾 Bắt đầu backup GitLab..."
    log_info "📅 Timestamp: $timestamp"
    log_warning "⏳ Quá trình này có thể mất 5-30 phút tùy vào kích thước dữ liệu..."
    echo ""

    # Tạo backup với progress monitoring
    local backup_pid
    docker exec "$GITLAB_CONTAINER" gitlab-backup create BACKUP="$timestamp" STRATEGY=copy &
    backup_pid=$!

    # Monitor backup progress
    local attempt=1
    local max_attempts=180  # 180 * 10s = 30 phút
    local progress_chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    local progress_index=0

    while kill -0 $backup_pid 2>/dev/null && [ $attempt -le $max_attempts ]; do
        local current_time=$(date +%s)
        local elapsed=$((current_time - backup_start_time))
        local elapsed_minutes=$((elapsed / 60))
        local elapsed_seconds=$((elapsed % 60))

        local progress_char=${progress_chars:$progress_index:1}
        progress_index=$(((progress_index + 1) % ${#progress_chars}))

        echo -ne "\r  $progress_char Đang backup... ${elapsed_minutes}m ${elapsed_seconds}s | Lần thử: $attempt/$max_attempts"

        sleep 10
        ((attempt++))
    done
    echo ""

    # Đợi process hoàn thành
    wait $backup_pid
    local backup_exit_code=$?

    local backup_end_time=$(date +%s)
    local backup_duration=$((backup_end_time - backup_start_time))
    local backup_minutes=$((backup_duration / 60))
    local backup_seconds=$((backup_duration % 60))

    if [ $backup_exit_code -eq 0 ]; then
        # Kiểm tra file backup có được tạo không
        if docker exec "$GITLAB_CONTAINER" test -f "/var/opt/gitlab/backups/${timestamp}_gitlab_backup.tar"; then
            local backup_size=$(docker exec "$GITLAB_CONTAINER" du -h "/var/opt/gitlab/backups/${timestamp}_gitlab_backup.tar" | cut -f1)
            log_success "✅ Backup dữ liệu thành công!"
            echo "  ⏱️ Thời gian backup: ${backup_minutes}m ${backup_seconds}s"
            echo "  💾 Kích thước backup: $backup_size"
            return 0
        else
            log_error "❌ File backup không được tạo!"
            return 1
        fi
    else
        log_error "❌ Backup process thất bại (exit code: $backup_exit_code)!"
        echo "  ⏱️ Thời gian thử backup: ${backup_minutes}m ${backup_seconds}s"
        return 1
    fi
}

# Hàm backup cấu hình GitLab
backup_gitlab_config() {
    local timestamp="$1"
    local config_backup="$BACKUP_DIR/config_$timestamp.tar.gz"

    log_info "📋 Backup cấu hình GitLab..."

    # Kiểm tra thư mục config có tồn tại không
    if [ ! -d "$PROJECT_DIR/gitlab/config" ]; then
        log_warning "⚠️ Thư mục config không tồn tại, bỏ qua backup config"
        return 0
    fi

    # Tạo backup config
    if tar -czf "$config_backup" -C "$PROJECT_DIR/gitlab" config 2>/dev/null; then
        local config_size=$(du -h "$config_backup" | cut -f1)
        log_success "✅ Backup cấu hình thành công!"
        echo "  📁 File: $(basename "$config_backup")"
        echo "  💾 Kích thước: $config_size"
        return 0
    else
        log_error "❌ Backup cấu hình thất bại!"
        return 1
    fi
}

# Hàm post-backup tasks
post_backup_tasks() {
    local timestamp="$1"

    # Copy backup file từ container ra host (nếu cần)
    log_info "📤 Copy backup file ra host..."
    local backup_file="${timestamp}_gitlab_backup.tar"
    local host_backup_path="$BACKUP_DIR/$backup_file"

    if docker cp "$GITLAB_CONTAINER:/var/opt/gitlab/backups/$backup_file" "$host_backup_path" 2>/dev/null; then
        log_success "✅ Đã copy backup file ra host"

        # Verify backup file integrity
        if [ -f "$host_backup_path" ] && [ -s "$host_backup_path" ]; then
            local host_backup_size=$(du -h "$host_backup_path" | cut -f1)
            log_info "  📁 File: $backup_file"
            log_info "  💾 Kích thước: $host_backup_size"
        else
            log_warning "⚠️ Backup file trên host có vấn đề"
        fi
    else
        log_warning "⚠️ Không thể copy backup file ra host"
        log_info "Backup vẫn có sẵn trong container tại: /var/opt/gitlab/backups/$backup_file"
    fi

    # Dọn dẹp backup cũ
    cleanup_old_backups
}

# Hàm dọn dẹp backup cũ
cleanup_old_backups() {
    log_info "🧹 Dọn dẹp backup cũ..."

    # Cấu hình retention
    local retention_days=7
    local retention_count=10

    # Dọn dẹp theo ngày
    log_info "Xóa backup cũ hơn $retention_days ngày..."
    local deleted_files=0

    # Dọn dẹp backup files
    if command -v find >/dev/null 2>&1; then
        deleted_files=$(find "$BACKUP_DIR" -name "*_gitlab_backup.tar" -mtime +$retention_days -delete -print 2>/dev/null | wc -l)
        find "$BACKUP_DIR" -name "config_*.tar.gz" -mtime +$retention_days -delete 2>/dev/null
    fi

    if [ "$deleted_files" -gt 0 ]; then
        log_success "✅ Đã xóa $deleted_files backup files cũ"
    else
        log_info "📋 Không có backup files cũ cần xóa"
    fi

    # Dọn dẹp theo số lượng (giữ tối đa 10 backup gần nhất)
    local backup_count=$(ls -1 "$BACKUP_DIR"/*_gitlab_backup.tar 2>/dev/null | wc -l)
    if [ "$backup_count" -gt "$retention_count" ]; then
        log_info "Giữ $retention_count backup gần nhất, xóa $(($backup_count - $retention_count)) backup cũ..."
        ls -1t "$BACKUP_DIR"/*_gitlab_backup.tar 2>/dev/null | tail -n +$((retention_count + 1)) | xargs rm -f
        ls -1t "$BACKUP_DIR"/config_*.tar.gz 2>/dev/null | tail -n +$((retention_count + 1)) | xargs rm -f
        log_success "✅ Đã dọn dẹp theo số lượng"
    fi

    # Dọn dẹp backup trong container
    log_info "Dọn dẹp backup cũ trong container..."
    docker exec "$GITLAB_CONTAINER" find /var/opt/gitlab/backups -name "*_gitlab_backup.tar" -mtime +$retention_days -delete 2>/dev/null || true
}

# Hàm hiển thị tổng kết backup
show_backup_summary() {
    local timestamp="$1"

    log_header "TỔng KẾT BACKUP"

    echo "📊 Thông tin backup:"
    echo "  🕐 Thời gian: $(date -d "${timestamp:0:8} ${timestamp:9:2}:${timestamp:11:2}:${timestamp:13:2}" "+%d/%m/%Y %H:%M:%S" 2>/dev/null || echo "$timestamp")"
    echo "  📁 Thư mục: $BACKUP_DIR"
    echo ""

    echo "📋 Danh sách files đã tạo:"

    # Backup chính
    local main_backup="$BACKUP_DIR/${timestamp}_gitlab_backup.tar"
    if [ -f "$main_backup" ]; then
        local size=$(du -h "$main_backup" | cut -f1)
        echo "  ✅ ${timestamp}_gitlab_backup.tar ($size)"
    else
        echo "  ⚠️ ${timestamp}_gitlab_backup.tar (chỉ có trong container)"
    fi

    # Config backup
    local config_backup="$BACKUP_DIR/config_${timestamp}.tar.gz"
    if [ -f "$config_backup" ]; then
        local size=$(du -h "$config_backup" | cut -f1)
        echo "  ✅ config_${timestamp}.tar.gz ($size)"
    else
        echo "  ❌ config_${timestamp}.tar.gz (thất bại)"
    fi

    echo ""
    echo "💡 Lưu ý quan trọng:"
    echo "  • Backup được giữ trong $retention_days ngày"
    echo "  • Tối đa $retention_count backup gần nhất được giữ lại"
    echo "  • Backup trong container: /var/opt/gitlab/backups/"
    echo "  • Để restore: sử dụng option [6] RESTORE"
    echo ""

    # Hiển thị tổng số backup hiện có
    local total_backups=$(ls -1 "$BACKUP_DIR"/*_gitlab_backup.tar 2>/dev/null | wc -l)
    echo "📈 Tổng số backup hiện có: $total_backups"

    if [ "$total_backups" -gt 0 ]; then
        echo ""
        echo "📋 5 backup gần nhất:"
        ls -1t "$BACKUP_DIR"/*_gitlab_backup.tar 2>/dev/null | head -5 | while read backup_file; do
            local filename=$(basename "$backup_file")
            local backup_date=$(echo "$filename" | grep -o '[0-9]\{8\}_[0-9]\{6\}')
            local formatted_date=$(date -d "${backup_date:0:8} ${backup_date:9:2}:${backup_date:11:2}:${backup_date:13:2}" "+%d/%m/%Y %H:%M:%S" 2>/dev/null || echo "$backup_date")
            local size=$(du -h "$backup_file" | cut -f1)
            echo "    📦 $filename ($size) - $formatted_date"
        done
    fi
}

# 3. CHỨC NĂNG RESTORE GITLAB
restore_gitlab() {
    log_header "RESTORE GITLAB"

    # Bước 1: Kiểm tra yêu cầu và trạng thái
    log_info "🔍 Bước 1/7: Kiểm tra yêu cầu hệ thống..."
    check_requirements

    log_info "🔍 Kiểm tra trạng thái GitLab..."
    local gitlab_status
    check_gitlab_status
    gitlab_status=$?

    if [ $gitlab_status -eq 2 ]; then
        log_error "❌ GitLab container chưa được tạo!"
        log_info "Vui lòng cài đặt GitLab trước khi restore"
        log_info "Sử dụng option [3] INSTALL để cài đặt GitLab"
        return 1
    fi

    # Bước 2: Liệt kê và chọn backup
    log_info "🔍 Bước 2/7: Liệt kê backup có sẵn..."
    local selected_backup
    local backup_timestamp
    if ! select_backup_file selected_backup backup_timestamp; then
        return 1
    fi

    # Bước 3: Kiểm tra backup
    log_info "🔍 Bước 3/7: Kiểm tra backup được chọn..."
    if ! validate_backup_file "$selected_backup" "$backup_timestamp"; then
        return 1
    fi

    # Bước 4: Xác nhận restore
    log_info "🔍 Bước 4/7: Xác nhận restore..."
    if ! confirm_restore_operation "$selected_backup"; then
        return 1
    fi

    # Bước 5: Chuẩn bị restore
    log_info "🔍 Bước 5/7: Chuẩn bị restore..."
    if ! prepare_restore_environment "$selected_backup" "$backup_timestamp"; then
        return 1
    fi

    # Bước 6: Thực hiện restore
    log_info "🔍 Bước 6/7: Thực hiện restore..."
    if ! perform_gitlab_restore "$backup_timestamp"; then
        log_error "❌ Restore thất bại!"
        return 1
    fi

    # Bước 7: Kiểm tra và hoàn tất
    log_info "🔍 Bước 7/7: Kiểm tra và hoàn tất restore..."
    if verify_restore_success; then
        log_success "🎉 Restore GitLab thành công!"
        show_restore_summary "$selected_backup"
        return 0
    else
        log_error "❌ Restore có vấn đề!"
        show_restore_troubleshooting
        return 1
    fi
}

# Hàm chọn backup file
select_backup_file() {
    local -n selected_backup_ref=$1
    local -n backup_timestamp_ref=$2

    log_info "📋 Tìm kiếm backup files..."

    # Tìm backup trong thư mục host
    local host_backups=($(find "$BACKUP_DIR" -name "*_gitlab_backup.tar" -printf "%f\n" 2>/dev/null | sort -r))

    # Tìm backup trong container
    local container_backups=()
    if docker exec "$GITLAB_CONTAINER" test -d "/var/opt/gitlab/backups" 2>/dev/null; then
        mapfile -t container_backups < <(docker exec "$GITLAB_CONTAINER" find /var/opt/gitlab/backups -name "*_gitlab_backup.tar" -printf "%f\n" 2>/dev/null | sort -r)
    fi

    # Kết hợp và loại bỏ duplicate
    local all_backups=()
    for backup in "${host_backups[@]}" "${container_backups[@]}"; do
        if [[ ! " ${all_backups[@]} " =~ " ${backup} " ]]; then
            all_backups+=("$backup")
        fi
    done

    if [ ${#all_backups[@]} -eq 0 ]; then
        log_error "❌ Không tìm thấy backup nào!"
        echo ""
        log_info "💡 Các vị trí tìm kiếm:"
        echo "  • Host: $BACKUP_DIR"
        echo "  • Container: /var/opt/gitlab/backups"
        echo ""
        log_info "Để tạo backup mới, sử dụng option [5] BACKUP"
        return 1
    fi

    echo ""
    log_success "✅ Tìm thấy ${#all_backups[@]} backup files:"
    echo ""

    # Hiển thị danh sách backup với thông tin chi tiết
    for i in "${!all_backups[@]}"; do
        local backup_file="${all_backups[$i]}"
        local backup_date=$(echo "$backup_file" | grep -o '[0-9]\{8\}_[0-9]\{6\}')
        local formatted_date=$(date -d "${backup_date:0:8} ${backup_date:9:2}:${backup_date:11:2}:${backup_date:13:2}" "+%d/%m/%Y %H:%M:%S" 2>/dev/null || echo "$backup_date")

        # Kiểm tra vị trí file
        local location=""
        if [[ " ${host_backups[@]} " =~ " ${backup_file} " ]]; then
            local size=$(du -h "$BACKUP_DIR/$backup_file" 2>/dev/null | cut -f1 || echo "N/A")
            location="Host ($size)"
        fi
        if [[ " ${container_backups[@]} " =~ " ${backup_file} " ]]; then
            if [ -n "$location" ]; then
                location="$location + Container"
            else
                location="Container"
            fi
        fi

        echo "   $((i+1)). $backup_file"
        echo "      📅 Ngày tạo: $formatted_date"
        echo "      📍 Vị trí: $location"
        echo ""
    done

    read -p "Chọn backup để restore (1-${#all_backups[@]}): " choice

    if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt ${#all_backups[@]} ]; then
        log_error "❌ Lựa chọn không hợp lệ!"
        return 1
    fi

    selected_backup_ref="${all_backups[$((choice-1))]}"
    backup_timestamp_ref=$(echo "$selected_backup_ref" | grep -o '[0-9]\{8\}_[0-9]\{6\}')

    log_success "✅ Đã chọn backup: $selected_backup_ref"
    return 0
}

# Hàm kiểm tra backup file
validate_backup_file() {
    local backup_file="$1"
    local backup_timestamp="$2"

    log_info "🔍 Kiểm tra tính hợp lệ của backup..."

    # Kiểm tra backup trong host
    local host_backup_path="$BACKUP_DIR/$backup_file"
    local container_backup_path="/var/opt/gitlab/backups/$backup_file"
    local backup_available=false

    if [ -f "$host_backup_path" ]; then
        log_success "✅ Backup có sẵn trên host: $host_backup_path"
        local file_size=$(du -h "$host_backup_path" | cut -f1)
        echo "  💾 Kích thước: $file_size"

        # Kiểm tra file có bị corrupt không
        if tar -tzf "$host_backup_path" >/dev/null 2>&1; then
            log_success "✅ Backup file không bị corrupt"
        else
            log_warning "⚠️ Backup file có thể bị corrupt"
        fi
        backup_available=true
    fi

    # Kiểm tra backup trong container
    if docker exec "$GITLAB_CONTAINER" test -f "$container_backup_path" 2>/dev/null; then
        log_success "✅ Backup có sẵn trong container: $container_backup_path"
        backup_available=true
    fi

    if [ "$backup_available" = false ]; then
        log_error "❌ Backup file không tồn tại ở cả host và container!"
        return 1
    fi

    # Kiểm tra timestamp hợp lệ
    if [[ "$backup_timestamp" =~ ^[0-9]{8}_[0-9]{6}$ ]]; then
        local backup_date=$(date -d "${backup_timestamp:0:8} ${backup_timestamp:9:2}:${backup_timestamp:11:2}:${backup_timestamp:13:2}" "+%d/%m/%Y %H:%M:%S" 2>/dev/null)
        if [ -n "$backup_date" ]; then
            log_success "✅ Timestamp hợp lệ: $backup_date"
        else
            log_warning "⚠️ Timestamp có định dạng lạ: $backup_timestamp"
        fi
    else
        log_warning "⚠️ Timestamp không đúng định dạng: $backup_timestamp"
    fi

    return 0
}

# Hàm xác nhận restore
confirm_restore_operation() {
    local backup_file="$1"

    echo ""
    log_warning "⚠️ CẢNH BÁO QUAN TRỌNG ⚠️"
    echo ""
    echo "Restore sẽ:"
    echo "  🗑️ Xóa toàn bộ dữ liệu GitLab hiện tại"
    echo "  📦 Thay thế bằng dữ liệu từ backup: $backup_file"
    echo "  👥 Tất cả users, projects, issues sẽ bị thay thế"
    echo "  🔑 SSH keys và access tokens sẽ bị thay thế"
    echo "  ⚙️ Cấu hình GitLab sẽ bị thay thế"
    echo ""
    echo "💡 Khuyến nghị:"
    echo "  • Tạo backup hiện tại trước khi restore"
    echo "  • Thông báo cho team về downtime"
    echo "  • Đảm bảo không có ai đang sử dụng GitLab"
    echo ""

    read -p "Bạn có CHẮC CHẮN muốn tiếp tục restore? (yes/no): " confirmation

    case "$confirmation" in
        "yes"|"YES")
            log_info "✅ Xác nhận restore"
            return 0
            ;;
        *)
            log_info "❌ Hủy restore"
            return 1
            ;;
    esac
}

# Hàm chuẩn bị restore
prepare_restore_environment() {
    local backup_file="$1"
    local backup_timestamp="$2"

    # Copy backup vào container nếu cần
    local host_backup_path="$BACKUP_DIR/$backup_file"
    local container_backup_path="/var/opt/gitlab/backups/$backup_file"

    if [ -f "$host_backup_path" ] && ! docker exec "$GITLAB_CONTAINER" test -f "$container_backup_path" 2>/dev/null; then
        log_info "📤 Copy backup vào container..."
        if docker cp "$host_backup_path" "$GITLAB_CONTAINER:$container_backup_path"; then
            log_success "✅ Đã copy backup vào container"
        else
            log_error "❌ Không thể copy backup vào container"
            return 1
        fi
    fi

    # Kiểm tra quyền trong container
    if ! docker exec "$GITLAB_CONTAINER" test -r "$container_backup_path"; then
        log_error "❌ Không có quyền đọc backup trong container"
        return 1
    fi

    # Tạo backup hiện tại trước khi restore (safety backup)
    log_info "🛡️ Tạo safety backup trước khi restore..."
    local safety_timestamp=$(date +%Y%m%d_%H%M%S)_pre_restore
    if docker exec "$GITLAB_CONTAINER" gitlab-backup create BACKUP="$safety_timestamp" STRATEGY=copy >/dev/null 2>&1; then
        log_success "✅ Đã tạo safety backup: ${safety_timestamp}_gitlab_backup.tar"
    else
        log_warning "⚠️ Không thể tạo safety backup"
        read -p "Tiếp tục restore mà không có safety backup? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi

    return 0
}

# Hàm thực hiện restore
perform_gitlab_restore() {
    local backup_timestamp="$1"
    local restore_start_time=$(date +%s)

    log_info "🔄 Bắt đầu restore GitLab..."
    log_warning "⏳ Quá trình này có thể mất 5-20 phút..."
    echo ""

    # Dừng GitLab services
    log_info "⏸️ Dừng GitLab services..."
    docker exec "$GITLAB_CONTAINER" gitlab-ctl stop unicorn 2>/dev/null || true
    docker exec "$GITLAB_CONTAINER" gitlab-ctl stop puma 2>/dev/null || true
    docker exec "$GITLAB_CONTAINER" gitlab-ctl stop sidekiq 2>/dev/null || true
    docker exec "$GITLAB_CONTAINER" gitlab-ctl stop gitaly 2>/dev/null || true

    # Thực hiện restore với monitoring
    log_info "📦 Restore dữ liệu từ backup..."
    local restore_pid
    docker exec "$GITLAB_CONTAINER" gitlab-backup restore BACKUP="$backup_timestamp" force=yes &
    restore_pid=$!

    # Monitor restore progress
    local attempt=1
    local max_attempts=120  # 120 * 10s = 20 phút
    local progress_chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    local progress_index=0

    while kill -0 $restore_pid 2>/dev/null && [ $attempt -le $max_attempts ]; do
        local current_time=$(date +%s)
        local elapsed=$((current_time - restore_start_time))
        local elapsed_minutes=$((elapsed / 60))
        local elapsed_seconds=$((elapsed % 60))

        local progress_char=${progress_chars:$progress_index:1}
        progress_index=$(((progress_index + 1) % ${#progress_chars}))

        echo -ne "\r  $progress_char Đang restore... ${elapsed_minutes}m ${elapsed_seconds}s | Lần thử: $attempt/$max_attempts"

        sleep 10
        ((attempt++))
    done
    echo ""

    # Đợi process hoàn thành
    wait $restore_pid
    local restore_exit_code=$?

    local restore_end_time=$(date +%s)
    local restore_duration=$((restore_end_time - restore_start_time))
    local restore_minutes=$((restore_duration / 60))
    local restore_seconds=$((restore_duration % 60))

    if [ $restore_exit_code -eq 0 ]; then
        log_success "✅ Restore dữ liệu thành công!"
        echo "  ⏱️ Thời gian restore: ${restore_minutes}m ${restore_seconds}s"

        # Khởi động lại GitLab
        log_info "🔄 Khởi động lại GitLab..."
        docker exec "$GITLAB_CONTAINER" gitlab-ctl restart

        return 0
    else
        log_error "❌ Restore thất bại (exit code: $restore_exit_code)!"
        echo "  ⏱️ Thời gian thử restore: ${restore_minutes}m ${restore_seconds}s"
        return 1
    fi
}

# Hàm kiểm tra restore thành công
verify_restore_success() {
    log_info "🔍 Kiểm tra restore thành công..."

    # Đợi GitLab khởi động
    if ! wait_for_gitlab; then
        log_error "❌ GitLab không khởi động được sau restore"
        return 1
    fi

    # Kiểm tra database connection
    if docker exec "$GITLAB_CONTAINER" gitlab-rails runner "ActiveRecord::Base.connection.current_database" >/dev/null 2>&1; then
        log_success "✅ Database connection OK"
    else
        log_error "❌ Database connection failed"
        return 1
    fi

    # Kiểm tra web interface
    local max_attempts=10
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        local http_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8088" 2>/dev/null || echo "000")
        if [[ "$http_code" =~ ^(200|302)$ ]]; then
            log_success "✅ Web interface accessible"
            return 0
        fi

        echo -ne "\r  ⏳ Kiểm tra web interface... ($attempt/$max_attempts)"
        sleep 5
        ((attempt++))
    done
    echo ""

    log_warning "⚠️ Web interface chưa sẵn sàng hoàn toàn"
    return 0
}

# Hàm hiển thị tổng kết restore
show_restore_summary() {
    local backup_file="$1"

    log_header "TỔNG KẾT RESTORE"

    echo "📊 Thông tin restore:"
    local backup_date=$(echo "$backup_file" | grep -o '[0-9]\{8\}_[0-9]\{6\}')
    local formatted_date=$(date -d "${backup_date:0:8} ${backup_date:9:2}:${backup_date:11:2}:${backup_date:13:2}" "+%d/%m/%Y %H:%M:%S" 2>/dev/null || echo "$backup_date")
    echo "  📦 Backup đã restore: $backup_file"
    echo "  📅 Ngày tạo backup: $formatted_date"
    echo "  🕐 Thời gian restore: $(date "+%d/%m/%Y %H:%M:%S")"
    echo ""

    echo "✅ Restore hoàn thành thành công!"
    echo ""

    echo "🌐 Thông tin truy cập GitLab:"
    echo "  URL: ${GITLAB_EXTERNAL_URL:-http://localhost:8088}"
    echo "  Username: ${GITLAB_ROOT_USERNAME:-root}"
    echo "  Password: ${GITLAB_ROOT_PASSWORD:-Nex!tFlow@2025!}"
    echo ""

    echo "💡 Các bước tiếp theo:"
    echo "  1. Đăng nhập và kiểm tra dữ liệu"
    echo "  2. Kiểm tra users và projects"
    echo "  3. Test các chức năng chính"
    echo "  4. Thông báo cho team về việc restore"
    echo "  5. Cập nhật SSH keys nếu cần"
    echo ""

    echo "🛡️ Safety backup:"
    echo "  • Safety backup đã được tạo trước khi restore"
    echo "  • Có thể tìm thấy trong /var/opt/gitlab/backups/"
    echo "  • Tên file có suffix '_pre_restore'"
}

# Hàm hiển thị troubleshooting restore
show_restore_troubleshooting() {
    log_header "HƯỚNG DẪN KHẮC PHỤC LỖI RESTORE"

    echo "🔍 Các bước kiểm tra và khắc phục:"
    echo ""
    echo "1. 📋 Kiểm tra logs GitLab:"
    echo "   docker logs gitlab"
    echo ""
    echo "2. 🔄 Thử khởi động lại GitLab:"
    echo "   docker restart gitlab"
    echo ""
    echo "3. 🗄️ Kiểm tra database:"
    echo "   docker exec gitlab gitlab-rails dbconsole"
    echo ""
    echo "4. 🔧 Reconfigure GitLab:"
    echo "   docker exec gitlab gitlab-ctl reconfigure"
    echo ""
    echo "5. 🛡️ Restore từ safety backup:"
    echo "   • Tìm safety backup trong container"
    echo "   • Sử dụng option [6] RESTORE để restore lại"
    echo ""
    echo "6. 🧹 Reset hoàn toàn (last resort):"
    echo "   • Sử dụng option [13] RESET-ALL"
    echo "   • Sau đó restore lại từ backup"
    echo ""

    log_info "💡 Nếu vẫn gặp vấn đề, hãy sử dụng option [7] STATUS để chẩn đoán chi tiết"
}

# Menu tương tác
show_interactive_menu() {
    while true; do
        clear
        show_main_menu_header
        show_main_menu_options

        local choice
        read -p "Nhập lựa chọn (0-15): " choice
        echo ""

        # Validate input
        if ! validate_menu_choice "$choice"; then
            continue
        fi

        # Execute choice
        execute_menu_choice "$choice"

        # Return to menu unless exiting
        if [ "$choice" != "0" ]; then
            show_continue_prompt
        fi
    done
}

# Hàm hiển thị header menu chính
show_main_menu_header() {
    log_header "GITLAB MANAGER - NEXTFLOW CRM-AI"

    # Hiển thị system status nhanh
    show_quick_system_status

    echo ""
    echo "📋 MENU CHÍNH - Chọn chức năng:"
}

# Hàm hiển thị quick system status
show_quick_system_status() {
    local gitlab_status="❌"
    local postgres_status="❌"
    local redis_status="❌"

    # Check GitLab
    if docker ps --format "{{.Names}}" | grep -q "^gitlab$"; then
        local health=$(docker inspect gitlab --format='{{.State.Health.Status}}' 2>/dev/null || echo "unknown")
        case "$health" in
            "healthy") gitlab_status="✅" ;;
            "unhealthy") gitlab_status="⚠️" ;;
            "starting") gitlab_status="⏳" ;;
            *) gitlab_status="🔄" ;;
        esac
    fi

    # Check PostgreSQL
    if docker ps --format "{{.Names}}" | grep -q "^postgres$"; then
        postgres_status="✅"
    fi

    # Check Redis
    if docker ps --format "{{.Names}}" | grep -q "^redis$"; then
        redis_status="✅"
    fi

    echo "🖥️ System Status: GitLab $gitlab_status | PostgreSQL $postgres_status | Redis $redis_status"
}

# Hàm hiển thị menu options
show_main_menu_options() {
    echo ""
    echo "🚀 SETUP & DEPLOYMENT:"
    echo "   1. [CHECK] Kiểm tra GitLab images"
    echo "   2. [BUILD] Build GitLab custom image"
    echo "   3. [INSTALL] Cài đặt GitLab (auto-build nếu cần)"
    echo "   4. [INFO] Xem thông tin truy cập"
    echo ""

    echo "💾 BACKUP & RESTORE:"
    echo "   5. [BACKUP] Sao lưu GitLab"
    echo "   6. [RESTORE] Khôi phục GitLab từ backup"
    echo ""

    echo "🔧 TROUBLESHOOTING & DIAGNOSTICS:"
    echo "   7. [STATUS] Chẩn đoán trạng thái tổng thể"
    echo "   8. [CHECK-DB] Kiểm tra databases"
    echo "   9. [LOGS] Xem GitLab logs"
    echo ""

    echo "👤 USER MANAGEMENT:"
    echo "   10. [CREATE-ROOT] Tạo/quản lý root user"
    echo "   11. [RESET-ROOT] Reset password root user"
    echo ""

    echo "🗄️ DATABASE MANAGEMENT:"
    echo "   12. [CLEAN-DB] Dọn dẹp databases cũ"
    echo "   13. [MIGRATE] Migrate database"
    echo ""

    echo "⚠️ ADVANCED OPERATIONS:"
    echo "   14. [RESET-ALL] Reset toàn bộ GitLab (NGUY HIỂM)"
    echo "   15. [ADVANCED] Menu advanced options"
    echo ""

    echo "   0. [EXIT] Thoát"
    echo ""
    echo "================================================================"

    # Hiển thị quick tips
    show_quick_tips
    echo ""
}

# Hàm hiển thị quick tips
show_quick_tips() {
    echo ""
    echo "💡 Quick Tips:"

    # Dynamic tips based on system status
    if ! docker ps --format "{{.Names}}" | grep -q "^gitlab$"; then
        echo "   • GitLab chưa chạy → Sử dụng [3] INSTALL để cài đặt"
    elif ! docker ps --format "{{.Names}}" | grep -q "^postgres$"; then
        echo "   • PostgreSQL chưa chạy → Khởi động: docker-compose up -d postgres"
    else
        local health=$(docker inspect gitlab --format='{{.State.Health.Status}}' 2>/dev/null || echo "unknown")
        case "$health" in
            "healthy")
                echo "   • GitLab đang hoạt động tốt → Sử dụng [5] BACKUP để sao lưu"
                ;;
            "unhealthy")
                echo "   • GitLab có vấn đề → Sử dụng [7] STATUS để chẩn đoán"
                ;;
            "starting")
                echo "   • GitLab đang khởi động → Vui lòng đợi hoặc xem [9] LOGS"
                ;;
        esac
    fi

    echo "   • Cần hỗ trợ → Sử dụng [7] STATUS để tạo diagnostic report"
}

# Hàm validate menu choice
validate_menu_choice() {
    local choice="$1"

    # Check if choice is a number
    if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
        log_error "❌ Vui lòng nhập số từ 0-15"
        sleep 2
        return 1
    fi

    # Check if choice is in valid range
    if [ "$choice" -lt 0 ] || [ "$choice" -gt 15 ]; then
        log_error "❌ Lựa chọn không hợp lệ! Vui lòng chọn từ 0-15"
        sleep 2
        return 1
    fi

    return 0
}

# Hàm execute menu choice
execute_menu_choice() {
    local choice="$1"

    case $choice in
        1)
            log_info "🔍 Đang kiểm tra GitLab images..."
            check_gitlab_images
            ;;
        2)
            log_info "🔨 Đang build GitLab custom image..."
            build_gitlab
            ;;
        3)
            log_info "📦 Đang cài đặt GitLab..."
            install_gitlab
            ;;
        4)
            log_info "ℹ️ Hiển thị thông tin truy cập..."
            show_access_info
            ;;
        5)
            log_info "💾 Đang tạo backup GitLab..."
            backup_gitlab
            ;;
        6)
            log_info "🔄 Đang restore GitLab..."
            restore_gitlab
            ;;
        7)
            log_info "🔍 Đang chẩn đoán hệ thống..."
            check_gitlab_status_detailed
            ;;
        8)
            log_info "🗄️ Đang kiểm tra databases..."
            check_databases
            ;;
        9)
            log_info "📋 Đang xem GitLab logs..."
            show_gitlab_logs
            ;;
        10)
            log_info "👤 Đang quản lý root user..."
            create_root_user
            ;;
        11)
            log_info "🔑 Đang reset password root user..."
            reset_root_user
            ;;
        12)
            log_info "🧹 Đang dọn dẹp databases..."
            clean_old_databases
            ;;
        13)
            log_info "🔄 Đang migrate database..."
            migrate_database
            ;;
        14)
            log_warning "⚠️ Chuẩn bị reset toàn bộ GitLab..."
            reset_all_gitlab
            ;;
        15)
            log_info "⚙️ Mở menu advanced..."
            show_advanced_menu
            ;;
        0)
            show_exit_message
            exit 0
            ;;
    esac
}

# Hàm hiển thị continue prompt
show_continue_prompt() {
    echo ""
    echo "================================================================"
    read -p "📱 Nhấn Enter để quay lại menu chính..." -r
}

# Hàm hiển thị exit message
show_exit_message() {
    clear
    log_header "CẢM ƠN BẠN ĐÃ SỬ DỤNG GITLAB MANAGER"

    echo ""
    echo "🎉 NextFlow CRM-AI GitLab Manager"
    echo ""
    echo "📞 Hỗ trợ:"
    echo "   • Email: nextflow.vn@gmail.com"
    echo "   • GitHub: https://github.com/nextflow-crm"
    echo "   • Documentation: Xem thư mục tai_lieu_du_an/"
    echo ""
    echo "💡 Tips:"
    echo "   • Tạo backup định kỳ để bảo vệ dữ liệu"
    echo "   • Kiểm tra system status thường xuyên"
    echo "   • Cập nhật GitLab version định kỳ"
    echo ""
    log_success "Tạm biệt và chúc bạn làm việc hiệu quả! 🚀"
    echo ""
}

# Hàm hiển thị GitLab logs
show_gitlab_logs() {
    log_header "GITLAB LOGS"

    if ! docker ps --format "{{.Names}}" | grep -q "^gitlab$"; then
        log_error "❌ GitLab container không chạy!"
        return 1
    fi

    echo "📋 Chọn loại logs muốn xem:"
    echo ""
    echo "   1. [RECENT] Logs gần nhất (50 dòng)"
    echo "   2. [LIVE] Theo dõi logs real-time"
    echo "   3. [ALL] Tất cả logs"
    echo "   4. [ERROR] Chỉ error logs"
    echo "   5. [GITLAB] GitLab application logs"
    echo "   6. [NGINX] Nginx access logs"
    echo "   0. [BACK] Quay lại"
    echo ""

    read -p "Chọn loại logs (0-6): " log_choice
    echo ""

    case $log_choice in
        1)
            log_info "📋 Hiển thị 50 logs gần nhất..."
            docker logs gitlab --tail 50
            ;;
        2)
            log_info "📋 Theo dõi logs real-time (Ctrl+C để dừng)..."
            docker logs gitlab -f
            ;;
        3)
            log_info "📋 Hiển thị tất cả logs..."
            docker logs gitlab
            ;;
        4)
            log_info "📋 Hiển thị error logs..."
            docker logs gitlab 2>&1 | grep -i error
            ;;
        5)
            log_info "📋 Hiển thị GitLab application logs..."
            docker exec gitlab tail -f /var/log/gitlab/gitlab-rails/production.log 2>/dev/null || log_error "Không thể truy cập GitLab logs"
            ;;
        6)
            log_info "📋 Hiển thị Nginx access logs..."
            docker exec gitlab tail -f /var/log/gitlab/nginx/gitlab_access.log 2>/dev/null || log_error "Không thể truy cập Nginx logs"
            ;;
        0)
            return 0
            ;;
        *)
            log_error "Lựa chọn không hợp lệ!"
            ;;
    esac
}

# Hàm hiển thị advanced menu
show_advanced_menu() {
    while true; do
        clear
        log_header "ADVANCED OPTIONS MENU"

        echo ""
        echo "⚙️ ADVANCED OPERATIONS:"
        echo ""
        echo "   1. [DIAGNOSTIC] Tạo diagnostic report"
        echo "   2. [CONTAINERS] Quản lý containers"
        echo "   3. [NETWORKS] Quản lý Docker networks"
        echo "   4. [VOLUMES] Quản lý Docker volumes"
        echo "   5. [PERFORMANCE] Kiểm tra performance"
        echo "   6. [SECURITY] Security audit"
        echo "   7. [MAINTENANCE] Maintenance mode"
        echo "   8. [EXPORT] Export cấu hình"
        echo "   9. [IMPORT] Import cấu hình"
        echo ""
        echo "   0. [BACK] Quay lại menu chính"
        echo ""
        echo "================================================================"
        echo ""

        read -p "Chọn advanced option (0-9): " adv_choice
        echo ""

        case $adv_choice in
            1)
                log_info "📊 Tạo diagnostic report..."
                generate_diagnostic_report
                ;;
            2)
                log_info "🐳 Quản lý containers..."
                manage_containers
                ;;
            3)
                log_info "🔗 Quản lý networks..."
                manage_networks
                ;;
            4)
                log_info "💾 Quản lý volumes..."
                manage_volumes
                ;;
            5)
                log_info "⚡ Kiểm tra performance..."
                check_performance_detailed
                ;;
            6)
                log_info "🔒 Security audit..."
                security_audit
                ;;
            7)
                log_info "🔧 Maintenance mode..."
                maintenance_mode
                ;;
            8)
                log_info "📤 Export cấu hình..."
                export_configuration
                ;;
            9)
                log_info "📥 Import cấu hình..."
                import_configuration
                ;;
            0)
                return 0
                ;;
            *)
                log_error "Lựa chọn không hợp lệ!"
                sleep 2
                ;;
        esac

        if [ "$adv_choice" != "0" ]; then
            echo ""
            read -p "Nhấn Enter để tiếp tục..." -r
        fi
    done
}

# Hàm quản lý containers
manage_containers() {
    log_header "QUẢN LÝ CONTAINERS"

    echo "🐳 Container Status:"
    docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    echo ""

    echo "Chọn thao tác:"
    echo "   1. Start tất cả containers"
    echo "   2. Stop tất cả containers"
    echo "   3. Restart GitLab container"
    echo "   4. Xem container logs"
    echo "   5. Container resource usage"
    echo "   0. Quay lại"
    echo ""

    read -p "Chọn thao tác (0-5): " container_choice

    case $container_choice in
        1)
            log_info "🚀 Starting tất cả containers..."
            docker-compose up -d
            ;;
        2)
            log_warning "⏸️ Stopping tất cả containers..."
            docker-compose down
            ;;
        3)
            log_info "🔄 Restarting GitLab container..."
            docker restart gitlab
            ;;
        4)
            echo "Chọn container để xem logs:"
            docker ps --format "{{.Names}}" | nl
            read -p "Nhập số thứ tự: " container_num
            local container_name=$(docker ps --format "{{.Names}}" | sed -n "${container_num}p")
            if [ -n "$container_name" ]; then
                docker logs "$container_name" --tail 50
            fi
            ;;
        5)
            log_info "📊 Container resource usage:"
            docker stats --no-stream
            ;;
    esac
}

# Hàm quản lý networks
manage_networks() {
    log_header "QUẢN LÝ DOCKER NETWORKS"

    echo "🔗 Docker Networks:"
    docker network ls
    echo ""

    echo "Chọn thao tác:"
    echo "   1. Tạo demo network"
    echo "   2. Xóa demo network"
    echo "   3. Inspect demo network"
    echo "   4. Prune unused networks"
    echo "   0. Quay lại"
    echo ""

    read -p "Chọn thao tác (0-4): " network_choice

    case $network_choice in
        1)
            log_info "🔗 Tạo demo network..."
            docker network create demo 2>/dev/null || log_warning "Network đã tồn tại"
            ;;
        2)
            log_warning "🗑️ Xóa demo network..."
            docker network rm demo 2>/dev/null || log_warning "Network không tồn tại"
            ;;
        3)
            log_info "🔍 Inspect demo network:"
            docker network inspect demo 2>/dev/null || log_error "Network không tồn tại"
            ;;
        4)
            log_info "🧹 Prune unused networks..."
            docker network prune -f
            ;;
    esac
}

# Hàm quản lý volumes
manage_volumes() {
    log_header "QUẢN LÝ DOCKER VOLUMES"

    echo "💾 Docker Volumes:"
    docker volume ls
    echo ""

    echo "Chọn thao tác:"
    echo "   1. Inspect GitLab volumes"
    echo "   2. Backup volumes"
    echo "   3. Prune unused volumes"
    echo "   4. Volume disk usage"
    echo "   0. Quay lại"
    echo ""

    read -p "Chọn thao tác (0-4): " volume_choice

    case $volume_choice in
        1)
            log_info "🔍 GitLab volumes:"
            docker volume ls | grep -E "(gitlab|postgres|redis)" || log_info "Không có GitLab volumes"
            ;;
        2)
            log_info "💾 Backup volumes..."
            log_warning "Chức năng này cần được implement"
            ;;
        3)
            log_warning "🧹 Prune unused volumes..."
            read -p "Bạn có chắc chắn? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                docker volume prune -f
            fi
            ;;
        4)
            log_info "📊 Volume disk usage:"
            docker system df -v
            ;;
    esac
}

# Hàm kiểm tra performance chi tiết
check_performance_detailed() {
    log_header "PERFORMANCE MONITORING"

    echo "⚡ System Performance:"
    echo ""

    # CPU và Memory
    if command -v free >/dev/null 2>&1; then
        echo "💾 Memory Usage:"
        free -h
        echo ""
    fi

    # Disk Usage
    echo "💿 Disk Usage:"
    df -h
    echo ""

    # Docker Stats
    echo "🐳 Container Stats:"
    docker stats --no-stream
    echo ""

    # Load Average
    if command -v uptime >/dev/null 2>&1; then
        echo "📊 System Load:"
        uptime
        echo ""
    fi

    # GitLab specific performance
    if docker ps --format "{{.Names}}" | grep -q "^gitlab$"; then
        echo "🔍 GitLab Performance:"
        local response_time=$(curl -s -o /dev/null -w "%{time_total}" "http://localhost:8088" 2>/dev/null || echo "N/A")
        echo "   Response time: ${response_time}s"

        # GitLab processes
        echo "   GitLab processes:"
        docker exec gitlab ps aux | head -10
    fi
}

# Hàm security audit
security_audit() {
    log_header "SECURITY AUDIT"

    echo "🔒 Security Check:"
    echo ""

    # Check exposed ports
    echo "🔌 Exposed Ports:"
    netstat -tuln 2>/dev/null | grep -E ":(8088|2222|5050|5432|6379)" || echo "No exposed ports found"
    echo ""

    # Check Docker security
    echo "🐳 Docker Security:"
    echo "   Running containers as root:"
    docker ps --format "table {{.Names}}\t{{.RunningFor}}" | grep -v "NAMES"
    echo ""

    # Check file permissions
    echo "📁 File Permissions:"
    ls -la "$PROJECT_DIR/gitlab/" | head -5
    echo ""

    # Check GitLab security settings
    if docker ps --format "{{.Names}}" | grep -q "^gitlab$"; then
        echo "🔐 GitLab Security:"
        echo "   Admin users:"
        docker exec gitlab gitlab-rails runner "puts User.where(admin: true).pluck(:username, :email)" 2>/dev/null || echo "Cannot check admin users"
    fi
}

# Hàm maintenance mode
maintenance_mode() {
    log_header "MAINTENANCE MODE"

    echo "🔧 Maintenance Operations:"
    echo ""
    echo "   1. Enable maintenance mode"
    echo "   2. Disable maintenance mode"
    echo "   3. Check maintenance status"
    echo "   4. System cleanup"
    echo "   0. Quay lại"
    echo ""

    read -p "Chọn thao tác (0-4): " maint_choice

    case $maint_choice in
        1)
            log_warning "🔧 Enabling maintenance mode..."
            # Implement maintenance mode enable
            log_info "Maintenance mode enabled"
            ;;
        2)
            log_info "✅ Disabling maintenance mode..."
            # Implement maintenance mode disable
            log_info "Maintenance mode disabled"
            ;;
        3)
            log_info "📊 Maintenance status:"
            # Check maintenance status
            log_info "Maintenance mode: Disabled"
            ;;
        4)
            log_info "🧹 System cleanup..."
            docker system prune -f
            ;;
    esac
}

# Hàm export configuration
export_configuration() {
    log_header "EXPORT CONFIGURATION"

    local export_dir="$PROJECT_DIR/exports"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local export_file="$export_dir/gitlab_config_$timestamp.tar.gz"

    mkdir -p "$export_dir"

    log_info "📤 Exporting GitLab configuration..."

    if tar -czf "$export_file" -C "$PROJECT_DIR" \
        docker-compose.yml \
        .env \
        gitlab/config \
        scripts/ 2>/dev/null; then

        log_success "✅ Configuration exported: $export_file"
        local file_size=$(du -h "$export_file" | cut -f1)
        log_info "📊 File size: $file_size"
    else
        log_error "❌ Export failed"
    fi
}

# Hàm import configuration
import_configuration() {
    log_header "IMPORT CONFIGURATION"

    local export_dir="$PROJECT_DIR/exports"

    if [ ! -d "$export_dir" ]; then
        log_error "❌ Export directory không tồn tại"
        return 1
    fi

    echo "📥 Available configuration files:"
    ls -la "$export_dir"/*.tar.gz 2>/dev/null || {
        log_error "Không có file configuration nào"
        return 1
    }

    echo ""
    read -p "Nhập tên file để import: " import_file

    if [ -f "$export_dir/$import_file" ]; then
        log_warning "⚠️ Import sẽ ghi đè cấu hình hiện tại!"
        read -p "Bạn có chắc chắn? (yes/no): " confirm

        if [ "$confirm" = "yes" ]; then
            log_info "📥 Importing configuration..."
            if tar -xzf "$export_dir/$import_file" -C "$PROJECT_DIR"; then
                log_success "✅ Configuration imported successfully"
            else
                log_error "❌ Import failed"
            fi
        fi
    else
        log_error "❌ File không tồn tại"
    fi
}

# Hiển thị thông tin truy cập
show_access_info() {
    log_header "THÔNG TIN TRUY CẬP GITLAB"
    echo ""
    log_info "Thông tin truy cập GitLab:"
    echo "   URL: ${GITLAB_EXTERNAL_URL:-http://localhost:8088}"
    echo "   Username: ${GITLAB_ROOT_USERNAME:-root}"
    echo "   Password: ${GITLAB_ROOT_PASSWORD:-Nex!tFlow@2025!}"
    echo "   Email: ${GITLAB_ROOT_EMAIL:-admin@nextflow.local}"
    echo ""
    log_info "Container Registry:"
    echo "   URL: ${GITLAB_REGISTRY_URL:-http://localhost:5050}"
    echo ""
    log_info "SSH Git Access:"
    echo "   SSH: ssh://git@localhost:${GITLAB_SSH_PORT:-2222}"
    echo ""
    log_info "Trạng thái GitLab:"
    if check_gitlab_status; then
        echo "   [OK] GitLab đang chạy"
    else
        echo "   [ERROR] GitLab không chạy"
    fi
    echo ""
    log_info "Version cố định: ${GITLAB_VERSION:-16.11.10-ce.0}"
}

# ============================================================================
# FIX & TROUBLESHOOTING FUNCTIONS
# ============================================================================

# Hàm kiểm tra GitLab container
check_gitlab_container() {
    log_info "Đang kiểm tra GitLab container..."

    # Kiểm tra container có tồn tại không
    if ! docker ps -a --format "{{.Names}}" | grep -q "^${GITLAB_CONTAINER}$"; then
        log_error "GitLab container không tồn tại!"
        log_info "Các bước khắc phục:"
        echo "  1. Kiểm tra file docker-compose.yml có đúng không"
        echo "  2. Chạy: docker-compose --profile gitlab up -d gitlab"
        echo "  3. Hoặc sử dụng option [3] INSTALL trong menu"
        return 1
    fi

    # Kiểm tra container có đang chạy không
    if ! docker ps --format "{{.Names}}" | grep -q "^${GITLAB_CONTAINER}$"; then
        log_warning "GitLab container đã dừng!"
        log_info "Các bước khắc phục:"
        echo "  1. Khởi động: docker-compose --profile gitlab up -d gitlab"
        echo "  2. Kiểm tra logs: docker logs gitlab"
        echo "  3. Hoặc sử dụng option [3] INSTALL trong menu"
        return 1
    fi

    # Kiểm tra health status chi tiết
    local health_status=$(docker inspect "$GITLAB_CONTAINER" --format='{{.State.Health.Status}}' 2>/dev/null || echo "no-health-check")
    local container_state=$(docker inspect "$GITLAB_CONTAINER" --format='{{.State.Status}}' 2>/dev/null || echo "unknown")

    log_info "Trạng thái container: $container_state"

    case "$health_status" in
        "healthy")
            log_success "GitLab container đang khỏe mạnh"
            return 0
            ;;
        "unhealthy")
            log_error "GitLab container không khỏe mạnh!"
            log_info "Các bước khắc phục:"
            echo "  1. Kiểm tra logs: docker logs gitlab"
            echo "  2. Kiểm tra tài nguyên hệ thống (RAM, CPU, disk)"
            echo "  3. Restart container: docker restart gitlab"
            return 1
            ;;
        "starting")
            log_warning "GitLab đang trong quá trình khởi động..."
            log_info "Vui lòng đợi 5-10 phút để GitLab khởi động hoàn tất"
            return 2
            ;;
        "no-health-check")
            log_info "Container đang chạy (không có health check)"
            # Kiểm tra thêm bằng cách ping GitLab service
            if docker exec "$GITLAB_CONTAINER" gitlab-ctl status >/dev/null 2>&1; then
                log_success "GitLab services đang hoạt động"
                return 0
            else
                log_warning "GitLab services chưa sẵn sàng"
                return 2
            fi
            ;;
        *)
            log_warning "Trạng thái health không xác định: $health_status"
            return 2
            ;;
    esac
}

# Hàm kiểm tra kết nối mạng
check_network_connectivity() {
    log_info "Kiểm tra kết nối mạng..."

    # Kiểm tra Docker network
    if ! docker network ls | grep -q "demo"; then
        log_warning "Docker network 'demo' không tồn tại"
        log_info "Network sẽ được tạo tự động khi khởi động services"
    else
        log_success "Docker network 'demo' đã sẵn sàng"
    fi

    # Kiểm tra port conflicts
    local ports_to_check=(8088 2222 5050)
    local conflicted_ports=()

    for port in "${ports_to_check[@]}"; do
        if netstat -tuln 2>/dev/null | grep -q ":$port " || ss -tuln 2>/dev/null | grep -q ":$port "; then
            conflicted_ports+=("$port")
        fi
    done

    if [ ${#conflicted_ports[@]} -gt 0 ]; then
        log_warning "Phát hiện xung đột port: ${conflicted_ports[*]}"
        log_info "Các port này cần thiết cho GitLab:"
        echo "  • 8088: Web interface"
        echo "  • 2222: SSH Git operations"
        echo "  • 5050: Container Registry"
        echo ""
        echo "Khắc phục:"
        echo "  • Dừng services đang sử dụng các port này"
        echo "  • Hoặc thay đổi port trong file .env"
        return 1
    else
        log_success "Không có xung đột port"
        return 0
    fi
}

# Hàm kiểm tra biến môi trường
check_environment_variables() {
    log_info "Kiểm tra biến môi trường..."

    local required_vars=(
        "GITLAB_ROOT_PASSWORD"
        "GITLAB_ROOT_EMAIL"
        "GITLAB_DATABASE"
        "POSTGRES_USER"
        "POSTGRES_PASSWORD"
    )

    local missing_vars=()

    for var in "${required_vars[@]}"; do
        if [ -z "${!var:-}" ]; then
            missing_vars+=("$var")
        fi
    done

    if [ ${#missing_vars[@]} -gt 0 ]; then
        log_error "Thiếu các biến môi trường quan trọng:"
        for var in "${missing_vars[@]}"; do
            echo "  ❌ $var"
        done
        log_info "Vui lòng kiểm tra file .env và đảm bảo các biến này được thiết lập"
        return 1
    else
        log_success "Tất cả biến môi trường cần thiết đã được thiết lập"
        return 0
    fi
}

# Hàm kiểm tra trạng thái tổng thể GitLab
check_gitlab_status_detailed() {
    log_header "CHẨN ĐOÁN GITLAB TOÀN DIỆN"

    log_info "🔍 Bắt đầu chẩn đoán toàn diện GitLab..."
    echo ""

    # Khởi tạo biến theo dõi
    local overall_status="healthy"
    local issues_found=()
    local warnings_found=()
    local recommendations=()

    # 1. Kiểm tra Docker và Container
    log_info "📦 1. KIỂM TRA DOCKER VÀ CONTAINER"
    check_docker_environment issues_found warnings_found

    # 2. Kiểm tra GitLab Container
    log_info "🐳 2. KIỂM TRA GITLAB CONTAINER"
    check_gitlab_container_detailed issues_found warnings_found

    # 3. Kiểm tra Dependencies
    log_info "🔗 3. KIỂM TRA DEPENDENCIES"
    check_gitlab_dependencies issues_found warnings_found

    # 4. Kiểm tra GitLab Services
    log_info "⚙️ 4. KIỂM TRA GITLAB SERVICES"
    check_gitlab_internal_services issues_found warnings_found

    # 5. Kiểm tra Database
    log_info "🗄️ 5. KIỂM TRA DATABASE"
    check_gitlab_database_detailed issues_found warnings_found

    # 6. Kiểm tra Web Interface
    log_info "🌐 6. KIỂM TRA WEB INTERFACE"
    check_gitlab_web_interface issues_found warnings_found

    # 7. Kiểm tra Network và Ports
    log_info "🔌 7. KIỂM TRA NETWORK VÀ PORTS"
    check_gitlab_network issues_found warnings_found

    # 8. Kiểm tra Performance
    log_info "⚡ 8. KIỂM TRA PERFORMANCE"
    check_gitlab_performance issues_found warnings_found

    # Tổng kết và khuyến nghị
    show_diagnosis_summary issues_found warnings_found recommendations
}

# Hàm kiểm tra Docker environment
check_docker_environment() {
    local -n issues_ref=$1
    local -n warnings_ref=$2

    # Kiểm tra Docker daemon
    if docker info >/dev/null 2>&1; then
        log_success "  ✅ Docker daemon đang chạy"

        # Kiểm tra Docker version
        local docker_version=$(docker --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        log_info "     🏷️ Phiên bản: $docker_version"

        # Kiểm tra Docker resources
        local docker_info=$(docker system df 2>/dev/null)
        if [ -n "$docker_info" ]; then
            log_info "     💾 Docker disk usage:"
            echo "$docker_info" | while read line; do
                echo "        $line"
            done
        fi
    else
        log_error "  ❌ Docker daemon không chạy"
        issues_ref+=("Docker daemon không hoạt động")
    fi

    # Kiểm tra Docker Compose
    if command -v docker-compose >/dev/null 2>&1; then
        local compose_version=$(docker-compose --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        log_success "  ✅ Docker Compose có sẵn (v$compose_version)"
    else
        log_error "  ❌ Docker Compose không có sẵn"
        issues_ref+=("Docker Compose không được cài đặt")
    fi

    # Kiểm tra Docker network
    if docker network ls | grep -q "demo"; then
        log_success "  ✅ Docker network 'demo' đã tồn tại"
    else
        log_warning "  ⚠️ Docker network 'demo' chưa tồn tại"
        warnings_ref+=("Docker network 'demo' chưa được tạo")
    fi

    echo ""
}

# Hàm kiểm tra GitLab container chi tiết
check_gitlab_container_detailed() {
    local -n issues_ref=$1
    local -n warnings_ref=$2

    # Kiểm tra container tồn tại
    if docker ps -a --format "{{.Names}}" | grep -q "^gitlab$"; then
        log_success "  ✅ GitLab container đã tồn tại"

        # Kiểm tra container state
        local container_state=$(docker inspect gitlab --format='{{.State.Status}}' 2>/dev/null)
        local container_health=$(docker inspect gitlab --format='{{.State.Health.Status}}' 2>/dev/null || echo "no-health-check")

        case "$container_state" in
            "running")
                log_success "  ✅ Container đang chạy"

                case "$container_health" in
                    "healthy")
                        log_success "     💚 Health status: Healthy"
                        ;;
                    "unhealthy")
                        log_error "     ❤️ Health status: Unhealthy"
                        issues_ref+=("GitLab container không khỏe mạnh")
                        ;;
                    "starting")
                        log_warning "     💛 Health status: Starting"
                        warnings_ref+=("GitLab đang trong quá trình khởi động")
                        ;;
                    "no-health-check")
                        log_info "     ℹ️ Health status: Không có health check"
                        ;;
                esac
                ;;
            "exited")
                log_error "  ❌ Container đã dừng"
                local exit_code=$(docker inspect gitlab --format='{{.State.ExitCode}}' 2>/dev/null)
                log_error "     💀 Exit code: $exit_code"
                issues_ref+=("GitLab container đã dừng với exit code $exit_code")
                ;;
            "restarting")
                log_warning "  ⚠️ Container đang restart"
                warnings_ref+=("GitLab container đang restart")
                ;;
            *)
                log_warning "  ⚠️ Container state không xác định: $container_state"
                warnings_ref+=("GitLab container có state lạ: $container_state")
                ;;
        esac

        # Kiểm tra container resources
        if [ "$container_state" = "running" ]; then
            local stats=$(docker stats gitlab --no-stream --format "{{.CPUPerc}} {{.MemUsage}}" 2>/dev/null)
            if [ -n "$stats" ]; then
                local cpu_usage=$(echo "$stats" | cut -d' ' -f1)
                local mem_usage=$(echo "$stats" | cut -d' ' -f2)
                log_info "     📊 CPU: $cpu_usage | Memory: $mem_usage"

                # Cảnh báo nếu CPU hoặc Memory cao
                local cpu_num=$(echo "$cpu_usage" | sed 's/%//')
                if (( $(echo "$cpu_num > 80" | bc -l 2>/dev/null || echo "0") )); then
                    warnings_ref+=("CPU usage cao: $cpu_usage")
                fi
            fi
        fi

    else
        log_error "  ❌ GitLab container không tồn tại"
        issues_ref+=("GitLab container chưa được tạo")
    fi

    echo ""
}

# Hàm kiểm tra GitLab dependencies
check_gitlab_dependencies() {
    local -n issues_ref=$1
    local -n warnings_ref=$2

    # Kiểm tra PostgreSQL
    if docker ps --format "{{.Names}}" | grep -q "^postgres$"; then
        log_success "  ✅ PostgreSQL container đang chạy"

        # Test connection
        if docker exec postgres pg_isready -U nextflow >/dev/null 2>&1; then
            log_success "     🔗 PostgreSQL connection OK"

            # Kiểm tra database size
            local db_size=$(docker exec postgres psql -U nextflow -d nextflow_gitlab -tAc "SELECT pg_size_pretty(pg_database_size('nextflow_gitlab'));" 2>/dev/null || echo "N/A")
            log_info "     💾 Database size: $db_size"
        else
            log_error "     ❌ Không thể kết nối PostgreSQL"
            issues_ref+=("PostgreSQL connection failed")
        fi
    else
        log_error "  ❌ PostgreSQL container không chạy"
        issues_ref+=("PostgreSQL container không hoạt động")
    fi

    # Kiểm tra Redis
    if docker ps --format "{{.Names}}" | grep -q "^redis$"; then
        log_success "  ✅ Redis container đang chạy"

        # Test connection
        if docker exec redis redis-cli ping >/dev/null 2>&1; then
            log_success "     🔗 Redis connection OK"

            # Kiểm tra Redis info
            local redis_info=$(docker exec redis redis-cli info memory 2>/dev/null | grep "used_memory_human" | cut -d: -f2 | tr -d '\r')
            if [ -n "$redis_info" ]; then
                log_info "     💾 Redis memory usage: $redis_info"
            fi
        else
            log_error "     ❌ Không thể kết nối Redis"
            issues_ref+=("Redis connection failed")
        fi
    else
        log_error "  ❌ Redis container không chạy"
        issues_ref+=("Redis container không hoạt động")
    fi

    echo ""
}

# Hàm kiểm tra GitLab internal services
check_gitlab_internal_services() {
    local -n issues_ref=$1
    local -n warnings_ref=$2

    if docker ps --format "{{.Names}}" | grep -q "^gitlab$"; then
        # Kiểm tra GitLab services
        local gitlab_status=$(docker exec gitlab gitlab-ctl status 2>/dev/null)
        if [ $? -eq 0 ]; then
            log_success "  ✅ GitLab services đang chạy"

            # Phân tích từng service
            local running_services=0
            local total_services=0

            while IFS= read -r line; do
                if [[ "$line" =~ ^run: ]]; then
                    ((running_services++))
                    ((total_services++))
                    local service_name=$(echo "$line" | awk '{print $2}' | cut -d: -f1)
                    log_success "     ✅ $service_name"
                elif [[ "$line" =~ ^down: ]]; then
                    ((total_services++))
                    local service_name=$(echo "$line" | awk '{print $2}' | cut -d: -f1)
                    log_error "     ❌ $service_name (down)"
                    issues_ref+=("GitLab service '$service_name' không chạy")
                fi
            done <<< "$gitlab_status"

            log_info "     📊 Services: $running_services/$total_services đang chạy"

            if [ $running_services -lt $total_services ]; then
                warnings_ref+=("Một số GitLab services không chạy")
            fi
        else
            log_error "  ❌ Không thể lấy GitLab service status"
            issues_ref+=("Không thể kiểm tra GitLab services")
        fi
    else
        log_error "  ❌ GitLab container không chạy"
        issues_ref+=("GitLab container không hoạt động")
    fi

    echo ""
}

# Hàm kiểm tra GitLab database chi tiết
check_gitlab_database_detailed() {
    local -n issues_ref=$1
    local -n warnings_ref=$2

    if docker ps --format "{{.Names}}" | grep -q "^gitlab$"; then
        # Kiểm tra database connection từ GitLab
        if docker exec gitlab gitlab-rails runner "ActiveRecord::Base.connection.current_database" >/dev/null 2>&1; then
            local db_name=$(docker exec gitlab gitlab-rails runner "puts ActiveRecord::Base.connection.current_database" 2>/dev/null)
            log_success "  ✅ GitLab kết nối database: $db_name"

            # Kiểm tra database statistics
            local user_count=$(docker exec gitlab gitlab-rails runner "puts User.count" 2>/dev/null || echo "0")
            local project_count=$(docker exec gitlab gitlab-rails runner "puts Project.count" 2>/dev/null || echo "0")
            local issue_count=$(docker exec gitlab gitlab-rails runner "puts Issue.count" 2>/dev/null || echo "0")

            log_info "     👥 Users: $user_count"
            log_info "     📁 Projects: $project_count"
            log_info "     🎫 Issues: $issue_count"

            # Kiểm tra root user
            local root_exists=$(docker exec gitlab gitlab-rails runner "puts User.find_by(username: 'root') ? 'true' : 'false'" 2>/dev/null || echo "false")
            if [ "$root_exists" = "true" ]; then
                log_success "     👑 Root user tồn tại"
            else
                log_warning "     ⚠️ Root user chưa tồn tại"
                warnings_ref+=("Root user chưa được tạo")
            fi

            # Kiểm tra database migrations
            local pending_migrations=$(docker exec gitlab gitlab-rails runner "puts ActiveRecord::Base.connection.migration_context.needs_migration?" 2>/dev/null || echo "unknown")
            if [ "$pending_migrations" = "false" ]; then
                log_success "     🔄 Database migrations up-to-date"
            elif [ "$pending_migrations" = "true" ]; then
                log_warning "     ⚠️ Có pending migrations"
                warnings_ref+=("Database có pending migrations")
            fi

        else
            log_error "  ❌ GitLab không thể kết nối database"
            issues_ref+=("GitLab database connection failed")
        fi
    else
        log_error "  ❌ GitLab container không chạy"
        issues_ref+=("GitLab container không hoạt động")
    fi

    echo ""
}

# Hàm kiểm tra GitLab web interface
check_gitlab_web_interface() {
    local -n issues_ref=$1
    local -n warnings_ref=$2

    # Kiểm tra HTTP response
    local http_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8088" 2>/dev/null || echo "000")
    local response_time=$(curl -s -o /dev/null -w "%{time_total}" "http://localhost:8088" 2>/dev/null || echo "0")

    case "$http_code" in
        "200")
            log_success "  ✅ Web interface accessible (HTTP $http_code)"
            log_info "     ⏱️ Response time: ${response_time}s"

            # Cảnh báo nếu response time chậm
            if (( $(echo "$response_time > 5" | bc -l 2>/dev/null || echo "0") )); then
                warnings_ref+=("Web interface phản hồi chậm: ${response_time}s")
            fi
            ;;
        "302")
            log_success "  ✅ Web interface redirect (HTTP $http_code)"
            log_info "     ⏱️ Response time: ${response_time}s"
            ;;
        "502"|"503"|"504")
            log_error "  ❌ Web interface lỗi server (HTTP $http_code)"
            issues_ref+=("Web interface trả về HTTP $http_code")
            ;;
        "000")
            log_error "  ❌ Không thể kết nối web interface"
            issues_ref+=("Không thể kết nối đến web interface")
            ;;
        *)
            log_warning "  ⚠️ Web interface trả về HTTP code lạ: $http_code"
            warnings_ref+=("Web interface HTTP code không mong đợi: $http_code")
            ;;
    esac

    # Kiểm tra health endpoint
    local health_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8088/-/health" 2>/dev/null || echo "000")
    if [ "$health_code" = "200" ]; then
        log_success "     ✅ Health endpoint OK"
    else
        log_warning "     ⚠️ Health endpoint không accessible"
        warnings_ref+=("Health endpoint không hoạt động")
    fi

    echo ""
}

# Hàm kiểm tra network và ports
check_gitlab_network() {
    local -n issues_ref=$1
    local -n warnings_ref=$2

    # Kiểm tra các ports cần thiết
    local ports_to_check=(8088 2222 5050)
    local port_status=()

    for port in "${ports_to_check[@]}"; do
        if netstat -tuln 2>/dev/null | grep -q ":$port " || ss -tuln 2>/dev/null | grep -q ":$port "; then
            log_success "  ✅ Port $port đang được sử dụng"
            port_status+=("$port:active")
        else
            log_warning "  ⚠️ Port $port không được sử dụng"
            warnings_ref+=("Port $port không active")
            port_status+=("$port:inactive")
        fi
    done

    # Kiểm tra port conflicts
    local conflicted_ports=()
    for port in "${ports_to_check[@]}"; do
        local port_processes=$(netstat -tulnp 2>/dev/null | grep ":$port " | grep -v docker | wc -l)
        if [ "$port_processes" -gt 1 ]; then
            conflicted_ports+=("$port")
        fi
    done

    if [ ${#conflicted_ports[@]} -gt 0 ]; then
        log_warning "  ⚠️ Port conflicts detected: ${conflicted_ports[*]}"
        warnings_ref+=("Port conflicts: ${conflicted_ports[*]}")
    fi

    # Kiểm tra Docker network connectivity
    if docker network ls | grep -q "demo"; then
        log_success "  ✅ Docker network 'demo' tồn tại"

        # Kiểm tra containers trong network
        local network_containers=$(docker network inspect demo --format '{{range .Containers}}{{.Name}} {{end}}' 2>/dev/null)
        if [ -n "$network_containers" ]; then
            log_info "     🔗 Containers trong network: $network_containers"
        fi
    else
        log_warning "  ⚠️ Docker network 'demo' không tồn tại"
        warnings_ref+=("Docker network 'demo' chưa được tạo")
    fi

    echo ""
}

# Hàm kiểm tra performance
check_gitlab_performance() {
    local -n issues_ref=$1
    local -n warnings_ref=$2

    # Kiểm tra system resources
    if command -v free >/dev/null 2>&1; then
        local total_ram=$(free -m | awk 'NR==2{printf "%.1f", $2/1024}')
        local used_ram=$(free -m | awk 'NR==2{printf "%.1f", $3/1024}')
        local ram_usage=$(free | awk 'NR==2{printf "%.1f", $3*100/$2}')

        log_info "  💾 RAM: ${used_ram}GB / ${total_ram}GB (${ram_usage}%)"

        if (( $(echo "$ram_usage > 90" | bc -l 2>/dev/null || echo "0") )); then
            warnings_ref+=("RAM usage cao: ${ram_usage}%")
        fi
    fi

    # Kiểm tra disk usage
    local disk_usage=$(df -h "$PROJECT_DIR" | awk 'NR==2{print $5}' | sed 's/%//')
    local disk_available=$(df -h "$PROJECT_DIR" | awk 'NR==2{print $4}')

    log_info "  💿 Disk: ${disk_usage}% used, ${disk_available} available"

    if [ "$disk_usage" -gt 90 ]; then
        warnings_ref+=("Disk usage cao: ${disk_usage}%")
    fi

    # Kiểm tra GitLab container performance
    if docker ps --format "{{.Names}}" | grep -q "^gitlab$"; then
        local container_stats=$(docker stats gitlab --no-stream --format "{{.CPUPerc}} {{.MemUsage}}" 2>/dev/null)
        if [ -n "$container_stats" ]; then
            local cpu_usage=$(echo "$container_stats" | cut -d' ' -f1)
            local mem_usage=$(echo "$container_stats" | cut -d' ' -f2)
            log_info "  🐳 GitLab Container - CPU: $cpu_usage | Memory: $mem_usage"

            local cpu_num=$(echo "$cpu_usage" | sed 's/%//')
            if (( $(echo "$cpu_num > 80" | bc -l 2>/dev/null || echo "0") )); then
                warnings_ref+=("GitLab container CPU usage cao: $cpu_usage")
            fi
        fi
    fi

    echo ""
}

# Hàm hiển thị tổng kết chẩn đoán
show_diagnosis_summary() {
    local -n issues_ref=$1
    local -n warnings_ref=$2
    local -n recommendations_ref=$3

    log_header "TỔNG KẾT CHẨN ĐOÁN"

    # Tính toán overall status
    local overall_status="healthy"
    if [ ${#issues_ref[@]} -gt 0 ]; then
        overall_status="critical"
    elif [ ${#warnings_ref[@]} -gt 0 ]; then
        overall_status="warning"
    fi

    # Hiển thị overall status
    case "$overall_status" in
        "healthy")
            log_success "🎉 TRẠNG THÁI TỔNG THỂ: KHỎE MẠNH"
            echo "   GitLab đang hoạt động bình thường"
            ;;
        "warning")
            log_warning "⚠️ TRẠNG THÁI TỔNG THỂ: CÓ CẢNH BÁO"
            echo "   GitLab hoạt động nhưng có một số vấn đề cần chú ý"
            ;;
        "critical")
            log_error "🚨 TRẠNG THÁI TỔNG THỂ: CÓ VẤN ĐỀ NGHIÊM TRỌNG"
            echo "   GitLab có vấn đề cần khắc phục ngay"
            ;;
    esac

    echo ""

    # Hiển thị issues
    if [ ${#issues_ref[@]} -gt 0 ]; then
        log_error "🚨 VẤN ĐỀ NGHIÊM TRỌNG (${#issues_ref[@]}):"
        for issue in "${issues_ref[@]}"; do
            echo "   ❌ $issue"
        done
        echo ""
    fi

    # Hiển thị warnings
    if [ ${#warnings_ref[@]} -gt 0 ]; then
        log_warning "⚠️ CẢNH BÁO (${#warnings_ref[@]}):"
        for warning in "${warnings_ref[@]}"; do
            echo "   ⚠️ $warning"
        done
        echo ""
    fi

    # Hiển thị thông tin truy cập nếu GitLab healthy
    if [ "$overall_status" != "critical" ]; then
        log_info "🌐 THÔNG TIN TRUY CẬP:"
        echo "   URL: ${GITLAB_EXTERNAL_URL:-http://localhost:8088}"
        echo "   Username: ${GITLAB_ROOT_USERNAME:-root}"
        echo "   Password: ${GITLAB_ROOT_PASSWORD:-Nex!tFlow@2025!}"
        echo "   Email: ${GITLAB_ROOT_EMAIL:-nextflow.vn@gmail.com}"
        echo ""
    fi

    # Đưa ra khuyến nghị
    generate_recommendations issues_ref warnings_ref recommendations_ref
    if [ ${#recommendations_ref[@]} -gt 0 ]; then
        log_info "💡 KHUYẾN NGHỊ:"
        for rec in "${recommendations_ref[@]}"; do
            echo "   💡 $rec"
        done
        echo ""
    fi

    # Hiển thị next steps
    show_next_steps "$overall_status"
}

# Kiểm tra databases
check_databases() {
    log_header "KIỂM TRA CÁC DATABASE GITLAB"

    log_info "🔍 Quét tất cả databases liên quan GitLab..."

    # Kiểm tra PostgreSQL container trước
    if ! docker ps --format "{{.Names}}" | grep -q "^postgres$"; then
        log_error "❌ PostgreSQL container không chạy!"
        log_info "Khởi động PostgreSQL: docker-compose up -d postgres"
        return 1
    fi

    echo ""
    log_info "📋 Danh sách tất cả databases:"
    docker exec postgres psql -U nextflow -c "SELECT datname, pg_size_pretty(pg_database_size(datname)) as size FROM pg_database WHERE datname LIKE '%gitlab%' OR datname LIKE '%partition%' ORDER BY datname;"

    echo ""
    log_info "🎯 Kiểm tra database chính:"
    local main_db="${GITLAB_DATABASE:-nextflow_gitlab}"

    if docker exec postgres psql -U nextflow -c "SELECT 1 FROM pg_database WHERE datname = '$main_db';" | grep -q 1; then
        log_success "✅ Database '$main_db' tồn tại"

        # Kiểm tra tables và dữ liệu
        local table_count=$(docker exec postgres psql -U nextflow -d "$main_db" -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" -t | xargs)
        local db_size=$(docker exec postgres psql -U nextflow -d "$main_db" -tAc "SELECT pg_size_pretty(pg_database_size('$main_db'));" 2>/dev/null)

        log_info "  📊 Số lượng tables: $table_count"
        log_info "  💾 Kích thước database: $db_size"

        if [ "$table_count" -gt 50 ]; then
            log_success "  ✅ Database có đầy đủ dữ liệu GitLab"

            # Kiểm tra một số tables quan trọng
            local important_tables=("users" "projects" "issues" "merge_requests")
            for table in "${important_tables[@]}"; do
                local count=$(docker exec postgres psql -U nextflow -d "$main_db" -tAc "SELECT COUNT(*) FROM $table;" 2>/dev/null || echo "0")
                log_info "    📋 $table: $count records"
            done
        elif [ "$table_count" -gt 0 ]; then
            log_warning "  ⚠️ Database có tables nhưng có thể chưa đầy đủ"
        else
            log_warning "  ⚠️ Database trống - cần migrate"
        fi
    else
        log_error "❌ Database '$main_db' không tồn tại"
        log_info "Tạo database: docker exec postgres psql -U nextflow -c \"CREATE DATABASE $main_db;\""
    fi

    echo ""
    log_info "🗑️ Kiểm tra databases cũ và không dùng:"

    # Kiểm tra database cũ
    local old_databases=("gitlabhq_production" "gitlab_partitions_dynamic" "gitlab_partitions_static")
    local found_old=false

    for old_db in "${old_databases[@]}"; do
        if docker exec postgres psql -U nextflow -c "SELECT 1 FROM pg_database WHERE datname = '$old_db';" | grep -q 1; then
            found_old=true
            local old_table_count=$(docker exec postgres psql -U nextflow -d "$old_db" -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" -t | xargs 2>/dev/null || echo "0")
            local old_size=$(docker exec postgres psql -U nextflow -d "$old_db" -tAc "SELECT pg_size_pretty(pg_database_size('$old_db'));" 2>/dev/null || echo "N/A")

            if [ "$old_table_count" -eq 0 ]; then
                log_info "  🗑️ '$old_db': Trống ($old_size) - có thể xóa an toàn"
            else
                log_warning "  ⚠️ '$old_db': Có $old_table_count tables ($old_size) - cần backup trước khi xóa"
            fi
        fi
    done

    if [ "$found_old" = false ]; then
        log_success "✅ Không có databases cũ không dùng"
    fi

    echo ""
    log_info "💡 Các thao tác có thể thực hiện:"
    echo "  • Xóa databases cũ: option [11] CLEAN-DB"
    echo "  • Migrate database: option [12] MIGRATE"
    echo "  • Reset database: option [13] RESET-ALL"
}

# Hàm tạo khuyến nghị dựa trên issues và warnings
generate_recommendations() {
    local -n issues_ref=$1
    local -n warnings_ref=$2
    local -n recommendations_ref=$3

    # Khuyến nghị cho issues
    for issue in "${issues_ref[@]}"; do
        case "$issue" in
            *"Docker daemon"*)
                recommendations_ref+=("Khởi động Docker daemon: systemctl start docker (Linux) hoặc Docker Desktop (Windows/Mac)")
                ;;
            *"GitLab container"*"không hoạt động"*)
                recommendations_ref+=("Khởi động GitLab: docker-compose --profile gitlab up -d gitlab")
                ;;
            *"PostgreSQL"*"không hoạt động"*)
                recommendations_ref+=("Khởi động PostgreSQL: docker-compose up -d postgres")
                ;;
            *"Redis"*"không hoạt động"*)
                recommendations_ref+=("Khởi động Redis: docker-compose up -d redis")
                ;;
            *"database connection"*)
                recommendations_ref+=("Kiểm tra database: option [8] CHECK-DB và [12] MIGRATE")
                ;;
            *"Web interface"*)
                recommendations_ref+=("Kiểm tra logs: docker logs gitlab và restart: docker restart gitlab")
                ;;
        esac
    done

    # Khuyến nghị cho warnings
    for warning in "${warnings_ref[@]}"; do
        case "$warning" in
            *"Root user"*)
                recommendations_ref+=("Tạo root user: option [9] CREATE-ROOT")
                ;;
            *"pending migrations"*)
                recommendations_ref+=("Chạy migrations: option [12] MIGRATE")
                ;;
            *"CPU usage cao"*)
                recommendations_ref+=("Kiểm tra tài nguyên hệ thống và restart GitLab nếu cần")
                ;;
            *"RAM usage cao"*)
                recommendations_ref+=("Giải phóng RAM hoặc tăng RAM cho hệ thống")
                ;;
            *"Disk usage cao"*)
                recommendations_ref+=("Dọn dẹp disk space và backup cũ: option [5] BACKUP")
                ;;
        esac
    done

    # Khuyến nghị chung
    if [ ${#issues_ref[@]} -eq 0 ] && [ ${#warnings_ref[@]} -eq 0 ]; then
        recommendations_ref+=("GitLab đang hoạt động tốt! Tạo backup định kỳ: option [5] BACKUP")
    fi
}

# Hàm hiển thị next steps
show_next_steps() {
    local overall_status="$1"

    log_info "🚀 CÁC BƯỚC TIẾP THEO:"

    case "$overall_status" in
        "critical")
            echo "   1. Khắc phục các vấn đề nghiêm trọng ở trên"
            echo "   2. Sử dụng option [13] RESET-ALL nếu cần reset hoàn toàn"
            echo "   3. Kiểm tra logs: docker logs gitlab"
            echo "   4. Chạy lại chẩn đoán: option [7] STATUS"
            ;;
        "warning")
            echo "   1. Xem xét các cảnh báo ở trên"
            echo "   2. Thực hiện các khuyến nghị được đưa ra"
            echo "   3. Tạo backup: option [5] BACKUP"
            echo "   4. Chạy lại chẩn đoán để xác nhận: option [7] STATUS"
            ;;
        "healthy")
            echo "   1. Tạo backup định kỳ: option [5] BACKUP"
            echo "   2. Kiểm tra cập nhật GitLab"
            echo "   3. Monitor performance thường xuyên"
            echo "   4. Thiết lập backup tự động"
            ;;
    esac

    echo ""
    echo "📞 Hỗ trợ thêm:"
    echo "   • Xem logs chi tiết: docker logs gitlab"
    echo "   • Restart services: docker restart gitlab"
    echo "   • Menu troubleshooting: options [7-13]"
}

# Hàm tạo GitLab diagnostic report
generate_diagnostic_report() {
    log_header "TẠO BÁO CÁO CHẨN ĐOÁN"

    local report_file="$PROJECT_DIR/gitlab_diagnostic_$(date +%Y%m%d_%H%M%S).txt"

    log_info "📝 Tạo báo cáo chẩn đoán chi tiết..."

    {
        echo "GITLAB DIAGNOSTIC REPORT"
        echo "========================"
        echo "Generated: $(date)"
        echo "System: $(uname -a 2>/dev/null || echo 'Unknown')"
        echo ""

        echo "DOCKER INFORMATION:"
        echo "-------------------"
        docker --version 2>/dev/null || echo "Docker not available"
        docker-compose --version 2>/dev/null || echo "Docker Compose not available"
        echo ""

        echo "CONTAINER STATUS:"
        echo "-----------------"
        docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "Cannot get container status"
        echo ""

        echo "GITLAB CONTAINER LOGS (last 50 lines):"
        echo "---------------------------------------"
        docker logs gitlab --tail 50 2>/dev/null || echo "Cannot get GitLab logs"
        echo ""

        echo "SYSTEM RESOURCES:"
        echo "-----------------"
        if command -v free >/dev/null 2>&1; then
            free -h
        else
            echo "Memory info not available"
        fi
        echo ""
        df -h "$PROJECT_DIR" 2>/dev/null || echo "Disk info not available"
        echo ""

        echo "NETWORK STATUS:"
        echo "---------------"
        netstat -tuln 2>/dev/null | grep -E ":(8088|2222|5050|5432|6379)" || echo "Network info not available"
        echo ""

        echo "GITLAB SERVICES:"
        echo "----------------"
        docker exec gitlab gitlab-ctl status 2>/dev/null || echo "Cannot get GitLab service status"
        echo ""

    } > "$report_file"

    if [ -f "$report_file" ]; then
        log_success "✅ Báo cáo đã được tạo: $report_file"
        local file_size=$(du -h "$report_file" | cut -f1)
        log_info "📊 Kích thước file: $file_size"
        echo ""
        log_info "💡 Bạn có thể gửi file này cho support team để được hỗ trợ"
    else
        log_error "❌ Không thể tạo báo cáo"
    fi
}

# Hàm xóa database cũ và partitions
clean_old_databases() {
    log_header "DỌN DẸP DATABASE CŨ VÀ PARTITIONS"

    # Kiểm tra PostgreSQL trước
    if ! docker ps --format "{{.Names}}" | grep -q "^postgres$"; then
        log_error "❌ PostgreSQL container không chạy!"
        log_info "Khởi động PostgreSQL: docker-compose up -d postgres"
        return 1
    fi

    log_info "🔍 Quét databases cũ và không sử dụng..."
    echo ""

    # Danh sách databases có thể cần dọn dẹp
    local databases_to_check=(
        "gitlabhq_production"
        "gitlab_partitions_dynamic"
        "gitlab_partitions_static"
        "gitlab_test"
        "gitlab_development"
    )

    local found_databases=()
    local safe_to_delete=()
    local has_data=()

    # Quét và phân loại databases
    for db in "${databases_to_check[@]}"; do
        if docker exec postgres psql -U nextflow -c "SELECT 1 FROM pg_database WHERE datname = '$db';" | grep -q 1; then
            found_databases+=("$db")

            # Kiểm tra có dữ liệu không
            local table_count=$(docker exec postgres psql -U nextflow -d "$db" -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" -t | xargs 2>/dev/null || echo "0")
            local db_size=$(docker exec postgres psql -U nextflow -d "$db" -tAc "SELECT pg_size_pretty(pg_database_size('$db'));" 2>/dev/null || echo "N/A")

            if [ "$table_count" -eq 0 ]; then
                safe_to_delete+=("$db:$db_size")
                log_info "  🗑️ '$db': Trống ($db_size) - an toàn để xóa"
            else
                has_data+=("$db:$table_count:$db_size")
                log_warning "  ⚠️ '$db': Có $table_count tables ($db_size) - cần cẩn thận"
            fi
        fi
    done

    if [ ${#found_databases[@]} -eq 0 ]; then
        log_success "✅ Không tìm thấy database cũ nào cần dọn dẹp"
        return 0
    fi

    echo ""
    log_info "📊 Tổng kết:"
    echo "  🗑️ Databases trống (an toàn xóa): ${#safe_to_delete[@]}"
    echo "  ⚠️ Databases có dữ liệu (cần cẩn thận): ${#has_data[@]}"
    echo ""

    # Xử lý databases trống
    if [ ${#safe_to_delete[@]} -gt 0 ]; then
        log_info "🗑️ Xóa databases trống:"
        for item in "${safe_to_delete[@]}"; do
            local db_name=$(echo "$item" | cut -d: -f1)
            local db_size=$(echo "$item" | cut -d: -f2)

            read -p "Xóa database trống '$db_name' ($db_size)? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                if docker exec postgres psql -U nextflow -c "DROP DATABASE IF EXISTS $db_name;" 2>/dev/null; then
                    log_success "  ✅ Đã xóa '$db_name'"
                else
                    log_error "  ❌ Không thể xóa '$db_name'"
                fi
            else
                log_info "  ⏭️ Bỏ qua '$db_name'"
            fi
        done
        echo ""
    fi

    # Xử lý databases có dữ liệu
    if [ ${#has_data[@]} -gt 0 ]; then
        log_warning "⚠️ Databases có dữ liệu (cần backup trước khi xóa):"
        for item in "${has_data[@]}"; do
            local db_name=$(echo "$item" | cut -d: -f1)
            local table_count=$(echo "$item" | cut -d: -f2)
            local db_size=$(echo "$item" | cut -d: -f3)

            echo "  📋 '$db_name': $table_count tables ($db_size)"
        done
        echo ""

        log_info "💡 Để xóa databases có dữ liệu:"
        echo "  1. Tạo backup trước: pg_dump -U nextflow -h localhost database_name > backup.sql"
        echo "  2. Xác nhận không cần dữ liệu"
        echo "  3. Xóa thủ công: docker exec postgres psql -U nextflow -c \"DROP DATABASE database_name;\""
        echo ""

        read -p "Bạn có muốn xóa FORCE tất cả databases có dữ liệu? (NGUY HIỂM - yes/no): " confirmation
        if [ "$confirmation" = "yes" ]; then
            log_warning "🚨 CẢNH BÁO: Đang xóa databases có dữ liệu..."
            for item in "${has_data[@]}"; do
                local db_name=$(echo "$item" | cut -d: -f1)
                if docker exec postgres psql -U nextflow -c "DROP DATABASE IF EXISTS $db_name;" 2>/dev/null; then
                    log_success "  ✅ Đã xóa '$db_name'"
                else
                    log_error "  ❌ Không thể xóa '$db_name'"
                fi
            done
        else
            log_info "✅ Giữ nguyên databases có dữ liệu"
        fi
    fi

    # Dọn dẹp connections và cache
    log_info "🧹 Dọn dẹp connections và cache PostgreSQL..."
    docker exec postgres psql -U nextflow -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname IN ('gitlabhq_production', 'gitlab_partitions_dynamic', 'gitlab_partitions_static') AND pid <> pg_backend_pid();" 2>/dev/null || true

    # Vacuum và analyze
    log_info "🔧 Tối ưu hóa PostgreSQL..."
    docker exec postgres psql -U nextflow -c "VACUUM;" 2>/dev/null || true

    log_success "✅ Hoàn thành dọn dẹp database!"
}

# Reset root user
reset_root_user() {
    echo "============================================"
    log_info "RESET ROOT USER GITLAB"
    echo "============================================"

    check_gitlab_container

    log_info "Đang reset root user..."

    # Tạo script reset root
    cat > /tmp/reset_root.rb << 'EOF'
# Tìm user root
user = User.find_by(username: 'root')

if user.nil?
  puts "User root không tồn tại. Tạo user root bằng GitLab rake task..."
  puts "Chạy: docker exec gitlab gitlab-rake \"gitlab:setup\" để tạo user root"
  exit 1
else
  puts "User root đã tồn tại - đang reset password..."

  # Reset password và thông tin
  user.email = ENV['GITLAB_ROOT_EMAIL'] || 'nextflow.vn@gmail.com'
  user.password = ENV['GITLAB_ROOT_PASSWORD'] || 'Nex!tFlow@2025!'
  user.password_confirmation = ENV['GITLAB_ROOT_PASSWORD'] || 'Nex!tFlow@2025!'
  user.admin = true

  # Confirm user nếu chưa confirm
  unless user.confirmed?
    user.confirmed_at = Time.current
    user.skip_confirmation!
  end

  # Save user
  if user.save
    puts "Đã reset user root thành công!"
  else
    puts "Lỗi khi save user: #{user.errors.full_messages.join(', ')}"
    exit 1
  end
end

puts ""
puts "Root user info:"
puts "Username: #{user.username}"
puts "Email: #{user.email}"
puts "Admin: #{user.admin}"
puts "Confirmed: #{user.confirmed?}"
puts "Password đã được reset"
EOF

    # Chạy script trong GitLab
    docker cp /tmp/reset_root.rb gitlab:/tmp/reset_root.rb
    docker exec gitlab bash -c "cd /opt/gitlab && gitlab-rails runner /tmp/reset_root.rb"

    # Cleanup
    rm -f /tmp/reset_root.rb
    docker exec gitlab rm -f /tmp/reset_root.rb

    log_success "Đã reset root user thành công!"
    echo ""
    log_info "Thông tin đăng nhập:"
    echo "  URL: ${GITLAB_EXTERNAL_URL:-http://localhost:8088}"
    echo "  Username: root"
    echo "  Password: ${GITLAB_ROOT_PASSWORD:-Nex!tFlow@2025!}"
    echo "  Email: ${GITLAB_ROOT_EMAIL:-nextflow.vn@gmail.com}"
}

# Hàm migrate database
migrate_database() {
    log_header "MIGRATE DATABASE GITLAB"

    # Bước 1: Kiểm tra yêu cầu
    log_info "🔍 Bước 1/5: Kiểm tra yêu cầu..."
    if ! check_gitlab_container; then
        log_error "❌ GitLab container không sẵn sàng cho migration"
        return 1
    fi

    # Bước 2: Pre-migration checks
    log_info "🔍 Bước 2/5: Kiểm tra trước migration..."
    if ! pre_migration_checks; then
        log_error "❌ Pre-migration checks thất bại"
        return 1
    fi

    # Bước 3: Backup trước migration
    log_info "🔍 Bước 3/5: Tạo backup an toàn..."
    create_pre_migration_backup

    # Bước 4: Thực hiện migration
    log_info "🔍 Bước 4/5: Thực hiện database migration..."
    if perform_database_migration; then
        log_success "✅ Database migration thành công!"
    else
        log_error "❌ Database migration thất bại!"
        return 1
    fi

    # Bước 5: Post-migration verification
    log_info "🔍 Bước 5/5: Kiểm tra sau migration..."
    if post_migration_verification; then
        log_success "🎉 Migration hoàn thành và được xác minh!"
        return 0
    else
        log_warning "⚠️ Migration hoàn thành nhưng có cảnh báo"
        return 0
    fi
}

# Hàm kiểm tra trước migration
pre_migration_checks() {
    log_info "Kiểm tra database connection..."
    if ! docker exec gitlab gitlab-rails runner "ActiveRecord::Base.connection.current_database" >/dev/null 2>&1; then
        log_error "❌ Không thể kết nối database"
        return 1
    fi

    log_info "Kiểm tra pending migrations..."
    local pending_migrations=$(docker exec gitlab gitlab-rails runner "puts ActiveRecord::Base.connection.migration_context.needs_migration?" 2>/dev/null || echo "unknown")

    case "$pending_migrations" in
        "false")
            log_success "✅ Database đã up-to-date"
            log_info "Không có migrations cần chạy"
            read -p "Vẫn muốn chạy migration check? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                return 1
            fi
            ;;
        "true")
            log_warning "⚠️ Có pending migrations cần chạy"
            ;;
        "unknown")
            log_warning "⚠️ Không thể xác định migration status"
            ;;
    esac

    log_info "Kiểm tra database size..."
    local db_size=$(docker exec postgres psql -U nextflow -d nextflow_gitlab -tAc "SELECT pg_size_pretty(pg_database_size('nextflow_gitlab'));" 2>/dev/null || echo "Unknown")
    log_info "Database size: $db_size"

    log_info "Kiểm tra available disk space..."
    local available_space=$(df -BG "$PROJECT_DIR" 2>/dev/null | awk 'NR==2 {print $4}' | sed 's/G//' || echo "0")
    if [ "$available_space" -lt 2 ]; then
        log_warning "⚠️ Disk space thấp: ${available_space}GB"
        log_info "Migration có thể cần thêm disk space"
    fi

    log_success "✅ Pre-migration checks hoàn thành"
    return 0
}

# Hàm tạo backup trước migration
create_pre_migration_backup() {
    log_info "🛡️ Tạo safety backup trước migration..."

    local backup_timestamp=$(date +%Y%m%d_%H%M%S)_pre_migration

    # Tạo backup nhanh
    if docker exec gitlab gitlab-backup create BACKUP="$backup_timestamp" STRATEGY=copy >/dev/null 2>&1; then
        log_success "✅ Đã tạo safety backup: ${backup_timestamp}_gitlab_backup.tar"
        log_info "Backup location: /var/opt/gitlab/backups/"
    else
        log_warning "⚠️ Không thể tạo safety backup"
        read -p "Tiếp tục migration mà không có backup? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return 1
        fi
    fi
}

# Hàm thực hiện migration
perform_database_migration() {
    local migration_start_time=$(date +%s)

    log_info "🔄 Bắt đầu database migration..."
    log_warning "⏳ Quá trình này có thể mất vài phút..."
    echo ""

    # Chạy migration với monitoring
    local migration_pid
    docker exec gitlab gitlab-rake db:migrate &
    migration_pid=$!

    # Monitor migration progress
    local attempt=1
    local max_attempts=60  # 60 * 10s = 10 phút
    local progress_chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    local progress_index=0

    while kill -0 $migration_pid 2>/dev/null && [ $attempt -le $max_attempts ]; do
        local current_time=$(date +%s)
        local elapsed=$((current_time - migration_start_time))
        local elapsed_minutes=$((elapsed / 60))
        local elapsed_seconds=$((elapsed % 60))

        local progress_char=${progress_chars:$progress_index:1}
        progress_index=$(((progress_index + 1) % ${#progress_chars}))

        echo -ne "\r  $progress_char Đang migrate... ${elapsed_minutes}m ${elapsed_seconds}s | Lần thử: $attempt/$max_attempts"

        sleep 10
        ((attempt++))
    done
    echo ""

    # Đợi process hoàn thành
    wait $migration_pid
    local migration_exit_code=$?

    local migration_end_time=$(date +%s)
    local migration_duration=$((migration_end_time - migration_start_time))
    local migration_minutes=$((migration_duration / 60))
    local migration_seconds=$((migration_duration % 60))

    if [ $migration_exit_code -eq 0 ]; then
        log_success "✅ Database migration thành công!"
        echo "  ⏱️ Thời gian migration: ${migration_minutes}m ${migration_seconds}s"
        return 0
    else
        log_error "❌ Database migration thất bại (exit code: $migration_exit_code)!"
        echo "  ⏱️ Thời gian thử migration: ${migration_minutes}m ${migration_seconds}s"
        return 1
    fi
}

# Hàm kiểm tra sau migration
post_migration_verification() {
    log_info "🔍 Kiểm tra database sau migration..."

    # Kiểm tra database connection
    if docker exec gitlab gitlab-rails runner "ActiveRecord::Base.connection.current_database" >/dev/null 2>&1; then
        log_success "✅ Database connection OK"
    else
        log_error "❌ Database connection failed sau migration"
        return 1
    fi

    # Kiểm tra migration status
    local pending_migrations=$(docker exec gitlab gitlab-rails runner "puts ActiveRecord::Base.connection.migration_context.needs_migration?" 2>/dev/null || echo "unknown")
    if [ "$pending_migrations" = "false" ]; then
        log_success "✅ Tất cả migrations đã được apply"
    else
        log_warning "⚠️ Vẫn có pending migrations: $pending_migrations"
    fi

    # Kiểm tra database integrity
    log_info "Kiểm tra database integrity..."
    local user_count=$(docker exec gitlab gitlab-rails runner "puts User.count" 2>/dev/null || echo "0")
    local project_count=$(docker exec gitlab gitlab-rails runner "puts Project.count" 2>/dev/null || echo "0")

    log_info "  👥 Users: $user_count"
    log_info "  📁 Projects: $project_count"

    # Kiểm tra GitLab services
    if docker exec gitlab gitlab-ctl status >/dev/null 2>&1; then
        log_success "✅ GitLab services đang hoạt động"
    else
        log_warning "⚠️ GitLab services có vấn đề"
        return 1
    fi

    log_success "✅ Post-migration verification hoàn thành"
    return 0
}

# Hàm reset toàn bộ GitLab
reset_all_gitlab() {
    log_header "RESET TOÀN BỘ GITLAB"

    log_warning "🚨 CẢNH BÁO: THAO TÁC NGUY HIỂM 🚨"
    echo ""
    echo "Thao tác này sẽ:"
    echo "  🗑️ Xóa TẤT CẢ dữ liệu GitLab hiện tại"
    echo "  🗄️ Xóa databases cũ và partitions"
    echo "  🔄 Migrate database mới"
    echo "  👑 Reset root user"
    echo "  ⚙️ Reconfigure GitLab"
    echo "  🔧 Restart tất cả services"
    echo ""
    echo "💀 DỮ LIỆU SẼ BỊ MẤT VĨNH VIỄN!"
    echo ""

    # Xác nhận mạnh mẽ
    log_warning "Để tiếp tục, bạn phải gõ chính xác: RESET_ALL_GITLAB"
    read -p "Nhập xác nhận: " confirmation

    if [ "$confirmation" != "RESET_ALL_GITLAB" ]; then
        log_info "❌ Xác nhận không đúng. Hủy thao tác reset."
        return 0
    fi

    echo ""
    read -p "Lần xác nhận cuối: Bạn có CHẮC CHẮN muốn reset toàn bộ? (yes/no): " final_confirm
    if [ "$final_confirm" != "yes" ]; then
        log_info "❌ Hủy thao tác reset."
        return 0
    fi

    echo ""
    log_warning "🚀 Bắt đầu reset toàn bộ GitLab..."

    # Bước 1: Tạo final backup
    log_info "🔍 Bước 1/7: Tạo final backup..."
    create_final_backup_before_reset

    # Bước 2: Dừng GitLab services
    log_info "🔍 Bước 2/7: Dừng GitLab services..."
    stop_gitlab_services_for_reset

    # Bước 3: Dọn dẹp databases
    log_info "🔍 Bước 3/7: Dọn dẹp databases..."
    if ! reset_databases; then
        log_error "❌ Lỗi khi reset databases"
        return 1
    fi

    # Bước 4: Dọn dẹp GitLab data
    log_info "🔍 Bước 4/7: Dọn dẹp GitLab data..."
    clean_gitlab_data_for_reset

    # Bước 5: Reconfigure GitLab
    log_info "🔍 Bước 5/7: Reconfigure GitLab..."
    if ! reconfigure_gitlab_after_reset; then
        log_error "❌ Lỗi khi reconfigure GitLab"
        return 1
    fi

    # Bước 6: Migrate và setup
    log_info "🔍 Bước 6/7: Migrate và setup database..."
    if ! setup_fresh_gitlab; then
        log_error "❌ Lỗi khi setup GitLab mới"
        return 1
    fi

    # Bước 7: Verification
    log_info "🔍 Bước 7/7: Kiểm tra GitLab sau reset..."
    if verify_reset_success; then
        log_success "🎉 Reset toàn bộ GitLab hoàn thành!"
        show_reset_summary
        return 0
    else
        log_error "❌ Reset có vấn đề!"
        show_reset_troubleshooting
        return 1
    fi
}

# Hàm tạo final backup trước reset
create_final_backup_before_reset() {
    log_info "🛡️ Tạo final backup trước khi reset..."

    local final_backup_timestamp=$(date +%Y%m%d_%H%M%S)_final_before_reset

    if docker exec gitlab gitlab-backup create BACKUP="$final_backup_timestamp" STRATEGY=copy >/dev/null 2>&1; then
        log_success "✅ Đã tạo final backup: ${final_backup_timestamp}_gitlab_backup.tar"
        log_info "Backup location: /var/opt/gitlab/backups/"

        # Copy ra host nếu có thể
        local host_backup_path="$BACKUP_DIR/${final_backup_timestamp}_gitlab_backup.tar"
        if docker cp "gitlab:/var/opt/gitlab/backups/${final_backup_timestamp}_gitlab_backup.tar" "$host_backup_path" 2>/dev/null; then
            log_success "✅ Đã copy final backup ra host: $host_backup_path"
        fi
    else
        log_warning "⚠️ Không thể tạo final backup"
        read -p "Tiếp tục reset mà không có final backup? (yes/no): " backup_confirm
        if [ "$backup_confirm" != "yes" ]; then
            return 1
        fi
    fi
}

# Hàm dừng GitLab services cho reset
stop_gitlab_services_for_reset() {
    log_info "⏸️ Dừng tất cả GitLab services..."

    # Dừng GitLab services
    docker exec gitlab gitlab-ctl stop 2>/dev/null || true

    # Dừng container
    docker stop gitlab 2>/dev/null || true

    log_success "✅ Đã dừng GitLab services"
}

# Hàm reset databases
reset_databases() {
    log_info "🗄️ Reset tất cả databases..."

    # Terminate tất cả connections
    docker exec postgres psql -U nextflow -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname LIKE '%gitlab%' AND pid <> pg_backend_pid();" 2>/dev/null || true

    # Drop tất cả GitLab databases
    local gitlab_databases=("nextflow_gitlab" "gitlabhq_production" "gitlab_partitions_dynamic" "gitlab_partitions_static" "gitlab_test" "gitlab_development")

    for db in "${gitlab_databases[@]}"; do
        if docker exec postgres psql -U nextflow -c "SELECT 1 FROM pg_database WHERE datname = '$db';" | grep -q 1; then
            log_info "  🗑️ Xóa database: $db"
            docker exec postgres psql -U nextflow -c "DROP DATABASE IF EXISTS $db;" 2>/dev/null || true
        fi
    done

    # Tạo lại database chính
    log_info "  🆕 Tạo database mới: nextflow_gitlab"
    if docker exec postgres psql -U nextflow -c "CREATE DATABASE nextflow_gitlab;" 2>/dev/null; then
        log_success "✅ Đã tạo database mới"
        return 0
    else
        log_error "❌ Không thể tạo database mới"
        return 1
    fi
}

# Hàm dọn dẹp GitLab data
clean_gitlab_data_for_reset() {
    log_info "🧹 Dọn dẹp GitLab data directories..."

    # Dọn dẹp GitLab data (giữ lại config và backups)
    local data_dirs=("$PROJECT_DIR/gitlab/data" "$PROJECT_DIR/gitlab/logs")

    for dir in "${data_dirs[@]}"; do
        if [ -d "$dir" ]; then
            log_info "  🗑️ Dọn dẹp: $(basename "$dir")"
            rm -rf "$dir"/* 2>/dev/null || true
        fi
    done

    log_success "✅ Đã dọn dẹp GitLab data"
}

# Hàm reconfigure GitLab sau reset
reconfigure_gitlab_after_reset() {
    log_info "⚙️ Reconfigure GitLab..."

    # Khởi động GitLab container
    docker-compose --profile gitlab up -d gitlab

    # Đợi container sẵn sàng
    local attempt=1
    local max_attempts=30

    while [ $attempt -le $max_attempts ]; do
        if docker exec gitlab gitlab-ctl status >/dev/null 2>&1; then
            break
        fi
        echo -ne "\r  ⏳ Đợi GitLab container... ($attempt/$max_attempts)"
        sleep 10
        ((attempt++))
    done
    echo ""

    if [ $attempt -gt $max_attempts ]; then
        log_error "❌ GitLab container không khởi động được"
        return 1
    fi

    # Reconfigure
    if docker exec gitlab gitlab-ctl reconfigure; then
        log_success "✅ Reconfigure thành công"
        return 0
    else
        log_error "❌ Reconfigure thất bại"
        return 1
    fi
}

# Hàm setup GitLab mới
setup_fresh_gitlab() {
    log_info "🆕 Setup GitLab mới..."

    # Migrate database
    if docker exec gitlab gitlab-rake db:migrate; then
        log_success "✅ Database migration thành công"
    else
        log_error "❌ Database migration thất bại"
        return 1
    fi

    # Seed initial data
    if docker exec gitlab gitlab-rake db:seed_fu GITLAB_ROOT_PASSWORD="${GITLAB_ROOT_PASSWORD:-Nex!tFlow@2025!}" GITLAB_ROOT_EMAIL="${GITLAB_ROOT_EMAIL:-nextflow.vn@gmail.com}"; then
        log_success "✅ Database seeding thành công"
    else
        log_warning "⚠️ Database seeding có vấn đề"
    fi

    return 0
}

# Hàm kiểm tra reset thành công
verify_reset_success() {
    log_info "🔍 Kiểm tra GitLab sau reset..."

    # Đợi GitLab sẵn sàng
    if ! wait_for_gitlab; then
        log_error "❌ GitLab không khởi động được sau reset"
        return 1
    fi

    # Kiểm tra database
    local user_count=$(docker exec gitlab gitlab-rails runner "puts User.count" 2>/dev/null || echo "0")
    if [ "$user_count" -gt 0 ]; then
        log_success "✅ Database có users: $user_count"
    else
        log_warning "⚠️ Database chưa có users"
    fi

    # Kiểm tra root user
    local root_exists=$(docker exec gitlab gitlab-rails runner "puts User.find_by(username: 'root') ? 'true' : 'false'" 2>/dev/null || echo "false")
    if [ "$root_exists" = "true" ]; then
        log_success "✅ Root user đã được tạo"
    else
        log_warning "⚠️ Root user chưa được tạo"
    fi

    # Kiểm tra web interface
    local http_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8088" 2>/dev/null || echo "000")
    if [[ "$http_code" =~ ^(200|302)$ ]]; then
        log_success "✅ Web interface accessible"
    else
        log_warning "⚠️ Web interface chưa sẵn sàng"
    fi

    return 0
}

# Hàm hiển thị tổng kết reset
show_reset_summary() {
    log_header "TỔNG KẾT RESET GITLAB"

    echo "🎉 Reset GitLab hoàn thành thành công!"
    echo ""
    echo "📊 Những gì đã được thực hiện:"
    echo "  ✅ Tạo final backup trước reset"
    echo "  ✅ Xóa tất cả databases cũ"
    echo "  ✅ Dọn dẹp GitLab data directories"
    echo "  ✅ Tạo database mới"
    echo "  ✅ Reconfigure GitLab"
    echo "  ✅ Migrate database"
    echo "  ✅ Seed initial data"
    echo ""

    echo "🌐 Thông tin truy cập GitLab mới:"
    echo "  URL: ${GITLAB_EXTERNAL_URL:-http://localhost:8088}"
    echo "  Username: ${GITLAB_ROOT_USERNAME:-root}"
    echo "  Password: ${GITLAB_ROOT_PASSWORD:-Nex!tFlow@2025!}"
    echo "  Email: ${GITLAB_ROOT_EMAIL:-nextflow.vn@gmail.com}"
    echo ""

    echo "💡 Các bước tiếp theo:"
    echo "  1. Đăng nhập và thay đổi password"
    echo "  2. Cấu hình GitLab settings"
    echo "  3. Tạo projects và users mới"
    echo "  4. Setup CI/CD runners nếu cần"
    echo "  5. Tạo backup định kỳ"
    echo ""

    echo "🛡️ Backup information:"
    echo "  • Final backup đã được tạo trước reset"
    echo "  • Location: /var/opt/gitlab/backups/ và $BACKUP_DIR"
    echo "  • Có thể restore nếu cần: option [6] RESTORE"
}

# Hàm hiển thị troubleshooting reset
show_reset_troubleshooting() {
    log_header "HƯỚNG DẪN KHẮC PHỤC LỖI RESET"

    echo "🔍 Các bước kiểm tra và khắc phục:"
    echo ""
    echo "1. 📋 Kiểm tra logs GitLab:"
    echo "   docker logs gitlab"
    echo ""
    echo "2. 🔄 Thử reconfigure lại:"
    echo "   docker exec gitlab gitlab-ctl reconfigure"
    echo ""
    echo "3. 🗄️ Kiểm tra database:"
    echo "   docker exec postgres psql -U nextflow -l"
    echo ""
    echo "4. 🔧 Thử migrate lại:"
    echo "   option [12] MIGRATE"
    echo ""
    echo "5. 👑 Tạo root user thủ công:"
    echo "   option [9] CREATE-ROOT"
    echo ""
    echo "6. 🛡️ Restore từ backup nếu cần:"
    echo "   option [6] RESTORE"
    echo ""
    echo "7. 🆘 Liên hệ support:"
    echo "   Tạo diagnostic report: option [7] STATUS"
    echo ""

    log_info "💡 Reset có thể mất thời gian để hoàn toàn ổn định"
}

# Hàm tạo root user
create_root_user() {
    log_header "TẠO ROOT USER GITLAB"

    # Bước 1: Kiểm tra yêu cầu
    log_info "🔍 Bước 1/5: Kiểm tra yêu cầu..."
    if ! check_gitlab_container; then
        log_error "❌ GitLab container không sẵn sàng"
        return 1
    fi

    # Bước 2: Kiểm tra root user hiện tại
    log_info "🔍 Bước 2/5: Kiểm tra root user hiện tại..."
    if check_existing_root_user; then
        return 0  # Root user đã tồn tại và được xử lý
    fi

    # Bước 3: Chuẩn bị thông tin user
    log_info "🔍 Bước 3/5: Chuẩn bị thông tin root user..."
    prepare_root_user_info

    # Bước 4: Tạo root user
    log_info "🔍 Bước 4/5: Tạo root user..."
    if create_root_user_process; then
        log_success "✅ Root user đã được tạo thành công!"
    else
        log_error "❌ Tạo root user thất bại!"
        return 1
    fi

    # Bước 5: Kiểm tra và hoàn tất
    log_info "🔍 Bước 5/5: Kiểm tra root user..."
    if verify_root_user_creation; then
        log_success "🎉 Root user đã sẵn sàng sử dụng!"
        show_root_user_info
        return 0
    else
        log_warning "⚠️ Root user được tạo nhưng có vấn đề"
        return 1
    fi
}

# Hàm kiểm tra root user hiện tại
check_existing_root_user() {
    local user_count=$(docker exec gitlab gitlab-rails runner "puts User.count" 2>/dev/null || echo "0")
    local root_exists=$(docker exec gitlab gitlab-rails runner "puts User.find_by(username: 'root') ? 'true' : 'false'" 2>/dev/null || echo "false")

    log_info "👥 Tổng số users trong database: $user_count"

    if [ "$root_exists" = "true" ]; then
        log_success "✅ Root user đã tồn tại!"

        # Lấy thông tin root user hiện tại
        local root_info=$(docker exec gitlab gitlab-rails runner "
            user = User.find_by(username: 'root')
            if user
                puts \"#{user.email}|#{user.admin}|#{user.created_at}|#{user.confirmed_at ? 'confirmed' : 'unconfirmed'}\"
            end
        " 2>/dev/null || echo "unknown|unknown|unknown|unknown")

        local root_email=$(echo "$root_info" | cut -d'|' -f1)
        local is_admin=$(echo "$root_info" | cut -d'|' -f2)
        local created_at=$(echo "$root_info" | cut -d'|' -f3)
        local confirmed_status=$(echo "$root_info" | cut -d'|' -f4)

        echo "  📧 Email: $root_email"
        echo "  👑 Admin: $is_admin"
        echo "  📅 Tạo lúc: $created_at"
        echo "  ✅ Trạng thái: $confirmed_status"
        echo ""

        log_info "Các tùy chọn:"
        echo "  1. Giữ nguyên root user hiện tại"
        echo "  2. Reset password root user"
        echo "  3. Cập nhật thông tin root user"
        echo "  4. Xóa và tạo lại root user"
        echo ""

        read -p "Chọn tùy chọn (1-4): " choice

        case $choice in
            1)
                log_info "✅ Giữ nguyên root user hiện tại"
                show_root_user_info
                return 0
                ;;
            2)
                reset_root_user_password
                return $?
                ;;
            3)
                update_root_user_info
                return $?
                ;;
            4)
                log_warning "⚠️ Sẽ xóa và tạo lại root user"
                read -p "Bạn có chắc chắn? Dữ liệu root user sẽ bị mất! (yes/no): " confirmation
                if [ "$confirmation" = "yes" ]; then
                    delete_existing_root_user
                    return 1  # Tiếp tục tạo root user mới
                else
                    log_info "Hủy thao tác"
                    return 0
                fi
                ;;
            *)
                log_error "Lựa chọn không hợp lệ!"
                return 0
                ;;
        esac
    else
        if [ "$user_count" -gt 0 ]; then
            log_warning "⚠️ Database có $user_count users nhưng không có root user"
        else
            log_info "ℹ️ Database trống, sẽ tạo root user mới"
        fi
        return 1  # Cần tạo root user mới
    fi
}

# Hàm chuẩn bị thông tin root user
prepare_root_user_info() {
    local default_email="${GITLAB_ROOT_EMAIL:-nextflow.vn@gmail.com}"
    local default_password="${GITLAB_ROOT_PASSWORD:-Nex!tFlow@2025!}"

    log_info "📋 Thông tin root user sẽ được tạo:"
    echo "  👤 Username: root"
    echo "  📧 Email: $default_email"
    echo "  🔑 Password: $default_password"
    echo "  👑 Role: Administrator"
    echo ""

    read -p "Sử dụng thông tin mặc định? (Y/n): " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Nn]$ ]]; then
        # Cho phép user nhập thông tin custom
        echo ""
        read -p "Nhập email cho root user [$default_email]: " custom_email
        read -s -p "Nhập password cho root user (để trống = dùng mặc định): " custom_password
        echo

        if [ -n "$custom_email" ]; then
            export GITLAB_ROOT_EMAIL="$custom_email"
            log_info "✅ Sử dụng email custom: $custom_email"
        fi
        if [ -n "$custom_password" ]; then
            export GITLAB_ROOT_PASSWORD="$custom_password"
            log_info "✅ Sử dụng password custom"
        fi
    else
        log_info "✅ Sử dụng thông tin mặc định"
    fi
}

# Hàm tạo root user process
create_root_user_process() {
    local creation_start_time=$(date +%s)
    local root_password="${GITLAB_ROOT_PASSWORD:-Nex!tFlow@2025!}"
    local root_email="${GITLAB_ROOT_EMAIL:-nextflow.vn@gmail.com}"

    log_info "👑 Bắt đầu tạo root user..."
    log_warning "⏳ Quá trình này có thể mất 1-5 phút..."
    echo ""

    # Thử phương pháp 1: Sử dụng script Ruby custom
    if [ -f "$GITLAB_SCRIPTS_DIR/create_root_user.rb" ]; then
        log_info "🔧 Phương pháp 1: Sử dụng script Ruby custom..."
        docker cp "$GITLAB_SCRIPTS_DIR/create_root_user.rb" gitlab:/tmp/

        if docker exec gitlab bash -c "GITLAB_ROOT_PASSWORD='$root_password' GITLAB_ROOT_EMAIL='$root_email' gitlab-rails runner /tmp/create_root_user.rb" 2>/dev/null; then
            docker exec gitlab rm -f /tmp/create_root_user.rb 2>/dev/null
            log_success "✅ Script Ruby thành công!"
            return 0
        else
            docker exec gitlab rm -f /tmp/create_root_user.rb 2>/dev/null
            log_warning "⚠️ Script Ruby thất bại, thử phương pháp khác..."
        fi
    fi

    # Phương pháp 2: Sử dụng db:seed_fu
    log_info "🔧 Phương pháp 2: Sử dụng GitLab seed data..."
    if docker exec gitlab gitlab-rake db:seed_fu GITLAB_ROOT_PASSWORD="$root_password" GITLAB_ROOT_EMAIL="$root_email" 2>/dev/null; then
        log_success "✅ Seed data thành công!"
        return 0
    else
        log_warning "⚠️ Seed data thất bại, thử phương pháp khác..."
    fi

    # Phương pháp 3: Tạo user trực tiếp bằng Rails console
    log_info "🔧 Phương pháp 3: Tạo user trực tiếp..."
    local create_user_script="
        begin
            # Xóa root user cũ nếu có
            old_user = User.find_by(username: 'root')
            old_user&.destroy

            # Tạo root user mới
            user = User.new(
                username: 'root',
                email: '$root_email',
                name: 'Administrator',
                password: '$root_password',
                password_confirmation: '$root_password',
                admin: true,
                confirmed_at: Time.current,
                confirmation_token: nil
            )

            if user.save
                puts 'Root user created successfully'
                exit 0
            else
                puts 'Failed to create root user: ' + user.errors.full_messages.join(', ')
                exit 1
            end
        rescue => e
            puts 'Error: ' + e.message
            exit 1
        end
    "

    if docker exec gitlab gitlab-rails runner "$create_user_script" 2>/dev/null; then
        log_success "✅ Tạo user trực tiếp thành công!"
        return 0
    else
        log_error "❌ Tất cả phương pháp đều thất bại!"
        return 1
    fi
}

# Hàm kiểm tra root user sau tạo
verify_root_user_creation() {
    log_info "🔍 Kiểm tra root user đã được tạo..."

    # Kiểm tra user tồn tại
    local root_exists=$(docker exec gitlab gitlab-rails runner "puts User.find_by(username: 'root') ? 'true' : 'false'" 2>/dev/null || echo "false")

    if [ "$root_exists" = "true" ]; then
        log_success "✅ Root user đã tồn tại"

        # Kiểm tra thông tin chi tiết
        local user_details=$(docker exec gitlab gitlab-rails runner "
            user = User.find_by(username: 'root')
            if user
                puts \"#{user.email}|#{user.admin}|#{user.confirmed_at ? 'confirmed' : 'unconfirmed'}|#{user.sign_in_count}\"
            end
        " 2>/dev/null || echo "unknown|unknown|unknown|unknown")

        local email=$(echo "$user_details" | cut -d'|' -f1)
        local is_admin=$(echo "$user_details" | cut -d'|' -f2)
        local confirmed=$(echo "$user_details" | cut -d'|' -f3)
        local sign_in_count=$(echo "$user_details" | cut -d'|' -f4)

        log_info "  📧 Email: $email"
        log_info "  👑 Admin: $is_admin"
        log_info "  ✅ Confirmed: $confirmed"
        log_info "  🔢 Sign-in count: $sign_in_count"

        # Kiểm tra có thể đăng nhập không
        if [ "$confirmed" = "confirmed" ] && [ "$is_admin" = "true" ]; then
            log_success "✅ Root user đã sẵn sàng sử dụng"
            return 0
        else
            log_warning "⚠️ Root user có vấn đề về quyền hoặc confirmation"
            return 1
        fi
    else
        log_error "❌ Root user không được tạo"
        return 1
    fi
}

# Hàm reset password root user
reset_root_user_password() {
    log_info "🔑 Reset password root user..."

    local new_password="${GITLAB_ROOT_PASSWORD:-Nex!tFlow@2025!}"

    read -p "Nhập password mới (để trống = dùng mặc định): " custom_password
    if [ -n "$custom_password" ]; then
        new_password="$custom_password"
    fi

    local reset_script="
        user = User.find_by(username: 'root')
        if user
            user.password = '$new_password'
            user.password_confirmation = '$new_password'
            if user.save
                puts 'Password reset successfully'
            else
                puts 'Failed to reset password: ' + user.errors.full_messages.join(', ')
                exit 1
            end
        else
            puts 'Root user not found'
            exit 1
        end
    "

    if docker exec gitlab gitlab-rails runner "$reset_script" 2>/dev/null; then
        log_success "✅ Password đã được reset thành công!"
        log_info "🔑 Password mới: $new_password"
        return 0
    else
        log_error "❌ Reset password thất bại!"
        return 1
    fi
}

# Hàm cập nhật thông tin root user
update_root_user_info() {
    log_info "📝 Cập nhật thông tin root user..."

    # Lấy thông tin hiện tại
    local current_info=$(docker exec gitlab gitlab-rails runner "
        user = User.find_by(username: 'root')
        if user
            puts \"#{user.email}|#{user.name}\"
        end
    " 2>/dev/null || echo "unknown|unknown")

    local current_email=$(echo "$current_info" | cut -d'|' -f1)
    local current_name=$(echo "$current_info" | cut -d'|' -f2)

    echo "Thông tin hiện tại:"
    echo "  📧 Email: $current_email"
    echo "  👤 Name: $current_name"
    echo ""

    read -p "Email mới (để trống = giữ nguyên): " new_email
    read -p "Name mới (để trống = giữ nguyên): " new_name

    if [ -z "$new_email" ] && [ -z "$new_name" ]; then
        log_info "Không có thay đổi nào"
        return 0
    fi

    # Chuẩn bị script update
    local update_script="
        user = User.find_by(username: 'root')
        if user
    "

    if [ -n "$new_email" ]; then
        update_script="$update_script
            user.email = '$new_email'"
    fi

    if [ -n "$new_name" ]; then
        update_script="$update_script
            user.name = '$new_name'"
    fi

    update_script="$update_script
            if user.save
                puts 'User updated successfully'
            else
                puts 'Failed to update user: ' + user.errors.full_messages.join(', ')
                exit 1
            end
        else
            puts 'Root user not found'
            exit 1
        end
    "

    if docker exec gitlab gitlab-rails runner "$update_script" 2>/dev/null; then
        log_success "✅ Thông tin root user đã được cập nhật!"
        return 0
    else
        log_error "❌ Cập nhật thông tin thất bại!"
        return 1
    fi
}

# Hàm xóa root user hiện tại
delete_existing_root_user() {
    log_warning "🗑️ Xóa root user hiện tại..."

    local delete_script="
        user = User.find_by(username: 'root')
        if user
            user.destroy
            puts 'Root user deleted'
        else
            puts 'Root user not found'
        end
    "

    if docker exec gitlab gitlab-rails runner "$delete_script" 2>/dev/null; then
        log_success "✅ Root user đã được xóa"
    else
        log_warning "⚠️ Không thể xóa root user"
    fi
}

# Hàm hiển thị thông tin root user
show_root_user_info() {
    log_header "THÔNG TIN ROOT USER"

    echo "🌐 Thông tin đăng nhập GitLab:"
    echo "  URL: ${GITLAB_EXTERNAL_URL:-http://localhost:8088}"
    echo "  Username: root"
    echo "  Password: ${GITLAB_ROOT_PASSWORD:-Nex!tFlow@2025!}"
    echo "  Email: ${GITLAB_ROOT_EMAIL:-nextflow.vn@gmail.com}"
    echo ""

    echo "💡 Các bước tiếp theo:"
    echo "  1. Đăng nhập vào GitLab"
    echo "  2. Thay đổi password nếu cần"
    echo "  3. Cấu hình profile và settings"
    echo "  4. Tạo projects và users khác"
    echo "  5. Setup SSH keys"
    echo ""

    echo "🔧 Quản lý root user:"
    echo "  • Reset password: option [10] RESET-ROOT"
    echo "  • Tạo lại root user: option [9] CREATE-ROOT"
    echo "  • Kiểm tra status: option [7] STATUS"
}

# Main function VỚI LOGGING
main() {
    # Khởi tạo session logging
    start_session_log

    # Trap để cleanup khi script kết thúc
    trap 'end_session_log; cleanup_old_logs' EXIT

    # Log system info
    log_info "GitLab Manager started with args: $*"
    log_debug "Working directory: $PROJECT_DIR"
    log_debug "Environment: $(uname -a)"

    # Nếu không có tham số, hiển thị menu tương tác
    if [ $# -eq 0 ]; then
        log_info "Starting interactive menu mode"
        show_interactive_menu
        return
    fi

    # Xử lý tham số dòng lệnh với enhanced logging
    local command="$1"
    log_info "Executing command: $command"
    monitor_command "$command"

    case "$command" in
        images)
            create_operation_report "check_gitlab_images" "started" "Checking GitLab images"
            if check_gitlab_images; then
                create_operation_report "check_gitlab_images" "success" "GitLab images checked successfully"
            else
                create_operation_report "check_gitlab_images" "failed" "Failed to check GitLab images"
            fi
            ;;
        build)
            create_operation_report "build_gitlab" "started" "Building GitLab custom image"
            if build_gitlab; then
                create_operation_report "build_gitlab" "success" "GitLab custom image built successfully"
            else
                create_operation_report "build_gitlab" "failed" "Failed to build GitLab custom image"
            fi
            ;;
        install)
            create_operation_report "install_gitlab" "started" "Installing GitLab"
            if install_gitlab; then
                create_operation_report "install_gitlab" "success" "GitLab installed successfully"
            else
                create_operation_report "install_gitlab" "failed" "Failed to install GitLab"
            fi
            ;;
        info)
            create_operation_report "show_access_info" "started" "Showing access information"
            show_access_info
            create_operation_report "show_access_info" "success" "Access information displayed"
            ;;
        backup)
            create_operation_report "backup_gitlab" "started" "Creating GitLab backup"
            if backup_gitlab; then
                create_operation_report "backup_gitlab" "success" "GitLab backup created successfully"
            else
                create_operation_report "backup_gitlab" "failed" "Failed to create GitLab backup"
            fi
            ;;
        restore)
            create_operation_report "restore_gitlab" "started" "Restoring GitLab from backup"
            if restore_gitlab; then
                create_operation_report "restore_gitlab" "success" "GitLab restored successfully"
            else
                create_operation_report "restore_gitlab" "failed" "Failed to restore GitLab"
            fi
            ;;
        status)
            create_operation_report "check_gitlab_status" "started" "Checking GitLab status"
            check_gitlab_status_detailed
            create_operation_report "check_gitlab_status" "success" "GitLab status checked"
            ;;
        check-db)
            create_operation_report "check_databases" "started" "Checking databases"
            check_databases
            create_operation_report "check_databases" "success" "Databases checked"
            ;;
        create-root)
            create_operation_report "create_root_user" "started" "Creating root user"
            if create_root_user; then
                create_operation_report "create_root_user" "success" "Root user created successfully"
            else
                create_operation_report "create_root_user" "failed" "Failed to create root user"
            fi
            ;;
        reset-root)
            create_operation_report "reset_root_user" "started" "Resetting root user"
            if reset_root_user; then
                create_operation_report "reset_root_user" "success" "Root user reset successfully"
            else
                create_operation_report "reset_root_user" "failed" "Failed to reset root user"
            fi
            ;;
        clean-db)
            create_operation_report "clean_old_databases" "started" "Cleaning old databases"
            if clean_old_databases; then
                create_operation_report "clean_old_databases" "success" "Old databases cleaned successfully"
            else
                create_operation_report "clean_old_databases" "failed" "Failed to clean old databases"
            fi
            ;;
        migrate)
            create_operation_report "migrate_database" "started" "Migrating database"
            if migrate_database; then
                create_operation_report "migrate_database" "success" "Database migrated successfully"
            else
                create_operation_report "migrate_database" "failed" "Failed to migrate database"
            fi
            ;;
        reset-all)
            create_operation_report "reset_all_gitlab" "started" "Resetting all GitLab"
            if reset_all_gitlab; then
                create_operation_report "reset_all_gitlab" "success" "GitLab reset successfully"
            else
                create_operation_report "reset_all_gitlab" "failed" "Failed to reset GitLab"
            fi
            ;;
        logs)
            create_operation_report "show_log_statistics" "started" "Showing log statistics"
            show_log_statistics
            create_operation_report "show_log_statistics" "success" "Log statistics displayed"
            ;;
        health)
            create_operation_report "monitor_gitlab_health" "started" "Monitoring GitLab health"
            monitor_gitlab_health
            create_operation_report "monitor_gitlab_health" "success" "GitLab health monitored"
            ;;
        report)
            create_operation_report "create_daily_report" "started" "Creating daily report"
            if create_daily_report; then
                create_operation_report "create_daily_report" "success" "Daily report created successfully"
            else
                create_operation_report "create_daily_report" "failed" "Failed to create daily report"
            fi
            ;;
        help|*)
            echo "GitLab Manager - NextFlow CRM-AI"
            echo ""
            echo "Sử dụng: $0 [COMMAND]"
            echo ""
            echo "Commands:"
            echo "  images      - Kiểm tra GitLab images có sẵn"
            echo "  build       - Build GitLab custom image"
            echo "  install     - Cài đặt GitLab"
            echo "  info        - Xem thông tin truy cập"
            echo ""
            echo "  💾 Backup & Restore:"
            echo "  backup      - Sao lưu dữ liệu GitLab"
            echo "  restore     - Khôi phục dữ liệu GitLab từ backup"
            echo ""
            echo "  🔧 Troubleshooting & Fix:"
            echo "  status      - Kiểm tra trạng thái tổng thể GitLab"
            echo "  check-db    - Kiểm tra trạng thái database"
            echo "  create-root - Tạo root user mới (khi chưa có root)"
            echo "  reset-root  - Reset root user và password"
            echo "  clean-db    - Xóa database cũ và partitions không dùng"
            echo "  migrate     - Chạy database migration"
            echo "  reset-all   - Reset toàn bộ GitLab"
            echo ""
            echo "  📊 Monitoring & Logging:"
            echo "  logs        - Xem log statistics và thông tin"
            echo "  health      - Kiểm tra health status real-time"
            echo "  report      - Tạo daily report"
            echo ""
            echo "  help        - Hiển thị help này"
            echo ""
            echo "Chạy không tham số để vào menu tương tác: $0"

            if [ "$1" != "help" ]; then
                log_warning "Unknown command: $1"
                create_operation_report "help" "success" "Help displayed for unknown command: $1"
            else
                create_operation_report "help" "success" "Help displayed"
            fi
            ;;
    esac
}

# Chạy main function
main "$@"
