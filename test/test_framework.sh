#!/bin/bash

# GDST Test Framework
# Provides utilities for testing the GDST tool with proper assertions and reporting
# Based on the comprehensive dry-run testing performed

# Don't use set -e in the test framework to allow better error handling
# set -e

# Test framework configuration
TEST_FRAMEWORK_VERSION="1.0.0"
TEST_RESULTS_DIR="${TEST_RESULTS_DIR:-/tmp/gdst-test-results}"
TEST_TEMP_DIR="${TEST_TEMP_DIR:-/tmp/gdst-test-temp}"
GDST_SCRIPT_DIR="${GDST_SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# Source color definitions from constants.sh
source "$GDST_SCRIPT_DIR/constants.sh"

# Test counters
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Current test context
CURRENT_TEST_SUITE=""
CURRENT_TEST_NAME=""
TEST_START_TIME=""

# Initialize test framework
init_test_framework() {
    echo -e "${BLUE}=== GDST Test Framework v${TEST_FRAMEWORK_VERSION} ===${NC}"
    echo "Test Results Directory: $TEST_RESULTS_DIR"
    echo "Temporary Directory: $TEST_TEMP_DIR"
    echo "GDST Script Directory: $GDST_SCRIPT_DIR"
    echo ""
    
    # Create directories
    mkdir -p "$TEST_RESULTS_DIR"
    mkdir -p "$TEST_TEMP_DIR"
    
    # Initialize log file
    echo "GDST Test Run - $(date)" > "$TEST_RESULTS_DIR/test_run.log"
    
    # Setup cleanup trap - only if not already set
    if [[ -z "$TEST_TRAP_SET" ]]; then
        trap cleanup_test_framework EXIT
        TEST_TRAP_SET=true
    fi
}

# Cleanup function
cleanup_test_framework() {
    if [[ -d "$TEST_TEMP_DIR" ]]; then
        rm -rf "$TEST_TEMP_DIR"
    fi
    
    # Calculate incomplete tests
    local incomplete_tests=$((TESTS_TOTAL - TESTS_PASSED - TESTS_FAILED - TESTS_SKIPPED))
    
    # Print final summary
    echo ""
    echo -e "${BLUE}=== Test Summary ===${NC}"
    echo "Total Tests: $TESTS_TOTAL"
    echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
    echo -e "Skipped: ${YELLOW}$TESTS_SKIPPED${NC}"
    
    if [[ $incomplete_tests -gt 0 ]]; then
        echo -e "Incomplete: ${YELLOW}$incomplete_tests${NC}"
        TESTS_FAILED=$((TESTS_FAILED + incomplete_tests))
    fi
    
    if [[ $TESTS_FAILED -gt 0 ]]; then
        echo -e "${RED}Some tests failed!${NC}"
        # Don't exit here - let the script continue
    else
        echo -e "${GREEN}All tests passed!${NC}"
        # Don't exit here - let the script continue
    fi
}

# Start a test suite
start_test_suite() {
    local suite_name="$1"
    CURRENT_TEST_SUITE="$suite_name"
    echo -e "${BLUE}=== Starting Test Suite: $suite_name ===${NC}"
    echo "Starting test suite: $suite_name" >> "$TEST_RESULTS_DIR/test_run.log"
}

# Start a test case
start_test() {
    local test_name="$1"
    CURRENT_TEST_NAME="$test_name"
    TEST_START_TIME=$(date +%s)
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    
    echo -e "${YELLOW}Running: $test_name${NC}"
    echo "  Starting test: $test_name" >> "$TEST_RESULTS_DIR/test_run.log"
}

# Pass a test
pass_test() {
    local message="${1:-Test passed}"
    local end_time=$(date +%s)
    local duration=$((end_time - TEST_START_TIME))
    
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${GREEN}  ✓ PASS${NC} - $message (${duration}s)"
    echo "  PASS - $CURRENT_TEST_NAME: $message (${duration}s)" >> "$TEST_RESULTS_DIR/test_run.log"
}

# Fail a test
fail_test() {
    local message="${1:-Test failed}"
    local end_time=$(date +%s)
    local duration=$((end_time - TEST_START_TIME))
    
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}  ✗ FAIL${NC} - $message (${duration}s)"
    echo "  FAIL - $CURRENT_TEST_NAME: $message (${duration}s)" >> "$TEST_RESULTS_DIR/test_run.log"
}

# Skip a test
skip_test() {
    local message="${1:-Test skipped}"
    
    TESTS_SKIPPED=$((TESTS_SKIPPED + 1))
    echo -e "${YELLOW}  ⚠ SKIP${NC} - $message"
    echo "  SKIP - $CURRENT_TEST_NAME: $message" >> "$TEST_RESULTS_DIR/test_run.log"
}

# Assert functions
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Values should be equal}"
    
    if [[ "$expected" == "$actual" ]]; then
        return 0
    else
        echo "  Expected: '$expected'"
        echo "  Actual: '$actual'"
        echo "  FAIL: $message"
        return 1
    fi
}

