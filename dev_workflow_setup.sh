#!/bin/bash

# GDST - GitHub Development Setup Tool
# This script sets up a complete development environment with branching strategy and GitHub configuration
# Designed for command-line automation with comprehensive logging and validation

set -e

# Get the directory where this script is located
SCRIPT_DIR="${SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
source "${SCRIPT_DIR}/const_and_fctn.sh"

# Source template utilities
source "$SCRIPT_DIR/template_utils.sh"


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

# Function to print colored output
print_status() {
    if [[ "$LOG_LEVEL" =~ ^(INFO|DEBUG)$ ]]; then
        echo -e "${GREEN}[INFO]${NC} $1"
    fi
}

print_warning() {
    if [[ "$LOG_LEVEL" =~ ^(WARN|INFO|DEBUG)$ ]]; then
        echo -e "${YELLOW}[WARNING]${NC} $1"
    fi
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_debug() {
    if [[ "$LOG_LEVEL" == "DEBUG" ]]; then
        echo -e "${BLUE}[DEBUG]${NC} $1"
    fi
}

print_header() {
    echo -e "${BLUE}=== $1 ===${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to show help
show_help() {
    cat << EOF
GDST - GitHub Development Setup Tool

USAGE:
    $0 [OPTIONS]

DESCRIPTION:
    Sets up a complete development environment with branching strategy, GitHub configuration,
    and automated branch naming validation following industry best practices.

OPTIONS:
    -n, --name REPO_NAME        Repository name (required)
    -u, --username USERNAME     GitHub username (required)
    -t, --type TYPE             Project type: node, python, java, react, other (default: node)
    -V, --visibility VISIBILITY Repository visibility: public, private (default: public)
    -d, --directory DIR         Working directory to create project in (default: current directory)
    -v, --verbose               Enable verbose output (sets log level to DEBUG)
    -l, --level LEVEL           Set log level: INFO, WARN, ERROR, DEBUG (default: INFO)
    
    --skip-install              Skip npm/pip package installation
    --skip-protection           Skip GitHub branch protection setup
    --dry-run                   Show what would be done without executing
    
    -h, --help                  Show this help message
    --version                   Show version information

EXAMPLES:
    # Basic usage with required parameters
    $0 --name my-project --username myuser
    
    # Create a private Python project
    $0 -n my-python-app -u myuser -t python -V private
    
    # Create project in a specific directory
    $0 -n my-project -u myuser -d /path/to/projects
    
    # Dry run to see what would be created
    $0 -n test-project -u testuser --dry-run
    
    # Skip package installation for faster setup
    $0 -n my-project -u myuser --skip-install
    
    # Run with verbose output and custom log level
    $0 -n my-project -u myuser --verbose

SUPPORTED PROJECT TYPES:
    node        Node.js project with package.json, Jest, ESLint, Prettier
    react       React project (same as node but with React-specific setup)
    python      Python project with requirements.txt, pytest, black, flake8
    java        Java project with Maven pom.xml
    other       Generic project with basic structure

PREREQUISITES:
    • Git installed and configured
    • GitHub CLI (gh) installed and authenticated
    • Internet connection for GitHub operations
    • Node.js (for node/react projects)
    • Python 3 (for python projects)
    • Java/Maven (for java projects)

NOTES:
    • Repository name and GitHub username are required parameters
    • GitHub CLI must be authenticated with 'gh auth login' before running
    • The script will create a new directory with the repository name
    • Branch protection requires admin access to the repository
    • Use --dry-run to preview changes without making them

EOF
}

# Function to show version
show_version() {
    echo "GDST - GitHub Development Setup Tool v1.0.0"
    echo "Copyright (c) 2025"
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
    
    # Validate working directory
    if [ ! -d "$WORKING_DIR" ]; then
        print_error "Working directory does not exist: $WORKING_DIR"
        exit 1
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

# Function to execute or simulate commands based on dry-run mode
execute_command() {
    local description="$1"
    shift
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY RUN]${NC} $description"
        echo -e "${YELLOW}[DRY RUN]${NC} Would execute: $*"
        return 0
    else
        print_status "$description"
        "$@"
    fi
}

# Function to create file or simulate in dry-run mode
create_file_safe() {
    local file_path="$1"
    local description="$2"
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY RUN]${NC} Would create file: $file_path"
        echo -e "${YELLOW}[DRY RUN]${NC} $description"
        return 0
    fi
    
    return 1  # Let the calling function handle actual file creation
}

# Function to check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    print_debug "Starting prerequisite checks..."
    
    if [ "$DRY_RUN" = true ]; then
        print_status "Dry run mode - skipping prerequisite installation"
        return 0
    fi
    
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
    
    # Check required tools
    local missing_tools=()
    
    if ! command_exists git; then
        missing_tools+=("git")
    fi
    
    if ! command_exists curl; then
        missing_tools+=("curl")
    fi
    
    if ! command_exists gh; then
        print_warning "GitHub CLI not found. Installing..."
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update
        sudo apt install gh -y
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        print_status "Installing missing tools..."
        sudo apt update
        sudo apt install -y "${missing_tools[@]}"
    fi
    
    print_status "All prerequisites satisfied ✓"
}

