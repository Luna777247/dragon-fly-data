# Search for remaining verifiable indicators in World Bank
Write-Host "=== Searching for Remaining Indicators ===" -ForegroundColor Cyan

$indicators = @(
    # CO2 Emissions
    @{Name="CO2 Emissions per Capita"; Code="EN.ATM.CO2E.PC"},
    
    # Median Age
    @{Name="Median Age"; Code="SP.POP.AG00.MA.IN"},
    
    # Deaths and Births (absolute numbers)
    @{Name="Deaths Total"; Code="SP.DYN.DTHS.IN"},
    @{Name="Births Total"; Code="SP.DYN.BIRTH.IN"},
    
    # UNDP HDR components (if available separately)
    @{Name="HDI Value"; Code="UNDP.HDI.XD"},
    @{Name="Life Expectancy at Birth (UNDP)"; Code="SP.DYN.LE00.IN"},
    
    # Housing
    @{Name="Household Size"; Code="SP.HOU.SIZE"},
    
    # EPI Score (not likely in WB but try)
    @{Name="EPI Environmental Performance"; Code="EN.EPI.OVRL"},
    
    # World Population
    @{Name="World Population Total"; Code="SP.POP.TOTL"},
    
    # Migration Rate
    @{Name="Net Migration Rate"; Code="SM.POP.NETM"},
    
    # Additional demographic
    @{Name="Infant Mortality Rate per 1000"; Code="SP.DYN.IMRT.IN"},
    @{Name="Population Growth Rate"; Code="SP.POP.GROW"},
    
    # Income/Inequality components
    @{Name="Income Index"; Code="SI.DST.05TH.20"},
    
    # Regional fertility (ASEAN average)
    @{Name="Fertility Rate ASEAN"; Code="SP.DYN.TFRT.IN"},
    
    # Urbanization rate (world)
    @{Name="Urban Population World"; Code="SP.URB.TOTL"},
    
    # Climate Risk (not in WB)
    @{Name="Climate Risk Index"; Code="EN.CLC.RISK"}
)

foreach ($ind in $indicators) {
    Write-Host "`nSearching: $($ind.Name) [$($ind.Code)]..." -ForegroundColor Yellow
    try {
        # For Vietnam-specific indicators
        $url = "https://api.worldbank.org/v2/country/VNM/indicator/$($ind.Code)?format=json&per_page=1000&date=1960:2024"
        $response = Invoke-RestMethod -Uri $url -Method Get
        
        if ($response.Count -gt 1 -and $response[1].value) {
            $data = $response[1].value | Where-Object { $null -ne $_.value } | Sort-Object date -Descending
            if ($data) {
                $latest = $data | Select-Object -First 1
                Write-Host "  ✓ FOUND: Latest $($latest.date) = $($latest.value)" -ForegroundColor Green
                $response | ConvertTo-Json -Depth 10 | Out-File "wb_$($ind.Code.Replace('.','_')).json" -Encoding UTF8
            }
        } else {
            Write-Host "  ✗ No data available" -ForegroundColor Red
        }
    } catch {
        Write-Host "  ✗ API Error" -ForegroundColor Red
    }
    Start-Sleep -Milliseconds 300
}

# Try world-level indicators
Write-Host "`n=== Checking World-Level Indicators ===" -ForegroundColor Cyan
$worldIndicators = @(
    @{Name="World Population"; Code="SP.POP.TOTL"; Country="WLD"},
    @{Name="World Urbanization Rate"; Code="SP.URB.TOTL.IN.ZS"; Country="WLD"},
    @{Name="Global Median Age"; Code="SP.POP.AG00.MA.IN"; Country="WLD"}
)

foreach ($ind in $worldIndicators) {
    Write-Host "`nSearching: $($ind.Name)..." -ForegroundColor Yellow
    try {
        $url = "https://api.worldbank.org/v2/country/$($ind.Country)/indicator/$($ind.Code)?format=json&per_page=1000&date=1960:2024"
        $response = Invoke-RestMethod -Uri $url -Method Get
        
        if ($response.Count -gt 1 -and $response[1].value) {
            $data = $response[1].value | Where-Object { $null -ne $_.value } | Sort-Object date -Descending
            if ($data) {
                $latest = $data | Select-Object -First 1
                Write-Host "  ✓ FOUND: Latest $($latest.date) = $($latest.value)" -ForegroundColor Green
                $response | ConvertTo-Json -Depth 10 | Out-File "wb_world_$($ind.Code.Replace('.','_')).json" -Encoding UTF8
            }
        }
    } catch {
        Write-Host "  ✗ API Error" -ForegroundColor Red
    }
    Start-Sleep -Milliseconds 300
}

Write-Host "`n=== Search Complete ===" -ForegroundColor Green