assert_contains() {
    local text="$1"
    local pattern="$2"
    local message="${3:-Text should contain pattern}"
    
    if [[ "$text" == *"$pattern"* ]]; then
        return 0
    else
        echo "  Text: '$text'"
        echo "  Pattern: '$pattern'"
        echo "  FAIL: $message"
        return 1
    fi
}

assert_not_contains() {
    local text="$1"
    local pattern="$2"
    local message="${3:-Text should not contain pattern}"
    
    if [[ "$text" != *"$pattern"* ]]; then
        return 0
    else
        echo "  Text: '$text'"
        echo "  Pattern: '$pattern'"
        fail_test "$message"
        return 1
    fi
}

assert_file_exists() {
    local file_path="$1"
    local message="${2:-File should exist}"
    
    if [[ -f "$file_path" ]]; then
        return 0
    else
        fail_test "$message: $file_path"
        return 1
    fi
}

assert_file_not_exists() {
    local file_path="$1"
    local message="${2:-File should not exist}"
    
    if [[ ! -f "$file_path" ]]; then
        return 0
    else
        fail_test "$message: $file_path"
        return 1
    fi
}

assert_exit_code() {
    local expected_code="$1"
    local actual_code="$2"
    local message="${3:-Exit code should match}"
    
    if [[ "$expected_code" -eq "$actual_code" ]]; then
        return 0
    else
        echo "  Expected exit code: $expected_code"
        echo "  Actual exit code: $actual_code"
        echo "  FAIL: $message"
        return 1
    fi
}

# Run GDST command with dry-run and capture output
run_gdst_dry_run() {
    local args="$*"
    
    # Ensure test temp directory exists
    mkdir -p "$TEST_TEMP_DIR"
    
    local temp_output="$TEST_TEMP_DIR/gdst_output_$$"
    
    # Run GDST with dry-run and capture both stdout and stderr
    # Temporarily disable set -e to allow non-zero exit codes
    local old_errexit
    if [[ $- =~ e ]]; then
        old_errexit=true
        set +e
    else
        old_errexit=false
    fi
    
    # Handle empty args properly
    if [[ -z "$args" ]]; then
        "$GDST_SCRIPT_DIR/gdst.sh" --dry-run > "$temp_output" 2>&1
    else
        "$GDST_SCRIPT_DIR/gdst.sh" $args --dry-run > "$temp_output" 2>&1
    fi
    local exit_code=$?
    
    # Restore previous errexit setting
    if [[ "$old_errexit" == "true" ]]; then
        set -e
    fi
    
    # Store output for assertions
    if [[ -f "$temp_output" ]]; then
        GDST_OUTPUT=$(cat "$temp_output")
    else
        GDST_OUTPUT=""
    fi
    GDST_EXIT_CODE=$exit_code
    
    return $exit_code
}

# Run GDST command and capture output (without dry-run)
run_gdst() {
    local args="$*"
    local temp_output="$TEST_TEMP_DIR/gdst_output_$$"
    
    # Run GDST and capture both stdout and stderr
    set +e
    "$GDST_SCRIPT_DIR/gdst.sh" $args > "$temp_output" 2>&1
    local exit_code=$?
    set -e
    
    # Store output for assertions
    GDST_OUTPUT=$(cat "$temp_output")
    GDST_EXIT_CODE=$exit_code
    
    return $exit_code
}

# Create a temporary test directory
create_test_dir() {
    local dir_name="${1:-test-project}"
    local test_dir="$TEST_TEMP_DIR/$dir_name"
    
    mkdir -p "$test_dir"
    echo "$test_dir"
}

# Mock GitHub CLI for testing
setup_github_mock() {
    local mock_dir="$TEST_TEMP_DIR/mock"
    mkdir -p "$mock_dir"
    
    # Create mock gh command
    cat > "$mock_dir/gh" << 'EOF'
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
        # Mock API responses
        case "$3" in
            "rate_limit")
                echo '{"rate":{"limit":5000,"remaining":4995,"reset":1640995200}}'
                ;;
            *)
                echo '{"message": "Mock API response"}'
                ;;
        esac
        exit 0
        ;;
    *)
        echo "Mock gh command: $*"
        exit 0
        ;;
esac
EOF
    chmod +x "$mock_dir/gh"
    
    # Add to PATH
    export PATH="$mock_dir:$PATH"
}

# Remove GitHub mock
remove_github_mock() {
    # Remove mock directory from PATH
    local mock_dir="$TEST_TEMP_DIR/mock"
    if [[ -d "$mock_dir" ]]; then
        export PATH="${PATH//$mock_dir:/}"
        rm -rf "$mock_dir"
    fi
}

# Utility function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Log function for debugging
log_debug() {
    echo "[DEBUG] $*" >> "$TEST_RESULTS_DIR/test_run.log"
}

# Export functions for use in test files
export -f init_test_framework cleanup_test_framework
export -f start_test_suite start_test pass_test fail_test skip_test
export -f assert_equals assert_contains assert_not_contains
export -f assert_file_exists assert_file_not_exists assert_exit_code
export -f run_gdst_dry_run run_gdst create_test_dir
export -f setup_github_mock remove_github_mock command_exists log_debug