# Function to setup local development environment
setup_local_environment() {
    print_header "Setting up Local Development Environment"
    
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
        cd "$REPO_NAME"
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
    
    # Configure git user if not set
    if [ -z "$(git config user.name)" ]; then
        git config user.name "Developer"
        git config user.email "developer@example.com"
        print_status "Configured Git user (you can change this later)"
    fi
    
    # Create initial branch structure
    # Set default branch name and create initial commit
    git config init.defaultBranch main
    
    # Create initial commit on master/main
    touch .gitkeep
    git add .gitkeep
    git commit -m "Initial commit"
    
    # Rename to main if needed and create other branches
    git branch -M main 2>/dev/null || true
    git checkout -b dev/main
    git checkout -b qa/staging
    git checkout dev/main
    
    print_status "Created initial branch structure"
    
    # Create project structure based on type
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
    
    # Create basic project structure
    mkdir -p src tests docs
    
    # Create package.json from template
    if [ ! -f "package.json" ]; then
        copy_template "$TEMPLATES_DIR/project-configs/package.json.template" "package.json" "$REPO_NAME" "$GITHUB_USERNAME"
    fi
    
    # Create sample files from templates
    [ ! -f "src/index.js" ] && copy_template "$TEMPLATES_DIR/project-configs/src-index.js.template" "src/index.js" "$REPO_NAME" "$GITHUB_USERNAME"
    [ ! -f "tests/index.test.js" ] && copy_template "$TEMPLATES_DIR/project-configs/test-index.test.js.template" "tests/index.test.js" "$REPO_NAME" "$GITHUB_USERNAME"
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
    
    # Create basic project structure
    mkdir -p src tests docs
    
    # Create requirements files from templates
    [ ! -f "requirements.txt" ] && touch requirements.txt
    [ ! -f "requirements-dev.txt" ] && copy_template "$TEMPLATES_DIR/project-configs/requirements-dev.txt.template" "requirements-dev.txt" "$REPO_NAME" "$GITHUB_USERNAME"
    
    # Create sample files from templates
    [ ! -f "src/main.py" ] && copy_template "$TEMPLATES_DIR/project-configs/src-main.py.template" "src/main.py" "$REPO_NAME" "$GITHUB_USERNAME"
    [ ! -f "tests/test_main.py" ] && copy_template "$TEMPLATES_DIR/project-configs/test-main.py.template" "tests/test_main.py" "$REPO_NAME" "$GITHUB_USERNAME"
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
    
    # Create basic project structure
    mkdir -p src/main/java src/test/java
    
    # Create pom.xml from template
    [ ! -f "pom.xml" ] && copy_template "$TEMPLATES_DIR/project-configs/pom.xml.template" "pom.xml" "$REPO_NAME" "$GITHUB_USERNAME"
}

