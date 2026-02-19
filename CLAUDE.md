# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

NightShift is a **PowerShell-based autonomous AI coding orchestrator** that runs multi-session AI workflows using Claude Code or OpenAI Codex CLI. It orchestrates AI agents to work autonomously on software projects by reading ROADMAP files, implementing tasks, running tests, and tracking progress.

**Platform**: Windows PowerShell 5.1+
**Primary Language**: PowerShell (.ps1)
**Core Purpose**: Loop execution of AI coding agents with session management, auto-commit, and progress tracking

## Architecture

### Core Components

1. **autonomous_loop.ps1** - Main orchestrator
   - Reads `config.json` for configuration
   - Executes N sessions with configurable delays between each
   - Manages auto-commit/push after every N sessions
   - Implements time-based stopping (stopTime)
   - Handles graceful interruption (Ctrl+C)
   - Imports all library modules

2. **lib/providers.ps1** - Provider abstraction layer
   - `Invoke-Provider`: Dispatches to correct provider based on config
   - `Invoke-Claude`: Runs `claude -p "<prompt>" --allowedTools "<tools>" --model "<model>"`
   - `Invoke-Codex`: Runs `codex exec "<prompt>" --full-auto`
   - `Test-ProviderInstalled`: Validates provider CLI availability

3. **lib/logging.ps1** - Session logging
   - `Write-Log`: Timestamped entries to both console and `logs/autonomous_sessions.log`
   - `Initialize-LogSession`: Session start header
   - `Complete-LogSession`: Session end summary

4. **lib/git-helpers.ps1** - Git automation
   - `Invoke-AutoCommitAndPush`: Auto-commit after every N sessions with structured commit message
   - `Test-GitRepository`: Validates git repository status

5. **NightShift_GUI.ps1** - Windows Forms GUI
   - Visual configuration interface
   - Live output streaming
   - Provider/model/session configuration
   - ROADMAP preview with status parsing
   - Start/Stop controls

### Configuration System

**config.json structure:**
```json
{
  "provider": "claude|codex",
  "project": "ShortcutName",
  "maxSessions": 10,
  "delaySeconds": 45,
  "commitEveryNSessions": 3,
  "defaultModel": "sonnet|opus|haiku",
  "stopTime": "HH:mm",
  "timezone": "EST|PST|UTC|LOCAL",
  "projectShortcuts": {
    "ShortcutName": "Detailed autonomous prompt..."
  }
}
```

**Project Shortcuts** are the heart of the system:
- Each shortcut is a carefully crafted autonomous prompt
- Specifies: working directory, ROADMAP location, task count per session, where to write code, test commands, update requirements
- Includes constraints (NEVER rules) and mandatory protocols (ALWAYS rules)
- Should be 5-15 lines with clear structure

### Session Flow

1. Load config.json and resolve project shortcut
2. Validate provider installation
3. Initialize session logging
4. **Loop** (while sessionCount < maxSessions):
   - Check stopTime (exit if past deadline)
   - Display session header with timestamp
   - Push to projectRoot directory
   - Invoke provider with command/prompt
   - Calculate session duration
   - Log session completion
   - If (sessionCount % commitEveryNSessions == 0): auto-commit and push
   - Countdown delay (checking stopTime each second)
5. Display final summary

## Key Commands

### Running Sessions
```powershell
# Using config.json settings
.\autonomous_loop.ps1

# Override config with parameters
.\autonomous_loop.ps1 -Provider "claude" -Project "MyProject" -MaxSessions 5 -DelaySeconds 60

# Inline custom command (no shortcut)
.\autonomous_loop.ps1 -Project "Read ROADMAP.md and implement next 2 tasks"

# GUI mode
.\Launch_GUI.bat
# or
.\NightShift_GUI.ps1
```

### Testing Providers
```powershell
.\tests\test-claude.ps1
.\tests\test-codex.ps1
```

### Running All Tests
```powershell
.\tests\run-all-tests.ps1
```

## Working with NightShift Code

### Module Import Pattern
All library modules are imported in autonomous_loop.ps1 using dot-sourcing:
```powershell
. (Join-Path $libDir "providers.ps1")
. (Join-Path $libDir "logging.ps1")
. (Join-Path $libDir "git-helpers.ps1")
```

### Adding a New Provider
1. Add provider case to `Invoke-Provider` switch in `lib/providers.ps1`
2. Create `Invoke-<ProviderName>` function with signature:
   ```powershell
   function Invoke-<Provider> {
       param(
           [string]$Command,
           [string]$Model = ""
       )
       # Run provider CLI
   }
   ```
3. Add provider to `Test-ProviderInstalled` validation
4. Update GUI model list in `Get-ModelsForProvider` (NightShift_GUI.ps1)
5. Add test script in `tests/test-<provider>.ps1`
6. Document in `docs/PROVIDERS.md`

