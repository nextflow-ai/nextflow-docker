#!/bin/bash

# 🌐 NextFlow Cloudflare Tunnels Manager
# Script để quản lý Cloudflare Tunnels (start, stop, restart, status)

set -euo pipefail

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Source utilities
source "$SCRIPT_DIR/../utils/logging.sh"

# Configuration
ACTION=""
TUNNEL_NAME=""
ALL_TUNNELS=false

# Available tunnels
AVAILABLE_TUNNELS=(
    "nextflow"
    "nextflow-api"
    "nextflow-docs"
    "nextflow-monitoring"
    "nextflow-ai"
    "nextflow-gitlab"
)

# Show help
show_help() {
    show_banner "NEXTFLOW CLOUDFLARE TUNNELS MANAGER"
    
    echo "Usage: $0 <ACTION> [OPTIONS]"
    echo
    echo "Actions:"
    echo "  start                   Start tunnels"
    echo "  stop                    Stop tunnels"
    echo "  restart                 Restart tunnels"
    echo "  status                  Show tunnel status"
    echo "  logs                    Show tunnel logs"
    echo
    echo "Options:"
    echo "  --tunnel <name>         Specific tunnel name"
    echo "  --all                   Apply to all tunnels"
    echo "  --help                  Show this help message"
    echo
    echo "Available tunnels:"
    for tunnel in "${AVAILABLE_TUNNELS[@]}"; do
        echo "  • $tunnel"
    done
    echo
    echo "Examples:"
    echo "  $0 start --all"
    echo "  $0 stop --tunnel nextflow-api"
    echo "  $0 restart --tunnel nextflow"
    echo "  $0 status --all"
    echo "  $0 logs --tunnel nextflow-gitlab"
}

# Parse command line arguments
parse_arguments() {
    if [[ $# -eq 0 ]]; then
        show_help
        exit 1
    fi
    
    ACTION="$1"
    shift
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --tunnel)
                if [[ -n "${2:-}" ]]; then
                    TUNNEL_NAME="$2"
                    shift 2
                else
                    log_error "Option --tunnel requires a value"
                    exit 1
                fi
                ;;
            --all)
                ALL_TUNNELS=true
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
    
    # Validate action
    case "$ACTION" in
        start|stop|restart|status|logs)
            ;;
        *)
            log_error "Invalid action: $ACTION"
            show_help
            exit 1
            ;;
    esac
    
    # Validate tunnel selection
    if [[ "$ALL_TUNNELS" != true ]] && [[ -z "$TUNNEL_NAME" ]]; then
        log_error "Must specify either --tunnel <name> or --all"
        show_help
        exit 1
    fi
    
    # Validate tunnel name if specified
    if [[ -n "$TUNNEL_NAME" ]] && [[ ! " ${AVAILABLE_TUNNELS[*]} " =~ " $TUNNEL_NAME " ]]; then
        log_error "Invalid tunnel name: $TUNNEL_NAME"
        log_info "Available tunnels: ${AVAILABLE_TUNNELS[*]}"
        exit 1
    fi
}

# Get tunnel PID
get_tunnel_pid() {
    local tunnel_name="$1"
    local pid_file="$PROJECT_ROOT/cloudflared/${tunnel_name}.pid"
    
    if [[ -f "$pid_file" ]]; then
        local pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            echo "$pid"
            return 0
        else
            # PID file exists but process is dead
            rm -f "$pid_file"
            return 1
        fi
    else
        return 1
    fi
}

# Check tunnel status
check_tunnel_status() {
    local tunnel_name="$1"
    
    if get_tunnel_pid "$tunnel_name" >/dev/null; then
        echo "running"
    else
        echo "stopped"
    fi
}

# Start single tunnel
start_tunnel() {
    local tunnel_name="$1"
    local config_file="$PROJECT_ROOT/cloudflared/${tunnel_name}.yml"
    local log_file="$PROJECT_ROOT/logs/cloudflared-${tunnel_name}.log"
    local pid_file="$PROJECT_ROOT/cloudflared/${tunnel_name}.pid"
    
    # Check if already running
    if [[ "$(check_tunnel_status "$tunnel_name")" == "running" ]]; then
        log_warning "Tunnel $tunnel_name is already running"
        return 0
    fi
    
    # Check config file
    if [[ ! -f "$config_file" ]]; then
        log_error "Config file not found: $config_file"
        log_info "Run: ./scripts/cloudflare/setup-tunnels.sh --domain <your-domain>"
        return 1
    fi
    
    # Create directories
    mkdir -p "$PROJECT_ROOT/logs"
    mkdir -p "$PROJECT_ROOT/cloudflared"
    
    log_info "Starting tunnel: $tunnel_name"
    
    # Start tunnel
    nohup cloudflared tunnel --config "$config_file" run > "$log_file" 2>&1 &
    local pid=$!
    
    # Save PID
    echo "$pid" > "$pid_file"
    
    # Wait a moment and check if it's still running
    sleep 2
    if kill -0 "$pid" 2>/dev/null; then
        log_success "✅ Started tunnel: $tunnel_name (PID: $pid)"
        return 0
    else
        log_error "❌ Failed to start tunnel: $tunnel_name"
        log_info "Check logs: tail -f $log_file"
        return 1
    fi
}

