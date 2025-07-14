#!/usr/bin/env bash
SCRIPT_DIR="${SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
source "${SCRIPT_DIR}/const_and_fctn.sh"

# Advanced Bash Logging Library
# Usage: source this file in your script, then use log_info, log_warn, etc.

# =============================================================================
# Configuration
# =============================================================================

# Log levels
readonly LOG_LEVEL_ERROR=1
readonly LOG_LEVEL_WARN=2
readonly LOG_LEVEL_INFO=3
readonly LOG_LEVEL_DEBUG=4

# Default log level (can be overridden)
LOG_LEVEL=${LOG_LEVEL:-$LOG_LEVEL_INFO}

# Terminal logging (set to true/false or use command line flags)
TERMINAL_LOGGING=${TERMINAL_LOGGING:-false}

# Color support detection
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
    COLORS_SUPPORTED=true
else
    COLORS_SUPPORTED=false
fi

# Color definitions
if [[ $COLORS_SUPPORTED == true ]]; then
    readonly COLOR_RED=$(tput setaf 1)
    readonly COLOR_YELLOW=$(tput setaf 226)
    readonly COLOR_GREEN=$(tput setaf 28)
    readonly COLOR_BLUE=$(tput setaf 21)
    readonly COLOR_MAGENTA=$(tput setaf 128)
    readonly COLOR_CYAN=$(tput setaf 36)
    readonly COLOR_WHITE=$(tput setaf 15)
    readonly COLOR_BOLD=$(tput bold)
    readonly COLOR_RESET=$(tput sgr0)
else
    readonly COLOR_RED=""
    readonly COLOR_YELLOW=""
    readonly COLOR_GREEN=""
    readonly COLOR_BLUE=""
    readonly COLOR_MAGENTA=""
    readonly COLOR_CYAN=""
    readonly COLOR_WHITE=""
    readonly COLOR_BOLD=""
    readonly COLOR_RESET=""

fi


# =============================================================================
# Helper Functions
# =============================================================================

# Get current timestamp
get_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Get script name for logger
get_script_name() {
    basename "${BASH_SOURCE[2]:-$0}"
}

# Parse command line arguments for logging options
parse_logging_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --verbose|-v)
                TERMINAL_LOGGING=true
                LOG_LEVEL=$LOG_LEVEL_DEBUG
                shift
                ;;
            --quiet|-q)
                TERMINAL_LOGGING=false
                shift
                ;;
            --terminal-log)
                TERMINAL_LOGGING=true
                shift
                ;;
            --no-colors)
                COLORS_SUPPORTED=false
                shift
                ;;
            --log-level)
                case $2 in
                    error|ERROR|1) LOG_LEVEL=$LOG_LEVEL_ERROR ;;
                    warn|WARN|2) LOG_LEVEL=$LOG_LEVEL_WARN ;;
                    info|INFO|3) LOG_LEVEL=$LOG_LEVEL_INFO ;;
                    debug|DEBUG|4) LOG_LEVEL=$LOG_LEVEL_DEBUG ;;
                    *) echo "Invalid log level: $2" >&2; exit 1 ;;
                esac
                shift 2
                ;;
            *)
                # Return remaining arguments
                break
                ;;
        esac
    done
}

# =============================================================================
# Core Logging Functions
# =============================================================================

# Internal logging function
_log() {
    local level=$1
    local syslog_priority=$2
    local color=$3
    local output_stream=$4
    shift 4
    
    local timestamp=$(get_timestamp)
    local script_name=$(get_script_name)
    
    # Always log to system logger
    logger -p "$syslog_priority" -t "$script_name" "$*"
    
    # Conditionally log to terminal
    if [[ $TERMINAL_LOGGING == true ]]; then
        local message
        if [[ $COLORS_SUPPORTED == true ]]; then
            message="${color}[${level}]${COLOR_RESET} ${COLOR_BOLD}${timestamp}${COLOR_RESET} $*"
        else
            message="[${level}] ${timestamp} $*"
        fi
        
        if [[ $output_stream == "stderr" ]]; then
            echo "$message" >&2
        else
            echo "$message"
        fi
    fi
}

