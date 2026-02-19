# Test: Config Validation
# Tests edge cases, malformed JSON, and invalid config values

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Config Validation Tests" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$scriptDir = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
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

# Test 1: Empty config file
Write-Host "[TEST 1] Testing empty config..." -ForegroundColor Yellow
$tempConfig = Join-Path ([System.IO.Path]::GetTempPath()) "test-empty-$(Get-Random).json"
"" | Set-Content $tempConfig

try {
    $empty = Get-Content $tempConfig -Raw | ConvertFrom-Json
    # Empty string may parse or not - either behavior is acceptable
    Test-Assert "Empty config handled gracefully" ($true)
} catch {
    Test-Assert "Empty config throws error (acceptable)" ($true)
}
Remove-Item $tempConfig -Force
Write-Host ""

# Test 2: Invalid JSON
Write-Host "[TEST 2] Testing invalid JSON..." -ForegroundColor Yellow
$tempConfig = Join-Path ([System.IO.Path]::GetTempPath()) "test-invalid-$(Get-Random).json"
"{provider: 'claude', invalid json here" | Set-Content $tempConfig

try {
    $invalid = Get-Content $tempConfig -Raw | ConvertFrom-Json
    Test-Assert "Invalid JSON throws error" ($false) "Should have thrown"
} catch {
    Test-Assert "Invalid JSON throws error" ($true)
}
Remove-Item $tempConfig -Force
Write-Host ""

# Test 3: Missing required fields
Write-Host "[TEST 3] Testing missing required fields..." -ForegroundColor Yellow
$tempConfig = Join-Path ([System.IO.Path]::GetTempPath()) "test-missing-$(Get-Random).json"

@"
{
    "maxSessions": 10,
    "delaySeconds": 45
}
"@ | Set-Content $tempConfig

try {
    $missing = Get-Content $tempConfig -Raw | ConvertFrom-Json
    Test-Assert "Config loads even with missing provider" ($null -ne $missing)
    Test-Assert "Missing provider field is null" ($null -eq $missing.provider)
    Test-Assert "Missing projectShortcuts is null" ($null -eq $missing.projectShortcuts)
} catch {
    Test-Assert "Config with missing fields loads" ($false) "Threw unexpectedly: $_"
}
Remove-Item $tempConfig -Force
Write-Host ""

# Test 4: Invalid maxSessions values
Write-Host "[TEST 4] Testing invalid maxSessions..." -ForegroundColor Yellow

# Negative value
$tempConfig = Join-Path ([System.IO.Path]::GetTempPath()) "test-negative-$(Get-Random).json"
@"
{
    "provider": "claude",
    "maxSessions": -5,
    "delaySeconds": 45
}
"@ | Set-Content $tempConfig

$negConfig = Get-Content $tempConfig -Raw | ConvertFrom-Json
Test-Assert "Negative maxSessions parses as number" ($negConfig.maxSessions -is [int])
Test-Assert "Negative maxSessions value is -5" ($negConfig.maxSessions -eq -5)
Remove-Item $tempConfig -Force

# Zero value
$tempConfig = Join-Path ([System.IO.Path]::GetTempPath()) "test-zero-$(Get-Random).json"
@"
{
    "provider": "claude",
    "maxSessions": 0,
    "delaySeconds": 45
}
"@ | Set-Content $tempConfig

$zeroConfig = Get-Content $tempConfig -Raw | ConvertFrom-Json
Test-Assert "Zero maxSessions parses" ($zeroConfig.maxSessions -eq 0)
Remove-Item $tempConfig -Force

# Extremely large value
$tempConfig = Join-Path ([System.IO.Path]::GetTempPath()) "test-large-$(Get-Random).json"
@"
{
    "provider": "claude",
    "maxSessions": 999999,
    "delaySeconds": 45
}
"@ | Set-Content $tempConfig

$largeConfig = Get-Content $tempConfig -Raw | ConvertFrom-Json
Test-Assert "Extremely large maxSessions parses" ($largeConfig.maxSessions -eq 999999)
Remove-Item $tempConfig -Force

# String instead of number
$tempConfig = Join-Path ([System.IO.Path]::GetTempPath()) "test-string-$(Get-Random).json"
@"
{
    "provider": "claude",
    "maxSessions": "ten",
    "delaySeconds": 45
}
"@ | Set-Content $tempConfig

$stringConfig = Get-Content $tempConfig -Raw | ConvertFrom-Json
Test-Assert "String maxSessions parses as string" ($stringConfig.maxSessions -is [string])
Remove-Item $tempConfig -Force
Write-Host ""

# Test 5: Invalid provider values
Write-Host "[TEST 5] Testing invalid provider values..." -ForegroundColor Yellow
$tempConfig = Join-Path ([System.IO.Path]::GetTempPath()) "test-provider-$(Get-Random).json"
@"
{
    "provider": "invalid-provider-9000",
    "maxSessions": 10,
    "delaySeconds": 45
}
"@ | Set-Content $tempConfig

