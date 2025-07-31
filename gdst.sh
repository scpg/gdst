#!/bin/bash

# GDST - GitHub Development Setup Tool
# This script sets up a complete development environment with branching strategy and GitHub configuration
# Designed for command-line automation with comprehensive logging and validation

set -e

# Get the directory where this script is located
SCRIPT_FIX_NAME="gdst"
SCRIPT_DIR="${SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

# Ensure we're sourcing from the correct directory (handle CI environments)
LIB_DIR="${SCRIPT_DIR}/lib"
if [[ ! -d "$LIB_DIR" ]]; then
    # Try to find the lib directory relative to current working directory
    if [[ -d "./lib" ]]; then
        LIB_DIR="./lib"
    elif [[ -d "../lib" ]]; then
        LIB_DIR="../lib"
    else
        echo "ERROR: Cannot find lib directory. Expected at: $LIB_DIR" >&2
        exit 1
    fi
fi

source "${LIB_DIR}/constants.sh"
source "${LIB_DIR}/logging_lib.sh"
# Source template utilities
source "${LIB_DIR}/template_utils.sh"


# Configuration
REPO_NAME=""
GITHUB_USERNAME=""
PROJECT_TYPE="node" # node, python, java, etc.
REPO_VISIBILITY="public" # public or private
SKIP_INSTALL=false
SKIP_PROTECTION=false
DRY_RUN=false
VERBOSE_MODE=false
LOG_LEVEL="INFO" # INFO, WARN, ERROR, DEBUG
WORKING_DIR="$(pwd)"

# Function to load configuration file
load_config_file() {
    local config_file="${1:-gdst.conf}"
    
    # Quick pre-parse to check for -d/--directory option
    local target_dir="$WORKING_DIR"
    local args=("$@")
    for ((i=0; i<${#args[@]}; i++)); do
        case "${args[i]}" in
            -d|--directory)
                if [ $((i+1)) -lt ${#args[@]} ]; then
                    target_dir="${args[$((i+1))]}"
                    break
                fi
                ;;
        esac
    done
    
    # Check if config file exists in script directory first, then in target directory
    local config_path=""
    if [ -f "${SCRIPT_DIR}/${config_file}" ]; then
        config_path="${SCRIPT_DIR}/${config_file}"
    elif [ -f "${target_dir}/${config_file}" ]; then
        config_path="${target_dir}/${config_file}"
    fi
    
    if [ -n "$config_path" ]; then
        print_debug "Loading configuration from: $config_path"
        # Source the config file in a safe manner
        while IFS='=' read -r key value; do
            # Skip comments and empty lines
            [[ "$key" =~ ^[[:space:]]*# ]] && continue
            [[ -z "$key" ]] && continue
            
            # Remove leading/trailing whitespace and quotes
            key=$(echo "$key" | xargs)
            value=$(echo "$value" | xargs | sed 's/^"//; s/"$//')
            
            # Only set if the value is not empty and variable is not already set by command line
            if [[ -n "$value" ]]; then
                case "$key" in
                    REPO_NAME)
                        [[ -z "$REPO_NAME" ]] && REPO_NAME="$value"
                        ;;
                    GITHUB_USERNAME)
                        [[ -z "$GITHUB_USERNAME" ]] && GITHUB_USERNAME="$value"
                        ;;
                    PROJECT_TYPE)
                        # Only use config value if still at default
                        [[ "$PROJECT_TYPE" == "node" ]] && PROJECT_TYPE="$value"
                        ;;
                    REPO_VISIBILITY)
                        # Only use config value if still at default
                        [[ "$REPO_VISIBILITY" == "public" ]] && REPO_VISIBILITY="$value"
                        ;;
                    WORKING_DIR)
                        # Only use config value if still at default
                        [[ "$WORKING_DIR" == "$(pwd)" ]] && WORKING_DIR="$value"
                        ;;
                    SKIP_INSTALL)
                        # Only use config value if still at default
                        [[ "$SKIP_INSTALL" == "false" ]] && SKIP_INSTALL="$value"
                        ;;
                    SKIP_PROTECTION)
                        # Only use config value if still at default
                        [[ "$SKIP_PROTECTION" == "false" ]] && SKIP_PROTECTION="$value"
                        ;;
                    DRY_RUN)
                        # Only use config value if still at default
                        [[ "$DRY_RUN" == "false" ]] && DRY_RUN="$value"
                        ;;
                    VERBOSE_MODE)
                        # Only use config value if still at default
                        [[ "$VERBOSE_MODE" == "false" ]] && VERBOSE_MODE="$value"
                        ;;
                    LOG_LEVEL)
                        # Only use config value if still at default
                        [[ "$LOG_LEVEL" == "INFO" ]] && LOG_LEVEL="$value"
                        ;;
                esac
            fi
        done < "$config_path"
        print_debug "Configuration loaded successfully"
    else
        print_debug "No configuration file found (checked: ${SCRIPT_DIR}/${config_file} and ${WORKING_DIR}/${config_file})"
    fi
}

# Function to print colored output
print_status() {
    if [[ "$LOG_LEVEL" =~ ^(INFO|DEBUG)$ ]]; then
        echo -e "${GREEN}[INFO]${NC} $1"
    fi
}

# Enhanced logging with timestamps
LOG_FILE=""
LOG_TIMESTAMP=true

# Function to initialize logging
init_logging() {
    if [ -n "$LOG_FILE" ]; then
        LOG_FILE="$(pwd)/gdst_$(date +%Y%m%d_%H%M%S).log"
        print_debug "Logging to file: $LOG_FILE"
    fi
}

# Function to log message with timestamp
log_message() {
    local level="$1"
    local message="$2"
    local timestamp=""
    
    if [ "$LOG_TIMESTAMP" = true ]; then
        timestamp="$(date '+%Y-%m-%d %H:%M:%S') "
    fi
    
    local log_entry="${timestamp}[$level] $message"
    
    if [ -n "$LOG_FILE" ]; then
        echo "$log_entry" >> "$LOG_FILE"
    fi
    
    # Also output to console based on log level
    case "$level" in
        ERROR)
            echo -e "${RED}[ERROR]${NC} $message" >&2
            ;;
        WARN)
            if [[ "$LOG_LEVEL" =~ ^(WARN|INFO|DEBUG)$ ]]; then
                echo -e "${YELLOW}[WARNING]${NC} $message"
            fi
            ;;
        INFO)
            if [[ "$LOG_LEVEL" =~ ^(INFO|DEBUG)$ ]]; then
                echo -e "${GREEN}[INFO]${NC} $message"
            fi
            ;;
        DEBUG)
            if [[ "$LOG_LEVEL" == "DEBUG" ]]; then
                echo -e "${BLUE}[DEBUG]${NC} $message" >&2
            fi
            ;;
    esac
}

# Update existing print functions to use structured logging
print_status() {
    log_message_safely "INFO" "$1"
}

print_warning() {
    log_message_safely "WARN" "$1"
}

print_error() {
    log_message_safely "ERROR" "$1"
}

print_debug() {
    log_message_safely "DEBUG" "$1"
}

