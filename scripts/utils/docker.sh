#!/bin/bash

# Docker utilities for NextFlow Docker scripts
# Author: Augment Agent
# Version: 1.0

# Source logging utilities
source "$(dirname "${BASH_SOURCE[0]}")/logging.sh"

# Detect Docker Compose command
detect_docker_compose() {
    if command -v docker-compose &> /dev/null; then
        echo "docker-compose"
    elif docker compose version &> /dev/null; then
        echo "docker compose"
    else
        log_error "Docker Compose không được tìm thấy!"
        return 1
    fi
}

# Check Docker installation
check_docker() {
    log_info "Kiểm tra Docker..."
    
    if ! command -v docker &> /dev/null; then
        log_error "Docker không được cài đặt. Vui lòng cài đặt Docker trước."
        return 1
    fi
    
    if ! docker info &> /dev/null; then
        log_error "Docker daemon không chạy. Vui lòng khởi động Docker."
        return 1
    fi
    
    log_success "Docker đã sẵn sàng!"
    return 0
}

# Check Docker Compose
check_docker_compose() {
    log_info "Kiểm tra Docker Compose..."
    
    DOCKER_COMPOSE=$(detect_docker_compose)
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    
    log_success "Docker Compose đã sẵn sàng: $DOCKER_COMPOSE"
    export DOCKER_COMPOSE
    return 0
}

# Check if container is running
is_container_running() {
    local container_name="$1"
    docker ps --format "table {{.Names}}" | grep -q "^${container_name}$"
}

# Check if container exists
container_exists() {
    local container_name="$1"
    docker ps -a --format "table {{.Names}}" | grep -q "^${container_name}$"
}

# Wait for container to be healthy
wait_for_container_health() {
    local container_name="$1"
    local max_attempts="${2:-30}"
    local attempt=1
    
    log_info "Đợi container $container_name khởi động..."
    
    while [[ $attempt -le $max_attempts ]]; do
        if is_container_running "$container_name"; then
            local health_status=$(docker inspect --format='{{.State.Health.Status}}' "$container_name" 2>/dev/null)
            
            if [[ "$health_status" == "healthy" ]] || [[ -z "$health_status" ]]; then
                log_success "Container $container_name đã sẵn sàng!"
                return 0
            fi
        fi
        
        show_progress $attempt $max_attempts
        sleep 2
        attempt=$((attempt+1))
    done
    
    log_warning "Container $container_name có thể chưa sẵn sàng sau $max_attempts lần thử."
    return 1
}

# Stop all containers
stop_all_containers() {
    log_info "Dừng tất cả các container..."
    
    local running_containers=$(docker ps -q)
    if [[ -n "$running_containers" ]]; then
        docker stop $running_containers
        log_success "Đã dừng tất cả các container!"
    else
        log_info "Không có container nào đang chạy."
    fi
}

# Remove all containers
remove_all_containers() {
    log_info "Xóa tất cả các container..."
    
    local all_containers=$(docker ps -a -q)
    if [[ -n "$all_containers" ]]; then
        docker rm $all_containers
        log_success "Đã xóa tất cả các container!"
    else
        log_info "Không có container nào để xóa."
    fi
}

# Clean up Docker resources
docker_cleanup() {
    log_info "Dọn dẹp Docker resources..."
    
    # Remove stopped containers
    docker container prune -f
    
    # Remove unused networks
    docker network prune -f
    
    # Remove unused volumes (with confirmation)
    if confirm_action "Xóa các volume không sử dụng?"; then
        docker volume prune -f
    fi
    
    # Remove unused images (with confirmation)
    if confirm_action "Xóa các image không sử dụng?"; then
        docker image prune -f
    fi
    
    log_success "Đã dọn dẹp Docker resources!"
}

# Check container logs
check_container_logs() {
    local container_name="$1"
    local lines="${2:-50}"
    
    if is_container_running "$container_name"; then
        log_info "Logs của container $container_name (${lines} dòng cuối):"
        docker logs --tail "$lines" "$container_name"
    else
        log_warning "Container $container_name không đang chạy."
    fi
}

# Get container status
get_container_status() {
    local container_name="$1"
    
    if container_exists "$container_name"; then
        docker ps -a --filter "name=^${container_name}$" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    else
        echo "Container $container_name không tồn tại."
    fi
}

# Pull latest images
pull_images() {
    local compose_file="${1:-docker-compose.yml}"
    
    log_info "Cập nhật images..."
    $DOCKER_COMPOSE -f "$compose_file" pull
    
    if [[ $? -eq 0 ]]; then
        log_success "Đã cập nhật images thành công!"
        return 0
    else
        log_error "Cập nhật images thất bại!"
        return 1
    fi
}

# Deploy with profile
deploy_with_profile() {
    local compose_file="$1"
    local profile="$2"
    local additional_args="${3:-}"
    
    log_info "Triển khai với profile: $profile"
    
    if [[ -n "$profile" ]]; then
        $DOCKER_COMPOSE -f "$compose_file" --profile "$profile" up -d $additional_args
    else
        $DOCKER_COMPOSE -f "$compose_file" up -d $additional_args
    fi
    
    if [[ $? -eq 0 ]]; then
        log_success "Triển khai thành công!"
        return 0
    else
        log_error "Triển khai thất bại!"
        return 1
    fi
}

# Stop services with profile
stop_with_profile() {
    local compose_file="$1"
    local profile="$2"
    
    log_info "Dừng services với profile: $profile"
    
    if [[ -n "$profile" ]]; then
        $DOCKER_COMPOSE -f "$compose_file" --profile "$profile" down
    else
        $DOCKER_COMPOSE -f "$compose_file" down
    fi
    
    if [[ $? -eq 0 ]]; then
        log_success "Đã dừng services thành công!"
        return 0
    else
        log_error "Dừng services thất bại!"
        return 1
    fi
}

# Check service health
check_service_health() {
    local compose_file="$1"
    local service_name="$2"
    
    log_info "Kiểm tra trạng thái service: $service_name"
    
    local container_id=$($DOCKER_COMPOSE -f "$compose_file" ps -q "$service_name")
    
    if [[ -n "$container_id" ]]; then
        local status=$(docker inspect --format='{{.State.Status}}' "$container_id")
        local health=$(docker inspect --format='{{.State.Health.Status}}' "$container_id" 2>/dev/null)
        
        echo "Status: $status"
        if [[ -n "$health" ]]; then
            echo "Health: $health"
        fi
        
        if [[ "$status" == "running" ]]; then
            return 0
        else
            return 1
        fi
    else
        log_warning "Service $service_name không tồn tại hoặc không chạy."
        return 1
    fi
}

# Export functions
export -f detect_docker_compose check_docker check_docker_compose
export -f is_container_running container_exists wait_for_container_health
export -f stop_all_containers remove_all_containers docker_cleanup
export -f check_container_logs get_container_status pull_images
export -f deploy_with_profile stop_with_profile check_service_health
