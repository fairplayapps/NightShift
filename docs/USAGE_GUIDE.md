# NightShift Usage Guide

**How to set up and run autonomous coding sessions on new projects**

---

## Quick Start: Point NightShift at a New Project

### Option 1: Simple Command (No Config)

```powershell
cd "C:\Path\To\Your\Project"
.\autonomous_loop.ps1 `
  -Provider "claude" `
  -Project "Read ROADMAP.md and implement the next 2 unchecked tasks. Update checkboxes when done." `
  -MaxSessions 5 `
  -DelaySeconds 60
```

**That's it!** NightShift will:
- Use Claude Code
- Run 5 autonomous sessions
- Wait 60 seconds between each
- Auto-commit after each session
- Stop when done or you Ctrl+C

---

### Option 2: Add Project Shortcut (Reusable)

**Step 1: Create a ROADMAP.md in your project**

```markdown
# Project XYZ Roadmap

## Current Status
Phase 1: Setting up authentication

## Current Task
Implement user login with JWT tokens

## Tasks
- [ ] Create user model (User table with email, password hash)
- [ ] Write login endpoint (POST /api/auth/login)
- [ ] Add JWT token generation
- [ ] Write tests for login flow
- [ ] Create basic login UI component

## Tech Stack
- Node.js + Express
- PostgreSQL
- React + TypeScript
```

**Step 2: Add to config.json**

```json
{
  "provider": "claude",
  "project": "MyNewProject",
  
  "projectShortcuts": {
    "MyNewProject": "Autonomous agent. Working directory: C:\\Projects\\MyNewProject. Read ROADMAP.md, find CURRENT TASK. IMPLEMENT 1-2 tasks from the task list - write actual code and tests. Update ROADMAP.md checkboxes. Run tests to verify (npm test or pytest). Create progress report at PROGRESS.md. Work scope: implement, test, document."
  }
}
```

**Step 3: Run**

```powershell
cd C:\Projects\MyNewProject
C:\Users\YourUsername\Desktop\NightShift - Open\autonomous_loop.ps1
```

Done! It reads config.json and runs autonomously.

---

## Configuration Explained

### Basic Settings

```json
{
  "provider": "claude",           // Which AI: claude or codex
  "project": "MyNewProject",      // Which shortcut to use
  "maxSessions": 10,              // Run 10 sessions then stop
  "delaySeconds": 45,             // Wait 45 sec between sessions
  "commitEveryNSessions": 3,      // Git commit every 3 sessions
  "defaultModel": "sonnet",       // Claude model (sonnet/opus/haiku)
  "stopTime": "23:30",            // Stop at 11:30 PM
  "timezone": "EST"               // Your timezone
}
```

### Provider Comparison

| Setting | When to Use |
|---------|-------------|
| `"provider": "claude"` | Best quality, long context, pay-per-token |
| `"provider": "codex"` | OpenAI ecosystem, reasoning models |

### Session Settings

**Short test run (30 min):**
```json
{
  "maxSessions": 3,
  "delaySeconds": 30,
  "stopTime": ""
}
```

**Overnight run (8 hours):**
```json
{
  "maxSessions": 100,
  "delaySeconds": 120,
  "stopTime": "08:00",
  "commitEveryNSessions": 5
}
```

**Long weekend run:**
```json
{
  "maxSessions": 200,
  "delaySeconds": 180,
  "stopTime": "",
  "commitEveryNSessions": 10
}
```

---

## How to Write Good Project Shortcuts

### Template

```json
"ProjectName": "Autonomous agent. Working directory: C:\\Path\\To\\Project. Read ROADMAP.md, find CURRENT TASK section. IMPLEMENT 1-2 tasks - write actual code and tests. Update ROADMAP.md checkboxes when done. Run tests (npm test). Create progress report at PROGRESS.md. Work scope: [specific boundaries]."
```

### Key Elements

1. **Working Directory** - Where the code lives
2. **ROADMAP.md Location** - Where to find next tasks
3. **Task Scope** - How many tasks per session (1-2 recommended)
4. **Testing Protocol** - What to run to verify
5. **Update Instructions** - What to mark as done
6. **Boundaries** - What NOT to do

