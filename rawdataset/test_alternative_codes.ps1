# Try alternative indicator codes based on World Bank documentation
Write-Host "=== Trying Alternative Indicator Codes ===" -ForegroundColor Cyan

function Test-Indicator {
    param($Name, $Codes)
    
    Write-Host "`n$Name :" -ForegroundColor Yellow
    foreach ($code in $Codes) {
        try {
            $url = "https://api.worldbank.org/v2/country/VNM/indicator/$code?format=json&per_page=50&date=2020:2024"
            $response = Invoke-RestMethod -Uri $url -Method Get -ErrorAction Stop
            
            if ($response.Count -gt 1 -and $response[1].value) {
                $data = $response[1].value | Where-Object { $null -ne $_.value } | Select-Object -First 1
                if ($data) {
                    Write-Host "  ✓ $code : $($data.date) = $($data.value)" -ForegroundColor Green
                    
                    # Download full dataset
                    $fullUrl = "https://api.worldbank.org/v2/country/VNM/indicator/$code?format=json&per_page=1000&date=1960:2024"
                    $fullData = Invoke-RestMethod -Uri $fullUrl -Method Get
                    $fullData | ConvertTo-Json -Depth 10 | Out-File "wb_$($code.Replace('.','_')).json" -Encoding UTF8
                    return $code
                }
            }
        }
        catch {
            # Silently continue to next code
        }
    }
    Write-Host "  ✗ No working code found" -ForegroundColor Red
    return $null
}

# Test different codes for each indicator
Test-Indicator "CO2 Emissions" @("EN.ATM.CO2E.PC", "EN.CO2.ETOT.MT", "EN.CO2.MANF.ZS")
Test-Indicator "Population Growth" @("SP.POP.GROW", "SP.POP.DPND", "AG.LND.TOTL.K2")  
Test-Indicator "Median Age" @("SP.POP.AG00.MA", "SP.POP.AG00.FE", "SP.POP.1564.TO")
Test-Indicator "Household Size" @("SP.HOU.FEMA", "SP.HOU.ALLW", "SP.DYN.LE00.FE.IN")

Write-Host "`n=== Testing World Population Codes ===" -ForegroundColor Cyan
function Test-WorldIndicator {
    param($Name, $Codes)
    
    Write-Host "`n$Name (World):" -ForegroundColor Yellow
    foreach ($code in $Codes) {
        try {
            $url = "https://api.worldbank.org/v2/country/WLD/indicator/$code?format=json&per_page=50&date=2020:2024"
            $response = Invoke-RestMethod -Uri $url -Method Get -ErrorAction Stop
            
            if ($response.Count -gt 1 -and $response[1].value) {
                $data = $response[1].value | Where-Object { $null -ne $_.value } | Select-Object -First 1
                if ($data) {
                    Write-Host "  ✓ $code : $($data.date) = $($data.value)" -ForegroundColor Green
                    
                    # Download full dataset
                    $fullUrl = "https://api.worldbank.org/v2/country/WLD/indicator/$code?format=json&per_page=1000&date=1960:2024"
                    $fullData = Invoke-RestMethod -Uri $fullUrl -Method Get
                    $fullData | ConvertTo-Json -Depth 10 | Out-File "wb_world_$($code.Replace('.','_')).json" -Encoding UTF8
                    return $code
                }
            }
        }
        catch {
            # Silently continue
        }
    }
    Write-Host "  ✗ No working code found" -ForegroundColor Red
}

Test-WorldIndicator "World Population" @("SP.POP.TOTL", "SP.POP.GROW", "AG.LND.TOTL.K2")
Test-WorldIndicator "World Urbanization" @("SP.URB.TOTL.IN.ZS", "SP.URB.GROW", "SP.RUR.TOTL.ZS")

Write-Host "`n=== Complete ===" -ForegroundColor Green
