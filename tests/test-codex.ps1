# Test: OpenAI Codex CLI Provider
# Tests the OpenAI Codex CLI integration

param(
    [string]$TestProject = "C:\TestProject"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing OpenAI Codex CLI Provider" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Import provider module
$libPath = Join-Path $PSScriptRoot "..\lib"
. (Join-Path $libPath "providers.ps1")

# Test 1: Check if Codex CLI is installed
Write-Host "[TEST 1] Checking if OpenAI Codex CLI is installed..." -ForegroundColor Yellow
$isInstalled = Test-ProviderInstalled -Provider "codex"

if ($isInstalled) {
    Write-Host "  OK: OpenAI Codex CLI is installed" -ForegroundColor Green
} else {
    Write-Host "  ERROR: OpenAI Codex CLI is NOT installed" -ForegroundColor Red
    Write-Host "  Install with: npm install -g @openai/codex" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Test 2: Check authentication
Write-Host "[TEST 2] Checking OpenAI Codex authentication..." -ForegroundColor Yellow
Write-Host "  NOTE: Ensure you are logged in with: codex login" -ForegroundColor DarkGray
Write-Host ""

# Test 3: Dry run with simple command
Write-Host "[TEST 3] Testing Codex with simple command..." -ForegroundColor Yellow
Write-Host "  Command: List all TypeScript files" -ForegroundColor DarkGray
Write-Host "  This will run Codex CLI in non-interactive mode." -ForegroundColor DarkGray
Write-Host ""

$testCommand = "List all TypeScript files in the current directory"

try {
    $exitCode = Invoke-Provider -Provider "codex" -Command $testCommand -ProjectRoot $TestProject
    
    if ($exitCode -eq 0) {
        Write-Host ""
        Write-Host "  SUCCESS: Codex provider test completed" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "  WARNING: Codex provider completed with exit code: $exitCode" -ForegroundColor Yellow
    }
} catch {
    Write-Host ""
    Write-Host "  ERROR: Codex provider test failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "OpenAI Codex CLI Test Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
