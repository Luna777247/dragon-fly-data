# Download ILO Industry and Services Employment data from World Bank API
$indicators = @(
    @{id="SL.IND.EMPL.ZS"; name="industry_employment"},
    @{id="SL.SRV.EMPL.ZS"; name="services_employment"}
)

foreach ($indicator in $indicators) {
    $url = "https://api.worldbank.org/v2/country/VNM/indicator/$($indicator.id)?format=json&per_page=1000"
    $outputFile = "wb_ilo_$($indicator.name).json"

    Write-Host "Downloading $($indicator.name) data..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $url -OutFile $outputFile -UseBasicParsing
        Write-Host "✓ Downloaded $($indicator.name) data" -ForegroundColor Green
    } catch {
        Write-Host "✗ Failed to download $($indicator.name) data: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "ILO employment data download completed!" -ForegroundColor Green