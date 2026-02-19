# Project Shortcut Template

**Copy this to create new project shortcuts in config.json**

---

## Template: Autonomous Project Agent

```json
"ProjectName": "Autonomous agent for [Project Name]. CRITICAL: Working directory is [PATH]. Read [PROJECT]/ROADMAP.md, find CURRENT STATUS and CURRENT TASK. IMPLEMENT 1-2 tasks - write actual code and tests. Work in [DIRECTORY]/. Run [TEST_COMMAND] to verify. Update ROADMAP.md: mark completed tasks [x], update CURRENT STATUS and CURRENT TASK. Create session report: [REPORT_PATH]/Session_N.md. CONSTRAINTS: NEVER modify [PROTECTED_FILES]. NEVER create files in [WRONG_DIRECTORY]."
```

---

## Customization Checklist

When creating a new shortcut, replace:

- [ ] `ProjectName` - Short identifier (use in config.json)
- [ ] `[Project Name]` - Full project name
- [ ] `[PATH]` - Working directory (e.g., `C:\\Projects\\MyApp`)
- [ ] `[PROJECT]` - Project folder name
- [ ] `[DIRECTORY]` - Where to create code files (e.g., `src/`)
- [ ] `[TEST_COMMAND]` - How to run tests (e.g., `npm test`, `pytest`)
- [ ] `[REPORT_PATH]` - Where to save session reports
- [ ] `[PROTECTED_FILES]` - Files to never modify
- [ ] `[WRONG_DIRECTORY]` - Directories to avoid

---

## Advanced Template: Full Autonomous Agent

For complex projects with detailed protocols:

```json
"ProjectName": "Autonomous agent for [Project Name] [DESCRIPTION]. SESSION START: (1) Read [PROJECT]/ROADMAP.md CURRENT STATUS, (2) Identify next 1-2 unchecked tasks, (3) If blocked, skip to next workable task. DEVELOPMENT PHILOSOPHY: (1) [PRINCIPLE_1], (2) [PRINCIPLE_2], (3) [PRINCIPLE_3]. WORKING DIRECTORY: Create ALL code files in [DIRECTORY]/. TECH: [TECH_STACK]. TESTING DISCIPLINE: (1) Write unit tests for NEW functions/components, (2) Add integration tests for NEW endpoints, (3) Every 3-4 sessions: run [TEST_COMMAND], FIX failures before continuing, (4) [ADDITIONAL_TEST_REQUIREMENTS]. PRIORITIES: [PHASE_PRIORITY_ORDER]. QUALITY GATES: Session [N1] - [MILESTONE_1], Session [N2] - [MILESTONE_2], Session [N3] - [MILESTONE_3]. BLOCKER PROTOCOL: If stuck for >10 minutes, mark task as [!] in ROADMAP, document blocker in NOTES, move to next task. CONSTRAINTS: [CONSTRAINTS_LIST]. SESSION END: (1) Mark completed tasks [x] in ROADMAP.md, (2) Update CURRENT STATUS, (3) Add CHANGELOG entry: date, phase, 1-line summary, (4) Create session report at [REPORT_PATH]/Session_N.md with: tasks completed, files created/modified, blockers encountered, next steps. NEVER create files in [WRONG_DIRECTORY]."
```

---

## Replacement Guide for Advanced Template

### Required Fields

**Project Info:**
- `[Project Name]` - Full name
- `[DESCRIPTION]` - One-line summary
- `[PROJECT]` - Folder name
- `[DIRECTORY]` - Working directory
- `[REPORT_PATH]` - Report location

**Technical:**
- `[TECH_STACK]` - Technologies used (e.g., "React + TypeScript + Node.js + PostgreSQL")
- `[TEST_COMMAND]` - Test command (e.g., "npm test", "pytest", "cargo test")

**Priorities:**
- `[PHASE_PRIORITY_ORDER]` - Phase order (e.g., "Phase 0 (setup) → Phase 1 (core) → Phase 2 (features)")

**Milestones:**
- `[N1]`, `[N2]`, `[N3]` - Session numbers
- `[MILESTONE_1]`, `[MILESTONE_2]`, `[MILESTONE_3]` - What should be done

**Constraints:**
- `[CONSTRAINTS_LIST]` - What NOT to do
- `[WRONG_DIRECTORY]` - Directories to avoid

### Optional Fields

**Development Philosophy:**
- `[PRINCIPLE_1]` - (e.g., "Core functionality FIRST")
- `[PRINCIPLE_2]` - (e.g., "Working code > perfect code")
- `[PRINCIPLE_3]` - (e.g., "Vertical slices - complete flows")

**Testing Requirements:**
- `[ADDITIONAL_TEST_REQUIREMENTS]` - Extra testing rules

---

## Examples from Your Projects

### Simple Project (Quick Setup)

```json
"NewTool": "Read NewTool/ROADMAP.md. Implement 1-2 tasks. Work in src/. Run npm test. Update ROADMAP checkboxes. Create report at reports/session_N.md. NEVER modify config.json."
```

### Complex Project (Full Protocol)

See your MyProject shortcut in current config.json as reference.

---

## Tips for Writing Good Shortcuts

### ✅ DO Include:
1. **Explicit paths** - Exact directories for code
2. **Test commands** - How to verify work
3. **Update instructions** - What to mark/document
4. **Boundaries** - What NOT to do
5. **Session protocol** - Start and end routines
6. **Quality gates** - Milestones at specific sessions

### ❌ DON'T:
1. Be vague - "improve the code" vs "refactor auth.js login function"
2. Forget test requirements
3. Skip blocker protocols
4. Leave out file/directory constraints
5. Omit session reporting instructions

---

## Testing Your Shortcut

Before long runs, test with:

```powershell
.\autonomous_loop.ps1 -Project "YourShortcut" -MaxSessions 2 -DelaySeconds 30
```

Check:
- [ ] Did it work in right directory?
- [ ] Did it update ROADMAP correctly?
- [ ] Did tests run?
- [ ] Did session report get created?
- [ ] Did it avoid protected areas?

If any issues, revise shortcut and test again.
