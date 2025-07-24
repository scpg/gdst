#!/bin/bash
# Local CI test script - mimics GitHub Actions workflow

set -e

echo "=== GDST Local CI Test ==="

# Setup
echo "1. Setting up test environment..."
chmod +x gdst.sh lib/*.sh test/*.sh

# Quick checks
echo "2. Running quick checks..."
echo "  - Syntax checking main script..."
bash -n gdst.sh

echo "  - Syntax checking library scripts..."
find lib -name "*.sh" -exec bash -n {} \;

echo "  - Running shellcheck (error level only)..."
if command -v shellcheck >/dev/null 2>&1; then
    shellcheck -S error gdst.sh
    find lib -name "*.sh" -exec shellcheck -S error {} \;
    echo "  ✅ Shellcheck passed"
else
    echo "  ⚠️ Shellcheck not available, skipping"
fi

echo "  - Testing basic functionality..."
./gdst.sh --help >/dev/null
./gdst.sh --version >/dev/null
echo "  ✅ Basic functionality working"

# Core tests
echo "3. Running core tests..."

# Test bats if available
if command -v bats >/dev/null 2>&1; then
    echo "  - Running bats tests..."
    cd test
    bats test_example.bats
    cd ..
    echo "  ✅ Bats tests passed"
else
    echo "  ⚠️ Bats not available, skipping bats tests"
fi

# Test dry-run
echo "  - Testing dry-run functionality..."
TEST_DIR="/tmp/gdst_ci_test"
mkdir -p "$TEST_DIR"
./gdst.sh --name "ci-test" --username "testuser" --type "python" --directory "$TEST_DIR" --dry-run >/dev/null
rm -rf "$TEST_DIR"
echo "  ✅ Dry-run test passed"

echo ""
echo "🎉 All local CI tests passed!"
echo "Ready for GitHub Actions workflow!"
