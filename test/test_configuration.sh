#!/bin/bash

# GDST Configuration Tests
# Tests configuration file support and template processing

source "$(dirname "${BASH_SOURCE[0]}")/test_framework.sh"

test_config_file_loading() {
    start_test "Configuration file loading"
    
    local test_dir=$(create_test_dir "config-test")
    local config_file="$test_dir/gdst.conf"
    
    # Create test configuration file
    cat > "$config_file" << EOF
PROJECT_TYPE=python
REPO_VISIBILITY=private
VERBOSE_MODE=true
LOG_LEVEL=DEBUG
EOF
    
    # Change to test directory and run GDST from there
    local original_dir=$(pwd)
    cd "$test_dir"
    
    # Run GDST with config file in current directory and command line args that should override
    local temp_output="$TEST_TEMP_DIR/gdst_output_$$"
    "$GDST_SCRIPT_DIR/gdst.sh" -n test-project -u testuser -t node --dry-run > "$temp_output" 2>&1
    local exit_code=$?
    
    # Restore original directory
    cd "$original_dir"
    
    # Store output for assertions
    if [[ -f "$temp_output" ]]; then
        GDST_OUTPUT=$(cat "$temp_output")
    else
        GDST_OUTPUT=""
    fi
    GDST_EXIT_CODE=$exit_code
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should exit successfully" &&
       assert_contains "$GDST_OUTPUT" "Project Type: node" "Should use command line over config for type" &&
       assert_contains "$GDST_OUTPUT" "Repository Visibility: private" "Should use config value when not overridden by command line" &&
       assert_contains "$GDST_OUTPUT" "Verbose Mode: Yes" "Should use config value for verbose mode" &&
       assert_contains "$GDST_OUTPUT" "Log Level: DEBUG" "Should use config value for log level"; then
        pass_test "Configuration file loading works correctly"
    fi
}

test_template_validation() {
    start_test "Template validation and processing"
    
    run_gdst_dry_run "-n test-project -u testuser --verbose"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should exit successfully" &&
       assert_contains "$GDST_OUTPUT" "Would create package.json" "Should process Node.js templates" &&
       assert_contains "$GDST_OUTPUT" "Would create .gitignore" "Should process gitignore templates" &&
       assert_contains "$GDST_OUTPUT" "Would create README.md" "Should process README templates"; then
        pass_test "Template validation and processing works correctly"
    fi
}

test_project_structure_creation_node() {
    start_test "Node.js project structure creation"
    
    # Test Node.js project structure
    run_gdst_dry_run "-n test-node -u testuser -t node --verbose"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should exit successfully" &&
       assert_contains "$GDST_OUTPUT" "Would create src/, tests/, docs/ directories" "Should create Node.js directories" &&
       assert_contains "$GDST_OUTPUT" "Would create sample files: src/index.js, tests/index.test.js" "Should create Node.js files"; then
        pass_test "Node.js project structure creation works correctly"
    fi
}

test_project_structure_creation_python() {
    start_test "Python project structure creation"
    
    # Test Python project structure
    run_gdst_dry_run "-n test-python -u testuser -t python --verbose"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should exit successfully" &&
       assert_contains "$GDST_OUTPUT" "Setting up Python project structure" "Should setup Python structure"; then
        pass_test "Python project structure creation works correctly"
    fi
}

test_github_workflow_creation() {
    start_test "GitHub workflow creation"
    
    run_gdst_dry_run "-n test-project -u testuser --verbose"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should exit successfully" &&
       assert_contains "$GDST_OUTPUT" "Would create .github/workflows/ci-cd.yml" "Should create CI/CD workflow" &&
       assert_contains "$GDST_OUTPUT" "Would create .github/pull_request_template/default.md" "Should create PR template"; then
        pass_test "GitHub workflow creation works correctly"
    fi
}

test_helper_scripts_creation() {
    start_test "Helper scripts creation"
    
    run_gdst_dry_run "-n test-project -u testuser --verbose"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should exit successfully" &&
       assert_contains "$GDST_OUTPUT" "Would create scripts/new-feature.sh" "Should create new-feature script" &&
       assert_contains "$GDST_OUTPUT" "Would create scripts/deploy-qa.sh" "Should create deploy-qa script" &&
       assert_contains "$GDST_OUTPUT" "Would create scripts/deploy-prod.sh" "Should create deploy-prod script"; then
        pass_test "Helper scripts creation works correctly"
    fi
}

