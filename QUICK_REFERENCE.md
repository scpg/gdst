# GDST Quick Reference

## 🎯 Two Different Use Cases

### 👤 **END USERS** (Creating new projects)
```bash
# You want to create a new project repository
./gdst.sh -n my-project -u myusername -t node

# Get help
./gdst.sh --help

# DO NOT use make commands!
```

### 👨‍💻 **DEVELOPERS** (Working on GDST itself)
```bash
# You want to test/improve the GDST tool
make GDST_DEVELOPER_MODE=true test

# Get help
make help

# Run specific tests
make GDST_DEVELOPER_MODE=true test-basic

# See CONTRIBUTING.md for details
```

## 🔒 **Security Feature**
The Makefile is protected and requires the `GDST_DEVELOPER_MODE=true` flag to execute any commands (except `help`). This prevents accidental execution by end users.

## ⚠️ Important
- **End users**: Use `./gdst.sh` directly
- **Developers**: Use `make GDST_DEVELOPER_MODE=true <command>` for testing
- **The Makefile is protected and requires explicit developer mode flag!**

## Need Help?
- **Using GDST**: Run `./gdst.sh --help`
- **Contributing**: See `CONTRIBUTING.md`
- **Testing**: See `test/README.md`
