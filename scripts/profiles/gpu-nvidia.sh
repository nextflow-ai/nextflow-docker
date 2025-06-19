#!/bin/bash

# ============================================================================
# NEXTFLOW DOCKER - PROFILE GPU-NVIDIA
# ============================================================================
# Tác giả: NextFlow Development Team
# Phiên bản: 1.0
# Ngày cập nhật: 2025-06-17
#
# MÔ TẢ:
# Profile này triển khai các dịch vụ AI với hỗ trợ GPU NVIDIA.
# Bao gồm Ollama với GPU acceleration và Open-WebUI.
#
# ĐIỀU KIỆN TIÊN QUYẾT:
# - NVIDIA GPU driver đã được cài đặt
# - NVIDIA Container Toolkit đã được cài đặt
# - Docker hỗ trợ GPU runtime
#
# DỊCH VỤ TRIỂN KHAI:
# - Ollama (GPU-accelerated) - Cổng 11434
# - Open-WebUI - Cổng 5080
# ============================================================================

# Import các thư viện cần thiết
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/logging.sh"
source "$SCRIPT_DIR/../utils/docker.sh"
source "$SCRIPT_DIR/../utils/validation.sh"

# ============================================================================
# CẤU HÌNH PROFILE GPU-NVIDIA
# ============================================================================

# Tên profile
PROFILE_NAME="gpu-nvidia"

# Danh sách services cần triển khai (service names trong docker-compose.yml)
GPU_SERVICES=(
    "ollama-gpu"
    "open-webui"
    "ollama-pull-llama-gpu"
)

# Container names tương ứng (để kiểm tra status)
GPU_CONTAINERS=(
    "ollama"
    "open-webui"
    "ollama-pull-llama"
)

# Cổng dịch vụ
OLLAMA_PORT="11434"
OPEN_WEBUI_PORT="5080"

# ============================================================================
# FUNCTIONS KIỂM TRA GPU
# ============================================================================

# Hàm kiểm tra NVIDIA GPU
check_nvidia_gpu() {
    log_info "🔍 Kiểm tra NVIDIA GPU..."
    
    # Kiểm tra nvidia-smi
    if ! command -v nvidia-smi >/dev/null 2>&1; then
        log_error "❌ nvidia-smi không tìm thấy. Vui lòng cài đặt NVIDIA driver"
        return 1
    fi
    
    # Kiểm tra GPU có sẵn
    if ! nvidia-smi >/dev/null 2>&1; then
        log_error "❌ Không thể truy cập NVIDIA GPU"
        return 1
    fi
    
    # Hiển thị thông tin GPU
    log_info "📊 Thông tin GPU:"
    nvidia-smi --query-gpu=name,memory.total,driver_version --format=csv,noheader,nounits | while read line; do
        log_info "  GPU: $line"
    done
    
    log_success "✅ NVIDIA GPU sẵn sàng"
    return 0
}

# Hàm kiểm tra Docker GPU support
check_docker_gpu() {
    log_info "🔍 Kiểm tra Docker GPU support..."
    
    # Kiểm tra nvidia-container-runtime
    if ! docker info 2>/dev/null | grep -q "nvidia"; then
        log_warning "⚠️ Docker chưa được cấu hình để sử dụng GPU"
        log_info "💡 Hướng dẫn cài đặt NVIDIA Container Toolkit:"
        log_info "   https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html"
    fi
    
    # Test GPU access trong Docker
    log_info "🧪 Test GPU access trong Docker..."
    if docker run --rm --gpus all nvidia/cuda:11.8-base-ubuntu20.04 nvidia-smi >/dev/null 2>&1; then
        log_success "✅ Docker có thể truy cập GPU"
        return 0
    else
        log_warning "⚠️ Docker không thể truy cập GPU, sẽ chạy ở chế độ CPU"
        return 1
    fi
}

# ============================================================================
# FUNCTIONS TRIỂN KHAI
# ============================================================================

