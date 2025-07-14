#!/bin/bash

# GDST Developer Aliases
# Source this file to get convenient aliases for development

# Source color definitions from constants.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/constants.sh"

# Alias for make commands with developer flag
alias gmake='make GDST_DEVELOPER_MODE=true'

# Common development commands
alias gdst-test='make GDST_DEVELOPER_MODE=true test'
alias gdst-test-basic='make GDST_DEVELOPER_MODE=true test-basic'
alias gdst-test-advanced='make GDST_DEVELOPER_MODE=true test-advanced'
alias gdst-test-security='make GDST_DEVELOPER_MODE=true test-security'
alias gdst-validate='make GDST_DEVELOPER_MODE=true validate'
alias gdst-lint='make GDST_DEVELOPER_MODE=true lint'
alias gdst-clean='make GDST_DEVELOPER_MODE=true clean'
alias gdst-setup='make GDST_DEVELOPER_MODE=true setup'

echo -e "${GREEN}GDST Developer aliases loaded!${NC}"
echo -e "${BLUE}Usage examples:${NC}"
echo -e "${CYAN}  gdst-test          ${NC}# Run all tests"
echo -e "${CYAN}  gdst-test-basic    ${NC}# Run basic tests"
echo -e "${CYAN}  gdst-validate      ${NC}# Quick validation"
echo -e "${CYAN}  gdst-lint          ${NC}# Run linting"
echo -e "${CYAN}  gmake <target>     ${NC}# Generic make with developer flag"
echo ""
echo -e "${YELLOW}To use these aliases, run: ${NC}source dev_aliases.sh"
