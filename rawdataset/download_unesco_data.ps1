# Download UNESCO Education Indicators from World Bank API
Write-Host "Downloading UNESCO Education Indicators for Vietnam..." -ForegroundColor Green

# UNESCO Education Indicators (available through World Bank)
$unescoIndicators = @(
    @{Name="Mean_Years_of_Schooling"; Code="SE.SEC.CUAT.LO.ZS"; Description="Educational attainment, at least completed lower secondary, population 25+, total (%) (cumulative)"},
    @{Name="Expected_Years_of_Schooling"; Code="HD.HCI.OVRL"; Description="Human Capital Index (scale 0-1)"},  # This might be available
    @{Name="Education_Index"; Code="SE.ADT.LITR.ZS"; Description="Literacy rate, adult total (% of people ages 15 and above)"}
)

# Alternative indicators that might give us education data
$educationIndicators = @(
    @{Name="Mean_Years_Schooling"; Code="SE.SEC.CUAT.LO.ZS"; Description="Completed lower secondary education"},
    @{Name="Upper_Secondary_Completion"; Code="SE.SEC.CUAT.UP.ZS"; Description="Educational attainment, at least completed upper secondary, population 25+, total (%)"},
    @{Name="Tertiary_Education"; Code="SE.TER.CUAT.BA.ZS"; Description="Educational attainment, at least Bachelor's or equivalent, population 25+, total (%)"},
    @{Name="Youth_Literacy"; Code="SE.ADT.1524.LT.ZS"; Description="Literacy rate, youth total (% of people ages 15-24)"},
    @{Name="School_Enrollment_Primary"; Code="SE.PRM.ENRR"; Description="School enrollment, primary (% gross)"},
    @{Name="School_Enrollment_Secondary"; Code="SE.SEC.ENRR"; Description="School enrollment, secondary (% gross)"}
)

$allIndicators = $unescoIndicators + $educationIndicators

foreach ($indicator in $allIndicators) {
    $code = $indicator.Code
    $name = $indicator.Name
    $description = $indicator.Description

    Write-Host "Trying to download ${description} ($code)..." -ForegroundColor Yellow

    try {
        $url = "https://api.worldbank.org/v2/country/VNM/indicator/$code?format=json&per_page=1000"
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing
        $jsonData = $response.Content | ConvertFrom-Json

        if ($jsonData -and $jsonData.Count -gt 1) {
            $vietnamData = $jsonData[1] | Where-Object { $_.countryiso3code -eq 'VNM' -and $null -ne $_.value } | Sort-Object date -Descending
            $latest = $vietnamData | Select-Object -First 1

            if ($latest) {
                Write-Host "  ✓ Found data: $($latest.date) = $($latest.value)" -ForegroundColor Green
                $jsonData | ConvertTo-Json -Depth 10 | Out-File "wb_unesco_${name}.json" -Encoding UTF8
            } else {
                Write-Host "  ✗ No Vietnam data available" -ForegroundColor Red
            }
        } else {
            Write-Host "  ✗ No data returned from API" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "  ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Checking available UNESCO/education data..." -ForegroundColor Cyan

# Check what we have
$unescoFiles = Get-ChildItem "wb_unesco_*.json"
if ($unescoFiles.Count -gt 0) {
    Write-Host "Available UNESCO files:" -ForegroundColor Green
    foreach ($file in $unescoFiles) {
        $fileName = $file.Name -replace 'wb_unesco_', '' -replace '.json', ''
        Write-Host "  • $fileName"
    }
} else {
    Write-Host "No UNESCO files found" -ForegroundColor Red
}

# Also check existing education-related files
$educationFiles = Get-ChildItem "wb_unesco_*.json", "wb_who_*.json" | Where-Object { $_.Name -match "(literacy|schooling|education)" }
if ($educationFiles.Count -gt 0) {
    Write-Host ""
    Write-Host "Existing education-related files:" -ForegroundColor Yellow
    foreach ($file in $educationFiles) {
        Write-Host "  • $($file.Name)"
    }
}