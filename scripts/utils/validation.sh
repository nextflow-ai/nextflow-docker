#!/bin/bash

# Validation utilities for NextFlow Docker scripts
# Author: Augment Agent
# Version: 1.0

# Source logging utilities
source "$(dirname "${BASH_SOURCE[0]}")/logging.sh"

# Validate file exists
validate_file_exists() {
    local file_path="$1"
    local file_description="${2:-File}"
    
    if [[ ! -f "$file_path" ]]; then
        log_error "$file_description không tồn tại: $file_path"
        return 1
    fi
    
    log_debug "$file_description tồn tại: $file_path"
    return 0
}

# Validate directory exists
validate_directory_exists() {
    local dir_path="$1"
    local dir_description="${2:-Directory}"
    
    if [[ ! -d "$dir_path" ]]; then
        log_error "$dir_description không tồn tại: $dir_path"
        return 1
    fi
    
    log_debug "$dir_description tồn tại: $dir_path"
    return 0
}

# Validate docker-compose.yml
validate_docker_compose_file() {
    local compose_file="${1:-docker-compose.yml}"
    
    log_info "Kiểm tra file docker-compose: $compose_file"
    
    if ! validate_file_exists "$compose_file" "Docker Compose file"; then
        return 1
    fi
    
    # Check syntax
    if ! $DOCKER_COMPOSE -f "$compose_file" config > /dev/null 2>&1; then
        log_error "File docker-compose có lỗi cú pháp!"
        return 1
    fi
    
    log_success "File docker-compose hợp lệ!"
    return 0
}

# Validate .env file
validate_env_file() {
    local env_file="${1:-.env}"
    
    log_info "Kiểm tra file .env: $env_file"
    
    if ! validate_file_exists "$env_file" "Environment file"; then
        log_warning "File .env không tồn tại. Sẽ tạo từ .env.example nếu có."
        
        if validate_file_exists ".env.example" "Environment example file"; then
            cp .env.example "$env_file"
            log_success "Đã tạo file .env từ .env.example"
            log_warning "Vui lòng cập nhật các biến môi trường trong file .env"
        else
            log_error "Không tìm thấy file .env.example để tạo .env"
            return 1
        fi
    fi
    
    # Check for required variables
    local required_vars=(
        "POSTGRES_USER"
        "POSTGRES_PASSWORD"
        "N8N_ENCRYPTION_KEY"
        "N8N_USER_MANAGEMENT_JWT_SECRET"
    )
    
    local missing_vars=()
    for var in "${required_vars[@]}"; do
        if ! grep -q "^${var}=" "$env_file"; then
            missing_vars+=("$var")
        fi
    done
    
    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        log_warning "Các biến môi trường bị thiếu trong file .env:"
        for var in "${missing_vars[@]}"; do
            log_warning "  - $var"
        done
        log_info "Vui lòng thêm các biến này vào file .env"
    else
        log_success "File .env có đầy đủ các biến cần thiết!"
    fi
    
    return 0
}

# Validate port availability
validate_port_available() {
    local port="$1"
    local service_name="${2:-Service}"

    # Try different methods to check port availability
    if command -v netstat &> /dev/null; then
        # Windows/Linux netstat check
        if netstat -an 2>/dev/null | grep -q ":${port} "; then
            log_warning "Port $port đã được sử dụng (cần cho $service_name)"
            return 1
        fi
    elif command -v ss &> /dev/null; then
        # Linux ss command
        if ss -tuln 2>/dev/null | grep -q ":${port} "; then
            log_warning "Port $port đã được sử dụng (cần cho $service_name)"
            return 1
        fi
    elif command -v lsof &> /dev/null; then
        # macOS/Linux lsof command
        if lsof -i ":${port}" &> /dev/null; then
            log_warning "Port $port đã được sử dụng (cần cho $service_name)"
            return 1
        fi
    else
        log_debug "Không thể kiểm tra port availability (thiếu netstat/ss/lsof)"
        # Return success to not block deployment
        return 0
    fi

    log_debug "Port $port có sẵn cho $service_name"
    return 0
}

