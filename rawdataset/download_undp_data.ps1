# Download UNDP HDR indicators (available through World Bank)
Write-Host "Downloading UNDP HDR indicators for Vietnam..." -ForegroundColor Green

# UNDP HDR indicators that might be available through World Bank
$undpIndicators = @(
    @{Name="Poverty_Rate"; Code="SI.POV.NAHC"; Description="Poverty headcount ratio at national poverty lines (% of population)"},
    @{Name="Poverty_Gap"; Code="SI.POV.GAPS"; Description="Poverty gap at $1.90 a day (2011 PPP) (%)"},
    @{Name="Gini_Index"; Code="SI.POV.GINI"; Description="Gini index"},
    @{Name="Education_Index"; Code="HD.HCI.OVRL"; Description="Human Capital Index (includes education component)"},
    @{Name="Mean_Years_Schooling"; Code="BAR.SCHL.15UP"; Description="Barro-Lee: Average years of total schooling, age 15+, total"},
    @{Name="Expected_Years_Schooling"; Code="HD.HCI.OVRL"; Description="Human Capital Index"}
)

# Alternative UNDP-related indicators
$hdrIndicators = @(
    @{Name="Multidimensional_Poverty"; Code="SI.POV.MDIM"; Description="Multidimensional poverty headcount ratio (% of total population)"},
    @{Name="Income_Index"; Code="HD.HCI.OVRL"; Description="Human Capital Index"},
    @{Name="Gender_Inequality_Index"; Code="HD.HCI.OVRL"; Description="Human Capital Index"}
)

$allIndicators = $undpIndicators + $hdrIndicators

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
                $jsonData | ConvertTo-Json -Depth 10 | Out-File "wb_undp_${name}.json" -Encoding UTF8
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
Write-Host "Checking available UNDP data..." -ForegroundColor Cyan

# Check what UNDP files we have
$undpFiles = Get-ChildItem "wb_undp_*.json"
if ($undpFiles.Count -gt 0) {
    Write-Host "Available UNDP files:" -ForegroundColor Green
    foreach ($file in $undpFiles) {
        $fileName = $file.Name -replace 'wb_undp_', '' -replace '.json', ''
        Write-Host "  • $fileName"
    }
} else {
    Write-Host "No UNDP files found" -ForegroundColor Red
}

# Check for any existing UNDP-related data
$existingUndpData = Get-ChildItem "wb_*.json" | Where-Object {
    $_.Name -match "(pov|hdr|gini|multidim|inequality)" -or
    $_.Name -match "(undp|hdi|human|capital)"
}

if ($existingUndpData.Count -gt 0) {
    Write-Host ""
    Write-Host "Existing UNDP-related files:" -ForegroundColor Yellow
    foreach ($file in $existingUndpData) {
        Write-Host "  • $($file.Name)"
    }
}

Write-Host ""
Write-Host "Note: If UNDP indicators are not available through World Bank API," -ForegroundColor Yellow
Write-Host "you may need to download directly from UNDP HDR website:"
Write-Host "https://hdr.undp.org/data-center/human-development-index#/indicies/HDI"