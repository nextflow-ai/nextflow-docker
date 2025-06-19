#!/bin/bash

# 🔧 NextFlow Cloudflare Tunnel Environment Updater
# Script để cập nhật tunnel IDs và tokens vào file .env

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source utilities
source "$SCRIPT_DIR/../utils/logging.sh"

# Configuration
ENV_FILE="$PROJECT_ROOT/.env"
INTERACTIVE_MODE=true
AUTO_MODE=false

# Show help
show_help() {
    show_banner "CLOUDFLARE TUNNEL ENVIRONMENT UPDATER"
    
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  --auto                  Auto-detect tunnels and update .env"
    echo "  --interactive           Interactive mode (default)"
    echo "  --help                  Show this help message"
    echo
    echo "Examples:"
    echo "  $0                      # Interactive mode"
    echo "  $0 --auto              # Auto-detect and update"
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --auto)
                AUTO_MODE=true
                INTERACTIVE_MODE=false
                shift
                ;;
            --interactive)
                INTERACTIVE_MODE=true
                AUTO_MODE=false
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
}

# Check cloudflared
check_cloudflared() {
    if ! command -v cloudflared >/dev/null 2>&1; then
        log_error "cloudflared is not installed!"
        return 1
    fi
    
    if ! cloudflared tunnel list >/dev/null 2>&1; then
        log_error "Not logged in to Cloudflare!"
        log_info "Run: cloudflared tunnel login"
        return 1
    fi
    
    return 0
}

# Check .env file
check_env_file() {
    if [[ ! -f "$ENV_FILE" ]]; then
        log_warning "File .env không tồn tại. Tạo file mới..."
        touch "$ENV_FILE"
        log_success "Đã tạo file .env!"
    fi
}

# Update environment variable
update_env_var() {
    local var_name="$1"
    local var_value="$2"
    
    if grep -q "^$var_name=" "$ENV_FILE"; then
        # Update existing variable
        sed -i "s/^$var_name=.*/$var_name=$var_value/" "$ENV_FILE"
    else
        # Add new variable
        echo "$var_name=$var_value" >> "$ENV_FILE"
    fi
    
    log_success "Updated $var_name"
}

# Get tunnel info
get_tunnel_info() {
    local tunnel_name="$1"
    
    # Get tunnel ID
    local tunnel_id=$(cloudflared tunnel list | grep "$tunnel_name" | awk '{print $1}' | head -1)
    
    if [[ -z "$tunnel_id" || "$tunnel_id" == "ID" ]]; then
        return 1
    fi
    
    # Get tunnel token
    local tunnel_token=$(cloudflared tunnel token "$tunnel_name" 2>/dev/null || echo "")
    
    echo "$tunnel_id|$tunnel_token"
    return 0
}

# Auto update mode
auto_update_tunnels() {
    show_banner "AUTO UPDATE MODE"
    
    if ! check_cloudflared; then
        return 1
    fi
    
    log_info "Auto-detecting Cloudflare tunnels..."
    
    # Tunnel mappings
    declare -A TUNNEL_MAPPINGS=(
        ["nextflow"]="CLOUDFLARE_TUNNEL_ID,CLOUDFLARE_TUNNEL_TOKEN"
        ["nextflow-api"]="CLOUDFLARE_TUNNEL_API_ID,CLOUDFLARE_TUNNEL_API_TOKEN"
        ["nextflow-docs"]="CLOUDFLARE_TUNNEL_DOCS_ID,CLOUDFLARE_TUNNEL_DOCS_TOKEN"
        ["nextflow-monitoring"]="CLOUDFLARE_TUNNEL_MONITORING_ID,CLOUDFLARE_TUNNEL_MONITORING_TOKEN"
        ["nextflow-ai"]="CLOUDFLARE_TUNNEL_AI_ID,CLOUDFLARE_TUNNEL_AI_TOKEN"
        ["nextflow-gitlab"]="CLOUDFLARE_TUNNEL_GITLAB_ID,CLOUDFLARE_TUNNEL_GITLAB_TOKEN"
    )
    
    # Add Cloudflare section if not exists
    if ! grep -q "# Cloudflare Tunnels" "$ENV_FILE"; then
        echo "" >> "$ENV_FILE"
        echo "# Cloudflare Tunnels" >> "$ENV_FILE"
    fi
    
    local updated_count=0
    local failed_count=0
    
    for tunnel_name in "${!TUNNEL_MAPPINGS[@]}"; do
        log_info "Processing tunnel: $tunnel_name"
        
        local tunnel_info
        if tunnel_info=$(get_tunnel_info "$tunnel_name"); then
            IFS='|' read -ra INFO <<< "$tunnel_info"
            local tunnel_id="${INFO[0]}"
            local tunnel_token="${INFO[1]}"
            
            # Parse variable names
            IFS=',' read -ra VARS <<< "${TUNNEL_MAPPINGS[$tunnel_name]}"
            local id_var="${VARS[0]}"
            local token_var="${VARS[1]}"
            
            # Update variables
            update_env_var "$id_var" "$tunnel_id"
            if [[ -n "$tunnel_token" ]]; then
                update_env_var "$token_var" "$tunnel_token"
            fi
            
            ((updated_count++))
            log_success "✅ Updated $tunnel_name"
        else
            log_warning "⚠️ Tunnel not found: $tunnel_name"
            ((failed_count++))
        fi
    done
    
    # Summary
    echo
    log_info "Auto update results:"
    log_success "✅ Updated: $updated_count tunnels"
    if [[ $failed_count -gt 0 ]]; then
        log_warning "⚠️ Not found: $failed_count tunnels"
    fi
}

