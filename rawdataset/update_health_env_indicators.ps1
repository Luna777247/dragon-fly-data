# Integrate Health and Environmental Indicators from World Bank API
$healthEnvData = @{}

# Load Health Expenditure (% GDP) - use latest available data
$data = Get-Content 'wb_health_expenditure.json' | ConvertFrom-Json
$vietnamData = $data[1] | Where-Object { $_.countryiso3code -eq 'VNM' -and $null -ne $_.value } | Sort-Object date -Descending
$latestHealth = $vietnamData | Select-Object -First 1
if ($latestHealth) {
    $year = $latestHealth.date
    $value = $latestHealth.value
    if (-not $healthEnvData.ContainsKey($year)) {
        $healthEnvData[$year] = @{}
    }
    $healthEnvData[$year]['Health_Expenditure'] = [math]::Round($value, 2)
}

# Load CO2 Emissions per Capita - use latest available data
$data = Get-Content 'wb_co2_emissions.json' | ConvertFrom-Json
$vietnamData = $data[1] | Where-Object { $_.countryiso3code -eq 'VNM' -and $null -ne $_.value } | Sort-Object date -Descending
$latestCO2 = $vietnamData | Select-Object -First 1
if ($latestCO2) {
    $year = $latestCO2.date
    $value = $latestCO2.value
    if (-not $healthEnvData.ContainsKey($year)) {
        $healthEnvData[$year] = @{}
    }
    $healthEnvData[$year]['CO2_Emissions'] = [math]::Round($value, 2)
}

# Load Renewable Energy Share - use latest available data
$data = Get-Content 'wb_renewable_energy.json' | ConvertFrom-Json
$vietnamData = $data[1] | Where-Object { $_.countryiso3code -eq 'VNM' -and $null -ne $_.value } | Sort-Object date -Descending
$latestRenewable = $vietnamData | Select-Object -First 1
if ($latestRenewable) {
    $year = $latestRenewable.date
    $value = $latestRenewable.value
    if (-not $healthEnvData.ContainsKey($year)) {
        $healthEnvData[$year] = @{}
    }
    $healthEnvData[$year]['Renewable_Energy'] = [math]::Round($value, 1)
}

Write-Host "Latest Health and Environmental Indicators for Vietnam:" -ForegroundColor Green
$healthEnvData.GetEnumerator() | Sort-Object Name -Descending | Select-Object -First 3 | ForEach-Object {
    $year = $_.Key
    $data = $_.Value
    $healthExp = if ($data.ContainsKey('Health_Expenditure')) { $data['Health_Expenditure'] } else { 'N/A' }
    $co2 = if ($data.ContainsKey('CO2_Emissions')) { $data['CO2_Emissions'] } else { 'N/A' }
    $renewable = if ($data.ContainsKey('Renewable_Energy')) { $data['Renewable_Energy'] } else { 'N/A' }
    Write-Host "$year - Health Expenditure: ${healthExp}%, CO2 Emissions: ${co2} t, Renewable Energy: ${renewable}%"
}

# Update CSV
$csv = Import-Csv 'src/data/vietnam_advance.csv'

foreach ($row in $csv) {
    $year = $row.Year
    if ($healthEnvData.ContainsKey($year)) {
        $data = $healthEnvData[$year]
        if ($data.ContainsKey('Health_Expenditure')) {
            $row.'Health Expenditure (% GDP)' = $data['Health_Expenditure']
        }
        if ($data.ContainsKey('CO2_Emissions')) {
            $row.'CO? Emissions per Capita (t)' = $data['CO2_Emissions']
        }
        if ($data.ContainsKey('Renewable_Energy')) {
            $row.'Renewable Energy Share (%)' = $data['Renewable_Energy']
        }
    }
}

$csv | Export-Csv 'src/data/vietnam_advance.csv' -NoTypeInformation -Encoding UTF8

Write-Host ""
Write-Host "Health and environmental indicators integrated successfully!" -ForegroundColor Green