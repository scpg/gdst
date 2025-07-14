# GDST Demo Scripts

This directory contains demonstration scripts to help you understand what GDST creates before running it on real projects.

## 🎬 Available Demo Scripts

### 1. Interactive Demo (`demo_completion_message.sh`)

**Purpose**: Shows the complete GDST workflow with step-by-step presentation

```bash
# Run with default parameters
./demo/demo_completion_message.sh

# Run with custom parameters
./demo/demo_completion_message.sh my-project myusername python
```

**Features**:
- ✅ Step-by-step presentation with user pauses
- ✅ Shows project structure visualization
- ✅ Demonstrates common development commands
- ✅ Explains branch protection and rulesets
- ✅ Provides emergency cleanup information
- ✅ Interactive experience with "Press Enter to continue"

### 2. Quick Demo (`demo_quick.sh`)

**Purpose**: Shows the completion message without interruptions

```bash
# Run with default parameters
./demo/demo_quick.sh

# Run with custom parameters
./demo/demo_quick.sh my-project myusername python
```

**Features**:
- ✅ Complete output without pauses
- ✅ Perfect for documentation screenshots
- ✅ Shows what users will see after GDST completes
- ✅ Non-interactive, suitable for automation

## 📋 What the Demo Shows

### Project Creation Summary
- Local project directory structure
- GitHub repository setup
- Branch structure (main → dev/main → qa/staging)
- CI/CD pipeline configuration
- Branch protection rules and rulesets
- Development tools and configurations
- Helper scripts for workflow automation

### Next Steps Guidance
1. File review and customization
2. Environment configuration
3. Development workflow commands
4. QA deployment process
5. Production deployment process

### Resource Links
- GitHub repository URL
- Documentation locations
- Branch naming guidelines
- Development and deployment guides

### Development Commands
- Project navigation
- Feature branch creation
- Commit and push workflows
- QA and production deployment

### Branch Protection Information
- GitHub rulesets overview
- Conventional commits enforcement
- Branch naming validation
- Tag protection and semantic versioning
- PR requirements and code review rules

### Emergency Management
- Repository deletion commands
- Local directory cleanup
- Safety warnings

## 🎯 When to Use Each Demo

### Use Interactive Demo When:
- 👥 Presenting to a team
- 📚 Learning about GDST features
- 🎓 Training new developers
- 🔍 Exploring all capabilities

### Use Quick Demo When:
- 📖 Creating documentation
- 🖼️ Taking screenshots
- 🤖 Automating demonstrations
- ⚡ Quick reference

## 💡 Pro Tips

1. **Before Real Usage**: Always run the demo first to understand what GDST creates
2. **Team Training**: Use the interactive demo to onboard new team members
3. **Documentation**: Use the quick demo for creating user guides
4. **Customization**: Pass your actual project parameters to see realistic output

## 🚀 Ready to Try GDST?

After exploring the demo, run GDST for real:

```bash
./gdst.sh -n your-project -u your-username -t node
```

Need help? Run: `./gdst.sh --help`
