#!/usr/bin/env bats

# Example bats test file demonstrating migration from custom test framework
# This shows how to convert existing tests to bats format

# Load bats helpers
load 'bats-support/load'
load 'bats-assert/load'

# Setup function runs before each test
setup() {
    # Set up test environment
    export TEST_DIR="/tmp/gdst_test_$$"
    mkdir -p "$TEST_DIR"
    
    # Make gdst.sh executable and available
    export GDST_SCRIPT="/mnt/c/dev/2025/gdst/gdst.sh"
    chmod +x "$GDST_SCRIPT"
}

# Teardown function runs after each test
teardown() {
    # Clean up test environment
    rm -rf "$TEST_DIR"
}

@test "gdst.sh displays help when no arguments provided" {
    run "$GDST_SCRIPT"
    
    assert_failure
    assert_output --partial "Repository name is required"
    assert_output --partial "--help"
}

@test "gdst.sh displays version with --version flag" {
    run "$GDST_SCRIPT" --version
    
    assert_success
    assert_output --partial "GDST"
    assert_output --partial "v1.0.0"
}

@test "gdst.sh creates directory structure" {
    run "$GDST_SCRIPT" --name "test-project" --username "testuser" --type "python" --directory "$TEST_DIR" --dry-run
    
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
