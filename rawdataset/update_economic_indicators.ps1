# Integrate Economic Indicators from World Bank API
$economicData = @{}

# Load GDP per Capita
$data = Get-Content 'wb_gdp_per_capita.json' | ConvertFrom-Json
$vietnamData = $data[1] | Where-Object { $_.countryiso3code -eq 'VNM' }
foreach ($entry in $vietnamData) {
    $year = $entry.date
    $value = $entry.value
    if ($null -ne $value -and $value) {
        if (-not $economicData.ContainsKey($year)) {
            $economicData[$year] = @{}
        }
        $economicData[$year]['GDP_per_Capita'] = [math]::Round($value, 2)
    }
}

# Load GDP Growth Rate
$data = Get-Content 'wb_gdp_growth.json' | ConvertFrom-Json
$vietnamData = $data[1] | Where-Object { $_.countryiso3code -eq 'VNM' }
foreach ($entry in $vietnamData) {
    $year = $entry.date
    $value = $entry.value
    if ($null -ne $value -and $value) {
        if (-not $economicData.ContainsKey($year)) {
            $economicData[$year] = @{}
        }
        $economicData[$year]['GDP_Growth'] = [math]::Round($value, 2)
    }
}

# Load GDP Total (convert to billion USD)
$data = Get-Content 'wb_gdp_total.json' | ConvertFrom-Json
$vietnamData = $data[1] | Where-Object { $_.countryiso3code -eq 'VNM' }
foreach ($entry in $vietnamData) {
    $year = $entry.date
    $value = $entry.value
    if ($null -ne $value -and $value) {
        if (-not $economicData.ContainsKey($year)) {
            $economicData[$year] = @{}
        }
        # Convert from USD to billion USD
        $economicData[$year]['GDP_billion'] = [math]::Round($value / 1000000000, 2)
    }
}

# Load Inflation Rate
$data = Get-Content 'wb_inflation.json' | ConvertFrom-Json
$vietnamData = $data[1] | Where-Object { $_.countryiso3code -eq 'VNM' }
foreach ($entry in $vietnamData) {
    $year = $entry.date
    $value = $entry.value
    if ($null -ne $value -and $value) {
        if (-not $economicData.ContainsKey($year)) {
            $economicData[$year] = @{}
        }
        $economicData[$year]['Inflation'] = [math]::Round($value, 2)
    }
}

# Load Imports (% GDP)
$data = Get-Content 'wb_imports_gdp.json' | ConvertFrom-Json
$vietnamData = $data[1] | Where-Object { $_.countryiso3code -eq 'VNM' }
foreach ($entry in $vietnamData) {
    $year = $entry.date
    $value = $entry.value
    if ($null -ne $value -and $value) {
        if (-not $economicData.ContainsKey($year)) {
            $economicData[$year] = @{}
        }
        $economicData[$year]['Imports_GDP'] = [math]::Round($value, 1)
    }
}

# Load Exports (% GDP)
$data = Get-Content 'wb_exports_gdp.json' | ConvertFrom-Json
$vietnamData = $data[1] | Where-Object { $_.countryiso3code -eq 'VNM' }
foreach ($entry in $vietnamData) {
    $year = $entry.date
    $value = $entry.value
    if ($null -ne $value -and $value) {
        if (-not $economicData.ContainsKey($year)) {
            $economicData[$year] = @{}
        }
        $economicData[$year]['Exports_GDP'] = [math]::Round($value, 1)
    }
}

Write-Host "Economic Indicators for Vietnam (2023):" -ForegroundColor Green
$year2023 = $economicData['2023']
if ($year2023) {
    $gdpCap = if ($year2023.ContainsKey('GDP_per_Capita')) { $year2023['GDP_per_Capita'] } else { 'N/A' }
    $gdpGrowth = if ($year2023.ContainsKey('GDP_Growth')) { $year2023['GDP_Growth'] } else { 'N/A' }
    $gdpBillion = if ($year2023.ContainsKey('GDP_billion')) { $year2023['GDP_billion'] } else { 'N/A' }
    $inflation = if ($year2023.ContainsKey('Inflation')) { $year2023['Inflation'] } else { 'N/A' }
    $imports = if ($year2023.ContainsKey('Imports_GDP')) { $year2023['Imports_GDP'] } else { 'N/A' }
    $exports = if ($year2023.ContainsKey('Exports_GDP')) { $year2023['Exports_GDP'] } else { 'N/A' }

    Write-Host "GDP per Capita (USD): $gdpCap"
    Write-Host "GDP Growth Rate (%): $gdpGrowth"
    Write-Host "GDP (billion USD): $gdpBillion"
    Write-Host "Inflation Rate (%): $inflation"
    Write-Host "Imports (% GDP): $imports"
    Write-Host "Exports (% GDP): $exports"
}

# Update CSV
$csv = Import-Csv 'src/data/vietnam_advance.csv'

foreach ($row in $csv) {
    $year = $row.Year
    if ($economicData.ContainsKey($year)) {
        $data = $economicData[$year]
        if ($data.ContainsKey('GDP_per_Capita')) {
            $row.'GDP per Capita (USD)' = $data['GDP_per_Capita']
        }
        if ($data.ContainsKey('GDP_Growth')) {
            $row.'GDP Growth Rate (%)' = $data['GDP_Growth']
        }
        if ($data.ContainsKey('GDP_billion')) {
            $row.'GDP (billion USD)' = $data['GDP_billion']
        }
        if ($data.ContainsKey('Inflation')) {
            $row.'Inflation Rate (%)' = $data['Inflation']
        }
        if ($data.ContainsKey('Imports_GDP')) {
            $row.'Imports (% GDP)' = $data['Imports_GDP']
        }
        if ($data.ContainsKey('Exports_GDP')) {
            $row.'Exports (% GDP)' = $data['Exports_GDP']
        }
    }
}

$csv | Export-Csv 'src/data/vietnam_advance.csv' -NoTypeInformation -Encoding UTF8

Write-Host ""
Write-Host "Economic indicators integrated successfully!" -ForegroundColor Green