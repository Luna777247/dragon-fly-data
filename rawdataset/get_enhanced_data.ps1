# Enhanced script to get CO2 and calculate rankings
Write-Host "=== Enhanced Data Collection for Remaining Columns ===" -ForegroundColor Cyan

# Try CO2 with different date ranges and fallback
Write-Host "`n1. CO2 Emissions - Trying multiple approaches..." -ForegroundColor Yellow
$co2Found = $false

# Try approach 1: Recent years only
try {
    $url = "https://api.worldbank.org/v2/country/VN/indicator/EN.ATM.CO2E.PC?format=json&date=2015:2021&per_page=100"
    Write-Host "  Trying 2015-2021 range..." -ForegroundColor Gray
    $response = Invoke-RestMethod -Uri $url -Method Get
    
    if ($response.Count -gt 1 -and $response[1]) {
        $data = $response[1] | Where-Object { $null -ne $_.value } | Sort-Object date -Descending
        if ($data -and $data.Count -gt 0) {
            Write-Host "  ✓ CO2 Data Found!" -ForegroundColor Green
            foreach ($item in $data | Select-Object -First 5) {
                Write-Host "    $($item.date): $($item.value) metric tons per capita" -ForegroundColor Cyan
            }
            $response | ConvertTo-Json -Depth 10 | Out-File "wb_co2_emissions.json" -Encoding UTF8
            $co2Found = $true
        }
    }
}
catch {
    Write-Host "  Failed: $_" -ForegroundColor Red
}

# Try approach 2: Alternative CO2 indicator
if (-not $co2Found) {
    Write-Host "  Trying alternative indicator EN.ATM.CO2E.KT..." -ForegroundColor Gray
    try {
        $url = "https://api.worldbank.org/v2/country/VN/indicator/EN.ATM.CO2E.KT?format=json&date=2015:2021"
        $response = Invoke-RestMethod -Uri $url -Method Get
        
        if ($response.Count -gt 1 -and $response[1]) {
            $data = $response[1] | Where-Object { $null -ne $_.value }
            if ($data) {
                Write-Host "  ✓ Total CO2 Emissions Found (will need to convert to per capita)" -ForegroundColor Yellow
                $latest = $data | Sort-Object date -Descending | Select-Object -First 1
                Write-Host "    $($latest.date): $($latest.value) kilotons" -ForegroundColor Cyan
            }
        }
    }
    catch {
        Write-Host "  Failed" -ForegroundColor Red
    }
}

# Calculate Global Rank with actual data
Write-Host "`n2. Calculating Vietnam Global Population Rank (2022-2024)..." -ForegroundColor Yellow
$years = @(2024, 2023, 2022)
$rankData = @()

foreach ($year in $years) {
    try {
        Write-Host "  Processing year $year..." -ForegroundColor Gray
        $url = "https://api.worldbank.org/v2/country/all/indicator/SP.POP.TOTL?format=json&date=$year&per_page=300"
        $response = Invoke-RestMethod -Uri $url -Method Get
        
        if ($response.Count -gt 1 -and $response[1]) {
            $allCountries = $response[1] | Where-Object { 
                $null -ne $_.value -and $_.value -gt 0 -and $_.countryiso3code -ne ''
            } | Sort-Object value -Descending
            
            $rank = 0
            $vnPop = 0
            foreach ($i in 0..($allCountries.Count - 1)) {
                if ($allCountries[$i].countryiso3code -eq 'VNM') {
                    $rank = $i + 1
                    $vnPop = $allCountries[$i].value
                    break
                }
            }
            
            if ($rank -gt 0) {
                Write-Host "    ✓ Year $year`: Rank #$rank (Population: $([math]::Round($vnPop/1000000, 2))M)" -ForegroundColor Green
                $rankData += [PSCustomObject]@{
                    Year = $year
                    Rank = $rank
                    Population = $vnPop
                }
            }
        }
        Start-Sleep -Milliseconds 500
    }
    catch {
        Write-Host "    Failed for $year" -ForegroundColor Red
    }
}

if ($rankData.Count -gt 0) {
    $rankData | ConvertTo-Json | Out-File "vietnam_global_ranks.json" -Encoding UTF8
}

