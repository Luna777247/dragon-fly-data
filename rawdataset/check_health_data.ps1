# Check latest health expenditure data
$data = Get-Content 'wb_health_expenditure.json' | ConvertFrom-Json
$vietnamData = $data[1] | Where-Object { $_.countryiso3code -eq 'VNM' } | Sort-Object date -Descending | Select-Object -First 5

Write-Host "Latest Health Expenditure data for Vietnam:" -ForegroundColor Green
foreach ($entry in $vietnamData) {
    Write-Host "$($entry.date): $($entry.value)"
}