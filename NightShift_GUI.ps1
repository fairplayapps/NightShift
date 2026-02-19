# NightShift Control Center
# Comprehensive visual interface for autonomous AI coding sessions
#
# ⚠️  WARNING: This GUI is EXPERIMENTAL and has not been fully tested!
# ⚠️  For production use, please use autonomous_loop.ps1 directly from the command line.
# ⚠️  The GUI may have bugs or incomplete features. Use at your own risk.

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Paths and Globals ---
$scriptDir    = Split-Path -Parent $MyInvocation.MyCommand.Path
$configPath   = Join-Path $scriptDir "config.json"
$loopScript   = Join-Path $scriptDir "autonomous_loop.ps1"
$metaDir      = Join-Path $scriptDir "meta"
$reportsDir   = Join-Path $metaDir   "session_reports"
$learningsDir = Join-Path $metaDir   "learnings"
$templatesDir = Join-Path $scriptDir "templates"
$logFilePath  = Join-Path $scriptDir "autonomous_sessions.log"

$global:runnerProcess = $null
$global:config        = $null
$global:openWorkDirBtn = $null

# --- Helper Functions ---

function Load-Config {
    if (Test-Path $configPath) {
        return Get-Content $configPath -Raw | ConvertFrom-Json
    }
    return $null
}

function Save-Config {
    param($cfg)
    $cfg | ConvertTo-Json -Depth 10 | Set-Content $configPath -Encoding UTF8
}

function Get-ShortcutNames {
    $cfg = Load-Config
    if ($cfg -and $cfg.projectShortcuts) {
        return ($cfg.projectShortcuts | Get-Member -MemberType NoteProperty).Name
    }
    return @()
}

function Get-ModelsForProvider {
    param([string]$provider)
    switch ($provider) {
        "claude"  { return @("sonnet", "opus", "haiku") }
        "codex"   { return @("(auto - Codex)") }
        default   { return @("sonnet", "opus", "haiku") }
    }
}

function Find-Roadmap {
    param([string]$dir)
    if (-not $dir -or -not (Test-Path $dir)) { return "" }
    $candidates = @(
        (Join-Path $dir "ROADMAP.md"),
        (Join-Path $dir "roadmap.md"),
        (Join-Path $dir "Roadmap.md")
    )
    foreach ($c in $candidates) {
        if (Test-Path $c) { return $c }
    }
    $found = Get-ChildItem $dir -Filter "ROADMAP.md" -Recurse -Depth 2 -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if ($found) { return $found.FullName }
    return ""
}

function Get-RoadmapStatus {
    param([string]$roadmapPath)
    if (-not $roadmapPath -or -not (Test-Path $roadmapPath)) { return "(no ROADMAP found)" }
    $content = Get-Content $roadmapPath -Raw -ErrorAction SilentlyContinue
    if ($content -match '(?s)## Current Status\s*\r?\n(.+?)(?=\r?\n## |\r?\n---|\z)') {
        $status = $Matches[1].Trim()
        if ($status.Length -gt 300) { $status = $status.Substring(0, 300) + "..." }
        return $status
    }
    if ($content -match '(?s)## Current Task\s*\r?\n(.+?)(?=\r?\n## |\r?\n---|\z)') {
        $task = $Matches[1].Trim()
        if ($task.Length -gt 300) { $task = $task.Substring(0, 300) + "..." }
        return $task
    }
    return "(ROADMAP found - no Current Status/Task section)"
}

function Update-ButtonStates {
    # Update Open Roadmap button
    if ($roadmapText.Text -and (Test-Path $roadmapText.Text)) {
        $openRmBtn.Enabled = $true
    } else {
        $openRmBtn.Enabled = $false
    }
    
    # Update Open Work Dir button
    if ($global:openWorkDirBtn) {
        if ($wdText.Text -and (Test-Path $wdText.Text)) {
            $global:openWorkDirBtn.Enabled = $true
        } else {
            $global:openWorkDirBtn.Enabled = $false
        }
    }
}

function Log-Message {
    param([string]$msg)
    $ts = Get-Date -Format "HH:mm:ss"
    $logBox.AppendText("[$ts] $msg`r`n")
    $logBox.SelectionStart = $logBox.TextLength
    $logBox.ScrollToCaret()
}

# --- Colors ---
$bgMain      = [System.Drawing.Color]::FromArgb(30, 30, 36)
$bgPanel     = [System.Drawing.Color]::FromArgb(40, 42, 54)
$bgInput     = [System.Drawing.Color]::FromArgb(55, 58, 72)
$fgPrimary   = [System.Drawing.Color]::FromArgb(230, 230, 240)
$fgSecondary = [System.Drawing.Color]::FromArgb(160, 165, 180)
$fgAccent    = [System.Drawing.Color]::FromArgb(80, 200, 255)
$fgGreen     = [System.Drawing.Color]::FromArgb(80, 220, 100)
$fgRed       = [System.Drawing.Color]::FromArgb(255, 85, 85)
$fgYellow    = [System.Drawing.Color]::FromArgb(255, 200, 50)
$btnGreen    = [System.Drawing.Color]::FromArgb(40, 167, 69)
$btnRed      = [System.Drawing.Color]::FromArgb(220, 53, 69)
$btnBlue     = [System.Drawing.Color]::FromArgb(0, 123, 255)
$btnGray     = [System.Drawing.Color]::FromArgb(65, 70, 85)

$fontNormal  = New-Object System.Drawing.Font("Segoe UI", 9)
$fontBold    = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$fontSmall   = New-Object System.Drawing.Font("Segoe UI", 8)
$fontTitle   = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$fontClock   = New-Object System.Drawing.Font("Consolas", 14, [System.Drawing.FontStyle]::Bold)
$fontMono    = New-Object System.Drawing.Font("Consolas", 9)
$fontSection = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)

