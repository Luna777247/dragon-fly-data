# Integrate ILO Employment Sector Data from World Bank API
$employmentData = @{}

# Load agriculture employment data
$data = Get-Content 'wb_ilo_agriculture_employment.json' | ConvertFrom-Json
$vietnamData = $data[1] | Where-Object { $_.countryiso3code -eq 'VNM' }
foreach ($entry in $vietnamData) {
    $year = $entry.date
    $value = $entry.value
    if ($null -ne $value -and $value) {
        if (-not $employmentData.ContainsKey($year)) {
            $employmentData[$year] = @{}
        }
        $employmentData[$year]['Agriculture'] = [math]::Round($value, 1)
    }
}

# Load industry employment data
$data = Get-Content 'wb_ilo_industry_employment.json' | ConvertFrom-Json
$vietnamData = $data[1] | Where-Object { $_.countryiso3code -eq 'VNM' }
foreach ($entry in $vietnamData) {
    $year = $entry.date
    $value = $entry.value
    if ($null -ne $value -and $value) {
        if (-not $employmentData.ContainsKey($year)) {
            $employmentData[$year] = @{}
        }
        $employmentData[$year]['Industry'] = [math]::Round($value, 1)
    }
}

# Load services employment data
$data = Get-Content 'wb_ilo_services_employment.json' | ConvertFrom-Json
$vietnamData = $data[1] | Where-Object { $_.countryiso3code -eq 'VNM' }
foreach ($entry in $vietnamData) {
    $year = $entry.date
    $value = $entry.value
    if ($null -ne $value -and $value) {
        if (-not $employmentData.ContainsKey($year)) {
            $employmentData[$year] = @{}
        }
        $employmentData[$year]['Services'] = [math]::Round($value, 1)
    }
}

Write-Host "ILO Employment Sector Data for Vietnam:" -ForegroundColor Green
$employmentData.GetEnumerator() | Sort-Object Name | ForEach-Object {
    $year = $_.Key
    $sectors = $_.Value
    $agri = if ($sectors.ContainsKey('Agriculture')) { $sectors['Agriculture'] } else { 'N/A' }
    $ind = if ($sectors.ContainsKey('Industry')) { $sectors['Industry'] } else { 'N/A' }
    $serv = if ($sectors.ContainsKey('Services')) { $sectors['Services'] } else { 'N/A' }
    Write-Host "$year - Agriculture: ${agri}%, Industry: ${ind}%, Services: ${serv}%"
}

# Update CSV
$csv = Import-Csv 'src/data/vietnam_advance.csv'

foreach ($row in $csv) {
    $year = $row.Year
    if ($employmentData.ContainsKey($year)) {
        $sectors = $employmentData[$year]
        if ($sectors.ContainsKey('Agriculture')) {
            $row.'Employment Agriculture (%)' = $sectors['Agriculture']
        }
        if ($sectors.ContainsKey('Industry')) {
            $row.'Employment Industry (%)' = $sectors['Industry']
        }
        if ($sectors.ContainsKey('Services')) {
            $row.'Employment Services (%)' = $sectors['Services']
        }
    }
}

$csv | Export-Csv 'src/data/vietnam_advance.csv' -NoTypeInformation -Encoding UTF8

Write-Host ""
Write-Host "ILO Employment Sector data integrated successfully!" -ForegroundColor Green