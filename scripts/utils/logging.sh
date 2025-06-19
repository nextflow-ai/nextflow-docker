#!/bin/bash

# Logging utilities for NextFlow Docker scripts
# Author: Augment Agent
# Version: 1.0

# Màu sắc cho output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
NC='\033[0m' # No Color

# Icons
SUCCESS_ICON="✅"
ERROR_ICON="❌"
WARNING_ICON="⚠️"
INFO_ICON="ℹ️"
LOADING_ICON="🔄"

# Hàm hiển thị thông báo với màu sắc và icon
log_info() {
    echo -e "${BLUE}${INFO_ICON} [INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}${SUCCESS_ICON} [SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}${WARNING_ICON} [WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}${ERROR_ICON} [ERROR]${NC} $1"
}

log_loading() {
    echo -e "${CYAN}${LOADING_ICON} [LOADING]${NC} $1"
}

log_debug() {
    if [[ "${DEBUG:-false}" == "true" ]]; then
        echo -e "${PURPLE}[DEBUG]${NC} $1"
    fi
}

# Hàm hiển thị banner
show_banner() {
    local title="$1"
    local width=60
    local padding=$(( (width - ${#title}) / 2 ))
    
    echo -e "${BLUE}"
    echo "$(printf '=%.0s' $(seq 1 $width))"
    echo "$(printf '%*s' $padding)$title"
    echo "$(printf '=%.0s' $(seq 1 $width))"
    echo -e "${NC}"
}

# Hàm hiển thị progress bar
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((current * width / total))
    local remaining=$((width - completed))
    
    printf "\r${CYAN}Progress: [${GREEN}"
    printf '%*s' $completed | tr ' ' '█'
    printf "${NC}"
    printf '%*s' $remaining | tr ' ' '░'
    printf "${CYAN}] ${percentage}%%${NC}"
    
    if [[ $current -eq $total ]]; then
        echo ""
    fi
}

# Hàm log với timestamp
log_with_timestamp() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case $level in
        "INFO")
            echo -e "${BLUE}[$timestamp] ${INFO_ICON} [INFO]${NC} $message"
            ;;
        "SUCCESS")
            echo -e "${GREEN}[$timestamp] ${SUCCESS_ICON} [SUCCESS]${NC} $message"
            ;;
        "WARNING")
            echo -e "${YELLOW}[$timestamp] ${WARNING_ICON} [WARNING]${NC} $message"
            ;;
        "ERROR")
            echo -e "${RED}[$timestamp] ${ERROR_ICON} [ERROR]${NC} $message"
            ;;
        *)
            echo -e "[$timestamp] $message"
            ;;
    esac
}

# Hàm log vào file
log_to_file() {
    local level="$1"
    local message="$2"
    local log_file="${LOG_FILE:-/tmp/nextflow-docker.log}"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$level] $message" >> "$log_file"
}

# Hàm log kết hợp console và file
log_combined() {
    local level="$1"
    local message="$2"
    
    # Log to console
    case $level in
        "INFO")
            log_info "$message"
            ;;
        "SUCCESS")
            log_success "$message"
            ;;
        "WARNING")
            log_warning "$message"
            ;;
        "ERROR")
            log_error "$message"
            ;;
    esac
    
    # Log to file
    log_to_file "$level" "$message"
}

# Hàm hiển thị menu với style
show_menu() {
    local title="$1"
    shift
    local options=("$@")
    
    echo -e "${BLUE}"
    echo "=== $title ==="
    echo -e "${NC}"
    
    for i in "${!options[@]}"; do
        echo -e "${CYAN}$((i+1)).${NC} ${options[$i]}"
    done
    
    echo -e "${BLUE}"
    echo "$(printf '=%.0s' $(seq 1 ${#title}))"
    echo -e "${NC}"
    echo -n "Nhập lựa chọn của bạn: "
}

# Hàm confirm với style
confirm_action() {
    local message="$1"
    local default="${2:-n}"

    while true; do
        echo -e "${YELLOW}${WARNING_ICON} $message${NC}"
        if [[ "$default" == "y" ]]; then
            echo -n "Bạn có chắc chắn muốn tiếp tục? (Y/n): "
        else
            echo -n "Bạn có chắc chắn muốn tiếp tục? (y/N): "
        fi

        read -r response
        case "$response" in
            [yY][eE][sS]|[yY])
                return 0
                ;;
            [nN][oO]|[nN])
                return 1
                ;;
            "")
                if [[ "$default" == "y" ]]; then
                    return 0
                else
                    return 1
                fi
                ;;
            *)
                echo -e "${RED}${ERROR_ICON} Lựa chọn không hợp lệ!${NC}"
                # Continue loop để hỏi lại
                ;;
        esac
    done
}

# Hàm hiển thị spinner
show_spinner() {
    local pid=$1
    local message="$2"
    local delay=0.1
    local spinstr='|/-\'
    
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf "\r${CYAN}${LOADING_ICON} %s [%c]${NC}" "$message" "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done
    printf "\r${GREEN}${SUCCESS_ICON} %s [Done]${NC}\n" "$message"
}

# Export functions
export -f log_info log_success log_warning log_error log_loading log_debug
export -f show_banner show_progress log_with_timestamp log_to_file log_combined
export -f show_menu confirm_action show_spinner
