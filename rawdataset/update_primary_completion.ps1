# Update Primary Completion Rate in CSV
Write-Host "=== Updating Primary Completion Rate ===" -ForegroundColor Cyan

# Data from World Bank API SE.PRM.CMPT.ZS
$completionData = @{
    2011 = 96.5
    2012 = 99.7
    2013 = 98.6
    2014 = 97.6
    2015 = 97.3
    2016 = 100.0
    2018 = 101.7
    2022 = 100.8
    2024 = 100.6
}

Write-Host "`nData to update:" -ForegroundColor Yellow
foreach ($year in $completionData.Keys | Sort-Object) {
    Write-Host "  Year $year : $($completionData[$year])%" -ForegroundColor White
}

# Load and update CSV
Write-Host "`nUpdating CSV..." -ForegroundColor Yellow
$csv = Import-Csv "src\data\vietnam_advance.csv" -Encoding UTF8
$updates = 0

foreach ($row in $csv) {
    $year = [int]$row.Year
    if ($completionData.ContainsKey($year)) {
        $row.'Primary Completion Rate (%)' = $completionData[$year]
        $updates++
    }
}

$csv | Export-Csv "src\data\vietnam_advance.csv" -Encoding UTF8 -NoTypeInformation

Write-Host "✓ Updated $updates rows" -ForegroundColor Green

# Verify
Write-Host "`n=== Verification ===" -ForegroundColor Cyan
$csv = Import-Csv "src\data\vietnam_advance.csv" -Encoding UTF8
$filled = ($csv | Where-Object { $_.'Primary Completion Rate (%)' -and $_.'Primary Completion Rate (%)' -ne "0" -and $_.'Primary Completion Rate (%)' -ne "" }).Count
$total = $csv.Count
$fillRate = [math]::Round(($filled / $total) * 100, 1)

Write-Host "Primary Completion Rate column:" -ForegroundColor White
Write-Host "  Filled: $filled / $total rows ($fillRate%)" -ForegroundColor $(if ($fillRate -ge 50) { "Green" } else { "Yellow" })

# Show all data
Write-Host "`nAll data (2011-2024):" -ForegroundColor Cyan
foreach ($row in $csv) {
    $rate = $row.'Primary Completion Rate (%)'
    $status = if ($rate -and $rate -ne "0" -and $rate -ne "") { "✓" } else { "✗" }
    $color = if ($rate -and $rate -ne "0" -and $rate -ne "") { "Green" } else { "Gray" }
    Write-Host "  Year $($row.Year): $(if ($rate) { "$rate%" } else { "N/A" }) $status" -ForegroundColor $color
}

Write-Host "`n✅ Update complete!" -ForegroundColor Green
Write-Host "   Missing years: 2017, 2019-2021, 2023 (World Bank has no data)" -ForegroundColor Yellow