# Stop single tunnel
stop_tunnel() {
    local tunnel_name="$1"
    local pid_file="$PROJECT_ROOT/cloudflared/${tunnel_name}.pid"
    
    local pid
    if pid=$(get_tunnel_pid "$tunnel_name"); then
        log_info "Stopping tunnel: $tunnel_name (PID: $pid)"
        
        # Try graceful shutdown first
        if kill "$pid" 2>/dev/null; then
            # Wait for graceful shutdown
            local count=0
            while kill -0 "$pid" 2>/dev/null && [[ $count -lt 10 ]]; do
                sleep 1
                ((count++))
            done
            
            # Force kill if still running
            if kill -0 "$pid" 2>/dev/null; then
                log_warning "Forcing kill of tunnel: $tunnel_name"
                kill -9 "$pid" 2>/dev/null || true
            fi
        fi
        
        # Remove PID file
        rm -f "$pid_file"
        
        log_success "✅ Stopped tunnel: $tunnel_name"
        return 0
    else
        log_warning "Tunnel $tunnel_name is not running"
        return 0
    fi
}

# Restart single tunnel
restart_tunnel() {
    local tunnel_name="$1"
    
    log_info "Restarting tunnel: $tunnel_name"
    stop_tunnel "$tunnel_name"
    sleep 2
    start_tunnel "$tunnel_name"
}

# Show single tunnel status
show_tunnel_status() {
    local tunnel_name="$1"
    local status=$(check_tunnel_status "$tunnel_name")
    local pid=""
    
    if [[ "$status" == "running" ]]; then
        pid=$(get_tunnel_pid "$tunnel_name")
        echo "  • $tunnel_name: ✅ Running (PID: $pid)"
    else
        echo "  • $tunnel_name: ❌ Stopped"
    fi
}

# Show tunnel logs
show_tunnel_logs() {
    local tunnel_name="$1"
    local log_file="$PROJECT_ROOT/logs/cloudflared-${tunnel_name}.log"
    
    if [[ -f "$log_file" ]]; then
        log_info "Showing logs for tunnel: $tunnel_name"
        echo "----------------------------------------"
        tail -f "$log_file"
    else
        log_error "Log file not found: $log_file"
        return 1
    fi
}

# Execute action on tunnels
execute_action() {
    local tunnels_to_process=()
    
    if [[ "$ALL_TUNNELS" == true ]]; then
        tunnels_to_process=("${AVAILABLE_TUNNELS[@]}")
    else
        tunnels_to_process=("$TUNNEL_NAME")
    fi
    
    case "$ACTION" in
        start)
            log_info "Starting tunnels..."
            for tunnel in "${tunnels_to_process[@]}"; do
                start_tunnel "$tunnel"
            done
            ;;
        stop)
            log_info "Stopping tunnels..."
            for tunnel in "${tunnels_to_process[@]}"; do
                stop_tunnel "$tunnel"
            done
            ;;
        restart)
            log_info "Restarting tunnels..."
            for tunnel in "${tunnels_to_process[@]}"; do
                restart_tunnel "$tunnel"
            done
            ;;
        status)
            log_info "Tunnel status:"
            for tunnel in "${tunnels_to_process[@]}"; do
                show_tunnel_status "$tunnel"
            done
            ;;
        logs)
            if [[ "$ALL_TUNNELS" == true ]]; then
                log_error "Cannot show logs for all tunnels simultaneously"
                log_info "Use: $0 logs --tunnel <tunnel-name>"
                exit 1
            else
                show_tunnel_logs "$TUNNEL_NAME"
            fi
            ;;
    esac
}

# Show management summary
show_summary() {
    if [[ "$ACTION" == "logs" ]]; then
        return 0
    fi
    
    echo
    log_info "Tunnel management completed!"
    echo
    
    log_info "Current status:"
    for tunnel in "${AVAILABLE_TUNNELS[@]}"; do
        show_tunnel_status "$tunnel"
    done
    
    echo
    log_info "Management commands:"
    echo "  • Start all: $0 start --all"
    echo "  • Stop all: $0 stop --all"
    echo "  • Status: $0 status --all"
    echo "  • Logs: $0 logs --tunnel <name>"
}

# Main function
main() {
    # Parse arguments
    parse_arguments "$@"
    
    # Show action banner
    show_banner "CLOUDFLARE TUNNELS MANAGER"
    log_info "Action: $ACTION"
    
    if [[ "$ALL_TUNNELS" == true ]]; then
        log_info "Target: All tunnels"
    else
        log_info "Target: $TUNNEL_NAME"
    fi
    
    # Execute action
    execute_action
    
    # Show summary
    show_summary
}

# Run main function with all arguments
main "$@"
