# Learnings & Patterns

**Knowledge base of what works and what doesn't**

---

## What Worked Well

### [Date] - [Project] - [Pattern Name]

**Context:** [Situation]

**Approach:** [What we did]

**Result:** [Positive outcome]

**Reusable Pattern:** [How to apply this elsewhere]

---

### Example: Detailed Task Success Criteria

**Date:** 2026-02-07  
**Project:** All projects  
**Pattern:** Adding detailed success criteria to ROADMAP tasks

**Context:** Vague tasks like "Add authentication" led to incomplete or misdirected work.

**Approach:** 
```markdown
- [ ] Add JWT authentication
  - POST /api/login endpoint
  - Accepts email + password
  - Returns JWT token (24h expiry)
  - Add authenticateToken() middleware
  - 5 test cases (valid, invalid, expired, etc.)
```

**Result:** 
- 95% task completion rate (vs 60% before)
- Fewer iterations needed
- More consistent quality

**Reusable Pattern:** 
For any task, add:
1. What to create
2. Where it goes
3. How to test it
4. Success criteria

---

## Mistakes to Avoid

### [Date] - [Project] - [Issue Name]

**What Happened:** [Description of problem]

**Why It Happened:** [Root cause]

**Impact:** [Consequences]

**How to Avoid:** [Prevention strategy]

---

### Example: Missing Test Requirements

**Date:** 2026-02-05  
**Project:** WebApp  
**Issue:** Code completed but no tests written

**What Happened:** 
10 sessions of work, feature worked, but zero tests. Had to spend 5 additional sessions writing tests retroactively.

**Why It Happened:** 
Project shortcut didn't mandate tests. ROADMAP had "write tests" as optional followup task.

**Impact:**
- Extra 5 sessions (50% more time)
- Some bugs found late
- Harder to test completed code

**How to Avoid:**
1. Add to shortcut: "TESTING MANDATORY: New functions require unit tests. New endpoints require integration tests."
2. In ROADMAP: Make tests part of task, not separate
   ```markdown
   - [ ] Add login endpoint
     - Implementation in src/auth/login.js
     - Integration test in tests/auth/login.test.js (5+ cases)
   ```
3. Quality gate: "Session 10 checkpoint: 20+ tests passing"

---

## Provider Comparisons

### Claude Sonnet 4.5

**Strengths:**
- [What it does well]
- [Pattern it excels at]

**Weaknesses:**
- [What struggles with]
- [When to avoid]

**Best For:**
- [Use case 1]
- [Use case 2]

**Cost:** [Typical per session]

---

### OpenAI Codex CLI

**Strengths:**

**Weaknesses:**

**Best For:**

**Cost:**

---

## Common Patterns

### Pattern: Example-Driven Development

**When to use:** Complex implementations, unfamiliar APIs, consistent style needed

**How:**
1. In ROADMAP, add example code block
2. Show desired structure/style
3. Ask AI to follow pattern

**Example:**
```markdown
## Current Task
Add validation for user inputs

### Follow This Pattern
File: `src/validators/emailValidator.js`
\```javascript
export function validateEmail(email) {
  if (!email || typeof email !== 'string') {
    return { valid: false, error: 'Email required' };
  }
  // ... rest of validation
  return { valid: true };
}
\```

Create similar validators for password and username.
```

**Success Rate:** 90%+ tasks follow pattern correctly

---

### Pattern: Blocker Protocol

**When to use:** Complex projects, new technologies, high uncertainty

**How:**
Add to shortcut:
```json
"If stuck >15 min: (1) Mark task [!] in ROADMAP, (2) Document blocker in NOTES, (3) Move to next task, (4) Revisit at end"
```

**Result:** 
- Prevents infinite loops
- Documents issues for review
- Maintains forward progress

---

### Pattern: Quality Gates

**When to use:** Long-running projects, critical quality requirements

**How:**
```markdown
## Quality Gates
- Session 5: Foundation (tests pass, basic features work)
- Session 15: Core complete (all CRUD, 30+ tests)
- Session 30: polish (E2E tests, docs, deploy ready)
```

**Result:**
- Clear milestones
- Early detection of issues
- Measurable progress

---

## Technology-Specific Notes

### React + TypeScript

**What Works:**
- Component-first approach
- Test each component before moving on
- Use existing component as template

**Gotchas:**
- Type definitions need explicit instruction
- PropTypes vs TypeScript interfaces

**Best Practice:**
Always provide component template in ROADMAP

---

### Python + Flask/Django

**What Works:**
- [Fill in based on experience]

**Gotchas:**
- [Common issues]

**Best Practice:**
- [Recommendations]

---

### Node.js + Express

**What Works:**
- [Fill in based on experience]

**Gotchas:**
- [Common issues]

**Best Practice:**
- [Recommendations]

---

## Session Management Insights

### Optimal Settings by Project Type

**New Project (unknown territory):**
```json
{
  "maxSessions": 3,
  "delaySeconds": 60,
  "commitEveryNSessions": 1
}
```

**Established Project (proven patterns):**
```json
{
  "maxSessions": 10,
  "delaySeconds": 90,
  "commitEveryNSessions": 3
}
```

**Production-Critical (high risk):**
```json
{
  "maxSessions": 5,
  "delaySeconds": 120,
  "commitEveryNSessions": 1
}
```

---

## Decision Log

### [Date] - [Decision Topic]

**Context:** [Situation requiring decision]

**Options Considered:**
1. [Option 1] - [Pros/Cons]
2. [Option 2] - [Pros/Cons]

**Decision:** [What was chosen]

**Rationale:** [Why this choice]

**Result:** [How it worked out]

---

## TODO: Future Improvements

- [ ] [Idea for NightShift improvement]
- [ ] [ROADMAP template enhancement]
- [ ] [New pattern to document]

---

**Last Updated:** [Date]