### Modifying Session Logic
Key variables in autonomous_loop.ps1:
- `$sessionCount`: Current session number (1-indexed)
- `$startTime`: Overall run start time
- `$logPath`: Path to `logs/autonomous_sessions.log`
- `$command`: Resolved prompt from shortcut or inline
- `$projectRoot`: Parent directory of script location

Main loop is lines 208-300. Modify here for:
- Pre-session checks (lines 211-219)
- Session execution (lines 221-246)
- Post-session actions (lines 252-266)
- Delay countdown (lines 269-298)

### Error Handling Pattern
All functions use try/finally with Push-Location/Pop-Location:
```powershell
Push-Location $targetDir
try {
    # Do work
}
finally {
    Pop-Location
}
```

## Important Constraints

### File Organization
- **NEVER modify** provider CLI installations or global npm packages
- **Session reports** go in `meta/session_reports/[ProjectName]/`
- **Templates** in `templates/` are meant to be copied, not modified directly
- **Logs** auto-append to `logs/autonomous_sessions.log`
- **GUI** only modifies `config.json`, never touches autonomous_loop.ps1

### Provider CLI Requirements
- **Claude**: Requires `claude` CLI in PATH + Anthropic API key
- **Codex**: Requires `codex` CLI in PATH + OpenAI API key
- All providers must be invokable from PowerShell

### Project Shortcut Best Practices
1. Always specify working directory (absolute path)
2. Include ROADMAP.md location
3. Define task count per session (usually 1-2)
4. Specify test command (e.g., `npm test`, `pytest`)
5. Add "NEVER create files in X" constraints
6. Add "ALWAYS update ROADMAP checkboxes" requirements
7. Include session report location
8. Keep under 20 lines for clarity

### Autonomous Operation Philosophy
NightShift is designed for **supervised autonomy**:
- AI agents work independently within defined constraints
- Human reviews progress periodically (every 3-5 sessions)
- Auto-commit provides rollback points
- Delay between sessions allows Ctrl+C intervention
- StopTime prevents overnight overruns

## Common Development Tasks

### Add New Config Option
1. Add field to config.json
2. Add to `$config` read in autonomous_loop.ps1 (lines 36-56)
3. Add parameter to script header (lines 15-24)
4. Add override logic (lines 40-49)
5. Update GUI if visual control needed (NightShift_GUI.ps1)
6. Document in docs/USAGE_GUIDE.md

### Debug Session Execution
1. Check `logs/autonomous_sessions.log` for timestamped entries
2. Review git log: `git log --oneline -20`
3. Read session reports: `meta/session_reports/[Project]/Session_NNN.md`
4. Run single session: `.\autonomous_loop.ps1 -MaxSessions 1`
5. Test provider manually: `claude -p "test prompt"`

### Modify Commit Message Format
Edit `Invoke-AutoCommitAndPush` in `lib/git-helpers.ps1` (lines 46-55):
```powershell
$commitMsg = @"
Your custom message format here
Session: $SessionNumber
"@
```

## File Naming Conventions

- Session reports: `Session_001.md` (zero-padded, 3 digits)
- Test scripts: `test-<component>.ps1`
- Library modules: `<functionality>.ps1` (no prefix)
- Documentation: `UPPERCASE.md` for primary docs, `lowercase.md` for secondary

## Testing Strategy

**Unit tests**: Not implemented (PowerShell module testing complex)
**Integration tests**: Provider CLI tests in `tests/`
**Manual testing**: Run 2-3 session test before long runs
**Validation**: Provider installation checks before execution

## Templates Directory

`templates/` contains **reusable starting points** for new projects:
- `ROADMAP_TEMPLATE.md`: Task breakdown structure
- `PROJECT_SHORTCUT_TEMPLATE.md`: Config.json shortcut format
- `SESSION_REPORT_TEMPLATE.md`: Progress tracking format
- `NEW_PROJECT_SETUP.md`: Complete setup walkthrough
- `QUICKSTART_TEMPLATE.md`: Project quick reference

**Copy these** to new projects, don't modify originals.

## Meta Documentation System

`meta/session_reports/` stores reports by project:
```
meta/
├── session_reports/
│   ├── ProjectA/
│   │   ├── Session_001.md
│   │   └── Session_002.md
│   └── ProjectB/
│       └── Session_001.md
└── learnings/
    └── PATTERNS.md
```

Reports created by AI agents document:
- Tasks completed
- Files created/modified
- Tests run
- Blockers encountered
- Next steps

## GUI Architecture

NightShift_GUI.ps1 is a **Windows Forms application**:
- 3-panel layout: Config (left), Output (right), Control (top)
- Live PowerShell job execution with output streaming
- ROADMAP preview with regex-based status parsing
- Saves to config.json, launches autonomous_loop.ps1 as background job
- Does NOT modify core orchestration logic

## Reference Documentation

- **BEST_PRACTICES.md**: Proven patterns, common pitfalls, advanced strategies
- **USAGE_GUIDE.md**: Step-by-step usage instructions
- **PROVIDERS.md**: Provider installation and authentication
- **STRUCTURE.md**: Complete directory structure explanation