print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Security validation functions
sanitize_input() {
    local input="$1"
    local allow_special="${2:-false}"
    
    if [ -z "$input" ]; then
        return 1
    fi
    
    # Remove dangerous characters if not allowing special characters
    if [ "$allow_special" = "false" ]; then
        # Remove shell metacharacters, command substitution, and path traversal attempts
        input=$(echo "$input" | sed -e 's/\]/\_/g' -e 's/[;&|`$(){}\\\*?<>[]/_/g' | sed 's|\.\./||g')
        # Remove any remaining quotes or backticks
        input=$(echo "$input" | tr -d '`"'"'")
    fi
    
    # Validate length (reasonable limits)
    if [ ${#input} -gt 100 ]; then
        return 1
    fi
    
    # Ensure result is not empty after sanitization
    if [ -z "$input" ]; then
        return 1
    fi
    
    echo "$input"
    return 0
}

# Function to validate repository name
validate_repo_name() {
    local repo_name="$1"
    
    # Check if empty
    if [ -z "$repo_name" ]; then
        print_error "Repository name cannot be empty"
        return 1
    fi
    
    # Check length
    if [ ${#repo_name} -gt 100 ]; then
        print_error "Repository name too long (max 100 characters)"
        return 1
    fi
    
    # Check for valid characters (GitHub naming rules)
    if ! [[ "$repo_name" =~ ^[a-zA-Z0-9._-]+$ ]]; then
        print_error "Repository name contains invalid characters. Use only letters, numbers, dots, hyphens, and underscores"
        return 1
    fi
    
    # Check for dangerous patterns
    if [[ "$repo_name" =~ \.\./|^\.|\.$|^-|--$ ]]; then
        print_error "Repository name contains dangerous patterns"
        return 1
    fi
    
    return 0
}

# Function to validate GitHub username
validate_github_username() {
    local username="$1"
    
    # Check if empty
    if [ -z "$username" ]; then
        print_error "GitHub username cannot be empty"
        return 1
    fi
    
    # Check length
    if [ ${#username} -gt 39 ]; then
        print_error "GitHub username too long (max 39 characters)"
        return 1
    fi
    
    # Check for valid characters (GitHub username rules)
    if ! [[ "$username" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$ ]]; then
        print_error "GitHub username contains invalid characters or format"
        return 1
    fi
    
    # Check for dangerous patterns
    if [[ "$username" =~ \.\./|^\.|\.$|^-|--$ ]]; then
        print_error "GitHub username contains dangerous patterns"
        return 1
    fi
    
    return 0
}

# Function to sanitize file paths
sanitize_path() {
    local path="$1"
    local allow_relative="${2:-false}"
    
    if [ -z "$path" ]; then
        return 1
    fi
    
    # Remove path traversal attempts using proper sed escaping
    path=$(echo "$path" | sed 's|\.\./||g' | sed 's|/\.\./|/|g')
    
    # Remove multiple consecutive slashes
    path=$(echo "$path" | sed 's|/\+|/|g')
    
    # Remove dangerous characters using character class
    path=$(echo "$path" | sed 's|[;&|`$(){}[\]\\*?<>]|_|g')
    
    # If not allowing relative paths, ensure it doesn't start with ../
    if [ "$allow_relative" = "false" ]; then
        if [[ "$path" =~ ^\.\./|/\.\./|^\.\.$ ]]; then
            return 1
        fi
    fi
    
    echo "$path"
    return 0
}

# Function to validate and sanitize working directory
validate_working_directory() {
    local dir_path="$1"
    
    # If empty or just current directory, use pwd
    if [ -z "$dir_path" ] || [ "$dir_path" = "." ]; then
        dir_path="$(pwd)"
    fi
    
    # Sanitize the path
    local sanitized_path
    sanitized_path=$(sanitize_path "$dir_path" true)
    
    if [ $? -ne 0 ] || [ -z "$sanitized_path" ]; then
        print_error "Invalid working directory path"
        return 1
    fi
    
    # Convert to absolute path, handling different cases
    local abs_path
    if [[ "$sanitized_path" == /* ]]; then
        # Already absolute
        abs_path="$sanitized_path"
    elif [ "$sanitized_path" = "." ]; then
        # Current directory
        abs_path="$(pwd)"
    else
        # Make relative path absolute
        abs_path="$(pwd)/$sanitized_path"
    fi
    
    # Validate the resolved path
    if ! validate_directory "$abs_path" "working directory"; then
        return 1
    fi
    
    echo "$abs_path"
    return 0
}

# Function to escape shell arguments safely
escape_shell_arg() {
    local arg="$1"
    
    # Use printf %q to safely escape shell arguments
    printf '%q' "$arg"
}

# Function to execute commands with input validation
execute_command_with_validation() {
    local description="$1"
    local continue_on_error="${2:-false}"
    shift 2
    
    print_debug "Executing with validation: $*"
    
    # Validate all arguments
    local validated_args=()
    for arg in "$@"; do
        local escaped_arg
        escaped_arg=$(escape_shell_arg "$arg")
        validated_args+=("$escaped_arg")
    done
    
    # Execute the command with validated arguments
    if eval "${validated_args[@]}" 2>/dev/null; then
        print_status "$description ✓"
        return 0
    else
        if [ "$continue_on_error" = "true" ]; then
            print_warning "$description failed, continuing..."
            return 0
        else
            print_error "$description failed"
            return 1
        fi
    fi
}

# Function to safely process templates with input validation
process_template_safely() {
    local template_file="$1"
    local destination_file="$2"
    local repo_name="$3"
    local github_username="$4"
    
    # Validate inputs
    local safe_template_file
    safe_template_file=$(sanitize_path "$template_file")
    if [ $? -ne 0 ]; then
        print_error "Invalid template file path"
        return 1
    fi
    
    local safe_destination_file
    safe_destination_file=$(sanitize_path "$destination_file")
    if [ $? -ne 0 ]; then
        print_error "Invalid destination file path"
        return 1
    fi
    
    local safe_repo_name
    safe_repo_name=$(sanitize_input "$repo_name")
    if [ $? -ne 0 ]; then
        print_error "Invalid repository name for template processing"
        return 1
    fi
    
    local safe_github_username
    safe_github_username=$(sanitize_input "$github_username")
    if [ $? -ne 0 ]; then
        print_error "Invalid GitHub username for template processing"
        return 1
    fi
    
    # Process template with validated inputs
    if copy_template "$safe_template_file" "$safe_destination_file" "$safe_repo_name" "$safe_github_username"; then
        return 0
    else
        print_error "Template processing failed"
        return 1
    fi
}

# Function to log messages safely (prevent log injection)
log_message_safely() {
    local level="$1"
    local message="$2"
    
    # Sanitize log message to prevent injection
    local safe_message
    safe_message=$(echo "$message" | sed 's/[;&|`$(){}[\]\\]/\\&/g' | tr -d '\n\r')
    
    # Limit message length
    if [ ${#safe_message} -gt 500 ]; then
        safe_message="${safe_message:0:500}..."
    fi
    
    # Call original log function with sanitized message
    log_message "$level" "$safe_message"
}

# Function to handle errors safely without exposing sensitive information
handle_error_safely() {
    local error_context="$1"
    local sensitive_info="${2:-false}"
    
    if [ "$sensitive_info" = "true" ]; then
        # Don't expose sensitive information in error messages
        print_error "$error_context failed - check logs for details"
        log_message_safely "ERROR" "$error_context failed with sensitive information"
    else
        print_error "$error_context failed"
    fi
}

# Function to safely copy templates with error handling
copy_template_safe() {
    local template_file="$1"
    local destination_file="$2"
    local repo_name="$3"
    local github_username="$4"
    local description="${5:-$(basename "$destination_file")}"
    
    print_debug "Copying template: $template_file -> $destination_file"
    
    # Use secure template processing
    if process_template_safely "$template_file" "$destination_file" "$repo_name" "$github_username"; then
        print_status "Created $description"
        return 0
    else
        print_error "Failed to create $description from template"
        return 1
    fi
}

# Function to safely create directories with error handling
create_directory_safe() {
    local dir_path="$1"
    local description="${2:-directory}"
    
    print_debug "Creating directory: $dir_path"
    
    # Sanitize directory path
    local safe_dir_path
    safe_dir_path=$(sanitize_path "$dir_path")
    if [ $? -ne 0 ]; then
        print_error "Invalid directory path: $dir_path"
        return 1
    fi
    
    if mkdir -p "$safe_dir_path" 2>/dev/null; then
        print_status "Created $description: $safe_dir_path"
        return 0
    else
        print_error "Failed to create $description: $safe_dir_path"
        return 1
    fi
}

# Function to safely execute commands with error handling
execute_command_safe() {
    local description="$1"
    local continue_on_error="${2:-false}"
    shift 2
    
    print_debug "Executing: $*"
    
    # Use secure command execution
    if execute_command_with_validation "$description" "$continue_on_error" "$@"; then
        return 0
    else
        return 1
    fi
}

# Working directory management functions
ORIGINAL_DIR=""
PROJECT_DIR=""

# Function to save current directory
save_current_directory() {
    ORIGINAL_DIR="$(pwd)"
    print_debug "Saved current directory: $ORIGINAL_DIR"
}

# Function to safely change to working directory
change_to_working_directory() {
    local target_dir="$1"
    
    print_debug "Changing to working directory: $target_dir"
    
    if [ ! -d "$target_dir" ]; then
        print_error "Working directory does not exist: $target_dir"
        return 1
    fi
    
    if ! cd "$target_dir"; then
        print_error "Failed to change to working directory: $target_dir"
        return 1
    fi
    
    print_debug "Successfully changed to: $(pwd)"
    return 0
}

# Function to safely change to project directory
change_to_project_directory() {
    local project_name="$1"
    
    PROJECT_DIR="$(pwd)/$project_name"
    print_debug "Changing to project directory: $PROJECT_DIR"
    
    if [ ! -d "$project_name" ]; then
        print_error "Project directory does not exist: $project_name"
        return 1
    fi
    
    if ! cd "$project_name"; then
        print_error "Failed to change to project directory: $project_name"
        return 1
    fi
    
    print_debug "Successfully changed to project directory: $(pwd)"
    return 0
}

# Function to restore original directory
restore_original_directory() {
    if [ -n "$ORIGINAL_DIR" ] && [ -d "$ORIGINAL_DIR" ]; then
        print_debug "Restoring original directory: $ORIGINAL_DIR"
        if cd "$ORIGINAL_DIR"; then
            print_debug "Successfully restored to: $(pwd)"
        else
            print_warning "Failed to restore original directory: $ORIGINAL_DIR"
        fi
    else
        print_warning "No original directory to restore"
    fi
}

# Function to get current working directory safely
get_current_directory() {
    pwd 2>/dev/null || {
        print_error "Failed to get current directory"
        return 1
    }
}

# Function to validate directory exists and is accessible
validate_directory() {
    local dir_path="$1"
    local description="${2:-directory}"
    
    if [ -z "$dir_path" ]; then
        print_error "Directory path is empty for $description"
        return 1
    fi
    
    if [ ! -d "$dir_path" ]; then
        print_error "$description does not exist: $dir_path"
        return 1
    fi
    
    if [ ! -r "$dir_path" ]; then
        print_error "$description is not readable: $dir_path"
        return 1
    fi
    
    if [ ! -w "$dir_path" ]; then
        print_error "$description is not writable: $dir_path"
        return 1
    fi
    
    print_debug "Directory validation passed for $description: $dir_path"
    return 0
}

# Function to check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    print_debug "Starting prerequisite checks..."
    
    # Check if templates directory exists
    if ! check_templates_directory; then
        exit 1
    fi
    
    # Check if we're in WSL
    if grep -q microsoft /proc/version 2>/dev/null; then
        print_status "Running in WSL environment ✓"
    else
        print_warning "Not running in WSL. Some features may not work as expected."
    fi
    
    # Use comprehensive dependency validation
    if ! validate_all_dependencies; then
        exit 1
    fi
    
    print_status "All prerequisites satisfied ✓"
}

# Function to configure git user with improved logic
configure_git_user() {
    print_debug "Configuring Git user settings..."
    
    # Check both local and global git configuration
    local local_name=$(git config --local user.name 2>/dev/null)
    local local_email=$(git config --local user.email 2>/dev/null)
    local global_name=$(git config --global user.name 2>/dev/null)
    local global_email=$(git config --global user.email 2>/dev/null)
    
    # Determine if we need to set local configuration
    local need_local_config=false
    
    # If no local config and no global config, we need to set something
    if [ -z "$local_name" ] && [ -z "$global_name" ]; then
        need_local_config=true
        print_warning "No Git user name configured globally or locally"
    fi
    
    if [ -z "$local_email" ] && [ -z "$global_email" ]; then
        need_local_config=true
        print_warning "No Git user email configured globally or locally"
    fi
    
    # If we need local config, try to get better defaults
    if [ "$need_local_config" = true ]; then
        local default_name="Developer"
        local default_email="developer@local.dev"
        
        # Try to get better defaults from environment or system
        if [ -n "$USER" ]; then
            default_name="$USER"
        elif [ -n "$USERNAME" ]; then
            default_name="$USERNAME"
        fi
        
        # Try to construct a better email
        if [ -n "$USER" ]; then
            default_email="$USER@$(hostname -f 2>/dev/null || echo 'local.dev')"
        fi
        
        # Set local git configuration
        if [ -z "$local_name" ] && [ -z "$global_name" ]; then
            git config --local user.name "$default_name"
            print_status "Set local Git user name to: $default_name"
        fi
        
        if [ -z "$local_email" ] && [ -z "$global_email" ]; then
            git config --local user.email "$default_email"
            print_status "Set local Git user email to: $default_email"
        fi
        
        print_warning "Git user configuration is temporary for this repository"
        print_warning "Configure globally with: git config --global user.name 'Your Name'"
        print_warning "Configure globally with: git config --global user.email 'your.email@example.com'"
    else
        # Configuration exists, just report what we're using
        local effective_name="${local_name:-$global_name}"
        local effective_email="${local_email:-$global_email}"
        print_status "Using Git user: $effective_name <$effective_email>"
    fi
}

# Function to create initial branch structure with improved error handling
create_initial_branch_structure() {
    print_debug "Creating initial branch structure..."
    
    # Set default branch name
    git config init.defaultBranch main
    
    # Get current branch name
    local current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    print_debug "Current branch: $current_branch"
    
    # Create initial commit if repository is empty
    if [ -z "$(git log --oneline 2>/dev/null)" ]; then
        print_status "Creating initial commit..."
        touch .gitkeep
        git add .gitkeep
        
        if ! git commit -m "Initial commit: Setup development workflow"; then
            print_error "Failed to create initial commit"
            return 1
        fi
    fi
    
    # Ensure we're on main branch
    if [ "$current_branch" != "main" ]; then
        print_status "Renaming current branch to main..."
        git branch -M main 2>/dev/null || {
            print_warning "Could not rename branch to main, continuing..."
        }
    fi
    
    # Create development branches with proper error handling
    print_status "Creating development branches..."
    
    # Create dev/main branch
    if ! git show-ref --verify --quiet refs/heads/dev/main; then
        if git checkout -b dev/main; then
            print_status "Created dev/main branch"
        else
            print_error "Failed to create dev/main branch"
            return 1
        fi
    else
        print_status "dev/main branch already exists"
        git checkout dev/main
    fi
    
    # Create qa/staging branch from dev/main
    if ! git show-ref --verify --quiet refs/heads/qa/staging; then
        if git checkout -b qa/staging; then
            print_status "Created qa/staging branch"
        else
            print_error "Failed to create qa/staging branch"
            return 1
        fi
    else
        print_status "qa/staging branch already exists"
        git checkout qa/staging
    fi
    
    # Return to dev/main as the working branch
    if ! git checkout dev/main; then
        print_error "Failed to checkout dev/main branch"
        return 1
    fi
    
    print_status "Branch structure created successfully"
    print_status "Working on dev/main branch"
    
    return 0
}

# Function to setup local development environment
setup_local_environment() {
    print_header "Setting up Local Development Environment"
    
    # Save current directory
    if ! save_current_directory; then
        print_error "Failed to save current directory"
        return 1
    fi
    
    # Create project directory
    if [ ! -d "$REPO_NAME" ]; then
        if [ "$DRY_RUN" = true ]; then
            echo -e "${YELLOW}[DRY RUN]${NC} Would create project directory: $REPO_NAME"
        else
            mkdir "$REPO_NAME"
            print_status "Created project directory: $REPO_NAME"
        fi
    fi
    
    if [ "$DRY_RUN" = false ]; then
        if ! change_to_working_directory "$REPO_NAME"; then
            print_error "Failed to change to project directory: $REPO_NAME"
            return 1
        fi
    fi
    
    # Initialize git repository
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY RUN]${NC} Would initialize Git repository"
        echo -e "${YELLOW}[DRY RUN]${NC} Would configure Git user"
        echo -e "${YELLOW}[DRY RUN]${NC} Would create initial branch structure"
        print_status "Created initial branch structure (dry run)"
        
        # Call project setup function
        case $PROJECT_TYPE in
            node|react)
                setup_node_project
                ;;
            python)
                setup_python_project
                ;;
            java)
                setup_java_project
                ;;
            *)
                setup_generic_project
                ;;
        esac
        return 0
    fi
    
    # Initialize git repository
    if [ ! -d ".git" ]; then
        git init
        print_status "Initialized Git repository"
    fi
    
    # Configure git user with improved logic
    configure_git_user || return 1
    
    # Create initial branch structure
    create_initial_branch_structure || return 1
    
    print_status "Created initial branch structure"
    
    # Create project structure based on type with error handling
    print_status "Setting up project structure for $PROJECT_TYPE"
    case $PROJECT_TYPE in
        node|react)
            setup_node_project || return 1
            ;;
        python)
            setup_python_project || return 1
            ;;
        java)
            setup_java_project || return 1
            ;;
        *)
            setup_generic_project || return 1
            ;;
    esac
    
    return 0
}

# Function to setup Node.js project
setup_node_project() {
    print_status "Setting up Node.js project structure"
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY RUN]${NC} Would create package.json with Node.js configuration"
        echo -e "${YELLOW}[DRY RUN]${NC} Would create src/, tests/, docs/ directories"
        echo -e "${YELLOW}[DRY RUN]${NC} Would create sample files: src/index.js, tests/index.test.js"
        return 0
    fi
    
    # Create basic project structure with error handling
    create_directory_safe "src" "source directory" || return 1
    create_directory_safe "tests" "tests directory" || return 1
    create_directory_safe "docs" "documentation directory" || return 1
    
    # Create package.json from template
    if [ ! -f "package.json" ]; then
        copy_template_safe "$TEMPLATES_DIR/project-configs/package.json.template" "package.json" "$REPO_NAME" "$GITHUB_USERNAME" "package.json" || return 1
    fi
    
    # Create sample files from templates with error handling
    if [ ! -f "src/index.js" ]; then
        copy_template_safe "$TEMPLATES_DIR/project-configs/src-index.js.template" "src/index.js" "$REPO_NAME" "$GITHUB_USERNAME" "src/index.js" || return 1
    fi
    
    if [ ! -f "tests/index.test.js" ]; then
        copy_template_safe "$TEMPLATES_DIR/project-configs/test-index.test.js.template" "tests/index.test.js" "$REPO_NAME" "$GITHUB_USERNAME" "tests/index.test.js" || return 1
    fi
    
    return 0
}

# Function to setup Python project
setup_python_project() {
    print_status "Setting up Python project structure"
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY RUN]${NC} Would create Python project structure"
        echo -e "${YELLOW}[DRY RUN]${NC} Would create requirements.txt and requirements-dev.txt"
        echo -e "${YELLOW}[DRY RUN]${NC} Would create src/, tests/, docs/ directories"
        echo -e "${YELLOW}[DRY RUN]${NC} Would create sample files: src/main.py, tests/test_main.py"
        return 0
    fi
    
    # Create basic project structure with error handling
    create_directory_safe "src" "source directory" || return 1
    create_directory_safe "tests" "tests directory" || return 1
    create_directory_safe "docs" "documentation directory" || return 1
    
    # Create requirements files from templates
    if [ ! -f "requirements.txt" ]; then
        if ! touch requirements.txt; then
            print_error "Failed to create requirements.txt"
            return 1
        fi
        print_status "Created requirements.txt"
    fi
    
    if [ ! -f "requirements-dev.txt" ]; then
        copy_template_safe "$TEMPLATES_DIR/project-configs/requirements-dev.txt.template" "requirements-dev.txt" "$REPO_NAME" "$GITHUB_USERNAME" "requirements-dev.txt" || return 1
    fi
    
    # Create sample files from templates with error handling
    if [ ! -f "src/main.py" ]; then
        copy_template_safe "$TEMPLATES_DIR/project-configs/src-main.py.template" "src/main.py" "$REPO_NAME" "$GITHUB_USERNAME" "src/main.py" || return 1
    fi
    
    if [ ! -f "tests/test_main.py" ]; then
        copy_template_safe "$TEMPLATES_DIR/project-configs/test-main.py.template" "tests/test_main.py" "$REPO_NAME" "$GITHUB_USERNAME" "tests/test_main.py" || return 1
    fi
    
    return 0
}

# Function to setup Java project
setup_java_project() {
    print_status "Setting up Java project structure"
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY RUN]${NC} Would create Java project structure with Maven"
        echo -e "${YELLOW}[DRY RUN]${NC} Would create pom.xml"
        echo -e "${YELLOW}[DRY RUN]${NC} Would create src/main/java and src/test/java directories"
        return 0
    fi
    
    # Create basic project structure with error handling
    create_directory_safe "src/main/java" "Java source directory" || return 1
    create_directory_safe "src/test/java" "Java test directory" || return 1
    
    # Create pom.xml from template
    if [ ! -f "pom.xml" ]; then
        copy_template_safe "$TEMPLATES_DIR/project-configs/pom.xml.template" "pom.xml" "$REPO_NAME" "$GITHUB_USERNAME" "pom.xml" || return 1
    fi
    
    return 0
}

# Function to setup generic project
setup_generic_project() {
    print_status "Setting up generic project structure"
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY RUN]${NC} Would create generic project structure"
        echo -e "${YELLOW}[DRY RUN]${NC} Would create src/, docs/, tests/ directories"
        return 0
    fi
    
    # Create basic project structure with error handling
    create_directory_safe "src" "source directory" || return 1
    create_directory_safe "docs" "documentation directory" || return 1
    create_directory_safe "tests" "tests directory" || return 1
    
    return 0
}

# Function to create GitHub workflows
create_github_workflows() {
    print_header "Creating GitHub Workflows"
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY RUN]${NC} Would create .github/workflows/ci-cd.yml"
        echo -e "${YELLOW}[DRY RUN]${NC} Would create .github/pull_request_template/default.md"
        print_status "GitHub workflows created ✓ (dry run)"
        return 0
    fi
    
    # Create GitHub workflows from templates with error handling
    copy_template_safe "$TEMPLATES_DIR/workflows/ci-cd.yml.template" ".github/workflows/ci-cd.yml" "$REPO_NAME" "$GITHUB_USERNAME" "CI/CD workflow" || return 1
    copy_template_safe "$TEMPLATES_DIR/workflows/pull_request_template.md.template" ".github/pull_request_template/default.md" "$REPO_NAME" "$GITHUB_USERNAME" "PR template" || return 1
    
    print_status "GitHub workflows created ✓"
    return 0
}

# Function to create configuration files
create_config_files() {
    print_header "Creating Configuration Files"
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY RUN]${NC} Would create .gitignore for $PROJECT_TYPE project"
        echo -e "${YELLOW}[DRY RUN]${NC} Would create .env.example"
        echo -e "${YELLOW}[DRY RUN]${NC} Would create README.md"
        print_status "Configuration files created ✓ (dry run)"
        return 0
    fi
    
    # Create .gitignore using templates with error handling
    local gitignore_template=$(get_gitignore_template "$PROJECT_TYPE")
    if [ ! -f ".gitignore" ]; then
        copy_template_safe "$gitignore_template" ".gitignore" "$REPO_NAME" "$GITHUB_USERNAME" ".gitignore" || return 1
    fi
    
    # Create .env.example using template with error handling
    if [ ! -f ".env.example" ]; then
        copy_template_safe "$TEMPLATES_DIR/project-configs/.env.example.template" ".env.example" "$REPO_NAME" "$GITHUB_USERNAME" ".env.example" || return 1
    fi
    
    # Create README.md using template with error handling
    if [ ! -f "README.md" ]; then
        copy_template_safe "$TEMPLATES_DIR/docs/README.md.template" "README.md" "$REPO_NAME" "$GITHUB_USERNAME" "README.md" || return 1
    fi
    
    print_status "Configuration files created ✓"
    return 0
}

# Function to setup GitHub repository
setup_github_repository() {
    print_header "Setting up GitHub Repository"
    
    # Check if user is logged in to GitHub CLI
    if ! gh auth status >/dev/null 2>&1; then
        print_warning "Not logged in to GitHub CLI. Please authenticate:"
        gh auth login
    fi
    
    # Create repository
    print_status "Creating GitHub repository..."
    local visibility_flag=""
    if [ "$REPO_VISIBILITY" = "private" ]; then
        visibility_flag="--private"
    else
        visibility_flag="--public"
    fi
    
    if gh repo create "$REPO_NAME" $visibility_flag --description "Auto-generated repository with development workflow" 2>/dev/null; then
        print_status "GitHub repository created successfully ($REPO_VISIBILITY)"
    else
        print_warning "Failed to create repository (may already exist)"
    fi
    
    # Add remote origin
    git remote add origin "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git" 2>/dev/null || print_warning "Remote origin may already exist"
    
    print_status "GitHub repository created ✓"
}

# Function to configure branch protection using modern GitHub rulesets
configure_branch_protection() {
    print_header "Configuring Branch Protection"
    
    # Ensure we're on the correct branch and push changes
    print_status "Pushing initial branch structure to GitHub..."
    
    # Add all files and commit
    git add .
    git commit -m "Initial commit: Setup development workflow" --allow-empty
    
    # Push dev/main branch first
    if ! git push -u origin dev/main; then
        print_error "Failed to push dev/main branch"
        return 1
    fi
    
    # Push qa/staging branch
    if git checkout qa/staging; then
        if ! git merge dev/main --no-edit; then
            print_warning "Failed to merge dev/main into qa/staging"
        fi
        if ! git push -u origin qa/staging; then
            print_warning "Failed to push qa/staging branch"
        fi
    else
        print_warning "Failed to checkout qa/staging branch"
    fi
    
    # Push main branch
    if git checkout main; then
        if ! git merge dev/main --no-edit; then
            print_warning "Failed to merge dev/main into main"
        fi
        if ! git push -u origin main; then
            print_warning "Failed to push main branch"
        fi
    else
        print_warning "Failed to checkout main branch"
    fi
    
    # Return to dev/main
    if ! git checkout dev/main; then
        print_error "Failed to return to dev/main branch"
        return 1
    fi
    
    print_status "Setting up GitHub repository rulesets..."
    
    # Wait a moment for branches to be available on GitHub
    sleep 3
    
    # Setup rulesets using the new script
    if [ -f "scripts/setup-github-rulesets.sh" ]; then
        print_status "Creating repository rulesets for branch protection and naming validation..."
        if bash scripts/setup-github-rulesets.sh setup "$GITHUB_USERNAME" "$REPO_NAME"; then
            print_status "✅ Repository rulesets configured successfully"
        else
            print_warning "⚠️  Ruleset configuration completed with some warnings"
            print_warning "You can manually run: ./scripts/setup-github-rulesets.sh setup $GITHUB_USERNAME $REPO_NAME"
        fi
    else
        print_warning "Ruleset setup script not found, falling back to basic branch protection"
        # Fallback to simpler protection if ruleset script is missing
        print_status "Creating basic branch protection rules..."
        
        # Try to create basic branch protection (simplified)
        gh api repos/"$GITHUB_USERNAME"/"$REPO_NAME"/branches/main/protection \
            --method PUT \
            --field required_pull_request_reviews='{"required_approving_review_count":1}' \
            --field enforce_admins=false \
            --field restrictions=null 2>/dev/null || print_warning "Could not set basic branch protection"
    fi
    
    print_status "Branch protection setup completed ✓"
}

# Function to create helper scripts
create_helper_scripts() {
    print_header "Creating Helper Scripts"
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY RUN]${NC} Would create scripts/new-feature.sh"
        echo -e "${YELLOW}[DRY RUN]${NC} Would create scripts/deploy-qa.sh"
        echo -e "${YELLOW}[DRY RUN]${NC} Would create scripts/deploy-prod.sh"
        print_status "Helper scripts created ✓ (dry run)"
        return 0
    fi
    
    # Create scripts directory
    create_directory_safe "scripts" "scripts directory" || return 1
    
    # Create scripts from templates with error handling
    copy_template_safe "$TEMPLATES_DIR/scripts/new-feature.sh.template" "scripts/new-feature.sh" "$REPO_NAME" "$GITHUB_USERNAME" "new-feature.sh script" || return 1
    copy_template_safe "$TEMPLATES_DIR/scripts/deploy-qa.sh.template" "scripts/deploy-qa.sh" "$REPO_NAME" "$GITHUB_USERNAME" "deploy-qa.sh script" || return 1
    copy_template_safe "$TEMPLATES_DIR/scripts/deploy-prod.sh.template" "scripts/deploy-prod.sh" "$REPO_NAME" "$GITHUB_USERNAME" "deploy-prod.sh script" || return 1
    copy_template_safe "$TEMPLATES_DIR/scripts/setup-github-rulesets.sh.template" "scripts/setup-github-rulesets.sh" "$REPO_NAME" "$GITHUB_USERNAME" "setup-github-rulesets.sh script" || return 1
    
    # Make scripts executable with error handling
    if ! chmod +x scripts/*.sh; then
        print_error "Failed to make scripts executable"
        return 1
    fi
    
    print_status "Helper scripts created ✓"
    return 0
}

# Function to setup development tools
setup_development_tools() {
    print_header "Setting up Development Tools"
    
    if [ "$DRY_RUN" = true ]; then
        print_status "Dry run mode - would install development tools for $PROJECT_TYPE project"
        return 0
    fi
    
    # Pre-validate dependencies before attempting setup
    if ! check_project_dependencies "$PROJECT_TYPE"; then
        print_warning "Project dependencies not met, skipping development tools setup"
        return 0
    fi
    
    case $PROJECT_TYPE in
        node|react)
            # Install development dependencies
            if command_exists npm && [ -f "package.json" ]; then
                execute_command_safe "Installing Node.js development dependencies" true npm install
                
                # Setup Husky for git hooks
                if [ -d "node_modules" ]; then
                    execute_command_safe "Installing Husky git hooks" true npx husky install
                    execute_command_safe "Adding pre-commit hook" true npx husky add .husky/pre-commit "npx lint-staged"
                    
                    # Create lint-staged configuration by modifying package.json
                    if ! sed -i '$d' package.json; then
                        print_warning "Failed to modify package.json for lint-staged config"
                    else
                        # Add lint-staged config and close the JSON
                        if ! cat >> package.json << 'EOF'; then
  },
  "lint-staged": {
    "*.{js,jsx,ts,tsx}": [
      "eslint --fix",
      "prettier --write"
    ],
    "*.{json,css,md}": [
      "prettier --write"
    ]
  }
}
EOF
                            print_warning "Failed to add lint-staged configuration"
                        fi
                    fi
                fi
            else
                print_warning "npm not found or package.json missing, skipping Node.js setup"
            fi
            ;;
        python)
            # Setup Python virtual environment
            if command_exists python3; then
                execute_command_safe "Setting up Python virtual environment" true python3 -m venv venv
                if [ -f "venv/bin/activate" ]; then
                    source venv/bin/activate
                    execute_command_safe "Installing Python dependencies" true pip install -r requirements-dev.txt
                    
                    # Setup pre-commit hooks using template
                    copy_template_safe "$TEMPLATES_DIR/project-configs/.pre-commit-config.yaml.template" ".pre-commit-config.yaml" "$REPO_NAME" "$GITHUB_USERNAME" ".pre-commit-config.yaml" || print_warning "Failed to create pre-commit config"
                    execute_command_safe "Installing pre-commit hooks" true pre-commit install
                fi
            else
                print_warning "python3 not found, skipping Python setup"
            fi
            ;;
        java)
            # Java projects typically use Maven or Gradle
            if command_exists mvn; then
                execute_command_safe "Validating Maven project structure" true mvn validate
                print_status "Maven project structure validated"
            else
                print_warning "Maven not found, skipping Java build validation"
            fi
            ;;
        *)
            print_status "No specific development tools setup for project type: $PROJECT_TYPE"
            ;;
    esac
    
    print_status "Development tools configured ✓"
}

# Function to create documentation
create_documentation() {
    print_header "Creating Documentation"
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY RUN]${NC} Would create docs/DEVELOPMENT.md"
        echo -e "${YELLOW}[DRY RUN]${NC} Would create docs/DEPLOYMENT.md"
        print_status "Documentation created ✓ (dry run)"
        return 0
    fi
    
    # Create docs directory
    create_directory_safe "docs" "documentation directory" || return 1
    
    # Create documentation from templates with error handling
    copy_template_safe "$TEMPLATES_DIR/docs/DEVELOPMENT.md.template" "docs/DEVELOPMENT.md" "$REPO_NAME" "$GITHUB_USERNAME" "DEVELOPMENT.md" || return 1
    copy_template_safe "$TEMPLATES_DIR/docs/DEPLOYMENT.md.template" "docs/DEPLOYMENT.md" "$REPO_NAME" "$GITHUB_USERNAME" "DEPLOYMENT.md" || return 1
    
    print_status "Documentation created ✓"
    return 0
}

# Function to setup branch validation
setup_branch_validation() {
    print_header "Setting up Branch Validation"
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY RUN]${NC} Would create branch validation scripts"
        echo -e "${YELLOW}[DRY RUN]${NC} Would install Git hooks"
        echo -e "${YELLOW}[DRY RUN]${NC} Would create branch naming documentation"
        print_status "Branch validation setup ✓ (dry run)"
        return 0
    fi
    
    # Create scripts directory if it doesn't exist
    create_directory_safe "scripts" "scripts directory" || return 1
    
    # Copy branch validation script with error handling
    copy_template_safe "$TEMPLATES_DIR/scripts/validate-branch-name.sh.template" "scripts/validate-branch-name.sh" "$REPO_NAME" "$GITHUB_USERNAME" "validate-branch-name.sh script" || return 1
    
    execute_command_safe "Make validation script executable" false chmod +x scripts/validate-branch-name.sh || return 1
    
    # Setup Git hooks
    print_status "Installing Git hooks for branch validation..."
    
    # Create hooks directory
    create_directory_safe ".git/hooks" "git hooks directory" || return 1
    
    # Copy pre-commit hook for branch validation with error handling
    copy_template_safe "$TEMPLATES_DIR/project-configs/pre-commit-branch-check.template" ".git/hooks/pre-commit-branch-check" "$REPO_NAME" "$GITHUB_USERNAME" "pre-commit-branch-check hook" || return 1
    execute_command_safe "Make pre-commit-branch-check executable" false chmod +x .git/hooks/pre-commit-branch-check || return 1
    
    # Copy pre-push hook for branch validation with error handling
    copy_template_safe "$TEMPLATES_DIR/project-configs/pre-push.template" ".git/hooks/pre-push" "$REPO_NAME" "$GITHUB_USERNAME" "pre-push hook" || return 1
    execute_command_safe "Make pre-push hook executable" false chmod +x .git/hooks/pre-push || return 1
    
    # Create or update existing pre-commit hook to include branch validation
    if [ -f ".git/hooks/pre-commit" ]; then
        # Append to existing pre-commit hook
        if ! grep -q "pre-commit-branch-check" .git/hooks/pre-commit; then
            {
                echo ""
                echo "# Branch name validation"
                echo "bash \"\$(git rev-parse --show-toplevel)/.git/hooks/pre-commit-branch-check\""
            } >> .git/hooks/pre-commit || {
                print_error "Failed to update existing pre-commit hook"
                return 1
            }
        fi
    else
        # Create new pre-commit hook
        if ! cat > .git/hooks/pre-commit << 'EOF'; then
#!/bin/bash

# Branch name validation
bash "$(git rev-parse --show-toplevel)/.git/hooks/pre-commit-branch-check"
EOF
            print_error "Failed to create pre-commit hook"
            return 1
        fi
        execute_command_safe "Make pre-commit hook executable" false chmod +x .git/hooks/pre-commit || return 1
    fi
    
    # Create branch naming documentation with error handling
    copy_template_safe "$TEMPLATES_DIR/docs/BRANCH_NAMING.md.template" "docs/BRANCH_NAMING.md" "$REPO_NAME" "$GITHUB_USERNAME" "BRANCH_NAMING.md" || return 1
    
    print_status "Branch validation setup ✓"
    print_status "Git hooks installed for automatic branch name validation"
    print_status "Branch naming documentation created at docs/BRANCH_NAMING.md"
    
    return 0
}

# Function to check project-specific dependencies
check_project_dependencies() {
    local project_type="$1"
    local missing_deps=()
    
    case "$project_type" in
        node|react)
            if ! command_exists node; then
                missing_deps+=("node")
            fi
            if ! command_exists npm; then
                missing_deps+=("npm")
            fi
            ;;
        python)
            if ! command_exists python3; then
                missing_deps+=("python3")
            fi
            if ! command_exists pip3; then
                missing_deps+=("pip3")
            fi
            ;;
        java)
            if ! command_exists java; then
                missing_deps+=("java")
            fi
            if ! command_exists mvn; then
                missing_deps+=("mvn")
            fi
            ;;
    esac
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing project dependencies for $project_type: ${missing_deps[*]}"
        show_installation_guide "${missing_deps[@]}"
        return 1
    fi
    
    return 0
}

# Function to show installation guide for missing dependencies
show_installation_guide() {
    local missing_deps=("$@")
    
    print_header "Installation Guide for Missing Dependencies"
    
    for dep in "${missing_deps[@]}"; do
        case "$dep" in
            node)
                echo -e "${BLUE}To install Node.js:${NC}"
                echo "  • Using NodeSource: curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && sudo apt-get install -y nodejs"
                echo "  • Using NVM: curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash && nvm install --lts"
                echo "  • Using snap: sudo snap install node --classic"
                echo ""
                ;;
            npm)
                echo -e "${BLUE}To install npm:${NC}"
                echo "  • Usually installed with Node.js"
                echo "  • If separate: sudo apt-get install npm"
                echo ""
                ;;
            python3)
                echo -e "${BLUE}To install Python 3:${NC}"
                echo "  • Ubuntu/Debian: sudo apt-get install python3 python3-pip python3-venv"
                echo "  • Using pyenv: curl https://pyenv.run | bash"
                echo ""
                ;;
            pip3)
                echo -e "${BLUE}To install pip3:${NC}"
                echo "  • Ubuntu/Debian: sudo apt-get install python3-pip"
                echo "  • Using get-pip: curl https://bootstrap.pypa.io/get-pip.py | python3"
                echo ""
                ;;
            java)
                echo -e "${BLUE}To install Java:${NC}"
                echo "  • OpenJDK 11: sudo apt-get install openjdk-11-jdk"
                echo "  • OpenJDK 17: sudo apt-get install openjdk-17-jdk"
                echo "  • Oracle JDK: Download from https://www.oracle.com/java/technologies/downloads/"
                echo ""
                ;;
            mvn)
                echo -e "${BLUE}To install Maven:${NC}"
                echo "  • Ubuntu/Debian: sudo apt-get install maven"
                echo "  • Manual: Download from https://maven.apache.org/download.cgi"
                echo ""
                ;;
            git)
                echo -e "${BLUE}To install Git:${NC}"
                echo "  • Ubuntu/Debian: sudo apt-get install git"
                echo "  • Configure: git config --global user.name 'Your Name' && git config --global user.email 'your.email@example.com'"
                echo ""
                ;;
            gh)
                echo -e "${BLUE}To install GitHub CLI:${NC}"
                echo "  • Official: curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg"
                echo "  • Add repo: echo 'deb [arch=\$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main' | sudo tee /etc/apt/sources.list.d/github-cli.list"
                echo "  • Install: sudo apt update && sudo apt install gh"
                echo "  • Login: gh auth login"
                echo ""
                ;;
            curl)
                echo -e "${BLUE}To install curl:${NC}"
                echo "  • Ubuntu/Debian: sudo apt-get install curl"
                echo ""
                ;;
        esac
    done
    
    echo -e "${RED}Please install the missing dependencies and run the script again.${NC}"
}

# Function to validate all core dependencies
validate_core_dependencies() {
    print_debug "Validating core dependencies..."
    
    local missing_core=()
    
    # Core dependencies required by all project types
    if ! command_exists git; then
        missing_core+=("git")
    fi
    
    if ! command_exists curl; then
        missing_core+=("curl")
    fi
    
    if ! command_exists gh; then
        missing_core+=("gh")
    fi
    
    if [ ${#missing_core[@]} -ne 0 ]; then
        print_error "Missing core dependencies: ${missing_core[*]}"
        show_installation_guide "${missing_core[@]}"
        return 1
    fi
    
    return 0
}

# Function to validate GitHub CLI authentication
validate_github_authentication() {
    print_debug "Validating GitHub CLI authentication..."
    
    if ! command_exists gh; then
        print_error "GitHub CLI not installed"
        return 1
    fi
    
    if ! gh auth status >/dev/null 2>&1; then
        print_error "GitHub CLI not authenticated"
        echo ""
        echo -e "${YELLOW}Please run:${NC} gh auth login"
        echo -e "${YELLOW}Then run this script again.${NC}"
        return 1
    fi
    
    print_debug "GitHub CLI authentication verified"
    return 0
}

# Function to perform comprehensive dependency validation
validate_all_dependencies() {
    print_header "Validating Dependencies"
    
    # Skip in dry run mode
    if [ "$DRY_RUN" = true ]; then
        print_status "Dry run mode - skipping dependency validation"
        return 0
    fi
    
    # Validate core dependencies
    if ! validate_core_dependencies; then
        return 1
    fi
    
    # Validate GitHub authentication
    if ! validate_github_authentication; then
        return 1
    fi
    
    # Validate project-specific dependencies
    if ! check_project_dependencies "$PROJECT_TYPE"; then
        return 1
    fi
    
    print_status "All dependencies validated successfully ✓"
    return 0
}

# Function to perform pre-flight checks
perform_preflight_checks() {
    print_header "Pre-flight Checks"
    
    local checks_passed=true
    
    # Check disk space
    local available_space=$(df -BG "$(pwd)" | awk 'NR==2 {print $4}' | sed 's/G//')
    if [ "$available_space" -lt 1 ]; then
        print_error "Insufficient disk space (less than 1GB available)"
        checks_passed=false
    else
        print_status "Disk space check passed (${available_space}GB available)"
    fi
    
    # Check internet connectivity (skip in CI environments or dry-run)
    if [ "$DRY_RUN" = true ] || [ -n "$CI" ] || [ -n "$GITHUB_ACTIONS" ]; then
        print_status "Internet connectivity check skipped (CI/dry-run mode)"
    elif ! ping -c 1 github.com >/dev/null 2>&1; then
        print_warning "No internet connection to GitHub (tests may be limited)"
        # Don't fail the pre-flight checks for connectivity in dry-run scenarios
    else
        print_status "Internet connectivity check passed"
    fi
    
    # Check GitHub API rate limit
    if command_exists gh; then
        local rate_limit
        rate_limit=$(gh api rate_limit 2>/dev/null | grep -o '"remaining":[0-9]*' | cut -d: -f2 2>/dev/null)
        
        # Ensure rate_limit is a valid integer
        if [[ "$rate_limit" =~ ^[0-9]+$ ]]; then
            if [ "$rate_limit" -lt 10 ]; then
                print_warning "GitHub API rate limit is low: $rate_limit requests remaining"
            else
                print_status "GitHub API rate limit check passed ($rate_limit requests remaining)"
            fi
        else
            print_warning "Could not determine GitHub API rate limit"
        fi
    fi
    
    # Check if repository already exists
    if [ "$DRY_RUN" = false ] && command_exists gh; then
        if gh repo view "$GITHUB_USERNAME/$REPO_NAME" >/dev/null 2>&1; then
            print_error "Repository $GITHUB_USERNAME/$REPO_NAME already exists on GitHub"
            checks_passed=false
        else
            print_status "Repository name availability check passed"
        fi
    fi
    
    # Check local directory conflicts
    if [ -d "$REPO_NAME" ]; then
        print_warning "Local directory $REPO_NAME already exists"
        if [ "$DRY_RUN" = false ]; then
            echo -e "${YELLOW}This will modify the existing directory. Continue? (y/N)${NC}"
            read -r response
            if [[ ! "$response" =~ ^[Yy]$ ]]; then
                print_error "Operation cancelled by user"
                checks_passed=false
            fi
        fi
    fi
    
    if [ "$checks_passed" = true ]; then
        print_status "All pre-flight checks passed ✓"
        return 0
    else
        print_error "Pre-flight checks failed"
        return 1
    fi
}

# Progress indicator functions
PROGRESS_CURRENT=0
PROGRESS_TOTAL=0
PROGRESS_ENABLED=true

# Function to initialize progress
init_progress() {
    local total="$1"
    PROGRESS_TOTAL="$total"
    PROGRESS_CURRENT=0
    
    if [ "$VERBOSE_MODE" = true ] && [ "$PROGRESS_ENABLED" = true ]; then
        echo -e "${BLUE}Progress: [${PROGRESS_CURRENT}/${PROGRESS_TOTAL}]${NC}"
    fi
}

# Function to update progress
update_progress() {
    local message="$1"
    ((PROGRESS_CURRENT++))
    
    if [ "$VERBOSE_MODE" = true ] && [ "$PROGRESS_ENABLED" = true ]; then
        local percentage=$(( (PROGRESS_CURRENT * 100) / PROGRESS_TOTAL ))
        echo -e "${BLUE}Progress: [${PROGRESS_CURRENT}/${PROGRESS_TOTAL}] (${percentage}%) - ${message}${NC}"
    fi
}

# Function to show spinner for long operations
show_spinner() {
    local pid="$1"
    local message="$2"
    local spin_chars="⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
    local i=0
    
    if [ "$VERBOSE_MODE" != true ]; then
        return 0
    fi
    
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r${BLUE}%s${NC} %s" "${spin_chars:i++%${#spin_chars}:1}" "$message"
        sleep 0.1
    done
    
    printf "\r${GREEN}✓${NC} %s\n" "$message"
}

# Function to show version
show_version() {
    echo "GDST - GitHub Development Setup Tool v1.0.0"
    echo "Copyright (c) 2025"
}

# Function to show help
show_help() {
    echo "GDST - GitHub Development Setup Tool"
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Required arguments:"
    echo "  -n, --name NAME          Repository name"
    echo "  -u, --username USERNAME  GitHub username"
    echo ""
    echo "Optional arguments:"
    echo "  -t, --type TYPE          Project type (node, python, java, react, other) [default: node]"
    echo "  -V, --visibility VIS     Repository visibility (public, private) [default: public]"
    echo "  -d, --directory DIR      Working directory [default: current directory]"
    echo "  -v, --verbose            Enable verbose output"
    echo "  -l, --level LEVEL        Log level (INFO, WARN, ERROR, DEBUG) [default: INFO]"
    echo "  --skip-install           Skip package installation"
    echo "  --skip-protection        Skip branch protection setup"
    echo "  --dry-run                Show what would be done without making changes"
    echo "  -h, --help               Show this help message"
    echo "  --version                Show version information"
    echo ""
    echo "Examples:"
    echo "  $0 -n my-project -u myusername"
    echo "  $0 -n my-app -u myusername -t python -V private"
    echo "  $0 -n test-project -u myusername --dry-run"
    echo "  $0 -n my-project -u myusername --verbose"
    echo ""
    echo "This script sets up a complete development workflow with:"
    echo "  • Local development environment"
    echo "  • GitHub repository with branch protection"
    echo "  • CI/CD pipelines with branch validation"
    echo "  • Automated branch naming validation (Git hooks)"
    echo "  • Enhanced development tools and scripts"
    echo "  • Branch naming conventions documentation"
}

# Function to parse command line arguments
parse_arguments() {
    print_debug "Parsing command line arguments: $*"
    while [[ $# -gt 0 ]]; do
        case $1 in
            -n|--name)
                REPO_NAME="$2"
                shift 2
                ;;
            -u|--username)
                GITHUB_USERNAME="$2"
                shift 2
                ;;
            -t|--type)
                PROJECT_TYPE="$2"
                shift 2
                ;;
            -V|--visibility)
                REPO_VISIBILITY="$2"
                shift 2
                ;;
            -d|--directory)
                WORKING_DIR="$2"
                shift 2
                ;;
            -v|--verbose)
                VERBOSE_MODE=true
                LOG_LEVEL="DEBUG"
                shift
                ;;
            -l|--level)
                LOG_LEVEL="$2"
                shift 2
                ;;
            --skip-install)
                SKIP_INSTALL=true
                shift
                ;;
            --skip-protection)
                SKIP_PROTECTION=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            --version)
                show_version
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                echo "Use --help for usage information"
                exit 1
                ;;
        esac
    done
}

# Function to validate arguments
validate_arguments() {
    # Repository name and username are always required
    if [ -z "$REPO_NAME" ]; then
        print_error "Repository name is required. Use -n or --name"
        echo "Run '$0 --help' for usage information"
        exit 1
    fi
    
    if [ -z "$GITHUB_USERNAME" ]; then
        print_error "GitHub username is required. Use -u or --username"
        echo "Run '$0 --help' for usage information"
        exit 1
    fi
    
    # Validate repository name with security checks
    if ! validate_repo_name "$REPO_NAME"; then
        # In dry run mode, sanitize the name instead of failing
        if [ "$DRY_RUN" = true ]; then
            print_warning "Repository name contains invalid characters, sanitizing..."
            local sanitized_name
            sanitized_name=$(sanitize_input "$REPO_NAME")
            if [ $? -eq 0 ] && [ -n "$sanitized_name" ]; then
                REPO_NAME="$sanitized_name"
                print_warning "Using sanitized name: $REPO_NAME"
            else
                REPO_NAME="sanitized-project"
                print_warning "Using fallback name: $REPO_NAME"
            fi
        else
            exit 1
        fi
    fi
    
    # Validate GitHub username with security checks
    if ! validate_github_username "$GITHUB_USERNAME"; then
        # In dry run mode, sanitize the username instead of failing
        if [ "$DRY_RUN" = true ]; then
            print_warning "GitHub username contains invalid characters, sanitizing..."
            GITHUB_USERNAME=$(sanitize_input "$GITHUB_USERNAME")
            if [ $? -ne 0 ] || [ -z "$GITHUB_USERNAME" ]; then
                GITHUB_USERNAME="sanitized-user"
                print_warning "Using sanitized username: $GITHUB_USERNAME"
            fi
        else
            exit 1
        fi
    fi
    
    # Validate project type
    if [[ ! "$PROJECT_TYPE" =~ ^(node|python|java|react|other)$ ]]; then
        print_error "Invalid project type: $PROJECT_TYPE. Supported: node, python, java, react, other"
        exit 1
    fi
    
    # Validate repository visibility
    if [[ ! "$REPO_VISIBILITY" =~ ^(public|private)$ ]]; then
        print_error "Invalid repository visibility: $REPO_VISIBILITY. Supported: public, private"
        exit 1
    fi
    
    # Validate log level
    if [[ ! "$LOG_LEVEL" =~ ^(INFO|WARN|ERROR|DEBUG)$ ]]; then
        print_error "Invalid log level: $LOG_LEVEL. Supported: INFO, WARN, ERROR, DEBUG"
        exit 1
    fi
    
    # Validate and sanitize working directory
    local validated_working_dir
    validated_working_dir=$(validate_working_directory "$WORKING_DIR")
    if [ $? -ne 0 ]; then
        # In dry run mode, use current directory as fallback
        if [ "$DRY_RUN" = true ]; then
            print_warning "Working directory invalid, using current directory"
            WORKING_DIR="$(pwd)"
        else
            exit 1
        fi
    else
        WORKING_DIR="$validated_working_dir"
    fi
}

# Function to show configuration
show_configuration() {
    print_debug "Current configuration: Repository=$REPO_NAME, Username=$GITHUB_USERNAME, Type=$PROJECT_TYPE"
    
    echo -e "\n${GREEN}Configuration:${NC}"
    echo "Repository: $REPO_NAME"
    echo "GitHub Username: $GITHUB_USERNAME"
    echo "Project Type: $PROJECT_TYPE"
    echo "Repository Visibility: $REPO_VISIBILITY"
    echo "Working Directory: $WORKING_DIR"
    if [ "$VERBOSE_MODE" = true ]; then
        echo "Verbose Mode: Yes"
    fi
    if [ "$LOG_LEVEL" != "INFO" ]; then
        echo "Log Level: $LOG_LEVEL"
    fi
    if [ "$SKIP_INSTALL" = true ]; then
        echo "Skip Package Install: Yes"
    fi
    if [ "$SKIP_PROTECTION" = true ]; then
        echo "Skip Branch Protection: Yes"
    fi
    if [ "$DRY_RUN" = true ]; then
        echo "Dry Run Mode: Yes"
    fi
    echo ""
}

# Main execution function
main() {
    # Load configuration file first (before argument parsing)
    # Pass arguments to allow pre-parsing for -d option
    load_config_file "gdst.conf" "$@"
    
    # Parse command line arguments (these will override config file values)
    parse_arguments "$@"
    
    # Validate arguments
    validate_arguments
    
    # Save current directory and change to working directory
    if ! save_current_directory; then
        print_error "Failed to save current directory"
        exit 1
    fi
    
    if ! change_to_working_directory "$WORKING_DIR"; then
        print_error "Failed to change to working directory: $WORKING_DIR"
        exit 1
    fi
    
    print_header "GDST - Development Workflow Setup"
    print_status "This script will set up a complete development workflow with:"
    echo "  • Local development environment"
    echo "  • GitHub repository with branch protection"
    echo "  • CI/CD pipelines with branch validation"
    echo "  • Automated branch naming validation (Git hooks)"
    echo "  • Enhanced development tools and scripts"
    echo "  • Branch naming conventions documentation"
    echo ""
    
    if [ "$DRY_RUN" = false ]; then
        print_warning "Prerequisites:"
        echo "  • GitHub CLI must be authenticated (run 'gh auth login' first)"
        echo "  • Stable internet connection required"
        echo "  • Git user configuration (will be set if missing)"
        echo ""
    fi
    
    # Show configuration
    show_configuration
    
    # Execute setup steps with error handling
    check_prerequisites || {
        print_error "Prerequisites check failed"
        exit 1
    }
    
    perform_preflight_checks || {
        print_error "Pre-flight checks failed"
        exit 1
    }
    
    setup_local_environment || {
        print_error "Local environment setup failed"
        exit 1
    }
    
    create_github_workflows || {
        print_error "GitHub workflows creation failed"
        exit 1
    }
    
    create_config_files || {
        print_error "Configuration files creation failed"
        exit 1
    }
    
    if [ "$DRY_RUN" = false ]; then
        setup_github_repository || {
            print_error "GitHub repository setup failed"
            exit 1
        }
        
        if [ "$SKIP_PROTECTION" = false ]; then
            configure_branch_protection || {
                print_error "Branch protection configuration failed"
                exit 1
            }
        else
            print_warning "Skipping branch protection setup"
        fi
    fi
    
    create_helper_scripts || {
        print_error "Helper scripts creation failed"
        exit 1
    }
    
    if [ "$SKIP_INSTALL" = false ]; then
        setup_development_tools || {
            print_warning "Development tools setup failed, continuing..."
        }
    else
        print_warning "Skipping package installation"
    fi
    
    create_documentation || {
        print_error "Documentation creation failed"
        exit 1
    }
    
    setup_branch_validation || {
        print_warning "Branch validation setup failed, continuing..."
    }
    
    print_header "Setup Complete!"
    if [ "$DRY_RUN" = true ]; then
        print_status "Dry run completed - no actual changes were made"
    else
        print_status "Your development workflow is now ready!"
    fi
    echo ""
    echo -e "${GREEN}Next steps:${NC}"
    echo "1. Review the generated files and customize as needed"
    echo "2. Update .env with your actual configuration"
    echo "3. Start developing with: ./scripts/new-feature.sh <feature-name>"
    echo "4. Deploy to QA with: ./scripts/deploy-qa.sh"
    echo "5. Deploy to production with: ./scripts/deploy-prod.sh"
    echo ""
    if [ "$DRY_RUN" = false ]; then
    echo -e "${BLUE}Repository:${NC} https://github.com/$GITHUB_USERNAME/$REPO_NAME"
        echo -e "${BLUE}Documentation:${NC} Check docs/ folder for detailed guides"
        echo -e "${BLUE}Advanced Features:${NC} See docs/ADVANCED_RULESETS.md for ruleset details"
        echo ""
        echo -e "${RED}⚠️  Repository Management:${NC}"
        echo -e "${RED}If the repository created is incorrect, you can delete it with the command:${NC}"
        echo -e "${RED}gh repo delete $GITHUB_USERNAME/$REPO_NAME --yes${NC}"
        echo -e "${RED}Warning: This will permanently delete the repository and all its contents!${NC}"
        echo ""
        echo -e "${YELLOW}💡 To also remove the local directory:${NC}"
        echo -e "${YELLOW}rm -rf $REPO_NAME${NC}"
    fi
    
    # Restore original directory
    if ! restore_original_directory; then
        print_warning "Failed to restore original directory"
    fi
}

# Run main function with all arguments
main "$@"