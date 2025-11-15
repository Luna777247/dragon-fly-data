# Check existing UNESCO education data
Write-Host "Checking existing UNESCO education data..." -ForegroundColor Green

$unescoFiles = @(
    "wb_unesco_mean_schooling.json",
    "wb_unesco_expected_schooling.json",
    "wb_unesco_literacy.json",
    "wb_unesco_primary_completion.json"
)

foreach ($file in $unescoFiles) {
    if (Test-Path $file) {
        Write-Host ""
        Write-Host "Checking $file..." -ForegroundColor Yellow

        try {
            $data = Get-Content $file | ConvertFrom-Json
            $vietnamData = $data[1] | Where-Object { $_.countryiso3code -eq 'VNM' -and $null -ne $_.value } | Sort-Object date -Descending
            $latest = $vietnamData | Select-Object -First 1

            if ($latest) {
                Write-Host "  ✓ Latest data: $($latest.date) = $($latest.value)" -ForegroundColor Green
                Write-Host "  Description: $($latest.indicator.value)" -ForegroundColor Gray

                # Show a few more recent years
                $recentData = $vietnamData | Select-Object -First 5
                Write-Host "  Recent data:" -ForegroundColor Cyan
                foreach ($entry in $recentData) {
                    Write-Host "    $($entry.date): $($entry.value)"
                }
            } else {
                Write-Host "  ✗ No Vietnam data found" -ForegroundColor Red
            }
        }
        catch {
            Write-Host "  ✗ Error reading file: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "$file not found" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Summary of available education indicators:" -ForegroundColor Cyan
$availableData = @()

foreach ($file in $unescoFiles) {
    if (Test-Path $file) {
        try {
            $data = Get-Content $file | ConvertFrom-Json
            $vietnamData = $data[1] | Where-Object { $_.countryiso3code -eq 'VNM' -and $null -ne $_.value }
            if ($vietnamData.Count -gt 0) {
                $latest = $vietnamData | Sort-Object date -Descending | Select-Object -First 1
                $availableData += @{
                    File = $file
                    LatestYear = $latest.date
                    LatestValue = $latest.value
                    Description = $latest.indicator.value
                }
            }
        }
        catch {
            # Continue
        }
    }
}

$availableData | ForEach-Object {
    Write-Host "• $($_.File): $($_.LatestYear) = $($_.LatestValue) ($($_.Description))"
}