# Interactive update for single tunnel
interactive_update_tunnel() {
    local tunnel_name="$1"
    local id_var="$2"
    local token_var="$3"
    
    echo
    log_info "Updating tunnel: $tunnel_name"
    
    # Get current values
    local current_id=""
    local current_token=""
    
    if grep -q "^$id_var=" "$ENV_FILE"; then
        current_id=$(grep "^$id_var=" "$ENV_FILE" | cut -d'=' -f2)
    fi
    
    if grep -q "^$token_var=" "$ENV_FILE"; then
        current_token=$(grep "^$token_var=" "$ENV_FILE" | cut -d'=' -f2)
    fi
    
    # Show current values
    if [[ -n "$current_id" ]]; then
        log_info "Current ID: ${current_id:0:20}..."
    fi
    
    if [[ -n "$current_token" ]]; then
        log_info "Current Token: ${current_token:0:20}..."
    fi
    
    # Auto-detect option
    echo
    echo "1. Auto-detect from cloudflared"
    echo "2. Manual input"
    echo "3. Skip this tunnel"
    echo
    read -p "Choose option (1-3): " choice
    
    case $choice in
        1)
            local tunnel_info
            if tunnel_info=$(get_tunnel_info "$tunnel_name"); then
                IFS='|' read -ra INFO <<< "$tunnel_info"
                local tunnel_id="${INFO[0]}"
                local tunnel_token="${INFO[1]}"
                
                update_env_var "$id_var" "$tunnel_id"
                if [[ -n "$tunnel_token" ]]; then
                    update_env_var "$token_var" "$tunnel_token"
                fi
                
                log_success "✅ Auto-detected and updated $tunnel_name"
            else
                log_error "❌ Could not auto-detect tunnel: $tunnel_name"
            fi
            ;;
        2)
            # Manual input
            read -p "Enter tunnel ID: " new_id
            if [[ -n "$new_id" ]]; then
                update_env_var "$id_var" "$new_id"
            fi
            
            read -p "Enter tunnel token (optional): " new_token
            if [[ -n "$new_token" ]]; then
                update_env_var "$token_var" "$new_token"
            fi
            
            log_success "✅ Manually updated $tunnel_name"
            ;;
        3)
            log_info "Skipped $tunnel_name"
            ;;
        *)
            log_warning "Invalid choice, skipping $tunnel_name"
            ;;
    esac
}

# Interactive mode
interactive_mode() {
    show_banner "INTERACTIVE UPDATE MODE"
    
    if ! check_cloudflared; then
        log_warning "cloudflared not available, manual input only"
    fi
    
    # Add Cloudflare section if not exists
    if ! grep -q "# Cloudflare Tunnels" "$ENV_FILE"; then
        echo "" >> "$ENV_FILE"
        echo "# Cloudflare Tunnels" >> "$ENV_FILE"
    fi
    
    # Tunnel definitions
    declare -A TUNNELS=(
        ["nextflow"]="CLOUDFLARE_TUNNEL_ID,CLOUDFLARE_TUNNEL_TOKEN"
        ["nextflow-api"]="CLOUDFLARE_TUNNEL_API_ID,CLOUDFLARE_TUNNEL_API_TOKEN"
        ["nextflow-docs"]="CLOUDFLARE_TUNNEL_DOCS_ID,CLOUDFLARE_TUNNEL_DOCS_TOKEN"
        ["nextflow-monitoring"]="CLOUDFLARE_TUNNEL_MONITORING_ID,CLOUDFLARE_TUNNEL_MONITORING_TOKEN"
        ["nextflow-ai"]="CLOUDFLARE_TUNNEL_AI_ID,CLOUDFLARE_TUNNEL_AI_TOKEN"
        ["nextflow-gitlab"]="CLOUDFLARE_TUNNEL_GITLAB_ID,CLOUDFLARE_TUNNEL_GITLAB_TOKEN"
    )
    
    for tunnel_name in "${!TUNNELS[@]}"; do
        IFS=',' read -ra VARS <<< "${TUNNELS[$tunnel_name]}"
        local id_var="${VARS[0]}"
        local token_var="${VARS[1]}"
        
        interactive_update_tunnel "$tunnel_name" "$id_var" "$token_var"
    done
    
    echo
    log_success "Interactive update completed!"
}

# Show current environment
show_current_env() {
    log_info "Current Cloudflare tunnel configuration:"
    echo
    
    if grep -q "# Cloudflare Tunnels" "$ENV_FILE"; then
        # Show only Cloudflare section
        sed -n '/# Cloudflare Tunnels/,/^$/p' "$ENV_FILE" | grep -E "(CLOUDFLARE_|DOMAIN=)" || log_info "No Cloudflare variables found"
    else
        log_info "No Cloudflare tunnel configuration found"
    fi
}

# Main function
main() {
    # Parse arguments
    parse_arguments "$@"
    
    # Check environment file
    check_env_file
    
    # Show current configuration
    show_current_env
    
    # Execute based on mode
    if [[ "$AUTO_MODE" == true ]]; then
        auto_update_tunnels
    else
        interactive_mode
    fi
    
    echo
    log_info "Updated .env file location: $ENV_FILE"
    log_info "To apply changes, restart your services"
}

# Run main function with all arguments
main "$@"
