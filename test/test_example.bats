#!/usr/bin/env bats

# Example bats test file demonstrating migration from custom test framework
# This shows how to convert existing tests to bats format

# Load bats helpers
load 'bats-support/load'
load 'bats-assert/load'

# Setup function runs before each test
setup() {
    echo "=== BATS TEST SETUP DEBUG ===" >&2
    echo "Current working directory: $(pwd)" >&2
    echo "BATS_TEST_FILENAME: ${BATS_TEST_FILENAME:-'not set'}" >&2
    echo "BATS_TEST_DIRNAME: ${BATS_TEST_DIRNAME:-'not set'}" >&2
    
    # Set up test environment
    export TEST_DIR="/tmp/gdst_test_$$"
    mkdir -p "$TEST_DIR"
    echo "Created test directory: $TEST_DIR" >&2
    
    # Make gdst.sh executable and available
    # Use the current working directory approach
    echo "Searching for gdst.sh script..." >&2
    
    if [[ -f "./gdst.sh" ]]; then
        export GDST_SCRIPT="$(pwd)/gdst.sh"
        echo "Found gdst.sh in current directory: $GDST_SCRIPT" >&2
    elif [[ -f "../gdst.sh" ]]; then
        export GDST_SCRIPT="$(cd .. && pwd)/gdst.sh"
        echo "Found gdst.sh in parent directory: $GDST_SCRIPT" >&2
    else
        # Fallback: search for the script
        echo "Searching for gdst.sh recursively..." >&2
        export GDST_SCRIPT="$(find "$(pwd)" -name "gdst.sh" -type f | head -1)"
        echo "Found via search: $GDST_SCRIPT" >&2
    fi
    
    # Additional debug information
    echo "Contents of current directory:" >&2
    ls -la >&2
    echo "Contents of parent directory:" >&2
    ls -la .. 2>/dev/null >&2 || echo "Cannot access parent directory" >&2
    
    # Verify the script exists before trying to make it executable
    if [[ ! -f "$GDST_SCRIPT" ]]; then
        echo "ERROR: Could not find gdst.sh" >&2
        echo "PWD: $(pwd)" >&2
        echo "Script path attempted: $GDST_SCRIPT" >&2
        echo "Available files in current dir:" >&2
        find . -name "*.sh" -type f 2>/dev/null >&2 || echo "No .sh files found" >&2
        echo "===========================" >&2
        exit 1
    fi
    
    echo "Making script executable: $GDST_SCRIPT" >&2
    chmod +x "$GDST_SCRIPT"
    echo "Script permissions: $(ls -la "$GDST_SCRIPT")" >&2
    echo "=== SETUP COMPLETE ===" >&2
}

# Teardown function runs after each test
teardown() {
    # Clean up test environment
    rm -rf "$TEST_DIR"
}

@test "gdst.sh displays help when no arguments provided" {
    echo "=== TEST: Help display ===" >&2
    echo "Running: $GDST_SCRIPT" >&2
    
    run "$GDST_SCRIPT"
    
    echo "Exit code: $status" >&2
    echo "Output length: ${#output}" >&2
    echo "Output preview: ${output:0:100}..." >&2
    
    assert_failure
    assert_output --partial "Repository name is required"
    assert_output --partial "--help"
}

@test "gdst.sh displays version with --version flag" {
    echo "=== TEST: Version display ===" >&2
    echo "Running: $GDST_SCRIPT --version" >&2
    
    run "$GDST_SCRIPT" --version
    
    echo "Exit code: $status" >&2
    echo "Output: $output" >&2
    
    assert_success
    assert_output --partial "GDST"
    assert_output --partial "v1.0.0"
}

@test "gdst.sh creates directory structure" {
    echo "=== TEST: Directory structure ===" >&2
    echo "Running: $GDST_SCRIPT --name test-project --username testuser --type python --directory $TEST_DIR --dry-run" >&2
    
    run "$GDST_SCRIPT" --name "test-project" --username "testuser" --type "python" --directory "$TEST_DIR" --dry-run
    
    echo "Exit code: $status" >&2
    echo "Output length: ${#output}" >&2
    echo "Output preview: ${output:0:200}..." >&2
    
    assert_success
    assert_output --partial "test-project"
    assert_output --partial "python"
}

@test "gdst.sh respects configuration file settings" {
    # Create a test configuration file
    cat > "$TEST_DIR/gdst.conf" << EOF
REPO_NAME=config-test
PROJECT_TYPE=python
GITHUB_USERNAME=testuser
EOF
    
    cd "$TEST_DIR"
    run "$GDST_SCRIPT" --directory "$TEST_DIR" --dry-run
    
    assert_success
    assert_output --partial "config-test"
    assert_output --partial "python"
}

@test "command line arguments override configuration file" {
    # Create a test configuration file
    cat > "$TEST_DIR/gdst.conf" << EOF
REPO_NAME=config-test
PROJECT_TYPE=node
GITHUB_USERNAME=testuser
EOF
    
    cd "$TEST_DIR"
    run "$GDST_SCRIPT" --name "override-test" --type "python" --directory "$TEST_DIR" --dry-run
    
    assert_success
    assert_output --partial "override-test"
    assert_output --partial "python"
    refute_output --partial "config-test"
    refute_output --partial "node"
}
