# GDST - GitHub Development Setup Tool

This directory contains a comprehensive development workflow setup script that automates the creation of GitHub repositories with proper branching strategies, CI/CD pipelines, and development tools.

## Contents

- `gdst.sh` - Main setup script
- `template_utils.sh` - Template processing utilities
- `templates/` - Directory containing all template files
- `docs/dev_workflow_setup_guide.md` - Detailed setup guide
- `test_dev_workflow.sh` - Test script

## Quick Start

```bash
# Interactive mode (recommended for first use)
./gdst.sh

# Non-interactive mode
./gdst.sh --name my-project --username myuser --type node --non-interactive

# Dry run to see what would be created
./gdst.sh --name test-project --username testuser --dry-run --non-interactive
```

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
./gdst.sh -n my-node-app -u myusername -t node --non-interactive

# Create a Python project with private visibility
./gdst.sh -n my-python-app -u myusername -t python -v private --non-interactive

# Skip package installation for faster setup
./gdst.sh -n my-project -u myusername --skip-install --non-interactive

# Skip branch protection setup
./gdst.sh -n my-project -u myusername --skip-protection --non-interactive
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
./gdst.sh -n my-project -u myuser --non-interactive

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
