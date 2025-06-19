#!/bin/bash

# Monitoring profile deployment for NextFlow Docker
# Author: Augment Agent
# Version: 1.0
#
# Services included:
# - Prometheus (metrics collection)
# - Grafana (dashboard)
# - Loki (log aggregation)
# - Promtail (log collection agent)
# - Node Exporter (host metrics)
# - cAdvisor (container metrics)

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
PROFILE_NAME="monitoring"
COMPOSE_FILE="${COMPOSE_FILE:-docker-compose.yml}"

# Services in monitoring profile
MONITORING_SERVICES=(
    "prometheus"
    "grafana"
    "loki"
    "promtail"
    "node-exporter"
    "cadvisor"
)

# Monitoring services sẽ được truy cập qua Cloudflare tunnel chính

# Required ports for monitoring profile (Updated to match docker-compose.yml)
MONITORING_PORTS=(
    "9090:Prometheus"
    "3030:Grafana"              # Grafana port từ docker-compose.yml
    "3100:Loki"                 # Loki port từ docker-compose.yml
    "9100:Node Exporter"
    "8081:cAdvisor"             # cAdvisor port từ docker-compose.yml
)

# Deploy monitoring profile
deploy_monitoring() {
    local force_deploy="${1:-false}"

    show_banner "TRIỂN KHAI PROFILE MONITORING"

    log_info "Profile Monitoring bao gồm các dịch vụ:"
    for service in "${MONITORING_SERVICES[@]}"; do
        log_info "  ✓ $service"
    done
    echo

    # Validate requirements
    if ! validate_profile_requirements "$PROFILE_NAME"; then
        log_warning "Một số yêu cầu không được đáp ứng, nhưng sẽ tiếp tục triển khai..."
    fi

    # Stop existing monitoring containers first
    stop_existing_monitoring_containers

    # Monitoring profile hoạt động độc lập
    log_info "Monitoring profile hoạt động độc lập, không cần basic services"

    # Create monitoring directories
    create_monitoring_directories

    # Create monitoring configs if not exist
    create_monitoring_configs

    # Deploy monitoring services
    deploy_monitoring_services

    # Wait for services to be ready
    wait_for_monitoring_services

    # Show deployment summary
    show_monitoring_summary
}

# Stop existing monitoring containers
stop_existing_monitoring_containers() {
    log_info "Dừng monitoring containers hiện tại..."

    # Danh sách monitoring containers cần dừng
    local monitoring_containers=("prometheus" "grafana" "loki" "promtail" "node-exporter" "cadvisor")

    # Dừng containers bằng docker command
    for container in "${monitoring_containers[@]}"; do
        if docker ps --format "table {{.Names}}" | grep -q "^${container}$"; then
            log_info "Dừng container: $container"
            docker stop "$container" 2>/dev/null || true
            docker rm "$container" 2>/dev/null || true
        fi
    done

    # Dừng monitoring services bằng docker-compose
    log_info "Dừng monitoring services bằng docker-compose..."
    $DOCKER_COMPOSE -f "$COMPOSE_FILE" --profile monitoring down 2>/dev/null || true

    log_success "Đã dừng tất cả monitoring containers hiện tại"
}

# Monitoring profile hoạt động độc lập

# Create monitoring directories
create_monitoring_directories() {
    log_info "Tạo các thư mục monitoring..."

    local directories=(
        "config/monitoring"
        "monitoring/prometheus"
        "monitoring/grafana/provisioning/dashboards"
        "monitoring/grafana/provisioning/datasources"
        "monitoring/loki"
        "monitoring/promtail"
    )

    for dir in "${directories[@]}"; do
        if [[ ! -d "$dir" ]]; then
            mkdir -p "$dir"
            log_debug "Tạo thư mục: $dir"
        fi
    done

    log_success "Đã tạo các thư mục monitoring!"
}

