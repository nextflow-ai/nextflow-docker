#!/bin/bash

# ============================================================================
# SCRIPT KIỂM TRA TỐI ƯU HÓA NEXTFLOW DOCKER
# ============================================================================
# Tác giả: Augment Agent
# Phiên bản: 1.0
# Ngày tạo: 2025-06-16
# 
# MÔ TẢ:
# Script này kiểm tra và xác thực tất cả các tối ưu hóa đã được thực hiện:
# - Đồng bộ hóa port mapping
# - Cấu hình WordPress
# - Cloudflare tunnel optimization
# - Loại bỏ code dư thừa
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

# Biến đếm lỗi
ERROR_COUNT=0
WARNING_COUNT=0

# Hàm kiểm tra port mapping consistency
check_port_consistency() {
    show_banner "KIỂM TRA ĐỒNG BỘ PORT MAPPING"
    
    log_info "Kiểm tra port mapping giữa docker-compose.yml và scripts..."
    
    # Kiểm tra n8n port
    if grep -q "8003:5678" docker-compose.yml && grep -q "8003:n8n" scripts/profiles/basic.sh; then
        log_success "n8n port mapping đồng bộ (8003)"
    else
        log_error "n8n port mapping không đồng bộ"
        ((ERROR_COUNT++))
    fi
    
    # Kiểm tra Redis Commander port
    if grep -q "6101:8081" docker-compose.yml && grep -q "6101:Redis Commander" scripts/profiles/basic.sh; then
        log_success "Redis Commander port mapping đồng bộ (6101)"
    else
        log_error "Redis Commander port mapping không đồng bộ"
        ((ERROR_COUNT++))
    fi
    
    # Kiểm tra Open WebUI port
    if grep -q "8002:8080" docker-compose.yml; then
        log_success "Open WebUI port mapping đúng (8002)"
    else
        log_error "Open WebUI port mapping không đúng"
        ((ERROR_COUNT++))
    fi
    
    # Kiểm tra Stalwart Mail port
    if grep -q "MAIL_ADMIN_PORT:-8005.*:80" docker-compose.yml; then
        log_success "Stalwart Mail port mapping đúng (8005)"
    else
        log_error "Stalwart Mail port mapping không đúng"
        ((ERROR_COUNT++))
    fi
}

# Hàm kiểm tra cấu hình WordPress
check_wordpress_config() {
    show_banner "KIỂM TRA CẤU HÌNH WORDPRESS"

    log_info "Kiểm tra cấu hình database WordPress..."

    # Kiểm tra environment variables trong docker-compose.yml
    if grep -q "WORDPRESS_DB_HOST=mariadb:3306" docker-compose.yml; then
        log_success "WordPress DB host đúng"
    else
        log_error "WordPress DB host không đúng"
        ((ERROR_COUNT++))
    fi

    if grep -q "WORDPRESS_DB_NAME=\${MYSQL_DATABASE" docker-compose.yml; then
        log_success "WordPress DB name sử dụng biến môi trường"
    else
        log_error "WordPress DB name không sử dụng biến môi trường"
        ((ERROR_COUNT++))
    fi

    if grep -q "WORDPRESS_DB_USER=\${MYSQL_USER" docker-compose.yml; then
        log_success "WordPress DB user sử dụng biến môi trường"
    else
        log_error "WordPress DB user không sử dụng biến môi trường"
        ((ERROR_COUNT++))
    fi

    # Kiểm tra không còn WORDPRESS_CONFIG_EXTRA gây lỗi
    if ! grep -q "WORDPRESS_CONFIG_EXTRA=.*define.*define" docker-compose.yml; then
        log_success "Đã loại bỏ WORDPRESS_CONFIG_EXTRA gây PHP parse error"
    else
        log_error "Vẫn còn WORDPRESS_CONFIG_EXTRA có thể gây lỗi"
        ((ERROR_COUNT++))
    fi
}

# Hàm kiểm tra Cloudflare tunnel optimization
check_cloudflare_optimization() {
    show_banner "KIỂM TRA TỐI ƯU HÓA CLOUDFLARE TUNNELS"
    
    log_info "Kiểm tra số lượng Cloudflare tunnels..."
    
    # Đếm số tunnels services trong docker-compose.yml (chỉ đếm service definitions)
    tunnel_count=$(grep -c "^  cloudflare-tunnel" docker-compose.yml || echo "0")
    
    if [ "$tunnel_count" -le 3 ]; then
        log_success "Số lượng Cloudflare tunnels đã được tối ưu ($tunnel_count tunnels)"
    else
        log_warning "Vẫn còn quá nhiều Cloudflare tunnels ($tunnel_count tunnels)"
        ((WARNING_COUNT++))
    fi
    
    # Kiểm tra các file config đã bị xóa
    removed_configs=("cloudflared-messaging-config.yml" "cloudflared-docs-config.yml" "cloudflared-dev-config.yml" "cloudflared-storage-config.yml" "cloudflared-analytics-config.yml")
    
    for config in "${removed_configs[@]}"; do
        if [ ! -f "cloudflared/config/$config" ]; then
            log_success "Đã xóa file config dư thừa: $config"
        else
            log_warning "File config dư thừa vẫn tồn tại: $config"
            ((WARNING_COUNT++))
        fi
    done
}

