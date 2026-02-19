# NightShift Setup Wizard
# Interactive configuration for autonomous AI coding sessions

param(
    [switch]$SkipProviderCheck
)

$ErrorActionPreference = "Stop"

# Clear screen and show welcome
Clear-Host
Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                           ║" -ForegroundColor Cyan
Write-Host "║           🤖 NightShift Setup Wizard 🤖                    ║" -ForegroundColor Cyan
Write-Host "║                                                           ║" -ForegroundColor Cyan
Write-Host "║     Autonomous AI Coding Orchestrator for Windows        ║" -ForegroundColor Cyan
Write-Host "║                                                           ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "This wizard will configure NightShift for your project." -ForegroundColor White
Write-Host "It will create config.json and optionally generate a ROADMAP.md." -ForegroundColor White
Write-Host ""

# Get script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$configExamplePath = Join-Path $scriptDir "config.example.json"
$configPath = Join-Path $scriptDir "config.json"
$roadmapTemplatePath = Join-Path $scriptDir "templates\ROADMAP_TEMPLATE.md"

# Check if config already exists
if (Test-Path $configPath) {
    Write-Host "⚠️  config.json already exists!" -ForegroundColor Yellow
    Write-Host ""
    $overwrite = Read-Host "Overwrite existing configuration? (y/n)"
    if ($overwrite -ne "y") {
        Write-Host "Setup cancelled. Existing config.json preserved." -ForegroundColor Green
        exit 0
    }
}

# ============================================================
# STEP 1: Provider Detection
# ============================================================
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "STEP 1: Detecting AI Provider CLIs..." -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$claudeInstalled = $false
$codexInstalled = $false

if (-not $SkipProviderCheck) {
    # Check for Claude Code
    try {
        $claudeResult = Get-Command claude -ErrorAction SilentlyContinue
        if ($claudeResult) {
            Write-Host "✓ Claude Code CLI detected" -ForegroundColor Green
            $claudeInstalled = $true
        }
    }
    catch {
        Write-Host "✗ Claude Code CLI not found" -ForegroundColor Red
    }

    # Check for OpenAI Codex
    try {
        $codexResult = Get-Command codex -ErrorAction SilentlyContinue
        if ($codexResult) {
            Write-Host "✓ OpenAI Codex CLI detected" -ForegroundColor Green
            $codexInstalled = $true
        }
    }
    catch {
        Write-Host "✗ OpenAI Codex CLI not found" -ForegroundColor Red
    }

    # If neither installed, show installation instructions
    if (-not $claudeInstalled -and -not $codexInstalled) {
        Write-Host ""
        Write-Host "❌ No supported AI provider CLI found!" -ForegroundColor Red
        Write-Host ""
        Write-Host "NightShift requires one of the following:" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  1. Claude Code CLI" -ForegroundColor White
        Write-Host "     Install: https://claude.ai/code" -ForegroundColor DarkGray
        Write-Host "     Setup: Follow the installation wizard, authenticate with Anthropic API key" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "  2. OpenAI Codex CLI" -ForegroundColor White
        Write-Host "     Install: npm install -g @openai/codex-cli" -ForegroundColor DarkGray
        Write-Host "     Setup: codex auth (requires OpenAI API key)" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "After installing a provider CLI, run this setup wizard again." -ForegroundColor Yellow
        exit 1
    }
}
else {
    Write-Host "⚠️  Provider check skipped (--SkipProviderCheck flag)" -ForegroundColor Yellow
    $claudeInstalled = $true
    $codexInstalled = $true
}

# ============================================================
# STEP 2: Provider Selection
# ============================================================
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "STEP 2: Choose Your AI Provider" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$provider = ""
if ($claudeInstalled -and $codexInstalled) {
    Write-Host "Both providers detected. Which would you like to use?" -ForegroundColor White
    Write-Host "  1) Claude Code (recommended for most projects)" -ForegroundColor White
    Write-Host "  2) OpenAI Codex" -ForegroundColor White
    Write-Host ""
    $choice = Read-Host "Enter choice (1 or 2)"
    $provider = if ($choice -eq "2") { "codex" } else { "claude" }
}
elseif ($claudeInstalled) {
    $provider = "claude"
    Write-Host "Using: Claude Code" -ForegroundColor Green
}
elseif ($codexInstalled) {
    $provider = "codex"
    Write-Host "Using: OpenAI Codex" -ForegroundColor Green
}

# ============================================================
# STEP 3: Project Configuration
# ============================================================
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "STEP 3: Project Configuration" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Project directory
$defaultProjectDir = (Get-Location).Path
Write-Host "Project directory (where your code lives):" -ForegroundColor White
Write-Host "  Default: $defaultProjectDir" -ForegroundColor DarkGray
$projectDirInput = Read-Host "Press Enter for default, or enter custom path"
$projectDir = if ($projectDirInput) { $projectDirInput } else { $defaultProjectDir }

