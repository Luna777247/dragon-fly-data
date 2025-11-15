# Try specific indicators with detailed error checking
Write-Host "=== Downloading Specific Missing Indicators ===" -ForegroundColor Cyan

function Get-WBIndicator {
    param($Name, $Code, $CountryCode = "VNM")
    
    Write-Host "`n$Name [$Code]..." -ForegroundColor Yellow
    try {
        $url = "https://api.worldbank.org/v2/country/$CountryCode/indicator/$Code?format=json&per_page=1000&date=1960:2024"
        $response = Invoke-RestMethod -Uri $url -Method Get -ErrorAction Stop
        
        if ($response -and $response.Count -gt 1) {
            if ($response[1].value) {
                $data = $response[1].value | Where-Object { $null -ne $_.value }
                if ($data) {
                    $latest = $data | Select-Object -First 1
                    Write-Host "  ✓ Latest: $($latest.date) = $($latest.value)" -ForegroundColor Green
                    $response | ConvertTo-Json -Depth 10 | Out-File "wb_$($Code.Replace('.','_')).json" -Encoding UTF8
                    return $true
                }
            }
        }
        Write-Host "  ✗ No data available" -ForegroundColor Red
        return $false
    }
    catch {
        Write-Host "  ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# CO2 Emissions
Get-WBIndicator "CO2 Emissions per Capita (metric tons)" "EN.ATM.CO2E.PC"

# Population Growth
Get-WBIndicator "Population Growth Rate (%)" "SP.POP.GROW"

# Median Age  
Get-WBIndicator "Median Age" "SP.POP.AG00.MA.IN"

# Net Migration
Get-WBIndicator "Net Migration" "SM.POP.NETM"

# Infant Mortality (per 1000 births)
Get-WBIndicator "Infant Mortality Rate (per 1000)" "SP.DYN.IMRT.IN"

# World indicators
Write-Host "`n=== World-Level Indicators ===" -ForegroundColor Cyan
Get-WBIndicator "World Population" "SP.POP.TOTL" "WLD"
Get-WBIndicator "World Urban Population %" "SP.URB.TOTL.IN.ZS" "WLD"

Write-Host "`n=== Download Complete ===" -ForegroundColor Green
