# Search for correct education indicator codes
Write-Host "Searching for correct education indicator codes..." -ForegroundColor Green

# Try different codes for Mean Years of Schooling and Expected Years of Schooling
$educationCodes = @(
    "SE.SEC.CUAT.LO.MA.ZS",  # Mean years of schooling (years)
    "SE.SEC.CUAT.LO.FE.ZS",  # Mean years of schooling, female
    "SE.SEC.CUAT.LO.MA.ZS",  # Mean years of schooling, male
    "HD.HCI.EDUC.LO",        # HCI Education subindex
    "UIS.EA.MEAN.1T6.AG25T64", # Mean years of schooling (UNESCO)
    "UIS.SAP.1.GCA",         # School life expectancy
    "UIS.SLE.1T6.AG15T64",   # School life expectancy (years)
    "SE.SEC.DURS",           # Secondary education, duration (years)
    "SE.PRM.DURS",           # Primary education, duration (years)
    "UIS.E.0.T",             # Expected years of schooling
    "UIS.E.0.F",             # Expected years of schooling, female
    "UIS.E.0.M"              # Expected years of schooling, male
)

$foundIndicators = @()

foreach ($code in $educationCodes) {
    Write-Host "Trying $code..." -ForegroundColor Yellow

    try {
        $url = "https://api.worldbank.org/v2/country/VNM/indicator/$code?format=json&per_page=1000"
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing
        $jsonData = $response.Content | ConvertFrom-Json

        if ($jsonData -and $jsonData.Count -gt 1 -and $jsonData[1]) {
            $vietnamData = $jsonData[1] | Where-Object { $_.countryiso3code -eq 'VNM' -and $null -ne $_.value }
            if ($vietnamData.Count -gt 0) {
                $latest = $vietnamData | Sort-Object date -Descending | Select-Object -First 1
                Write-Host "  ✓ Found: $($latest.indicator.value)" -ForegroundColor Green
                Write-Host "    Latest: $($latest.date) = $($latest.value)" -ForegroundColor Green

                $foundIndicators += @{
                    Code = $code
                    Description = $latest.indicator.value
                    LatestYear = $latest.date
                    LatestValue = $latest.value
                    Data = $jsonData
                }

                # Save the data
                $jsonData | ConvertTo-Json -Depth 10 | Out-File "wb_education_$code.json" -Encoding UTF8
            }
        }
    }
    catch {
        # Continue to next code
    }
}

Write-Host ""
Write-Host "Summary of found education indicators:" -ForegroundColor Cyan
$foundIndicators | ForEach-Object {
    Write-Host "• $($_.Code): $($_.LatestYear) = $($_.LatestValue) ($($_.Description))"
}

# Try to get UNDP HDR data directly if available
Write-Host ""
Write-Host "Checking for UNDP HDR data sources..." -ForegroundColor Yellow
Write-Host "Note: Mean Years of Schooling and Expected Years of Schooling are typically from UNDP Human Development Reports"
Write-Host "You may need to download directly from: https://hdr.undp.org/data-center/human-development-index#/indicies/HDI"