# --- Main Form ---
$form = New-Object System.Windows.Forms.Form
$form.Text          = "NightShift Control Center"
$form.Size          = New-Object System.Drawing.Size(1400, 1100)
$form.MinimumSize   = New-Object System.Drawing.Size(1100, 850)
$form.StartPosition = "CenterScreen"
$form.BackColor     = $bgMain
$form.ForeColor     = $fgPrimary
$form.Font          = $fontNormal
$form.KeyPreview    = $true

# ============================================================
# HEADER PANEL - Title + Live Clock
# ============================================================
$headerPanel = New-Object System.Windows.Forms.Panel
$headerPanel.Dock      = "Top"
$headerPanel.Height    = 60
$headerPanel.BackColor = [System.Drawing.Color]::FromArgb(20, 22, 28)
$form.Controls.Add($headerPanel)

$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Location  = New-Object System.Drawing.Point(20, 12)
$titleLabel.Size      = New-Object System.Drawing.Size(180, 35)
$titleLabel.Text      = "NIGHTSHIFT"
$titleLabel.Font      = $fontTitle
$titleLabel.ForeColor = $fgAccent
$headerPanel.Controls.Add($titleLabel)

$subtitleLabel = New-Object System.Windows.Forms.Label
$subtitleLabel.Location  = New-Object System.Drawing.Point(195, 22)
$subtitleLabel.Size      = New-Object System.Drawing.Size(280, 20)
$subtitleLabel.Text      = "Autonomous AI Coding Orchestrator"
$subtitleLabel.Font      = $fontSmall
$subtitleLabel.ForeColor = $fgSecondary
$headerPanel.Controls.Add($subtitleLabel)

$clockLabel = New-Object System.Windows.Forms.Label
$clockLabel.Location  = New-Object System.Drawing.Point(600, 8)
$clockLabel.Size      = New-Object System.Drawing.Size(250, 24)
$clockLabel.Font      = $fontClock
$clockLabel.ForeColor = $fgAccent
$clockLabel.TextAlign = [System.Drawing.ContentAlignment]::TopRight
$clockLabel.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
$headerPanel.Controls.Add($clockLabel)

$clockDateLabel = New-Object System.Windows.Forms.Label
$clockDateLabel.Location  = New-Object System.Drawing.Point(600, 34)
$clockDateLabel.Size      = New-Object System.Drawing.Size(250, 18)
$clockDateLabel.Font      = $fontSmall
$clockDateLabel.ForeColor = $fgSecondary
$clockDateLabel.TextAlign = [System.Drawing.ContentAlignment]::TopRight
$clockDateLabel.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
$headerPanel.Controls.Add($clockDateLabel)

# ============================================================
# STATUS BAR
# ============================================================
$statusBar = New-Object System.Windows.Forms.Label
$statusBar.Location  = New-Object System.Drawing.Point(0, 60)
$statusBar.Size      = New-Object System.Drawing.Size(1400, 32)
$statusBar.Font      = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$statusBar.ForeColor = $fgSecondary
$statusBar.BackColor = $bgPanel
$statusBar.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
$statusBar.Text      = "   IDLE  --  Configure settings and click RUN"
$statusBar.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
$form.Controls.Add($statusBar)

# ============================================================
# LEFT COLUMN - Provider, Model, Session Settings
# ============================================================
$y = 105

# GroupBox for Provider Settings
$provGroupBox = New-Object System.Windows.Forms.GroupBox
$provGroupBox.Location  = New-Object System.Drawing.Point(15, $y)
$provGroupBox.Size      = New-Object System.Drawing.Size(650, 140)
$provGroupBox.Text      = "PROVIDER and MODEL"
$provGroupBox.Font      = $fontSection
$provGroupBox.ForeColor = $fgAccent
$provGroupBox.FlatStyle = "Flat"
$form.Controls.Add($provGroupBox)

$y += 30

# Provider
$provLabel = New-Object System.Windows.Forms.Label
$provLabel.Location  = New-Object System.Drawing.Point(15, 27)
$provLabel.Size      = New-Object System.Drawing.Size(70, 20)
$provLabel.Text      = "Provider:"
$provLabel.ForeColor = $fgSecondary
$provGroupBox.Controls.Add($provLabel)

$providerCombo = New-Object System.Windows.Forms.ComboBox
$providerCombo.Location      = New-Object System.Drawing.Point(90, 25)
$providerCombo.Size          = New-Object System.Drawing.Size(140, 25)
$providerCombo.DropDownStyle = "DropDownList"
$providerCombo.BackColor     = $bgInput
$providerCombo.ForeColor     = $fgPrimary
$providerCombo.FlatStyle     = "Flat"
@("claude", "codex") | ForEach-Object { $providerCombo.Items.Add($_) | Out-Null }
$provGroupBox.Controls.Add($providerCombo)

# Model
$modelLabel = New-Object System.Windows.Forms.Label
$modelLabel.Location  = New-Object System.Drawing.Point(250, 27)
$modelLabel.Size      = New-Object System.Drawing.Size(50, 20)
$modelLabel.Text      = "Model:"
$modelLabel.ForeColor = $fgSecondary
$provGroupBox.Controls.Add($modelLabel)

$modelCombo = New-Object System.Windows.Forms.ComboBox
$modelCombo.Location      = New-Object System.Drawing.Point(305, 25)
$modelCombo.Size          = New-Object System.Drawing.Size(180, 25)
$modelCombo.DropDownStyle = "DropDownList"
$modelCombo.BackColor     = $bgInput
$modelCombo.ForeColor     = $fgPrimary
$modelCombo.FlatStyle     = "Flat"
@("sonnet", "opus", "haiku") | ForEach-Object { $modelCombo.Items.Add($_) | Out-Null }
$provGroupBox.Controls.Add($modelCombo)

# Provider changes model list
$providerCombo.Add_SelectedIndexChanged({
    $modelCombo.Items.Clear()
    $models = Get-ModelsForProvider $providerCombo.SelectedItem
    foreach ($m in $models) { $modelCombo.Items.Add($m) | Out-Null }
    $modelCombo.SelectedIndex = 0
})

