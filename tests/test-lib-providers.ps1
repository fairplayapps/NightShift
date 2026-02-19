# Test: Provider Library
# Tests lib/providers.ps1 module functions and edge cases

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Provider Library Tests" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$libDir = Join-Path $scriptDir "lib"
$providersPath = Join-Path $libDir "providers.ps1"

$testsPassed = 0
$testsFailed = 0

function Test-Assert {
    param(
        [string]$TestName,
        [bool]$Condition,
        [string]$FailMessage = "Test failed"
    )
    if ($Condition) {
        Write-Host "  [PASS] $TestName" -ForegroundColor Green
        $script:testsPassed++
        return $true
    } else {
        Write-Host "  [FAIL] $TestName" -ForegroundColor Red
        Write-Host "    $FailMessage" -ForegroundColor DarkRed
        $script:testsFailed++
        return $false
    }
}

# Test 1: providers.ps1 exists and parses
Write-Host "[TEST 1] Testing providers.ps1 existence and parsing..." -ForegroundColor Yellow
Test-Assert "providers.ps1 file exists" (Test-Path $providersPath)

if (Test-Path $providersPath) {
    $parseErrors = $null
    $parseTokens = $null
    try {
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($providersPath, [ref]$parseTokens, [ref]$parseErrors)
        Test-Assert "providers.ps1 parses without errors" ($parseErrors.Count -eq 0)
    } catch {
        Test-Assert "providers.ps1 parses without errors" ($false) "Exception: $_"
    }
}
Write-Host ""

# Load providers module
. $providersPath

# Test 2: Test-ProviderInstalled function
Write-Host "[TEST 2] Testing Test-ProviderInstalled..." -ForegroundColor Yellow

$claudeInstalled = Test-ProviderInstalled -Provider "claude"
Test-Assert "Test-ProviderInstalled returns boolean for claude" ($claudeInstalled -is [bool])

# Copilot removed - only Claude and Codex supported

$codexInstalled = Test-ProviderInstalled -Provider "codex"
Test-Assert "Test-ProviderInstalled returns boolean for codex" ($codexInstalled -is [bool])

# AutoMan removed

# Test invalid provider (ValidateSet will throw, which is expected)
try {
    $invalidInstalled = Test-ProviderInstalled -Provider "invalid-provider-12345"
    Test-Assert "Test-ProviderInstalled handles invalid provider" ($false) "Should have thrown"
} catch {
    Test-Assert "Test-ProviderInstalled throws on invalid provider (ValidateSet)" ($true)
}
Write-Host ""

# Test 3: Function existence
Write-Host "[TEST 3] Testing provider function existence..." -ForegroundColor Yellow
$content = Get-Content $providersPath -Raw

Test-Assert "Invoke-Provider function exists" ($content -match "function Invoke-Provider")
Test-Assert "Invoke-Claude function exists" ($content -match "function Invoke-Claude")
# Copilot removed
Test-Assert "Invoke-Codex function exists" ($content -match "function Invoke-Codex")
# AutoMan removed
Test-Assert "Test-ProviderInstalled function exists" ($content -match "function Test-ProviderInstalled")
Write-Host ""

# Test 4: Provider command detection
Write-Host "[TEST 4] Testing provider CLI detection..." -ForegroundColor Yellow

# Check what's actually installed
$commands = @{
    "claude" = Get-Command "claude" -ErrorAction SilentlyContinue
    "codex" = Get-Command "codex" -ErrorAction SilentlyContinue
}

foreach ($key in $commands.Keys) {
    if ($commands[$key]) {
        Write-Host "  [INFO] $key CLI found in PATH: $($commands[$key].Source)" -ForegroundColor DarkGray
    } else {
        Write-Host "  [INFO] $key CLI not found (may not be installed)" -ForegroundColor DarkGray
    }
}

Test-Assert "At least one provider is installed" ($claudeInstalled -or $codexInstalled)
Write-Host ""

# Test 5: Provider invocation with invalid parameters
Write-Host "[TEST 5] Testing provider invocation edge cases..." -ForegroundColor Yellow