### Examples

**Web App Development:**
```json
"WebApp": "Read /docs/ROADMAP.md for CURRENT TASK. Implement 1-2 features - write component code + tests. Work in /src/. Run npm test to verify. Update ROADMAP checkboxes. Create report at /docs/SESSION_NOTES.md. Tech: React + TypeScript. NEVER modify config files without explicit instruction."
```

**Python ML Project:**
```json
"MLModel": "Read ROADMAP.md CURRENT TASK section. Implement 1 task: write model code, training script, or evaluation. Work in /src/models/. Run pytest to verify. Update ROADMAP. Document in PROGRESS.md. Tech: PyTorch, scikit-learn. NEVER delete existing model checkpoints."
```

**Documentation Project:**
```json
"Docs": "Read docs/ROADMAP.md CURRENT TASK. Write 2-3 documentation pages - clear, practical, with examples. Work in docs/pages/. Verify markdown renders correctly. Update ROADMAP checkboxes. Create summary in docs/CHANGELOG.md. Tone: Technical but accessible."
```

---

## Best Practices for Autonomous Work

### 1. Create Clear ROADMAPs

**Good ROADMAP:**
```markdown
## Current Status
Phase 2: Building API endpoints (3/8 done)

## Current Task
Implement user profile endpoint

## Next Tasks (Priority Order)
- [ ] GET /api/users/:id - fetch user profile
- [ ] PUT /api/users/:id - update user profile  
- [ ] Write integration tests for profile endpoints
- [ ] Add profile picture upload (POST /api/users/:id/avatar)
- [ ] Add input validation for profile updates

## Tech Notes
- Use Express middleware for auth
- Validate with Joi schemas
- Store avatars in S3 (credentials in .env)
- Write tests with supertest
```

**Bad ROADMAP:**
```markdown
## Tasks
- Finish user stuff
- Make it work better
- Add features
```

### 2. Set Boundaries

**Critical things to specify in shortcuts:**

✅ **DO specify:**
- Exact working directories
- Test commands
- File naming conventions
- Tech stack constraints
- What to update after each session

❌ **DON'T forget to say:**
- "NEVER modify [critical files]"
- "NEVER delete existing [important data]"
- "NEVER create files in [wrong directory]"
- "Run [tests] to verify before marking done"

### 3. Monitor Progress

**Check every 3-5 sessions:**
```powershell
# Stop NightShift (Ctrl+C)
# Review what it did
git log --oneline -20           # See commits
git diff HEAD~5 HEAD            # Review changes
npm test                        # Verify tests pass
```

**If it's off track:**
- Update ROADMAP.md to clarify next tasks
- Add boundaries to project shortcut
- Adjust session count (fewer = tighter control)

### 4. Use Delays Strategically

| Delay | Use Case |
|-------|----------|
| **30 sec** | Testing with close supervision |
| **60 sec** | Active monitoring, can review between sessions |
| **120 sec** | Semi-autonomous, check every 10 min |
| **300 sec (5 min)** | Fully autonomous, overnight runs |

Longer delays = more time to Ctrl+C if something goes wrong.

### 5. Commit Strategy

```json
"commitEveryNSessions": 3   // Commit every 3 sessions
```

- **Small projects:** Commit every 1-2 sessions
- **Large projects:** Commit every 3-5 sessions  
- **Experimental:** Commit every session (easy rollback)
- **Stable:** Commit every 5-10 sessions (cleaner history)

---

## Common Workflows

### Scenario 1: Start a New Feature

**Setup:**
1. Create feature branch
   ```bash
   git checkout -b feature/user-profiles
   ```

2. Write ROADMAP.md
   ```markdown
   ## Current Task
   Build user profile system
   
   ## Tasks
   - [ ] Create user profile model
   - [ ] Add profile CRUD API endpoints
   - [ ] Write API tests
   - [ ] Build profile UI component
   - [ ] Add profile edit form
   ```

3. Run NightShift
   ```powershell
   .\autonomous_loop.ps1 -MaxSessions 10 -DelaySeconds 60
   ```

4. Monitor progress, merge when done

---

### Scenario 2: Fix Bugs from Issue Tracker

