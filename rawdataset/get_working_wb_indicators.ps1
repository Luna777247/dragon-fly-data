# Get specific working World Bank indicators for Vietnam
Write-Host "Getting specific World Bank indicators with known data..." -ForegroundColor Green

# Known working indicators for Vietnam
$workingIndicators = @(
    @{Name="GDP_PPP_per_Capita"; Code="NY.GDP.PCAP.PP.CD"; Description="GDP PPP per Capita"},
    @{Name="Life_Expectancy"; Code="SP.DYN.LE00.IN"; Description="Life Expectancy"},
    @{Name="Literacy_Rate"; Code="SE.ADT.LITR.ZS"; Description="Literacy Rate"},
    @{Name="Health_Expenditure"; Code="SH.XPD.CHEX.GD.ZS"; Description="Health Expenditure % GDP"},
    @{Name="Access_Electricity"; Code="EG.ELC.ACCS.ZS"; Description="Access to Electricity"},
    @{Name="Renewable_Energy"; Code="EG.FEC.RNEW.ZS"; Description="Renewable Energy Consumption"},
    @{Name="CO2_Emissions"; Code="EN.ATM.CO2E.PC"; Description="CO2 Emissions per Capita"},
    @{Name="Forest_Area"; Code="AG.LND.FRST.ZS"; Description="Forest Area %"},
    @{Name="Agricultural_Land"; Code="AG.LND.AGRI.ZS"; Description="Agricultural Land %"}
)

foreach ($indicator in $workingIndicators) {
    $code = $indicator.Code
    $name = $indicator.Name
    $description = $indicator.Description

    Write-Host "Downloading ${description}..." -ForegroundColor Yellow

    try {
        $url = "https://api.worldbank.org/v2/country/VNM/indicator/$code?format=json&per_page=1000"
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing
        $jsonData = $response.Content | ConvertFrom-Json

        if ($jsonData -and $jsonData.Count -gt 1) {
            $vietnamData = $jsonData[1] | Where-Object { $_.countryiso3code -eq 'VNM' -and $null -ne $_.value } | Sort-Object date -Descending
            $latest = $vietnamData | Select-Object -First 1

            if ($latest) {
                Write-Host "  ✓ ${description}: $($latest.date) = $($latest.value)" -ForegroundColor Green
                $jsonData | ConvertTo-Json -Depth 10 | Out-File "wb_${name}.json" -Encoding UTF8
            } else {
                Write-Host "  ✗ No data for ${description}" -ForegroundColor Red
            }
        } else {
            Write-Host "  ✗ No response for ${description}" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "  ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Summary of downloaded indicators:" -ForegroundColor Cyan
Get-ChildItem "wb_*.json" | ForEach-Object {
    $name = $_.Name -replace 'wb_', '' -replace '.json', ''
    Write-Host "  • $name"
}