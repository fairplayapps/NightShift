# lib/providers.ps1
# Provider abstraction layer for NightShift
# Supports Claude Code and OpenAI Codex CLI

<#
.SYNOPSIS
    Invoke an AI coding provider with the specified command.

.PARAMETER Provider
    The provider to use: "claude" or "codex"

.PARAMETER Command
    The command/prompt to send to the provider

.PARAMETER AllowedTools
    Tools that the provider is allowed to use (provider-specific)

.PARAMETER Model
    The model to use (provider-specific)

.PARAMETER ProjectRoot
    The project root directory to run from

.EXAMPLE
    Invoke-Provider -Provider "claude" -Command "Fix all tests" -ProjectRoot "C:\Projects\MyApp"
#>
function Invoke-Provider {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("claude", "codex")]
        [string]$Provider,

        [Parameter(Mandatory=$true)]
        [string]$Command,

        [string]$AllowedTools = "Read,Glob,Grep,Edit,Write,Bash,Task,TodoWrite,TodoRead,Mcp,Browser,PythonExec,Jupyter,Computer",

        [string]$Model = "",

        [Parameter(Mandatory=$true)]
        [string]$ProjectRoot
    )

    Push-Location $ProjectRoot

    try {
        switch ($Provider.ToLower()) {
            "claude" {
                Invoke-Claude -Command $Command -AllowedTools $AllowedTools -Model $Model
            }
            "codex" {
                Invoke-Codex -Command $Command -Model $Model
            }
            default {
                throw "Unknown provider: $Provider. Supported: claude, codex"
            }
        }

        return $LASTEXITCODE
    }
    finally {
        Pop-Location
    }
}

<#
.SYNOPSIS
    Invoke Claude Code CLI

.PARAMETER Command
    The command/prompt to send to Claude

.PARAMETER AllowedTools
    Comma-separated list of allowed tools

.PARAMETER Model
    The Claude model to use (empty = default from Claude config)
#>
function Invoke-Claude {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Command,

        [string]$AllowedTools = "Read,Glob,Grep,Edit,Write,Bash,Task,TodoWrite,TodoRead,Mcp,Browser,PythonExec,Jupyter,Computer",

        [string]$Model = ""
    )

    $claudeArgs = @("-p", $Command, "--allowedTools", $AllowedTools)

    # Add model flag if specified
    if ($Model -ne "") {
        $claudeArgs += @("--model", $Model)
    }

    Write-Host "  [CLAUDE] Running: claude -p `"$Command`" --allowedTools $AllowedTools" -ForegroundColor Cyan

    claude @claudeArgs
}

<#
.SYNOPSIS
    Invoke OpenAI Codex CLI

.PARAMETER Command
    The command/prompt to send to Codex

.PARAMETER Model
    The model to use (optional, uses Codex default if not specified)
#>
function Invoke-Codex {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Command,

        [string]$Model = ""
    )

    Write-Host "  [CODEX] Running: codex exec `"<prompt>`" --full-auto --skip-git-repo-check --sandbox workspace-write" -ForegroundColor Cyan
    if ($Model -ne "") {
        Write-Host "  [CODEX] Model: $Model" -ForegroundColor DarkCyan
    }

    # Use & operator for direct invocation - array splatting doesn't work reliably with long strings
    if ($Model -ne "") {
        & codex exec $Command --full-auto --skip-git-repo-check --sandbox workspace-write --model $Model
    }
    else {
        & codex exec $Command --full-auto --skip-git-repo-check --sandbox workspace-write
    }
}

<#
.SYNOPSIS
    Test if a provider CLI is installed and available

.PARAMETER Provider
    The provider to test: "claude" or "codex"

.RETURNS
    $true if the provider is installed, $false otherwise
#>
function Test-ProviderInstalled {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("claude", "codex")]
        [string]$Provider
    )

    $command = switch ($Provider.ToLower()) {
        "claude" { "claude" }
        "codex" { "codex" }
    }

    $result = Get-Command $command -ErrorAction SilentlyContinue
    return ($null -ne $result)
}
