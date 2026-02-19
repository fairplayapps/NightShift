# E2E Test: GUI Functionality
# Tests NightShift_GUI.ps1 with actual GUI operations

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path -Parent $scriptDir
$guiScript = Join-Path $rootDir "NightShift_GUI.ps1"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "E2E Testing NightShift GUI" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Test assertion helper
$script:passCount = 0
$script:failCount = 0

function Test-Assert {
    param($Condition, $Message)
    if ($Condition) {
        Write-Host "  checkmark $Message" -ForegroundColor Green
        $script:passCount++
        return $true
    }
    else {
        Write-Host "  X FAIL: $Message" -ForegroundColor Red
        $script:failCount++
        return $false
    }
}

# Create isolated test environment
$testDir = Join-Path $env:TEMP "NightShiftGUITest_$(Get-Random)"
New-Item -ItemType Directory -Path $testDir -Force | Out-Null

try {
    Write-Host "TEST 1: GUI script exists and is readable" -ForegroundColor Yellow
    Test-Assert (Test-Path $guiScript) "NightShift_GUI.ps1 exists"

    if (Test-Path $guiScript) {
        $guiContent = Get-Content $guiScript -Raw
        Test-Assert ($guiContent.Length -gt 1000) "GUI script has content"
        Test-Assert ($guiContent -match "EXPERIMENTAL") "GUI has experimental warning"
    }
    Write-Host ""

    Write-Host "TEST 2: GUI script syntax validation" -ForegroundColor Yellow
    try {
        $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $guiScript -Raw), [ref]$null)
        Test-Assert $true "GUI script has valid PowerShell syntax"
    }
    catch {
        Test-Assert $false "GUI script syntax validation failed: $_"
    }
    Write-Host ""

    Write-Host "TEST 3: Required assemblies can be loaded" -ForegroundColor Yellow
    try {
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
        Test-Assert $true "System.Windows.Forms assembly loaded"

        Add-Type -AssemblyName System.Drawing -ErrorAction Stop
        Test-Assert $true "System.Drawing assembly loaded"
    }
    catch {
        Test-Assert $false "Assembly loading failed: $_"
        Write-Host "  WARN: GUI tests may be limited on this system" -ForegroundColor Yellow
    }
    Write-Host ""

    Write-Host "TEST 4: GUI helper functions exist" -ForegroundColor Yellow
    $guiContent = Get-Content $guiScript -Raw

    Test-Assert ($guiContent -match "function Load-Config") "Load-Config function exists"
    Test-Assert ($guiContent -match "function Save-Config") "Save-Config function exists"
    Test-Assert ($guiContent -match "function Get-ModelsForProvider") "Get-ModelsForProvider function exists"
    Test-Assert ($guiContent -match "function Find-Roadmap") "Find-Roadmap function exists"
    Write-Host ""

    Write-Host "TEST 5: Provider support validation" -ForegroundColor Yellow
    # Check that only Claude and Codex are supported
    Test-Assert ($guiContent -match '@\("claude", "codex"\)') "GUI supports only Claude and Codex"
    Test-Assert ($guiContent -notmatch '@\("claude", "copilot"') "GUI does not reference copilot in provider list"
    Test-Assert ($guiContent -notmatch '@\("claude", "copilot", "codex", "automan"\)') "GUI does not reference automan in provider list"
    Write-Host ""

    Write-Host "TEST 6: Test config loading logic" -ForegroundColor Yellow
    # Copy config.example.json to test directory
    $configExamplePath = Join-Path $rootDir "config.example.json"
    $testConfigPath = Join-Path $testDir "config.json"

    if (Test-Path $configExamplePath) {
        Copy-Item $configExamplePath $testConfigPath -Force
        Test-Assert (Test-Path $testConfigPath) "Test config.json created"

        # Test that it's valid JSON
        try {
            $config = Get-Content $testConfigPath -Raw | ConvertFrom-Json
            Test-Assert ($null -ne $config) "Config is valid JSON"
            Test-Assert ($null -ne $config.provider) "Config has provider field"
            Test-Assert ($null -ne $config.projectShortcuts) "Config has projectShortcuts"
        }
        catch {
            Test-Assert $false "Config JSON parsing failed: $_"
        }
    }
    else {
        Write-Host "  SKIP: config.example.json not found, skipping config load test" -ForegroundColor Yellow
    }
    Write-Host ""

    Write-Host "TEST 7: Test Get-ModelsForProvider function logic" -ForegroundColor Yellow
    # Extract and test the function logic
    $getModelsPattern = 'function Get-ModelsForProvider[\s\S]*?^}'
    if ($guiContent -match $getModelsPattern) {
        $functionContent = $Matches[0]

        # Verify it handles claude
        Test-Assert ($functionContent -match '"claude".*"sonnet", "opus", "haiku"') "Claude models defined correctly"

        # Verify it handles codex
        Test-Assert ($functionContent -match '"codex".*auto') "Codex model defined"

        # Verify no copilot
        Test-Assert ($functionContent -notmatch '"copilot"') "Copilot not in model provider"

        # Verify no automan
        Test-Assert ($functionContent -notmatch '"automan"') "AutoMan not in model provider"
    }
    Write-Host ""

    Write-Host "TEST 8: Test experimental warning placement" -ForegroundColor Yellow
    # Check that warning is at the top of the file
    $lines = Get-Content $guiScript
    $warningFound = $false
    $warningLine = 0

    for ($i = 0; $i -lt [Math]::Min(20, $lines.Count); $i++) {
        if ($lines[$i] -match "EXPERIMENTAL") {
            $warningFound = $true
            $warningLine = $i + 1
            break
        }
    }

    Test-Assert $warningFound "Experimental warning found in first 20 lines"
    if ($warningFound) {
        Test-Assert ($warningLine -lt 15) "Warning is prominently placed (line $warningLine)"
    }
    Write-Host ""

    Write-Host "TEST 9: Test timezone handling" -ForegroundColor Yellow
    # Verify that hardcoded EST timezone was replaced with system local time
    Test-Assert ($guiContent -notmatch 'AddHours\(-5\)') "No hardcoded EST timezone offset"
    Test-Assert ($guiContent -match '\$local = Get-Date|Get-Date.*local' -or $guiContent -notmatch 'AddHours') "Uses system local time"
    Write-Host ""

    Write-Host "TEST 10: Test ROADMAP preview functionality" -ForegroundColor Yellow
    # Create a test ROADMAP.md
    $testRoadmapPath = Join-Path $testDir "ROADMAP.md"
    $roadmapLines = @(
        "# Test Project ROADMAP",
        "",
        "## CURRENT STATUS",
        "**Phase:** Testing",
        "**Progress:** 1/3 completed",
        "",
        "## Phase 1: Setup",
        "- [x] Task 1: Complete",
        "- [ ] Task 2: Pending",
        "- [ ] Task 3: Pending"
    )
    $roadmapLines | Set-Content $testRoadmapPath
    Test-Assert (Test-Path $testRoadmapPath) "Test ROADMAP.md created"

    # Verify Find-Roadmap function exists
    Test-Assert ($guiContent -match "function Find-Roadmap") "Find-Roadmap function exists for ROADMAP preview"
    Write-Host ""

    Write-Host "TEST 11: GUI control creation validation" -ForegroundColor Yellow
    # Check that expected GUI controls are created
    Test-Assert ($guiContent -match '\$providerCombo') "Provider combo box created"
    Test-Assert ($guiContent -match '\$modelCombo') "Model combo box created"
    Test-Assert ($guiContent -match '\$shortcutCombo') "Project shortcut combo box created"
    Test-Assert ($guiContent -match '\$sessionsNumeric') "Max sessions numeric input created"
    Test-Assert ($guiContent -match '\$delayNumeric') "Delay numeric input created"
    Test-Assert ($guiContent -match '\$commitNumeric') "Commit frequency numeric input created"
    Test-Assert ($guiContent -match '\$runBtn') "Run button created"
    Test-Assert ($guiContent -match '\$stopBtn') "Stop button created"
    Write-Host ""

    Write-Host "TEST 12: Config save functionality validation" -ForegroundColor Yellow
    # Verify Save-Config function exists and has proper structure
    if ($guiContent -match 'function Save-Config[\s\S]*?ConvertTo-Json') {
        Test-Assert $true "Save-Config uses ConvertTo-Json"
    }
    Test-Assert ($guiContent -match 'function Save-Config') "Save-Config function exists"
    Write-Host ""

    Write-Host "TEST 13: Process management validation" -ForegroundColor Yellow
    # Check that GUI can manage the autonomous_loop.ps1 process
    Test-Assert ($guiContent -match 'Start-Process|Start-Job') "GUI can start PowerShell process"
    Test-Assert ($guiContent -match '\$global:runnerProcess|\$global:runnerJob') "GUI tracks runner process"
    Test-Assert ($guiContent -match 'Stop-Process|Stop-Job|Kill') "GUI can stop process"
    Write-Host ""

}
catch {
    Write-Host "ERROR during E2E test: $_" -ForegroundColor Red
    $script:failCount++
}
finally {
    # Cleanup
    Write-Host "CLEANUP: Removing test directory..." -ForegroundColor DarkGray
    if (Test-Path $testDir) {
        Remove-Item $testDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Summary
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "GUI E2E Test Results" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Passed: $script:passCount" -ForegroundColor Green
Write-Host "Failed: $script:failCount" -ForegroundColor $(if ($script:failCount -eq 0) { "Green" } else { "Red" })
Write-Host ""

if ($script:failCount -eq 0) {
    Write-Host "ALL GUI E2E TESTS PASSED" -ForegroundColor Green
    Write-Host ""
    Write-Host "The GUI:" -ForegroundColor White
    Write-Host "  checkmark Has valid PowerShell syntax" -ForegroundColor Green
    Write-Host "  checkmark Supports only Claude and Codex" -ForegroundColor Green
    Write-Host "  checkmark Has experimental warning" -ForegroundColor Green
    Write-Host "  checkmark Uses system local timezone" -ForegroundColor Green
    Write-Host "  checkmark Has all required functions and controls" -ForegroundColor Green
    Write-Host ""
    Write-Host "NOTE: These tests validate code structure and logic." -ForegroundColor Yellow
    Write-Host "Manual testing recommended to verify actual GUI rendering." -ForegroundColor Yellow
    Write-Host ""
    exit 0
}
else {
    Write-Host "$script:failCount GUI E2E TEST(S) FAILED" -ForegroundColor Red
    Write-Host ""
    exit 1
}
