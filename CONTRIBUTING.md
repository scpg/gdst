# Contributing to GDST

Thank you for your interest in contributing to the GDST (GitHub Development Setup Tool)!

## ⚠️ IMPORTANT - Understanding the Difference

### 👤 **End Users vs. 👨‍💻 Developers**

**If you want to CREATE a new project repository:**
- You are an **end user**
- Use `./gdst.sh` directly
- **DO NOT use the Makefile**
- See the main [README.md](README.md) for usage instructions

**If you want to CONTRIBUTE to the GDST tool itself:**
- You are a **developer**
- Use the Makefile for development tasks
- Continue reading this guide

## Development Setup

### Prerequisites
- Bash 4.0 or higher
- Git
- GitHub CLI (`gh`) installed and authenticated
- curl (for testing)

### Getting Started

1. **Fork and clone the repository**
   ```bash
   git clone https://github.com/your-username/gdst.git
   cd gdst
   ```

2. **Set up development environment**
   ```bash
   make GDST_DEVELOPER_MODE=true setup
   ```

3. **Install development dependencies**
   ```bash
   make GDST_DEVELOPER_MODE=true install-deps
   ```

## 🔒 **Security Feature**

The Makefile is protected with a security mechanism that requires the `GDST_DEVELOPER_MODE=true` flag to execute any commands (except `help`). This prevents accidental execution by end users who might run `make` commands by mistake.

## Development Workflow

### Testing Your Changes

**Always test your changes before submitting:**

```bash
# Run all tests (recommended)
make GDST_DEVELOPER_MODE=true test

# Run specific test suites
make GDST_DEVELOPER_MODE=true test-basic          # Basic functionality
make GDST_DEVELOPER_MODE=true test-advanced       # Advanced features
make GDST_DEVELOPER_MODE=true test-configuration  # Configuration handling
make GDST_DEVELOPER_MODE=true test-security       # Security features

# Quick validation (fastest)
make GDST_DEVELOPER_MODE=true validate
```

### Code Quality

```bash
# Run linting with shellcheck
make GDST_DEVELOPER_MODE=true lint

# Generate test coverage report
make GDST_DEVELOPER_MODE=true coverage

# Clean up test artifacts
make GDST_DEVELOPER_MODE=true clean
```

### Performance Testing

```bash
# Run performance tests
make GDST_DEVELOPER_MODE=true test-performance

# Run stress tests
make GDST_DEVELOPER_MODE=true test-stress

# Run integration tests
make GDST_DEVELOPER_MODE=true test-integration
```

## Makefile Commands Reference

### Test Commands
- `make GDST_DEVELOPER_MODE=true test` - Run all test suites
- `make GDST_DEVELOPER_MODE=true test-basic` - Basic functionality tests
- `make GDST_DEVELOPER_MODE=true test-advanced` - Advanced features tests
- `make GDST_DEVELOPER_MODE=true test-configuration` - Configuration tests
- `make GDST_DEVELOPER_MODE=true test-security` - Security tests
- `make GDST_DEVELOPER_MODE=true test-performance` - Performance tests
- `make GDST_DEVELOPER_MODE=true test-stress` - Stress tests
- `make GDST_DEVELOPER_MODE=true test-integration` - Integration tests
- `make GDST_DEVELOPER_MODE=true test-ci` - CI/CD test suite
- `make GDST_DEVELOPER_MODE=true test-docker` - Run tests in Docker container
- `make GDST_DEVELOPER_MODE=true validate` - Quick validation (basic tests only)

### Development Commands
- `make GDST_DEVELOPER_MODE=true setup` - Set up development environment
- `make GDST_DEVELOPER_MODE=true lint` - Run shellcheck on all scripts
- `make GDST_DEVELOPER_MODE=true coverage` - Generate test coverage report
- `make GDST_DEVELOPER_MODE=true clean` - Clean up test artifacts
- `make GDST_DEVELOPER_MODE=true install-deps` - Install test dependencies
- `make GDST_DEVELOPER_MODE=true report` - Generate test report
- `make help` - Show available commands (no flag required)

## Contributing Guidelines

### 1. Code Style
- Follow existing bash scripting conventions
- Use meaningful variable names
- Add comments for complex logic
- Maintain consistent indentation (2 spaces)

### 2. Testing
- **All changes must include tests**
- Add tests to the appropriate test suite:
  - `test/test_basic.sh` - Basic functionality
  - `test/test_advanced.sh` - Advanced features
  - `test/test_configuration.sh` - Configuration handling
  - `test/test_security.sh` - Security features
- Ensure all tests pass: `make test`
- Run security tests: `make test-security`

### 3. Documentation
- Update README.md for user-facing changes
- Update this CONTRIBUTING.md for development changes
- Add comments to complex code sections
- Update help text in gdst.sh if needed

### 4. Security
- Run security tests: `make test-security`
- Follow secure coding practices
- Validate all user inputs
- Avoid command injection vulnerabilities

### 5. Pull Request Process
1. Create a feature branch from `main`
2. Make your changes
3. Add/update tests as needed
4. Run `make test` to ensure everything works
5. Run `make lint` to check code quality
6. Update documentation if necessary
7. Submit a pull request with a clear description

## Test Framework

The project uses a comprehensive test framework located in the `test/` directory:

- **`test_framework.sh`** - Core testing utilities
- **`test_basic.sh`** - Basic functionality tests
- **`test_advanced.sh`** - Advanced features tests
- **`test_configuration.sh`** - Configuration tests
- **`test_security.sh`** - Security tests
- **`run_tests.sh`** - Master test runner
- **`ci_test.sh`** - CI/CD optimized runner

For detailed testing information, see [test/README.md](test/README.md).

## Common Development Tasks

### Adding a New Feature
1. Create tests for the new feature
2. Implement the feature in `gdst.sh`
3. Update templates if needed
4. Run tests: `make test`
5. Update documentation
6. Submit pull request

### Fixing a Bug
1. Create a test that reproduces the bug
2. Fix the bug in the code
3. Ensure the test now passes
4. Run full test suite: `make test`
5. Submit pull request

### Improving Security
1. Add security tests in `test/test_security.sh`
2. Implement security improvements
3. Run security tests: `make test-security`
4. Run all tests: `make test`
5. Submit pull request

## Debugging

### Test Failures
1. Check test output in `/tmp/gdst-test-results/test_run.log`
2. Run specific failing test: `make test-basic` (or appropriate suite)
3. Use verbose mode: `./test/run_tests.sh --verbose`
4. Check for permissions issues or missing dependencies

### Script Issues
1. Run with dry-run mode: `./gdst.sh -n test -u test --dry-run`
2. Use verbose mode: `./gdst.sh -n test -u test --verbose --dry-run`
3. Check shellcheck output: `make lint`

## Continuous Integration

The project uses GitHub Actions for CI/CD:
- All tests run automatically on push/PR
- Security scans are performed
- Performance tests validate changes
- Docker tests ensure cross-platform compatibility

## Getting Help

- Check the [main README.md](README.md) for user documentation
- Review existing tests for examples
- Look at the test framework documentation in [test/README.md](test/README.md)
- Create an issue for questions or bug reports

## Code of Conduct

Please be respectful and professional in all interactions. This project follows standard open-source community guidelines.

## License

By contributing to this project, you agree that your contributions will be licensed under the MIT License.

---

## Remember

**The Makefile is for GDST developers only!** End users should use `./gdst.sh` directly to create their projects. This distinction is crucial for proper project usage.