# Session Settings Label in GroupBox
$sessLabel2 = New-Object System.Windows.Forms.Label
$sessLabel2.Location  = New-Object System.Drawing.Point(15, 62)
$sessLabel2.Size      = New-Object System.Drawing.Size(620, 20)
$sessLabel2.Text      = "SESSION SETTINGS"
$sessLabel2.Font      = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$sessLabel2.ForeColor = $fgAccent
$provGroupBox.Controls.Add($sessLabel2)

# Sessions
$sessLabel = New-Object System.Windows.Forms.Label
$sessLabel.Location  = New-Object System.Drawing.Point(15, 87)
$sessLabel.Size      = New-Object System.Drawing.Size(70, 20)
$sessLabel.Text      = "Sessions:"
$sessLabel.ForeColor = $fgSecondary
$provGroupBox.Controls.Add($sessLabel)

$sessionsNumeric = New-Object System.Windows.Forms.NumericUpDown
$sessionsNumeric.Location  = New-Object System.Drawing.Point(90, 85)
$sessionsNumeric.Size      = New-Object System.Drawing.Size(70, 25)
$sessionsNumeric.Minimum   = 1
$sessionsNumeric.Maximum   = 200
$sessionsNumeric.Value     = 10
$sessionsNumeric.BackColor = $bgInput
$sessionsNumeric.ForeColor = $fgPrimary
$provGroupBox.Controls.Add($sessionsNumeric)

# Delay
$delayLabel = New-Object System.Windows.Forms.Label
$delayLabel.Location  = New-Object System.Drawing.Point(175, 87)
$delayLabel.Size      = New-Object System.Drawing.Size(65, 20)
$delayLabel.Text      = "Delay (s):"
$delayLabel.ForeColor = $fgSecondary
$provGroupBox.Controls.Add($delayLabel)

$delayNumeric = New-Object System.Windows.Forms.NumericUpDown
$delayNumeric.Location  = New-Object System.Drawing.Point(245, 85)
$delayNumeric.Size      = New-Object System.Drawing.Size(70, 25)
$delayNumeric.Minimum   = 10
$delayNumeric.Maximum   = 900
$delayNumeric.Increment = 5
$delayNumeric.Value     = 45
$delayNumeric.BackColor = $bgInput
$delayNumeric.ForeColor = $fgPrimary
$provGroupBox.Controls.Add($delayNumeric)

# Commit
$commitLabel = New-Object System.Windows.Forms.Label
$commitLabel.Location  = New-Object System.Drawing.Point(330, 87)
$commitLabel.Size      = New-Object System.Drawing.Size(55, 20)
$commitLabel.Text      = "Commit:"
$commitLabel.ForeColor = $fgSecondary
$provGroupBox.Controls.Add($commitLabel)

$commitNumeric = New-Object System.Windows.Forms.NumericUpDown
$commitNumeric.Location  = New-Object System.Drawing.Point(390, 85)
$commitNumeric.Size      = New-Object System.Drawing.Size(60, 25)
$commitNumeric.Minimum   = 0
$commitNumeric.Maximum   = 50
$commitNumeric.Value     = 3
$commitNumeric.BackColor = $bgInput
$commitNumeric.ForeColor = $fgPrimary
$provGroupBox.Controls.Add($commitNumeric)

# Stop time
$stopLabel = New-Object System.Windows.Forms.Label
$stopLabel.Location  = New-Object System.Drawing.Point(470, 87)
$stopLabel.Size      = New-Object System.Drawing.Size(60, 20)
$stopLabel.Text      = "Stop at:"
$stopLabel.ForeColor = $fgSecondary
$provGroupBox.Controls.Add($stopLabel)

$stopTimeText = New-Object System.Windows.Forms.TextBox
$stopTimeText.Location    = New-Object System.Drawing.Point(535, 85)
$stopTimeText.Size        = New-Object System.Drawing.Size(70, 25)
$stopTimeText.BackColor   = $bgInput
$stopTimeText.ForeColor   = $fgPrimary
$stopTimeText.BorderStyle = "FixedSingle"
$provGroupBox.Controls.Add($stopTimeText)

# Stop time validation indicator
$stopValidLabel = New-Object System.Windows.Forms.Label
$stopValidLabel.Location  = New-Object System.Drawing.Point(610, 88)
$stopValidLabel.Size      = New-Object System.Drawing.Size(20, 20)
$stopValidLabel.Text      = ""
$stopValidLabel.Font      = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$provGroupBox.Controls.Add($stopValidLabel)

$stopTimeText.Add_TextChanged({
    if ([string]::IsNullOrWhiteSpace($stopTimeText.Text)) {
        $stopValidLabel.Text = ""
    } elseif ($stopTimeText.Text -match '^([01]?[0-9]|2[0-3]):[0-5][0-9]$') {
        $stopValidLabel.Text = "OK"
        $stopValidLabel.ForeColor = $fgGreen
    } else {
        $stopValidLabel.Text = "!"
        $stopValidLabel.ForeColor = $fgRed
    }
})

$stopHint = New-Object System.Windows.Forms.Label
$stopHint.Location  = New-Object System.Drawing.Point(15, 113)
$stopHint.Size      = New-Object System.Drawing.Size(620, 18)
$stopHint.Text      = "Stop Time: 24h format e.g. 23:30 (leave blank for no limit)"
$stopHint.Font      = $fontSmall
$stopHint.ForeColor = [System.Drawing.Color]::FromArgb(120, 125, 140)
$provGroupBox.Controls.Add($stopHint)

$y += 155

# ============================================================
# RIGHT COLUMN - Project Selection
# ============================================================
$rX = 680
$rY = 105

# GroupBox for Project Settings
$projGroupBox = New-Object System.Windows.Forms.GroupBox
$projGroupBox.Location  = New-Object System.Drawing.Point($rX, $rY)
$projGroupBox.Size      = New-Object System.Drawing.Size(685, 285)
$projGroupBox.Text      = "PROJECT"
$projGroupBox.Font      = $fontSection
$projGroupBox.ForeColor = $fgAccent
$projGroupBox.FlatStyle = "Flat"
$form.Controls.Add($projGroupBox)

