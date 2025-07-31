#!/bin/bash

# Generate JUnit XML fallback for CI when main tests fail
# This ensures we always have some test results for GitHub Actions

RESULTS_DIR="/tmp/gdst-ci-results"
JUNIT_DIR="$RESULTS_DIR/junit"

# Create directories
mkdir -p "$JUNIT_DIR"

# Generate basic JUnit XML with current test status
generate_junit_xml() {
    local xml_file="$JUNIT_DIR/fallback-results.xml"
    
    cat > "$xml_file" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<testsuites>
  <testsuite name="GDST Test Suite" tests="1" failures="1" errors="0" skipped="0" time="0">
    <testcase name="GitHub Actions CI Test" classname="GDST" time="0">
      <failure message="Test execution failed in CI environment" type="failure">
        Tests failed to complete successfully in GitHub Actions environment.
        This is likely due to missing dependencies or environment setup issues.
        Check the workflow logs for more details.
      </failure>
    </testcase>
  </testsuite>
</testsuites>
EOF
    
    echo "Generated fallback JUnit XML: $xml_file"
}

# Generate summary
generate_summary() {
    local summary_file="$RESULTS_DIR/summary.txt"
    
    cat > "$summary_file" << EOF
GDST Test Suite - CI Execution Summary
=====================================

Status: FAILED
Environment: GitHub Actions (ubuntu-latest)
Timestamp: $(date)

Issue: Main test suite failed to complete successfully.
Cause: Tests appear to be designed for interactive/local execution.
Action Required: Review test suite for CI compatibility.

Note: This is a fallback report generated when the main test suite fails.
EOF
    
    echo "Generated summary: $summary_file"
}

# Main execution
echo "Generating fallback test results for CI..."
generate_junit_xml
generate_summary
echo "Fallback test results generated successfully."
