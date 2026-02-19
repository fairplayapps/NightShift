# Test: Claude Provider
# Tests the Claude Code CLI integration

param(
    [string]$TestProject = "C:\TestProject"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Testing Claude Provider" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Import provider module
$libPath = Join-Path $PSScriptRoot "..\lib"
. (Join-Path $libPath "providers.ps1")

# Test 1: Check if Claude is installed
Write-Host "[TEST 1] Checking if Claude CLI is installed..." -ForegroundColor Yellow
$isInstalled = Test-ProviderInstalled -Provider "claude"

if ($isInstalled) {
    Write-Host "  [OK] Claude CLI is installed" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] Claude CLI is NOT installed" -ForegroundColor Red
    Write-Host "  Install with: npm install -g @anthropic-ai/claude-code" -ForegroundColor Yellow
    exit 1
}

Write-Host ""

# Test 2: Dry run with simple command
Write-Host "[TEST 2] Testing Claude with simple command..." -ForegroundColor Yellow
Write-Host "  Command: 'List all TypeScript files in the current directory'" -ForegroundColor DarkGray
Write-Host "  This will run Claude in the test project directory." -ForegroundColor DarkGray
Write-Host ""

$testCommand = "List all TypeScript files in the current directory"

try {
    $exitCode = Invoke-Provider -Provider "claude" -Command $testCommand -ProjectRoot $TestProject
    
    if ($exitCode -eq 0) {
        Write-Host ""
        Write-Host "  [OK] Claude provider test completed successfully" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "  [WARN] Claude provider completed with exit code: $exitCode" -ForegroundColor Yellow
    }
} catch {
    Write-Host ""
    Write-Host "  [FAIL] Claude provider test failed: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Claude Provider Test Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
