# Centralized Color Definitions

This document describes the centralized color definition system implemented in GDST.

## Overview

All color definitions are now centralized in `constants.sh` to eliminate code duplication and improve maintainability.

## Color Definitions

The following colors are defined in `constants.sh`:

```bash
# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color
```

## Files Using Centralized Colors

### 1. `dev_aliases.sh`
- **Method**: Sources `constants.sh` directly
- **Usage**: `source "$SCRIPT_DIR/constants.sh"`

### 2. `test/test_framework.sh`
- **Method**: Sources `constants.sh` directly
- **Usage**: `source "$GDST_SCRIPT_DIR/constants.sh"`

### 3. `Makefile`
- **Method**: Uses hardcoded values synchronized with `constants.sh`
- **Reason**: Make doesn't support bash variable sourcing reliably
- **Note**: Values must be manually synchronized if `constants.sh` changes

## Files With Independent Color Definitions

### Templates
The following template files maintain their own color definitions because they are meant to be standalone files copied into generated projects:

- `templates/scripts/validate-branch-name.sh.template`
- `templates/project-configs/pre-push.template`
- `templates/project-configs/pre-commit-branch-check.template`
- `templates/scripts/new-feature.sh.template`
- `templates/scripts/setup-github-rulesets.sh.template`

This is intentional and correct since these files need to be self-contained.

## Benefits

1. **Maintainability**: Single source of truth for color definitions
2. **Consistency**: All development tools use the same color scheme
3. **Efficiency**: No duplicate code across multiple files
4. **Flexibility**: Easy to modify colors in one place

## Usage Guidelines

### For Bash Scripts
```bash
# Source colors from constants.sh
source "$SCRIPT_DIR/constants.sh"

# Use colors
echo -e "${GREEN}Success!${NC}"
echo -e "${RED}Error!${NC}"
```

### For Makefile
```makefile
# Colors are hardcoded but synchronized with constants.sh
@echo "$(GREEN)Success!$(NC)"
@echo "$(RED)Error!$(NC)"
```

## Maintenance

When modifying colors in `constants.sh`, ensure:
1. Update `Makefile` color definitions to match
2. Test all tools to ensure colors display correctly
3. Templates remain unchanged (they need independent definitions)
