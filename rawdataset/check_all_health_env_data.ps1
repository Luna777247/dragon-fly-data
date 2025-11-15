# Check latest data for health and environmental indicators
$indicators = @('health_expenditure', 'co2_emissions', 'renewable_energy')

foreach ($indicator in $indicators) {
    Write-Host "Latest $indicator data for Vietnam:" -ForegroundColor Yellow
    $data = Get-Content "wb_$indicator.json" | ConvertFrom-Json
    $vietnamData = $data[1] | Where-Object { $_.countryiso3code -eq 'VNM' -and $null -ne $_.value } | Sort-Object date -Descending | Select-Object -First 3

    foreach ($entry in $vietnamData) {
        Write-Host "  $($entry.date): $($entry.value)"
    }
    Write-Host ""
}