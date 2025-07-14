#!/usr/bin/env bash

SCRIPT_DIR="${SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
source "${SCRIPT_DIR}/const_and_fctn.sh"

# Demo script to show the enhanced completion message
# This demonstrates what users will see at the end of dev_workflow_setup.sh

REPO_NAME="my-test-project"
GITHUB_USERNAME="myusername"

echo -e "${BLUE}=== Setup Complete! ===${NC}"
echo -e "${GREEN}[INFO]${NC} Your development workflow is now ready!"
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo "1. Review the generated files and customize as needed"
echo "2. Update .env with your actual configuration"
echo "3. Start developing with: ./scripts/new-feature.sh <feature-name>"
echo "4. Deploy to QA with: ./scripts/deploy-qa.sh"
echo "5. Deploy to production with: ./scripts/deploy-prod.sh"
echo ""
echo -e "${BLUE}Repository:${NC} https://github.com/$GITHUB_USERNAME/$REPO_NAME"
echo -e "${BLUE}Documentation:${NC} Check docs/ folder for detailed guides"
echo ""
echo -e "${RED}⚠️  Repository Management:${NC}"
echo -e "${RED}If the repository created is incorrect, you can delete it with the command:${NC}"
echo -e "${RED}gh repo delete $GITHUB_USERNAME/$REPO_NAME --yes${NC}"
echo -e "${RED}Warning: This will permanently delete the repository and all its contents!${NC}"
echo ""
echo -e "${YELLOW}💡 To also remove the local directory:${NC}"
echo -e "${YELLOW}rm -rf $REPO_NAME${NC}"