# Hàm kiểm tra điều kiện tiên quyết
check_gpu_prerequisites() {
    log_info "🔍 Kiểm tra điều kiện tiên quyết cho GPU profile..."
    
    local errors=0
    
    # 1. Kiểm tra Docker và Docker Compose
    if ! check_docker || ! check_docker_compose; then
        log_error "❌ Docker hoặc Docker Compose không sẵn sàng"
        ((errors++))
    fi
    
    # 2. Kiểm tra NVIDIA GPU (không bắt buộc)
    if check_nvidia_gpu; then
        check_docker_gpu || log_warning "⚠️ Sẽ chạy ở chế độ CPU fallback"
    else
        log_warning "⚠️ Không tìm thấy NVIDIA GPU, sẽ chạy ở chế độ CPU"
    fi
    
    # 3. Kiểm tra ports
    local ports=("$OLLAMA_PORT" "$OPEN_WEBUI_PORT")
    for port in "${ports[@]}"; do
        if is_port_in_use "$port"; then
            log_warning "⚠️ Cổng $port đang được sử dụng"
        fi
    done
    
    # 4. Kiểm tra dung lượng ổ cứng (tối thiểu 10GB cho models)
    local available_space=$(df . | awk 'NR==2 {print $4}')
    local required_space=10485760  # 10GB in KB
    
    if [[ $available_space -lt $required_space ]]; then
        log_warning "⚠️ Dung lượng ổ cứng có thể không đủ (khuyến nghị ít nhất 10GB cho AI models)"
    fi
    
    if [[ $errors -gt 0 ]]; then
        log_error "❌ Tìm thấy $errors lỗi nghiêm trọng"
        return 1
    fi
    
    log_success "✅ Điều kiện tiên quyết đã được đáp ứng"
    return 0
}

# Hàm dừng GPU services hiện tại
stop_gpu_services() {
    log_info "🛑 Dừng GPU services hiện tại..."

    for container in "${GPU_CONTAINERS[@]}"; do
        if is_container_running "$container"; then
            log_info "Dừng container: $container"
            docker stop "$container" 2>/dev/null || true
            docker rm "$container" 2>/dev/null || true
        fi
    done

    log_success "✅ Đã dừng tất cả GPU services hiện tại"
}

# Hàm triển khai GPU services
deploy_gpu_services() {
    log_info "🚀 Triển khai GPU services..."
    
    # Pull images first
    log_info "📥 Tải GPU service images..."
    for service in "${GPU_SERVICES[@]}"; do
        log_debug "Pulling $service image..."
        $DOCKER_COMPOSE -f "$COMPOSE_FILE" pull "$service" 2>/dev/null || {
            log_warning "Không thể tải image cho $service, sẽ sử dụng image có sẵn"
        }
    done
    
    # Deploy services
    log_loading "Khởi động GPU services..."
    for service in "${GPU_SERVICES[@]}"; do
        log_debug "Starting $service..."
        $DOCKER_COMPOSE -f "$COMPOSE_FILE" up -d "$service" || {
            log_warning "Không thể khởi động $service"
        }
    done
    
    log_success "✅ Đã triển khai GPU services!"
}

# Hàm kiểm tra trạng thái GPU services
check_gpu_status() {
    log_info "📊 Kiểm tra trạng thái GPU services..."

    local all_healthy=true

    for container in "${GPU_CONTAINERS[@]}"; do
        if is_container_running "$container"; then
            log_success "✅ $container: Đang chạy"

            # Kiểm tra health cụ thể
            case "$container" in
                "ollama")
                    if curl -s http://localhost:$OLLAMA_PORT/api/tags >/dev/null 2>&1; then
                        log_success "✅ Ollama API: Hoạt động"
                    else
                        log_warning "⚠️ Ollama API: Chưa sẵn sàng"
                    fi
                    ;;
                "open-webui")
                    if curl -s http://localhost:$OPEN_WEBUI_PORT >/dev/null 2>&1; then
                        log_success "✅ Open-WebUI: Hoạt động"
                    else
                        log_warning "⚠️ Open-WebUI: Chưa sẵn sàng"
                    fi
                    ;;
                "ollama-pull-llama")
                    log_info "ℹ️ $container: Init container (chạy một lần)"
                    ;;
            esac
        else
            log_error "❌ $container: Không chạy"
            all_healthy=false
        fi
    done

    if [[ "$all_healthy" == "true" ]]; then
        log_success "🎉 Tất cả GPU services hoạt động bình thường!"
        return 0
    else
        log_error "❌ Một số GPU services có vấn đề"
        return 1
    fi
}

