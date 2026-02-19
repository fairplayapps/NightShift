# NightShift Best Practices

**Lessons learned from successful autonomous coding sessions**

---

## Table of Contents

1. [ROADMAP Design](#roadmap-design)
2. [Writing Effective Shortcuts](#writing-effective-shortcuts)
3. [Session Management](#session-management)
4. [Testing Strategy](#testing-strategy)
5. [Monitoring & Control](#monitoring--control)
6. [Common Pitfalls](#common-pitfalls)
7. [Advanced Patterns](#advanced-patterns)

---

## ROADMAP Design

### ✅ DO: Be Specific

**Bad:**
```markdown
- [ ] Add user authentication
```

**Good:**
```markdown
- [ ] Add user authentication
  - POST /api/login endpoint (email + password)
  - Returns JWT token
  - Stores token in localStorage
  - Integration test with supertest
  - Updates user.lastLogin timestamp
```

### ✅ DO: Include Current Status

Always have a CURRENT STATUS block:
```markdown
## Current Status
Phase 1.2: Building API endpoints (4/12 tasks done)
Last session: 2026-02-07 - Session 15
Next checkpoint: Session 20 - All CRUD endpoints complete
```

### ✅ DO: Break Work Into Phases

```markdown
## Phase 0: Foundation (Est. 3-5 sessions)
- [ ] Project structure
- [ ] Database setup
- [ ] Basic server

## Phase 1: Core Features (Est. 10-15 sessions)
- [ ] User model
- [ ] Authentication
- [ ] Authorization

## Phase 2: Advanced Features (Est. 10-15 sessions)
- [ ] Dashboard
- [ ] Analytics
```

### ✅ DO: Add Success Criteria

```markdown
**Phase 1 Complete When:**
- [ ] All 12 tasks checked
- [ ] Integration tests pass (20+ tests)
- [ ] User can signup, login, logout
- [ ] API documented in docs/API.md
```

### ❌ DON'T: Be Vague

Avoid:
- "Improve performance"
- "Fix bugs"
- "Add features"
- "Refactor code"

Instead:
- "Reduce /api/users response time from 2s to <500ms by adding database index on email column"
- "Fix #42: Login redirect returns 404 instead of /dashboard"
- "Add user profile page with avatar upload and bio editing"
- "Extract auth logic from controllers into services/ directory"

---

## Writing Effective Shortcuts

### Anatomy of a Good Shortcut

```json
"ProjectName": "
  Autonomous agent for [Project]. 
  
  WORKING DIRECTORY: [exact path].
  
  SESSION START: 
  (1) Read [path]/ROADMAP.md, find CURRENT TASK
  (2) Identify next 1-2 unchecked tasks
  
  IMPLEMENT: 
  - Write actual code in [directory]/
  - Write tests in tests/
  - Run [test_command] to verify
  
  SESSION END:
  (1) Mark completed tasks [x]
  (2) Update CURRENT STATUS
  (3) Create report at [report_path]
  
  CONSTRAINTS:
  - NEVER modify [protected files]
  - NEVER create files in [wrong directory]
  - Run tests before marking complete
"
```

### Essential Elements Checklist

Every shortcut should have:
- [ ] Working directory path
- [ ] Where to find next tasks (ROADMAP.md location)
- [ ] How many tasks per session (1-2 recommended)
- [ ] Where to write code
- [ ] How to test (exact command)
- [ ] What to update after completion
- [ ] Where to save session reports
- [ ] What NOT to do (constraints)

### Shortcut Templates by Project Type

**Web Application:**
```json
"WebApp": "Read /ROADMAP.md CURRENT TASK. Implement 1-2 features. Work in src/. Tech: React + TypeScript + Node.js. Run npm test to verify. Update ROADMAP checkboxes. Report at meta/session_reports/WebApp/. NEVER modify package.json without instruction."
```

**Python Data Project:**
```json
"DataAnalysis": "Read ROADMAP.md. Implement 1 analysis task. Work in notebooks/ or src/. Run pytest. Update ROADMAP. Report at reports/. Tech: Python + pandas + scikit-learn. NEVER delete raw_data/ folder."
```

**Documentation:**
```json
"Docs": "Read docs/ROADMAP.md. Write 2-3 pages - clear, practical, with examples. Work in docs/pages/. Verify markdown renders. Update ROADMAP. Report at docs/reports/. Tone: technical but accessible."
```

---

## Session Management

### Starting Strategy

**First Time with Project:**
```json
{
  "maxSessions": 2,
  "delaySeconds": 30,
  "commitEveryNSessions": 1
}
```
Short sessions, frequent commits = easy to monitor and rollback.

**Established Project:**
```json
{
  "maxSessions": 10,
  "delaySeconds": 60,
  "commitEveryNSessions": 3
}
```

**Overnight Run:**
```json
{
  "maxSessions": 50,
  "delaySeconds": 180,
  "commitEveryNSessions": 5,
  "stopTime": "08:00"
}
```

### Delay Strategy

| Delay | Use Case | Monitoring Level |
|-------|----------|------------------|
| 30s | Active testing/debugging | Watch every session |
| 60s | Standard development | Check every 3-5 sessions |
| 120s | Trusted project | Check every 10 sessions |
| 300s | Overnight/long runs | Review in morning |

Longer delays = more time to Ctrl+C if things go wrong.

### Commit Frequency

```json
"commitEveryNSessions": N
```

- **N=1:** Every session (safest, cleanest rollback)
- **N=3:** Every 3 sessions (good balance)
- **N=5:** Every 5 sessions (for stable projects)
- **N=0:** Disable auto-commit (manual only)

---

## Testing Strategy

### Testing Protocol in ROADMAP

Always include:
```markdown
## Testing Protocol (MANDATORY)

### After Every Code Change
1. Run unit tests: `[command]`
2. If new feature: Add integration test
3. If tests fail: FIX before marking task complete

### Quality Gates
- Session 5: 10+ tests passing
- Session 15: 30+ tests passing, integration coverage
- Session 30: 50+ tests passing, E2E coverage
```

### Testing in Shortcuts

Include test requirements:
```json
"TESTING: (1) Write unit test for NEW functions, (2) Add integration test for NEW endpoints, (3) Every 3-4 sessions: run npm test, FIX failures immediately, (4) NEVER mark task complete if tests fail"
```

### Test-First Tasks

For complex tasks, specify test-first:
```markdown
- [ ] Fix login redirect bug
  1. Write failing test that reproduces bug
  2. Run test - should FAIL
  3. Fix the code
  4. Run test - should PASS
  5. Mark complete
```

---

## Monitoring & Control

### Review Schedule

**Every 3-5 sessions:**
```powershell
# Stop NightShift (Ctrl+C)

# Check git log
git log --oneline -20

# Review recent changes
git diff HEAD~5 HEAD

# Verify tests
[test command]

# Read latest session report
cat meta/session_reports/[Project]/Session_N.md
```

### Warning Signs

Stop and review if you see:
- ⚠️ Tests failing
- ⚠️ Files created in wrong directories
- ⚠️ Same task attempted multiple times
- ⚠️ No progress for 3+ sessions
- ⚠️ Unexpected file deletions
- ⚠️ Protected files modified

### Course Correction

If things are off-track:

1. **Update ROADMAP:**
   - Make current task more specific
   - Add examples
   - Break into smaller subtasks

2. **Update Shortcut:**
   - Add more constraints
   - Strengthen "NEVER" rules
   - Add "ALWAYS" test requirements

3. **Reduce Sessions:**
   - From 10 → 3 sessions
   - Monitor more closely
   - Expand once on track

4. **Rollback if Needed:**
   ```powershell
   git log --oneline -10
   git reset --hard HEAD~3  # Undo last 3 commits
   ```

---

## Common Pitfalls

### 1. Vague Tasks

**Problem:** "Add authentication"

**Fix:** 
```markdown
- [ ] Add JWT authentication
  - POST /api/auth/login (email, password)
  - Validates against users table
  - Returns JWT token (expires in 24h)
  - Middleware: authenticateToken()
  - Test: 5 test cases (valid, invalid, expired, etc.)
```

### 2. Missing Test Requirements

**Problem:** Code works but no tests

**Fix:** Add to shortcut:
```json
"TESTING MANDATORY: Every new function requires unit test. Every new endpoint requires integration test. Mark task complete ONLY if tests pass."
```

### 3. Wrong Directory

**Problem:** Files created in project root instead of src/

**Fix:** Add to shortcut:
```json
"CRITICAL: ALL code files go in src/. NEVER create .js or .ts files in project root."
```

### 4. Gets Stuck on Same Task

**Problem:** Attempts same task 3+ times

**Fix:** Add blocker protocol:
```json
"If stuck on task >15 minutes: (1) Mark as [!] in ROADMAP, (2) Document blocker in NOTES, (3) Move to next task, (4) Revisit at session end if time permits"
```

### 5. No Progress Tracking

**Problem:** Can't tell what changed

**Fix:** Add session log to ROADMAP:
```markdown
## Session Log
| Session | Date | Tasks | Tests | Status |
|---------|------|-------|-------|--------|
| 1 | 2026-02-07 | 2 | ✅ 10 | ✅ |
```

### 6. Modifies Protected Files

**Problem:** Changed package.json, broke dependencies

**Fix:** Add to shortcut:
```json
"NEVER modify package.json, tsconfig.json, or .env files without explicit instruction"
```

---

## Advanced Patterns

### Pattern 1: Phase-Based Checkpoints

```json
{
  "projectShortcuts": {
    "MyApp": "... QUALITY GATES: Session 5 (foundation working), Session 15 (core features done), Session 30 (polish complete) ..."
  }
}
```

In ROADMAP:
```markdown
## Session 15 Checkpoint
Must have by session 15:
- [ ] All CRUD endpoints working
- [ ] 30+ tests passing
- [ ] API documented
- [ ] One complete user flow (signup → login → dashboard)
```

### Pattern 2: Multi-Provider Strategy

```json
{
  "monday": {
    "provider": "claude",
    "project": "MyApp",
    "maxSessions": 20
  },
  "tuesday": {
    "provider": "codex", 
    "project": "MyApp",
    "maxSessions": 20
  }
}
```

Compare quality, pick best provider.

### Pattern 3: Example-Driven Development

In ROADMAP, add examples:
```markdown
## Current Task
Add input validation for user registration

### Example to Follow
File: `src/validators/emailValidator.js`
```javascript
export function validateEmail(email) {
  const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!regex.test(email)) {
    return { valid: false, error: 'Invalid email' };
  }
  return { valid: true };
}
```

Follow this pattern for passwordValidator and usernameValidator.
```

### Pattern 4: Velocity Tracking

Track in session reports:
```markdown
## Session Velocity

| Sessions | Tasks | Avg/Session | Notes |
|----------|-------|-------------|-------|
| 1-5 | 8 | 1.6 | Fast (setup) |
| 6-10 | 6 | 1.2 | Medium (auth) |
| 11-15 | 3 | 0.6 | Slow (complex features) |
```

Use to estimate future work:
- Simple tasks: ~1.5 per session
- Medium tasks: ~1.0 per session
- Complex tasks: ~0.5 per session

### Pattern 5: Parallel Projects

For multi-project workspace:
```json
"all": "Deploy parallel agents. Each reads its ROADMAP, implements 1-2 tasks, updates status. Projects: A (auth), B (api), C (ui). Report in meta/session_reports/[Project]/"
```

Run all projects simultaneously, review afterward.

---

## Success Metrics

### Good Session
- ✅ 1-2 tasks completed
- ✅ Tests passing
- ✅ ROADMAP updated
- ✅ Session report created
- ✅ Git committed
- ✅ No protected files touched

### Excellent Session
- All above PLUS:
- ✅ Quality above minimum (well-tested, clean code)
- ✅ Documented decisions
- ✅ Examples added for future reference
- ✅ Progress toward quality gate

### Session Needs Attention
- ❌ No tasks completed
- ❌ Tests failing
- ❌ Wrong files modified
- ❌ No ROADMAP update
- ❌ Same task attempted multiple times

---

## Quick Reference Checklist

**Before starting autonomous run:**
- [ ] ROADMAP has clear CURRENT TASK
- [ ] Task has success criteria
- [ ] Testing protocol defined
- [ ] Project shortcut in config.json
- [ ] Report directory exists
- [ ] 2-session test run successful

**After every 3-5 sessions:**
- [ ] Review git log
- [ ] Check tests pass
- [ ] Read session reports
- [ ] Verify ROADMAP updated
- [ ] Check velocity vs estimate

**Before overnight run:**
- [ ] Test run successful (3-5 sessions)
- [ ] Commit frequency set (usually 5)
- [ ] Stop time configured
- [ ] Backup current state
- [ ] Clear CURRENT TASK defined

---

**Last Updated:** 2026-02-07
