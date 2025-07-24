#!/bin/bash
# Simplified CI verification script
# Tests all critical functionality quickly

set -e

echo "=== GDST CI Verification ==="
echo "Timestamp: $(date)"

# Basic environment check
echo "1. Environment Check..."
command -v bash >/dev/null || { echo "❌ bash not found"; exit 1; }
command -v git >/dev/null || { echo "❌ git not found"; exit 1; }
[[ -x gdst.sh ]] || { echo "❌ gdst.sh not executable"; exit 1; }
echo "  ✅ Environment OK"

# Quick syntax check
echo "2. Syntax Check..."
bash -n gdst.sh || { echo "❌ gdst.sh syntax error"; exit 1; }
find lib -name "*.sh" -exec bash -n {} \; || { echo "❌ Library syntax error"; exit 1; }
echo "  ✅ Syntax OK"

# Shellcheck (error level only)
echo "3. Shellcheck..."
if command -v shellcheck >/dev/null 2>&1; then
    shellcheck -S error gdst.sh || { echo "❌ Shellcheck errors"; exit 1; }
    find lib -name "*.sh" -exec shellcheck -S error {} \; || { echo "❌ Library shellcheck errors"; exit 1; }
    echo "  ✅ Shellcheck passed"
else
    echo "  ⚠️ Shellcheck not available"
fi

# Basic functionality tests
echo "4. Basic Functionality..."

# Test help
if ! ./gdst.sh --help >/dev/null 2>&1; then
    echo "❌ Help command failed"
    exit 1
fi

# Test version
if ! ./gdst.sh --version >/dev/null 2>&1; then
    echo "❌ Version command failed"  
    exit 1
fi

# Test error handling
if ./gdst.sh >/dev/null 2>&1; then
    echo "❌ Error handling failed (should fail without args)"
    exit 1
fi

echo "  ✅ Basic functionality OK"

# Bats tests if available
echo "5. Bats Tests..."
if command -v bats >/dev/null 2>&1; then
    cd test
    if bats test_example.bats >/dev/null 2>&1; then
        echo "  ✅ Bats tests passed"
    else
        echo "  ❌ Bats tests failed"
        exit 1
    fi
    cd ..
else
    echo "  ⚠️ Bats not available"
fi

# Dry-run test
echo "6. Dry-run Test..."
TEST_DIR="/tmp/gdst_verify_$$"
mkdir -p "$TEST_DIR"
if timeout 30 ./gdst.sh -n "ci-test" -u "testuser" -t "node" -d "$TEST_DIR" --dry-run >/dev/null 2>&1; then
    echo "  ✅ Dry-run test passed"
else
    echo "  ❌ Dry-run test failed"
    rm -rf "$TEST_DIR"
    exit 1
fi
rm -rf "$TEST_DIR"

echo ""
echo "🎉 All CI verification tests passed!"
echo "Ready for production deployment!"
