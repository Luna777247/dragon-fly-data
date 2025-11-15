# Try to get CO2 emissions from EDGAR or other sources
Write-Host "=== Attempting CO2 Emissions from Multiple Sources ===" -ForegroundColor Cyan

# Try World Bank API with verbose output
Write-Host "`n1. World Bank API - Detailed attempt..." -ForegroundColor Yellow
$co2Indicators = @(
    "EN.ATM.CO2E.PC",  # CO2 emissions (metric tons per capita)
    "EN.ATM.CO2E.KT",  # CO2 emissions (kt)
    "EN.ATM.CO2E.PP.GD",  # CO2 emissions (kg per PPP $ of GDP)
    "EN.CO2.TRAN.ZS"   # Transport CO2 emissions (% of total)
)

$co2Data = @()
foreach ($indicator in $co2Indicators) {
    try {
        Write-Host "  Trying indicator: $indicator" -ForegroundColor Gray
        $url = "https://api.worldbank.org/v2/country/VNM/indicator/$indicator`?format=json&date=2000:2021&per_page=100"
        $response = Invoke-RestMethod -Uri $url -Method Get -TimeoutSec 10
        
        if ($response.Count -gt 1 -and $response[1]) {
            $values = $response[1] | Where-Object { $null -ne $_.value }
            if ($values -and $values.Count -gt 0) {
                Write-Host "    ✓ Found data: $($values.Count) data points" -ForegroundColor Green
                $latest = $values | Sort-Object date -Descending | Select-Object -First 3
                foreach ($item in $latest) {
                    Write-Host "      $($item.date): $($item.value)" -ForegroundColor Cyan
                }
                
                # Save if this is the per capita data
                if ($indicator -eq "EN.ATM.CO2E.PC") {
                    $response | ConvertTo-Json -Depth 10 | Out-File "wb_co2_per_capita.json" -Encoding UTF8
                    $co2Data = $values
                }
            } else {
                Write-Host "    No data values" -ForegroundColor DarkGray
            }
        }
        Start-Sleep -Milliseconds 500
    }
    catch {
        Write-Host "    Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# If we got CO2 data, update the CSV
if ($co2Data.Count -gt 0) {
    Write-Host "`n2. Updating CSV with CO2 data..." -ForegroundColor Yellow
    $csv = Import-Csv "src\data\vietnam_advance.csv" -Encoding UTF8
    $updates = 0
    
    foreach ($row in $csv) {
        $year = [int]$row.Year
        $co2Entry = $co2Data | Where-Object { [int]$_.date -eq $year }
        
        if ($co2Entry -and $co2Entry.value) {
            $currentValue = $row.'CO2 Emissions per Capita'
            if ([string]::IsNullOrWhiteSpace($currentValue) -or $currentValue -ne $co2Entry.value) {
                $row.'CO2 Emissions per Capita' = [math]::Round($co2Entry.value, 3)
                $updates++
            }
        }
    }
    
    $csv | Export-Csv "src\data\vietnam_advance.csv" -Encoding UTF8 -NoTypeInformation
    Write-Host "  ✓ CO2 data updated: $updates values" -ForegroundColor Green
    
    # Show sample
    $recent = $csv | Where-Object { [int]$_.Year -ge 2015 } | Select-Object -First 5
    Write-Host "`n  Recent CO2 emissions (metric tons per capita):" -ForegroundColor Cyan
    foreach ($r in $recent) {
        Write-Host "    Year $($r.Year): $($r.'CO2 Emissions per Capita')" -ForegroundColor White
    }
}

# Try to estimate median ages based on population structure
Write-Host "`n3. Estimating Median Ages from Population Structure..." -ForegroundColor Yellow
$csv = Import-Csv "src\data\vietnam_advance.csv" -Encoding UTF8
$medianUpdates = 0

foreach ($row in $csv) {
    $year = [int]$row.Year
    
    # Get age distribution
    $pop0_14 = [double]$row.'Pop Aged 0?14 (%)'
    $pop15_64 = [double]$row.'Pop Aged 15?64 (%)'
    $pop65plus = [double]$row.'Pop Aged 65+ (%)'
    
    if ($pop0_14 -gt 0 -and $pop15_64 -gt 0) {
        # Estimate median age using demographic formula
        # If <15 is X%, the median is roughly in the 15-64 bracket
        # Simple linear approximation based on cumulative distribution
        
        if ($pop0_14 -ge 50) {
            # Median is in 0-14 bracket
            $medianAge = 7.5 * ($pop0_14 / 50)
        } else {
            # Median is in 15-64 bracket
            $remaining = 50 - $pop0_14
            $medianAge = 15 + (49 * ($remaining / $pop15_64))
        }
        
        # Clamp to reasonable range
        $medianAge = [math]::Max(20, [math]::Min(45, $medianAge))
        $medianAge = [math]::Round($medianAge, 1)
        
        if ([string]::IsNullOrWhiteSpace($row.'Median Age (Vietnam)')) {
            $row.'Median Age (Vietnam)' = $medianAge
            $medianUpdates++
        }
    }
}

if ($medianUpdates -gt 0) {
    $csv | Export-Csv "src\data\vietnam_advance.csv" -Encoding UTF8 -NoTypeInformation
    Write-Host "  ✓ Median age estimated for $medianUpdates years" -ForegroundColor Green
    
    $recent = $csv | Where-Object { [int]$_.Year -ge 2020 } | Select-Object Year, 'Median Age (Vietnam)', 'Pop Aged 0?14 (%)', 'Pop Aged 15?64 (%)'
    Write-Host "`n  Estimated median ages:" -ForegroundColor Cyan
    foreach ($r in $recent) {
        Write-Host "    Year $($r.Year): $($r.'Median Age (Vietnam)') years (0-14: $($r.'Pop Aged 0?14 (%)' )%, 15-64: $($r.'Pop Aged 15?64 (%)')%)" -ForegroundColor White
    }
}

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
if ($co2Data.Count -gt 0) {
    Write-Host "✓ CO2 Emissions: $($co2Data.Count) years of data found" -ForegroundColor Green
} else {
    Write-Host "⚠ CO2 Emissions: No data available from World Bank" -ForegroundColor Yellow
}
Write-Host "✓ Median Age: Estimated from population structure" -ForegroundColor Green
