# GDST Testing Guide

## Overview

This directory contains a comprehensive test suite for the GDST (GitHub Development Setup Tool) based on the extensive dry-run testing performed during development. The test suite follows software engineering best practices and provides automated validation of all GDST features.

## Test Structure

### Test Framework (`test_framework.sh`)
- **Purpose**: Core testing utilities and assertion functions
- **Features**:
  - Colored output and progress reporting
  - Comprehensive assertion functions
  - Test result tracking and reporting
  - Cleanup and mock setup utilities
  - CI/CD integration support

### Test Suites

#### 1. Basic Functionality Tests (`test_basic.sh`)
Tests core GDST functionality including:
- Help and version commands
- Required parameter validation
- Error handling for invalid inputs
- Basic project creation for all supported types (node, python, java, react, other)

#### 2. Advanced Features Tests (`test_advanced.sh`)
Tests advanced GDST features including:
- Verbose mode and custom log levels
- Skip options (--skip-install, --skip-protection)
- Custom directories and private repositories
- Combined option handling
- Pre-flight checks and progress indicators

#### 3. Configuration Tests (`test_configuration.sh`)
Tests configuration and template processing:
- Configuration file loading (gdst.conf)
- Configuration file precedence (command-line overrides config)
- Template validation and processing
- Project structure creation
- GitHub workflow and documentation generation
- Project-specific configurations

#### 4. Security Tests (`test_security.sh`)
Tests security features and vulnerability fixes:
- Sed command vulnerability protection
- Input validation and sanitization
- Path traversal protection
- Command injection protection
- Safe file creation and Git configuration

### Test Runners

#### Master Test Runner (`run_tests.sh`)
- **Purpose**: Execute all test suites or specific suites
- **Usage**: `./run_tests.sh [OPTIONS] [SUITE]`
- **Features**:
  - Run all tests or specific test suites
  - Performance and stress testing
  - Integration testing with mocked GitHub API
  - Verbose output options

#### CI Test Runner (`ci_test.sh`)
- **Purpose**: Optimized for CI/CD environments
- **Features**:
  - JUnit XML output for CI integration
  - Environment validation
  - Automated reporting and archiving
  - GitHub Actions integration

## Running Tests

### Quick Start

```bash
# Run all tests
./test/run_tests.sh

# Run specific test suite
./test/run_tests.sh basic

# Run with verbose output
./test/run_tests.sh --verbose

# Run performance tests
./test/run_tests.sh --performance
```

### Individual Test Suites

```bash
# Run basic functionality tests
./test/test_basic.sh

# Run advanced features tests
./test/test_advanced.sh

# Run configuration tests
./test/test_configuration.sh

# Run security tests
./test/test_security.sh
```

### CI/CD Integration

```bash
# Run in CI environment
./test/ci_test.sh

# Results will be in /tmp/gdst-ci-results/
```

## Test Coverage

The test suite covers:

### ✅ **Core Functionality**
- Command-line argument parsing
- Help and version information
- Project type validation
- Repository visibility options
- Working directory handling

### ✅ **Advanced Features**
- Verbose mode and logging levels
- Skip options for installation and protection
- Custom directory specification
- Combined option handling
- Pre-flight system checks

### ✅ **Configuration Management**
- Configuration file loading
- Template processing and validation
- Project structure creation
- GitHub workflow generation
- Documentation generation

### ✅ **Security Features**
- Input validation and sanitization
- Sed command vulnerability protection
- Path traversal prevention
- Command injection protection
- Safe file and directory operations

### ✅ **Error Handling**
- Missing required parameters
- Invalid option values
- Directory validation
- Graceful error messages
- Proper exit codes

## Test Development Best Practices

### 1. Test Structure
- **Arrange**: Set up test conditions
- **Act**: Execute the functionality being tested
- **Assert**: Verify the expected outcomes

