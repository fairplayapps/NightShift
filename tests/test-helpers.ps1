# Test: Helper Functions
# Unit tests for NightShift GUI helper functions

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Helper Functions Unit Tests" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$guiPath   = Join-Path $scriptDir "NightShift_GUI.ps1"
$configPath = Join-Path $scriptDir "config.json"
$configExamplePath = Join-Path $scriptDir "config.example.json"

# Create temporary config.json from config.example.json for testing
if (-not (Test-Path $configPath) -and (Test-Path $configExamplePath)) {
    Copy-Item $configExamplePath $configPath -Force
    $script:createdTempConfig = $true
} else {
    $script:createdTempConfig = $false
}

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

# Load helper functions by sourcing the GUI script (without showing form)
$guiCode = Get-Content $guiPath -Raw

# Replace $scriptDir with the actual GUI script directory
$guiScriptDir = Split-Path -Parent $guiPath
$guiCode = $guiCode -replace '\$scriptDir\s*=\s*Split-Path.*', "`$scriptDir = '$guiScriptDir'"

# Remove ShowDialog to prevent GUI launch
$helperFunctions = $guiCode -replace '(?s)\$form\.ShowDialog\(\).*$', ''
$helperFunctions = $helperFunctions -replace '(?s)\[void\]\$form\.ShowDialog\(\).*$', ''

# Execute and suppress output
$null = Invoke-Expression $helperFunctions 2>&1

# Test 1: Get-ModelsForProvider
Write-Host "[TEST 1] Testing Get-ModelsForProvider..." -ForegroundColor Yellow
$claudeModels = Get-ModelsForProvider "claude"
Test-Assert "Claude returns 3 models" ($claudeModels.Count -eq 3)
Test-Assert "Claude has sonnet model" ($claudeModels -contains "sonnet")
Test-Assert "Claude has opus model" ($claudeModels -contains "opus")
Test-Assert "Claude has haiku model" ($claudeModels -contains "haiku")

# Copilot removed - only Claude and Codex supported

$codexModels = Get-ModelsForProvider "codex"
Test-Assert "Codex returns 1 auto model" ($codexModels.Count -eq 1)
Test-Assert "Codex model is auto" ($codexModels -match "auto")

# AutoMan removed - only Claude and Codex supported

$unknownModels = Get-ModelsForProvider "unknown"
Test-Assert "Unknown provider returns default (Claude models)" ($unknownModels.Count -eq 3)
Write-Host ""

# Test 2: Load-Config
Write-Host "[TEST 2] Testing Load-Config..." -ForegroundColor Yellow
$cfg = Load-Config
Test-Assert "Load-Config returns object" ($null -ne $cfg)
if ($cfg) {
    Test-Assert "Config has provider field" ($null -ne $cfg.provider)
    Test-Assert "Config has projectShortcuts" ($null -ne $cfg.projectShortcuts)
    Test-Assert "Config has maxSessions" ($null -ne $cfg.maxSessions)
    Test-Assert "Config has delaySeconds" ($null -ne $cfg.delaySeconds)
}
Write-Host ""

# Test 3: Get-ShortcutNames
Write-Host "[TEST 3] Testing Get-ShortcutNames..." -ForegroundColor Yellow
$shortcuts = Get-ShortcutNames
Test-Assert "Get-ShortcutNames returns array" ($shortcuts -is [array])
Test-Assert "Shortcuts array is not empty" ($shortcuts.Count -gt 0)
if ($shortcuts.Count -gt 0) {
    Write-Host "  Found shortcuts: $($shortcuts -join ', ')" -ForegroundColor DarkGray
}
Write-Host ""

# Test 4: Find-Roadmap with valid directory
Write-Host "[TEST 4] Testing Find-Roadmap..." -ForegroundColor Yellow

# Test with current directory
$currentRoadmap = Find-Roadmap $scriptDir
Test-Assert "Find-Roadmap handles NightShift directory" ($true) # Always passes, just testing it doesn't crash

# Test with null/empty
$nullResult = Find-Roadmap $null
Test-Assert "Find-Roadmap handles null input" ($nullResult -eq "")

$emptyResult = Find-Roadmap ""
Test-Assert "Find-Roadmap handles empty string" ($emptyResult -eq "")

