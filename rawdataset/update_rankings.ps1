# Update CSV with rankings and regional data
Write-Host "=== Updating CSV with Rankings and Regional Data ===" -ForegroundColor Cyan

# Load the data files
$globalRanks = Get-Content "vietnam_global_ranks.json" -Raw | ConvertFrom-Json
$aseanRanks = Get-Content "vietnam_asean_ranks.json" -Raw | ConvertFrom-Json
$fertilityRates = Get-Content "asean_fertility_rates.json" -Raw | ConvertFrom-Json

# Load CSV
$csv = Import-Csv "src\data\vietnam_advance.csv" -Encoding UTF8

Write-Host "`nProcessing updates..." -ForegroundColor Yellow
$updates = 0

foreach ($row in $csv) {
    $year = [int]$row.Year
    
    # Update Global Rank
    $rankEntry = $globalRanks | Where-Object { $_.Year -eq $year }
    if ($rankEntry -and $rankEntry.Rank) {
        if ($row.'Vietnam Global Rank' -ne $rankEntry.Rank) {
            $row.'Vietnam Global Rank' = $rankEntry.Rank
            $updates++
        }
    }
    
    # Update ASEAN Rank
    $aseanEntry = $aseanRanks | Where-Object { $_.Year -eq $year }
    if ($aseanEntry -and $aseanEntry.Rank) {
        if ($row.'ASEAN Population Rank' -ne $aseanEntry.Rank) {
            $row.'ASEAN Population Rank' = $aseanEntry.Rank
            $updates++
        }
    }
    
    # Update Regional Fertility
    $fertilityEntry = $fertilityRates | Where-Object { $_.Year -eq $year }
    if ($fertilityEntry -and $fertilityEntry.Average) {
        if ($row.'Regional Avg Fertility Rate' -ne $fertilityEntry.Average) {
            $row.'Regional Avg Fertility Rate' = $fertilityEntry.Average
            $updates++
        }
    }
}

# Save updated CSV
$csv | Export-Csv "src\data\vietnam_advance.csv" -Encoding UTF8 -NoTypeInformation

Write-Host "`n✓ Updates completed: $updates values" -ForegroundColor Green

# Display sample data
Write-Host "`nSample data verification (2022-2024):" -ForegroundColor Cyan
$csv | Where-Object { [int]$_.Year -ge 2022 } | ForEach-Object {
    Write-Host "`nYear $($_.Year):" -ForegroundColor Yellow
    Write-Host "  Global Rank: $($_.'Vietnam Global Rank')" -ForegroundColor White
    Write-Host "  ASEAN Rank: $($_.'ASEAN Population Rank')" -ForegroundColor White
    Write-Host "  ASEAN Avg Fertility: $($_.'Regional Avg Fertility Rate')" -ForegroundColor White
}

Write-Host "`n=== Additional Columns Updated ===" -ForegroundColor Cyan
Write-Host "✓ Vietnam Global Rank" -ForegroundColor Green
Write-Host "✓ ASEAN Population Rank" -ForegroundColor Green
Write-Host "✓ Regional Avg Fertility Rate" -ForegroundColor Green
