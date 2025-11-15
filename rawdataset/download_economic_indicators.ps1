# Download remaining economic indicators from World Bank API
$indicators = @(
    @{id="NY.GDP.PCAP.CD"; name="gdp_per_capita"},
    @{id="NY.GDP.MKTP.KD.ZG"; name="gdp_growth"},
    @{id="NY.GDP.MKTP.CD"; name="gdp_total"},
    @{id="FP.CPI.TOTL.ZG"; name="inflation"},
    @{id="NE.IMP.GNFS.ZS"; name="imports_gdp"},
    @{id="NE.EXP.GNFS.ZS"; name="exports_gdp"}
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

Write-Host "Economic indicators download completed!" -ForegroundColor Green