# Project name
$defaultProjectName = Split-Path -Leaf $projectDir
Write-Host ""
Write-Host "Project name (used for session reports):" -ForegroundColor White
Write-Host "  Default: $defaultProjectName" -ForegroundColor DarkGray
$projectNameInput = Read-Host "Press Enter for default, or enter custom name"
$projectName = if ($projectNameInput) { $projectNameInput } else { $defaultProjectName }

# Test command
Write-Host ""
Write-Host "Test command (runs after code changes):" -ForegroundColor White
Write-Host "  Examples: npm test, pytest, dotnet test, cargo test" -ForegroundColor DarkGray
Write-Host "  Leave empty if no tests" -ForegroundColor DarkGray
$testCommand = Read-Host "Test command (or press Enter to skip)"

# Code directory (where AI should write files)
Write-Host ""
Write-Host "Code directory (where AI writes files):" -ForegroundColor White
Write-Host "  Default: $projectDir" -ForegroundColor DarkGray
$codeDirInput = Read-Host "Press Enter for default, or enter subdirectory (e.g., src/)"
$codeDir = if ($codeDirInput) { Join-Path $projectDir $codeDirInput } else { $projectDir }

# ============================================================
# STEP 4: Session Settings
# ============================================================
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "STEP 4: Session Settings" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Max sessions
Write-Host "Maximum sessions per run:" -ForegroundColor White
Write-Host "  Recommended: 5-10 sessions" -ForegroundColor DarkGray
Write-Host "  You can always Ctrl+C to stop early" -ForegroundColor DarkGray
$maxSessionsInput = Read-Host "Max sessions (default: 5)"
$maxSessions = if ($maxSessionsInput) { [int]$maxSessionsInput } else { 5 }

# Delay
Write-Host ""
Write-Host "Delay between sessions (seconds):" -ForegroundColor White
Write-Host "  Recommended: 30-60 seconds" -ForegroundColor DarkGray
Write-Host "  Prevents rate limits + gives you time to review/interrupt" -ForegroundColor DarkGray
$delayInput = Read-Host "Delay (default: 45)"
$delaySeconds = if ($delayInput) { [int]$delayInput } else { 45 }

# Auto-commit frequency
Write-Host ""
Write-Host "Auto-commit frequency:" -ForegroundColor White
Write-Host "  Commits code every N sessions (e.g., 3 = commits on sessions 3, 6, 9...)" -ForegroundColor DarkGray
Write-Host "  Set to 0 to disable auto-commit" -ForegroundColor DarkGray
$commitFreqInput = Read-Host "Commit every N sessions (default: 3)"
$commitFreq = if ($commitFreqInput) { [int]$commitFreqInput } else { 3 }

# Model selection (only for Claude)
$model = ""
if ($provider -eq "claude") {
    Write-Host ""
    Write-Host "Claude model:" -ForegroundColor White
    Write-Host "  1) sonnet (balanced - recommended)" -ForegroundColor White
    Write-Host "  2) opus (most capable, slower)" -ForegroundColor White
    Write-Host "  3) haiku (fastest, less capable)" -ForegroundColor White
    Write-Host "  4) (leave empty for Claude's default)" -ForegroundColor DarkGray
    $modelChoice = Read-Host "Enter choice (1-4, default: 1)"
    $model = switch ($modelChoice) {
        "2" { "opus" }
        "3" { "haiku" }
        "4" { "" }
        default { "sonnet" }
    }
}

# ============================================================
# STEP 5: ROADMAP.md
# ============================================================
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "STEP 5: ROADMAP.md Setup" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

$roadmapPath = Join-Path $projectDir "ROADMAP.md"
$createRoadmap = $false
$roadmapGoal = ""

if (Test-Path $roadmapPath) {
    Write-Host "✓ ROADMAP.md already exists at:" -ForegroundColor Green
    Write-Host "  $roadmapPath" -ForegroundColor DarkGray
}
else {
    Write-Host "No ROADMAP.md found. NightShift uses ROADMAP.md to track tasks." -ForegroundColor White
    Write-Host ""
    $createChoice = Read-Host "Create a ROADMAP.md now? (y/n, default: y)"
    if ($createChoice -ne "n") {
        $createRoadmap = $true
        Write-Host ""
        Write-Host "What are you working on? (1-2 sentences)" -ForegroundColor White
        Write-Host "  Example: Building a web app for task management with React and Node.js" -ForegroundColor DarkGray
        $roadmapGoal = Read-Host "Project goal"
    }
}

