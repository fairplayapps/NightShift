# [Project Name] Quick Start

**Fast reference for common commands and workflows**

---

## Quick Commands

### Development
```bash
# Install dependencies
[install command]

# Start development server
[dev command]

# Build project
[build command]
```

### Testing
```bash
# Run all tests
[test command]

# Run specific test file
[command with file path]

# Run tests in watch mode
[watch command]

# Check test coverage
[coverage command]
```

### Linting & Formatting
```bash
# Check code style
[lint command]

# Fix code style
[lint fix command]

# Format code
[format command]
```

---

## Project Structure

```
project/
├── src/              # Source code
│   ├── [structure]
├── tests/            # Test files
├── docs/             # Documentation
├── ROADMAP.md        # Development roadmap
└── [other folders]
```

---

## Current Priority

**See:** [ROADMAP.md](../ROADMAP.md) → **Current Task** section

**Phase:** [Current phase]  
**Next:** [Next 1-2 tasks]

---

## NightShift Integration

### Config
```json
{
  "project": "[ShortcutName]",
  "provider": "claude"
}
```

### Run Autonomous Sessions
```powershell
cd [ProjectPath]
C:\Users\[YourUsername]\Desktop\NightShift - Open\autonomous_loop.ps1
```

---

## Environment Setup

### Required
- [Requirement 1]
- [Requirement 2]

### Environment Variables
```bash
# Create .env file with:
[VAR_NAME]=[value]
[VAR_NAME]=[value]
```

---

## Common Workflows

### Start new feature
```bash
git checkout -b feature/[name]
[dev server command]
# Code...
[test command]
git commit -m "feat: [description]"
```

### Fix bug
```bash
git checkout -b fix/[name]
# Write failing test
[test command]
# Fix bug
[test command]  # Should pass now
git commit -m "fix: [description]"
```

### Run before commit
```bash
[lint command]
[test command]
[build command]  # Optional
```

---

## Debugging

### Check logs
```bash
[log command or location]
```

### Common issues

**Issue 1:** [Description]
- **Fix:** [Solution]

**Issue 2:** [Description]
- **Fix:** [Solution]

---

## Database (if applicable)

### Setup
```bash
[db setup command]
```

### Migrations
```bash
[migration command]
```

### Seed data
```bash
[seed command]
```

### Reset
```bash
[reset command]
```

---

## Deployment

### Prerequisites
- [ ] All tests pass
- [ ] No lint errors
- [ ] Build succeeds
- [ ] Environment variables configured

### Deploy
```bash
[deploy command]
```

---

## Useful Links

- **Documentation:** [link]
- **API Docs:** [link]
- **Design:** [Figma/etc link]
- **CI/CD:** [Pipeline link]

---

## Team / Contacts

- **Owner:** [Name]
- **Repository:** [URL]
- **Issues:** [Issue tracker URL]

---

**Last Updated:** [Date]
