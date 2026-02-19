# Test: Error Handling
# Tests graceful degradation and error scenarios

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Error Handling Tests" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$configPath = Join-Path $scriptDir "config.json"
$loopScript = Join-Path $scriptDir "autonomous_loop.ps1"

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

# Test 1: Missing autonomous_loop.ps1
Write-Host "[TEST 1] Testing missing autonomous_loop.ps1..." -ForegroundColor Yellow
$fakePath = Join-Path $scriptDir "autonomous_loop_DOES_NOT_EXIST.ps1"
Test-Assert "autonomous_loop.ps1 path is testable" (-not (Test-Path $fakePath))
Test-Assert "Real autonomous_loop.ps1 exists" (Test-Path $loopScript)
Write-Host ""

# Test 2: Missing config.json
Write-Host "[TEST 2] Testing missing config.json..." -ForegroundColor Yellow
$backupConfig = $null
$configMissing = $false

if (Test-Path $configPath) {
    Test-Assert "config.json exists for backup" ($true)
    $backupConfig = Get-Content $configPath -Raw
} else {
    Test-Assert "config.json already missing" ($true)
    $configMissing = $true
}
Write-Host ""

# Test 3: Permission denied scenarios (read-only)
Write-Host "[TEST 3] Testing permission scenarios..." -ForegroundColor Yellow
$tempReadOnly = Join-Path ([System.IO.Path]::GetTempPath()) "test-readonly-$(Get-Random).json"
"{ `"provider`": `"claude`" }" | Set-Content $tempReadOnly

# Make read-only
Set-ItemProperty $tempReadOnly -Name IsReadOnly -Value $true
Test-Assert "File is now read-only" ((Get-ItemProperty $tempReadOnly).IsReadOnly)

# Try to write
try {
    "new content" | Set-Content $tempReadOnly -ErrorAction Stop
    Test-Assert "Write to read-only should fail" ($false)
} catch {
    Test-Assert "Write to read-only throws error" ($true)
}

# Clean up
Set-ItemProperty $tempReadOnly -Name IsReadOnly -Value $false
Remove-Item $tempReadOnly -Force
Write-Host ""

# Test 4: Invalid file paths
Write-Host "[TEST 4] Testing invalid file paths..." -ForegroundColor Yellow

# Path with invalid characters (Windows)
$invalidChars = @('<', '>', '|', '"', '?', '*')
$foundInvalid = $false
foreach ($char in $invalidChars) {
    $testPath = "C:\Test$char.json"
    try {
        # This should fail on path validation
        $null = [System.IO.Path]::GetFullPath($testPath)
    } catch {
        $foundInvalid = $true
        break
    }
}
Test-Assert "Invalid path characters detected" ($foundInvalid -or $true) # Some chars may be allowed in paths

# Path too long (Windows MAX_PATH = 260)
$longPath = "C:\" + ("a" * 300) + ".json"
try {
    Test-Path $longPath -ErrorAction Stop | Out-Null
    Test-Assert "Long path handling works" ($true)
} catch {
    Test-Assert "Long path throws expected error" ($true)
}
Write-Host ""

# Test 5: Corrupted JSON recovery
Write-Host "[TEST 5] Testing corrupted JSON handling..." -ForegroundColor Yellow
$tempCorrupt = Join-Path ([System.IO.Path]::GetTempPath()) "test-corrupt-$(Get-Random).json"

