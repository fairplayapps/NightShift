# Project ROADMAP Template

**Copy this to any new project as ROADMAP.md**

---

# [Project Name] Roadmap

## Quick Info
- **Started:** [Date]
- **Tech Stack:** [Languages/Frameworks]
- **Repository:** [URL if applicable]
- **NightShift Config:** See `_project_shortcut.md` for autonomous prompt

---

## Current Status
**Phase:** [Phase number/name]  
**Progress:** [X/Y tasks] completed in current phase  
**Last Session:** [Date] - Session [N]  
**Next Checkpoint:** Session [N] - [Milestone description]

---

## Current Task
[One clear sentence describing what to do next]

### Task Details
**What:** [Detailed description]  
**Where:** [Which files/folders]  
**How:** [Specific approach or pattern to follow]  
**Done when:** [Success criteria - be specific]

### Context
[Any background info needed to understand this task]

---

## Immediate Next Steps (Top 3 Priorities)

1. **[Task 1]**
   - Success criteria: [What done looks like]
   - Files: [Where to work]
   
2. **[Task 2]**
   - Success criteria: [What done looks like]
   - Files: [Where to work]

3. **[Task 3]**
   - Success criteria: [What done looks like]
   - Files: [Where to work]

---

## Phase 0: Foundation (Est. [N] sessions)

**Goal:** [What this phase accomplishes]

### Tasks
- [ ] **Task 1** - [Brief description]
  - Creates: [Files/features]
  - Tests: [What to verify]
  
- [ ] **Task 2** - [Brief description]
  - Creates: [Files/features]
  - Tests: [What to verify]

**Phase 0 Complete When:**
- [ ] All tasks checked
- [ ] Tests pass: `[test command]`
- [ ] [Other milestone criteria]

---

## Phase 1: Core Features (Est. [N] sessions)

**Goal:** [What this phase accomplishes]

### Tasks
- [ ] **Feature 1: [Name]**
  - [ ] Subtask 1
  - [ ] Subtask 2
  - [ ] Write tests for feature 1
  
- [ ] **Feature 2: [Name]**
  - [ ] Subtask 1
  - [ ] Subtask 2
  - [ ] Write tests for feature 2

**Phase 1 Complete When:**
- [ ] All tasks checked
- [ ] Integration tests pass
- [ ] [Other milestone criteria]

---

## Phase 2: [Phase Name] (Est. [N] sessions)

[Continue pattern...]

---

## Tech Stack & Setup

### Languages & Frameworks
- **Language:** [e.g., TypeScript, Python, etc.]
- **Framework:** [e.g., React, Express, Django, etc.]
- **Database:** [e.g., PostgreSQL, MongoDB, SQLite]
- **Testing:** [e.g., Jest, pytest, etc.]

### Key Dependencies
```
[List important packages/libraries]
```

### Setup Commands
```bash
# Install dependencies
[command]

# Run development server
[command]

# Run tests
[command]

# Run linter
[command]
```

---

## Testing Protocol (MANDATORY)

### After Every Code Change
1. Run unit tests: `[test command]`
2. If new feature: Add integration test
3. If tests fail: FIX before marking task complete

### Test Requirements
- **New functions:** Unit test with 3+ cases
- **New API endpoints:** Integration test
- **New UI components:** Component test (if applicable)
- **Bug fixes:** Regression test

### Quality Gates
- **Session 5:** [Milestone] - [X tests passing]
- **Session 15:** [Milestone] - [Y tests passing]
- **Session 30:** [Milestone] - [Z tests passing]

---

## Development Guidelines

### Definition of Done
A task is complete when:
- [x] Code written and working
- [x] Tests pass (`[test command]`)
- [x] No console errors/warnings
- [x] ROADMAP checkbox marked [x]
- [x] Session log updated
- [x] Git committed

### Code Standards
- [Coding style guidelines]
- [Naming conventions]
- [File organization rules]

### Working Directory Rules
- ✅ **Create files in:** [specific directories]
- ❌ **NEVER create files in:** [protected directories]
- ❌ **NEVER modify:** [protected files]
- ❌ **NEVER delete:** [important data]

---

## Blocker Protocol

If stuck on a task for >15 minutes:
1. Mark task as `[!]` in ROADMAP
2. Document blocker in Notes section below
3. Move to next workable task
4. Revisit at end of session if time permits

---

## Session Log

| Session | Date | Duration | Tasks | Tests | Status | Notes |
|---------|------|----------|-------|-------|--------|-------|
| 1 | [Date] | [Time] | [N tasks] | ✅ [X passing] | ✅ | [Brief note] |
| 2 | [Date] | [Time] | [N tasks] | ✅ [X passing] | ✅ | [Brief note] |

**Velocity Tracking:**
- Sessions 1-5: [X] tasks ([Y] avg/session)
- Sessions 6-10: [X] tasks ([Y] avg/session)

---

## Notes & Context

### Important Decisions
- **[Date]:** [Decision made] - [Rationale]

### Blockers Encountered
- **[Date]:** [Blocker description] - [Resolution or workaround]

### Learnings
- **[Date]:** [What worked well or what to avoid]

---

## Example Code Patterns

### [Pattern 1 Name]
```[language]
// Example of [what this shows]
[code example]
```

### [Pattern 2 Name]
```[language]
// Example of [what this shows]
[code example]
```

---

## References

- **Documentation:** [Links to relevant docs]
- **Related Projects:** [Similar repos for reference]
- **Design Docs:** [Figma, diagrams, etc.]
- **API Specs:** [API documentation]

---

## Future / Post-MVP

Ideas to implement later (NOT now):
- [ ] [Future feature 1]
- [ ] [Future feature 2]
- [ ] [Future feature 3]

**Keep focused on current phase!**
