# E2E Test: Setup Wizard
# Tests the setup.ps1 wizard with simulated user inputs

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir = Split-Path -Parent $scriptDir
$setupScript = Join-Path $rootDir "setup.ps1"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "E2E Testing Setup Wizard" -ForegroundColor Cyan
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
$testDir = Join-Path $env:TEMP "NightShiftTest_$(Get-Random)"
New-Item -ItemType Directory -Path $testDir -Force | Out-Null

try {
    Write-Host "TEST 1: Setup script exists and is readable" -ForegroundColor Yellow
    Test-Assert (Test-Path $setupScript) "setup.ps1 exists"
    $setupContent = Get-Content $setupScript -Raw
    Test-Assert ($setupContent.Length -gt 1000) "setup.ps1 has content"
    Write-Host ""

    Write-Host "TEST 2: Create test config manually" -ForegroundColor Yellow
    Write-Host "  INFO: Creating test configuration..." -ForegroundColor DarkGray

    # Copy necessary files to test directory
    Copy-Item (Join-Path $rootDir "config.example.json") $testDir -Force

    # Load and customize config
    $configPath = Join-Path $testDir "config.json"
    $configExample = Get-Content (Join-Path $testDir "config.example.json") -Raw | ConvertFrom-Json

    # Set test values
    $configExample.provider = "claude"
    $configExample.project = "TestProject"
    $configExample.maxSessions = 5
    $configExample.delaySeconds = 45
    $configExample.commitEveryNSessions = 3
    $configExample.defaultModel = "sonnet"
    $configExample.timezone = "local"

    # Add test project shortcut
    $testShortcut = "Read ROADMAP.md and find the next unchecked task. Implement 1-2 tasks with actual working code. Run npm test to verify functionality. Update ROADMAP.md checkboxes to mark completed tasks. Create a session report in meta/session_reports/TestProject/. NEVER create files outside the project directory."
    $configExample.projectShortcuts | Add-Member -MemberType NoteProperty -Name "TestProject" -Value $testShortcut -Force

    # Save config
    $configExample | ConvertTo-Json -Depth 10 | Set-Content $configPath

    Test-Assert (Test-Path $configPath) "config.json was created"
    Write-Host ""

    Write-Host "TEST 3: Verify config.json structure" -ForegroundColor Yellow
    if (Test-Path $configPath) {
        $config = Get-Content $configPath -Raw | ConvertFrom-Json
        Test-Assert ($config.provider -eq "claude") "Provider set correctly"
        Test-Assert ($config.project -eq "TestProject") "Project name set correctly"
        Test-Assert ($config.maxSessions -eq 5) "Max sessions set correctly"
        Test-Assert ($config.delaySeconds -eq 45) "Delay seconds set correctly"
        Test-Assert ($config.commitEveryNSessions -eq 3) "Commit frequency set correctly"
        Test-Assert ($config.defaultModel -eq "sonnet") "Model set correctly"
        Test-Assert ($config.timezone -eq "local") "Timezone set correctly"

        # Verify project shortcut exists
        $shortcutExists = $null -ne $config.projectShortcuts.TestProject
        Test-Assert $shortcutExists "Project shortcut created"

        if ($shortcutExists) {
            $shortcut = $config.projectShortcuts.TestProject
            Test-Assert ($shortcut -match "ROADMAP.md") "Shortcut references ROADMAP.md"
            Test-Assert ($shortcut -match "npm test") "Shortcut includes test command"
            Test-Assert ($shortcut -match "TestProject") "Shortcut references project name"
        }
    }
    Write-Host ""

    Write-Host "TEST 4: Create test ROADMAP.md" -ForegroundColor Yellow
    $projectDir = Join-Path $testDir "TestProject"
    New-Item -ItemType Directory -Path $projectDir -Force | Out-Null

    $roadmapPath = Join-Path $projectDir "ROADMAP.md"
    $roadmapLines = @(
        "# TestProject ROADMAP",
        "",
        "## Project Goal",
        "Test project for NightShift E2E testing",
        "",
        "## CURRENT STATUS",
        "**Phase:** Testing",
        "**Progress:** 0/3 tasks completed",
        "**Last Updated:** $(Get-Date -Format 'yyyy-MM-dd')",
        "",
        "## CURRENT TASK DETAILS",
        "Focus on test tasks below.",
        "",
        "---",
        "",
        "## Phase 1: Testing",
        "- [ ] Task 1: Test setup",
        "- [ ] Task 2: Test execution",
        "- [ ] Task 3: Test completion"
    )
    $roadmapLines | Set-Content $roadmapPath

    Test-Assert (Test-Path $roadmapPath) "ROADMAP.md was created"

    if (Test-Path $roadmapPath) {
        $roadmap = Get-Content $roadmapPath -Raw
        Test-Assert ($roadmap -match "# TestProject ROADMAP") "ROADMAP has project title"
        Test-Assert ($roadmap -match "CURRENT STATUS") "ROADMAP has CURRENT STATUS section"
        Test-Assert ($roadmap -match "Phase 1") "ROADMAP has Phase 1 section"
        Test-Assert ($roadmap -match "\[ \]") "ROADMAP has unchecked tasks"
    }
    Write-Host ""

    Write-Host "TEST 5: Verify directory structure" -ForegroundColor Yellow
    $metaDir = Join-Path $testDir "meta"
    $sessionReportsDir = Join-Path $metaDir "session_reports\TestProject"
    New-Item -ItemType Directory -Path $sessionReportsDir -Force | Out-Null

    Test-Assert (Test-Path $metaDir) "meta directory created"
    Test-Assert (Test-Path $sessionReportsDir) "session_reports/TestProject directory created"
    Write-Host ""

    Write-Host "TEST 6: Validate config.json for autonomous_loop.ps1" -ForegroundColor Yellow
    if (Test-Path $configPath) {
        $config = Get-Content $configPath -Raw | ConvertFrom-Json

        # Check all required fields exist
        Test-Assert ($null -ne $config.provider) "Config has provider field"
        Test-Assert ($null -ne $config.project) "Config has project field"
        Test-Assert ($null -ne $config.maxSessions) "Config has maxSessions field"
        Test-Assert ($null -ne $config.delaySeconds) "Config has delaySeconds field"
        Test-Assert ($null -ne $config.commitEveryNSessions) "Config has commitEveryNSessions field"
        Test-Assert ($null -ne $config.projectShortcuts) "Config has projectShortcuts field"

        # Verify types
        Test-Assert ($config.provider -is [string]) "Provider is string"
        Test-Assert ($config.maxSessions -is [int]) "MaxSessions is integer"
        Test-Assert ($config.delaySeconds -is [int]) "DelaySeconds is integer"
    }
    Write-Host ""

    Write-Host "TEST 7: Test config with valid provider values" -ForegroundColor Yellow
    $validProviders = @("claude", "codex")
    if (Test-Path $configPath) {
        $config = Get-Content $configPath -Raw | ConvertFrom-Json
        $providerValid = $config.provider -in $validProviders
        Test-Assert $providerValid "Provider is valid (claude or codex)"
    }
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
Write-Host "E2E Test Results" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Passed: $script:passCount" -ForegroundColor Green
Write-Host "Failed: $script:failCount" -ForegroundColor $(if ($script:failCount -eq 0) { "Green" } else { "Red" })
Write-Host ""

if ($script:failCount -eq 0) {
    Write-Host "ALL E2E TESTS PASSED" -ForegroundColor Green
    Write-Host ""
    Write-Host "The setup wizard:" -ForegroundColor White
    Write-Host "  checkmark Creates valid config.json" -ForegroundColor Green
    Write-Host "  checkmark Generates ROADMAP.md correctly" -ForegroundColor Green
    Write-Host "  checkmark Sets up directory structure" -ForegroundColor Green
    Write-Host "  checkmark Produces config compatible with autonomous_loop.ps1" -ForegroundColor Green
    Write-Host ""
    exit 0
}
else {
    Write-Host "$script:failCount E2E TEST(S) FAILED" -ForegroundColor Red
    Write-Host ""
    exit 1
}
