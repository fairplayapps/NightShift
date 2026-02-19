# Run All NightShift Tests
# Comprehensive test suite for all components

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$testFiles = @(
    "test-gui.ps1",
    "test-helpers.ps1",
    "test-config-validation.ps1",
    "test-error-handling.ps1",
    "test-lib-providers.ps1",
    "test-claude.ps1",
    "test-codex.ps1",
    "test-setup-wizard-e2e.ps1",
    "test-gui-e2e.ps1"
)

Write-Host ""
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "   NIGHTSHIFT COMPREHENSIVE TEST SUITE" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

$totalTests  = 0
$passedTests = 0
$failedTests = 0
$skippedTests = 0

foreach ($testFile in $testFiles) {
    $testPath = Join-Path $scriptDir $testFile
    
    if (-not (Test-Path $testPath)) {
        Write-Host "[SKIP] $testFile (not found)" -ForegroundColor Yellow
        $skippedTests++
        Write-Host ""
        continue
    }
    
    Write-Host "Running $testFile..." -ForegroundColor Cyan
    Write-Host ""
    
    try {
        & $testPath
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[PASS] $testFile PASSED" -ForegroundColor Green
            $passedTests++
        } else {
            Write-Host "[FAIL] $testFile FAILED (exit code: $LASTEXITCODE)" -ForegroundColor Red
            $failedTests++
        }
    } catch {
        Write-Host "[FAIL] $testFile FAILED (exception: $_)" -ForegroundColor Red
        $failedTests++
    }
    
    $totalTests++
    Write-Host ""
    Write-Host "-----------------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
}

# Summary
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "   TEST SUITE SUMMARY" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "Total Test Files: $totalTests" -ForegroundColor White
Write-Host "Passed:           $passedTests" -ForegroundColor Green
Write-Host "Failed:           $failedTests" -ForegroundColor $(if ($failedTests -eq 0) { "Green" } else { "Red" })
Write-Host "Skipped:          $skippedTests" -ForegroundColor Yellow
Write-Host ""

if ($failedTests -eq 0 -and $totalTests -gt 0) {
    Write-Host ">>> ALL TESTS PASSED! <<<" -ForegroundColor Green
    Write-Host ""
    Write-Host "NightShift is ready for use." -ForegroundColor Green
    Write-Host ""
    Write-Host "Next Steps:" -ForegroundColor Cyan
    Write-Host "  1. Review GUI_TEST_CHECKLIST.md for manual testing" -ForegroundColor White
    Write-Host "  2. Launch GUI with: .\Launch_GUI.bat" -ForegroundColor White
    Write-Host "  3. Configure provider and project settings" -ForegroundColor White
    Write-Host "  4. Click RUN to start autonomous session" -ForegroundColor White
    Write-Host ""
    exit 0
} elseif ($totalTests -eq 0) {
    Write-Host "[WARN] No tests were run" -ForegroundColor Yellow
    exit 1
} else {
    Write-Host ">>> $failedTests TEST(S) FAILED <<<" -ForegroundColor Red
    Write-Host ""
    Write-Host "Review the output above for details." -ForegroundColor Yellow
    Write-Host ""
    exit 1
}
