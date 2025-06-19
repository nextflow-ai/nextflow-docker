#!/bin/bash

# AI profile deployment for NextFlow Docker
# Author: Augment Agent
# Version: 1.0
#
# Services included:
# - Ollama (CPU/GPU) - Local AI models
# - Open WebUI - AI chat interface
# - Cloudflare Tunnel AI - External access

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Load environment variables
if [[ -f "$PROJECT_ROOT/.env" ]]; then
    source "$PROJECT_ROOT/.env"
else
    echo "❌ File .env không tồn tại tại: $PROJECT_ROOT/.env"
    exit 1
fi

source "$SCRIPT_DIR/../utils/logging.sh"
source "$SCRIPT_DIR/../utils/docker.sh"
source "$SCRIPT_DIR/../utils/validation.sh"

# Profile configuration
PROFILE_NAME="ai"
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.yml}"

# Services in AI profile - CHỈ AI SERVICES
AI_SERVICES=(
    "ollama"           # Ollama server (GPU-enabled)
    "open-webui"       # AI chat interface
)

# Cloudflare tunnel - SỬ DỤNG TUNNEL CHÍNH (không phải cloudflare-tunnel-ai)
AI_TUNNEL_SERVICE="cloudflare-tunnel"

# Required ports for AI profile
AI_PORTS=(
    "11434:Ollama"
    "5080:Open WebUI"
)

# Deploy AI profile
deploy_ai() {
    local force_deploy="${1:-false}"

    show_banner "TRIỂN KHAI PROFILE AI"

    # Show services to be deployed
    log_info "Profile AI bao gồm các dịch vụ:"
    for service in "${AI_SERVICES[@]}"; do
        log_info "  ✓ $service"
    done
    echo

    # Validate requirements
    if ! validate_profile_requirements "$PROFILE_NAME"; then
        log_warning "Một số yêu cầu không được đáp ứng, nhưng sẽ tiếp tục triển khai..."
    fi

    # Kiểm tra AI containers hiện tại
    check_existing_ai_containers

    # Create AI directories
    create_ai_directories

    # Deploy AI services
    deploy_ai_services

    # Wait for services to be ready
    wait_for_ai_services

    # Deploy Cloudflare tunnel if configured
    deploy_ai_tunnel

    # Show deployment summary
    show_ai_summary
}