# Public logging functions
log_error() {
    [[ $LOG_LEVEL -ge $LOG_LEVEL_ERROR ]] && _log "ERROR" "user.error" "$COLOR_RED" "stderr" "$@"
}

log_warn() {
    [[ $LOG_LEVEL -ge $LOG_LEVEL_WARN ]] && _log "WARN" "user.warning" "$COLOR_YELLOW" "stderr" "$@"
}

log_info() {
    [[ $LOG_LEVEL -ge $LOG_LEVEL_INFO ]] && _log "INFO" "user.info" "$COLOR_GREEN" "stdout" "$@"
}

log_debug() {
    [[ $LOG_LEVEL -ge $LOG_LEVEL_DEBUG ]] && _log "DEBUG" "user.debug" "$COLOR_CYAN" "stdout" "$@"
}

# Special logging functions
log_success() {
    [[ $LOG_LEVEL -ge $LOG_LEVEL_INFO ]] && _log "SUCCESS" "user.info" "$COLOR_GREEN$COLOR_BOLD" "stdout" "$@"
}

log_critical() {
    _log "CRITICAL" "user.crit" "$COLOR_RED$COLOR_BOLD" "stderr" "$@"
}

# =============================================================================
# Utility Functions
# =============================================================================

# Enable terminal logging
enable_terminal_logging() {
    TERMINAL_LOGGING=true
}

# Disable terminal logging
disable_terminal_logging() {
    TERMINAL_LOGGING=false
}

# Set log level
set_log_level() {
    case $1 in
        error|ERROR|1) LOG_LEVEL=$LOG_LEVEL_ERROR ;;
        warn|WARN|2) LOG_LEVEL=$LOG_LEVEL_WARN ;;
        info|INFO|3) LOG_LEVEL=$LOG_LEVEL_INFO ;;
        debug|DEBUG|4) LOG_LEVEL=$LOG_LEVEL_DEBUG ;;
        *) log_error "Invalid log level: $1"; return 1 ;;
    esac
}

# Get current log level as string
get_log_level() {
    case $LOG_LEVEL in
        $LOG_LEVEL_ERROR) echo "ERROR" ;;
        $LOG_LEVEL_WARN) echo "WARN" ;;
        $LOG_LEVEL_INFO) echo "INFO" ;;
        $LOG_LEVEL_DEBUG) echo "DEBUG" ;;
        *) echo "UNKNOWN" ;;
    esac
}

# Log configuration info
log_config_info() {
    if [[ $TERMINAL_LOGGING == true ]]; then
        log_info "Logging configuration:"
        log_info "  Terminal logging: ${COLOR_GREEN}ENABLED${COLOR_RESET}"
        log_info "  Colors: ${COLOR_GREEN}$([ $COLORS_SUPPORTED == true ] && echo "ENABLED" || echo "DISABLED")${COLOR_RESET}"
        log_info "  Log level: ${COLOR_CYAN}$(get_log_level)${COLOR_RESET}"
        log_info "  System logging: ${COLOR_GREEN}ENABLED${COLOR_RESET}"
    fi
}

# =============================================================================
# Example Usage and Help
# =============================================================================

# Show usage examples
show_logging_usage() {
    cat << 'EOF'
Bash Logging Library Usage:

1. Source this file in your script:
   source /path/to/logging_lib.sh

2. Parse command line arguments (optional):
   parse_logging_args "$@"

3. Use logging functions:
   log_info "This is an info message"
   log_warn "This is a warning"
   log_error "This is an error"
   log_debug "This is debug info"
   log_success "Operation completed successfully"
   log_critical "Critical system error"

Command line options:
  --verbose, -v        Enable terminal logging and debug level
  --quiet, -q          Disable terminal logging
  --terminal-log       Enable terminal logging
  --no-colors          Disable color output
  --log-level LEVEL    Set log level (error|warn|info|debug)

Environment variables:
  TERMINAL_LOGGING     Set to true/false to control terminal output
  LOG_LEVEL           Set to 1-4 to control log level

Examples:
  ./myscript.sh --verbose          # Enable terminal logging with debug
  ./myscript.sh --quiet            # Only log to system logger
  ./myscript.sh --log-level warn   # Show only warnings and errors
EOF
}