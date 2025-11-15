# Download all available demographic and population indicators
Write-Host "Downloading demographic and population indicators..." -ForegroundColor Green

$indicators = @(
    @{Name="fertility_rate"; Code="SP.DYN.TFRT.IN"; Description="Fertility Rate"},
    @{Name="birth_rate"; Code="SP.DYN.CBRT.IN"; Description="Birth Rate"},
    @{Name="death_rate"; Code="SP.DYN.CDRT.IN"; Description="Death Rate"},
    @{Name="rural_population"; Code="SP.RUR.TOTL"; Description="Rural Population"},
    @{Name="urban_population"; Code="SP.URB.TOTL"; Description="Urban Population"},
    @{Name="population_density"; Code="EN.POP.DNST"; Description="Population Density"},
    @{Name="pop_0_14"; Code="SP.POP.0014.TO.ZS"; Description="Population ages 0-14 (%)"},
    @{Name="pop_15_64"; Code="SP.POP.1564.TO.ZS"; Description="Population ages 15-64 (%)"},
    @{Name="pop_65plus"; Code="SP.POP.65UP.TO.ZS"; Description="Population ages 65+ (%)"},
    @{Name="dependency_ratio"; Code="SP.POP.DPND"; Description="Age Dependency Ratio"}
)

$successCount = 0
$failCount = 0

foreach ($indicator in $indicators) {
    $name = $indicator.Name
    $code = $indicator.Code
    $description = $indicator.Description

    Write-Host "Downloading ${description} ($code)..." -ForegroundColor Yellow

    try {
        $url = "https://api.worldbank.org/v2/country/VNM/indicator/$code`?format=json&per_page=1000&date=1960:2024"
        $response = Invoke-RestMethod -Uri $url -Method Get

        if ($response -and $response.Count -gt 1 -and $response[1]) {
            $vietnamData = $response[1] | Where-Object { $_.countryiso3code -eq 'VNM' -and $null -ne $_.value }
            
            if ($vietnamData.Count -gt 0) {
                $latest = $vietnamData | Sort-Object date -Descending | Select-Object -First 1
                Write-Host "  ✓ Downloaded - Latest: $($latest.date) = $($latest.value)" -ForegroundColor Green
                
                $response | ConvertTo-Json -Depth 10 | Out-File "wb_${name}.json" -Encoding UTF8
                $successCount++
            } else {
                Write-Host "  ✗ No data available" -ForegroundColor Red
                $failCount++
            }
        }
    }
    catch {
        Write-Host "  ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
        $failCount++
    }
}

Write-Host ""
Write-Host "Download Summary:" -ForegroundColor Cyan
Write-Host "  Success: $successCount"
Write-Host "  Failed: $failCount"
Write-Host ""
Write-Host "Files created:" -ForegroundColor Yellow
Get-ChildItem "wb_*.json" | Where-Object { $_.LastWriteTime -gt (Get-Date).AddMinutes(-5) } | ForEach-Object {
    Write-Host "  • $($_.Name)"
}