# Create monitoring configs
create_monitoring_configs() {
    log_info "Tạo các file cấu hình monitoring..."

    # Create Prometheus config if not exists
    if [[ ! -f "config/monitoring/prometheus.yml" ]]; then
        create_prometheus_config
    fi

    # Create Grafana datasources config if not exists
    if [[ ! -f "config/monitoring/grafana-datasources.yml" ]]; then
        create_grafana_datasources_config
    fi

    # Create Grafana dashboards config if not exists
    if [[ ! -f "config/monitoring/grafana-dashboards.yml" ]]; then
        create_grafana_dashboards_config
    fi

    # Create Loki config if not exists
    if [[ ! -f "config/monitoring/loki-config.yml" ]]; then
        create_loki_config
    fi

    # Create Promtail config if not exists
    if [[ ! -f "config/monitoring/promtail-config.yml" ]]; then
        create_promtail_config
    fi

    log_success "Đã tạo các file cấu hình monitoring!"
}

# Create Prometheus config
create_prometheus_config() {
    cat > config/monitoring/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  # - "first_rules.yml"
  # - "second_rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']

  - job_name: 'n8n'
    static_configs:
      - targets: ['n8n:5678']
    metrics_path: '/metrics'

  - job_name: 'postgres'
    static_configs:
      - targets: ['postgres:5432']

  - job_name: 'redis'
    static_configs:
      - targets: ['redis:6379']
EOF
    log_debug "Tạo file: config/monitoring/prometheus.yml"
}

# Create Grafana datasources config
create_grafana_datasources_config() {
    cat > config/monitoring/grafana-datasources.yml << 'EOF'
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus:9090
    isDefault: true

  - name: Loki
    type: loki
    access: proxy
    url: http://loki:3100
EOF
    log_debug "Tạo file: config/monitoring/grafana-datasources.yml"
}

# Create Grafana dashboards config
create_grafana_dashboards_config() {
    cat > config/monitoring/grafana-dashboards.yml << 'EOF'
apiVersion: 1

providers:
  - name: 'default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /etc/grafana/provisioning/dashboards
EOF
    log_debug "Tạo file: config/monitoring/grafana-dashboards.yml"
}

# Create Loki config
create_loki_config() {
    cat > config/monitoring/loki-config.yml << 'EOF'
auth_enabled: false

server:
  http_listen_port: 3100

ingester:
  lifecycler:
    address: 127.0.0.1
    ring:
      kvstore:
        store: inmemory
      replication_factor: 1
    final_sleep: 0s
  chunk_idle_period: 1h
  max_chunk_age: 1h
  chunk_target_size: 1048576
  chunk_retain_period: 30s
  max_transfer_retries: 0

schema_config:
  configs:
    - from: 2020-10-24
      store: boltdb-shipper
      object_store: filesystem
      schema: v11
      index:
        prefix: index_
        period: 24h

storage_config:
  boltdb_shipper:
    active_index_directory: /loki/boltdb-shipper-active
    cache_location: /loki/boltdb-shipper-cache
    cache_ttl: 24h
    shared_store: filesystem
  filesystem:
    directory: /loki/chunks

limits_config:
  reject_old_samples: true
  reject_old_samples_max_age: 168h

chunk_store_config:
  max_look_back_period: 0s

table_manager:
  retention_deletes_enabled: false
  retention_period: 0s

ruler:
  storage:
    type: local
    local:
      directory: /loki/rules
  rule_path: /loki/rules-temp
  alertmanager_url: http://localhost:9093
  ring:
    kvstore:
      store: inmemory
  enable_api: true
EOF
    log_debug "Tạo file: config/monitoring/loki-config.yml"
}

