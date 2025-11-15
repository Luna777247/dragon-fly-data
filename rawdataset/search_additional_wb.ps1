# Try to find more World Bank indicators
Write-Host "Searching for additional World Bank indicators..." -ForegroundColor Green

$additionalCodes = @(
    @{Name="sex_ratio"; Codes=@("SP.POP.BRTH.MF", "SP.POP.TOTL.FE.ZS"); Description="Sex Ratio"},
    @{Name="life_exp_male"; Codes=@("SP.DYN.LE00.MA.IN"); Description="Life Expectancy Male"},
    @{Name="life_exp_female"; Codes=@("SP.DYN.LE00.FE.IN"); Description="Life Expectancy Female"},
    @{Name="median_age"; Codes=@("SP.POP.AG00.MA.IN", "SP.POP.AG25.MA.IN"); Description="Median Age"},
    @{Name="urban_growth"; Codes=@("SP.URB.GROW"); Description="Urban Growth Rate"},
    @{Name="land_area"; Codes=@("AG.LND.TOTL.K2"); Description="Land Area"},
    @{Name="births"; Codes=@("SP.DYN.CBRT.IN"); Description="Birth Rate"},
    @{Name="deaths"; Codes=@("SP.DYN.CDRT.IN"); Description="Death Rate"},
    @{Name="urbanization"; Codes=@("SP.URB.TOTL.IN.ZS"); Description="Urbanization Ratio"}
)

$foundCount = 0

foreach ($attempt in $additionalCodes) {
    $name = $attempt.Name
    $description = $attempt.Description
    $found = $false

    Write-Host "Searching for ${description}..." -ForegroundColor Yellow

    foreach ($code in $attempt.Codes) {
        try {
            $url = "https://api.worldbank.org/v2/country/VNM/indicator/$code`?format=json&per_page=1000&date=1960:2024"
            $response = Invoke-RestMethod -Uri $url -Method Get

            if ($response -and $response.Count -gt 1 -and $response[1]) {
                $vietnamData = $response[1] | Where-Object { $_.countryiso3code -eq 'VNM' -and $null -ne $_.value }
                
                if ($vietnamData.Count -gt 0) {
                    $latest = $vietnamData | Sort-Object date -Descending | Select-Object -First 1
                    Write-Host "  ✓ Found ($code) - Latest: $($latest.date) = $($latest.value)" -ForegroundColor Green
                    
                    $response | ConvertTo-Json -Depth 10 | Out-File "wb_${name}.json" -Encoding UTF8
                    $foundCount++
                    $found = $true
                    break
                }
            }
        }
        catch {
            # Continue
        }
    }

    if (-not $found) {
        Write-Host "  ✗ Not found" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Found $foundCount new indicators" -ForegroundColor Cyan