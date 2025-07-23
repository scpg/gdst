#!/bin/bash

# GDST - Quick test script for gdst.sh
# This tests the script in dry-run mode without GitHub integration
set -e

SCRIPT_DIR="${SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
# If SCRIPT_DIR ends with /test, use parent directory
if [[ "$SCRIPT_DIR" == */test ]]; then
    SCRIPT_DIR="$(dirname "$SCRIPT_DIR")"
fi


source "${SCRIPT_DIR}/lib/constants.sh"
source "${SCRIPT_DIR}/lib/logging_lib.sh"


# Enable terminal logging for testing
enable_terminal_logging
set_log_level info

# Trap for cleanup on script exit
cleanup() {
    if [[ -d "$TEST_DIR" ]]; then
        log_info "Cleaning up test directory..."
        rm -rf "$TEST_DIR"
    fi
}
trap cleanup EXIT

log_info "Starting GDST gdst.sh test suite"

# Create test directory
TEST_DIR_Template="/tmp/%s.%s.dev_workflow_test"
TEST_DIR=$(printf "$TEST_DIR_Template" "$SCRIPT_FIX_NAME" "$(date +%Y-%m-%d_%H-%M-%S)")
log_info "Creating test directory: $TEST_DIR"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

# Mock GitHub CLI to avoid actual repo creation
log_info "Setting up GitHub CLI mock"
export PATH="$TEST_DIR:$PATH"
cat > gh << 'EOF'
#!/bin/bash
case "$1" in
    "auth")
        echo "Logged in to github.com as testuser"
        exit 0
        ;;
    "repo")
        echo "Repository created successfully (mock)"
        exit 0
        ;;
    "api")
        echo "API call successful (mock)"
        exit 0
        ;;
    *)
        echo "Mock gh command: $*"
        exit 0
        ;;
esac
EOF
chmod +x gh

# Test the script with sample input
log_info "Testing with Node.js project..."
echo -e "test-project\ntestuser\nnode\npublic\ny" | timeout 60 bash "$SCRIPT_DIR/gdst.sh"

# Check if key files were created
echo ""
log_info "Checking created files..."
cd test-project
for file in package.json .gitignore README.md .github/workflows/ci-cd.yml; do
    if [ -f "$file" ]; then
        log_success "✓ $file created"
    else
        log_error "✗ $file missing"
    fi
done

# Check git branches
echo ""
log_info "Checking git branches..."
git branch -a

echo ""
log_success "Test completed successfully!"

# Note: Cleanup is handled by the EXIT trap
