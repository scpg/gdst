#!/bin/bash

# GDST Security Tests
# Tests security features and vulnerability fixes

source "$(dirname "${BASH_SOURCE[0]}")/test_framework.sh"

test_sed_vulnerability_protection() {
    start_test "Sed command vulnerability protection"
    
    # Test with potentially dangerous characters
    run_gdst_dry_run "-n 'test/project;rm -rf /' -u testuser"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should handle dangerous characters safely" &&
       assert_not_contains "$GDST_OUTPUT" "rm -rf" "Should not execute dangerous commands"; then
        pass_test "Sed command vulnerability protection works correctly"
    else
        fail_test "Sed command vulnerability protection test failed"
    fi
}

test_input_validation() {
    start_test "Input validation and sanitization"
    
    # Test with special characters in repository name
    run_gdst_dry_run "-n 'test\$project' -u testuser"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should handle special characters in input" &&
       assert_contains "$GDST_OUTPUT" "Repository: test\$project" "Should display repository name safely"; then
        pass_test "Input validation and sanitization works correctly"
    fi
}

test_path_traversal_protection() {
    start_test "Path traversal protection"
    
    # Test with path traversal attempt
    run_gdst_dry_run "-n '../../../etc/passwd' -u testuser"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should handle path traversal attempts safely" &&
       assert_not_contains "$GDST_OUTPUT" "/etc/passwd" "Should not access system files"; then
        pass_test "Path traversal protection works correctly"
    fi
}

test_command_injection_protection() {
    start_test "Command injection protection"
    
    # Test with command injection attempt
    run_gdst_dry_run "-n 'test\`whoami\`' -u testuser"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should handle command injection attempts safely" &&
       assert_not_contains "$GDST_OUTPUT" "whoami" "Should not execute injected commands"; then
        pass_test "Command injection protection works correctly"
    fi
}

test_directory_validation() {
    start_test "Directory validation and sanitization"
    
    # Test with invalid directory characters
    run_gdst_dry_run "-n test-project -u testuser -d '/tmp/test\$dir'"
    
    if assert_exit_code 1 $GDST_EXIT_CODE "Should reject invalid directory paths" &&
       assert_contains "$GDST_OUTPUT" "working directory does not exist" "Should show directory validation error"; then
        pass_test "Directory validation and sanitization works correctly"
    fi
}

test_username_validation() {
    start_test "Username validation and sanitization"
    
    # Test with potentially dangerous username
    run_gdst_dry_run "-n test-project -u 'user;rm -rf /'"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should handle dangerous usernames safely" &&
       assert_not_contains "$GDST_OUTPUT" "rm -rf" "Should not execute dangerous commands in username"; then
        pass_test "Username validation and sanitization works correctly"
    fi
}

test_file_creation_safety() {
    start_test "File creation safety"
    
    run_gdst_dry_run "-n test-project -u testuser --verbose"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should create files safely" &&
       assert_contains "$GDST_OUTPUT" "[DRY RUN]" "Should show dry run indicators" &&
       assert_not_contains "$GDST_OUTPUT" "rm -rf" "Should not contain dangerous commands"; then
        pass_test "File creation safety works correctly"
    fi
}

test_git_config_safety() {
    start_test "Git configuration safety"
    
    run_gdst_dry_run "-n test-project -u testuser --verbose"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should configure Git safely" &&
       assert_contains "$GDST_OUTPUT" "Would configure Git user" "Should show Git configuration" &&
       assert_not_contains "$GDST_OUTPUT" "git config --global" "Should not modify global Git config"; then
        pass_test "Git configuration safety works correctly"
    fi
}

test_template_processing_safety() {
    start_test "Template processing safety"
    
    run_gdst_dry_run "-n test-project -u testuser --verbose"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should process templates safely" &&
       assert_contains "$GDST_OUTPUT" "Would create package.json" "Should process templates" &&
       assert_not_contains "$GDST_OUTPUT" "eval" "Should not use eval in template processing"; then
        pass_test "Template processing safety works correctly"
    fi
}

test_error_message_safety() {
    start_test "Error message safety"
    
    # Test with input that could cause information disclosure
    run_gdst_dry_run "-n test-project -u testuser -d '/etc/shadow'"
    
    if assert_exit_code 1 $GDST_EXIT_CODE "Should handle security-sensitive paths safely" &&
       assert_contains "$GDST_OUTPUT" "working directory does not exist" "Should show safe error message" &&
       assert_not_contains "$GDST_OUTPUT" "shadow" "Should not expose sensitive path information"; then
        pass_test "Error message safety works correctly"
    fi
}

test_working_directory_safety() {
    start_test "Working directory safety"
    
    local test_dir=$(create_test_dir "safe-test")
    
    run_gdst_dry_run "-n test-project -u testuser -d $test_dir --verbose"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should handle working directory safely" &&
       assert_contains "$GDST_OUTPUT" "Directory validation passed" "Should validate directory" &&
       assert_contains "$GDST_OUTPUT" "Successfully changed to: $test_dir" "Should change directory safely"; then
        pass_test "Working directory safety works correctly"
    fi
}

test_rollback_safety() {
    start_test "Rollback mechanism safety"
    
    local test_dir=$(create_test_dir "rollback-test")
    
    run_gdst_dry_run "-n test-project -u testuser -d $test_dir --verbose"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should handle rollback safely" &&
       assert_contains "$GDST_OUTPUT" "Saved current directory" "Should save current directory" &&
       assert_contains "$GDST_OUTPUT" "Successfully restored to" "Should restore directory safely"; then
        pass_test "Rollback mechanism safety works correctly"
    fi
}

test_log_output_safety() {
    start_test "Log output safety"
    
    run_gdst_dry_run "-n test-project -u testuser --verbose"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should log output safely" &&
       assert_contains "$GDST_OUTPUT" "[DEBUG]" "Should contain debug messages" &&
       assert_not_contains "$GDST_OUTPUT" "password" "Should not log sensitive information"; then
        pass_test "Log output safety works correctly"
    fi
}

# Run all tests
run_security_tests() {
    start_test_suite "Security Tests"
    
    test_sed_vulnerability_protection
    test_input_validation
    test_path_traversal_protection
    test_command_injection_protection
    test_directory_validation
    test_username_validation
    test_file_creation_safety
    test_git_config_safety
    test_template_processing_safety
    test_error_message_safety
    test_working_directory_safety
    test_rollback_safety
    test_log_output_safety
}

# Run tests if this script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    init_test_framework
    run_security_tests
    
    # Exit with appropriate code
    if [[ $TESTS_FAILED -gt 0 ]]; then
        exit 1
    else
        exit 0
    fi
fi