### 2. Test Naming
- Use descriptive test names that explain the behavior being tested
- Follow pattern: `test_feature_description()`

### 3. Assertions
- Use specific assertion functions for different types of validation
- Include descriptive error messages
- Test both positive and negative cases

### 4. Test Independence
- Each test should be independent and not rely on other tests
- Use proper setup and cleanup for each test
- Avoid shared state between tests

### 5. Mock and Stubs
- Use GitHub API mocks for testing without external dependencies
- Mock file system operations when appropriate
- Ensure mocks accurately represent real behavior

## Adding New Tests

### 1. Create Test Function
```bash
test_new_feature() {
    start_test "Description of what is being tested"
    
    # Arrange
    local test_dir=$(create_test_dir "new-feature-test")
    
    # Act
    run_gdst_dry_run "-n test-project -u testuser --new-feature"
    
    # Assert
    if assert_exit_code 0 $GDST_EXIT_CODE "Should exit successfully" &&
       assert_contains "$GDST_OUTPUT" "Expected output" "Should contain expected output"; then
        pass_test "New feature works correctly"
    fi
}
```

### 2. Add to Test Suite
```bash
# Add to appropriate test suite function
run_feature_tests() {
    start_test_suite "Feature Tests"
    
    # ... existing tests ...
    test_new_feature
}
```

### 3. Update Documentation
- Update this README with new test descriptions
- Add any new dependencies or setup requirements
- Document any new test patterns or utilities

## Test Results

Test results are stored in:
- **Standard**: `/tmp/gdst-test-results/`
- **CI Environment**: `/tmp/gdst-ci-results/`

### Output Files
- `test_run.log`: Detailed test execution log
- `summary.txt`: Test summary (CI only)
- `junit/gdst-tests.xml`: JUnit XML format (CI only)
- `test-results.tar.gz`: Archived results (CI only)

## Performance Considerations

### Test Execution Time
- All tests run in dry-run mode to avoid actual file system changes
- GitHub API calls are mocked to prevent rate limiting
- Test suite typically completes in under 60 seconds

### Resource Usage
- Tests use temporary directories that are automatically cleaned up
- Minimal disk space required (< 100MB)
- Memory usage is minimal due to dry-run mode

## Troubleshooting

### Common Issues

1. **Permission Errors**
   - Ensure test directories are writable
   - Check that GDST script has execute permissions

2. **Missing Dependencies**
   - Verify bash version is 4.0 or higher
   - Ensure required tools are installed (git, curl, etc.)

3. **Test Failures**
   - Check test output in `/tmp/gdst-test-results/test_run.log`
   - Verify GDST script path is correct
   - Ensure no conflicting processes are running

### Debug Mode
```bash
# Run with debug output
DEBUG=1 ./test/run_tests.sh

# Check specific test output
./test/test_basic.sh --verbose
```

## Integration with Development Workflow

### Pre-commit Testing
```bash
# Add to .git/hooks/pre-commit
#!/bin/bash
./test/run_tests.sh basic
```

### CI/CD Integration
```yaml
# GitHub Actions example
- name: Run GDST Tests
  run: ./test/ci_test.sh
  
- name: Upload Test Results
  uses: actions/upload-artifact@v2
  with:
    name: test-results
    path: /tmp/gdst-ci-results/
```

## Future Enhancements

1. **Code Coverage**: Add coverage reporting for shell scripts
2. **Performance Benchmarks**: Automated performance regression testing
3. **Integration Tests**: Real GitHub API integration tests (with proper tokens)
4. **Parallel Execution**: Run test suites in parallel for faster execution
5. **Test Data Management**: Structured test data and fixtures

## Contributing

When contributing to the test suite:

1. Follow existing test patterns and naming conventions
2. Include both positive and negative test cases
3. Add appropriate documentation
4. Ensure tests are independent and reproducible
5. Update this README with any new test categories or utilities

## License

This test suite is part of the GDST project and follows the same licensing terms.