# Hàm kiểm tra environment variables consistency
check_env_consistency() {
    show_banner "KIỂM TRA ĐỒNG BỘ ENVIRONMENT VARIABLES"
    
    log_info "Kiểm tra consistency giữa .env và docker-compose.yml..."
    
    # Kiểm tra n8n port
    if grep -q "N8N_PORT=8003" .env; then
        log_success "N8N_PORT trong .env đúng (8003)"
    else
        log_error "N8N_PORT trong .env không đúng"
        ((ERROR_COUNT++))
    fi
    
    # Kiểm tra Flowise port
    if grep -q "FLOWISE_PORT=8001" .env; then
        log_success "FLOWISE_PORT trong .env đúng (8001)"
    else
        log_error "FLOWISE_PORT trong .env không đúng"
        ((ERROR_COUNT++))
    fi
    
    # Kiểm tra Open WebUI port
    if grep -q "OPENWEBUI_PORT=8002" .env; then
        log_success "OPENWEBUI_PORT trong .env đúng (8002)"
    else
        log_error "OPENWEBUI_PORT trong .env không đúng"
        ((ERROR_COUNT++))
    fi
    
    # Kiểm tra Mail admin port
    if grep -q "MAIL_ADMIN_PORT=8005" .env; then
        log_success "MAIL_ADMIN_PORT trong .env đúng (8005)"
    else
        log_error "MAIL_ADMIN_PORT trong .env không đúng"
        ((ERROR_COUNT++))
    fi
}

# Hàm kiểm tra Cloudflare tunnel config ports
check_tunnel_config_ports() {
    show_banner "KIỂM TRA PORT TRONG CLOUDFLARE TUNNEL CONFIGS"
    
    log_info "Kiểm tra port mapping trong Cloudflare tunnel configs..."
    
    # Kiểm tra AI tunnel config
    if [ -f "cloudflared/config/cloudflared-ai-config.yml" ]; then
        if grep -q "http://n8n:5678" cloudflared/config/cloudflared-ai-config.yml; then
            log_success "n8n port trong AI tunnel config đúng"
        else
            log_error "n8n port trong AI tunnel config không đúng"
            ((ERROR_COUNT++))
        fi
        
        if grep -q "http://open-webui:8080" cloudflared/config/cloudflared-ai-config.yml; then
            log_success "Open WebUI port trong AI tunnel config đúng"
        else
            log_error "Open WebUI port trong AI tunnel config không đúng"
            ((ERROR_COUNT++))
        fi
    else
        log_error "File cloudflared-ai-config.yml không tồn tại"
        ((ERROR_COUNT++))
    fi
    
    # Kiểm tra main tunnel config
    if [ -f "cloudflared/config/cloudflared-config.yml" ]; then
        if grep -q "http://stalwart-mail:80" cloudflared/config/cloudflared-config.yml; then
            log_success "Stalwart Mail port trong main tunnel config đúng"
        else
            log_error "Stalwart Mail port trong main tunnel config không đúng"
            ((ERROR_COUNT++))
        fi
    else
        log_error "File cloudflared-config.yml không tồn tại"
        ((ERROR_COUNT++))
    fi
}

# Hàm hiển thị tổng kết
show_summary() {
    show_banner "TỔNG KẾT KIỂM TRA TỐI ƯU HÓA"
    
    echo "📊 Kết quả kiểm tra:"
    echo "  • Lỗi nghiêm trọng: $ERROR_COUNT"
    echo "  • Cảnh báo: $WARNING_COUNT"
    echo
    
    if [ $ERROR_COUNT -eq 0 ] && [ $WARNING_COUNT -eq 0 ]; then
        log_success "🎉 TẤT CẢ KIỂM TRA THÀNH CÔNG! Hệ thống đã được tối ưu hóa hoàn toàn."
        echo
        echo "✅ Các tối ưu hóa đã hoàn thành:"
        echo "  • Đồng bộ hóa port mapping"
        echo "  • Sửa lỗi cấu hình WordPress"
        echo "  • Tối ưu hóa Cloudflare tunnels (giảm từ 8 xuống 3)"
        echo "  • Chuẩn hóa environment variables"
        echo "  • Loại bỏ code dư thừa"
        return 0
    elif [ $ERROR_COUNT -eq 0 ]; then
        log_warning "⚠️ Kiểm tra hoàn thành với $WARNING_COUNT cảnh báo nhỏ."
        return 0
    else
        log_error "❌ Phát hiện $ERROR_COUNT lỗi nghiêm trọng cần khắc phục!"
        return 1
    fi
}

# Main execution
main() {
    show_banner "NEXTFLOW DOCKER - KIỂM TRA TỐI ƯU HÓA"
    
    echo "🔍 Bắt đầu kiểm tra tổng thể hệ thống sau tối ưu hóa..."
    echo
    
    # Chuyển đến thư mục gốc của project
    cd "$(dirname "$0")/.."
    
    # Thực hiện các kiểm tra
    check_port_consistency
    echo
    check_wordpress_config
    echo
    check_cloudflare_optimization
    echo
    check_env_consistency
    echo
    check_tunnel_config_ports
    echo
    
    # Hiển thị tổng kết
    show_summary
}

# Chạy script
main "$@"
