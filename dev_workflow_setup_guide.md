# GDST - Development Workflow Setup Script - Quick Reference

## 🚀 **Enhanced Features Added**

The `dev_workflow_setup.sh` script now supports both **interactive** and **command-line** modes with extensive options.

## 📋 **Usage Modes**

### **Interactive Mode (Default)**
```bash
./dev_workflow_setup.sh
```
- Prompts for all required information
- Shows configuration before proceeding
- Default behavior (backward compatible)

### **Non-Interactive Mode**
```bash
./dev_workflow_setup.sh --name my-project --username myuser --non-interactive
```
- All parameters provided via command line
- No user prompts
- Perfect for automation and CI/CD

## 🛠️ **Command Line Options**

| Option | Short | Description | Example |
|--------|-------|-------------|---------|
| `--name` | `-n` | Repository name | `-n my-awesome-app` |
| `--username` | `-u` | GitHub username | `-u johndoe` |
| `--type` | `-t` | Project type | `-t python` |
| `--visibility` | `-v` | Repo visibility | `-v private` |
| `--directory` | `-d` | Working directory | `-d /path/to/projects` |
| `--skip-install` | | Skip package installation | `--skip-install` |
| `--skip-protection` | | Skip branch protection | `--skip-protection` |
| `--dry-run` | | Show what would be done | `--dry-run` |
| `--non-interactive` | | Non-interactive mode | `--non-interactive` |
| `--help` | `-h` | Show help | `--help` |
| `--version` | | Show version | `--version` |

## 🎯 **Project Types Supported**

- **`node`** - Node.js with package.json, Jest, ESLint, Prettier
- **`react`** - React project (same as node with React-specific setup)
- **`python`** - Python with requirements.txt, pytest, black, flake8
- **`java`** - Java with Maven pom.xml
- **`other`** - Generic project with basic structure

## 📝 **Common Usage Examples**

### **Quick Setup (Non-Interactive)**
```bash
./dev_workflow_setup.sh -n my-app -u myuser --non-interactive
```

### **Private Python Project**
```bash
./dev_workflow_setup.sh -n python-api -u myuser -t python -v private --non-interactive
```

### **Dry Run to Preview**
```bash
./dev_workflow_setup.sh -n test-project -u myuser --dry-run --non-interactive
```

### **Fast Setup (Skip Heavy Operations)**
```bash
./dev_workflow_setup.sh -n quick-setup -u myuser --skip-install --skip-protection --non-interactive
```

### **Custom Directory**
```bash
./dev_workflow_setup.sh -n project-name -u myuser -d /workspace/projects --non-interactive
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

Run `./dev_workflow_setup.sh --help` for complete documentation and examples.
