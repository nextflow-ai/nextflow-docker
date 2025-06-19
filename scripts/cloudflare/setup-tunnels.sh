#!/bin/bash

# 🌐 NextFlow Cloudflare Tunnels Setup
# Script để setup và quản lý Cloudflare Tunnels cho NextFlow

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source utilities
source "$SCRIPT_DIR/../utils/logging.sh"

# Configuration
DOMAIN=""
CREATE_TUNNELS=true
START_TUNNELS=true
UPDATE_ENV=true

# Tunnel definitions
declare -A TUNNELS=(
    ["nextflow"]="Main NextFlow application"
    ["nextflow-api"]="NextFlow API backend"
    ["nextflow-docs"]="NextFlow documentation"
    ["nextflow-monitoring"]="Monitoring stack (Grafana, Prometheus)"
    ["nextflow-ai"]="AI services (Flowise, Ollama)"
    ["nextflow-gitlab"]="GitLab self-hosted"
)

# Show help
show_help() {
    show_banner "NEXTFLOW CLOUDFLARE TUNNELS SETUP"
    
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  --domain <domain>       Domain for tunnels (e.g., nextflow.vn)"
    echo "  --create-only           Only create tunnels, don't start"
    echo "  --start-only            Only start existing tunnels"
    echo "  --no-env-update         Don't update .env file"
    echo "  --help                  Show this help message"
    echo
    echo "Examples:"
    echo "  $0 --domain nextflow.vn"
    echo "  $0 --domain company.com --create-only"
    echo "  $0 --start-only"
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --domain)
                if [[ -n "${2:-}" ]]; then
                    DOMAIN="$2"
                    shift 2
                else
                    log_error "Option --domain requires a value"
                    exit 1
                fi
                ;;
            --create-only)
                START_TUNNELS=false
                shift
                ;;
            --start-only)
                CREATE_TUNNELS=false
                shift
                ;;
            --no-env-update)
                UPDATE_ENV=false
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    # Validate required parameters
    if [[ -z "$DOMAIN" ]]; then
        log_error "Domain is required!"
        show_help
        exit 1
    fi
}

# Check cloudflared installation
check_cloudflared() {
    log_info "Checking cloudflared installation..."
    
    if ! command -v cloudflared >/dev/null 2>&1; then
        log_error "cloudflared is not installed!"
        log_info "Install from: https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/installation/"
        return 1
    fi
    
    # Check if logged in
    if ! cloudflared tunnel list >/dev/null 2>&1; then
        log_error "Not logged in to Cloudflare!"
        log_info "Run: cloudflared tunnel login"
        return 1
    fi
    
    log_success "cloudflared is ready!"
    return 0
}

# Create tunnel
create_tunnel() {
    local tunnel_name="$1"
    local description="$2"
    
    log_info "Creating tunnel: $tunnel_name"
    
    # Check if tunnel already exists
    if cloudflared tunnel list | grep -q "$tunnel_name"; then
        log_warning "Tunnel $tunnel_name already exists"
        return 0
    fi
    
    # Create tunnel
    if cloudflared tunnel create "$tunnel_name"; then
        log_success "✅ Created tunnel: $tunnel_name"
        return 0
    else
        log_error "❌ Failed to create tunnel: $tunnel_name"
        return 1
    fi
}

# Create all tunnels
create_all_tunnels() {
    if [[ "$CREATE_TUNNELS" != true ]]; then
        return 0
    fi
    
    log_info "Creating Cloudflare tunnels..."
    
    local created_count=0
    local failed_count=0
    
    for tunnel_name in "${!TUNNELS[@]}"; do
        local description="${TUNNELS[$tunnel_name]}"
        
        if create_tunnel "$tunnel_name" "$description"; then
            ((created_count++))
        else
            ((failed_count++))
        fi
    done
    
    log_info "Tunnel creation summary:"
    log_success "✅ Created: $created_count tunnels"
    if [[ $failed_count -gt 0 ]]; then
        log_warning "⚠️ Failed: $failed_count tunnels"
    fi
    
    return 0
}

