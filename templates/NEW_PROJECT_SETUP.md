# New Project Quick Start

**Complete setup guide for new projects with NightShift**

---

## Step 1: Create Project Structure

```powershell
# Create project directory
mkdir MyNewProject
cd MyNewProject

# Initialize git
git init

# Create basic structure
mkdir src
mkdir tests
mkdir docs
mkdir .runnerman

# Create placeholder files
New-Item README.md
New-Item ROADMAP.md
New-Item docs/QUICKSTART.md
```

---

## Step 2: Copy Templates

### From NightShift templates directory:

1. **Copy ROADMAP template:**
   ```powershell
   Copy-Item "C:\Users\[YourUsername]\Desktop\NightShift - Open\templates\ROADMAP_TEMPLATE.md" `
             ".\ROADMAP.md"
   ```

2. **Copy QUICKSTART template:**
   ```powershell
   Copy-Item "C:\Users\[YourUsername]\Desktop\NightShift - Open\templates\QUICKSTART_TEMPLATE.md" `
             ".\docs\QUICKSTART.md"
   ```

---

## Step 3: Fill Out ROADMAP.md

Edit ROADMAP.md and replace:
- `[Project Name]` - Your project name
- `[Tech Stack]` - Languages/frameworks
- `[Date]` - Today's date
- Fill in Phase 0 tasks (foundation work)
- Fill in Phase 1 tasks (core features)
- Add testing protocol
- Set quality gates

---

## Step 4: Create Project Shortcut

### Use the template:

1. Open: `C:\Users\[YourUsername]\Desktop\NightShift - Open\templates\PROJECT_SHORTCUT_TEMPLATE.md`

2. Copy the template you need (simple or advanced)

3. Customize for your project

4. Add to `config.json` in NightShift directory

**Example:**
```json
{
  "projectShortcuts": {
    "MyNewProject": "Autonomous agent for MyNewProject. Working directory: C:\\Projects\\MyNewProject. Read ROADMAP.md, find CURRENT TASK. IMPLEMENT 1-2 tasks - write code and tests. Work in src/. Run npm test. Update ROADMAP checkboxes. Create session report: C:\\Users\\[YourUsername]\\Desktop\\NightShift - Open\\meta\\session_reports\\MyNewProject\\Session_N.md. NEVER modify package.json without instruction."
  }
}
```

---

## Step 5: Create Report Directory

```powershell
mkdir "C:\Users\[YourUsername]\Desktop\NightShift - Open\meta\session_reports\MyNewProject"
```

---

## Step 6: Test Run (Short)

```powershell
cd MyNewProject

C:\Users\[YourUsername]\Desktop\NightShift - Open\autonomous_loop.ps1 `
  -Project "MyNewProject" `
  -MaxSessions 2 `
  -DelaySeconds 30
```

Check:
- [ ] Did it work in right directory?
- [ ] Did it read ROADMAP?
- [ ] Did tests run?
- [ ] Did session report get created?

---

## Step 7: Full Run

If test was successful:

```powershell
# Edit NightShift config.json
{
  "provider": "claude",
  "project": "MyNewProject",
  "maxSessions": 10,
  "delaySeconds": 60,
  "commitEveryNSessions": 3
}

# Run full sessions
.\autonomous_loop.ps1
```

---

## Step 8: Monitor & Adjust

### Every 3-5 sessions:
```powershell
# Stop NightShift (Ctrl+C)

# Review progress
git log --oneline -20
git diff HEAD~5 HEAD

# Check tests
[your test command]

# Read latest session report
```

### If things are off-track:
1. Update ROADMAP.md with clearer instructions
2. Add examples for complex tasks
3. Adjust project shortcut with more constraints
4. Restart with fewer sessions to monitor closer

---

## Recommended First-Run Settings

### For brand new projects:
```json
{
  "maxSessions": 5,
  "delaySeconds": 60,
  "commitEveryNSessions": 2,
  "defaultModel": "sonnet"
}
```

### For established projects:
```json
{
  "maxSessions": 10,
  "delaySeconds": 90,
  "commitEveryNSessions": 3,
  "defaultModel": "sonnet"
}
```

### For overnight runs:
```json
{
  "maxSessions": 50,
  "delaySeconds": 180,
  "commitEveryNSessions": 5,
  "stopTime": "08:00",
  "timezone": "EST"
}
```

---

## Common Issues & Fixes

### "It created files in wrong place"
**Fix:** Add to shortcut: `CRITICAL: ALL code files go in src/. NEVER create files in project root.`

### "It's not testing"
**Fix:** Make testing mandatory in ROADMAP: `TESTING PROTOCOL (MANDATORY): Run tests after EVERY change.`

### "Tasks aren't specific enough"
**Fix:** Add success criteria to each task in ROADMAP.

### "It keeps getting stuck"
**Fix:** Add blocker protocol: `If stuck >10 min, mark [!], move to next task.`

---

## Quick Reference Commands

```powershell
# Start autonomous run
.\autonomous_loop.ps1

# Test run (2 sessions)
.\autonomous_loop.ps1 -MaxSessions 2 -DelaySeconds 30

# Override project
.\autonomous_loop.ps1 -Project "OtherProject"

# Check git history
git log --oneline -10

# Review changes
git diff HEAD~3 HEAD

# Rollback if needed  
git reset --hard HEAD~2

# Check session reports
ls "C:\Users\[YourUsername]\Desktop\NightShift - Open\meta\session_reports\MyProject"
```

---

## Checklist: Ready for Autonomous Run?

Before first full run:

- [ ] ROADMAP.md has clear CURRENT TASK
- [ ] Phase 0 tasks are well-defined
- [ ] Testing protocol is documented
- [ ] Project shortcut is in config.json
- [ ] Session report directory exists
- [ ] Git is initialized
- [ ] Basic project structure exists (src/, tests/)
- [ ] Test command works
- [ ] Did 2-session test run successfully

If all checked → Ready for full autonomous run!
