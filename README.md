# NightShift 🌙

**Autonomous AI Coding Orchestrator for Windows**

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Platform](https://img.shields.io/badge/Platform-Windows-0078d4.svg)](https://github.com/fairplayapps/NightShift)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE.svg)](https://github.com/fairplayapps/NightShift)

NightShift runs multi-session AI coding workflows using Claude Code or OpenAI Codex CLI. Point it at your project, set a ROADMAP, and let it implement tasks autonomously — through the night if you want.

**Perfect for:**
- Autonomous overnight/weekend coding sessions 🌙
- Burning through AI credits before they expire ⏰
- Systematic project implementation without handholding 🎯
- Multi-task workflows with auto-commit checkpoints ✅

---

## Quick Start

**Prerequisites:**
- Windows PowerShell 5.1+ (comes with Windows)
- Claude Code or OpenAI Codex CLI

**Installation:**
1. Clone/download this repository
2. Install an AI CLI (see [Provider Installation](#provider-installation))
3. Run setup: `.\setup.ps1`
4. Start first session: `.\autonomous_loop.ps1`

---

## How It Works

```
1. Read ROADMAP.md → Find next unchecked task
2. Invoke AI provider with task
3. AI implements, runs tests, updates ROADMAP
4. Log session results
5. Delay (prevent rate limits)
6. Auto-commit every N sessions
7. Repeat until done or stopTime hit
```

Press **Ctrl+C anytime** to stop gracefully.

---

## Core Concepts

### ROADMAP.md
Your task list that NightShift reads:

```markdown
## Phase 1: Setup
- [x] Create project structure
- [ ] Add authentication
- [ ] Implement user profiles
```

Use `[ ]` for unchecked, `[x]` for complete. AI marks tasks done.

### Project Shortcuts
Pre-written prompts in `config.json`:

```json
"WebApp": "Read ROADMAP.md, find next task, implement with code, run npm test, update ROADMAP checkboxes, create session report."
```

Setup wizard creates these automatically.

### Session Reports
AI creates reports in `meta/session_reports/<project>/Session_001.md`:
- Tasks completed
- Files modified
- Tests run
- Blockers
- Next steps

---

## Setup Wizard

`.\setup.ps1` configures NightShift interactively:

1. Detects AI providers (Claude/Codex)
2. Asks for project details (name, directory, test command)
3. Configures sessions (max, delay, auto-commit frequency)
4. Creates ROADMAP.md if needed
5. Generates config.json with your shortcuts

---

## Configuration

**config.json:**
```json
{
  "provider": "claude",              // "claude" or "codex"
  "project": "WebApp",               // Shortcut name
  "maxSessions": 5,                  // Max sessions
  "delaySeconds": 45,                // Pause between sessions
  "commitEveryNSessions": 3,         // Auto-commit freq (0=disable)
  "defaultModel": "sonnet",          // "opus", "sonnet", "haiku"
  "stopTime": "23:30",               // Stop time (empty=disabled)
  "timezone": "local",               // "EST", "PST", "UTC", "local"

  "projectShortcuts": {
    "WebApp": "Your prompt here..."
  }
}
```

**Manual Setup (optional):**
```powershell
Copy-Item config.example.json config.json
# Edit config.json
# Create ROADMAP.md from templates/ROADMAP_TEMPLATE.md
.\autonomous_loop.ps1
```

---

## Running Sessions

**Basic:**
```powershell
.\autonomous_loop.ps1  # Uses config.json
```

**Override config:**
```powershell
.\autonomous_loop.ps1 -Provider "claude" -Project "WebApp" -MaxSessions 10
```

**Custom inline prompt:**
```powershell
.\autonomous_loop.ps1 -Project "Read ROADMAP.md and implement next 2 tasks"
```

**Parameters:**
- `-Provider` - "claude" or "codex"
- `-Project` - Shortcut name or inline prompt
- `-MaxSessions` - Max sessions to run
- `-DelaySeconds` - Pause between sessions
- `-CommitEveryNSessions` - Auto-commit frequency
- `-Model` - "opus"/"sonnet"/"haiku" (Claude only)
- `-StopTime` - "HH:mm" format (e.g., "23:30")
- `-Timezone` - "EST"/"PST"/"UTC"/"local"

**Examples:**
```powershell
# 10 sessions with Opus
.\autonomous_loop.ps1 -MaxSessions 10 -Model "opus"

# Run until 11:30 PM, commit every 2 sessions
.\autonomous_loop.ps1 -StopTime "23:30" -CommitEveryNSessions 2

# Quick test (1 session, no delay)
.\autonomous_loop.ps1 -MaxSessions 1 -DelaySeconds 0
```

---

## Writing Good Shortcuts

Include:
1. Working directory
2. ROADMAP location
3. Task count (1-2 recommended)
4. Where to write code
5. Test command
6. Update requirements
7. Constraints ("NEVER...")

**Example:**
```
Autonomous agent. Working directory is PROJECT ROOT. Read ROADMAP.md, find next unchecked task. Implement 1-2 tasks with code. Run npm test. Update ROADMAP.md checkboxes. Create report in meta/session_reports/MyProject/. NEVER create files outside src/.
```

See `templates/PROJECT_SHORTCUT_TEMPLATE.md` for more.

---

## ROADMAP.md Best Practices

**Required sections:**
```markdown
## CURRENT STATUS
**Phase:** Planning
**Progress:** 2/10 tasks completed

## CURRENT TASK DETAILS
Focus on Phase 1 setup tasks

## Phase 1: Setup
- [x] Project structure
- [ ] Authentication
- [ ] User profiles
```

**Tips:**
- Break tasks small (1 session each)
- Use clear descriptions
- Update CURRENT STATUS regularly
- Group by phases
- Add context notes

---

## Advanced Features

**Auto-Commit:**
```json
"commitEveryNSessions": 3  // Commits on sessions 3, 6, 9...
```

Messages include session count and AI attribution.

**Time-Based Stopping:**
```json
"stopTime": "23:30",
"timezone": "EST"
```

Prevents overnight overruns.

**Session Reports:**
```json
"WebApp": "...Create report in meta/session_reports/WebApp/Session_NNN.md"
```

**Learning Patterns:**
Document in `meta/learnings/PATTERNS.md`:
- Successful workflows
- Mistakes to avoid
- Provider performance
- Project-specific practices

---

## Troubleshooting

**"Provider CLI not found"**
- Install: https://claude.ai/code or `npm install -g @openai/codex-cli`

**"config.json not found"**
- Run `.\setup.ps1` or `Copy-Item config.example.json config.json`

**Sessions fail immediately**
- Check provider CLI authenticated: `claude --version`
- ROADMAP.md exists?
- Check `logs/autonomous_sessions.log`

**Git commits fail**
- Is it a git repo? `git status`
- Git identity configured? `git config user.name`

**AI makes same mistakes**
- Add constraints: "NEVER [mistake]"
- Add rules: "ALWAYS [behavior]"
- Try different model (Sonnet → Opus)

**Rate limits**
- Increase `delaySeconds` (60-120)
- Reduce `maxSessions`

---

## Provider Installation

### Claude Code (Recommended)

1. Install from https://claude.ai/code
2. Authenticate with Anthropic API key (from https://console.anthropic.com/)
3. Verify: `claude --version`

**Models:**
- `opus` - Most capable
- `sonnet` - Balanced (recommended)
- `haiku` - Fastest

### OpenAI Codex CLI

1. Install: `npm install -g @openai/codex-cli`
2. Auth: `codex auth` (OpenAI API key from https://platform.openai.com/api-keys)
3. Verify: `codex --version`

---

## Architecture

- `autonomous_loop.ps1` - Main orchestrator
- `lib/providers.ps1` - Provider abstraction
- `lib/logging.ps1` - Session logging
- `lib/git-helpers.ps1` - Auto-commit
- `setup.ps1` - Setup wizard
- `config.json` - User configuration

See [CLAUDE.md](CLAUDE.md) for detailed architecture.

---

## Testing

```powershell
.\tests\run-all-tests.ps1  # Run all tests
.\tests\test-claude.ps1     # Test specific provider
```

Tests cover providers, config, helpers, error handling.

---

## GUI ⚠️ Experimental

> **NOT PRODUCTION READY**
> The GUI has known bugs and has not been fully tested. It may crash, hang, or produce unexpected results. For reliable, stable operation always use the CLI (`autonomous_loop.ps1`) directly. The GUI is a convenience wrapper only.

If you still want to try it:

```powershell
.\NightShift_GUI.ps1
# or
.\Launch_GUI.bat
```

See [GUI_README.md](GUI_README.md) for details.

---

## Project Structure

```
NightShift/
├── autonomous_loop.ps1          # Main script
├── setup.ps1                    # Setup wizard
├── config.example.json          # Config template
├── lib/                         # Core libraries
├── docs/                        # Documentation
├── templates/                   # Starter files
├── meta/                        # Session tracking
├── tests/                       # Test suite
└── logs/                        # Session logs
```

---

## FAQ

**Q: Will this use all my API credits?**
A: Yes, that's the point! Control with `maxSessions` and `stopTime`.

**Q: Can I run overnight?**
A: Yes. Set `stopTime` and `commitEveryNSessions`.

**Q: What if AI makes mistakes?**
A: Ctrl+C to stop, review last commit, adjust shortcut constraints.

**Q: GitHub Copilot support?**
A: Removed. Use Claude Code or OpenAI Codex.

**Q: Need to babysit?**
A: No! Set and forget. Check `meta/session_reports/` later.

**Q: Multiple projects?**
A: Switch via `config.json` or different shortcuts (not simultaneous).

**Q: Windows-only?**
A: Yes. PowerShell 5.1+ required.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for bug reports and pull requests.

---

## License

GPL v3 - See [LICENSE](LICENSE)

---

## Documentation

- **Getting Started:** This README + `.\setup.ps1`
- **Detailed Usage:** `docs/USAGE_GUIDE.md`
- **Best Practices:** `docs/BEST_PRACTICES.md`
- **Provider Setup:** `docs/PROVIDERS.md`
- **Templates:** `templates/` folder

---

**Built for vibe coders who want AI to do the work while they sleep.** 😴🤖
