# autonomous_loop.ps1
# NightShift: Autonomous AI Coding Session Runner
# Supports: Claude Code, OpenAI Codex CLI
#
# Usage:
#   1. Edit config.json to set your preferences
#   2. Run: .\autonomous_loop.ps1
#
#   Or override config with parameters:
#   .\autonomous_loop.ps1 -Provider "codex" -Project "WebApp" -MaxSessions 5
#
# Press Ctrl+C at any time to stop gracefully.

param(
    [string]$Provider = "",
    [string]$Project = "",
    [int]$MaxSessions = 0,
    [int]$DelaySeconds = 0,
    [int]$CommitEveryNSessions = 0,
    [string]$StopTime = "",
    [string]$Timezone = "",
    [string]$ConfigFile = ".\config.json"
)

# Import library modules
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$libDir = Join-Path $scriptDir "lib"
. (Join-Path $libDir "providers.ps1")
. (Join-Path $libDir "logging.ps1")
. (Join-Path $libDir "git-helpers.ps1")

# Load config from JSON file
$configPath = Join-Path $scriptDir "config.json"

if (Test-Path $configPath) {
    $config = Get-Content $configPath -Raw | ConvertFrom-Json

    # Use config values as defaults, command-line params override
    if ($Provider -eq "") { $Provider = $config.provider }
    if ($Project -eq "") { $Project = $config.project }
    if ($MaxSessions -eq 0) { $MaxSessions = $config.maxSessions }
    if ($DelaySeconds -eq 0) { $DelaySeconds = $config.delaySeconds }
    if ($CommitEveryNSessions -eq 0 -and $config.commitEveryNSessions) {
        $CommitEveryNSessions = $config.commitEveryNSessions
    }
    if ($StopTime -eq "" -and $config.stopTime) { $StopTime = $config.stopTime }
    if ($Timezone -eq "" -and $config.timezone) { $Timezone = $config.timezone }
    $defaultModel = $config.defaultModel

    # Build project shortcuts from config
    $projectCommands = @{}
    $config.projectShortcuts.PSObject.Properties | ForEach-Object {
        $projectCommands[$_.Name] = $_.Value
    }
}
else {
    # Fallback defaults if no config file
    if ($Provider -eq "") { $Provider = "claude" }
    if ($Project -eq "") { $Project = "WebApp" }
    if ($MaxSessions -eq 0) { $MaxSessions = 5 }
    if ($DelaySeconds -eq 0) { $DelaySeconds = 45 }
    $defaultModel = "sonnet"
}

# Resolve command from shortcut or use as-is
if ($projectCommands.ContainsKey($Project)) {
    $command = $projectCommands[$Project]
}
else {
    $command = $Project
}

# Validate provider
if ($Provider -notin @("claude", "codex")) {
    Write-Host "Error: Invalid provider '$Provider'" -ForegroundColor Red
    Write-Host "Valid providers: claude, codex" -ForegroundColor Yellow
    Write-Host "See docs/PROVIDERS.md for setup instructions" -ForegroundColor Yellow
    exit 1
}

# Check if provider is installed
if (-not (Test-ProviderInstalled -Provider $Provider)) {
    Write-Host "Error: Provider '$Provider' is not installed" -ForegroundColor Red
    Write-Host "See docs/PROVIDERS.md for installation instructions" -ForegroundColor Yellow
    exit 1
}

# Session tracking
$sessionCount = 0
$startTime = Get-Date
$logsDir = Join-Path $scriptDir "logs"
if (-not (Test-Path $logsDir)) {
    New-Item -ItemType Directory -Path $logsDir | Out-Null
}
$logPath = Join-Path $logsDir "autonomous_sessions.log"


# Time limit check function
function Test-PastStopTime {
    param(
        [string]$StopTimeStr,
        [string]$TimezoneStr
    )

    if ([string]::IsNullOrWhiteSpace($StopTimeStr)) {
        return $false
    }

    # Parse the stop time (expected format: "HH:mm" like "23:30")
    try {
        $timeParts = $StopTimeStr -split ':'
        $stopHour = [int]$timeParts[0]
        $stopMinute = [int]$timeParts[1]
    }
    catch {
        Write-Log -Message "WARNING: Invalid stopTime format '$StopTimeStr'. Expected 'HH:mm' (e.g., '23:30')" -LogPath $logPath
        return $false
    }

    # Get current time in the specified timezone
    $now = Get-Date

    switch ($TimezoneStr.ToUpper()) {
        "EST" {
            $tz = [TimeZoneInfo]::FindSystemTimeZoneById("Eastern Standard Time")
            $now = [TimeZoneInfo]::ConvertTime($now, $tz)
        }
        "PST" {
            $tz = [TimeZoneInfo]::FindSystemTimeZoneById("Pacific Standard Time")
            $now = [TimeZoneInfo]::ConvertTime($now, $tz)
        }
        "UTC" {
            $now = $now.ToUniversalTime()
        }
        "LOCAL" {
            # Already in local time
        }
        default {
            # Try to find the timezone by ID
            try {
                $tz = [TimeZoneInfo]::FindSystemTimeZoneById($TimezoneStr)
                $now = [TimeZoneInfo]::ConvertTime($now, $tz)
            }
            catch {
                Write-Log -Message "WARNING: Unknown timezone '$TimezoneStr'. Using local time." -LogPath $logPath
            }
        }
    }

    # Build stop datetime for today
    $stopDateTime = Get-Date -Year $now.Year -Month $now.Month -Day $now.Day -Hour $stopHour -Minute $stopMinute -Second 0

    # Check if we've passed the stop time
    return ($now -ge $stopDateTime)
}