$rY = 30

# Shortcut Dropdown
$scLabel = New-Object System.Windows.Forms.Label
$scLabel.Location  = New-Object System.Drawing.Point(15, $rY)
$scLabel.Size      = New-Object System.Drawing.Size(75, 20)
$scLabel.Text      = "Shortcut:"
$scLabel.ForeColor = $fgSecondary
$projGroupBox.Controls.Add($scLabel)

$shortcutCombo = New-Object System.Windows.Forms.ComboBox
$shortcutCombo.Location      = New-Object System.Drawing.Point(95, ($rY - 2))
$shortcutCombo.Size          = New-Object System.Drawing.Size(220, 25)
$shortcutCombo.DropDownStyle = "DropDownList"
$shortcutCombo.BackColor     = $bgInput
$shortcutCombo.ForeColor     = $fgPrimary
$shortcutCombo.FlatStyle     = "Flat"
$projGroupBox.Controls.Add($shortcutCombo)

# Populate shortcuts from config
$shortcuts = Get-ShortcutNames
foreach ($s in $shortcuts) { $shortcutCombo.Items.Add($s) | Out-Null }

$rY += 36

# Working Directory
$wdLabel = New-Object System.Windows.Forms.Label
$wdLabel.Location  = New-Object System.Drawing.Point(15, $rY)
$wdLabel.Size      = New-Object System.Drawing.Size(75, 20)
$wdLabel.Text      = "Work Dir:"
$wdLabel.ForeColor = $fgSecondary
$projGroupBox.Controls.Add($wdLabel)

$wdText = New-Object System.Windows.Forms.TextBox
$wdText.Location    = New-Object System.Drawing.Point(95, ($rY - 2))
$wdText.Size        = New-Object System.Drawing.Size(470, 25)
$wdText.BackColor   = $bgInput
$wdText.ForeColor   = $fgPrimary
$wdText.BorderStyle = "FixedSingle"
$wdText.ReadOnly    = $true
$projGroupBox.Controls.Add($wdText)

$browseBtn = New-Object System.Windows.Forms.Button
$browseBtn.Location  = New-Object System.Drawing.Point(570, ($rY - 2))
$browseBtn.Size      = New-Object System.Drawing.Size(45, 25)
$browseBtn.Text      = "..."
$browseBtn.BackColor = $btnGray
$browseBtn.ForeColor = $fgPrimary
$browseBtn.FlatStyle = "Flat"
$browseBtn.Cursor = [System.Windows.Forms.Cursors]::Hand
$browseBtn.Add_MouseEnter({ $browseBtn.BackColor = [System.Drawing.Color]::FromArgb(85, 90, 105) })
$browseBtn.Add_MouseLeave({ $browseBtn.BackColor = $btnGray })
$browseBtn.Add_Click({
    $fbd = New-Object System.Windows.Forms.FolderBrowserDialog
    $fbd.Description = "Select project working directory"
    $fbd.ShowNewFolderButton = $false
    if ($wdText.Text -and (Test-Path $wdText.Text)) {
        $fbd.SelectedPath = $wdText.Text
    }
    if ($fbd.ShowDialog() -eq "OK") {
        $wdText.Text = $fbd.SelectedPath
        $rm = Find-Roadmap $fbd.SelectedPath
        if ($rm) {
            $roadmapText.Text = $rm
            $roadmapStatusBox.Text = Get-RoadmapStatus $rm
        } else {
            $roadmapText.Text = "(none found)"
            $roadmapStatusBox.Text = ""
        }
        Update-ButtonStates
        Log-Message "Working dir: $($fbd.SelectedPath)"
    }
})
$projGroupBox.Controls.Add($browseBtn)

# Pick Folder button (direct folder selection)
$pickFolderBtn = New-Object System.Windows.Forms.Button
$pickFolderBtn.Location  = New-Object System.Drawing.Point(620, ($rY - 2))
$pickFolderBtn.Size      = New-Object System.Drawing.Size(50, 25)
$pickFolderBtn.Text      = "Pick"
$pickFolderBtn.BackColor = $btnBlue
$pickFolderBtn.ForeColor = [System.Drawing.Color]::White
$pickFolderBtn.FlatStyle = "Flat"
$pickFolderBtn.Font      = $fontSmall
$pickFolderBtn.Cursor = [System.Windows.Forms.Cursors]::Hand
$pickFolderBtn.Add_MouseEnter({ $pickFolderBtn.BackColor = [System.Drawing.Color]::FromArgb(20, 143, 255) })
$pickFolderBtn.Add_MouseLeave({ $pickFolderBtn.BackColor = $btnBlue })
$pickFolderBtn.Add_Click({
    $fbd = New-Object System.Windows.Forms.FolderBrowserDialog
    $fbd.Description = "Select any folder on your computer as the working directory"
    $fbd.ShowNewFolderButton = $false
    $fbd.SelectedPath = [Environment]::GetFolderPath("MyDocuments")
    if ($fbd.ShowDialog() -eq "OK") {
        $wdText.Text = $fbd.SelectedPath
        $rm = Find-Roadmap $fbd.SelectedPath
        if ($rm) {
            $roadmapText.Text = $rm
            $roadmapStatusBox.Text = Get-RoadmapStatus $rm
        } else {
            $roadmapText.Text = "(none found)"
            $roadmapStatusBox.Text = ""
        }
        Update-ButtonStates
        Log-Message "Work dir set directly: $($fbd.SelectedPath)"
    }
})
$projGroupBox.Controls.Add($pickFolderBtn)

$rY += 32

# Roadmap Path
$rmLabel = New-Object System.Windows.Forms.Label
$rmLabel.Location  = New-Object System.Drawing.Point(15, $rY)
$rmLabel.Size      = New-Object System.Drawing.Size(75, 20)
$rmLabel.Text      = "Roadmap:"
$rmLabel.ForeColor = $fgSecondary
$projGroupBox.Controls.Add($rmLabel)

