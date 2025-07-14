#!/bin/bash

# GDST Continuous Integration Test Script
# Designed to run in CI/CD environments with proper reporting

set -e

# CI environment detection
CI_ENVIRONMENT="${CI_ENVIRONMENT:-false}"
if [[ "$CI" == "true" || "$GITHUB_ACTIONS" == "true" || "$JENKINS_URL" != "" ]]; then
    CI_ENVIRONMENT=true
fi

# Test configuration for CI
if [[ "$CI_ENVIRONMENT" == "true" ]]; then
    export TEST_RESULTS_DIR="/tmp/gdst-ci-results"
    export TEST_TEMP_DIR="/tmp/gdst-ci-temp"
    
    # Create JUnit XML output directory
    mkdir -p "$TEST_RESULTS_DIR/junit"
    
    # Install dependencies for XML reporting
    command -v xmlstarlet >/dev/null 2>&1 || {
        echo "Installing xmlstarlet for XML reporting..."
        if command -v apt-get >/dev/null 2>&1; then
            sudo apt-get update && sudo apt-get install -y xmlstarlet
        elif command -v yum >/dev/null 2>&1; then
            sudo yum install -y xmlstarlet
        fi
    }
fi

# Source the test framework
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/test_framework.sh"

# Enhanced test framework for CI
init_ci_test_framework() {
    echo "=== GDST CI Test Framework ==="
    echo "CI Environment: $CI_ENVIRONMENT"
    echo "Test Results Directory: $TEST_RESULTS_DIR"
    echo "Start Time: $(date)"
    echo ""
    
    # Initialize base framework
    init_test_framework
    
    # CI-specific setup
    if [[ "$CI_ENVIRONMENT" == "true" ]]; then
        # Set up JUnit XML output
        export JUNIT_XML_FILE="$TEST_RESULTS_DIR/junit/gdst-tests.xml"
        
        # Initialize JUnit XML
        cat > "$JUNIT_XML_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<testsuites name="GDST Tests" tests="0" failures="0" errors="0" time="0">
</testsuites>
EOF
    fi
}

# CI-specific test result reporting
report_ci_test_result() {
    local test_name="$1"
    local status="$2"
    local message="$3"
    local duration="${4:-0}"
    
    if [[ "$CI_ENVIRONMENT" == "true" && -f "$JUNIT_XML_FILE" ]]; then
        # Add test case to JUnit XML
        local xml_content
        xml_content=$(cat "$JUNIT_XML_FILE")
        
        # Simple XML generation (would be better with proper XML library)
        local test_case="<testcase name=\"$test_name\" classname=\"GDST\" time=\"$duration\">"
        
        if [[ "$status" == "FAIL" ]]; then
            test_case="$test_case<failure message=\"$message\">$message</failure>"
        elif [[ "$status" == "SKIP" ]]; then
            test_case="$test_case<skipped message=\"$message\">$message</skipped>"
        fi
        
        test_case="$test_case</testcase>"
        
        # Insert test case before closing testsuites tag
        xml_content="${xml_content%</testsuites>}$test_case</testsuites>"
        
        echo "$xml_content" > "$JUNIT_XML_FILE"
    fi
}

# Override test framework functions for CI reporting
original_pass_test=$(declare -f pass_test)
original_fail_test=$(declare -f fail_test)
original_skip_test=$(declare -f skip_test)

pass_test() {
    local message="${1:-Test passed}"
    local end_time=$(date +%s)
    local duration=$((end_time - TEST_START_TIME))
    
    eval "$original_pass_test"
    report_ci_test_result "$CURRENT_TEST_NAME" "PASS" "$message" "$duration"
}

fail_test() {
    local message="${1:-Test failed}"
    local end_time=$(date +%s)
    local duration=$((end_time - TEST_START_TIME))
    
    eval "$original_fail_test"
    report_ci_test_result "$CURRENT_TEST_NAME" "FAIL" "$message" "$duration"
}

skip_test() {
    local message="${1:-Test skipped}"
    
    eval "$original_skip_test"
    report_ci_test_result "$CURRENT_TEST_NAME" "SKIP" "$message" "0"
}

# Pre-test environment validation
validate_ci_environment() {
    echo "=== Validating CI Environment ==="
    
    # Check required tools
    local required_tools=("bash" "git" "curl")
    for tool in "${required_tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "✓ $tool is available"
        else
            echo "✗ $tool is missing"
            exit 1
        fi
    done
    
    # Check GDST script exists
    if [[ -f "$SCRIPT_DIR/../gdst.sh" ]]; then
        echo "✓ GDST script found"
    else
        echo "✗ GDST script not found"
        exit 1
    fi
    
    # Check disk space
    local available_space=$(df /tmp | tail -1 | awk '{print $4}')
    if [[ $available_space -gt 100000 ]]; then
        echo "✓ Sufficient disk space available"
    else
        echo "✗ Insufficient disk space"
        exit 1
    fi
    
    echo "Environment validation passed"
    echo ""
}

# Post-test cleanup and reporting
cleanup_ci_environment() {
    echo ""
    echo "=== CI Test Cleanup ==="
    
    if [[ "$CI_ENVIRONMENT" == "true" ]]; then
        # Generate summary report
        echo "Test Summary:" > "$TEST_RESULTS_DIR/summary.txt"
        echo "Total Tests: $TESTS_TOTAL" >> "$TEST_RESULTS_DIR/summary.txt"
        echo "Passed: $TESTS_PASSED" >> "$TEST_RESULTS_DIR/summary.txt"
        echo "Failed: $TESTS_FAILED" >> "$TEST_RESULTS_DIR/summary.txt"
        echo "Skipped: $TESTS_SKIPPED" >> "$TEST_RESULTS_DIR/summary.txt"
        echo "End Time: $(date)" >> "$TEST_RESULTS_DIR/summary.txt"
        
        # Output results for CI systems
        if [[ "$GITHUB_ACTIONS" == "true" ]]; then
            echo "::set-output name=tests_total::$TESTS_TOTAL"
            echo "::set-output name=tests_passed::$TESTS_PASSED"
            echo "::set-output name=tests_failed::$TESTS_FAILED"
            echo "::set-output name=tests_skipped::$TESTS_SKIPPED"
        fi
        
        # Archive test results
        if command -v tar >/dev/null 2>&1; then
            tar -czf "$TEST_RESULTS_DIR/test-results.tar.gz" -C "$TEST_RESULTS_DIR" .
            echo "Test results archived to: $TEST_RESULTS_DIR/test-results.tar.gz"
        fi
    fi
    
    # Call original cleanup
    cleanup_test_framework
}

# Main CI test execution
run_ci_tests() {
    # Override cleanup trap for CI
    trap cleanup_ci_environment EXIT
    
    validate_ci_environment
    init_ci_test_framework
    
    # Import and run test suites
    source "$SCRIPT_DIR/test_basic.sh"
    source "$SCRIPT_DIR/test_advanced.sh"
    source "$SCRIPT_DIR/test_configuration.sh"
    source "$SCRIPT_DIR/test_security.sh"
    
    # Run all test suites
    run_basic_tests
    run_advanced_tests
    run_configuration_tests
    run_security_tests
    
    echo "=== CI Test Execution Complete ==="
}

# Run CI tests
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_ci_tests
fi
