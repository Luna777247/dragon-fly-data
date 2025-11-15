# Get Primary Completion Rate data from World Bank
Write-Host "=== Fetching Primary Completion Rate Data ===" -ForegroundColor Cyan

# World Bank indicator for Primary Completion Rate
$indicator = "SE.PRM.CMPT.ZS"  # Primary completion rate, total (% of relevant age group)
$country = "VN"
$startYear = 2011
$endYear = 2024

Write-Host "`nDownloading data from World Bank API..." -ForegroundColor Yellow
$url = "https://api.worldbank.org/v2/country/$country/indicator/${indicator}?date=${startYear}:${endYear}&format=json&per_page=100"

try {
    $response = Invoke-RestMethod -Uri $url -Method Get
    
    if ($response.Count -ge 2 -and $response[1]) {
        $data = $response[1]
        
        Write-Host "✓ Data retrieved: $($data.Count) records" -ForegroundColor Green
        
        # Parse and organize data
        $completionRates = @{}
        foreach ($item in $data) {
            if ($item.value) {
                $year = [int]$item.date
                $rate = [math]::Round($item.value, 1)
                $completionRates[$year] = $rate
                Write-Host "  Year $year : $rate%" -ForegroundColor White
            }
        }
        
        # Save to JSON
        $completionRates | ConvertTo-Json | Out-File "primary_completion_rates.json" -Encoding UTF8
        Write-Host "`n✓ Data saved to primary_completion_rates.json" -ForegroundColor Green
        
        # Update CSV
        Write-Host "`nUpdating CSV file..." -ForegroundColor Yellow
        $csv = Import-Csv "src\data\vietnam_advance.csv" -Encoding UTF8
        $updates = 0
        
        foreach ($row in $csv) {
            $year = [int]$row.Year
            if ($completionRates.ContainsKey($year)) {
                $row.'Primary Completion Rate (%)' = $completionRates[$year]
                $updates++
            }
        }
        
        $csv | Export-Csv "src\data\vietnam_advance.csv" -Encoding UTF8 -NoTypeInformation
        
        Write-Host "✓ Updated $updates rows in CSV" -ForegroundColor Green
        
        # Verify update
        Write-Host "`n=== Verification ===" -ForegroundColor Cyan
        $csv = Import-Csv "src\data\vietnam_advance.csv" -Encoding UTF8
        $filled = ($csv | Where-Object { $_.'Primary Completion Rate (%)' -and $_.'Primary Completion Rate (%)' -ne "0" }).Count
        $total = $csv.Count
        $fillRate = [math]::Round(($filled / $total) * 100, 1)
        
        Write-Host "Primary Completion Rate column:" -ForegroundColor White
        Write-Host "  Filled rows: $filled / $total ($fillRate%)" -ForegroundColor $(if ($fillRate -ge 50) { "Green" } else { "Yellow" })
        
        # Show sample data
        Write-Host "`nSample data (2020-2024):" -ForegroundColor Cyan
        $recent = $csv | Where-Object { [int]$_.Year -ge 2020 -and [int]$_.Year -le 2024 }
        foreach ($r in $recent) {
            $rate = $r.'Primary Completion Rate (%)'
            $status = if ($rate -and $rate -ne "0") { "✓" } else { "✗" }
            Write-Host "  Year $($r.Year): $rate% $status" -ForegroundColor $(if ($rate -and $rate -ne "0") { "Green" } else { "Gray" })
        }
        
    } else {
        Write-Host "⚠ No data returned from API" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "✗ Error fetching data: $_" -ForegroundColor Red
}

Write-Host "`n=== Complete ===" -ForegroundColor Green