# Validate required ports
validate_required_ports() {
    local ports_services=(
        "5432:PostgreSQL"
        "6379:Redis"
        "7856:n8n"
        "4001:Flowise"
        "6333:Qdrant"
        "8080:WordPress"
        "3306:MariaDB"
    )
    
    log_info "Kiểm tra các port cần thiết..."
    
    local conflicts=()
    for port_service in "${ports_services[@]}"; do
        local port="${port_service%:*}"
        local service="${port_service#*:}"
        
        if ! validate_port_available "$port" "$service"; then
            conflicts+=("$port ($service)")
        fi
    done
    
    if [[ ${#conflicts[@]} -gt 0 ]]; then
        log_warning "Các port bị xung đột:"
        for conflict in "${conflicts[@]}"; do
            log_warning "  - $conflict"
        done
        log_info "Vui lòng dừng các service đang sử dụng port này hoặc thay đổi cấu hình"
        return 1
    else
        log_success "Tất cả các port cần thiết đều có sẵn!"
        return 0
    fi
}

# Validate disk space
validate_disk_space() {
    local required_space_gb="${1:-10}"
    local path="${2:-.}"
    
    log_info "Kiểm tra dung lượng đĩa..."
    
    if command -v df &> /dev/null; then
        local available_kb=$(df "$path" | awk 'NR==2 {print $4}')
        local available_gb=$((available_kb / 1024 / 1024))
        
        if [[ $available_gb -lt $required_space_gb ]]; then
            log_warning "Dung lượng đĩa không đủ. Cần: ${required_space_gb}GB, Có: ${available_gb}GB"
            return 1
        else
            log_success "Dung lượng đĩa đủ: ${available_gb}GB (cần ${required_space_gb}GB)"
            return 0
        fi
    else
        log_debug "Không thể kiểm tra dung lượng đĩa (thiếu df command)"
        return 0
    fi
}

# Validate memory
validate_memory() {
    local required_memory_gb="${1:-4}"
    
    log_info "Kiểm tra bộ nhớ RAM..."
    
    if [[ -f /proc/meminfo ]]; then
        local total_memory_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
        local total_memory_gb=$((total_memory_kb / 1024 / 1024))
        
        if [[ $total_memory_gb -lt $required_memory_gb ]]; then
            log_warning "Bộ nhớ RAM không đủ. Cần: ${required_memory_gb}GB, Có: ${total_memory_gb}GB"
            return 1
        else
            log_success "Bộ nhớ RAM đủ: ${total_memory_gb}GB (cần ${required_memory_gb}GB)"
            return 0
        fi
    else
        log_debug "Không thể kiểm tra bộ nhớ (thiếu /proc/meminfo)"
        return 0
    fi
}

# Validate GPU (for AI profile)
validate_gpu() {
    log_info "Kiểm tra GPU NVIDIA..."
    
    if command -v nvidia-smi &> /dev/null; then
        if nvidia-smi &> /dev/null; then
            log_success "GPU NVIDIA đã sẵn sàng!"
            return 0
        else
            log_warning "nvidia-smi không hoạt động. Driver có thể chưa được cài đặt đúng."
            return 1
        fi
    else
        log_info "Không tìm thấy nvidia-smi. Sẽ sử dụng CPU."
        return 1
    fi
}

# Validate profile requirements
validate_profile_requirements() {
    local profile="$1"
    
    case "$profile" in
        "basic")
            log_info "Kiểm tra yêu cầu cho profile basic..."
            validate_memory 4 && validate_disk_space 10
            ;;
        "monitoring")
            log_info "Kiểm tra yêu cầu cho profile monitoring..."
            validate_memory 6 && validate_disk_space 15
            ;;
        "ai")
            log_info "Kiểm tra yêu cầu cho profile AI..."
            validate_memory 8 && validate_disk_space 20
            ;;
        "gpu-nvidia")
            log_info "Kiểm tra yêu cầu cho profile GPU NVIDIA..."
            validate_gpu && validate_memory 8 && validate_disk_space 20
            ;;
        *)
            log_debug "Không có yêu cầu đặc biệt cho profile: $profile"
            return 0
            ;;
    esac
}

# Validate all requirements
validate_all_requirements() {
    local profile="${1:-basic}"
    
    show_banner "KIỂM TRA YÊU CẦU HỆ THỐNG"
    
    local checks=(
        "validate_docker_compose_file"
        "validate_env_file"
        "validate_required_ports"
        "validate_profile_requirements $profile"
    )
    
    local failed_checks=()
    
    for check in "${checks[@]}"; do
        if ! eval "$check"; then
            failed_checks+=("$check")
        fi
    done
    
    if [[ ${#failed_checks[@]} -eq 0 ]]; then
        log_success "Tất cả các kiểm tra đều thành công!"
        return 0
    else
        log_warning "Một số kiểm tra thất bại:"
        for check in "${failed_checks[@]}"; do
            log_warning "  - $check"
        done
        return 1
    fi
}

# Check if port is in use (alias for validate_port_available with inverted logic)
is_port_in_use() {
    local port="$1"
    local service_name="${2:-Service}"

    # Try different methods to check port availability
    if command -v netstat &> /dev/null; then
        # Windows/Linux netstat check
        if netstat -an 2>/dev/null | grep -q ":${port} "; then
            return 0  # Port is in use
        fi
    elif command -v ss &> /dev/null; then
        # Linux ss command
        if ss -tuln 2>/dev/null | grep -q ":${port} "; then
            return 0  # Port is in use
        fi
    elif command -v lsof &> /dev/null; then
        # macOS/Linux lsof command
        if lsof -i ":${port}" &> /dev/null; then
            return 0  # Port is in use
        fi
    else
        log_debug "Không thể kiểm tra port availability (thiếu netstat/ss/lsof)"
        return 1  # Assume port is not in use
    fi

    return 1  # Port is not in use
}

# Export functions
export -f validate_file_exists validate_directory_exists
export -f validate_docker_compose_file validate_env_file
export -f validate_port_available validate_required_ports
export -f validate_disk_space validate_memory validate_gpu
export -f validate_profile_requirements validate_all_requirements
export -f is_port_in_use