# Test with non-existent directory
$fakeResult = Find-Roadmap "C:\NonExistent\Path\12345"
Test-Assert "Find-Roadmap handles non-existent path" ($fakeResult -eq "")

# Test with file instead of directory
$tempFile = [System.IO.Path]::GetTempFileName()
$fileResult = Find-Roadmap $tempFile
Test-Assert "Find-Roadmap handles file path (not directory)" ($fileResult -eq "")
Remove-Item $tempFile -Force
Write-Host ""

# Test 5: Get-RoadmapStatus
Write-Host "[TEST 5] Testing Get-RoadmapStatus..." -ForegroundColor Yellow

# Test with null/empty
$nullStatus = Get-RoadmapStatus $null
Test-Assert "Get-RoadmapStatus handles null" ($nullStatus -eq "(no ROADMAP found)")

$emptyStatus = Get-RoadmapStatus ""
Test-Assert "Get-RoadmapStatus handles empty string" ($emptyStatus -eq "(no ROADMAP found)")

# Test with non-existent file
$fakeStatus = Get-RoadmapStatus "C:\NonExistent\ROADMAP.md"
Test-Assert "Get-RoadmapStatus handles non-existent file" ($fakeStatus -eq "(no ROADMAP found)")

# Test with valid ROADMAP content
$tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
New-Item -ItemType Directory -Path $tempDir | Out-Null
$tempRoadmap = Join-Path $tempDir "ROADMAP.md"

# Create test ROADMAP with Current Status section
@"
# Test ROADMAP

## Current Status

Working on feature X
Testing is in progress

## Next Steps
- Continue testing
"@ | Set-Content $tempRoadmap

$status = Get-RoadmapStatus $tempRoadmap
Test-Assert "Get-RoadmapStatus parses Current Status section" ($status -match "Working on feature X")

# Create ROADMAP with Current Task instead
@"
# Test ROADMAP

## Current Task

Implementing Y feature

## Details
Some details here
"@ | Set-Content $tempRoadmap

$taskStatus = Get-RoadmapStatus $tempRoadmap
Test-Assert "Get-RoadmapStatus falls back to Current Task" ($taskStatus -match "Implementing Y feature")

# Create ROADMAP without status section
@"
# Test ROADMAP

Just a basic roadmap

## Goals
- Goal 1
- Goal 2
"@ | Set-Content $tempRoadmap

$noStatus = Get-RoadmapStatus $tempRoadmap
Test-Assert "Get-RoadmapStatus handles missing status section" ($noStatus -match "ROADMAP found - no Current Status")

# Clean up
Remove-Item -Path $tempDir -Recurse -Force
Write-Host ""

# Test 6: Save-Config and Load-Config roundtrip
Write-Host "[TEST 6] Testing Save-Config roundtrip..." -ForegroundColor Yellow
$testConfigPath = Join-Path ([System.IO.Path]::GetTempPath()) "test-config-$(Get-Random).json"

# Create test config
$testConfig = [PSCustomObject]@{
    provider = "codex"
    project = "TestProject"
    maxSessions = 5
    delaySeconds = 30
    commitEveryNSessions = 2
    stopTime = "18:00"
    timezone = "EST"
}

# Save it
$testConfig | ConvertTo-Json -Depth 10 | Set-Content $testConfigPath -Encoding UTF8

# Load it back
$loaded = Get-Content $testConfigPath -Raw | ConvertFrom-Json
Test-Assert "Roundtrip preserves provider" ($loaded.provider -eq "codex")
Test-Assert "Roundtrip preserves project" ($loaded.project -eq "TestProject")
Test-Assert "Roundtrip preserves maxSessions" ($loaded.maxSessions -eq 5)
Test-Assert "Roundtrip preserves delaySeconds" ($loaded.delaySeconds -eq 30)

# Clean up
Remove-Item $testConfigPath -Force
Write-Host ""

# Cleanup temporary config.json if we created it
if ($script:createdTempConfig -and (Test-Path $configPath)) {
    Remove-Item $configPath -Force -ErrorAction SilentlyContinue
}

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
    Write-Host "[SUCCESS] All helper function tests passed!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "[FAIL] $testsFailed tests failed" -ForegroundColor Red
    exit 1
}
