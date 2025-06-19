#!/bin/bash

# ============================================================================
# NEXTFLOW DOCKER - QUICK STATUS & PORT CHECK
# ============================================================================
# Script kiểm tra nhanh trạng thái các dịch vụ và port conflicts

set -e

# === COLORS ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# === LOGGING FUNCTIONS ===
log_info() { echo -e "${BLUE}ℹ️ [INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}✅ [SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}⚠️ [WARNING]${NC} $1"; }
log_error() { echo -e "${RED}❌ [ERROR]${NC} $1"; }

show_banner() {
    echo "============================================================"
    echo "           🔍 NEXTFLOW QUICK STATUS & PORT CHECK"
    echo "============================================================"
}

# Port mapping configuration
declare -A host_ports
declare -A container_ports

# Basic profile ports
host_ports[5432]="postgres"
host_ports[6379]="redis"
host_ports[8082]="redis-commander"
host_ports[6333]="qdrant"
host_ports[6334]="qdrant"
host_ports[5672]="rabbitmq"
host_ports[15672]="rabbitmq"
host_ports[3306]="mariadb"
host_ports[8080]="wordpress"

# AI profile ports
host_ports[7856]="n8n"
host_ports[4001]="flowise"
host_ports[7860]="langflow"
host_ports[11434]="ollama"
host_ports[5080]="open-webui"

# Monitoring profile ports
host_ports[9090]="prometheus"
host_ports[3030]="grafana"
host_ports[3100]="loki"
host_ports[9100]="node-exporter"
host_ports[8081]="cadvisor"

# GitLab profile ports
host_ports[8088]="gitlab"
host_ports[8443]="gitlab"
host_ports[2222]="gitlab"

# Mail profile ports
host_ports[25]="stalwart"
host_ports[587]="stalwart"
host_ports[465]="stalwart"
host_ports[143]="stalwart"
host_ports[993]="stalwart"
host_ports[110]="stalwart"
host_ports[995]="stalwart"
host_ports[8090]="stalwart"
host_ports[4190]="stalwart"

# Check port conflicts function
check_port_conflicts() {
    echo
    log_info "🔍 KIỂM TRA XUNG ĐỘT PORTS..."

    declare -A port_count
    for port in "${!host_ports[@]}"; do
        ((port_count[$port]++))
    done

    local conflicts=0
    for port in "${!port_count[@]}"; do
        if [[ ${port_count[$port]} -gt 1 ]]; then
            log_error "❌ XUNG ĐỘT HOST PORT $port"
            ((conflicts++))
        fi
    done

    if [[ $conflicts -eq 0 ]]; then
        log_success "✅ Không có xung đột HOST PORTS"
    else
        log_warning "⚠️ Phát hiện $conflicts xung đột ports"
    fi

    return $conflicts
}

# Check containers function
check_containers() {
    log_info "🔍 Kiểm tra containers..."

    local containers=("postgres" "redis" "redis-commander" "qdrant" "mariadb" "wordpress" "n8n" "flowise" "cloudflare-tunnel")
    local running=0
    local total=${#containers[@]}

    for container in "${containers[@]}"; do
        if docker ps --format "{{.Names}}" | grep -q "^${container}$"; then
            log_success "✅ $container đang chạy"
            ((running++))
        else
            log_error "❌ $container không chạy"
        fi
    done

    echo
    log_info "📊 Tổng kết containers: $running/$total đang chạy"

    if [[ $running -eq $total ]]; then
        log_success "🎉 Tất cả containers đang chạy!"
    else
        log_warning "⚠️ Một số containers chưa chạy"
    fi

    return $((total - running))
}

# Check services function
check_services() {
    echo
    log_info "🌐 Kiểm tra services..."

    # WordPress
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8080 | grep -qE "^(200|302)$"; then
        log_success "✅ WordPress truy cập được"
    else
        log_error "❌ WordPress không truy cập được"
    fi

    # n8n
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:7856 | grep -qE "^(200|302)$"; then
        log_success "✅ n8n truy cập được"
    else
        log_warning "⚠️ n8n không truy cập được (có thể chưa chạy)"
    fi

    # Flowise
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:4001 | grep -qE "^(200|302)$"; then
        log_success "✅ Flowise truy cập được"
    else
        log_warning "⚠️ Flowise không truy cập được (có thể chưa chạy)"
    fi
}

# Check databases function
check_databases() {
    echo
    log_info "🗄️ Kiểm tra databases..."

    # PostgreSQL
    if docker exec postgres psql -U nextflow -d postgres -c "SELECT 1;" >/dev/null 2>&1; then
        log_success "✅ PostgreSQL kết nối OK"
    else
        log_error "❌ PostgreSQL kết nối thất bại"
    fi

    # MariaDB
    if docker exec mariadb mariadb -u nextflow -pnextflow@2025 -e "SELECT 1;" >/dev/null 2>&1; then
        log_success "✅ MariaDB kết nối OK"
    else
        log_error "❌ MariaDB kết nối thất bại"
    fi

    # Redis
    if docker exec redis redis-cli -a nextflow@2025 ping >/dev/null 2>&1; then
        log_success "✅ Redis kết nối OK"
    else
        log_error "❌ Redis kết nối thất bại"
    fi
}

# Show access info function
show_access_info() {
    echo
    log_info "💡 THÔNG TIN TRUY CẬP:"
    echo "  • WordPress      : http://localhost:8080"
    echo "  • n8n Automation : http://localhost:7856"
    echo "  • Flowise AI     : http://localhost:4001"
    echo "  • Redis Commander: http://localhost:8082"
    echo "  • RabbitMQ       : http://localhost:15672"
    echo "  • Qdrant         : http://localhost:6333"
    echo
    log_info "🔑 THÔNG TIN ĐĂNG NHẬP:"
    echo "  • RabbitMQ       : admin/admin"
    echo "  • Redis Commander: admin/nextflow@2025"
    echo "  • Database       : nextflow/nextflow@2025"
    echo
    log_info "📊 MONITORING (nếu đã triển khai):"
    echo "  • Prometheus     : http://localhost:9090"
    echo "  • Grafana        : http://localhost:3030 (admin/admin)"
    echo "  • Loki           : http://localhost:3100"
}

# Main function
main() {
    local check_type="${1:-all}"

    show_banner

    case "$check_type" in
        "containers"|"c")
            check_containers
            ;;
        "ports"|"p")
            check_port_conflicts
            ;;
        "services"|"s")
            check_services
            ;;
        "databases"|"db")
            check_databases
            ;;
        "info"|"i")
            show_access_info
            ;;
        "all"|*)
            check_containers
            check_services
            check_databases
            check_port_conflicts
            show_access_info
            ;;
    esac
}

# Run main with arguments
main "$@"
