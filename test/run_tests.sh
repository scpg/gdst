#!/bin/bash

# GDST Test Suite Runner
# Master test runner that executes all test suites

source "$(dirname "${BASH_SOURCE[0]}")/test_framework.sh"

# Test suite files
TEST_SUITES=(
    "test_basic.sh"
    "test_advanced.sh"
    "test_configuration.sh"
    "test_security.sh"
)

# Import individual test suites
for suite in "${TEST_SUITES[@]}"; do
    source "$(dirname "${BASH_SOURCE[0]}")/$suite"
done

# Run all test suites
run_all_tests() {
    echo -e "${BLUE}=== GDST Comprehensive Test Suite ===${NC}"
    echo "Running all test suites..."
    echo ""
    
    init_test_framework
    
    # Run each test suite
    run_basic_tests
    run_advanced_tests
    run_configuration_tests
    run_security_tests
    
    echo -e "${BLUE}=== All Test Suites Complete ===${NC}"
}

# Run specific test suite
run_specific_suite() {
    local suite_name="$1"
    
    case "$suite_name" in
        "basic")
            init_test_framework
            run_basic_tests
            ;;
        "advanced")
            init_test_framework
            run_advanced_tests
            ;;
        "configuration")
            init_test_framework
            run_configuration_tests
            ;;
        "security")
            init_test_framework
            run_security_tests
            ;;
        *)
            echo "Unknown test suite: $suite_name"
            echo "Available suites: basic, advanced, configuration, security"
            exit 1
            ;;
    esac
}

# Performance test function
run_performance_tests() {
    start_test_suite "Performance Tests"
    
    start_test "Performance - Basic project creation time"
    local start_time=$(date +%s.%N)
    
    run_gdst_dry_run "-n perf-test -u testuser"
    
    local end_time=$(date +%s.%N)
    local duration=$(echo "$end_time - $start_time" | bc)
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should complete within reasonable time" &&
       [[ $(echo "$duration < 10" | bc) -eq 1 ]]; then
        pass_test "Basic project creation completed in ${duration}s"
    else
        fail_test "Basic project creation took too long: ${duration}s"
    fi
}

# Stress test function
run_stress_tests() {
    start_test_suite "Stress Tests"
    
    start_test "Stress - Multiple rapid executions"
    local failed_count=0
    
    for i in {1..5}; do
        run_gdst_dry_run "-n stress-test-$i -u testuser" > /dev/null 2>&1
        if [[ $GDST_EXIT_CODE -ne 0 ]]; then
            failed_count=$((failed_count + 1))
        fi
    done
    
    if [[ $failed_count -eq 0 ]]; then
        pass_test "Multiple rapid executions completed successfully"
    else
        fail_test "$failed_count out of 5 executions failed"
    fi
}

# Integration test function
run_integration_tests() {
    start_test_suite "Integration Tests"
    
    start_test "Integration - End-to-end workflow"
    local test_dir=$(create_test_dir "integration-test")
    
    # Setup GitHub mock
    setup_github_mock
    
    run_gdst_dry_run "-n integration-test -u testuser -d $test_dir --verbose"
    
    if assert_exit_code 0 $GDST_EXIT_CODE "Should complete end-to-end workflow" &&
       assert_contains "$GDST_OUTPUT" "Setup Complete!" "Should complete setup" &&
       assert_contains "$GDST_OUTPUT" "Next steps:" "Should provide next steps"; then
        pass_test "End-to-end workflow completed successfully"
    fi
    
    # Cleanup GitHub mock
    remove_github_mock
}

# Show usage information
show_usage() {
    echo "GDST Test Suite Runner"
    echo ""
    echo "Usage: $0 [OPTIONS] [SUITE]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -p, --performance   Run performance tests"
    echo "  -s, --stress        Run stress tests"
    echo "  -i, --integration   Run integration tests"
    echo "  -a, --all           Run all tests (default)"
    echo "  -v, --verbose       Verbose output"
    echo ""
    echo "Test Suites:"
    echo "  basic               Basic functionality tests"
    echo "  advanced            Advanced features tests"
    echo "  configuration       Configuration and templates tests"
    echo "  security            Security and vulnerability tests"
    echo ""
    echo "Examples:"
    echo "  $0                  Run all test suites"
    echo "  $0 basic            Run only basic tests"
    echo "  $0 --performance    Run performance tests"
    echo "  $0 --integration    Run integration tests"
}

# Parse command line arguments
PERFORMANCE_TESTS=false
STRESS_TESTS=false
INTEGRATION_TESTS=false
ALL_TESTS=true
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -p|--performance)
            PERFORMANCE_TESTS=true
            ALL_TESTS=false
            shift
            ;;
        -s|--stress)
            STRESS_TESTS=true
            ALL_TESTS=false
            shift
            ;;
        -i|--integration)
            INTEGRATION_TESTS=true
            ALL_TESTS=false
            shift
            ;;
        -a|--all)
            ALL_TESTS=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        basic|advanced|configuration|security)
            run_specific_suite "$1"
            exit $?
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Run tests based on options
if [[ "$PERFORMANCE_TESTS" == true ]]; then
    init_test_framework
    run_performance_tests
elif [[ "$STRESS_TESTS" == true ]]; then
    init_test_framework
    run_stress_tests
elif [[ "$INTEGRATION_TESTS" == true ]]; then
    init_test_framework
    run_integration_tests
elif [[ "$ALL_TESTS" == true ]]; then
    run_all_tests
fi
