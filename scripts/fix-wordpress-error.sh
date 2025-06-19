#!/bin/bash

# ============================================================================
# SCRIPT SỬA LỖI WORDPRESS - NEXTFLOW DOCKER
# ============================================================================
# Tác giả: Augment Agent
# Phiên bản: 1.0
# Ngày tạo: 2025-06-16
# 
# MÔ TẢ:
# Script này sửa lỗi PHP parse error trong WordPress do WORDPRESS_CONFIG_EXTRA
# và restart WordPress container với cấu hình đã sửa
# ============================================================================

set -euo pipefail

# Thiết lập màu sắc cho output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Hàm hiển thị log với màu sắc
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

show_banner() {
    echo -e "${BLUE}"
    echo "============================================================================"
    echo "  $1"
    echo "============================================================================"
    echo -e "${NC}"
}

# Hàm kiểm tra service có đang chạy không
check_service_running() {
    local service_name="$1"
    if docker ps --format "table {{.Names}}" | grep -q "^${service_name}$"; then
        return 0
    else
        return 1
    fi
}

# Hàm sửa lỗi WordPress
fix_wordpress_error() {
    show_banner "SỬA LỖI WORDPRESS PHP PARSE ERROR"
    
    log_info "Đang sửa lỗi WordPress..."
    
    # Dừng WordPress container hiện tại
    if check_service_running "wordpress"; then
        log_info "Dừng WordPress container hiện tại..."
        docker stop wordpress
        docker rm wordpress
        log_success "Đã dừng WordPress container"
    else
        log_info "WordPress container không đang chạy"
    fi
    
    # Kiểm tra MariaDB
    if check_service_running "mariadb"; then
        log_success "MariaDB đang chạy"
    else
        log_info "Khởi động MariaDB..."
        docker-compose up -d mariadb
        sleep 10
    fi
    
    # Khởi động lại WordPress với cấu hình đã sửa
    log_info "Khởi động WordPress với cấu hình đã sửa..."
    docker-compose up -d wordpress
    
    # Chờ WordPress khởi động
    log_info "Chờ WordPress khởi động (30 giây)..."
    sleep 30
    
    return 0
}

# Hàm kiểm tra WordPress sau khi sửa
check_wordpress_status() {
    show_banner "KIỂM TRA WORDPRESS SAU KHI SỬA"
    
    log_info "Kiểm tra trạng thái WordPress..."
    
    # Kiểm tra container
    if check_service_running "wordpress"; then
        log_success "WordPress container đang chạy"
    else
        log_error "WordPress container không chạy"
        return 1
    fi
    
    # Kiểm tra logs để xem còn lỗi không
    log_info "Kiểm tra logs WordPress..."
    local recent_logs=$(docker logs wordpress --tail 10 2>&1)
    
    if echo "$recent_logs" | grep -q "PHP Parse error"; then
        log_error "Vẫn còn PHP parse error trong logs"
        echo "Recent logs:"
        echo "$recent_logs"
        return 1
    elif echo "$recent_logs" | grep -q "configured -- resuming normal operations"; then
        log_success "Apache đã khởi động thành công"
    else
        log_warning "Không thấy thông báo khởi động Apache, kiểm tra logs"
    fi
    
    # Test HTTP response
    log_info "Test HTTP response..."
    sleep 5
    
    local response_code=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:8080" || echo "000")
    
    case $response_code in
        200)
            log_success "WordPress trả về HTTP 200 - Hoạt động bình thường"
            ;;
        302|301)
            log_success "WordPress trả về HTTP $response_code - Redirect (bình thường cho setup)"
            ;;
        500)
            log_error "WordPress trả về HTTP 500 - Vẫn còn lỗi server"
            return 1
            ;;
        000)
            log_error "Không thể kết nối đến WordPress"
            return 1
            ;;
        *)
            log_warning "WordPress trả về HTTP $response_code - Cần kiểm tra thêm"
            ;;
    esac
    
    return 0
}

# Hàm hiển thị hướng dẫn tiếp theo
show_next_steps() {
    show_banner "HƯỚNG DẪN TIẾP THEO"
    
    log_success "WordPress đã được sửa lỗi thành công!"
    echo
    echo "🌐 Truy cập WordPress:"
    echo "  • Local: http://localhost:8080"
    echo "  • External: https://nextflow.vn (qua Cloudflare tunnel)"
    echo
    echo "🔧 Thiết lập WordPress lần đầu:"
    echo "  1. Mở http://localhost:8080 trong browser"
    echo "  2. Chọn ngôn ngữ"
    echo "  3. Nhập thông tin site:"
    echo "     - Site Title: NextFlow"
    echo "     - Username: admin"
    echo "     - Password: nextflow@2025"
    echo "     - Email: admin@nextflow.vn"
    echo "  4. Hoàn thành cài đặt"
    echo
    echo "📋 Kiểm tra logs nếu cần:"
    echo "  docker logs wordpress"
    echo
    echo "🔄 Restart WordPress nếu cần:"
    echo "  docker-compose restart wordpress"
    echo
}

# Hàm hiển thị thông tin debug
show_debug_info() {
    show_banner "THÔNG TIN DEBUG"
    
    log_info "Thông tin containers:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(wordpress|mariadb)"
    
    echo
    log_info "WordPress logs (10 dòng cuối):"
    docker logs wordpress --tail 10 2>&1 || echo "Không thể lấy logs"
    
    echo
    log_info "MariaDB status:"
    if check_service_running "mariadb"; then
        docker exec mariadb mariadb -u root -p"nextflow@2025" -e "SHOW DATABASES;" 2>/dev/null || echo "Không thể kết nối MariaDB"
    else
        echo "MariaDB không chạy"
    fi
}

# Main execution
main() {
    show_banner "NEXTFLOW DOCKER - SỬA LỖI WORDPRESS"
    
    echo "🔧 Bắt đầu sửa lỗi WordPress PHP parse error..."
    echo
    
    # Chuyển đến thư mục gốc của project
    cd "$(dirname "$0")/.."
    
    # Sửa lỗi WordPress
    if fix_wordpress_error; then
        echo
        if check_wordpress_status; then
            echo
            show_next_steps
            return 0
        else
            echo
            log_error "WordPress vẫn có vấn đề sau khi sửa"
            show_debug_info
            return 1
        fi
    else
        log_error "Không thể sửa lỗi WordPress"
        return 1
    fi
}

# Chạy script
main "$@"