$roadmapText = New-Object System.Windows.Forms.TextBox
$roadmapText.Location    = New-Object System.Drawing.Point(95, ($rY - 2))
$roadmapText.Size        = New-Object System.Drawing.Size(520, 25)
$roadmapText.BackColor   = $bgInput
$roadmapText.ForeColor   = $fgYellow
$roadmapText.BorderStyle = "FixedSingle"
$roadmapText.ReadOnly    = $true
$projGroupBox.Controls.Add($roadmapText)

$openRmBtn = New-Object System.Windows.Forms.Button
$openRmBtn.Location  = New-Object System.Drawing.Point(620, ($rY - 2))
$openRmBtn.Size      = New-Object System.Drawing.Size(50, 25)
$openRmBtn.Text      = "Open"
$openRmBtn.Font      = $fontSmall
$openRmBtn.BackColor = $btnGray
$openRmBtn.ForeColor = $fgPrimary
$openRmBtn.FlatStyle = "Flat"
$openRmBtn.Cursor = [System.Windows.Forms.Cursors]::Hand
$openRmBtn.Add_MouseEnter({ if ($openRmBtn.Enabled) { $openRmBtn.BackColor = [System.Drawing.Color]::FromArgb(85, 90, 105) } })
$openRmBtn.Add_MouseLeave({ $openRmBtn.BackColor = $btnGray })
$openRmBtn.Add_Click({
    if ($roadmapText.Text -and (Test-Path $roadmapText.Text)) {
        Start-Process "code" $roadmapText.Text
    } else {
        [System.Windows.Forms.MessageBox]::Show("No ROADMAP file found. Browse to a project dir first.", "No ROADMAP", "OK", "Warning")
    }
})
$openRmBtn.Enabled = $false
$projGroupBox.Controls.Add($openRmBtn)

$rY += 30

# Roadmap Status
$rmStatusLabel = New-Object System.Windows.Forms.Label
$rmStatusLabel.Location  = New-Object System.Drawing.Point(15, $rY)
$rmStatusLabel.Size      = New-Object System.Drawing.Size(75, 20)
$rmStatusLabel.Text      = "Status:"
$rmStatusLabel.ForeColor = $fgSecondary
$projGroupBox.Controls.Add($rmStatusLabel)

$roadmapStatusBox = New-Object System.Windows.Forms.TextBox
$roadmapStatusBox.Location    = New-Object System.Drawing.Point(95, ($rY - 2))
$roadmapStatusBox.Size        = New-Object System.Drawing.Size(575, 180)
$roadmapStatusBox.Multiline   = $true
$roadmapStatusBox.ScrollBars  = "Vertical"
$roadmapStatusBox.BackColor   = $bgInput
$roadmapStatusBox.ForeColor   = $fgGreen
$roadmapStatusBox.BorderStyle = "FixedSingle"
$roadmapStatusBox.ReadOnly    = $true
$roadmapStatusBox.Font        = $fontSmall
$projGroupBox.Controls.Add($roadmapStatusBox)

$y = 405

# ============================================================
# SEPARATOR
# ============================================================
$sep1 = New-Object System.Windows.Forms.Label
$sep1.Location  = New-Object System.Drawing.Point(20, $y)
$sep1.Size      = New-Object System.Drawing.Size(1360, 1)
$sep1.BackColor = [System.Drawing.Color]::FromArgb(60, 63, 80)
$form.Controls.Add($sep1)
$y += 12

# ============================================================
# CONTROL BUTTONS - Load, Save, RUN, STOP
# ============================================================
$btnY = $y

$loadBtn = New-Object System.Windows.Forms.Button
$loadBtn.Location  = New-Object System.Drawing.Point(20, $btnY)
$loadBtn.Size      = New-Object System.Drawing.Size(130, 50)
$loadBtn.Text      = "Load Config`r`n(Alt+L)"
$loadBtn.BackColor = $btnGray
$loadBtn.ForeColor = $fgPrimary
$loadBtn.FlatStyle = "Flat"
$loadBtn.Font      = $fontBold
$loadBtn.Cursor = [System.Windows.Forms.Cursors]::Hand
$loadBtn.Add_MouseEnter({ $loadBtn.BackColor = [System.Drawing.Color]::FromArgb(85, 90, 105) })
$loadBtn.Add_MouseLeave({ $loadBtn.BackColor = $btnGray })
$loadBtn.Add_Click({
    $cfg = Load-Config
    if ($cfg) {
        $global:config = $cfg
        $providerCombo.SelectedItem = $cfg.provider
        if ($cfg.project -and $shortcutCombo.Items.Contains($cfg.project)) {
            $shortcutCombo.SelectedItem = $cfg.project
        }
        $sessionsNumeric.Value = [Math]::Max(1, [Math]::Min(200, $cfg.maxSessions))
        $delayNumeric.Value    = [Math]::Max(10, [Math]::Min(900, $cfg.delaySeconds))
        $commitNumeric.Value   = [Math]::Max(0, [Math]::Min(50, $cfg.commitEveryNSessions))
        $stopTimeText.Text     = $cfg.stopTime
        if ($cfg.defaultModel -and $modelCombo.Items.Contains($cfg.defaultModel)) {
            $modelCombo.SelectedItem = $cfg.defaultModel
        }
        Update-ButtonStates
        Log-Message "Config loaded from config.json"
    } else {
        Log-Message "ERROR: Could not read config.json"
    }
})
$form.Controls.Add($loadBtn)

