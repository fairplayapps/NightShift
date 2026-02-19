# Templates Directory

**Copy these templates when starting new projects**

---

## Files

### Core Templates
- **[ROADMAP_TEMPLATE.md](ROADMAP_TEMPLATE.md)** - Complete project roadmap with phases, tasks, testing protocol
- **[PROJECT_SHORTCUT_TEMPLATE.md](PROJECT_SHORTCUT_TEMPLATE.md)** - How to create config.json shortcuts
- **[SESSION_REPORT_TEMPLATE.md](SESSION_REPORT_TEMPLATE.md)** - Track session progress and metrics
- **[QUICKSTART_TEMPLATE.md](QUICKSTART_TEMPLATE.md)** - Quick reference guide for projects

### Guides
- **[NEW_PROJECT_SETUP.md](NEW_PROJECT_SETUP.md)** - Step-by-step setup for new projects

---

## Usage

### Starting a New Project

1. **Copy ROADMAP template:**
   ```powershell
   Copy-Item templates/ROADMAP_TEMPLATE.md C:/YourProject/ROADMAP.md
   ```

2. **Fill in the template:**
   - Replace [Project Name], [Tech Stack], etc.
   - Define Phase 0 tasks (foundation)
   - Define Phase 1 tasks (core features)
   - Add testing protocol
   - Set quality gates

3. **Create project shortcut:**
   - Use PROJECT_SHORTCUT_TEMPLATE.md as guide
   - Add to config.json

4. **Create report directory:**
   ```powershell
   mkdir meta/session_reports/YourProject
   ```

5. **Run test:**
   ```powershell
   .\autonomous_loop.ps1 -Project "YourProject" -MaxSessions 2
   ```

---

## Customization

These templates are starting points. Adjust based on:
- Project type (web app, CLI tool, data analysis, docs)
- Tech stack (React, Python, Rust, etc.)
- Team size (solo vs. team)
- Project phase (greenfield vs. maintenance)

---

## Tips

### ✅ DO:
- Keep templates updated based on learnings
- Add project-specific examples
- Be specific with success criteria
- Include test requirements

### ❌ DON'T:
- Copy templates blindly without customization
- Skip filling in [placeholders]
- Forget to create report directories
- Omit testing protocols

---

**See also:** [docs/BEST_PRACTICES.md](../docs/BEST_PRACTICES.md) for patterns and recommendations
