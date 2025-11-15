# Download UNDP Human Development Report data for Vietnam
Write-Host "Searching for additional World Bank indicators..." -ForegroundColor Green

# Try to find Human Capital Index, Fertility Rate, and other missing indicators
$searchIndicators = @(
    @{Name="Human_Capital_Index"; Codes=@("HD.HCI.OVRL", "HD.HCI.LAYS"); Description="Human Capital Index"},
    @{Name="Fertility_Rate"; Codes=@("SP.DYN.TFRT.IN"); Description="Fertility Rate"},
    @{Name="Birth_Rate"; Codes=@("SP.DYN.CBRT.IN"); Description="Birth Rate"},
    @{Name="Death_Rate"; Codes=@("SP.DYN.CDRT.IN"); Description="Death Rate"},
    @{Name="Rural_Population"; Codes=@("SP.RUR.TOTL"); Description="Rural Population"},
    @{Name="Urban_Population"; Codes=@("SP.URB.TOTL"); Description="Urban Population"},
    @{Name="Population_Density"; Codes=@("EN.POP.DNST"); Description="Population Density"},
    @{Name="Sex_Ratio"; Codes=@("SP.POP.BRTH.MF"); Description="Sex Ratio at Birth"},
    @{Name="Pop_0_14"; Codes=@("SP.POP.0014.TO.ZS"); Description="Population ages 0-14 (%)"},
    @{Name="Pop_15_64"; Codes=@("SP.POP.1564.TO.ZS"); Description="Population ages 15-64 (%)"},
    @{Name="Pop_65plus"; Codes=@("SP.POP.65UP.TO.ZS"); Description="Population ages 65+ (%)"},
    @{Name="Dependency_Ratio"; Codes=@("SP.POP.DPND"); Description="Age Dependency Ratio"},
    @{Name="Urban_Growth"; Codes=@("SP.URB.GROW"); Description="Urban Population Growth"},
    @{Name="Mean_Schooling"; Codes=@("HD.HCI.EYRS"); Description="Mean Years of Schooling"},
    @{Name="Expected_Schooling"; Codes=@("SE.SCH.LIFE"); Description="Expected Years of Schooling"},
    @{Name="CO2_Per_Capita"; Codes=@("EN.ATM.CO2E.PC"); Description="CO2 Emissions per Capita"}
)

$foundIndicators = @()

foreach ($attempt in $searchIndicators) {
    $name = $attempt.Name
    $description = $attempt.Description
    $found = $false

    Write-Host "Searching for ${description}..." -ForegroundColor Yellow

    foreach ($code in $attempt.Codes) {
        try {
            $url = "https://api.worldbank.org/v2/country/VNM/indicator/$code?format=json&per_page=1000&date=2000:2024"
            $response = Invoke-WebRequest -Uri $url -UseBasicParsing
            $jsonData = $response.Content | ConvertFrom-Json

            if ($jsonData -and $jsonData.Count -gt 1 -and $jsonData[1]) {
                $vietnamData = $jsonData[1] | Where-Object { $_.countryiso3code -eq 'VNM' -and $null -ne $_.value }
                if ($vietnamData.Count -gt 0) {
                    $latest = $vietnamData | Sort-Object date -Descending | Select-Object -First 1
                    Write-Host "  ✓ Found ${description} ($code)" -ForegroundColor Green
                    Write-Host "    Latest: $($latest.date) = $($latest.value)" -ForegroundColor Cyan

                    # Save the data
                    $jsonData | ConvertTo-Json -Depth 10 | Out-File "wb_${name}.json" -Encoding UTF8
                    $foundIndicators += @{Name=$name; Code=$code; Description=$description}
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
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "Found $($foundIndicators.Count) indicators with data"
$foundIndicators | ForEach-Object {
    Write-Host "  • $($_.Description) ($($_.Code))"
}