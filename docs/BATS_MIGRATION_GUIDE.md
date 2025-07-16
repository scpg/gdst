# Bats Test Migration Guide

## Overview

This guide demonstrates how to migrate from the custom test framework to **bats-core** (Bash Automated Testing System). Bats is an industry-standard testing framework for Bash scripts that provides TAP-compliant output and powerful assertion helpers.

## Installation

Bats-core and its helpers have been installed in the `test/` directory:

```bash
test/
├── bats/              # Bats-core framework
├── bats-support/      # Helper functions for bats
├── bats-assert/       # Assertion helpers
└── test_example.bats  # Example bats test file
```

## Running Bats Tests

### Basic Commands

```bash
# Run a single test file
test/bats/bin/bats test/test_example.bats

# Run all bats tests
test/bats/bin/bats test/*.bats

# Run with verbose output
test/bats/bin/bats --verbose test/test_example.bats

# Run with TAP output
test/bats/bin/bats --tap test/test_example.bats
```

### Test Output Format

Bats provides clear, readable output:

```
test_example.bats
 ✓ gdst.sh displays help when no arguments provided
 ✓ gdst.sh displays version with --version flag
 ✓ gdst.sh creates directory structure
 ✓ gdst.sh respects configuration file settings
 ✓ command line arguments override configuration file

5 tests, 0 failures
```

## Migration From Custom Framework

### Custom Framework vs Bats

| Custom Framework | Bats Equivalent |
|------------------|-----------------|
| `start_test "description"` | `@test "description" {` |
| `pass_test` | `assert_success` |
| `fail_test "message"` | `assert_failure` |
| `assert_equals "expected" "actual"` | `assert_equal "expected" "actual"` |
| `assert_contains "substring" "text"` | `assert_output --partial "substring"` |

### Example Migration

**Before (Custom Framework):**
```bash
start_test "gdst.sh displays help when no arguments provided"
run_command "$GDST_SCRIPT"
if [ $? -eq 0 ]; then
    fail_test "Expected command to fail but it succeeded"
else
    if echo "$output" | grep -q "Repository name is required"; then
        pass_test
    else
        fail_test "Expected 'Repository name is required' in output"
    fi
fi
```

**After (Bats):**
```bash
@test "gdst.sh displays help when no arguments provided" {
    run "$GDST_SCRIPT"
    
    assert_failure
    assert_output --partial "Repository name is required"
    assert_output --partial "--help"
}
```

## Bats Test Structure

### Basic Test Template

```bash
#!/usr/bin/env bats

# Load bats helpers
load 'bats-support/load'
load 'bats-assert/load'

# Setup function runs before each test
setup() {
    export TEST_DIR="/tmp/gdst_test_$$"
    mkdir -p "$TEST_DIR"
    export GDST_SCRIPT="/mnt/c/dev/2025/gdst/gdst.sh"
    chmod +x "$GDST_SCRIPT"
}

# Teardown function runs after each test
teardown() {
    rm -rf "$TEST_DIR"
}

@test "test description" {
    # Test code here
    run some_command
    assert_success
    assert_output "expected output"
}
```

### Key Bats Features

1. **`run` command**: Captures exit status and output
2. **`setup()` and `teardown()`**: Automatic test isolation
3. **Assertion helpers**: Rich set of assertions from bats-assert
4. **Test isolation**: Each test runs in its own subprocess

## Available Assertions

### Basic Assertions
- `assert_success`: Command succeeded (exit code 0)
- `assert_failure`: Command failed (non-zero exit code)
- `assert_equal expected actual`: Values are equal
- `assert_not_equal expected actual`: Values are not equal

### Output Assertions
- `assert_output "text"`: Exact output match
- `assert_output --partial "text"`: Partial output match
- `assert_output --regexp "pattern"`: Regex output match
- `refute_output "text"`: Output does not contain text

### Line Assertions
- `assert_line "text"`: Specific line contains text
- `assert_line --index 0 "text"`: Line at index contains text
- `assert_line --partial "text"`: Any line contains text

### File Assertions
- `assert [ -f "file" ]`: File exists
- `assert [ -d "dir" ]`: Directory exists
- `assert [ -x "file" ]`: File is executable

## Migration Strategy

### Phase 1: Convert Test Structure
1. Replace `start_test` with `@test`
2. Add `setup()` and `teardown()` functions
3. Replace custom assertions with bats assertions

### Phase 2: Enhance with Bats Features
1. Use `run` command for better output capture
2. Add proper test isolation
3. Use bats-assert helpers for cleaner assertions

### Phase 3: Add Advanced Features
1. Use test fixtures for complex setups
2. Add test parameterization
3. Implement test helpers for common operations

## Best Practices

### 1. Test Isolation
```bash
setup() {
    export TEST_TEMP_DIR="/tmp/test_$$"
    mkdir -p "$TEST_TEMP_DIR"
}

teardown() {
    rm -rf "$TEST_TEMP_DIR"
}
```

### 2. Clear Test Descriptions
```bash
@test "gdst.sh creates Python project with correct structure"
@test "configuration file overrides default project type"
@test "command line arguments take precedence over config file"
```

### 3. Use Specific Assertions
```bash
# Instead of generic success/failure
assert_success

# Use specific output assertions
assert_output --partial "config-test"
assert_output --partial "python"
```

### 4. Test Both Positive and Negative Cases
```bash
@test "valid configuration is accepted" {
    run "$GDST_SCRIPT" --name "test" --username "user"
    assert_success
}

@test "missing required arguments are rejected" {
    run "$GDST_SCRIPT"
    assert_failure
    assert_output --partial "Repository name is required"
}
```

## Running Tests in CI/CD

Bats integrates well with CI/CD systems:

```yaml
# GitHub Actions example
- name: Run Bats Tests
  run: |
    test/bats/bin/bats test/*.bats
```

## Benefits of Migration

1. **Industry Standard**: Bats is widely used and well-maintained
2. **TAP Compliance**: Standard test output format
3. **Better Assertions**: Rich set of assertion helpers
4. **Test Isolation**: Automatic setup/teardown
5. **CI/CD Integration**: Better reporting and integration
6. **Community Support**: Large ecosystem and documentation

## Current Status

- ✅ Bats-core installed and working
- ✅ Example test file created and passing
- ✅ Migration guide documented
- 📋 Next: Begin systematic migration of existing 49 tests

The migration can be done incrementally, starting with the most critical tests and gradually converting the entire test suite.
