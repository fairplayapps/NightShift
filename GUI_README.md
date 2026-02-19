# NightShift GUI Launcher 🖱️

**Visual interface for NightShift - No command line needed!**

> ⚠️ **EXPERIMENTAL - NOT FULLY TESTED**
> This GUI has not been thoroughly tested. For production use, we recommend using
> `autonomous_loop.ps1` directly from the command line. Use the GUI at your own risk.

---

## Quick Start

**Double-click:** `Launch_GUI.bat`

That's it! The GUI will open.

---

## Features

### 🎛️ Visual Configuration
- **Provider Selection** - Choose Claude or Codex
- **Project Input** - Enter project shortcut name
- **Session Settings** - Max sessions, delay between sessions
- **Commit Settings** - Auto-commit frequency
- **Model Selection** - Choose Claude model (sonnet/opus/haiku)
- **Stop Time** - Set automatic stop time (e.g., 23:30)

### 🎮 Controls
- **📂 Load Config** - Load settings from config.json
- **💾 Save Config** - Save current settings to config.json
- **▶️ RUN** - Start autonomous sessions
- **⏹️ STOP** - Stop running sessions immediately
- **📊 View Reports** - Open session reports folder

### 📺 Live Output
- Real-time log display
- See what NightShift is doing
- Status updates
- Process completion notifications

---

## Usage

### 1. Configure Settings

Fill in the fields:
- **Provider:** Select your AI provider
- **Project Shortcut:** Enter project name from config.json
- **Max Sessions:** How many sessions to run (1-100)
- **Delay (sec):** Pause between sessions (10-600)
- **Commit Every N:** Auto-commit frequency (0 = disabled)
- **Model:** Claude model to use
- **Stop Time:** Optional stop time (24h format)
- **Timezone:** For stop time (e.g., EST)

### 2. Save Configuration (Optional)

Click **💾 Save Config** to save to config.json

### 3. Run Autonomous Sessions

Click **▶️ RUN** to start

- GUI will show live updates
- Process runs in background
- Check `autonomous_sessions.log` for detailed output

### 4. Stop If Needed

Click **⏹️ STOP** to halt immediately

---

## Tips

### ✅ DO:
- **Load config first** - Click 📂 Load Config to get current settings
- **Save before long runs** - Save config before overnight runs
- **Watch the log** - Monitor output for issues
- **Use Stop button** - Clean shutdown of sessions

### 💡 Pro Tips:
- **Desktop shortcut:** Right-click Launch_GUI.bat → Send to Desktop
- **Test first:** Start with 2-3 sessions to test configuration
- **Reports:** Click 📊 View Reports to see session output
- **Command line still works:** GUI is optional convenience

---

## Keyboard Shortcuts

- **Alt+R** - Run (when RUN button focused)
- **Alt+S** - Stop (when STOP button focused)
- **Escape** - Close GUI window

---

## Troubleshooting

### GUI won't open
**Issue:** Script execution disabled  
**Fix:** Run PowerShell as Admin:
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Process won't start
**Issue:** Provider not installed
**Fix:** Install the provider:
```powershell
# Claude
npm install -g @anthropic-ai/claude-code

# Codex
npm install -g @openai/codex
```

### Can't stop process
**Issue:** Process not responding  
**Fix:** Close GUI window (will force-kill process)

---

## Technical Details

- **Built with:** PowerShell Windows Forms
- **Requires:** Windows, PowerShell 5.1+
- **Dependencies:** None (uses built-in .NET assemblies)
- **Process management:** Background PowerShell process
- **Log location:** `autonomous_sessions.log`

---

## Alternative: Command Line

Prefer terminal? You can still use:

```powershell
.\autonomous_loop.ps1
```

GUI is optional convenience. Both methods work!

---

## Screenshots

**Main Window:**
```
┌─────────────────────────────────────────┐
│ NightShift Control Center 🤖              │
├─────────────────────────────────────────┤
│ Provider: [claude ▼]                    │
│ Project:  [MyProject_____________]     │
│ Sessions: [5]      Delay: [45] sec      │
│ Commit:   [3]      Model: [sonnet ▼]    │
│ Stop:     [23:30]  Zone:  [EST]         │
├─────────────────────────────────────────┤
│ [📂 Load] [💾 Save] [▶️ RUN] [⏹️ STOP] │
├─────────────────────────────────────────┤
│ Output Log:                              │
│ ┌─────────────────────────────────────┐ │
│ │ [10:30:15] NightShift GUI - Ready    │ │
│ │ [10:30:15] Loaded config.json       │ │
│ │ [10:31:42] Starting NightShift...    │ │
│ │                                     │ │
│ └─────────────────────────────────────┘ │
├─────────────────────────────────────────┤
│ Ready - Configure and click RUN         │
└─────────────────────────────────────────┘
```

---

**Enjoy visual autonomous coding!** 🚀
