# Try World Bank API with different approach - test individual indicators
Write-Host "Testing World Bank API with specific indicator codes..." -ForegroundColor Green
Write-Host ""

$testCodes = @(
    "SP.DYN.TFRT.IN",  # Fertility rate
    "SP.DYN.CBRT.IN",  # Birth rate
    "SP.DYN.CDRT.IN",  # Death rate
    "SP.RUR.TOTL",     # Rural population
    "SP.URB.TOTL",     # Urban population
    "EN.POP.DNST",     # Population density
    "SP.POP.0014.TO.ZS", # Pop 0-14
    "SP.POP.1564.TO.ZS", # Pop 15-64
    "SP.POP.65UP.TO.ZS", # Pop 65+
    "SP.POP.DPND",     # Dependency ratio
    "EN.ATM.CO2E.PC"   # CO2 per capita
)

foreach ($code in $testCodes) {
    Write-Host "Testing $code..." -ForegroundColor Yellow
    
    try {
        $url = "https://api.worldbank.org/v2/country/VNM/indicator/$code`?format=json&per_page=10"
        $response = Invoke-RestMethod -Uri $url -Method Get
        
        if ($response -and $response.Count -gt 1) {
            $data = $response[1]
            if ($data) {
                $recent = $data | Where-Object { $null -ne $_.value } | Select-Object -First 3
                if ($recent) {
                    Write-Host "  ✓ Data available!" -ForegroundColor Green
                    $recent | ForEach-Object {
                        Write-Host "    $($_.date): $($_.value)"
                    }
                } else {
                    Write-Host "  ✗ No values available" -ForegroundColor Red
                }
            }
        } else {
            Write-Host "  ✗ No response data" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "  ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Write-Host ""
}