# Hàm hiển thị thông tin truy cập
show_gpu_access_info() {
    log_info "🌐 Thông tin truy cập GPU services:"
    echo
    echo "🤖 Ollama (AI Model Server):"
    echo "   🔗 API Endpoint: http://localhost:${OLLAMA_PORT}"
    echo "   📋 List Models: curl http://localhost:${OLLAMA_PORT}/api/tags"
    echo "   💬 Chat API: http://localhost:${OLLAMA_PORT}/api/chat"
    echo
    echo "🌐 Open-WebUI (Chat Interface):"
    echo "   🔗 Web Interface: http://localhost:${OPEN_WEBUI_PORT}"
    echo "   👤 Đăng ký tài khoản đầu tiên sẽ trở thành admin"
    echo
    echo "🔧 Lệnh quản lý hữu ích:"
    echo "   📋 Xem models: docker exec ollama ollama list"
    echo "   📥 Tải model: docker exec ollama ollama pull llama2"
    echo "   💬 Chat CLI: docker exec -it ollama ollama run llama2"
    echo "   📝 Xem logs: docker logs ollama"
    echo
    echo "🎯 Models khuyến nghị:"
    echo "   • llama2:7b (4GB VRAM)"
    echo "   • codellama:7b (4GB VRAM)"
    echo "   • mistral:7b (4GB VRAM)"
    echo "   • llama2:13b (8GB VRAM)"
    echo
}

# ============================================================================
# FUNCTION CHÍNH - TRIỂN KHAI GPU PROFILE
# ============================================================================

# Hàm chính triển khai gpu-nvidia profile
deploy_gpu_nvidia() {
    local force_deploy="${1:-false}"
    
    show_banner "🎮 TRIỂN KHAI GPU-NVIDIA PROFILE"
    
    log_info "🚀 Bắt đầu triển khai GPU services với NVIDIA acceleration..."
    
    # 1. Kiểm tra điều kiện tiên quyết
    if ! check_gpu_prerequisites; then
        if [[ "$force_deploy" != "true" ]]; then
            log_error "❌ Điều kiện tiên quyết không được đáp ứng"
            return 1
        else
            log_warning "⚠️ Bỏ qua lỗi điều kiện tiên quyết (force deploy)"
        fi
    fi
    
    # 2. Dừng GPU services hiện tại (chỉ GPU services)
    stop_gpu_services
    
    # 3. Triển khai GPU services
    if ! deploy_gpu_services; then
        log_error "❌ Triển khai GPU services thất bại"
        return 1
    fi
    
    # 4. Đợi services khởi động
    log_info "⏳ Đợi GPU services khởi động..."
    sleep 15
    
    # 5. Kiểm tra trạng thái cuối cùng
    if check_gpu_status; then
        log_success "🎉 Triển khai GPU-NVIDIA profile hoàn tất thành công!"
        show_gpu_access_info
        return 0
    else
        log_error "❌ Triển khai có một số vấn đề"
        log_info "💡 Kiểm tra logs để biết thêm chi tiết:"
        log_info "   docker logs ollama"
        log_info "   docker logs open-webui"
        log_info "   docker logs ollama-pull-llama"
        return 1
    fi
}

# ============================================================================
# EXPORT FUNCTIONS
# ============================================================================

# Export các functions để có thể sử dụng từ bên ngoài
export -f deploy_gpu_nvidia
export -f check_gpu_status
export -f show_gpu_access_info