# Get formatted stop time for display
function Get-StopTimeDisplay {
    param(
        [string]$StopTimeStr,
        [string]$TimezoneStr
    )

    if ([string]::IsNullOrWhiteSpace($StopTimeStr)) {
        return "disabled"
    }

    return "$StopTimeStr $TimezoneStr"
}

# Clear screen and show header
Clear-Host
Write-Host ""
Write-Host "  ================================================================" -ForegroundColor Cyan
Write-Host "  |                                                              |" -ForegroundColor Cyan
Write-Host "  |   NIGHTSHIFT - Autonomous Claude Code Session Runner          |" -ForegroundColor Cyan
Write-Host "  |                                                              |" -ForegroundColor Cyan
Write-Host "  ================================================================" -ForegroundColor Cyan
Write-Host "  |                                                              |" -ForegroundColor Cyan
$commitInfo = if ($CommitEveryNSessions -gt 0) { "every $CommitEveryNSessions sessions" } else { "disabled" }
$stopTimeInfo = Get-StopTimeDisplay -StopTimeStr $StopTime -TimezoneStr $Timezone
Write-Host "  |   Provider:   $($Provider.ToUpper().PadRight(43))|" -ForegroundColor Cyan
Write-Host "  |   Project:    $($Project.PadRight(43))|" -ForegroundColor Cyan
Write-Host "  |   Sessions:   $($MaxSessions.ToString().PadRight(43))|" -ForegroundColor Cyan
Write-Host "  |   Delay:      $("$DelaySeconds seconds".PadRight(43))|" -ForegroundColor Cyan
Write-Host "  |   Commit+Push: $($commitInfo.PadRight(42))|" -ForegroundColor Cyan
Write-Host "  |   Stop at:    $($stopTimeInfo.PadRight(43))|" -ForegroundColor Cyan
Write-Host "  |                                                              |" -ForegroundColor Cyan
Write-Host "  |   Press Ctrl+C at any time to stop                           |" -ForegroundColor Yellow
Write-Host "  |                                                              |" -ForegroundColor Cyan
Write-Host "  ================================================================" -ForegroundColor Cyan
Write-Host ""

Write-Log -Message "=== NIGHTSHIFT STARTED ===" -LogPath $logPath
Write-Log -Message "Provider: $Provider | Project: $Project | Command: $command | Max Sessions: $MaxSessions | Stop at: $stopTimeInfo" -LogPath $logPath

