# GDST - Development Workflow Setup Script - Quick Reference

## 🚀 **Enhanced Features Added**

The `gdst.sh` script provides comprehensive command-line options for automated development workflow setup.

## 🎬 **Try the Demo First!**

**Before using GDST on a real project, explore the demo to understand what it creates:**

```bash
# Interactive demo - shows the complete workflow step by step
./demo/demo_completion_message.sh

# Quick demo - shows the completion message without pauses
./demo/demo_quick.sh

# Custom demo with your parameters
./demo/demo_completion_message.sh my-project myusername python
```

The demo demonstrates:
- ✅ What files and directories are created
- ✅ The completion message you'll see
- ✅ Common development commands
- ✅ Branch protection and rulesets information
- ✅ Emergency cleanup commands

## 📋 **Usage**

### **Command-Line Mode**
```bash
./gdst.sh --name my-project --username myuser
```
- All parameters provided via command line
- No user prompts
- Perfect for automation and CI/CD

### **Help and Information**
```bash
./gdst.sh --help     # Show all options
./gdst.sh --version  # Show version information
```

## 🛠️ **Command Line Options**

| Option | Short | Description | Example |
|--------|-------|-------------|---------|
| `--name` | `-n` | Repository name | `-n my-awesome-app` |
| `--username` | `-u` | GitHub username | `-u johndoe` |
| `--type` | `-t` | Project type | `-t python` |
| `--visibility` | `-V` | Repo visibility | `-V private` |
| `--directory` | `-d` | Working directory | `-d /path/to/projects` |
| `--skip-install` | | Skip package installation | `--skip-install` |
| `--skip-protection` | | Skip branch protection | `--skip-protection` |
| `--dry-run` | | Show what would be done | `--dry-run` |
| `--verbose` | `-v` | Enable verbose output | `--verbose` |
| `--level` | `-l` | Set log level | `--level DEBUG` |
| `--help` | `-h` | Show help | `--help` |
| `--version` | | Show version | `--version` |

## ⚙️ **Configuration File Support**

GDST supports configuration files to set default values for common parameters:

```bash
# Copy the example configuration file
cp gdst.conf.example gdst.conf

# Edit with your preferred defaults
nano gdst.conf
```

**Configuration file format:**
```bash
# Example gdst.conf
REPO_NAME=""
GITHUB_USERNAME="your-username"
PROJECT_TYPE="python"
REPO_VISIBILITY="private"
VERBOSE_MODE=true
LOG_LEVEL="DEBUG"
```

**Configuration behavior:**
- ✅ Configuration file values are used as defaults
- ✅ Command-line arguments override configuration values
- ✅ Supports all main GDST parameters
- ✅ Comments and empty lines are ignored
- ✅ File is automatically ignored by git

## 🎯 **Project Types Supported**

- **`node`** - Node.js with package.json, Jest, ESLint, Prettier
- **`react`** - React project (same as node with React-specific setup)
- **`python`** - Python with requirements.txt, pytest, black, flake8
- **`java`** - Java with Maven pom.xml
- **`other`** - Generic project with basic structure

## 📝 **Common Usage Examples**

### **Quick Setup**
```bash
./gdst.sh -n my-app -u myuser
```

### **Private Python Project**
```bash
./gdst.sh -n python-api -u myuser -t python -V private
```

### **Dry Run to Preview**
```bash
./gdst.sh -n test-project -u myuser --dry-run
```

### **Fast Setup (Skip Heavy Operations)**
```bash
./gdst.sh -n quick-setup -u myuser --skip-install --skip-protection
```

### **Custom Directory**
```bash
./gdst.sh -n project-name -u myuser -d /workspace/projects
```

## ⚡ **Speed Options**

- **`--skip-install`** - Skip npm/pip package installation (faster setup)
- **`--skip-protection`** - Skip GitHub branch protection setup
- **`--dry-run`** - Preview what would be created without making changes

## 🔧 **Troubleshooting**

### **Common Issues**

1. **"Repository name required"**
   - Solution: Add `-n repo-name` for non-interactive mode

2. **"GitHub username required"**
   - Solution: Add `-u username` for non-interactive mode

3. **"Not logged in to GitHub CLI"**
   - Solution: Run `gh auth login` first

4. **"Invalid project type"**
   - Solution: Use one of: `node`, `python`, `java`, `react`, `other`

### **Validation**

The script validates all inputs and provides clear error messages:
- Repository name and username are required for non-interactive mode
- Project type must be one of the supported types
- Repository visibility must be `public` or `private`
- Working directory must exist

## 🎉 **Benefits**

✅ **Flexible Usage** - Interactive or automated  
✅ **Complete Validation** - All inputs are validated  
✅ **Dry Run Support** - Preview before execution  
✅ **Speed Options** - Skip time-consuming operations  
✅ **Comprehensive Help** - Built-in documentation  
✅ **Error Handling** - Clear error messages and recovery  
✅ **Backward Compatible** - Existing usage still works  

## 📖 **Full Help**

Run `./gdst.sh --help` for complete documentation and examples.
