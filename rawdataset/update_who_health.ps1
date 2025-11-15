# Extract WHO health data from World Bank API for Vietnam
$lifeExpectancyData = Get-Content 'wb_who_life_expectancy.json' | ConvertFrom-Json
$infantMortalityData = Get-Content 'wb_who_infant_mortality.json' | ConvertFrom-Json
$under5MortalityData = Get-Content 'wb_who_under5_mortality.json' | ConvertFrom-Json

# Extract Vietnam data (data is in the second element of the array)
$vnLifeExpectancy = $lifeExpectancyData[1] | Where-Object { $_.countryiso3code -eq 'VNM' -and $_.value -ne $null }
$vnInfantMortality = $infantMortalityData[1] | Where-Object { $_.countryiso3code -eq 'VNM' -and $_.value -ne $null }
$vnUnder5Mortality = $under5MortalityData[1] | Where-Object { $_.countryiso3code -eq 'VNM' -and $_.value -ne $null }

# Create hashtables for quick lookup
$lifeExpectancyHash = @{}
$infantMortalityHash = @{}
$under5MortalityHash = @{}

foreach ($item in $vnLifeExpectancy) {
    $lifeExpectancyHash[$item.date] = $item.value
}

foreach ($item in $vnInfantMortality) {
    $infantMortalityHash[$item.date] = $item.value
}

foreach ($item in $vnUnder5Mortality) {
    $under5MortalityHash[$item.date] = $item.value
}

# Show sample data
Write-Host "Life Expectancy Sample:"
$lifeExpectancyHash.GetEnumerator() | Select-Object -First 5 | Format-Table
Write-Host "Infant Mortality Sample:"
$infantMortalityHash.GetEnumerator() | Select-Object -First 5 | Format-Table
Write-Host "Under-5 Mortality Sample:"
$under5MortalityHash.GetEnumerator() | Select-Object -First 5 | Format-Table

# Load the CSV
$csvPath = "src/data/vietnam_advance.csv"
$csvData = Import-Csv -Path $csvPath

# Update the CSV with WHO data
foreach ($row in $csvData) {
    $year = $row.Year

    # Update Life Expectancy
    if ($lifeExpectancyHash.ContainsKey($year) -and [string]::IsNullOrEmpty($row.'Life Expectancy')) {
        $row.'Life Expectancy' = $lifeExpectancyHash[$year]
    }

    # Update Infant Mortality
    if ($infantMortalityHash.ContainsKey($year) -and [string]::IsNullOrEmpty($row.'Infant Mortality')) {
        $row.'Infant Mortality' = $infantMortalityHash[$year]
    }

    # Update Under-5 Mortality
    if ($under5MortalityHash.ContainsKey($year) -and [string]::IsNullOrEmpty($row.'Under-5 Mortality')) {
        $row.'Under-5 Mortality' = $under5MortalityHash[$year]
    }

    # Also update Infant Mortality Rate (?) if it's the same as Infant Mortality
    if ($infantMortalityHash.ContainsKey($year) -and [string]::IsNullOrEmpty($row.'Infant Mortality Rate (?)')) {
        $row.'Infant Mortality Rate (?)' = $infantMortalityHash[$year]
    }
}

# Export updated CSV
$csvData | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8

Write-Host "WHO health data update completed!"