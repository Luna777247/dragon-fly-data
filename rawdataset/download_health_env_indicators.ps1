# Download health and environmental indicators from World Bank API
$indicators = @(
    @{id="SH.XPD.CHEX.GD.ZS"; name="health_expenditure"},
    @{id="EN.ATM.CO2E.PC"; name="co2_emissions"},
    @{id="EG.FEC.RNEW.ZS"; name="renewable_energy"}
)

foreach ($indicator in $indicators) {
    $url = "https://api.worldbank.org/v2/country/VNM/indicator/$($indicator.id)?format=json&per_page=1000"
    $outputFile = "wb_$($indicator.name).json"

    Write-Host "Downloading $($indicator.name) data..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $url -OutFile $outputFile -UseBasicParsing
        Write-Host "✓ Downloaded $($indicator.name) data" -ForegroundColor Green
    } catch {
        Write-Host "✗ Failed to download $($indicator.name) data: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "Health and environmental indicators download completed!" -ForegroundColor Green