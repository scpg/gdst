# GDST - GitHub Development Setup Tool

🚀 **Automates the creation of GitHub repositories with proper branching strategies, CI/CD pipelines, and development tools.**

## ⚠️ IMPORTANT - Two Different Use Cases

### 👤 **For END USERS** (Creating new projects)
If you want to **create a new project repository**, you use GDST directly:

```bash
# Create a new Node.js project
./gdst.sh -n my-awesome-project -u myusername -t node

# Create a Python project with private visibility
./gdst.sh -n my-python-app -u myusername -t python -V private

# See all options
./gdst.sh --help
```

**DO NOT use the Makefile** - it's not for end users!

### 👨‍💻 **For DEVELOPERS** (Working on GDST itself)
If you want to **contribute to or test the GDST tool**, see the [Contributing](#contributing) section.

---

## Quick Start for End Users

```bash
# Create a new project
./gdst.sh --name my-project --username myuser --type node

# Dry run to see what would be created
./gdst.sh --name test-project --username testuser --dry-run

# See all available options
./gdst.sh --help
```

## ⚙️ Configuration File Support

**GDST supports configuration files for setting default values:**

```bash
# Copy the example configuration file
cp gdst.conf.example gdst.conf

# Edit the configuration file with your defaults
nano gdst.conf

# Now you can run GDST with fewer arguments
./gdst.sh  # Will use values from gdst.conf as defaults
```

**Configuration file features:**
- ✅ Set default values for common parameters
- ✅ Command-line arguments override configuration values
- ✅ Supports all main GDST options
- ✅ Comments and empty lines are ignored
- ✅ Configuration file is automatically ignored by git

## 🎬 Try the Demo First!

**Before running GDST on a real project, try the demo to see what it creates:**

```bash
# Interactive demo - shows the complete workflow and completion message
./demo/demo_completion_message.sh

# Quick demo - shows the completion message without pauses
./demo/demo_quick.sh

# Custom demo with your parameters
./demo/demo_completion_message.sh my-project myusername python
```

The demo shows you exactly what GDST will create and how to use the generated project structure.

## Features

- ✅ Complete project scaffolding for Node.js, Python, Java, and generic projects
- ✅ GitHub repository creation with branch protection
- ✅ CI/CD pipeline setup (GitHub Actions) with branch validation
- ✅ **Automated branch naming validation** with Git hooks
- ✅ **Enterprise-grade GitHub rulesets** with conventional commits
- ✅ **Tag protection and semantic versioning** enforcement
- ✅ **Enhanced branch naming conventions** following industry best practices
- ✅ Development tools configuration (ESLint, Prettier, pre-commit hooks)
- ✅ **Interactive branch creation script** with category selection
- ✅ Helper scripts for feature development and deployment
- ✅ Comprehensive documentation generation
- ✅ Template-based configuration for easy customization

## Project Types Supported

- **node** - Node.js project with package.json, Jest, ESLint, Prettier
- **react** - React project (same as node but with React-specific setup)  
- **python** - Python project with requirements.txt, pytest, black, flake8
- **java** - Java project with Maven pom.xml
- **other** - Generic project with basic structure

## Requirements

- Git installed and configured
- GitHub CLI (gh) installed and authenticated
- Internet connection for GitHub operations
- Node.js (for node/react projects)
- Python 3 (for python projects)
- Java/Maven (for java projects)

## Usage Examples

```bash
# Create a Node.js project
./gdst.sh -n my-node-app -u myusername -t node

# Create a Python project with private visibility
./gdst.sh -n my-python-app -u myusername -t python -V private

# Skip package installation for faster setup
./gdst.sh -n my-project -u myusername --skip-install

# Skip branch protection setup
./gdst.sh -n my-project -u myusername --skip-protection
```

For more detailed information, see `docs/dev_workflow_setup_guide.md`.

## Branch Naming Conventions

This setup includes comprehensive branch naming validation and conventions:

### Supported Branch Categories

- **`feature/`** - New features or enhancements
- **`bugfix/`** - Bug fixes  
- **`hotfix/`** - Critical production fixes
- **`test/`** - Experimental features or testing
- **`chore/`** - Maintenance tasks, refactoring
- **`docs/`** - Documentation updates

### Examples

```bash
# Create branches using the enhanced script
./scripts/new-feature.sh --interactive           # Interactive mode
./scripts/new-feature.sh feature user-login     # Direct mode
./scripts/new-feature.sh bugfix 123-error-fix   # With issue number

# Valid branch names
feature/user-authentication
bugfix/login-error-fix
hotfix/security-patch
feature/123-shopping-cart
docs/api-documentation
```

### Automatic Validation

- **Git Hooks**: Validates branch names before commits and pushes
- **CI/CD Pipeline**: Validates branch names in pull requests
- **Interactive Script**: Guides proper branch creation
- **Documentation**: Complete naming guidelines in `docs/BRANCH_NAMING.md`

### GitHub Repository Rulesets

Modern GitHub rulesets provide enterprise-grade branch protection:

```bash
# Automatic setup during project creation
./gdst.sh -n my-project -u myuser

# Manual ruleset management
./scripts/setup-github-rulesets.sh setup myuser myproject  # Create rulesets
./scripts/setup-github-rulesets.sh list                   # View rulesets
./scripts/setup-github-rulesets.sh delete 12345           # Remove ruleset
```

**Rulesets Created:**
- **Enhanced Branch Protection** - Advanced PR requirements with conventional commits
- **Tag Protection & Semantic Versioning** - Prevents tag deletion, enforces semver
- **Feature Branch Standards** - Commit validation for feature/bugfix/hotfix branches  
- **Development Branch Standards** - Commit validation for test/chore/docs branches

### Advanced Features

**Enterprise-Grade Repository Management:**
- **Conventional Commits Enforcement** - Structured commit messages following industry standards
- **Semantic Versioning** - Automatic tag validation using semver patterns
- **Enhanced PR Requirements** - 2+ approvals, thread resolution, last-push approval
- **Status Check Integration** - CI/CD and branch validation must pass
- **Organization Admin Bypass** - Emergency access controls for critical situations

**Implementation Based on GitHub Best Practices:**
- Templates derived from [GitHub's Official Ruleset Recipes](https://github.com/github/ruleset-recipes)
- Conventional commit patterns supporting all standard types (feat, fix, docs, etc.)
- Semantic versioning regex supporting pre-release and build metadata
- Branch-specific commit validation tailored to workflow types

## Conventional Commits

This setup enforces [Conventional Commits](https://www.conventionalcommits.org/) specification for better project history:

### Supported Commit Types

- **`feat:`** - New features
- **`fix:`** - Bug fixes
- **`docs:`** - Documentation changes
- **`style:`** - Code style changes (formatting, etc.)
- **`refactor:`** - Code refactoring
- **`test:`** - Adding or updating tests
- **`chore:`** - Maintenance tasks
- **`ci:`** - CI/CD changes
- **`build:`** - Build system changes
- **`perf:`** - Performance improvements
- **`revert:`** - Reverting previous commits

### Examples

```bash
# Valid conventional commit messages
feat: add user authentication system
fix: resolve login button styling issue
docs: update API documentation
feat(auth): implement OAuth2 integration
fix(ui): correct mobile responsive layout
chore(deps): update dependency versions
```

### Benefits

- **Automated Changelog Generation** - Tools can parse commit history
- **Semantic Release** - Automatic version bumping based on commit types
- **Better Team Communication** - Clear intent from commit messages
- **Git History Navigation** - Easy to filter by change type

## Credits and References

This project (GDST) was inspired by and builds upon excellent resources from the development community:

- **Branch Naming Conventions**: [Tilburg Science Hub - Naming Git Branches](https://tilburgsciencehub.com/topics/automation/version-control/advanced-git/naming-git-branches/) - Comprehensive guide on Git branch naming best practices
- **GitHub Rulesets**: [GitHub Ruleset Recipes](https://github.com/github/ruleset-recipes) - Official GitHub repository with ruleset examples and patterns

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

### 👨‍💻 **For GDST Developers Only**

If you want to contribute to the GDST tool itself, you'll use the Makefile for development tasks:

#### Development Setup
```bash
# Clone the repository
git clone https://github.com/your-org/gdst.git
cd gdst

# Set up development environment
make setup

# Install development dependencies
make install-deps
```

#### Testing Your Changes
```bash
# Run all tests
make test

# Run specific test suites
make test-basic          # Basic functionality tests
make test-advanced       # Advanced features tests
make test-configuration  # Configuration tests
make test-security       # Security tests

# Quick validation
make validate

# Run performance tests
make test-performance
```

#### Code Quality
```bash
# Run linting
make lint

# Generate coverage report
make coverage

# Clean up test artifacts
make clean
```

#### CI/CD Testing
```bash
# Run CI test suite
make test-ci

# Run tests in Docker
make test-docker
```

### ⚠️ **Important Note**
The Makefile is **ONLY for developers working on the GDST tool itself**. End users who want to create projects should use `./gdst.sh` directly, not the Makefile.

### Development Workflow
1. Fork the repository
2. Create a feature branch
3. Make your changes to `gdst.sh` or related files
4. Run `make test` to ensure everything works
5. Run `make lint` to check code quality
6. Submit a pull request

### Adding New Features
- Add tests for new functionality in the appropriate test suite
- Update documentation in README.md
- Follow the existing code style and patterns
- Ensure all tests pass before submitting

For detailed testing information, see [test/README.md](test/README.md).
