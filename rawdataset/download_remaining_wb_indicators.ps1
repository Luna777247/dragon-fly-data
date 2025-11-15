# Download Remaining World Bank Indicators for Vietnam
Write-Host "Downloading remaining World Bank indicators for Vietnam..." -ForegroundColor Green

# Define indicators to download
$indicators = @(
    @{Name="Unemployment_Rate"; Code="SL.UEM.TOTL.ZS"; Description="Unemployment Rate (%)"},
    @{Name="Poverty_Rate"; Code="SI.POV.NAHC"; Description="Poverty Rate (% of population)"},
    @{Name="Human_Capital_Index"; Code="HD.HCI.OVRL"; Description="Human Capital Index"},
    @{Name="FDI_Inflows"; Code="BX.KLT.DINV.WD.GD.ZS"; Description="FDI Net Inflows (% GDP)"},
    @{Name="GDP_PPP"; Code="NY.GDP.PCAP.PP.CD"; Description="GDP PPP per Capita (current international $)"}
)

foreach ($indicator in $indicators) {
    $code = $indicator.Code
    $name = $indicator.Name
    $description = $indicator.Description

    Write-Host "Downloading $description ($code)..." -ForegroundColor Yellow

    try {
        $url = "https://api.worldbank.org/v2/country/VNM/indicator/$code?format=json&per_page=1000"
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing
        $jsonData = $response.Content | ConvertFrom-Json

        if ($jsonData -and $jsonData.Count -gt 1) {
            $jsonData | ConvertTo-Json -Depth 10 | Out-File "wb_$name.json" -Encoding UTF8
            Write-Host "  ✓ Saved wb_$name.json" -ForegroundColor Green
        } else {
            Write-Host "  ✗ No data available for $description" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "  ✗ Error downloading $description : $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Download complete. Checking data availability..." -ForegroundColor Cyan

# Check latest data for each indicator
foreach ($indicator in $indicators) {
    $name = $indicator.Name
    $description = $indicator.Description
    $filePath = "wb_$name.json"

    if (Test-Path $filePath) {
        try {
            $data = Get-Content $filePath | ConvertFrom-Json
            $vietnamData = $data[1] | Where-Object { $_.countryiso3code -eq 'VNM' -and $null -ne $_.value } | Sort-Object date -Descending
            $latest = $vietnamData | Select-Object -First 1

            if ($latest) {
                Write-Host "${description} ($($latest.date)): $($latest.value)" -ForegroundColor Green
            } else {
                Write-Host "${description}: No data available" -ForegroundColor Red
            }
        }
        catch {
            Write-Host "${description}: Error reading data" -ForegroundColor Red
        }
    } else {
        Write-Host "${description}: File not found" -ForegroundColor Red
    }
}