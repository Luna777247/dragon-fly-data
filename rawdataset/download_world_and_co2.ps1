# Download world-level reference data and additional indicators
Write-Host "=== Downloading World Reference Data ===" -ForegroundColor Cyan

function Get-WorldData {
    param($Name, $Code)
    
    Write-Host "`n$Name [$Code]..." -ForegroundColor Yellow
    try {
        # Try with WLD (World) country code
        $url = "https://api.worldbank.org/v2/country/WLD/indicator/$Code?format=json&per_page=1000&date=1960:2024"
        $response = Invoke-RestMethod -Uri $url -Method Get -ErrorAction Stop
        
        if ($response -and $response.Count -gt 1) {
            if ($response[1].value) {
                $data = $response[1].value | Where-Object { $null -ne $_.value } | Sort-Object date -Descending
                if ($data) {
                    $latest = $data | Select-Object -First 1
                    Write-Host "  ✓ Latest: $($latest.date) = $($latest.value)" -ForegroundColor Green
                    $response | ConvertTo-Json -Depth 10 | Out-File "wb_world_$($Code.Replace('.','_')).json" -Encoding UTF8
                    return $true
                }
            }
        }
        Write-Host "  ✗ No data" -ForegroundColor Red
        return $false
    }
    catch {
        Write-Host "  ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# World population
Get-WorldData "World Population" "SP.POP.TOTL"

# World urbanization
Get-WorldData "World Urban Population %" "SP.URB.TOTL.IN.ZS"

# Try CO2 with different approach
Write-Host "`n=== Trying CO2 Emissions ===" -ForegroundColor Cyan
$co2Codes = @("EN.ATM.CO2E.PC", "EN.ATM.CO2E.KT", "EN.CO2.TRAN.ZS", "EN.ATM.CO2E.PP.GD")

foreach ($code in $co2Codes) {
    Write-Host "`nTrying CO2 code: $code..." -ForegroundColor Yellow
    try {
        $url = "https://api.worldbank.org/v2/country/VNM/indicator/$code?format=json&per_page=100&date=2015:2024"
        $response = Invoke-RestMethod -Uri $url -Method Get -ErrorAction Stop
        
        if ($response -and $response.Count -gt 1) {
            if ($response[1].value) {
                $data = $response[1].value | Where-Object { $null -ne $_.value }
                if ($data) {
                    Write-Host "  ✓ FOUND! Code: $code" -ForegroundColor Green
                    $data | Select-Object -First 3 | ForEach-Object {
                        Write-Host "    $($_.date): $($_.value)"
                    }
                    
                    # Download full dataset
                    $fullUrl = "https://api.worldbank.org/v2/country/VNM/indicator/$code?format=json&per_page=1000&date=1960:2024"
                    $fullData = Invoke-RestMethod -Uri $fullUrl -Method Get
                    $fullData | ConvertTo-Json -Depth 10 | Out-File "wb_$($code.Replace('.','_')).json" -Encoding UTF8
                    break
                }
            }
        }
    }
    catch {
        # Continue to next code
    }
}

# Try getting ASEAN median age and fertility (regional comparison)
Write-Host "`n=== Trying Regional Data (ASEAN) ===" -ForegroundColor Cyan
$aseanCountries = @("THA", "MYS", "PHL", "IDN", "SGP")  # Sample ASEAN countries

Write-Host "`nFertility rates for ASEAN countries (2022):" -ForegroundColor Yellow
$aseanFertility = @()
foreach ($country in $aseanCountries) {
    try {
        $url = "https://api.worldbank.org/v2/country/$country/indicator/SP.DYN.TFRT.IN?format=json&per_page=10&date=2022:2022"
        $response = Invoke-RestMethod -Uri $url -Method Get -ErrorAction Stop
        if ($response -and $response.Count -gt 1) {
            if ($response[1].value) {
                $value = $response[1].value[0].value
                if ($value) {
                    Write-Host "  $country : $value" -ForegroundColor White
                    $aseanFertility += $value
                }
            }
        }
    }
    catch {
        # Skip country
    }
}

if ($aseanFertility.Count -gt 0) {
    $avgFertility = [math]::Round(($aseanFertility | Measure-Object -Average).Average, 2)
    Write-Host "`n  Average ASEAN Fertility: $avgFertility" -ForegroundColor Green
}

Write-Host "`n=== Download Complete ===" -ForegroundColor Green
