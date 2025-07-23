#!/bin/bash

# Bats Test Runner Script
# Provides convenient commands for running bats tests

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BATS_CMD="$SCRIPT_DIR/bats/bin/bats"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

usage() {
    echo "Bats Test Runner for GDST"
    echo
    echo "Usage: $0 [OPTIONS] [TEST_FILES...]"
    echo
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -v, --verbose  Run tests with verbose output"
    echo "  -t, --tap      Output in TAP format"
    echo "  -a, --all      Run all bats tests"
    echo "  -e, --example  Run example test"
    echo "  -c, --count    Count total tests"
    echo
    echo "Examples:"
    echo "  $0 -e                    # Run example test"
    echo "  $0 -a                    # Run all bats tests"
    echo "  $0 -v test/basic.bats    # Run specific test with verbose output"
    echo "  $0 -t test/*.bats        # Run all tests with TAP output"
    echo
    echo "Migration Commands:"
    echo "  $0 --migrate-help        # Show migration help"
    echo "  $0 --compare-frameworks  # Compare test frameworks"
}

show_migration_help() {
    echo -e "${YELLOW}Bats Migration Help${NC}"
    echo
    echo "To migrate from custom framework to bats:"
    echo
    echo "1. Study the example test:"
    echo "   $0 -e"
    echo
    echo "2. Read the migration guide:"
    echo "   cat docs/BATS_MIGRATION_GUIDE.md"
    echo
    echo "3. Compare frameworks:"
    echo "   $0 --compare-frameworks"
    echo
    echo "4. Start with one test file:"
    echo "   cp test/test_basic.sh test/test_basic.bats"
    echo "   # Edit test_basic.bats to use bats format"
    echo "   $0 test/test_basic.bats"
}

compare_frameworks() {
    echo -e "${YELLOW}Framework Comparison${NC}"
    echo
    echo "Custom Framework (current):"
    echo "  • Total tests: 49"
    echo "  • Test files: 4"
    echo "  • Format: Custom shell functions"
    echo "  • Output: Custom reporting"
    echo
    echo "Bats Framework (target):"
    echo "  • Industry standard"
    echo "  • TAP compliant output"
    echo "  • Rich assertion helpers"
    echo "  • Better CI/CD integration"
    echo
    echo "Run both frameworks:"
    echo "  Custom: ./test/test_all.sh"
    echo "  Bats:   $0 -a"
}

count_tests() {
    echo -e "${YELLOW}Test Count Summary${NC}"
    echo
    echo "Custom Framework Tests:"
    find test -name "test_*.sh" -not -name "test_all.sh" -not -name "test_framework.sh" | while read -r file; do
        count=$(grep -c "start_test" "$file" 2>/dev/null || echo "0")
        echo "  $(basename "$file"): $count tests"
    done
    
    echo
    echo "Bats Framework Tests:"
    find test -name "*.bats" | while read -r file; do
        count=$(grep -c "^@test" "$file" 2>/dev/null || echo "0")
        echo "  $(basename "$file"): $count tests"
    done
}

# Check if bats is available
if [ ! -f "$BATS_CMD" ]; then
    echo -e "${RED}Error: Bats not found at $BATS_CMD${NC}" >&2
    echo "Please ensure bats-core is installed in test/bats/" >&2
    exit 1
fi

# Parse command line arguments
VERBOSE=false
TAP=false
RUN_ALL=false
RUN_EXAMPLE=false
SHOW_COUNT=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -t|--tap)
            TAP=true
            shift
            ;;
        -a|--all)
            RUN_ALL=true
            shift
            ;;
        -e|--example)
            RUN_EXAMPLE=true
            shift
            ;;
        -c|--count)
            SHOW_COUNT=true
            shift
            ;;
        --migrate-help)
            show_migration_help
            exit 0
            ;;
        --compare-frameworks)
            compare_frameworks
            exit 0
            ;;
        -*)
            echo -e "${RED}Error: Unknown option $1${NC}" >&2
            usage
            exit 1
            ;;
        *)
            break
            ;;
    esac
done

# Handle special commands
if [ "$SHOW_COUNT" = true ]; then
    count_tests
    exit 0
fi

# Build bats command arguments
BATS_ARGS=()

if [ "$VERBOSE" = true ]; then
    BATS_ARGS+=(--verbose)
fi

if [ "$TAP" = true ]; then
    BATS_ARGS+=(--tap)
fi

# Determine what tests to run
if [ "$RUN_EXAMPLE" = true ]; then
    TEST_FILES=("test/test_example.bats")
elif [ "$RUN_ALL" = true ]; then
    TEST_FILES=(test/*.bats)
elif [ $# -gt 0 ]; then
    TEST_FILES=("$@")
else
    echo -e "${YELLOW}No test files specified. Use -h for help.${NC}"
    exit 1
fi

# Check if test files exist
for file in "${TEST_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "${RED}Error: Test file '$file' not found${NC}" >&2
        exit 1
    fi
done

# Run the tests
echo -e "${GREEN}Running bats tests...${NC}"
echo "Command: $BATS_CMD ${BATS_ARGS[*]} ${TEST_FILES[*]}"
echo

"$BATS_CMD" "${BATS_ARGS[@]}" "${TEST_FILES[@]}"
exit_code=$?

# Show summary
if [ $exit_code -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
else
    echo -e "${RED}✗ Some tests failed.${NC}"
fi

exit $exit_code