# Create Promtail config
create_promtail_config() {
    cat > config/monitoring/promtail-config.yml << 'EOF'
server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: http://loki:3100/loki/api/v1/push

scrape_configs:
  - job_name: containers
    static_configs:
      - targets:
          - localhost
        labels:
          job: containerlogs
          __path__: /var/lib/docker/containers/*/*log

    pipeline_stages:
      - json:
          expressions:
            output: log
            stream: stream
            attrs:
      - json:
          expressions:
            tag:
          source: attrs
      - regex:
          expression: (?P<container_name>(?:[^|]*))\|
          source: tag
      - timestamp:
          format: RFC3339Nano
          source: time
      - labels:
          stream:
          container_name:
      - output:
          source: output
EOF
    log_debug "Tạo file: config/monitoring/promtail-config.yml"
}

# Monitoring services sẽ được truy cập qua Cloudflare tunnel chính

# Deploy monitoring services
deploy_monitoring_services() {
    log_info "Triển khai các dịch vụ monitoring..."

    # Pull only monitoring images specifically
    log_info "Tải monitoring images..."
    local monitoring_services=("prometheus" "grafana" "loki" "promtail" "node-exporter" "cadvisor")

    for service in "${monitoring_services[@]}"; do
        log_debug "Pulling $service image..."
        $DOCKER_COMPOSE -f "$COMPOSE_FILE" pull "$service" 2>/dev/null || {
            log_warning "Không thể tải image cho $service, sẽ sử dụng image có sẵn"
        }
    done

    # Deploy only monitoring services specifically
    log_loading "Khởi động monitoring stack..."
    for service in "${monitoring_services[@]}"; do
        log_debug "Starting $service..."
        $DOCKER_COMPOSE -f "$COMPOSE_FILE" up -d "$service" || {
            log_warning "Không thể khởi động $service"
        }
    done

    # Monitoring services sẽ được truy cập qua Cloudflare tunnel chính
    log_info "Monitoring services sẽ được truy cập qua Cloudflare tunnel chính"

    log_success "Đã triển khai monitoring services!"
}

# Wait for monitoring services
wait_for_monitoring_services() {
    log_info "Đợi các dịch vụ monitoring sẵn sàng..."

    local services_to_check=(
        "prometheus:30"
        "grafana:30"
        "loki:20"
        "promtail:15"
        "node-exporter:10"
        "cadvisor:15"
    )

    for service_timeout in "${services_to_check[@]}"; do
        local service="${service_timeout%:*}"
        local timeout="${service_timeout#*:}"

        log_loading "Kiểm tra $service..."
        if wait_for_container_health "$service" "$timeout"; then
            log_success "$service đã sẵn sàng!"
        else
            log_warning "$service có thể chưa sẵn sàng hoàn toàn."
        fi
    done
}

# Show monitoring summary
show_monitoring_summary() {
    show_banner "TỔNG KẾT TRIỂN KHAI MONITORING"

    log_success "Profile Monitoring đã được triển khai thành công!"
    echo

    log_info "Các dịch vụ monitoring đã triển khai:"
    echo
    echo "📊 Monitoring Stack:"
    echo "  • Prometheus    : http://localhost:9090"
    echo "  • Grafana       : http://localhost:3030 (admin/admin)"
    echo "  • Loki          : http://localhost:3100"
    echo "  • Node Exporter : http://localhost:9100/metrics"
    echo "  • cAdvisor     : http://localhost:8081"
    echo

    echo "🌐 Truy cập từ xa:"
    echo "  • Monitoring services được truy cập qua Cloudflare tunnel chính"
    echo "  • Cấu hình: cloudflared/config/cloudflared-config.yml"
    echo

    log_info "Thông tin đăng nhập:"
    echo "  • Grafana: admin/admin (có thể thay đổi trong .env)"
    echo

    log_info "Hướng dẫn sử dụng:"
    echo "  1. Truy cập Grafana tại http://localhost:3030"
    echo "  2. Đăng nhập với admin/admin"
    echo "  3. Datasources đã được cấu hình tự động"
    echo "  4. Import dashboard từ Grafana.com hoặc tạo dashboard mới"
    echo

    # Check service status
    log_info "Trạng thái các container:"
    $DOCKER_COMPOSE -f "$COMPOSE_FILE" --profile monitoring ps
}

# Stop monitoring services
stop_monitoring() {
    show_banner "DỪNG PROFILE MONITORING"

    log_info "Dừng các dịch vụ monitoring..."
    $DOCKER_COMPOSE -f "$COMPOSE_FILE" --profile monitoring down

    log_success "Đã dừng tất cả các dịch vụ monitoring!"
}

# Export functions
export -f deploy_monitoring stop_monitoring
export -f create_monitoring_directories create_monitoring_configs
export -f show_monitoring_summary
