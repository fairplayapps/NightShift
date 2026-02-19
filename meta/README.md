# Meta Documentation

**Central storage for session reports, learnings, and project tracking**

---

## Structure

```
meta/
├── INDEX.md                 # Central tracking index
├── session_reports/         # Session reports by project
│   ├── ProjectA/
│   │   ├── Session_001.md
│   │   ├── Session_002.md
│   │   └── screenshots/     # Optional
│   └── ProjectB/
│       └── Session_001.md
├── learnings/               # Knowledge base
│   └── PATTERNS.md          # What worked, what didn't
└── archives/                # Old reports (>3 months)
    ├── 2025/
    └── 2024/
```

---

## Purpose

### Session Reports
- **Automatic creation** by autonomous_loop.ps1
- **Track progress** - what changed each session
- **Metrics** - tasks completed, tests passing, velocity
- **Decisions** - technical choices made
- **Blockers** - issues encountered

### Learnings
- **Patterns** - What works well
- **Mistakes** - What to avoid
- **Provider comparisons** - Performance across Claude/Codex
- **Best practices** - Discoveries from real projects

### Archives
- **Old reports** moved here after 3+ months
- **Keeps main directory clean**
- **Historical reference**

---

## How It Works

### Session Reports

When you run autonomous sessions:
```powershell
.\autonomous_loop.ps1 -Project "MyProject"
```

NightShift creates:
```
meta/session_reports/MyProject/Session_001.md
meta/session_reports/MyProject/Session_002.md
...
```

Each report includes:
- Tasks completed
- Files changed
- Tests status
- Blockers
- Next priorities

### Tracking Progress

Check [meta/INDEX.md](INDEX.md) for:
- Active project status
- Session counts
- Velocity trends
- Provider performance
- Blocker tracking

### Learnings Database

Document in [meta/learnings/PATTERNS.md](learnings/PATTERNS.md):
- **What worked:** Successful patterns to reuse
- **What failed:** Mistakes to avoid
- **Provider insights:** Which provider works best for what
- **Decisions:** Important technical choices

---

## Maintenance

### Weekly
- Update INDEX.md with week summary
- Add new patterns to PATTERNS.md
- Review active blockers

### Monthly
- Archive old session reports (>3 months)
- Update velocity statistics
- Review provider performance

### As Needed
- Document major learnings
- Update best practices
- Add decision rationale

---

## Tips

### Naming Conventions

**Session Reports:**
- Format: `Session_NNN.md` (zero-padded)
- Example: `Session_001.md`, `Session_042.md`

**Projects:**
- Use consistent names across config.json and meta/
- Example: "MyProject" not "fool-me-once" or "Fool Me Once"

**Screenshots:**
- `session_NNN_description.png`
- Store in project's `screenshots/` subfolder

### Organization

**Keep session reports organized by project:**
```
meta/session_reports/
├── WebApp/
├── CLI-Tool/
├── DataPipeline/
└── Docs/
```

**Archive regularly:**
```powershell
# Move old reports
Move-Item "meta/session_reports/OldProject" "meta/archives/2025/"
```

---

**See also:** 
- [templates/SESSION_REPORT_TEMPLATE.md](../templates/SESSION_REPORT_TEMPLATE.md) - Report template
- [docs/BEST_PRACTICES.md](../docs/BEST_PRACTICES.md) - Best practices guide
