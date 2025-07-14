# GDST - Advanced GitHub Rulesets Documentation

This document explains the enhanced GitHub rulesets implemented in GDST, based on best practices from the official [GitHub Ruleset Recipes](https://github.com/github/ruleset-recipes).

## Overview

The enhanced ruleset system provides enterprise-grade repository management with:

- **Conventional Commits** enforcement
- **Semantic Versioning** for tags
- **Advanced Pull Request** requirements
- **Branch-specific** validation rules
- **Status Check** integration
- **Emergency Bypass** controls

## Rulesets Implemented

### 1. Enhanced Branch Protection

**Targets:** `main`, `dev/main`, `qa/staging`

**Features:**
- **Pull Request Requirements:**
  - 2 required approving reviews
  - Dismiss stale reviews on push
  - Require approval from last push
  - Required review thread resolution
- **Status Checks:**
  - CI/CD validation must pass
  - Branch name validation required
  - Strict policy enforcement
- **Conventional Commits:**
  - Enforces structured commit messages
  - Supports all standard types (feat, fix, docs, etc.)
  - Optional scope and breaking change indicators
- **Protection Rules:**
  - Prevents deletion
  - Prevents force pushes

### 2. Tag Protection & Semantic Versioning

**Targets:** All tags (`~ALL`)

**Features:**
- **Semantic Versioning Enforcement:**
  - Must follow semver pattern: `v1.2.3`
  - Supports pre-release: `v1.2.3-beta.1`
  - Supports build metadata: `v1.2.3+build.123`
- **Tag Protection:**
  - Prevents tag deletion
  - Prevents tag overwriting
- **Release Management:**
  - Ensures consistent versioning
  - Supports automated release workflows

### 3. Feature Branch Standards

**Targets:** `feature/**`, `bugfix/**`, `hotfix/**`

**Features:**
- **Commit Message Patterns:**
  - Enforces branch-appropriate commit types
  - Supports: feat, fix, hotfix, docs, style, refactor, test, chore
  - Optional scope: `feat(auth): add login`
  - Length validation (1-50 characters)
- **Status Checks:**
  - Branch name validation required
  - Non-strict policy for flexibility
- **Update Protection:**
  - Allows updates while enforcing standards

### 4. Development Branch Standards

**Targets:** `test/**`, `chore/**`, `docs/**`

**Features:**
- **Specialized Commit Patterns:**
  - Enforces development-specific types
  - Supports: test, chore, docs
  - Scope and description validation
- **Branch Validation:**
  - Ensures proper naming conventions
  - Flexible status check policy
- **Development Workflow:**
  - Optimized for maintenance tasks
  - Documentation updates
  - Testing and experimentation

## Conventional Commits Specification

### Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types

| Type | Description | Example |
|------|-------------|---------|
| `feat` | New feature | `feat: add user registration` |
| `fix` | Bug fix | `fix: resolve login validation error` |
| `docs` | Documentation | `docs: update API documentation` |
| `style` | Code style | `style: format code with prettier` |
| `refactor` | Code refactoring | `refactor: extract user service` |
| `test` | Testing | `test: add unit tests for auth` |
| `chore` | Maintenance | `chore: update dependencies` |
| `ci` | CI/CD changes | `ci: add automated testing` |
| `build` | Build system | `build: configure webpack` |
| `perf` | Performance | `perf: optimize database queries` |
| `revert` | Revert changes | `revert: undo feature X` |

### Scopes (Optional)

```bash
feat(auth): implement OAuth2
fix(ui): correct mobile layout
docs(api): add endpoint documentation
```

### Breaking Changes

```bash
feat!: remove deprecated API endpoints
feat(api)!: change user schema structure
```

## Semantic Versioning

### Version Format

```
MAJOR.MINOR.PATCH[-PRERELEASE][+BUILD]
```

### Examples

```bash
v1.0.0          # Initial release
v1.0.1          # Patch release
v1.1.0          # Minor release
v2.0.0          # Major release
v1.0.0-alpha.1  # Pre-release
v1.0.0+build.1  # With build metadata
```

### Version Bumping Rules

- **PATCH** (`v1.0.1`): Bug fixes, chore updates
- **MINOR** (`v1.1.0`): New features, backwards compatible
- **MAJOR** (`v2.0.0`): Breaking changes, API changes

## Status Checks Integration

### Required Checks

1. **CI/CD Validation** (`ci-cd-validation`)
   - Automated tests must pass
   - Build process successful
   - Code quality checks

2. **Branch Name Validation** (`branch-name-validation`)
   - Enforces naming conventions
   - Validates branch structure
   - Ensures proper categorization

### Configuration

Add to your GitHub Actions workflow:

```yaml
name: Repository Validation
on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Validate Branch Name
        run: ./scripts/validate-branch-name.sh
      - name: Run Tests
        run: npm test  # or pytest, mvn test, etc.
```

## Emergency Bypass Controls

### Organization Admin Bypass

- **Who:** Organization administrators
- **When:** Emergency situations
- **Mode:** Always available
- **Use Cases:**
  - Critical security patches
  - Emergency hotfixes
  - Repository maintenance

### Best Practices

1. **Document Bypasses:** Always log why bypass was used
2. **Temporary Use:** Remove bypass after emergency
3. **Review Process:** Follow up with proper PR when possible
4. **Team Communication:** Notify team of bypass usage

## Configuration Options

### Customizing Rulesets

Edit the setup script variables:

```bash
# Enable/disable features
ENABLE_CONVENTIONAL_COMMITS=true
ENABLE_TAG_PROTECTION=true
ENABLE_SEMANTIC_VERSIONING=true

# Adjust requirements
REQUIRED_REVIEW_COUNT=2
ENABLE_ENHANCED_FEATURES=true
```

### Project-Specific Adjustments

1. **Review Requirements:** Adjust based on team size
2. **Status Checks:** Add project-specific checks
3. **Commit Patterns:** Modify for organizational standards
4. **Bypass Actors:** Configure based on team structure

## Migration Guide

### From Basic to Enhanced Rulesets

1. **Backup Current Settings:**
   ```bash
   ./scripts/setup-github-rulesets.sh list > current-rulesets.txt
   ```

2. **Update Ruleset Script:**
   ```bash
   # Replace old template with enhanced version
   cp templates/scripts/setup-github-rulesets.sh.template scripts/
   ```

3. **Apply New Rulesets:**
   ```bash
   ./scripts/setup-github-rulesets.sh setup username repo
   ```

4. **Update Team Documentation:**
   - Train team on conventional commits
   - Update contribution guidelines
   - Provide commit message examples

### Team Adoption Strategy

1. **Phase 1:** Enable warnings only
2. **Phase 2:** Enforce on new branches
3. **Phase 3:** Full enforcement
4. **Phase 4:** Add advanced features

## Troubleshooting

### Common Issues

1. **Status Check Failures:**
   - Ensure CI/CD workflow exists
   - Check branch name validation script
   - Verify required contexts

2. **Commit Message Rejection:**
   - Review conventional commit format
   - Check type spelling and case
   - Validate scope syntax

3. **Tag Creation Blocked:**
   - Verify semantic version format
   - Check for existing tags
   - Ensure proper version increment

### Support Commands

```bash
# List current rulesets
./scripts/setup-github-rulesets.sh list

# Validate branch name locally
./scripts/validate-branch-name.sh

# Test commit message format
echo "feat: test message" | grep -E "^(feat|fix|docs).*"
```

## Additional Resources

- [Conventional Commits Specification](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
- [GitHub Rulesets Documentation](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets)
- [GitHub Ruleset Recipes](https://github.com/github/ruleset-recipes)
