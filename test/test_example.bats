#!/usr/bin/env bats

# Simple bats test file for GDST
# This version uses basic bats functionality without complex helper dependencies

# Setup function runs before each test
setup() {
    echo "=== BATS TEST SETUP ===" >&2
    echo "Working directory: $(pwd)" >&2
    
    # Set up test environment
    export TEST_DIR="/tmp/gdst_test_$$"
    mkdir -p "$TEST_DIR"
    
    # Simple, reliable script detection
    if [[ -f "gdst.sh" ]]; then
        export GDST_SCRIPT="$(pwd)/gdst.sh"
    elif [[ -f "../gdst.sh" ]]; then
        export GDST_SCRIPT="$(cd .. && pwd)/gdst.sh"
    else
        echo "ERROR: Cannot find gdst.sh script" >&2
        echo "Current directory: $(pwd)" >&2
        echo "Files in current directory:" >&2
        ls -la >&2
        return 1
    fi
    
    echo "Using script: $GDST_SCRIPT" >&2
    chmod +x "$GDST_SCRIPT"
    echo "=== SETUP COMPLETE ===" >&2
}

# Teardown function runs after each test
teardown() {
    # Clean up test environment
    rm -rf "$TEST_DIR" 2>/dev/null || true
}

@test "gdst.sh displays help when no arguments provided" {
    echo "=== TEST: Help display ===" >&2
    
    run "$GDST_SCRIPT"
    
    echo "Exit code: $status" >&2
    echo "Output: $output" >&2
    
    [ "$status" -ne 0 ]
    [[ "$output" =~ "Repository name is required" ]]
}

@test "gdst.sh displays version with --version flag" {
    echo "=== TEST: Version display ===" >&2
    
    run "$GDST_SCRIPT" --version
    
    echo "Exit code: $status" >&2
    echo "Output: $output" >&2
    
    [ "$status" -eq 0 ]
    [[ "$output" =~ "GDST" ]]
}

@test "gdst.sh performs dry-run successfully" {
    echo "=== TEST: Dry-run functionality ===" >&2
    
    run "$GDST_SCRIPT" --name "test-project" --username "testuser" --type "python" --directory "$TEST_DIR" --dry-run
    
    echo "Exit code: $status" >&2
    echo "Output preview: ${output:0:200}..." >&2
    
    [ "$status" -eq 0 ]
    [[ "$output" =~ "test-project" ]]
}
