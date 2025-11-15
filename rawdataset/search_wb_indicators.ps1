# Search for correct World Bank indicator codes for Vietnam
Write-Host "Searching for available World Bank indicators for Vietnam..." -ForegroundColor Green

# Try different indicator codes for key metrics
$indicatorAttempts = @(
    @{Name="Unemployment_Rate"; Codes=@("SL.UEM.TOTL.ZS", "SL.UEM.TOTL.NE.ZS", "SL.UEM.1524.ZS"); Description="Unemployment Rate"},
    @{Name="Poverty_Headcount"; Codes=@("SI.POV.NAHC", "SI.POV.DDAY", "SI.POV.GINI"); Description="Poverty Rate"},
    @{Name="Human_Capital"; Codes=@("HD.HCI.OVRL", "HD.HCI.OVRL.FE", "HD.HCI.OVRL.MA"); Description="Human Capital Index"},
    @{Name="FDI_Inflows"; Codes=@("BX.KLT.DINV.WD.GD.ZS", "BX.KLT.DINV.CD.WD", "BX.KLT.DREM.CD.DT"); Description="FDI Net Inflows"},
    @{Name="GDP_PPP"; Codes=@("NY.GDP.PCAP.PP.CD", "NY.GDP.PCAP.PP.KD"); Description="GDP PPP per Capita"}
)

foreach ($attempt in $indicatorAttempts) {
    $name = $attempt.Name
    $description = $attempt.Description
    $found = $false

    Write-Host "Searching for ${description}..." -ForegroundColor Yellow

    foreach ($code in $attempt.Codes) {
        try {
            $url = "https://api.worldbank.org/v2/country/VNM/indicator/$code?format=json&per_page=1000"
            $response = Invoke-WebRequest -Uri $url -UseBasicParsing
            $jsonData = $response.Content | ConvertFrom-Json

            if ($jsonData -and $jsonData.Count -gt 1 -and $jsonData[1]) {
                $vietnamData = $jsonData[1] | Where-Object { $_.countryiso3code -eq 'VNM' -and $null -ne $_.value }
                if ($vietnamData.Count -gt 0) {
                    $latest = $vietnamData | Sort-Object date -Descending | Select-Object -First 1
                    Write-Host "  ✓ Found ${description} with code $code - Latest: $($latest.date) = $($latest.value)" -ForegroundColor Green

                    # Save the data
                    $jsonData | ConvertTo-Json -Depth 10 | Out-File "wb_${name}_$code.json" -Encoding UTF8
                    $found = $true
                    break
                }
            }
        }
        catch {
            # Continue to next code
        }
    }

    if (-not $found) {
        Write-Host "  ✗ No data found for ${description}" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Searching for additional indicators..." -ForegroundColor Cyan

# Try some other important indicators
$additionalIndicators = @(
    "SP.DYN.LE00.IN",  # Life expectancy
    "SE.ADT.LITR.ZS", # Literacy rate
    "SH.XPD.CHEX.GD.ZS", # Health expenditure
    "EG.ELC.ACCS.ZS", # Access to electricity
    "EG.FEC.RNEW.ZS", # Renewable energy consumption
    "EN.ATM.CO2E.PC", # CO2 emissions per capita
    "ER.H2O.FWTL.ZS", # Annual freshwater withdrawals
    "AG.LND.FRST.ZS", # Forest area
    "AG.LND.AGRI.ZS"  # Agricultural land
)

foreach ($code in $additionalIndicators) {
    try {
        $url = "https://api.worldbank.org/v2/country/VNM/indicator/$code?format=json&per_page=1000"
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing
        $jsonData = $response.Content | ConvertFrom-Json

        if ($jsonData -and $jsonData.Count -gt 1 -and $jsonData[1]) {
            $vietnamData = $jsonData[1] | Where-Object { $_.countryiso3code -eq 'VNM' -and $null -ne $_.value }
            if ($vietnamData.Count -gt 0) {
                $latest = $vietnamData | Sort-Object date -Descending | Select-Object -First 1
                Write-Host "✓ $code - Latest: $($latest.date) = $($latest.value)" -ForegroundColor Green
                $jsonData | ConvertTo-Json -Depth 10 | Out-File "wb_$code.json" -Encoding UTF8
            }
        }
    }
    catch {
        # Continue
    }
}