**ROADMAP.md:**
```markdown
## Current Task
Fix high-priority bugs

## Tasks (from GitHub issues)
- [ ] Fix #42: Login redirect broken (issue: users sent to 404)
- [ ] Fix #38: Profile pic upload fails (error: S3 permission denied)
- [ ] Fix #35: Email validation too strict (bug: rejects valid emails)

## Bug Fix Protocol
1. Write failing test that reproduces bug
2. Fix the bug
3. Verify test passes
4. Update issue with fix details
```

**Run:**
```powershell
.\autonomous_loop.ps1 -Project "BugFixes" -MaxSessions 6
```

---

### Scenario 3: Write Documentation

**ROADMAP.md:**
```markdown
## Current Task
Write API documentation

## Documentation Queue
- [ ] Authentication endpoints (POST /login, POST /register, POST /logout)
- [ ] User profile endpoints (GET/PUT /users/:id)
- [ ] Settings endpoints (GET/PUT /users/:id/settings)
- [ ] Each doc needs: description, request format, response format, example, errors

## Format
Use docs/templates/ENDPOINT_TEMPLATE.md as base
```

**Run:**
```powershell
.\autonomous_loop.ps1 -Project "Docs" -Provider "claude" -MaxSessions 8
```

---

### Scenario 4: Refactor Complex Code

**ROADMAP.md:**
```markdown
## Current Task
Refactor authentication module

## Refactoring Tasks
- [ ] Extract auth logic from controllers to services
- [ ] Add JSDoc comments to all auth functions
- [ ] Split auth.js into smaller modules (login, register, password-reset)
- [ ] Update tests to use new module structure
- [ ] Update imports in dependent files

## Constraints
- MUST keep all existing tests passing
- NEVER change public API signatures
- Run npm test after EVERY change
```

**Run with extra caution:**
```powershell
.\autonomous_loop.ps1 -MaxSessions 5 -DelaySeconds 120 -CommitEveryNSessions 1
```

Short sessions + frequent commits = easy rollback if needed.

---

## Troubleshooting

### "It's not doing what I want"

**Fix 1: Make ROADMAP more specific**
```markdown
❌ Bad: "Add user authentication"
✅ Good: "Implement JWT-based login: (1) POST /api/auth/login endpoint that accepts email+password, validates against DB, returns JWT token. (2) Write integration test. (3) Update API docs."
```

**Fix 2: Add examples**
```markdown
## Current Task
Add input validation

## Example (follow this pattern)
File: src/validators/userValidator.js
Function: validateEmail(email) - returns {valid: boolean, error?: string}
Test: tests/validators/userValidator.test.js
```

**Fix 3: Reduce scope**
```json
"maxSessions": 2  // Run 2 sessions, review, adjust, run 2 more
```

---

### "It's creating files in wrong place"

**Add to project shortcut:**
```json
"MyProject": "... CRITICAL: All code files go in /src/. NEVER create files in project root. NEVER create files in /config/ or /scripts/. ..."
```

---

### "It's not testing properly"

**Specify test protocol in ROADMAP:**
```markdown
## Testing Protocol (MANDATORY)
After implementing ANY code:
1. Run `npm test` (unit tests)
2. If tests fail, FIX them before continuing
3. For new endpoints: add integration test with supertest
4. Mark task done ONLY if tests pass
```

---

### "It keeps getting stuck on same task"

**Add blocker protocol to shortcut:**
```json
"MyProject": "... If stuck on task >15 minutes, mark as [BLOCKED] in ROADMAP, document blocker, move to next task. Revisit blocked tasks at session end if time permits. ..."
```

---

## Advanced: Command-Line Overrides

Override config.json without editing it:

```powershell
# Quick test with different provider
.\autonomous_loop.ps1 -Provider "codex" -MaxSessions 2

# Override project
.\autonomous_loop.ps1 -Project "Debug project. Find cause of memory leak in server.js. Add logging and profiling."

# Overnight run with stop time
.\autonomous_loop.ps1 -MaxSessions 100 -StopTime "07:00" -Timezone "EST"

# Manual model selection
.\autonomous_loop.ps1 -Provider "claude" -Model "opus" -MaxSessions 3
```

All command-line args override config.json for that run.