$saveBtn = New-Object System.Windows.Forms.Button
$saveBtn.Location  = New-Object System.Drawing.Point(160, $btnY)
$saveBtn.Size      = New-Object System.Drawing.Size(130, 50)
$saveBtn.Text      = "Save Config"
$saveBtn.BackColor = $btnBlue
$saveBtn.ForeColor = [System.Drawing.Color]::White
$saveBtn.FlatStyle = "Flat"
$saveBtn.Font      = $fontBold
$saveBtn.Cursor = [System.Windows.Forms.Cursors]::Hand
$saveBtn.Add_MouseEnter({ $saveBtn.BackColor = [System.Drawing.Color]::FromArgb(20, 143, 255) })
$saveBtn.Add_MouseLeave({ $saveBtn.BackColor = $btnBlue })
$saveBtn.Add_Click({
    $cfg = Load-Config
    if (-not $cfg) { $cfg = [PSCustomObject]@{} }
    $cfg.provider             = $providerCombo.SelectedItem
    $cfg.project              = $shortcutCombo.SelectedItem
    $cfg.maxSessions          = [int]$sessionsNumeric.Value
    $cfg.delaySeconds         = [int]$delayNumeric.Value
    $cfg.commitEveryNSessions = [int]$commitNumeric.Value
    $cfg.stopTime             = $stopTimeText.Text
    $cfg.timezone             = "EST"
    if ($providerCombo.SelectedItem -eq "claude") {
        $cfg.defaultModel = $modelCombo.SelectedItem
    }
    Save-Config $cfg
    Log-Message "Config saved to config.json"
})
$form.Controls.Add($saveBtn)

# Spacer

$runBtn = New-Object System.Windows.Forms.Button
$runBtn.Location  = New-Object System.Drawing.Point(400, $btnY)
$runBtn.Size      = New-Object System.Drawing.Size(200, 50)
$runBtn.Text      = "RUN (Alt+R)"
$runBtn.BackColor = $btnGreen
$runBtn.ForeColor = [System.Drawing.Color]::White
$runBtn.FlatStyle = "Flat"
$runBtn.Font      = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$runBtn.Cursor = [System.Windows.Forms.Cursors]::Hand
$runBtn.Add_MouseEnter({ if ($runBtn.Enabled) { $runBtn.BackColor = [System.Drawing.Color]::FromArgb(60, 187, 89) } })
$runBtn.Add_MouseLeave({ $runBtn.BackColor = $btnGreen })
$runBtn.Add_Click({
    if ($global:runnerProcess -and -not $global:runnerProcess.HasExited) {
        [System.Windows.Forms.MessageBox]::Show("NightShift is already running! Click STOP first.", "Running", "OK", "Warning")
        return
    }
    if (-not $providerCombo.SelectedItem) {
        [System.Windows.Forms.MessageBox]::Show("Select a provider first.", "No Provider", "OK", "Warning")
        return
    }
    if (-not $shortcutCombo.SelectedItem) {
        [System.Windows.Forms.MessageBox]::Show("Select a project shortcut first.", "No Project", "OK", "Warning")
        return
    }

    Log-Message "======= STARTING NIGHTSHIFT ======="
    Log-Message "Provider: $($providerCombo.SelectedItem)"
    Log-Message "Project:  $($shortcutCombo.SelectedItem)"
    Log-Message "Sessions: $($sessionsNumeric.Value)  Delay: $($delayNumeric.Value)s"

    $provider = $providerCombo.SelectedItem
    $project  = $shortcutCombo.SelectedItem
    $maxSess  = [int]$sessionsNumeric.Value
    $delaySec = [int]$delayNumeric.Value

    $psArgs = "-ExecutionPolicy Bypass -NoProfile -File `"$loopScript`" -Provider `"$provider`" -Project `"$project`" -MaxSessions $maxSess -DelaySeconds $delaySec"

    try {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName               = "powershell.exe"
        $psi.Arguments              = $psArgs
        $psi.UseShellExecute        = $false
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError  = $true
        $psi.CreateNoWindow         = $false
        $psi.WorkingDirectory       = $scriptDir

        $global:runnerProcess = New-Object System.Diagnostics.Process
        $global:runnerProcess.StartInfo = $psi
        $global:runnerProcess.Start() | Out-Null

        $runBtn.Enabled  = $false
        $stopBtn.Enabled = $true
        $statusBar.Text      = "   RUNNING  --  PID $($global:runnerProcess.Id)  |  $project  |  $provider"
        $statusBar.ForeColor = $fgGreen
        $statusBar.BackColor = [System.Drawing.Color]::FromArgb(20, 55, 30)

        Log-Message "Started (PID: $($global:runnerProcess.Id))"
        Log-Message "Watch autonomous_sessions.log for detailed output"
    } catch {
        Log-Message "ERROR: $_"
        [System.Windows.Forms.MessageBox]::Show("Failed to start: $_", "Error", "OK", "Error")
    }
})
$form.Controls.Add($runBtn)

$stopBtn = New-Object System.Windows.Forms.Button
$stopBtn.Location  = New-Object System.Drawing.Point(610, $btnY)
$stopBtn.Size      = New-Object System.Drawing.Size(200, 50)
$stopBtn.Text      = "STOP (Alt+S)"
$stopBtn.BackColor = $btnRed
$stopBtn.ForeColor = [System.Drawing.Color]::White
$stopBtn.FlatStyle = "Flat"
$stopBtn.Font      = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$stopBtn.Enabled   = $false
$stopBtn.Cursor = [System.Windows.Forms.Cursors]::Hand
$stopBtn.Add_MouseEnter({ if ($stopBtn.Enabled) { $stopBtn.BackColor = [System.Drawing.Color]::FromArgb(255, 105, 105) } })
$stopBtn.Add_MouseLeave({ $stopBtn.BackColor = $btnRed })
$stopBtn.Add_Click({
    if ($global:runnerProcess -and -not $global:runnerProcess.HasExited) {
        Log-Message "Stopping NightShift..."
        try {
            $global:runnerProcess.Kill()
            $global:runnerProcess.WaitForExit(5000)
            Log-Message "Stopped"
        } catch {
            Log-Message "Force killed: $_"
        }
        $global:runnerProcess = $null
    }
    $runBtn.Enabled  = $true
    $stopBtn.Enabled = $false
    $statusBar.Text      = "   STOPPED  --  Terminated by user"
    $statusBar.ForeColor = $fgRed
    $statusBar.BackColor = [System.Drawing.Color]::FromArgb(55, 20, 20)
})
$form.Controls.Add($stopBtn)

