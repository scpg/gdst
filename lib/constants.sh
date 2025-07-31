#!/usr/bin/env bash

# Script directories - export for use in other scripts (only set if not already set)
if [[ -z "${SCRIPT_DIR}" ]]; then
    export SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi
if [[ -z "${SCRIPT_FIX_NAME}" ]]; then
    export SCRIPT_FIX_NAME="$(basename "$0")"
fi

# Test directory
export TEST_DIR="${TEST_DIR:-$SCRIPT_DIR/test}"

# Demo directory
export DEMO_DIR="${DEMO_DIR:-$SCRIPT_DIR/demo}"

# Colors (exported for use in other scripts)
export RED='\033[0;31m'
export YELLOW='\033[1;33m'
export GREEN='\033[0;32m'
export BLUE='\033[0;34m'
export MAGENTA='\033[0;35m'
export CYAN='\033[0;36m'
export WHITE='\033[1;37m'
export BOLD='\033[1m'
export NC='\033[0m' # No Color

# Default configuration values
export DEFAULT_PROJECT_TYPE="node"
export DEFAULT_BRANCH="main"
export DEFAULT_LICENSE="MIT"