# Main loop with error handling
try {
    while ($sessionCount -lt $MaxSessions) {
        # Check if we've passed the stop time BEFORE starting a new session
        if (Test-PastStopTime -StopTimeStr $StopTime -TimezoneStr $Timezone) {
            Write-Host ""
            Write-Host "  ----------------------------------------------------------------" -ForegroundColor Yellow
            Write-Host "  [STOP TIME REACHED] It's past $StopTime $Timezone" -ForegroundColor Yellow
            Write-Host "  No new sessions will be started." -ForegroundColor Yellow
            Write-Host "  ----------------------------------------------------------------" -ForegroundColor Yellow
            Write-Log -Message "STOP TIME REACHED: Past $StopTime $Timezone - stopping before session $($sessionCount + 1)" -LogPath $logPath
            break
        }

        $sessionCount++
        $sessionStart = Get-Date

        # Session header
        Write-Host ""
        Write-Host "  ----------------------------------------------------------------" -ForegroundColor Yellow
        Write-Host "  SESSION $sessionCount of $MaxSessions" -ForegroundColor Yellow
        Write-Host "  Started: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Yellow
        Write-Host "  Command: $command" -ForegroundColor Yellow
        Write-Host "  ----------------------------------------------------------------" -ForegroundColor Yellow
        Write-Host ""

        Write-Log -Message "Session $sessionCount/$MaxSessions started" -LogPath $logPath

        # Navigate to project root before running provider
        # Use parent directory of NightShift as project root
        $projectRoot = Split-Path -Parent $scriptDir

        try {
            # Run AI provider with command
            $exitCode = Invoke-Provider -Provider $Provider -Command $command -Model $defaultModel -ProjectRoot $projectRoot
        }
        catch  {
            Write-Host "  [ERROR] Provider invocation failed: $_" -ForegroundColor Red
            Write-Log -Message "Session $sessionCount FAILED: $_" -LogPath $logPath
            $exitCode = 1
        }

        # Calculate session duration
        $sessionDuration = (Get-Date) - $sessionStart
        $durationStr = "{0:hh\:mm\:ss}" -f $sessionDuration

        # Session complete
        Write-Host ""
        Write-Host "  ----------------------------------------------------------------" -ForegroundColor Green
        Write-Host "  [OK] Session $sessionCount complete" -ForegroundColor Green
        Write-Host "  Duration: $durationStr" -ForegroundColor Green
        Write-Host "  Exit code: $exitCode" -ForegroundColor Green
        Write-Host "  ----------------------------------------------------------------" -ForegroundColor Green

        Write-Log -Message "Session $sessionCount complete | Duration: $durationStr | Exit: $exitCode" -LogPath $logPath

        # Check if we should auto-commit and push
        if ($CommitEveryNSessions -gt 0 -and ($sessionCount % $CommitEveryNSessions) -eq 0) {
            $logFunc = { param($msg) Write-Log -Message $msg -LogPath $logPath }
            Invoke-AutoCommitAndPush -SessionNumber $sessionCount -ProjectRoot $projectRoot -LogFunction $logFunc
        }

        # Pause between sessions (unless this was the last one)
        if ($sessionCount -lt $MaxSessions) {
            Write-Host ""
            Write-Host "  Next session starts in $DelaySeconds seconds..." -ForegroundColor DarkGray
            Write-Host "  Press Ctrl+C to stop after this session." -ForegroundColor DarkGray
            Write-Host ""

            # Countdown with live update, checking stop time each second
            $stopTimeReachedDuringDelay = $false
            for ($i = $DelaySeconds; $i -gt 0; $i--) {
                # Check stop time during countdown
                if (Test-PastStopTime -StopTimeStr $StopTime -TimezoneStr $Timezone) {
                    Write-Host ""
                    Write-Host "  ----------------------------------------------------------------" -ForegroundColor Yellow
                    Write-Host "  [STOP TIME REACHED] It's past $StopTime $Timezone" -ForegroundColor Yellow
                    Write-Host "  No new sessions will be started." -ForegroundColor Yellow
                    Write-Host "  ----------------------------------------------------------------" -ForegroundColor Yellow
                    Write-Log -Message "STOP TIME REACHED during delay: Past $StopTime $Timezone" -LogPath $logPath
                    $stopTimeReachedDuringDelay = $true
                    break
                }
                Write-Host "`r  Countdown: $i seconds remaining...   " -NoNewline -ForegroundColor DarkGray
                Start-Sleep -Seconds 1
            }

            if ($stopTimeReachedDuringDelay) {
                break
            }

            Write-Host "`r  Starting next session...                " -ForegroundColor DarkGray
            Write-Host ""
        }
    }
}
catch {
    # Handle Ctrl+C or other interruptions
    Write-Host ""
    Write-Host ""
    Write-Host "  ----------------------------------------------------------------" -ForegroundColor Yellow
    Write-Host "  [!] INTERRUPTED" -ForegroundColor Yellow
    Write-Host "  Stopped after $sessionCount session(s)" -ForegroundColor Yellow
    Write-Host "  Work has been saved to ROADMAP.md" -ForegroundColor Yellow
    Write-Host "  ----------------------------------------------------------------" -ForegroundColor Yellow

    Write-Log -Message "INTERRUPTED by user after $sessionCount sessions" -LogPath $logPath
}
finally {
    # Final summary
    $totalDuration = (Get-Date) - $startTime
    $totalDurationStr = "{0:hh\:mm\:ss}" -f $totalDuration

    Write-Host ""
    Write-Host "  ================================================================" -ForegroundColor Cyan
    Write-Host "  |                      RUN COMPLETE                            |" -ForegroundColor Cyan
    Write-Host "  ================================================================" -ForegroundColor Cyan
    Write-Host "  |                                                              |" -ForegroundColor Cyan
    Write-Host "  |   Sessions completed:  $($sessionCount.ToString().PadRight(35))|" -ForegroundColor Cyan
    Write-Host "  |   Total duration:      $($totalDurationStr.PadRight(35))|" -ForegroundColor Cyan
    Write-Host "  |   Log file:            autonomous_sessions.log              |" -ForegroundColor Cyan
    Write-Host "  |                                                              |" -ForegroundColor Cyan
    Write-Host "  |   Check ROADMAP.md for current project status.              |" -ForegroundColor Cyan
    Write-Host "  |                                                              |" -ForegroundColor Cyan
    Write-Host "  ================================================================" -ForegroundColor Cyan
    Write-Host ""

    Write-Log -Message "=== NIGHTSHIFT COMPLETE === Sessions: $sessionCount | Total time: $totalDurationStr" -LogPath $logPath
}
