#!/bin/bash

# Template utility functions for gdst.sh
# This file contains helper functions for processing template files

# Get the directory where this script is located
SCRIPT_DIR="${SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

TEMPLATES_DIR="$SCRIPT_DIR/templates"

# Function to escape special characters for sed
escape_sed_string() {
    local string="$1"
    # Escape backslashes, pipes, and other special characters that could break sed
    echo "$string" | sed 's/\\/\\\\/g; s/|/\\|/g; s/&/\\&/g'
}

# Function to substitute variables in a template
substitute_template() {
    local template_content="$1"
    local repo_name="$2"
    local github_username="$3"
    
    # Escape special characters in the replacement strings
    local escaped_repo_name=$(escape_sed_string "$repo_name")
    local escaped_github_username=$(escape_sed_string "$github_username")
    
    # Replace template variables using pipe delimiter to avoid issues with special characters
    echo "$template_content" | \
        sed "s|{{REPO_NAME}}|${escaped_repo_name}|g" | \
        sed "s|{{GITHUB_USERNAME}}|${escaped_github_username}|g"
}

# Function to copy and process a template file
copy_template() {
    local template_file="$1"
    local destination_file="$2"
    local repo_name="$3"
    local github_username="$4"
    
    # Validate input parameters
    if [ -z "$template_file" ] || [ -z "$destination_file" ] || [ -z "$repo_name" ] || [ -z "$github_username" ]; then
        print_error "copy_template: Missing required parameters"
        return 1
    fi
    
    if [ ! -f "$template_file" ]; then
        print_error "Template file not found: $template_file"
        return 1
    fi
    
    local template_content=$(cat "$template_file")
    local processed_content=$(substitute_template "$template_content" "$repo_name" "$github_username")
    
    # Create destination directory if it doesn't exist
    local dest_dir=$(dirname "$destination_file")
    mkdir -p "$dest_dir"
    
    # Write the processed content to the destination file
    echo "$processed_content" > "$destination_file"
    
    # Verify the file was created successfully
    if [ ! -f "$destination_file" ]; then
        print_error "Failed to create destination file: $destination_file"
        return 1
    fi
    
    return 0
}

# Function to get gitignore template based on project type
get_gitignore_template() {
    local project_type="$1"
    
    case $project_type in
        node|react)
            echo "$TEMPLATES_DIR/gitignore/.gitignore.node"
            ;;
        python)
            echo "$TEMPLATES_DIR/gitignore/.gitignore.python"
            ;;
        java)
            echo "$TEMPLATES_DIR/gitignore/.gitignore.java"
            ;;
        *)
            echo "$TEMPLATES_DIR/gitignore/.gitignore.generic"
            ;;
    esac
}

# Function to check if templates directory exists
check_templates_directory() {
    if [ ! -d "$TEMPLATES_DIR" ]; then
        print_error "Templates directory not found: $TEMPLATES_DIR"
        print_status "Please ensure the templates directory is in the same location as the script"
        return 1
    fi
    return 0
}

# Function to validate template file
validate_template() {
    local template_file="$1"
    local template_name="${2:-$(basename "$template_file")}"
    
    if [ ! -f "$template_file" ]; then
        print_error "Template file not found: $template_file"
        return 1
    fi
    
    if [ ! -r "$template_file" ]; then
        print_error "Template file not readable: $template_file"
        return 1
    fi
    
    # Check for required template variables
    local required_vars=("{{REPO_NAME}}" "{{GITHUB_USERNAME}}")
    local missing_vars=()
    
    for var in "${required_vars[@]}"; do
        if ! grep -q "$var" "$template_file"; then
            missing_vars+=("$var")
        fi
    done
    
    if [ ${#missing_vars[@]} -ne 0 ]; then
        print_warning "Template $template_name missing variables: ${missing_vars[*]}"
    fi
    
    print_debug "Template validation passed for: $template_name"
    return 0
}

# Function to list available templates
list_templates() {
    local templates_dir="$1"
    
    if [ ! -d "$templates_dir" ]; then
        print_error "Templates directory not found: $templates_dir"
        return 1
    fi
    
    echo -e "${BLUE}Available Templates:${NC}"
    find "$templates_dir" -name "*.template" -type f | while read -r template; do
        local relative_path="${template#$templates_dir/}"
        echo "  • $relative_path"
    done
}