---

## Example: Setting Up a Brand New Project

**Complete walkthrough:**

### 1. Create Project Structure
```bash
mkdir MyAwesomeApp
cd MyAwesomeApp
git init
npm init -y
```

### 2. Create ROADMAP.md
```markdown
# MyAwesomeApp Development Roadmap

## Current Status
Phase 0: Project initialization

## Current Task
Set up project foundation

## Phase 0: Foundation (Est. 5 sessions)
- [ ] Create package.json with dependencies (express, typescript, jest)
- [ ] Set up TypeScript config (tsconfig.json)
- [ ] Create folder structure (src/, tests/, docs/)
- [ ] Write basic Express server (src/server.ts)
- [ ] Add health check endpoint (GET /health)
- [ ] Write hello world test

## Phase 1: Core Features (Est. 15 sessions)
- [ ] Design database schema
- [ ] Set up PostgreSQL connection
- [ ] Create user model
- [ ] Implement user registration
- [ ] Implement user login
- [ ] Add JWT authentication middleware
- [ ] Write integration tests

## Tech Stack
- Node.js 20 + TypeScript
- Express 4
- PostgreSQL 16
- Jest for testing
- JWT for auth
```

### 3. Add to NightShift config.json
```json
{
  "provider": "claude",
  "project": "MyAwesomeApp",
  "maxSessions": 20,
  "delaySeconds": 60,
  "commitEveryNSessions": 5,
  
  "projectShortcuts": {
    "MyAwesomeApp": "Autonomous agent. Working directory: C:\\Users\\YourUsername\\Projects\\MyAwesomeApp. Read ROADMAP.md, find CURRENT TASK and CURRENT STATUS. IMPLEMENT 1-2 unchecked tasks from current phase - write actual production code and tests. Work in src/ for code, tests/ for tests. Run npm test to verify ALL tests pass. Update ROADMAP.md: mark completed tasks [x], update CURRENT TASK and CURRENT STATUS. Create session report at docs/SESSION_NOTES.md. Tech: Node.js + TypeScript + Express + PostgreSQL. NEVER modify package.json without explicit instruction. NEVER delete database migration files."
  }
}
```

### 4. Run NightShift
```powershell
cd MyAwesomeApp

# First run: short test (3 sessions)
C:\Users\YourUsername\Desktop\NightShift\autonomous_loop.ps1 -MaxSessions 3

# Review, then longer run
C:\Users\YourUsername\Desktop\NightShift\autonomous_loop.ps1 -MaxSessions 20
```

### 5. Monitor & Adjust

**After 5 sessions:**
- Check git log
- Review ROADMAP.md updates
- Verify tests pass: `npm test`
- If good: let it continue
- If off-track: Ctrl+C, update ROADMAP, restart

---

## Summary Checklist

Before running NightShift on a new project:

- [ ] Create/update ROADMAP.md with clear tasks
- [ ] Add project shortcut to config.json with:
  - [ ] Working directory path
  - [ ] Task scope (1-2 per session)
  - [ ] Test command
  - [ ] Update instructions
  - [ ] Boundaries (NEVER do X)
- [ ] Set provider (claude/codex)
- [ ] Set session count (start small: 3-5)
- [ ] Set delay (60-120 seconds for monitoring)
- [ ] Set commit frequency (3-5 sessions)
- [ ] Optional: set stopTime for overnight runs

Then: `.\autonomous_loop.ps1` and monitor!

---

## Quick Reference

**Start autonomous run:**
```powershell
.\autonomous_loop.ps1
```

**Stop early:**
```
Ctrl+C (graceful stop)
```

**Review progress:**
```powershell
git log --oneline -10      # Recent commits
git diff HEAD~5 HEAD       # Changes in last 5 commits
```

**Rollback if needed:**
```powershell
git reset --hard HEAD~3    # Undo last 3 commits (CAREFUL!)
```

**Test run (2 sessions):**
```powershell
.\autonomous_loop.ps1 -MaxSessions 2 -DelaySeconds 30
```

**Overnight run:**
```powershell
.\autonomous_loop.ps1 -MaxSessions 100 -StopTime "08:00" -CommitEveryNSessions 10
```