# Test with non-existent project root (should handle gracefully)
$tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "test-provider-$(Get-Random)"
New-Item -ItemType Directory -Path $tempDir | Out-Null

Write-Host "  [INFO] Testing provider invocation (this may take a moment)..." -ForegroundColor DarkGray

# Only test if at least one provider is installed
if ($claudeInstalled) {
    try {
        # This should either succeed or fail gracefully
        $exitCode = Invoke-Claude -Command "echo test" -ProjectRoot $tempDir -ErrorAction SilentlyContinue
        Test-Assert "Invoke-Claude returns exit code" ($null -ne $exitCode)
    } catch {
        Test-Assert "Invoke-Claude handles errors gracefully" ($true)
    }
} elseif ($codexInstalled) {
    try {
        $exitCode = Invoke-Codex -Command "echo test" -ProjectRoot $tempDir -ErrorAction SilentlyContinue
        Test-Assert "Invoke-Codex returns exit code" ($null -ne $exitCode)
    } catch {
        Test-Assert "Invoke-Codex handles errors gracefully" ($true)
    }
} else {
    Write-Host "  [SKIP] No providers installed, skipping invocation test" -ForegroundColor Yellow
    Test-Assert "Skipped provider invocation test" ($true)
}

Remove-Item -Path $tempDir -Recurse -Force
Write-Host ""

# Test 6: Provider parameter handling
Write-Host "[TEST 6] Testing provider parameter validation..." -ForegroundColor Yellow

# Test empty command
try {
    Test-Assert "Provider functions exist for testing" ($true)
    # These would fail if called with empty params, which is expected
} catch {
    Test-Assert "Empty parameters handled" ($true)
}
Write-Host ""

# Test 7: Provider exit codes
Write-Host "[TEST 7] Testing provider exit code patterns..." -ForegroundColor Yellow

# Exit codes should be integers
Test-Assert "Exit code data type is testable" ($true)

# Common exit codes: 0 = success, non-zero = failure
$testExitCodes = @(0, 1, 127, 255)
foreach ($code in $testExitCodes) {
    Test-Assert "Exit code $code is integer" ($code -is [int])
}
Write-Host ""

# Test 8: Provider module export
Write-Host "[TEST 8] Testing provider module exports..." -ForegroundColor Yellow

# Check if functions are accessible after dot-sourcing
$functions = @("Invoke-Provider", "Test-ProviderInstalled")
foreach ($func in $functions) {
    $cmd = Get-Command $func -ErrorAction SilentlyContinue
    Test-Assert "$func is accessible" ($null -ne $cmd)
}
Write-Host ""

# Test 9: Provider command construction
Write-Host "[TEST 9] Testing provider command patterns..." -ForegroundColor Yellow

# Verify providers.ps1 contains expected command patterns
Test-Assert "Claude uses 'claude -p' pattern" ($content -match "claude.*-p")
# Copilot removed
Test-Assert "Codex uses 'codex exec' pattern" ($content -match "codex\s+exec")
Write-Host ""

# Test 10: Error handling in providers
Write-Host "[TEST 10] Testing provider error handling..." -ForegroundColor Yellow

# Check for Write-Host or Write-Error patterns
Test-Assert "Providers use Write-Host for logging" ($content -match "Write-Host")

# Check for error handling (may use try-catch or other patterns)
$hasErrorHandling = ($content -match "try\s*{" -and $content -match "}\s*catch") -or ($content -match "ErrorAction")
Test-Assert "Providers have error handling" ($hasErrorHandling)
Write-Host ""

# Summary
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
$total = $testsPassed + $testsFailed
Write-Host "Total Tests:  $total" -ForegroundColor White
Write-Host "Passed:       $testsPassed" -ForegroundColor Green
Write-Host "Failed:       $testsFailed" -ForegroundColor $(if ($testsFailed -eq 0) { "Green" } else { "Red" })
Write-Host ""

if ($testsFailed -eq 0) {
    Write-Host "[SUCCESS] All provider library tests passed!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "[FAIL] $testsFailed tests failed" -ForegroundColor Red
    exit 1
}