# Function to setup generic project
setup_generic_project() {
    print_status "Setting up generic project structure"
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY RUN]${NC} Would create generic project structure"
        echo -e "${YELLOW}[DRY RUN]${NC} Would create src/, docs/, tests/ directories"
        return 0
    fi
    
    mkdir -p src docs tests
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
    
    # Create GitHub workflows from templates
    copy_template "$TEMPLATES_DIR/workflows/ci-cd.yml.template" ".github/workflows/ci-cd.yml" "$REPO_NAME" "$GITHUB_USERNAME"
    copy_template "$TEMPLATES_DIR/workflows/pull_request_template.md.template" ".github/pull_request_template/default.md" "$REPO_NAME" "$GITHUB_USERNAME"
    
    print_status "GitHub workflows created ✓"
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
    
    # Create .gitignore using templates
    local gitignore_template=$(get_gitignore_template "$PROJECT_TYPE")
    [ ! -f ".gitignore" ] && copy_template "$gitignore_template" ".gitignore" "$REPO_NAME" "$GITHUB_USERNAME"
    
    # Create .env.example using template
    [ ! -f ".env.example" ] && copy_template "$TEMPLATES_DIR/project-configs/.env.example.template" ".env.example" "$REPO_NAME" "$GITHUB_USERNAME"
    
    # Create README.md using template
    [ ! -f "README.md" ] && copy_template "$TEMPLATES_DIR/docs/README.md.template" "README.md" "$REPO_NAME" "$GITHUB_USERNAME"
    
    print_status "Configuration files created ✓"
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
    
    # Initial commit and push
    git add .
    git commit -m "Initial commit: Setup development workflow" --allow-empty
    git push -u origin dev/main
    
    # Push other branches
    git checkout qa/staging
    git merge dev/main
    git push -u origin qa/staging
    git checkout main
    git merge dev/main
    git push -u origin main
    git checkout dev/main
    
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
    
    mkdir -p scripts
    
    # Create scripts from templates
    copy_template "$TEMPLATES_DIR/scripts/new-feature.sh.template" "scripts/new-feature.sh" "$REPO_NAME" "$GITHUB_USERNAME"
    copy_template "$TEMPLATES_DIR/scripts/deploy-qa.sh.template" "scripts/deploy-qa.sh" "$REPO_NAME" "$GITHUB_USERNAME"
    copy_template "$TEMPLATES_DIR/scripts/deploy-prod.sh.template" "scripts/deploy-prod.sh" "$REPO_NAME" "$GITHUB_USERNAME"
    copy_template "$TEMPLATES_DIR/scripts/setup-github-rulesets.sh.template" "scripts/setup-github-rulesets.sh" "$REPO_NAME" "$GITHUB_USERNAME"
    
    # Make scripts executable
    chmod +x scripts/*.sh
    
    print_status "Helper scripts created ✓"
}

# Function to setup development tools
setup_development_tools() {
    print_header "Setting up Development Tools"
    
    if [ "$DRY_RUN" = true ]; then
        print_status "Dry run mode - would install development tools for $PROJECT_TYPE project"
        return 0
    fi
    
    case $PROJECT_TYPE in
        node|react)
            # Install development dependencies
            if command_exists npm && [ -f "package.json" ]; then
                print_status "Installing Node.js development dependencies..."
                npm install 2>/dev/null || print_warning "Failed to install npm dependencies"
                
                # Setup Husky for git hooks
                if [ -d "node_modules" ]; then
                    npx husky install 2>/dev/null || print_warning "Failed to install husky"
                    npx husky add .husky/pre-commit "npx lint-staged" 2>/dev/null || print_warning "Failed to add pre-commit hook"
                    
                    # Create lint-staged configuration by modifying package.json
                    # Remove the closing brace temporarily
                    sed -i '$d' package.json
                    # Add lint-staged config and close the JSON
                    cat >> package.json << 'EOF'
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
                fi
            fi
            ;;
        python)
            # Setup Python virtual environment
            if command_exists python3; then
                print_status "Setting up Python virtual environment..."
                python3 -m venv venv 2>/dev/null || print_warning "Failed to create virtual environment"
                if [ -f "venv/bin/activate" ]; then
                    source venv/bin/activate
                    pip install -r requirements-dev.txt 2>/dev/null || print_warning "Failed to install Python dependencies"
                    
                    # Setup pre-commit hooks using template
                    copy_template "$TEMPLATES_DIR/project-configs/.pre-commit-config.yaml.template" ".pre-commit-config.yaml" "$REPO_NAME" "$GITHUB_USERNAME"
                    pre-commit install 2>/dev/null || print_warning "Failed to install pre-commit hooks"
                fi
            fi
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
    
    mkdir -p docs
    
    # Create documentation from templates
    copy_template "$TEMPLATES_DIR/docs/DEVELOPMENT.md.template" "docs/DEVELOPMENT.md" "$REPO_NAME" "$GITHUB_USERNAME"
    copy_template "$TEMPLATES_DIR/docs/DEPLOYMENT.md.template" "docs/DEPLOYMENT.md" "$REPO_NAME" "$GITHUB_USERNAME"
    
    print_status "Documentation created ✓"
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
    mkdir -p scripts
    
    # Copy branch validation script
    copy_template "$TEMPLATES_DIR/scripts/validate-branch-name.sh.template" "scripts/validate-branch-name.sh" "$REPO_NAME" "$GITHUB_USERNAME"
    chmod +x scripts/validate-branch-name.sh
    
    # Setup Git hooks
    print_status "Installing Git hooks for branch validation..."
    
    # Create hooks directory
    mkdir -p .git/hooks
    
    # Copy pre-commit hook for branch validation
    copy_template "$TEMPLATES_DIR/project-configs/pre-commit-branch-check.template" ".git/hooks/pre-commit-branch-check" "$REPO_NAME" "$GITHUB_USERNAME"
    chmod +x .git/hooks/pre-commit-branch-check
    
    # Copy pre-push hook for branch validation
    copy_template "$TEMPLATES_DIR/project-configs/pre-push.template" ".git/hooks/pre-push" "$REPO_NAME" "$GITHUB_USERNAME"
    chmod +x .git/hooks/pre-push
    
    # Create or update existing pre-commit hook to include branch validation
    if [ -f ".git/hooks/pre-commit" ]; then
        # Append to existing pre-commit hook
        if ! grep -q "pre-commit-branch-check" .git/hooks/pre-commit; then
            echo "" >> .git/hooks/pre-commit
            echo "# Branch name validation" >> .git/hooks/pre-commit
            echo "bash \"\$(git rev-parse --show-toplevel)/.git/hooks/pre-commit-branch-check\"" >> .git/hooks/pre-commit
        fi
    else
        # Create new pre-commit hook
        cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash

# Branch name validation
bash "$(git rev-parse --show-toplevel)/.git/hooks/pre-commit-branch-check"
EOF
        chmod +x .git/hooks/pre-commit
    fi
    
    # Create branch naming documentation
    copy_template "$TEMPLATES_DIR/docs/BRANCH_NAMING.md.template" "docs/BRANCH_NAMING.md" "$REPO_NAME" "$GITHUB_USERNAME"
    
    print_status "Branch validation setup ✓"
    print_status "Git hooks installed for automatic branch name validation"
    print_status "Branch naming documentation created at docs/BRANCH_NAMING.md"
}

# Main execution function
main() {
    # Parse command line arguments first
    parse_arguments "$@"
    
    # Validate arguments
    validate_arguments
    
    # Change to working directory
    cd "$WORKING_DIR"
    
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
    
    # Execute setup steps
    check_prerequisites
    setup_local_environment
    create_github_workflows
    create_config_files
    
    if [ "$DRY_RUN" = false ]; then
        setup_github_repository
        
        if [ "$SKIP_PROTECTION" = false ]; then
            configure_branch_protection
        else
            print_warning "Skipping branch protection setup"
        fi
    fi
    
    create_helper_scripts
    
    if [ "$SKIP_INSTALL" = false ]; then
        setup_development_tools
    else
        print_warning "Skipping package installation"
    fi
    
    create_documentation
    setup_branch_validation
    
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
}

# Run main function with all arguments
main "$@"