test_documentation_creation() {
    start_test "Documentation creation"
    
    run_gdst_dry_run "-n test-project -u testuser --verbose"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should exit successfully" &&
       assert_contains "$GDST_OUTPUT" "Would create docs/DEVELOPMENT.md" "Should create development docs" &&
       assert_contains "$GDST_OUTPUT" "Would create docs/DEPLOYMENT.md" "Should create deployment docs"; then
        pass_test "Documentation creation works correctly"
    fi
}

test_branch_validation_setup() {
    start_test "Branch validation setup"
    
    run_gdst_dry_run "-n test-project -u testuser --verbose"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should exit successfully" &&
       assert_contains "$GDST_OUTPUT" "Would create branch validation scripts" "Should create validation scripts" &&
       assert_contains "$GDST_OUTPUT" "Would install Git hooks" "Should install git hooks" &&
       assert_contains "$GDST_OUTPUT" "Would create branch naming documentation" "Should create branch naming docs"; then
        pass_test "Branch validation setup works correctly"
    fi
}

test_project_specific_configurations_java() {
    start_test "Java project-specific configurations"
    
    # Test Java project specific configuration
    run_gdst_dry_run "-n test-java -u testuser -t java --verbose"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should exit successfully" &&
       assert_contains "$GDST_OUTPUT" "Setting up Java project structure" "Should setup Java structure" &&
       assert_contains "$GDST_OUTPUT" "Would create .gitignore for java project" "Should create Java gitignore"; then
        pass_test "Java project-specific configurations work correctly"
    fi
}

test_project_specific_configurations_python() {
    start_test "Python project-specific configurations"
    
    # Test Python project specific configuration
    run_gdst_dry_run "-n test-python -u testuser -t python --verbose"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should exit successfully" &&
       assert_contains "$GDST_OUTPUT" "Setting up Python project structure" "Should setup Python structure" &&
       assert_contains "$GDST_OUTPUT" "Would create .gitignore for python project" "Should create Python gitignore"; then
        pass_test "Python project-specific configurations work correctly"
    fi
}

test_environment_file_creation() {
    start_test "Environment file creation"
    
    run_gdst_dry_run "-n test-project -u testuser --verbose"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should exit successfully" &&
       assert_contains "$GDST_OUTPUT" "Would create .env.example" "Should create environment example file"; then
        pass_test "Environment file creation works correctly"
    fi
}

test_readme_generation() {
    start_test "README generation"
    
    run_gdst_dry_run "-n test-project -u testuser --verbose"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should exit successfully" &&
       assert_contains "$GDST_OUTPUT" "Would create README.md" "Should create README file"; then
        pass_test "README generation works correctly"
    fi
}

test_next_steps_guidance() {
    start_test "Next steps guidance"
    
    run_gdst_dry_run "-n test-project -u testuser"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should exit successfully" &&
       assert_contains "$GDST_OUTPUT" "Next steps:" "Should provide next steps" &&
       assert_contains "$GDST_OUTPUT" "Start developing with: ./scripts/new-feature.sh" "Should show development guidance" &&
       assert_contains "$GDST_OUTPUT" "Deploy to QA with: ./scripts/deploy-qa.sh" "Should show QA deployment guidance"; then
        pass_test "Next steps guidance provided correctly"
    fi
}

# Run all tests
run_configuration_tests() {
    start_test_suite "Configuration and Templates Tests"
    
    test_config_file_loading
    test_template_validation
    test_project_structure_creation_node
    test_project_structure_creation_python
    test_github_workflow_creation
    test_helper_scripts_creation
    test_documentation_creation
    test_branch_validation_setup
    test_project_specific_configurations_java
    test_project_specific_configurations_python
    test_environment_file_creation
    test_readme_generation
    test_next_steps_guidance
}

# Run tests if this script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    init_test_framework
    run_configuration_tests
    
    # Exit with appropriate code
    if [[ $TESTS_FAILED -gt 0 ]]; then
        exit 1
    else
        exit 0
    fi
fi
