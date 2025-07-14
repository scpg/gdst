#!/bin/bash

# Template utility functions for dev_workflow_setup.sh
# This file contains helper functions for processing template files

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES_DIR="$SCRIPT_DIR/templates"

# Function to substitute variables in a template
substitute_template() {
    local template_content="$1"
    local repo_name="$2"
    local github_username="$3"
    
    # Replace template variables
    echo "$template_content" | \
        sed "s/{{REPO_NAME}}/$repo_name/g" | \
        sed "s/{{GITHUB_USERNAME}}/$github_username/g"
}

# Function to copy and process a template file
copy_template() {
    local template_file="$1"
    local destination_file="$2"
    local repo_name="$3"
    local github_username="$4"
    
    if [ ! -f "$template_file" ]; then
        print_error "Template file not found: $template_file"
        return 1
    fi
    
    local template_content=$(cat "$template_file")
    local processed_content=$(substitute_template "$template_content" "$repo_name" "$github_username")
    
    # Create destination directory if it doesn't exist
    local dest_dir=$(dirname "$destination_file")
    mkdir -p "$dest_dir"
    
    echo "$processed_content" > "$destination_file"
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
