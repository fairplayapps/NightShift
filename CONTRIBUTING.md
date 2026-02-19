# Contributing to NightShift

## How to Contribute

NightShift is shared as-is with limited maintenance. We welcome:
- **Bug reports** - Create a GitHub issue with steps to reproduce
- **Bug fix pull requests** - Fix issues and submit PRs
- **Documentation improvements** - Fix typos, clarify instructions, add examples
- **New provider implementations** - Add support for other AI CLIs

## Before Submitting a PR

1. **Run the test suite**: `.\tests\run-all-tests.ps1`
2. **Ensure all tests pass** - Fix any failing tests before submitting
3. **Update documentation** if adding features
4. **Test on clean Windows PowerShell 5.1+ environment**

## Code Style

- Follow existing PowerShell conventions in the codebase
- Use `Push-Location`/`Pop-Location` pattern for directory changes
- Add comments for complex logic
- Keep functions focused and single-purpose
- Use descriptive variable names

## Testing

Add tests for new functionality in `tests/` directory following existing patterns.

Test files use a simple assertion pattern:
```powershell
function Test-Assert {
    param($Condition, $Message)
    if ($Condition) {
        Write-Host "  ✓ $Message" -ForegroundColor Green
        return $true
    }
    else {
        Write-Host "  ✗ FAIL: $Message" -ForegroundColor Red
        return $false
    }
}
```

## Adding a New Provider

To add support for a new AI CLI:

1. Add provider to `lib/providers.ps1`:
   - Add case to `Invoke-Provider` switch
   - Create `Invoke-<ProviderName>` function
   - Add to `Test-ProviderInstalled` validation
   - Update ValidateSet attributes

2. Update GUI if applicable:
   - Add to `Get-ModelsForProvider` in `NightShift_GUI.ps1`
   - Add to provider dropdown list

3. Add tests:
   - Create `tests/test-<provider>.ps1`
   - Update `tests/run-all-tests.ps1`

4. Document:
   - Add section to `docs/PROVIDERS.md`
   - Update README.md
   - Update CLAUDE.md architecture section

## Questions?

Open a GitHub issue for questions or clarifications.

## License

By contributing to NightShift, you agree that your contributions will be licensed under the GPL v3 License.