$y = $btnY + 62

# ============================================================
# SEPARATOR
# ============================================================
$sep2 = New-Object System.Windows.Forms.Label
$sep2.Location  = New-Object System.Drawing.Point(20, $y)
$sep2.Size      = New-Object System.Drawing.Size(1360, 1)
$sep2.BackColor = [System.Drawing.Color]::FromArgb(60, 63, 80)
$form.Controls.Add($sep2)
$y += 12

# ============================================================
# TOOLS and META DOCUMENTATION
# ============================================================
$metaGroupBox = New-Object System.Windows.Forms.GroupBox
$metaGroupBox.Location  = New-Object System.Drawing.Point(15, $y)
$metaGroupBox.Size      = New-Object System.Drawing.Size(1365, 110)
$metaGroupBox.Text      = "TOOLS and META"
$metaGroupBox.Font      = $fontSection
$metaGroupBox.ForeColor = $fgAccent
$metaGroupBox.FlatStyle = "Flat"
$form.Controls.Add($metaGroupBox)
$y += 115

$btnW   = 130
$btnH   = 32
$btnGap = 8

function Make-MetaButton {
    param([int]$x, [int]$row, [string]$text, [scriptblock]$action)
    $btn = New-Object System.Windows.Forms.Button
    $btn.Location  = New-Object System.Drawing.Point($x, (25 + ($row * ($btnH + $btnGap))))
    $btn.Size      = New-Object System.Drawing.Size($btnW, $btnH)
    $btn.Text      = $text
    $btn.BackColor = $btnGray
    $btn.ForeColor = $fgPrimary
    $btn.FlatStyle = "Flat"
    $btn.Font      = $fontSmall
    $btn.Cursor    = [System.Windows.Forms.Cursors]::Hand
    $btn.Add_MouseEnter({ $this.BackColor = [System.Drawing.Color]::FromArgb(85, 90, 105) })
    $btn.Add_MouseLeave({ $this.BackColor = $btnGray })
    $btn.Add_Click($action)
    $metaGroupBox.Controls.Add($btn)
    return $btn
}

$col = 15

