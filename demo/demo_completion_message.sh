#!/usr/bin/env bash

# Enhanced Demo Script for GDST - GitHub Development Setup Tool
# This script demonstrates what users will see at the end of gdst.sh execution
# Run this to preview the completion message and understand the workflow

SCRIPT_DIR="${SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"
source "${PARENT_DIR}/constants.sh"

# Demo configuration - customize these values for your demo
REPO_NAME="${1:-my-awesome-project}"
GITHUB_USERNAME="${2:-myusername}"
PROJECT_TYPE="${3:-node}"

# Function to show typing animation
show_typing() {
    local text="$1"
    local delay="${2:-0.03}"
    
    for ((i=0; i<${#text}; i++)); do
        echo -n "${text:$i:1}"
        sleep "$delay"
    done
    echo
}

# Function to pause for user interaction
pause_for_demo() {
    echo -e "\n${CYAN}Press Enter to continue...${NC}"
    read -r
}

# Function to show a command example with syntax highlighting
show_command() {
    local command="$1"
    local description="$2"
    
    echo -e "${MAGENTA}💻 ${description}${NC}"
    echo -e "${CYAN}\$ ${command}${NC}"
    echo
}

# Demo introduction
clear
echo -e "${BOLD}${BLUE}╔══════════════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${BLUE}║                    GDST - GitHub Development Setup Tool                              ║${NC}"
echo -e "${BOLD}${BLUE}║                              DEMO COMPLETION MESSAGE                                 ║${NC}"
echo -e "${BOLD}${BLUE}╚══════════════════════════════════════════════════════════════════════════════════════╝${NC}"
echo
echo -e "${YELLOW}🎯 This demo shows what you'll see after successfully running:${NC}"
show_command "./gdst.sh -n $REPO_NAME -u $GITHUB_USERNAME -t $PROJECT_TYPE" "Example GDST command"

pause_for_demo

# Simulate the actual completion message
echo -e "${BLUE}=== 🎉 Setup Complete! 🎉 ===${NC}"
echo -e "${GREEN}[INFO]${NC} Your development workflow is now ready!"
echo
echo -e "${GREEN}📋 What was created:${NC}"
echo "  ✅ Local project directory: $REPO_NAME/"
echo "  ✅ GitHub repository: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
echo "  ✅ Branch structure: main → dev/main → qa/staging"
echo "  ✅ CI/CD pipeline with GitHub Actions"
echo "  ✅ Branch protection rules and rulesets"
echo "  ✅ Development tools and configurations"
echo "  ✅ Helper scripts for workflow automation"
echo
echo -e "${GREEN}🚀 Next steps:${NC}"
echo "1. 📁 Review the generated files and customize as needed"
echo "2. ⚙️  Update .env with your actual configuration"
echo "3. 🌟 Start developing with: ./scripts/new-feature.sh <feature-name>"
echo "4. 🧪 Deploy to QA with: ./scripts/deploy-qa.sh"
echo "5. 🚀 Deploy to production with: ./scripts/deploy-prod.sh"
echo
echo -e "${BLUE}📚 Resources:${NC}"
echo "  🌐 Repository: https://github.com/$GITHUB_USERNAME/$REPO_NAME"
echo "  📖 Documentation: Check docs/ folder for detailed guides"
echo "  🎯 Branch naming: docs/BRANCH_NAMING.md"
echo "  🛠️  Development guide: docs/DEVELOPMENT.md"
echo "  🚀 Deployment guide: docs/DEPLOYMENT.md"
echo

pause_for_demo

# Show project structure
echo -e "${MAGENTA}📁 Project Structure Created:${NC}"
echo "
$REPO_NAME/
├── 📄 README.md
├── 📄 .gitignore
├── 📄 .env.example
├── 📁 src/
├── 📁 tests/
├── 📁 docs/
│   ├── 📄 BRANCH_NAMING.md
│   ├── 📄 DEVELOPMENT.md
│   └── 📄 DEPLOYMENT.md
├── 📁 scripts/
│   ├── 🛠️  new-feature.sh
│   ├── 🚀 deploy-qa.sh
│   ├── 🚀 deploy-prod.sh
│   └── ⚙️  setup-github-rulesets.sh
└── 📁 .github/
    └── 📁 workflows/
        └── 📄 ci-cd.yml
"

pause_for_demo

# Show common workflow commands
echo -e "${CYAN}⚡ Common Development Commands:${NC}"
echo
show_command "cd $REPO_NAME" "Enter your project directory"
show_command "./scripts/new-feature.sh feature user-login" "Create a new feature branch"
show_command "git add . && git commit -m 'feat: add user login functionality'" "Commit your changes"
show_command "git push origin feature/user-login" "Push to GitHub"
show_command "./scripts/deploy-qa.sh" "Deploy to QA environment"

pause_for_demo

# Show branch protection info
echo -e "${YELLOW}🛡️  Branch Protection & Rulesets:${NC}"
echo "  ✅ Enhanced branch protection with GitHub rulesets"
echo "  ✅ Conventional commits enforcement"
echo "  ✅ Automated branch naming validation"
echo "  ✅ Tag protection with semantic versioning"
echo "  ✅ PR requirements and code review rules"
echo
echo -e "${BLUE}🔗 Manage rulesets:${NC}"
show_command "./scripts/setup-github-rulesets.sh list" "View current rulesets"
show_command "./scripts/setup-github-rulesets.sh setup $GITHUB_USERNAME $REPO_NAME" "Re-apply rulesets"

pause_for_demo

# Emergency cleanup section
echo -e "${RED}⚠️  Emergency Repository Management:${NC}"
echo -e "${RED}If the repository was created incorrectly, you can delete it:${NC}"
echo
show_command "gh repo delete $GITHUB_USERNAME/$REPO_NAME --yes" "⚠️  Delete GitHub repository"
echo -e "${RED}Warning: This will permanently delete the repository and all its contents!${NC}"
echo
echo -e "${YELLOW}💡 To also remove the local directory:${NC}"
show_command "rm -rf $REPO_NAME" "Remove local project directory"

pause_for_demo

# Demo conclusion
echo -e "${BOLD}${GREEN}╔══════════════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║                              🎉 DEMO COMPLETE! 🎉                                   ║${NC}"
echo -e "${BOLD}${GREEN}║                                                                                      ║${NC}"
echo -e "${BOLD}${GREEN}║  Ready to try GDST for real? Run: ./gdst.sh -n your-project -u your-username       ║${NC}"
echo -e "${BOLD}${GREEN}║  Need help? Run: ./gdst.sh --help                                                   ║${NC}"
echo -e "${BOLD}${GREEN}╚══════════════════════════════════════════════════════════════════════════════════════╝${NC}"
echo
echo -e "${CYAN}Thank you for trying GDST! 🚀${NC}"
