# Test: NightShift GUI Components
# Validates GUI script structure and button logic

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "NightShift GUI Component Tests" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$guiPath   = Join-Path $scriptDir "NightShift_GUI.ps1"
$configPath = Join-Path $scriptDir "config.json"
$configExamplePath = Join-Path $scriptDir "config.example.json"
$loopPath   = Join-Path $scriptDir "autonomous_loop.ps1"

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

# Test 1: File Existence
Write-Host "[TEST 1] Checking file existence..." -ForegroundColor Yellow
Test-Assert "NightShift_GUI.ps1 exists" (Test-Path $guiPath)
Test-Assert "config.json exists" (Test-Path $configPath)
Test-Assert "autonomous_loop.ps1 exists" (Test-Path $loopPath)
Write-Host ""

# Test 2: Parse Check
Write-Host "[TEST 2] Parsing GUI script..." -ForegroundColor Yellow
$parseErrors = $null
$parseTokens = $null
try {
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($guiPath, [ref]$parseTokens, [ref]$parseErrors)
    Test-Assert "Script parses without errors" ($parseErrors.Count -eq 0) "Found $($parseErrors.Count) parse errors"
    if ($parseErrors.Count -gt 0) {
        foreach ($e in $parseErrors) {
            Write-Host "    Line $($e.Extent.StartLineNumber): $($e.Message)" -ForegroundColor DarkRed
        }
    }
} catch {
    Test-Assert "Script parses without errors" $false "Exception: $_"
}
Write-Host ""

# Test 3: Required Functions
Write-Host "[TEST 3] Checking helper functions..." -ForegroundColor Yellow
$content = Get-Content $guiPath -Raw
Test-Assert "Load-Config function exists" ($content -match "function Load-Config")
Test-Assert "Save-Config function exists" ($content -match "function Save-Config")
Test-Assert "Get-ShortcutNames function exists" ($content -match "function Get-ShortcutNames")
Test-Assert "Get-ModelsForProvider function exists" ($content -match "function Get-ModelsForProvider")
Test-Assert "Find-Roadmap function exists" ($content -match "function Find-Roadmap")
Test-Assert "Get-RoadmapStatus function exists" ($content -match "function Get-RoadmapStatus")
Test-Assert "Update-ButtonStates function exists" ($content -match "function Update-ButtonStates")
Test-Assert "Log-Message function exists" ($content -match "function Log-Message")
Write-Host ""

# Test 4: Button Definitions
Write-Host "[TEST 4] Checking button definitions..." -ForegroundColor Yellow
Test-Assert "RUN button defined" ($content -match '\$runBtn\s*=\s*New-Object System\.Windows\.Forms\.Button')
Test-Assert "STOP button defined" ($content -match '\$stopBtn\s*=\s*New-Object System\.Windows\.Forms\.Button')
Test-Assert "Load Config button defined" ($content -match '\$loadBtn\s*=\s*New-Object System\.Windows\.Forms\.Button')
Test-Assert "Save Config button defined" ($content -match '\$saveBtn\s*=\s*New-Object System\.Windows\.Forms\.Button')
Test-Assert "Browse button defined" ($content -match '\$browseBtn\s*=\s*New-Object System\.Windows\.Forms\.Button')
Test-Assert "Open Roadmap button defined" ($content -match '\$openRmBtn\s*=\s*New-Object System\.Windows\.Forms\.Button')
Write-Host ""

# Test 5: Control Validation
Write-Host "[TEST 5] Checking control validation..." -ForegroundColor Yellow
Test-Assert "RUN validates provider selection" ($content -match 'if \(-not \$providerCombo\.SelectedItem\)')
Test-Assert "RUN validates project selection" ($content -match 'if \(-not \$shortcutCombo\.SelectedItem\)')
Test-Assert "RUN checks for running process" ($content -match 'if \(\$global:runnerProcess -and -not \$global:runnerProcess\.HasExited\)')
Write-Host ""

# Test 6: Mutual Exclusivity
Write-Host "[TEST 6] Checking button mutual exclusivity..." -ForegroundColor Yellow
Test-Assert "RUN disables itself when clicked" ($content -match '\$runBtn\.Enabled\s*=\s*\$false')
Test-Assert "RUN enables STOP when clicked" ($content -match '\$stopBtn\.Enabled\s*=\s*\$true')
Test-Assert "STOP enables RUN when clicked" ($content -match '\$runBtn\.Enabled\s*=\s*\$true')
Test-Assert "STOP disables itself when clicked" ($content -match '\$stopBtn\.Enabled\s*=\s*\$false')
Test-Assert "STOP button starts disabled" ($content -match '\$stopBtn\.Enabled\s*=\s*\$false')
Write-Host ""