# Row 1
Make-MetaButton $col 0 "Edit Config" { Start-Process "code" "`"$configPath`"" }
$col += $btnW + $btnGap
Make-MetaButton $col 0 "Session Reports" {
    if (Test-Path $reportsDir) { Start-Process "explorer.exe" "`"$reportsDir`"" }
    else { Log-Message "Reports dir not found" }
}
$col += $btnW + $btnGap
Make-MetaButton $col 0 "Learnings" {
    $p = Join-Path $learningsDir "PATTERNS.md"
    if (Test-Path $p) { Start-Process "code" "`"$p`"" }
    else { Start-Process "explorer.exe" "`"$learningsDir`"" }
}
$col += $btnW + $btnGap
Make-MetaButton $col 0 "Templates" { Start-Process "explorer.exe" "`"$templatesDir`"" }
$col += $btnW + $btnGap
Make-MetaButton $col 0 "Best Practices" {
    $p = Join-Path $scriptDir "docs\BEST_PRACTICES.md"
    if (Test-Path $p) { Start-Process "code" "`"$p`"" }
}
$col += $btnW + $btnGap
Make-MetaButton $col 0 "Usage Guide" {
    $p = Join-Path $scriptDir "docs\USAGE_GUIDE.md"
    if (Test-Path $p) { Start-Process "code" "`"$p`"" }
}

# Row 2
$col = 15
Make-MetaButton $col 1 "Session Log" {
    if (Test-Path $logFilePath) { Start-Process "code" "`"$logFilePath`"" }
    else { Log-Message "No log file yet" }
}
$col += $btnW + $btnGap
$global:openWorkDirBtn = Make-MetaButton $col 1 "Open Work Dir" {
    if ($wdText.Text -and (Test-Path $wdText.Text)) {
        Start-Process "explorer.exe" "`"$($wdText.Text)`""
    } else { Log-Message "Set a working directory first" }
}
$global:openWorkDirBtn.Enabled = $false
$col += $btnW + $btnGap
Make-MetaButton $col 1 "Open Roadmap" {
    if ($roadmapText.Text -and (Test-Path $roadmapText.Text)) {
        Start-Process "code" "`"$($roadmapText.Text)`""
    } else { Log-Message "No roadmap found" }
}
$col += $btnW + $btnGap
Make-MetaButton $col 1 "Meta Index" {
    $p = Join-Path $metaDir "INDEX.md"
    if (Test-Path $p) { Start-Process "code" "`"$p`"" }
}
$col += $btnW + $btnGap
Make-MetaButton $col 1 "Providers Doc" {
    $p = Join-Path $scriptDir "docs\PROVIDERS.md"
    if (Test-Path $p) { Start-Process "code" "`"$p`"" }
}
$col += $btnW + $btnGap
Make-MetaButton $col 1 "NightShift Dir" {
    Start-Process "explorer.exe" "`"$scriptDir`""
}

# ============================================================
# SEPARATOR
# ============================================================
$sep3 = New-Object System.Windows.Forms.Label
$sep3.Location  = New-Object System.Drawing.Point(20, $y)
$sep3.Size      = New-Object System.Drawing.Size(1360, 1)
$sep3.BackColor = [System.Drawing.Color]::FromArgb(60, 63, 80)
$form.Controls.Add($sep3)
$y += 10

# ============================================================
# OUTPUT LOG
# ============================================================
$logSection = New-Object System.Windows.Forms.Label
$logSection.Location  = New-Object System.Drawing.Point(20, $y)
$logSection.Size      = New-Object System.Drawing.Size(200, 22)
$logSection.Text      = "OUTPUT LOG"
$logSection.Font      = $fontSection
$logSection.ForeColor = $fgAccent
$form.Controls.Add($logSection)

$clearBtn = New-Object System.Windows.Forms.Button
$clearBtn.Location  = New-Object System.Drawing.Point(1285, $y)
$clearBtn.Size      = New-Object System.Drawing.Size(95, 22)
$clearBtn.Text      = "Clear"
$clearBtn.BackColor = $bgPanel
$clearBtn.ForeColor = $fgSecondary
$clearBtn.FlatStyle = "Flat"
$clearBtn.Font      = $fontSmall
$clearBtn.Cursor    = [System.Windows.Forms.Cursors]::Hand
$clearBtn.Add_MouseEnter({ $clearBtn.ForeColor = $fgPrimary })
$clearBtn.Add_MouseLeave({ $clearBtn.ForeColor = $fgSecondary })
$clearBtn.Add_Click({ $logBox.Clear() })
$clearBtn.Anchor    = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
$form.Controls.Add($clearBtn)
$y += 24

$logBox = New-Object System.Windows.Forms.TextBox
$logBox.Location    = New-Object System.Drawing.Point(20, $y)
$logBox.Size        = New-Object System.Drawing.Size(1360, 480)
$logBox.Multiline   = $true
$logBox.ScrollBars  = "Vertical"
$logBox.ReadOnly    = $true
$logBox.WordWrap    = $true
$logBox.Font        = $fontMono
$logBox.BackColor   = [System.Drawing.Color]::FromArgb(18, 18, 24)
$logBox.ForeColor   = $fgGreen
$logBox.BorderStyle = "FixedSingle"
$logBox.Anchor      = [System.Windows.Forms.AnchorStyles]::Top -bor `
                      [System.Windows.Forms.AnchorStyles]::Bottom -bor `
                      [System.Windows.Forms.AnchorStyles]::Left -bor `
                      [System.Windows.Forms.AnchorStyles]::Right
$form.Controls.Add($logBox)

# ============================================================
# LIVE CLOCK TIMER
# ============================================================
$clockTimer = New-Object System.Windows.Forms.Timer
$clockTimer.Interval = 1000
$clockTimer.Add_Tick({
    $local = Get-Date
    $clockLabel.Text     = $local.ToString("hh:mm:ss tt")
    $clockDateLabel.Text = $local.ToString("dddd, MMMM dd yyyy")

    # Check if process exited
    if ($global:runnerProcess -and $global:runnerProcess.HasExited) {
        $code = $global:runnerProcess.ExitCode
        Log-Message "NightShift finished (exit code: $code)"
        $global:runnerProcess = $null
        $runBtn.Enabled  = $true
        $stopBtn.Enabled = $false
        $statusBar.Text      = "   COMPLETED  --  Finished (exit code: $code)"
        $statusBar.ForeColor = $fgYellow
        $statusBar.BackColor = [System.Drawing.Color]::FromArgb(50, 45, 20)
    }
})
$clockTimer.Start()

# ============================================================
# INITIAL LOAD
# ============================================================
$cfg = Load-Config
if ($cfg) {
    $global:config = $cfg
    if ($cfg.provider) { $providerCombo.SelectedItem = $cfg.provider }
    if ($cfg.project -and $shortcutCombo.Items.Contains($cfg.project)) {
        $shortcutCombo.SelectedItem = $cfg.project
    }
    if ($cfg.maxSessions)          { $sessionsNumeric.Value = [Math]::Max(1, [Math]::Min(200, $cfg.maxSessions)) }
    if ($cfg.delaySeconds)         { $delayNumeric.Value    = [Math]::Max(10, [Math]::Min(900, $cfg.delaySeconds)) }
    if ($cfg.commitEveryNSessions) { $commitNumeric.Value   = [Math]::Max(0, [Math]::Min(50, $cfg.commitEveryNSessions)) }
    $stopTimeText.Text = $cfg.stopTime
    if ($cfg.defaultModel -and $modelCombo.Items.Contains($cfg.defaultModel)) {
        $modelCombo.SelectedItem = $cfg.defaultModel
    }
}

# Initial clock update
$local = Get-Date
$clockLabel.Text     = $local.ToString("hh:mm:ss tt")
$clockDateLabel.Text = $local.ToString("dddd, MMMM dd yyyy")

# Update button states based on loaded config
Update-ButtonStates

Log-Message "NightShift Control Center v2.0"
Log-Message "Config loaded from: $configPath"
Log-Message "Provider: $($providerCombo.SelectedItem)  |  Project: $($shortcutCombo.SelectedItem)"
Log-Message "---"
Log-Message "Keyboard shortcuts: Alt+R (RUN), Alt+S (STOP), Alt+L (Load Config)"
Log-Message "Select a project, browse to working dir, click RUN"

# ============================================================
# KEYBOARD SHORTCUTS
# ============================================================
$form.Add_KeyDown({
    param($sender, $e)
    # Alt+R = RUN
    if ($e.Alt -and $e.KeyCode -eq [System.Windows.Forms.Keys]::R) {
        if ($runBtn.Enabled) {
            $runBtn.PerformClick()
        }
        $e.SuppressKeyPress = $true
    }
    # Alt+S = STOP
    elseif ($e.Alt -and $e.KeyCode -eq [System.Windows.Forms.Keys]::S) {
        if ($stopBtn.Enabled) {
            $stopBtn.PerformClick()
        }
        $e.SuppressKeyPress = $true
    }
    # Alt+L = Load Config
    elseif ($e.Alt -and $e.KeyCode -eq [System.Windows.Forms.Keys]::L) {
        $loadBtn.PerformClick()
        $e.SuppressKeyPress = $true
    }
})

# ============================================================
# SHOW
# ============================================================
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()

# Cleanup
if ($global:runnerProcess -and -not $global:runnerProcess.HasExited) {
    $global:runnerProcess.Kill()
}
$clockTimer.Stop()