# ============================================================
# STEP 6: Generate Project Shortcut
# ============================================================
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "STEP 6: Generating Configuration..." -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Build project shortcut prompt
$shortcutPrompt = "Autonomous agent. Working directory is PROJECT ROOT. Read ROADMAP.md and find the next unchecked task. Implement 1-2 tasks with actual working code."

if ($testCommand) {
    $shortcutPrompt += " Run $testCommand to verify functionality."
}

$shortcutPrompt += " Update ROADMAP.md checkboxes to mark completed tasks. Create a session report in meta/session_reports/$projectName/. NEVER create files outside the project directory."

# Load config example
$configExample = Get-Content $configExamplePath -Raw | ConvertFrom-Json

# Update config with user inputs
$configExample.provider = $provider
$configExample.project = $projectName
$configExample.maxSessions = $maxSessions
$configExample.delaySeconds = $delaySeconds
$configExample.commitEveryNSessions = $commitFreq
$configExample.defaultModel = $model
$configExample.stopTime = ""
$configExample.timezone = "local"

# Add generated project shortcut
$configExample.projectShortcuts | Add-Member -MemberType NoteProperty -Name $projectName -Value $shortcutPrompt -Force

# Save config
$configExample | ConvertTo-Json -Depth 10 | Set-Content $configPath
Write-Host "✓ Created config.json" -ForegroundColor Green

# Create ROADMAP if requested
if ($createRoadmap) {
    $roadmapContent = @"
# $projectName ROADMAP

## Project Goal
$roadmapGoal

## CURRENT STATUS
**Phase:** Planning
**Progress:** 0/10 tasks completed
**Last Updated:** $(Get-Date -Format "yyyy-MM-dd")

## CURRENT TASK DETAILS
Focus on Phase 1 tasks below. Mark tasks with [x] when complete.

---

## Phase 1: Initial Setup & Foundation
- [ ] Set up project structure and dependencies
- [ ] Create basic architecture/file organization
- [ ] Implement core functionality (first feature)
- [ ] Add initial tests
- [ ] Document setup process

## Phase 2: Core Features
- [ ] Feature 1: [Describe your first major feature]
- [ ] Feature 2: [Describe your second major feature]
- [ ] Feature 3: [Describe your third major feature]
- [ ] Add comprehensive test coverage
- [ ] Document API/usage

## Phase 3: Polish & Deployment
- [ ] Code review and refactoring
- [ ] Performance optimization
- [ ] Error handling and edge cases
- [ ] Deployment setup
- [ ] Final documentation

---

## Notes
- Update checkboxes [x] as tasks complete
- Update CURRENT STATUS after each session
- Add new tasks as needed
- Review and adjust phases based on progress
"@

    Set-Content $roadmapPath $roadmapContent
    Write-Host "✓ Created ROADMAP.md" -ForegroundColor Green
}

# Create meta directories
$metaDir = Join-Path $scriptDir "meta"
$sessionReportsDir = Join-Path $metaDir "session_reports\$projectName"
if (-not (Test-Path $sessionReportsDir)) {
    New-Item -ItemType Directory -Path $sessionReportsDir -Force | Out-Null
    Write-Host "✓ Created session reports directory" -ForegroundColor Green
}

# ============================================================
# STEP 7: Summary
# ============================================================
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "✓ Setup Complete!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "Configuration Summary:" -ForegroundColor White
Write-Host "  Provider: $provider" -ForegroundColor Cyan
Write-Host "  Project: $projectName" -ForegroundColor Cyan
Write-Host "  Max Sessions: $maxSessions" -ForegroundColor Cyan
Write-Host "  Delay: $delaySeconds seconds" -ForegroundColor Cyan
Write-Host "  Auto-commit: Every $commitFreq sessions" -ForegroundColor Cyan
if ($model) {
    Write-Host "  Model: $model" -ForegroundColor Cyan
}
Write-Host ""
Write-Host "Files Created:" -ForegroundColor White
Write-Host "  ✓ config.json" -ForegroundColor Green
if ($createRoadmap) {
    Write-Host "  ✓ ROADMAP.md" -ForegroundColor Green
}
Write-Host "  ✓ meta/session_reports/$projectName/" -ForegroundColor Green
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Review your ROADMAP.md and add specific tasks" -ForegroundColor White
Write-Host "2. Run your first session:" -ForegroundColor White
Write-Host ""
Write-Host "   .\autonomous_loop.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Monitor progress in meta/session_reports/$projectName/" -ForegroundColor White
Write-Host ""
Write-Host "For more information, see README.md or docs/USAGE_GUIDE.md" -ForegroundColor DarkGray
Write-Host ""
