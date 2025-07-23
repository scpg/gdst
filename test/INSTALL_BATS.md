# Bats-Core Installation Notes

## Quick Setup

The bats-core testing framework dependencies are not included in the repository to avoid submodule complexity. To set up the testing environment:

```bash
# Install bats-core and helpers
git clone https://github.com/bats-core/bats-core.git test/bats
git clone https://github.com/bats-core/bats-support.git test/bats-support
git clone https://github.com/bats-core/bats-assert.git test/bats-assert

# Make runner executable
chmod +x test/run_bats.sh

# Test the installation
./test/run_bats.sh -e
```

## Verify Installation

After installation, you should see:
- `test/bats/bin/bats` - Main bats executable
- `test/bats-support/` - Helper functions
- `test/bats-assert/` - Assertion helpers
- `test/test_example.bats` - Working example tests

## Usage

```bash
# Run example tests
./test/run_bats.sh -e

# Run with verbose output
./test/run_bats.sh -v test/test_example.bats

# Get help
./test/run_bats.sh --help
```

The bats directories are in .gitignore to prevent git submodule complications while keeping the migration infrastructure available.
