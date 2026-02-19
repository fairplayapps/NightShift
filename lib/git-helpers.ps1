# lib/git-helpers.ps1
# Git utilities for NightShift auto-commit and push

<#
.SYNOPSIS
    Commit and push changes to git repository

.PARAMETER SessionNumber
    The session number for the commit message

.PARAMETER ProjectRoot
    The project root directory

.PARAMETER LogFunction
    A script block for logging (receives message as parameter)

.RETURNS
    $true if commit and push succeeded, $false otherwise
#>
function Invoke-AutoCommitAndPush {
    param(
        [Parameter(Mandatory=$true)]
        [int]$SessionNumber,

        [Parameter(Mandatory=$true)]
        [string]$ProjectRoot,

        [scriptblock]$LogFunction = { param($msg) Write-Host $msg }
    )

    Push-Location $ProjectRoot

    try {
        & $LogFunction "Starting auto-commit and push for session $SessionNumber"

        Write-Host ""
        Write-Host "  ----------------------------------------------------------------" -ForegroundColor Magenta
        Write-Host "  [GIT] Auto-commit & push after session $SessionNumber" -ForegroundColor Magenta
        Write-Host "  ----------------------------------------------------------------" -ForegroundColor Magenta

        # Stage all changes
        git add -A

        # Get current date for commit message
        $commitDate = Get-Date -Format "yyyy-MM-dd HH:mm"
        $commitMsg = @"
Autonomous session $SessionNumber checkpoint

Auto-commit by NightShift after session $SessionNumber
Date: $commitDate

🤖 Generated with AI autonomous coding

Co-Authored-By: AI Coding Assistant <noreply@ai.dev>
"@

        # Commit
        git commit -m $commitMsg

        $commitExitCode = $LASTEXITCODE

        if ($commitExitCode -eq 0) {
            Write-Host "  [OK] Commit successful" -ForegroundColor Green
            & $LogFunction "Auto-commit after session $SessionNumber - SUCCESS"

            # Push to remote
            Write-Host "  [..] Pushing to remote..." -ForegroundColor Yellow
            git push

            if ($LASTEXITCODE -eq 0) {
                Write-Host "  [OK] Push successful" -ForegroundColor Green
                & $LogFunction "Auto-push after session $SessionNumber - SUCCESS"
                $success = $true
            } else {
                Write-Host "  [!!] Push failed (exit code: $LASTEXITCODE)" -ForegroundColor Red
                & $LogFunction "Auto-push after session $SessionNumber - FAILED"
                $success = $false
            }
        } else {
            Write-Host "  [--] No changes to commit" -ForegroundColor DarkGray
            & $LogFunction "Auto-commit after session $SessionNumber - No changes"
            $success = $true
        }

        Write-Host "  ----------------------------------------------------------------" -ForegroundColor Magenta
        Write-Host ""

        return $success
    }
    finally {
        Pop-Location
    }
}

<#
.SYNOPSIS
    Check if the current directory is a git repository

.PARAMETER Path
    The path to check (defaults to current directory)

.RETURNS
    $true if path is in a git repository, $false otherwise
#>
function Test-GitRepository {
    param(
        [string]$Path = "."
    )

    Push-Location $Path
    try {
        git rev-parse --git-dir 2>$null | Out-Null
        return ($LASTEXITCODE -eq 0)
    }
    finally {
        Pop-Location
    }
}