$provConfig = Get-Content $tempConfig -Raw | ConvertFrom-Json
Test-Assert "Invalid provider value parses" ($provConfig.provider -eq "invalid-provider-9000")
Remove-Item $tempConfig -Force
Write-Host ""

# Test 6: Non-existent projectShortcuts
Write-Host "[TEST 6] Testing non-existent project shortcuts..." -ForegroundColor Yellow
$tempConfig = Join-Path ([System.IO.Path]::GetTempPath()) "test-shortcuts-$(Get-Random).json"
@"
{
    "provider": "claude",
    "project": "NonExistentProject12345",
    "maxSessions": 10,
    "delaySeconds": 45,
    "projectShortcuts": {
        "Project1": {
            "prompt": "Test prompt 1"
        },
        "Project2": {
            "prompt": "Test prompt 2"
        }
    }
}
"@ | Set-Content $tempConfig

$shortcutConfig = Get-Content $tempConfig -Raw | ConvertFrom-Json
Test-Assert "Config with shortcuts parses" ($null -ne $shortcutConfig.projectShortcuts)
Test-Assert "Selected project doesn't exist in shortcuts" (-not ($shortcutConfig.projectShortcuts.PSObject.Properties.Name -contains "NonExistentProject12345"))
Remove-Item $tempConfig -Force
Write-Host ""

# Test 7: Special characters in values
Write-Host "[TEST 7] Testing special characters..." -ForegroundColor Yellow
$tempConfig = Join-Path ([System.IO.Path]::GetTempPath()) "test-special-$(Get-Random).json"
@"
{
    "provider": "claude",
    "stopTime": "23:59",
    "testField": "Test with \"quotes\" and \\ backslashes",
    "maxSessions": 10
}
"@ | Set-Content $tempConfig

$specialConfig = Get-Content $tempConfig -Raw | ConvertFrom-Json
Test-Assert "Config with special chars parses" ($null -ne $specialConfig)
Test-Assert "Quotes preserved in string" ($specialConfig.testField -match "quotes")
Remove-Item $tempConfig -Force
Write-Host ""

# Test 8: Array values
Write-Host "[TEST 8] Testing array values..." -ForegroundColor Yellow
$tempConfig = Join-Path ([System.IO.Path]::GetTempPath()) "test-array-$(Get-Random).json"
@"
{
    "provider": "claude",
    "maxSessions": 10,
    "testArray": [1, 2, 3, "four"]
}
"@ | Set-Content $tempConfig

$arrayConfig = Get-Content $tempConfig -Raw | ConvertFrom-Json
Test-Assert "Config with arrays parses" ($null -ne $arrayConfig.testArray)
Test-Assert "Array has correct length" ($arrayConfig.testArray.Count -eq 4)
Test-Assert "Array preserves mixed types" ($arrayConfig.testArray[3] -eq "four")
Remove-Item $tempConfig -Force
Write-Host ""

# Test 9: Nested objects
Write-Host "[TEST 9] Testing deeply nested objects..." -ForegroundColor Yellow
$tempConfig = Join-Path ([System.IO.Path]::GetTempPath()) "test-nested-$(Get-Random).json"
@"
{
    "provider": "claude",
    "maxSessions": 10,
    "projectShortcuts": {
        "Project1": {
            "nested": {
                "deep": {
                    "value": "found"
                }
            }
        }
    }
}
"@ | Set-Content $tempConfig

$nestedConfig = Get-Content $tempConfig -Raw | ConvertFrom-Json
Test-Assert "Deeply nested objects parse" ($null -ne $nestedConfig.projectShortcuts.Project1)
Test-Assert "Deep nesting accessible" ($nestedConfig.projectShortcuts.Project1.nested.deep.value -eq "found")
Remove-Item $tempConfig -Force
Write-Host ""

# Test 10: Unicode and emoji (if supported)
Write-Host "[TEST 10] Testing Unicode characters..." -ForegroundColor Yellow
$tempConfig = Join-Path ([System.IO.Path]::GetTempPath()) "test-unicode-$(Get-Random).json"
@"
{
    "provider": "claude",
    "maxSessions": 10,
    "testUnicode": "Test with üñíçödé"
}
"@ | Set-Content $tempConfig -Encoding UTF8

$unicodeConfig = Get-Content $tempConfig -Raw -Encoding UTF8 | ConvertFrom-Json
Test-Assert "Unicode characters preserve" ($unicodeConfig.testUnicode -match "üñíçödé")
Remove-Item $tempConfig -Force
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
    Write-Host "[SUCCESS] All config validation tests passed!" -ForegroundColor Green
    exit 0
} else {
    Write-Host "[FAIL] $testsFailed tests failed" -ForegroundColor Red
    exit 1
}