# Generate tunnel configuration
generate_tunnel_config() {
    local tunnel_name="$1"
    local config_file="$PROJECT_ROOT/cloudflared/${tunnel_name}.yml"
    
    # Create cloudflared directory
    mkdir -p "$PROJECT_ROOT/cloudflared"
    
    # Get tunnel ID
    local tunnel_id=$(cloudflared tunnel list | grep "$tunnel_name" | awk '{print $1}' | head -1)
    
    if [[ -z "$tunnel_id" ]]; then
        log_error "Cannot find tunnel ID for: $tunnel_name"
        return 1
    fi
    
    # Generate configuration based on tunnel type
    case "$tunnel_name" in
        "nextflow")
            cat > "$config_file" << EOF
tunnel: $tunnel_id
credentials-file: /root/.cloudflared/$tunnel_id.json

ingress:
  - hostname: $DOMAIN
    service: http://host.docker.internal:3002
  - hostname: app.$DOMAIN
    service: http://host.docker.internal:3002
  - service: http_status:404
EOF
            ;;
        "nextflow-api")
            cat > "$config_file" << EOF
tunnel: $tunnel_id
credentials-file: /root/.cloudflared/$tunnel_id.json

ingress:
  - hostname: api.$DOMAIN
    service: http://host.docker.internal:3001
  - service: http_status:404
EOF
            ;;
        "nextflow-docs")
            cat > "$config_file" << EOF
tunnel: $tunnel_id
credentials-file: /root/.cloudflared/$tunnel_id.json

ingress:
  - hostname: docs.$DOMAIN
    service: http://host.docker.internal:3003
  - service: http_status:404
EOF
            ;;
        "nextflow-monitoring")
            cat > "$config_file" << EOF
tunnel: $tunnel_id
credentials-file: /root/.cloudflared/$tunnel_id.json

ingress:
  - hostname: grafana.$DOMAIN
    service: http://host.docker.internal:3030
  - hostname: prometheus.$DOMAIN
    service: http://host.docker.internal:9090
  - service: http_status:404
EOF
            ;;
        "nextflow-ai")
            cat > "$config_file" << EOF
tunnel: $tunnel_id
credentials-file: /root/.cloudflared/$tunnel_id.json

ingress:
  - hostname: flowise.$DOMAIN
    service: http://host.docker.internal:3000
  - hostname: ai.$DOMAIN
    service: http://host.docker.internal:5080
  - hostname: ollama.$DOMAIN
    service: http://host.docker.internal:11434
  - service: http_status:404
EOF
            ;;
        "nextflow-gitlab")
            cat > "$config_file" << EOF
tunnel: $tunnel_id
credentials-file: /root/.cloudflared/$tunnel_id.json

ingress:
  - hostname: gitlab.$DOMAIN
    service: http://host.docker.internal:8080
  - hostname: registry.$DOMAIN
    service: http://host.docker.internal:5050
  - service: http_status:404
EOF
            ;;
        *)
            log_warning "Unknown tunnel type: $tunnel_name"
            return 1
            ;;
    esac
    
    log_success "Generated config for: $tunnel_name"
    return 0
}

# Generate all tunnel configurations
generate_all_configs() {
    log_info "Generating tunnel configurations..."
    
    for tunnel_name in "${!TUNNELS[@]}"; do
        generate_tunnel_config "$tunnel_name"
    done
    
    log_success "All tunnel configurations generated!"
}

