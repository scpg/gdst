#!/bin/bash

# GDST Advanced Features Tests
# Tests advanced features including verbose mode, skip options, custom directories, etc.

source "$(dirname "${BASH_SOURCE[0]}")/test_framework.sh"

test_verbose_mode() {
    start_test "Verbose mode provides detailed output"
    
    run_gdst_dry_run "-n test-project -u testuser --verbose"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should exit successfully" &&
       assert_contains "$GDST_OUTPUT" "Verbose Mode: Yes" "Should show verbose mode enabled" &&
       assert_contains "$GDST_OUTPUT" "Log Level: DEBUG" "Should show debug log level" &&
       assert_contains "$GDST_OUTPUT" "[DEBUG]" "Should contain debug messages"; then
        pass_test "Verbose mode provides detailed output"
    fi
}

test_custom_log_level() {
    start_test "Custom log level configuration"
    
    run_gdst_dry_run "-n test-project -u testuser --level ERROR"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should exit successfully" &&
       assert_contains "$GDST_OUTPUT" "Log Level: ERROR" "Should show custom log level"; then
        pass_test "Custom log level configured correctly"
    fi
}

test_skip_install_option() {
    start_test "Skip install option works correctly"
    
    run_gdst_dry_run "-n test-project -u testuser --skip-install"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should exit successfully" &&
       assert_contains "$GDST_OUTPUT" "Skip Package Install: Yes" "Should show skip install enabled" &&
       assert_contains "$GDST_OUTPUT" "Skipping package installation" "Should skip installation"; then
        pass_test "Skip install option works correctly"
    fi
}

test_skip_protection_option() {
    start_test "Skip protection option works correctly"
    
    run_gdst_dry_run "-n test-project -u testuser --skip-protection"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should exit successfully" &&
       assert_contains "$GDST_OUTPUT" "Skip Branch Protection: Yes" "Should show skip protection enabled"; then
        pass_test "Skip protection option works correctly"
    fi
}

test_private_repository() {
    start_test "Private repository visibility"
    
    run_gdst_dry_run "-n test-project -u testuser -V private"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should exit successfully" &&
       assert_contains "$GDST_OUTPUT" "Repository Visibility: private" "Should show private visibility"; then
        pass_test "Private repository visibility configured correctly"
    fi
}

test_custom_directory() {
    start_test "Custom working directory"
    
    local test_dir=$(create_test_dir "custom-test")
    
    run_gdst_dry_run "-n test-project -u testuser -d $test_dir"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should exit successfully" &&
       assert_contains "$GDST_OUTPUT" "Working Directory: $test_dir" "Should show custom directory"; then
        pass_test "Custom working directory configured correctly"
    fi
}

test_combined_options() {
    start_test "Combined options work together"
    
    local test_dir=$(create_test_dir "combined-test")
    
    run_gdst_dry_run "-n test-project -u testuser -t python -V private -d $test_dir --skip-install --skip-protection --verbose"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should exit successfully" &&
       assert_contains "$GDST_OUTPUT" "Project Type: python" "Should show Python project" &&
       assert_contains "$GDST_OUTPUT" "Repository Visibility: private" "Should show private visibility" &&
       assert_contains "$GDST_OUTPUT" "Working Directory: $test_dir" "Should show custom directory" &&
       assert_contains "$GDST_OUTPUT" "Skip Package Install: Yes" "Should skip install" &&
       assert_contains "$GDST_OUTPUT" "Skip Branch Protection: Yes" "Should skip protection" &&
       assert_contains "$GDST_OUTPUT" "Verbose Mode: Yes" "Should enable verbose mode"; then
        pass_test "Combined options work together correctly"
    fi
}

test_dry_run_mode() {
    start_test "Dry run mode prevents actual changes"
    
    run_gdst_dry_run "-n test-project -u testuser"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should exit successfully" &&
       assert_contains "$GDST_OUTPUT" "Dry Run Mode: Yes" "Should show dry run enabled" &&
       assert_contains "$GDST_OUTPUT" "[DRY RUN]" "Should contain dry run indicators" &&
       assert_contains "$GDST_OUTPUT" "Dry run completed - no actual changes were made" "Should confirm no changes"; then
        pass_test "Dry run mode prevents actual changes"
    fi
}

test_prerequisite_checks() {
    start_test "Prerequisite checks are performed"
    
    run_gdst_dry_run "-n test-project -u testuser --verbose"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should exit successfully" &&
       assert_contains "$GDST_OUTPUT" "Checking Prerequisites" "Should check prerequisites" &&
       assert_contains "$GDST_OUTPUT" "All prerequisites satisfied" "Should satisfy prerequisites"; then
        pass_test "Prerequisite checks are performed"
    fi
}

test_preflight_checks() {
    start_test "Pre-flight checks are performed"
    
    run_gdst_dry_run "-n test-project -u testuser --verbose"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should exit successfully" &&
       assert_contains "$GDST_OUTPUT" "Pre-flight Checks" "Should perform pre-flight checks" &&
       assert_contains "$GDST_OUTPUT" "Disk space check passed" "Should check disk space" &&
       assert_contains "$GDST_OUTPUT" "Internet connectivity check passed" "Should check connectivity" &&
       assert_contains "$GDST_OUTPUT" "All pre-flight checks passed" "Should pass all checks"; then
        pass_test "Pre-flight checks are performed"
    fi
}

test_progress_indicators() {
    start_test "Progress indicators are shown"
    
    run_gdst_dry_run "-n test-project -u testuser"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should exit successfully" &&
       assert_contains "$GDST_OUTPUT" "Setting up Local Development Environment" "Should show setup progress" &&
       assert_contains "$GDST_OUTPUT" "Creating GitHub Workflows" "Should show workflow progress" &&
       assert_contains "$GDST_OUTPUT" "Creating Configuration Files" "Should show config progress" &&
       assert_contains "$GDST_OUTPUT" "Setup Complete!" "Should show completion"; then
        pass_test "Progress indicators are shown"
    fi
}

test_error_handling_and_logging() {
    start_test "Error handling and logging work correctly"
    
    run_gdst_dry_run "-n test-project -u testuser --verbose"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should exit successfully" &&
       assert_contains "$GDST_OUTPUT" "[INFO]" "Should contain info messages" &&
       assert_contains "$GDST_OUTPUT" "[DEBUG]" "Should contain debug messages in verbose mode"; then
        pass_test "Error handling and logging work correctly"
    fi
}

# Run all tests
run_advanced_tests() {
    start_test_suite "Advanced Features Tests"
    
    test_verbose_mode
    test_custom_log_level
    test_skip_install_option
    test_skip_protection_option
    test_private_repository
    test_custom_directory
    test_combined_options
    test_dry_run_mode
    test_prerequisite_checks
    test_preflight_checks
    test_progress_indicators
    test_error_handling_and_logging
}

# Run tests if this script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    init_test_framework
    run_advanced_tests
    
    # Exit with appropriate code
    if [[ $TESTS_FAILED -gt 0 ]]; then
        exit 1
    else
        exit 0
    fi
fi
