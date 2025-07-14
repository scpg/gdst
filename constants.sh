#!/usr/bin/env bash
SCRIPT_DIR="${SCRIPT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
SCRIPT_FIX_NAME="${SCRIPT_FIX_NAME:-$(basename "$0")}"

# Test directory
TEST_DIR="${TEST_DIR:-$SCRIPT_DIR/test}"

# Demo directory
DEMO_DIR="${DEMO_DIR:-$SCRIPT_DIR/demo}"

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