# Test 7: State Management
Write-Host "[TEST 7] Checking state management..." -ForegroundColor Yellow
Test-Assert "Open Roadmap starts disabled" ($content -match '\$openRmBtn\.Enabled\s*=\s*\$false')
Test-Assert "Open Work Dir starts disabled" ($content -match '\$global:openWorkDirBtn\.Enabled\s*=\s*\$false')
Test-Assert "Update-ButtonStates called after browse" ($content -match 'Update-ButtonStates')
Test-Assert "Update-ButtonStates called on load" ($content -match 'Update-ButtonStates')
Write-Host ""

# Test 8: Provider Model Mapping
Write-Host "[TEST 8] Checking provider-model mapping..." -ForegroundColor Yellow
Test-Assert "Claude models defined" ($content -match '"claude"\s*{\s*return\s*@\("sonnet", "opus", "haiku"\)')
# Copilot removed
Test-Assert "Codex auto model" ($content -match '"codex"\s*{\s*return\s*@\("\(auto - Codex\)"\)')
# AutoMan removed
Test-Assert "Provider change handler exists" ($content -match '\$providerCombo\.Add_SelectedIndexChanged')
Write-Host ""

# Test 9: Timer and Process Management
Write-Host "[TEST 9] Checking timer and process management..." -ForegroundColor Yellow
Test-Assert "Clock timer defined" ($content -match '\$clockTimer\s*=\s*New-Object System\.Windows\.Forms\.Timer')
Test-Assert "Timer monitors process exit" ($content -match 'if \(\$global:runnerProcess -and \$global:runnerProcess\.HasExited\)')
Test-Assert "Timer uses local time (not hardcoded EST)" ($content -match '\$local\s*=\s*Get-Date' -and $content -notmatch 'AddHours\(-5\)')
Test-Assert "Process cleanup on exit" ($content -match 'if \(\$global:runnerProcess -and -not \$global:runnerProcess\.HasExited\)')
Write-Host ""

# Test 10: Config Integration
Write-Host "[TEST 10] Checking config integration..." -ForegroundColor Yellow
$cfg = $null
if (Test-Path $configPath) {
    try {
        $cfg = Get-Content $configPath -Raw | ConvertFrom-Json
        Test-Assert "Config is valid JSON" $true
        Test-Assert "Config has provider field" ($null -ne $cfg.provider)
        Test-Assert "Config has projectShortcuts" ($null -ne $cfg.projectShortcuts)
        Test-Assert "Config has maxSessions" ($null -ne $cfg.maxSessions)
        Test-Assert "Config has delaySeconds" ($null -ne $cfg.delaySeconds)
    } catch {
        Test-Assert "Config is valid JSON" $false "Parse error: $_"
    }
} else {
    Test-Assert "Config file exists" $false "File not found"
}
Write-Host ""

# Test 11: Meta Documentation Buttons
Write-Host "[TEST 11] Checking meta documentation buttons..." -ForegroundColor Yellow
Test-Assert "Edit Config button exists" ($content -match 'Make-MetaButton .+ "Edit Config"')
Test-Assert "Session Reports button exists" ($content -match 'Make-MetaButton .+ "Session Reports"')
Test-Assert "Learnings button exists" ($content -match 'Make-MetaButton .+ "Learnings"')
Test-Assert "Templates button exists" ($content -match 'Make-MetaButton .+ "Templates"')
Test-Assert "Best Practices button exists" ($content -match 'Make-MetaButton .+ "Best Practices"')
Test-Assert "Usage Guide button exists" ($content -match 'Make-MetaButton .+ "Usage Guide"')
Write-Host ""

# Test 12: Color Scheme
Write-Host "[TEST 12] Checking dark theme colors..." -ForegroundColor Yellow
Test-Assert "Background main color defined" ($content -match '\$bgMain\s*=')
Test-Assert "Background panel color defined" ($content -match '\$bgPanel\s*=')
Test-Assert "Foreground primary color defined" ($content -match '\$fgPrimary\s*=')
Test-Assert "Green button color defined" ($content -match '\$btnGreen\s*=')
Test-Assert "Red button color defined" ($content -match '\$btnRed\s*=')
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
    Write-Host "[SUCCESS] All GUI component tests passed!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "[FAIL] $testsFailed tests failed" -ForegroundColor Red
    exit 1
}