# Update environment file with tunnel information
update_environment() {
    if [[ "$UPDATE_ENV" != true ]]; then
        return 0
    fi
    
    log_info "Updating environment file with tunnel information..."
    
    local env_file="$PROJECT_ROOT/.env"
    
    # Add Cloudflare section if not exists
    if ! grep -q "# Cloudflare Tunnels" "$env_file" 2>/dev/null; then
        echo "" >> "$env_file"
        echo "# Cloudflare Tunnels" >> "$env_file"
    fi
    
    # Update domain
    if grep -q "^DOMAIN=" "$env_file"; then
        sed -i "s/^DOMAIN=.*/DOMAIN=$DOMAIN/" "$env_file"
    else
        echo "DOMAIN=$DOMAIN" >> "$env_file"
    fi
    
    # Add tunnel IDs and tokens
    for tunnel_name in "${!TUNNELS[@]}"; do
        local tunnel_id=$(cloudflared tunnel list | grep "$tunnel_name" | awk '{print $1}' | head -1)
        local tunnel_token=$(cloudflared tunnel token "$tunnel_name" 2>/dev/null || echo "")
        
        if [[ -n "$tunnel_id" ]]; then
            local id_var="CLOUDFLARE_TUNNEL_${tunnel_name^^}_ID"
            local token_var="CLOUDFLARE_TUNNEL_${tunnel_name^^}_TOKEN"
            
            # Replace hyphens with underscores for variable names
            id_var=${id_var//-/_}
            token_var=${token_var//-/_}
            
            # Update ID
            if grep -q "^$id_var=" "$env_file"; then
                sed -i "s/^$id_var=.*/$id_var=$tunnel_id/" "$env_file"
            else
                echo "$id_var=$tunnel_id" >> "$env_file"
            fi
            
            # Update token if available
            if [[ -n "$tunnel_token" ]]; then
                if grep -q "^$token_var=" "$env_file"; then
                    sed -i "s/^$token_var=.*/$token_var=$tunnel_token/" "$env_file"
                else
                    echo "$token_var=$tunnel_token" >> "$env_file"
                fi
            fi
        fi
    done
    
    log_success "Environment file updated!"
}

# Start tunnel
start_tunnel() {
    local tunnel_name="$1"
    local config_file="$PROJECT_ROOT/cloudflared/${tunnel_name}.yml"
    
    if [[ ! -f "$config_file" ]]; then
        log_error "Config file not found: $config_file"
        return 1
    fi
    
    log_info "Starting tunnel: $tunnel_name"
    
    # Start tunnel in background
    nohup cloudflared tunnel --config "$config_file" run > "$PROJECT_ROOT/logs/cloudflared-${tunnel_name}.log" 2>&1 &
    
    # Save PID
    echo $! > "$PROJECT_ROOT/cloudflared/${tunnel_name}.pid"
    
    log_success "✅ Started tunnel: $tunnel_name"
    return 0
}

# Start all tunnels
start_all_tunnels() {
    if [[ "$START_TUNNELS" != true ]]; then
        return 0
    fi
    
    log_info "Starting Cloudflare tunnels..."
    
    # Create logs directory
    mkdir -p "$PROJECT_ROOT/logs"
    
    local started_count=0
    local failed_count=0
    
    for tunnel_name in "${!TUNNELS[@]}"; do
        if start_tunnel "$tunnel_name"; then
            ((started_count++))
        else
            ((failed_count++))
        fi
        
        # Small delay between starts
        sleep 2
    done
    
    log_info "Tunnel startup summary:"
    log_success "✅ Started: $started_count tunnels"
    if [[ $failed_count -gt 0 ]]; then
        log_warning "⚠️ Failed: $failed_count tunnels"
    fi
    
    return 0
}

# Show setup summary
show_setup_summary() {
    show_banner "CLOUDFLARE TUNNELS SETUP SUMMARY"
    
    log_success "Cloudflare tunnels setup completed!"
    echo
    
    log_info "Domain: $DOMAIN"
    echo
    
    log_info "Available URLs:"
    echo "  • Main App: https://$DOMAIN"
    echo "  • API: https://api.$DOMAIN"
    echo "  • Docs: https://docs.$DOMAIN"
    echo "  • Grafana: https://grafana.$DOMAIN"
    echo "  • Prometheus: https://prometheus.$DOMAIN"
    echo "  • Flowise: https://flowise.$DOMAIN"
    echo "  • AI Chat: https://ai.$DOMAIN"
    echo "  • GitLab: https://gitlab.$DOMAIN"
    echo "  • Registry: https://registry.$DOMAIN"
    echo
    
    log_info "Management commands:"
    echo "  • View tunnels: cloudflared tunnel list"
    echo "  • Stop tunnel: kill \$(cat cloudflared/<tunnel-name>.pid)"
    echo "  • View logs: tail -f logs/cloudflared-<tunnel-name>.log"
    echo "  • Restart: $0 --domain $DOMAIN --start-only"
}

# Main function
main() {
    # Parse arguments
    parse_arguments "$@"
    
    # Show setup banner
    show_banner "NEXTFLOW CLOUDFLARE TUNNELS SETUP"
    log_info "Setting up Cloudflare tunnels for domain: $DOMAIN"
    
    # Check cloudflared
    check_cloudflared
    
    # Create tunnels
    create_all_tunnels
    
    # Generate configurations
    generate_all_configs
    
    # Update environment
    update_environment
    
    # Start tunnels
    start_all_tunnels
    
    # Show summary
    show_setup_summary
}

# Run main function with all arguments
main "$@"
