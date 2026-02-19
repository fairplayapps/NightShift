# lib/logging.ps1
# Logging utilities for NightShift

<#
.SYNOPSIS
    Write a timestamped log entry to both console and log file

.PARAMETER Message
    The message to log

.PARAMETER LogPath
    Path to the log file

.PARAMETER Color
    Console color for the message (default: DarkGray)
#>
function Write-Log {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,

        [Parameter(Mandatory=$true)]
        [string]$LogPath,

        [ConsoleColor]$Color = [ConsoleColor]::DarkGray
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "$timestamp | $Message"
    
    Write-Host $logEntry -ForegroundColor $Color
    Add-Content -Path $LogPath -Value $logEntry
}

<#
.SYNOPSIS
    Initialize a new log session

.PARAMETER LogPath
    Path to the log file

.PARAMETER SessionInfo
    Information about the session being started
#>
function Initialize-LogSession {
    param(
        [Parameter(Mandatory=$true)]
        [string]$LogPath,

        [Parameter(Mandatory=$true)]
        [hashtable]$SessionInfo
    )

    $separator = "=" * 80
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    $header = @"

$separator
NIGHTSHIFT SESSION STARTED
Time: $timestamp
Provider: $($SessionInfo.Provider)
Project: $($SessionInfo.Project)
Max Sessions: $($SessionInfo.MaxSessions)
$separator

"@

    Add-Content -Path $LogPath -Value $header
}

<#
.SYNOPSIS
    Finalize the log session with summary

.PARAMETER LogPath
    Path to the log file

.PARAMETER Summary
    Summary information about the completed session
#>
function Complete-LogSession {
    param(
        [Parameter(Mandatory=$true)]
        [string]$LogPath,

        [Parameter(Mandatory=$true)]
        [hashtable]$Summary
    )

    $separator = "=" * 80
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    $footer = @"

$separator
NIGHTSHIFT SESSION COMPLETE
Time: $timestamp
Sessions Completed: $($Summary.SessionsCompleted)
Total Duration: $($Summary.TotalDuration)
$separator

"@

    Add-Content -Path $LogPath -Value $footer
}
