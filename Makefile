# GDST Makefile - FOR DEVELOPERS ONLY
# =====================================
# 
# ⚠️  IMPORTANT: This Makefile is FOR GDST DEVELOPERS ONLY
# 
# If you want to CREATE a new project repository using GDST:
#   DO NOT USE THIS MAKEFILE
#   Instead run: ./gdst.sh -n your-project -u your-username -t project-type
# 
# This Makefile is only for:
# - Testing the GDST tool during development
# - Code quality checks and linting
# - CI/CD integration for the GDST project itself
# - Contributing to the GDST project
# 
# End users should NEVER need to run 'make' commands!
# =====================================================

# Color definitions sourced from constants.sh
# Using hardcoded values to maintain compatibility with Make's shell execution
RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[1;33m
BLUE=\033[0;34m
MAGENTA=\033[0;35m
CYAN=\033[0;36m
WHITE=\033[1;37m
BOLD=\033[1m
NC=\033[0m

# Note: These values are synchronized with constants.sh
# If you modify colors in constants.sh, update these values accordingly

.PHONY: test test-basic test-advanced test-configuration test-security test-performance test-stress test-integration test-ci clean help warning check-permission

# Default target
all: check-permission warning test

# Security check - requires explicit permission flag
check-permission:
	@if [ "$(GDST_DEVELOPER_MODE)" != "true" ]; then \
		echo ""; \
		echo "$(RED)🛑 GDST MAKEFILE EXECUTION BLOCKED$(NC)"; \
		echo "$(RED)=====================================$(NC)"; \
		echo ""; \
		echo "$(YELLOW)This Makefile is FOR GDST DEVELOPERS ONLY!$(NC)"; \
		echo ""; \
		echo "$(CYAN)If you want to CREATE a new project repository:$(NC)"; \
		echo "$(CYAN)  DO NOT use this Makefile$(NC)"; \
		echo "$(CYAN)  Instead run: $(WHITE)./gdst.sh -n your-project -u your-username -t project-type$(NC)"; \
		echo ""; \
		echo "$(MAGENTA)If you are a GDST developer and want to run tests:$(NC)"; \
		echo "$(MAGENTA)  Set the developer mode flag:$(NC)"; \
		echo "$(GREEN)  make GDST_DEVELOPER_MODE=true <target>$(NC)"; \
		echo ""; \
		echo "$(BOLD)Examples:$(NC)"; \
		echo "$(GREEN)  make GDST_DEVELOPER_MODE=true test$(NC)"; \
		echo "$(GREEN)  make GDST_DEVELOPER_MODE=true test-basic$(NC)"; \
		echo "$(GREEN)  make GDST_DEVELOPER_MODE=true help$(NC)"; \
		echo ""; \
		echo "$(BLUE)This safety mechanism prevents accidental execution by end users.$(NC)"; \
		echo ""; \
		exit 1; \
	fi

# Warning for developers (only shown after permission check passes)
warning:
	@echo ""
	@echo "$(GREEN)✅ GDST Developer Mode Enabled$(NC)"
	@echo "$(GREEN)==============================$(NC)"
	@echo ""
	@echo "$(CYAN)You are running the GDST development Makefile.$(NC)"
	@echo "$(CYAN)This is intended for developers working on the GDST tool itself.$(NC)"
	@echo ""

# Run all tests
test: check-permission
	@echo "$(BLUE)Running all GDST tests...$(NC)"
	@./test/run_tests.sh

# Run specific test suites
test-basic: check-permission
	@echo "$(BLUE)Running basic functionality tests...$(NC)"
	@./test/run_tests.sh basic

test-advanced: check-permission
	@echo "$(BLUE)Running advanced features tests...$(NC)"
	@./test/run_tests.sh advanced

test-configuration: check-permission
	@echo "$(BLUE)Running configuration tests...$(NC)"
	@./test/run_tests.sh configuration

test-security: check-permission
	@echo "$(BLUE)Running security tests...$(NC)"
	@./test/run_tests.sh security

# Run performance and stress tests
test-performance: check-permission
	@echo "$(MAGENTA)Running performance tests...$(NC)"
	@./test/run_tests.sh --performance

test-stress: check-permission
	@echo "$(MAGENTA)Running stress tests...$(NC)"
	@./test/run_tests.sh --stress

test-integration: check-permission
	@echo "$(MAGENTA)Running integration tests...$(NC)"
	@./test/run_tests.sh --integration

# Run CI tests
test-ci: check-permission
	@echo "$(CYAN)Running CI test suite...$(NC)"
	@./test/ci_test.sh

# Clean up test artifacts
clean: check-permission
	@echo "$(YELLOW)Cleaning up test artifacts...$(NC)"
	@rm -rf /tmp/gdst-test-results
	@rm -rf /tmp/gdst-ci-results
	@rm -rf /tmp/gdst-test-temp
	@echo "$(GREEN)Test artifacts cleaned up$(NC)"

# Run shellcheck on all scripts
lint: check-permission
	@echo "$(CYAN)Running shellcheck on all scripts...$(NC)"
	@if command -v shellcheck >/dev/null 2>&1; then \
		shellcheck gdst.sh; \
		find . -name "*.sh" -path "./test/*" -exec shellcheck {} \; ; \
		echo "$(GREEN)Shellcheck completed$(NC)"; \
	else \
		echo "$(RED)Shellcheck not installed. Install with: sudo apt-get install shellcheck$(NC)"; \
	fi

# Generate test coverage report (if coverage tools are available)
coverage: check-permission
	@echo "$(MAGENTA)Generating test coverage report...$(NC)"
	@if command -v kcov >/dev/null 2>&1; then \
		mkdir -p coverage; \
		kcov --include-pattern=gdst.sh coverage ./test/run_tests.sh; \
		echo "$(GREEN)Coverage report generated in coverage/$(NC)"; \
	else \
		echo "$(RED)kcov not installed. Install with: sudo apt-get install kcov$(NC)"; \
	fi

# Setup development environment
setup: check-permission
	@echo "$(CYAN)Setting up development environment...$(NC)"
	@chmod +x gdst.sh
	@chmod +x test/*.sh
	@echo "$(GREEN)Development environment setup complete$(NC)"

# Quick validation (basic tests only)
validate: check-permission
	@echo "$(BLUE)Running quick validation...$(NC)"
	@./test/run_tests.sh basic

# Install dependencies for testing
install-deps: check-permission
	@echo "$(CYAN)Installing test dependencies...$(NC)"
	@if command -v apt-get >/dev/null 2>&1; then \
		sudo apt-get update; \
		sudo apt-get install -y git curl bc xmlstarlet shellcheck; \
	elif command -v yum >/dev/null 2>&1; then \
		sudo yum install -y git curl bc xmlstarlet ShellCheck; \
	elif command -v brew >/dev/null 2>&1; then \
		brew install git curl bc xmlstarlet shellcheck; \
	else \
		echo "$(RED)Package manager not supported. Please install manually:$(NC)"; \
		echo "$(YELLOW)  - git, curl, bc, xmlstarlet, shellcheck$(NC)"; \
	fi
	@echo "$(GREEN)Dependencies installed$(NC)"

# Run tests in Docker (if Docker is available)
test-docker: check-permission
	@echo "$(CYAN)Running tests in Docker...$(NC)"
	@if command -v docker >/dev/null 2>&1; then \
		docker run --rm -v $(PWD):/workspace ubuntu:latest /bin/bash -c "\
			cd /workspace && \
			apt-get update && \
			apt-get install -y git curl bc xmlstarlet shellcheck && \
			chmod +x gdst.sh test/*.sh && \
			./test/run_tests.sh"; \
	else \
		echo "$(RED)Docker not installed. Please install Docker to run tests in container.$(NC)"; \
	fi

# Create test report
report: check-permission
	@echo "$(MAGENTA)Generating test report...$(NC)"
	@./test/run_tests.sh > test-report.txt 2>&1
	@echo "$(GREEN)Test report generated: test-report.txt$(NC)"

# Help target (accessible without permission check)
help:
	@echo "$(BOLD)$(BLUE)GDST Makefile Help - FOR DEVELOPERS ONLY$(NC)"
	@echo "$(BLUE)========================================$(NC)"
	@echo ""
	@echo "$(RED)🛑 MAKEFILE EXECUTION REQUIRES PERMISSION FLAG$(NC)"
	@echo ""
	@echo "$(YELLOW)This Makefile is FOR GDST DEVELOPERS ONLY!$(NC)"
	@echo ""
	@echo "$(CYAN)If you want to CREATE a new project repository:$(NC)"
	@echo "$(CYAN)  DO NOT use this Makefile$(NC)"
	@echo "$(CYAN)  Instead run: $(WHITE)./gdst.sh -n your-project -u your-username -t project-type$(NC)"
	@echo ""
	@echo "$(MAGENTA)If you are a GDST developer and want to run tests:$(NC)"
	@echo "$(MAGENTA)  Set the developer mode flag:$(NC)"
	@echo "$(GREEN)  make GDST_DEVELOPER_MODE=true <target>$(NC)"
	@echo ""
	@echo "$(BOLD)Available targets for GDST development:$(NC)"
	@echo "$(GREEN)  test              $(NC)Run all tests (default)"
	@echo "$(GREEN)  test-basic        $(NC)Run basic functionality tests"
	@echo "$(GREEN)  test-advanced     $(NC)Run advanced features tests"
	@echo "$(GREEN)  test-configuration$(NC)Run configuration tests"
	@echo "$(GREEN)  test-security     $(NC)Run security tests"
	@echo "$(MAGENTA)  test-performance  $(NC)Run performance tests"
	@echo "$(MAGENTA)  test-stress       $(NC)Run stress tests"
	@echo "$(MAGENTA)  test-integration  $(NC)Run integration tests"
	@echo "$(CYAN)  test-ci           $(NC)Run CI test suite"
	@echo "$(CYAN)  test-docker       $(NC)Run tests in Docker container"
	@echo "$(YELLOW)  clean             $(NC)Clean up test artifacts"
	@echo "$(CYAN)  lint              $(NC)Run shellcheck on all scripts"
	@echo "$(MAGENTA)  coverage          $(NC)Generate test coverage report"
	@echo "$(CYAN)  setup             $(NC)Setup development environment"
	@echo "$(BLUE)  validate          $(NC)Quick validation (basic tests)"
	@echo "$(CYAN)  install-deps      $(NC)Install test dependencies"
	@echo "$(MAGENTA)  report            $(NC)Generate test report"
	@echo "$(BLUE)  help              $(NC)Show this help message"
	@echo ""
	@echo "$(BOLD)Examples for GDST development:$(NC)"
	@echo "$(GREEN)  make GDST_DEVELOPER_MODE=true test$(NC)"
	@echo "$(GREEN)  make GDST_DEVELOPER_MODE=true test-basic$(NC)"
	@echo "$(YELLOW)  make GDST_DEVELOPER_MODE=true clean$(NC)"
	@echo "$(CYAN)  make GDST_DEVELOPER_MODE=true lint$(NC)"
	@echo ""
	@echo "$(CYAN)For end users wanting to create projects:$(NC)"
	@echo "$(WHITE)  ./gdst.sh --help  $(NC)# See how to use GDST"