# Kiểm tra AI containers đang chạy để tránh dừng không cần thiết
check_existing_ai_containers() {
    log_info "🔍 Kiểm tra AI containers đang chạy..."

    local running_containers=()
    local containers_to_deploy=()

    # Kiểm tra AI services
    for service in "${AI_SERVICES[@]}"; do
        if is_container_running "$service"; then
            running_containers+=("$service")
            log_info "✅ $service đang chạy - sẽ được giữ nguyên và apply cấu hình mới"
        else
            containers_to_deploy+=("$service")
            log_info "📦 $service chưa chạy - sẽ được triển khai"
        fi
    done

    # Thông báo tối ưu
    if [[ ${#running_containers[@]} -gt 0 ]]; then
        log_success "🎯 Tối ưu: Giữ nguyên ${#running_containers[@]} AI containers đang chạy: ${running_containers[*]}"
    fi

    if [[ ${#containers_to_deploy[@]} -gt 0 ]]; then
        log_info "📦 Sẽ triển khai ${#containers_to_deploy[@]} containers: ${containers_to_deploy[*]}"
    else
        log_success "🎉 Tất cả AI services đã đang chạy!"
        log_info "� Vẫn sẽ apply cấu hình mới cho tất cả services..."
    fi
}

# Deploy AI services - FUNCTION CHÍNH
deploy_ai_services() {
    log_info "🚀 Triển khai AI services..."

    # Kiểm tra GPU support
    local use_gpu=false
    if docker exec ollama nvidia-smi >/dev/null 2>&1; then
        log_success "✅ GPU support detected - sử dụng Ollama GPU"
        use_gpu=true
    else
        log_info "ℹ️ Không có GPU support - sử dụng Ollama CPU"
        use_gpu=false
    fi

    # Deploy Ollama (GPU hoặc CPU)
    if [[ "$use_gpu" == "true" ]]; then
        log_loading "Khởi động/cập nhật Ollama (GPU)..."
        $DOCKER_COMPOSE -f "$COMPOSE_FILE" --profile gpu-nvidia up -d ollama-gpu ollama-pull-llama-gpu
    else
        log_loading "Khởi động/cập nhật Ollama (CPU)..."
        $DOCKER_COMPOSE -f "$COMPOSE_FILE" --profile cpu up -d ollama-cpu ollama-pull-llama-cpu
    fi

    # Đợi Ollama sẵn sàng
    log_info "⏳ Đợi Ollama khởi động..."
    wait_for_container_health "ollama" 60

    # Deploy Open WebUI
    log_loading "Khởi động/cập nhật Open WebUI..."
    $DOCKER_COMPOSE -f "$COMPOSE_FILE" up -d open-webui

    log_success "✅ Đã triển khai AI services!"
}

# Loại bỏ function check_basic_services_for_ai vì AI profile chỉ cần Ollama và Open-WebUI

# Create AI directories
create_ai_directories() {
    log_info "Tạo các thư mục AI..."

    local directories=(
        "ollama/models"
        "open-webui/data"
    )

    for dir in "${directories[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            log_debug "Tạo thư mục: $dir"
        fi
    done

    log_success "Đã tạo các thư mục AI!"
}

# Deploy Cloudflare tunnel for AI profile
deploy_ai_tunnel() {
    log_info "🌐 Triển khai Cloudflare tunnel cho AI services..."

    # Sử dụng cloudflare-tunnel chính (không phải cloudflare-tunnel-ai)
    if is_container_running "$AI_TUNNEL_SERVICE"; then
        log_info "🔄 Restart $AI_TUNNEL_SERVICE để áp dụng cấu hình mới..."
        docker restart "$AI_TUNNEL_SERVICE"
    else
        log_info "🚀 Khởi động $AI_TUNNEL_SERVICE..."
        if ! $DOCKER_COMPOSE -f "$COMPOSE_FILE" up -d "$AI_TUNNEL_SERVICE" --no-deps; then
            log_warning "⚠️ Không thể khởi động $AI_TUNNEL_SERVICE (có thể do thiếu credentials)"
            log_info "💡 Để cấu hình Cloudflare tunnel:"
            log_info "  1. Kiểm tra credentials trong cloudflared/credentials/"
            log_info "  2. Cập nhật config trong cloudflared/config/cloudflared-config.yml"
            return 0
        fi
    fi

    # Chờ tunnel kết nối
    log_info "⏳ Chờ Cloudflare tunnel kết nối..."
    sleep 10

    # Kiểm tra logs để đảm bảo tunnel hoạt động
    if docker logs "$AI_TUNNEL_SERVICE" 2>&1 | grep -q -E "(Connection.*registered|connected to cloudflare)"; then
        log_success "✅ Cloudflare tunnel đã kết nối thành công!"

        # Hiển thị thông tin domains
        log_info "🌐 AI services có sẵn qua Cloudflare tunnel:"
        echo "  🤖 Open-WebUI: https://open-webui.nextflow.vn"
        echo "  🧠 Ollama API: https://ollama.nextflow.vn"

        return 0
    else
        log_warning "⚠️ Cloudflare tunnel đang chạy nhưng có thể chưa kết nối hoàn toàn"
        log_info "📋 Kiểm tra logs: docker logs $AI_TUNNEL_SERVICE"
        log_info "🔧 Kiểm tra cấu hình: cloudflared/config/cloudflared-config.yml"
        return 0
    fi
}

# Đã loại bỏ deploy_ai_services_cpu - sử dụng deploy_ai_services chính

# Đã loại bỏ deploy_ai_services_gpu - sử dụng deploy_ai_services chính

# Wait for AI services
wait_for_ai_services() {
    log_info "Đợi các dịch vụ AI sẵn sàng..."

    local services_to_check=(
        "ollama:60"
        "open-webui:30"
    )

    for service_timeout in "${services_to_check[@]}"; do
        local service="${service_timeout%:*}"
        local timeout="${service_timeout#*:}"

        # Check if container exists (ollama-cpu or ollama-gpu)
        if is_container_running "ollama-cpu" || is_container_running "ollama-gpu"; then
            service="ollama"
        fi

        log_loading "Kiểm tra $service..."
        if wait_for_container_health "$service" "$timeout"; then
            log_success "$service đã sẵn sàng!"
        else
            log_warning "$service có thể chưa sẵn sàng hoàn toàn."
        fi
    done
}

# Download AI models
download_ai_models() {
    local use_gpu="$1"

    log_info "Tải các mô hình AI..."

    # Check if model download container is running
    local model_container=""
    if [[ "$use_gpu" == "true" ]]; then
        model_container="ollama-pull-llama-gpu"
    else
        model_container="ollama-pull-llama-cpu"
    fi

    if is_container_running "$model_container"; then
        log_info "Container tải mô hình đang chạy: $model_container"
        log_info "Quá trình tải mô hình có thể mất vài phút..."

        # Show progress
        local timeout=600  # 10 minutes
        local elapsed=0
        while is_container_running "$model_container" && [[ $elapsed -lt $timeout ]]; do
            show_progress $elapsed $timeout
            sleep 10
            elapsed=$((elapsed + 10))
        done

        if [[ $elapsed -ge $timeout ]]; then
            log_warning "Quá trình tải mô hình mất quá lâu. Kiểm tra logs:"
            echo "  docker logs $model_container"
        else
            log_success "Đã tải xong các mô hình AI!"
        fi
    else
        log_warning "Container tải mô hình không chạy. Có thể cần tải mô hình thủ công."
        log_info "Để tải mô hình thủ công:"
        echo "  docker exec -it ollama ollama pull llama3.1"
        echo "  docker exec -it ollama ollama pull nomic-embed-text"
    fi
}

# Show AI summary
show_ai_summary() {
    show_banner "TỔNG KẾT TRIỂN KHAI AI"

    log_success "Profile AI đã được triển khai thành công!"
    echo

    # Kiểm tra GPU support
    local use_gpu=false
    if docker exec ollama nvidia-smi >/dev/null 2>&1; then
        use_gpu=true
    fi

    log_info "Các dịch vụ AI đã triển khai:"
    echo
    if [[ "$use_gpu" == "true" ]]; then
        echo "🚀 AI Stack (GPU):"
        echo "  • Ollama (GPU)  : http://localhost:11434"
    else
        echo "🚀 AI Stack (CPU):"
        echo "  • Ollama (CPU)  : http://localhost:11434"
    fi
    echo "  • Open WebUI    : http://localhost:5080"
    echo

    # Show Cloudflare tunnel info if running
    if is_container_running "$AI_TUNNEL_SERVICE"; then
        echo "🌐 Cloudflare Tunnel:"
        echo "  • Status        : ✅ Đang chạy"
        if [[ -n "${CLOUDFLARE_TUNNEL_ID:-}" ]]; then
            echo "  • Tunnel ID     : ${CLOUDFLARE_TUNNEL_ID}"
        fi
        echo "  • External URLs : Xem trong Cloudflare Dashboard"
        echo
    else
        echo "🌐 Cloudflare Tunnel:"
        echo "  • Status        : ❌ Chưa khởi động"
        echo
    fi

    log_info "Hướng dẫn sử dụng:"
    echo "  1. Truy cập Open WebUI tại http://localhost:5080"
    echo "  2. Tạo tài khoản admin (người đăng ký đầu tiên)"
    echo "  3. Chọn mô hình AI từ danh sách có sẵn"
    echo "  4. Bắt đầu chat với AI"
    echo

    log_info "Các mô hình AI có sẵn:"
    echo "  • llama3.1 - Mô hình chat đa năng"
    echo "  • nomic-embed-text - Mô hình embedding"
    echo "  • gemma2:2b - Mô hình nhẹ"
    echo "  • deepseek-r1:7b - Mô hình reasoning"
    echo

    log_info "Để tải thêm mô hình:"
    echo "  docker exec -it ollama ollama pull <model_name>"
    echo

    log_info "Để xem danh sách mô hình đã tải:"
    echo "  docker exec -it ollama ollama list"
    echo

    # Check service status
    log_info "Trạng thái các container AI:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(ollama|open-webui)"

    # Show GPU info if available
    if [[ "$use_gpu" == "true" ]] && docker exec ollama nvidia-smi >/dev/null 2>&1; then
        echo
        log_info "Thông tin GPU:"
        docker exec ollama nvidia-smi --query-gpu=name,memory.total,memory.used --format=csv,noheader,nounits
    fi
}

# Stop AI services
stop_ai() {
    show_banner "DỪNG PROFILE AI"

    log_info "Dừng các dịch vụ AI..."

    # Stop both CPU and GPU profiles
    $DOCKER_COMPOSE -f "$COMPOSE_FILE" --profile cpu down 2>/dev/null || true
    $DOCKER_COMPOSE -f "$COMPOSE_FILE" --profile gpu-nvidia down 2>/dev/null || true

    # Stop Open WebUI
    docker stop open-webui 2>/dev/null || true

    log_success "Đã dừng tất cả các dịch vụ AI!"
}

# Export functions
export -f deploy_ai stop_ai
export -f create_ai_directories deploy_ai_services deploy_ai_tunnel
export -f wait_for_ai_services show_ai_summary