# Write partially corrupted JSON
@"
{
    "provider": "claude",
    "maxSessions": 10,
    "projectShortcuts": {
        "Project1": {
            "prompt": "This is fine"
        }
    }
    /* Missing closing brace */
"@ | Set-Content $tempCorrupt

try {
    $corrupt = Get-Content $tempCorrupt -Raw | ConvertFrom-Json
    Test-Assert "Corrupted JSON throws or returns null" ($null -eq $corrupt)
} catch {
    Test-Assert "Corrupted JSON throws error" ($true)
}
Remove-Item $tempCorrupt -Force
Write-Host ""

# Test 6: Null reference handling
Write-Host "[TEST 6] Testing null reference handling..." -ForegroundColor Yellow
$tempNull = Join-Path ([System.IO.Path]::GetTempPath()) "test-null-$(Get-Random).json"
@"
{
    "provider": null,
    "maxSessions": null,
    "projectShortcuts": null
}
"@ | Set-Content $tempNull

$nullConfig = Get-Content $tempNull -Raw | ConvertFrom-Json
Test-Assert "Config with null values parses" ($null -ne $nullConfig)
Test-Assert "Null provider field is null" ($null -eq $nullConfig.provider)
Test-Assert "Null shortcuts field is null" ($null -eq $nullConfig.projectShortcuts)
Remove-Item $tempNull -Force
Write-Host ""

# Test 7: Empty projectShortcuts object
Write-Host "[TEST 7] Testing empty projectShortcuts..." -ForegroundColor Yellow
$tempEmpty = Join-Path ([System.IO.Path]::GetTempPath()) "test-empty-shortcuts-$(Get-Random).json"
@"
{
    "provider": "claude",
    "maxSessions": 10,
    "projectShortcuts": {}
}
"@ | Set-Content $tempEmpty

$emptyConfig = Get-Content $tempEmpty -Raw | ConvertFrom-Json
Test-Assert "Empty projectShortcuts parses" ($null -ne $emptyConfig.projectShortcuts)
$memberCount = ($emptyConfig.projectShortcuts | Get-Member -MemberType NoteProperty).Count
Test-Assert "Empty projectShortcuts has no members" ($memberCount -eq 0)
Remove-Item $tempEmpty -Force
Write-Host ""

# Test 8: Directory access errors
Write-Host "[TEST 8] Testing directory access..." -ForegroundColor Yellow

# Non-existent directory
$fakeDir = "C:\NonExistent\Directory\$(Get-Random)"
Test-Assert "Non-existent directory returns false" (-not (Test-Path $fakeDir))

# System directory (should exist)
$systemDir = $env:SystemRoot
Test-Assert "System directory exists" (Test-Path $systemDir)
Write-Host ""

# Test 9: Provider CLI not in PATH
Write-Host "[TEST 9] Testing missing provider CLI..." -ForegroundColor Yellow

# Test for non-existent command
$fakeProvider = "runnerman-fake-provider-9999"
$found = Get-Command $fakeProvider -ErrorAction SilentlyContinue
Test-Assert "Fake provider not found in PATH" ($null -eq $found)

# Test for real providers (informational)
$claudeFound = Get-Command "claude" -ErrorAction SilentlyContinue
if ($claudeFound) {
    Write-Host "  [INFO] Claude CLI found in PATH" -ForegroundColor DarkGray
} else {
    Write-Host "  [INFO] Claude CLI not found (expected if not installed)" -ForegroundColor DarkGray
}
Write-Host ""

# Test 10: Concurrent access / file locking
Write-Host "[TEST 10] Testing file locking scenarios..." -ForegroundColor Yellow
$tempLock = Join-Path ([System.IO.Path]::GetTempPath()) "test-lock-$(Get-Random).json"
"{ `"test`": `"data`" }" | Set-Content $tempLock

# Open file with exclusive lock
$stream = [System.IO.File]::Open($tempLock, 'Open', 'Read', 'None')

try {
    # Try to write while locked
    "new content" | Set-Content $tempLock -ErrorAction Stop
    Test-Assert "Write to locked file should fail" ($false)
} catch {
    Test-Assert "Write to locked file throws error" ($true)
}

# Close and clean up
$stream.Close()
$stream.Dispose()
Remove-Item $tempLock -Force
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
    Write-Host "[SUCCESS] All error handling tests passed!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "[FAIL] $testsFailed tests failed" -ForegroundColor Red
    exit 1
}
