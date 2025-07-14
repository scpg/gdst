#!/bin/bash

# GDST Basic Functionality Tests
# Tests core functionality including help, version, and basic project creation

source "$(dirname "${BASH_SOURCE[0]}")/test_framework.sh"

test_help_command() {
    start_test "Help command displays usage information"
    
    run_gdst_dry_run "--help"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Help command should exit with code 0" &&
       assert_contains "$GDST_OUTPUT" "GDST - GitHub Development Setup Tool" "Should display tool name" &&
       assert_contains "$GDST_OUTPUT" "USAGE:" "Should display usage section" &&
       assert_contains "$GDST_OUTPUT" "OPTIONS:" "Should display options section" &&
       assert_contains "$GDST_OUTPUT" "EXAMPLES:" "Should display examples section"; then
        pass_test "Help command displays comprehensive usage information"
    fi
}

test_version_command() {
    start_test "Version command displays version information"
    
    run_gdst_dry_run "--version"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Version command should exit with code 0" &&
       assert_contains "$GDST_OUTPUT" "GDST - GitHub Development Setup Tool" "Should display tool name" &&
       assert_contains "$GDST_OUTPUT" "v1.0.0" "Should display version number"; then
        pass_test "Version command displays correct version information"
    fi
}

test_missing_required_parameters() {
    start_test "Missing required parameters show error"
    
    run_gdst_dry_run ""
    
    if assert_exit_code 1 $GDST_EXIT_CODE "Should exit with error code" &&
       assert_contains "$GDST_OUTPUT" "Repository name is required" "Should show repository name error" &&
       assert_contains "$GDST_OUTPUT" "Use -n or --name" "Should show usage hint"; then
        pass_test "Missing required parameters handled correctly"
    fi
}

test_invalid_project_type() {
    start_test "Invalid project type shows error"
    
    run_gdst_dry_run "-n test-project -u testuser -t invalid"
    
    if assert_exit_code 1 $GDST_EXIT_CODE "Should exit with error code" &&
       assert_contains "$GDST_OUTPUT" "Invalid project type: invalid" "Should show invalid type error" &&
       assert_contains "$GDST_OUTPUT" "Supported: node, python, java, react, other" "Should show supported types"; then
        pass_test "Invalid project type handled correctly"
    fi
}

test_invalid_visibility() {
    start_test "Invalid repository visibility shows error"
    
    run_gdst_dry_run "-n test-project -u testuser -V invalid"
    
    if assert_exit_code 1 $GDST_EXIT_CODE "Should exit with error code" &&
       assert_contains "$GDST_OUTPUT" "Invalid repository visibility: invalid" "Should show invalid visibility error" &&
       assert_contains "$GDST_OUTPUT" "Supported: public, private" "Should show supported visibility options"; then
        pass_test "Invalid repository visibility handled correctly"
    fi
}

test_invalid_working_directory() {
    start_test "Invalid working directory shows error"
    
    run_gdst_dry_run "-n test-project -u testuser -d /nonexistent/directory"
    
    if assert_exit_code 1 $GDST_EXIT_CODE "Should exit with error code" &&
       assert_contains "$GDST_OUTPUT" "working directory does not exist" "Should show directory error"; then
        pass_test "Invalid working directory handled correctly"
    fi
}

test_basic_node_project() {
    start_test "Basic Node.js project creation"
    
    run_gdst_dry_run "-n test-node-project -u testuser -t node"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should exit successfully" &&
       assert_contains "$GDST_OUTPUT" "Repository: test-node-project" "Should show repository name" &&
       assert_contains "$GDST_OUTPUT" "Project Type: node" "Should show project type" &&
       assert_contains "$GDST_OUTPUT" "GitHub Username: testuser" "Should show username" &&
       assert_contains "$GDST_OUTPUT" "Setting up Node.js project structure" "Should setup Node.js structure" &&
       assert_contains "$GDST_OUTPUT" "Setup Complete!" "Should complete successfully"; then
        pass_test "Basic Node.js project created successfully"
    fi
}

test_basic_python_project() {
    start_test "Basic Python project creation"
    
    run_gdst_dry_run "-n test-python-project -u testuser -t python"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should exit successfully" &&
       assert_contains "$GDST_OUTPUT" "Repository: test-python-project" "Should show repository name" &&
       assert_contains "$GDST_OUTPUT" "Project Type: python" "Should show project type" &&
       assert_contains "$GDST_OUTPUT" "Setting up Python project structure" "Should setup Python structure" &&
       assert_contains "$GDST_OUTPUT" "Setup Complete!" "Should complete successfully"; then
        pass_test "Basic Python project created successfully"
    fi
}

test_basic_java_project() {
    start_test "Basic Java project creation"
    
    run_gdst_dry_run "-n test-java-project -u testuser -t java"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should exit successfully" &&
       assert_contains "$GDST_OUTPUT" "Repository: test-java-project" "Should show repository name" &&
       assert_contains "$GDST_OUTPUT" "Project Type: java" "Should show project type" &&
       assert_contains "$GDST_OUTPUT" "Setting up Java project structure" "Should setup Java structure" &&
       assert_contains "$GDST_OUTPUT" "Setup Complete!" "Should complete successfully"; then
        pass_test "Basic Java project created successfully"
    fi
}

test_basic_react_project() {
    start_test "Basic React project creation"
    
    run_gdst_dry_run "-n test-react-project -u testuser -t react"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should exit successfully" &&
       assert_contains "$GDST_OUTPUT" "Repository: test-react-project" "Should show repository name" &&
       assert_contains "$GDST_OUTPUT" "Project Type: react" "Should show project type" &&
       assert_contains "$GDST_OUTPUT" "Setting up Node.js project structure" "Should setup Node.js structure for React" &&
       assert_contains "$GDST_OUTPUT" "Setup Complete!" "Should complete successfully"; then
        pass_test "Basic React project created successfully"
    fi
}

test_basic_generic_project() {
    start_test "Basic generic project creation"
    
    run_gdst_dry_run "-n test-generic-project -u testuser -t other"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should exit successfully" &&
       assert_contains "$GDST_OUTPUT" "Repository: test-generic-project" "Should show repository name" &&
       assert_contains "$GDST_OUTPUT" "Project Type: other" "Should show project type" &&
       assert_contains "$GDST_OUTPUT" "Setting up generic project structure" "Should setup generic structure" &&
       assert_contains "$GDST_OUTPUT" "Setup Complete!" "Should complete successfully"; then
        pass_test "Basic generic project created successfully"
    fi
}

# Run all tests
run_basic_tests() {
    start_test_suite "Basic Functionality Tests"
    
    test_help_command
    test_version_command
    test_missing_required_parameters
    test_invalid_project_type
    test_invalid_visibility
    test_invalid_working_directory
    test_basic_node_project
    test_basic_python_project
    test_basic_java_project
    test_basic_react_project
    test_basic_generic_project
}

# Run tests if this script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    init_test_framework
    run_basic_tests
    
    # Exit with appropriate code
    if [[ $TESTS_FAILED -gt 0 ]]; then
        exit 1
    else
        exit 0
    fi
fi