# Calculate ASEAN Rank with historical data
Write-Host "`n3. Calculating ASEAN Population Rankings..." -ForegroundColor Yellow
$aseanCountries = @{
    'IDN' = 'Indonesia'
    'PHL' = 'Philippines'
    'VNM' = 'Vietnam'
    'THA' = 'Thailand'
    'MYS' = 'Malaysia'
    'MMR' = 'Myanmar'
    'KHM' = 'Cambodia'
    'LAO' = 'Laos'
    'SGP' = 'Singapore'
    'BRN' = 'Brunei'
}

$aseanRankData = @()
foreach ($year in $years) {
    Write-Host "  Processing ASEAN for year $year..." -ForegroundColor Gray
    $yearData = @()
    
    foreach ($code in $aseanCountries.Keys) {
        try {
            $url = "https://api.worldbank.org/v2/country/$code/indicator/SP.POP.TOTL?format=json&date=$year"
            $response = Invoke-RestMethod -Uri $url -Method Get
            
            if ($response.Count -gt 1 -and $response[1] -and $response[1][0].value) {
                $yearData += [PSCustomObject]@{
                    Country = $aseanCountries[$code]
                    Code = $code
                    Population = $response[1][0].value
                }
            }
            Start-Sleep -Milliseconds 200
        }
        catch {
            # Continue
        }
    }
    
    if ($yearData.Count -ge 8) {  # At least 8 ASEAN countries
        $sorted = $yearData | Sort-Object Population -Descending
        $vnRank = 0
        for ($i = 0; $i -lt $sorted.Count; $i++) {
            if ($sorted[$i].Code -eq 'VNM') {
                $vnRank = $i + 1
                break
            }
        }
        
        if ($vnRank -gt 0) {
            Write-Host "    ✓ Year $year`: ASEAN Rank #$vnRank" -ForegroundColor Green
            Write-Host "      Top 5: " -NoNewline -ForegroundColor Gray
            for ($i = 0; $i -lt [math]::Min(5, $sorted.Count); $i++) {
                Write-Host "$($sorted[$i].Country) " -NoNewline -ForegroundColor Cyan
            }
            Write-Host ""
            
            $aseanRankData += [PSCustomObject]@{
                Year = $year
                Rank = $vnRank
                TotalCountries = $yearData.Count
            }
        }
    }
}

if ($aseanRankData.Count -gt 0) {
    $aseanRankData | ConvertTo-Json | Out-File "vietnam_asean_ranks.json" -Encoding UTF8
}

# Calculate Regional Fertility Rate
Write-Host "`n4. Calculating Regional (ASEAN) Fertility Rates..." -ForegroundColor Yellow
$fertilityData = @()

foreach ($year in @(2024, 2023, 2022, 2021, 2020)) {
    Write-Host "  Processing fertility for year $year..." -ForegroundColor Gray
    $yearFertility = @()
    
    foreach ($code in $aseanCountries.Keys) {
        try {
            $url = "https://api.worldbank.org/v2/country/$code/indicator/SP.DYN.TFRT.IN?format=json&date=$year"
            $response = Invoke-RestMethod -Uri $url -Method Get
            
            if ($response.Count -gt 1 -and $response[1] -and $response[1][0].value) {
                $yearFertility += [PSCustomObject]@{
                    Country = $aseanCountries[$code]
                    Rate = $response[1][0].value
                }
            }
            Start-Sleep -Milliseconds 200
        }
        catch {
            # Continue
        }
    }
    
    if ($yearFertility.Count -gt 0) {
        $avg = [math]::Round(($yearFertility.Rate | Measure-Object -Average).Average, 3)
        Write-Host "    ✓ Year $year`: Avg = $avg (from $($yearFertility.Count) countries)" -ForegroundColor Green
        $fertilityData += [PSCustomObject]@{
            Year = $year
            Average = $avg
            Countries = $yearFertility.Count
        }
    }
}

if ($fertilityData.Count -gt 0) {
    $fertilityData | ConvertTo-Json | Out-File "asean_fertility_rates.json" -Encoding UTF8
}

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "✓ Global Rankings: $($rankData.Count) years calculated" -ForegroundColor Green
Write-Host "✓ ASEAN Rankings: $($aseanRankData.Count) years calculated" -ForegroundColor Green
Write-Host "✓ Regional Fertility: $($fertilityData.Count) years calculated" -ForegroundColor Green
if ($co2Found) {
    Write-Host "✓ CO2 Emissions: Data retrieved" -ForegroundColor Green
} else {
    Write-Host "⚠ CO2 Emissions: Needs alternative source" -ForegroundColor Yellow
}
