#!/bin/bash

# Interactive GDST Setup
# This script provides an interactive interface for the GDST tool

source "$(dirname "$0")/gdst.sh"

# Function to prompt for user input
prompt_for_input() {
    local prompt="$1"
    local default="$2"
    local variable_name="$3"
    local validation_function="$4"
    
    while true; do
        echo -e "${BLUE}$prompt${NC}"
        if [ -n "$default" ]; then
            echo -e "${GRAY}(default: $default)${NC}"
        fi
        echo -n "> "
        read -r input
        
        # Use default if no input provided
        if [ -z "$input" ] && [ -n "$default" ]; then
            input="$default"
        fi
        
        # Validate input if validation function provided
        if [ -n "$validation_function" ]; then
            if "$validation_function" "$input"; then
                eval "$variable_name='$input'"
                break
            else
                echo -e "${RED}Invalid input. Please try again.${NC}"
            fi
        else
            eval "$variable_name='$input'"
            break
        fi
    done
}

# Validation functions
validate_repo_name() {
    local name="$1"
    if [[ "$name" =~ ^[a-zA-Z0-9_.-]+$ ]]; then
        return 0
    else
        print_error "Repository name must contain only letters, numbers, hyphens, underscores, and dots"
        return 1
    fi
}

validate_project_type() {
    local type="$1"
    if [[ "$type" =~ ^(node|python|java|react|other)$ ]]; then
        return 0
    else
        print_error "Project type must be one of: node, python, java, react, other"
        return 1
    fi
}

# Interactive setup function
interactive_setup() {
    print_header "GDST Interactive Setup"
    echo "This will guide you through setting up a new development project."
    echo ""
    
    # Repository name
    prompt_for_input "Enter repository name:" "" "REPO_NAME" "validate_repo_name"
    
    # GitHub username
    prompt_for_input "Enter GitHub username:" "" "GITHUB_USERNAME"
    
    # Project type
    echo -e "${BLUE}Available project types:${NC}"
    echo "  • node - Node.js project with npm, Jest, ESLint"
    echo "  • react - React project (same as node)"
    echo "  • python - Python project with pip, pytest, black"
    echo "  • java - Java project with Maven"
    echo "  • other - Generic project structure"
    prompt_for_input "Select project type:" "node" "PROJECT_TYPE" "validate_project_type"
    
    # Repository visibility
    echo -e "${BLUE}Repository visibility:${NC}"
    echo "  • public - Anyone can see this repository"
    echo "  • private - Only you and collaborators can see this repository"
    prompt_for_input "Repository visibility (public/private):" "public" "REPO_VISIBILITY"
    
    # Working directory
    prompt_for_input "Working directory:" "$(pwd)" "WORKING_DIR"
    
    # Optional features
    echo -e "${BLUE}Optional features:${NC}"
    echo -n "Skip package installation? (y/N): "
    read -r skip_install
    if [[ "$skip_install" =~ ^[Yy]$ ]]; then
        SKIP_INSTALL=true
    fi
    
    echo -n "Skip branch protection setup? (y/N): "
    read -r skip_protection
    if [[ "$skip_protection" =~ ^[Yy]$ ]]; then
        SKIP_PROTECTION=true
    fi
    
    echo -n "Run in dry-run mode? (y/N): "
    read -r dry_run
    if [[ "$dry_run" =~ ^[Yy]$ ]]; then
        DRY_RUN=true
    fi
    
    # Show summary
    echo ""
    print_header "Configuration Summary"
    show_configuration
    
    echo -e "${BLUE}Proceed with setup? (Y/n):${NC}"
    read -r proceed
    if [[ "$proceed" =~ ^[Nn]$ ]]; then
        print_status "Setup cancelled by user"
        exit 0
    fi
    
    # Continue with normal setup
    return 0
}

# Main function for interactive mode
main_interactive() {
    interactive_setup
    
    # Call original main function with constructed arguments
    main --name "$REPO_NAME" --username "$GITHUB_USERNAME" --type "$PROJECT_TYPE" --visibility "$REPO_VISIBILITY" --directory "$WORKING_DIR" ${SKIP_INSTALL:+--skip-install} ${SKIP_PROTECTION:+--skip-protection} ${DRY_RUN:+--dry-run}
}

# Run interactive setup if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main_interactive
fi
