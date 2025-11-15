# Calculate derived fields from verified data
Write-Host "=== Calculating Derived Fields from Verified Data ===" -ForegroundColor Cyan

# Load CSV
$csv = Import-Csv "src\data\vietnam_advance.csv"

$updates = 0

foreach ($row in $csv) {
    $year = $row.Year
    $population = [double]$row.Population
    
    # Calculate absolute births and deaths from rates
    $birthRate = if ($row.'Birth Rate (?)') { [double]$row.'Birth Rate (?)' } else { 0 }
    $deathRate = if ($row.'Death Rate (?)') { [double]$row.'Death Rate (?)' } else { 0 }
    
    if ($population -gt 0 -and $birthRate -gt 0) {
        $births = [math]::Round($population * $birthRate / 1000, 0)
        $row.Births = $births
        $updates++
    }
    
    if ($population -gt 0 -and $deathRate -gt 0) {
        $deaths = [math]::Round($population * $deathRate / 1000, 0)
        $row.Deaths = $deaths
        $updates++
    }
    
    # Calculate Yearly Change and % Change
    if ($year -gt 1955) {
        $prevRow = $csv | Where-Object { $_.Year -eq ([int]$year - 1) }
        if ($prevRow) {
            $prevPop = [double]$prevRow.Population
            if ($prevPop -gt 0) {
                $yearlyChange = $population - $prevPop
                $yearlyPctChange = [math]::Round(($yearlyChange / $prevPop) * 100, 2)
                
                $row.'Yearly Change' = $yearlyChange
                $row.'Yearly % Change' = $yearlyPctChange
                $updates += 2
                
                # Calculate Population Doubling Time (years = 70 / growth rate)
                if ($yearlyPctChange -gt 0) {
                    $doublingTime = [math]::Round(70 / $yearlyPctChange, 1)
                    $row.'Population Doubling Time (Years)' = $doublingTime
                    $updates++
                }
            }
        }
    }
    
    # Calculate Population Growth (Absolute) - same as Yearly Change
    if ($row.'Yearly Change') {
        $row.'Population Growth (Absolute)' = $row.'Yearly Change'
        $updates++
    }
    
    # Calculate Net Migration Rate (per 1000)
    $migrants = if ($row.'Migrants (net)') { [double]$row.'Migrants (net)' } else { 0 }
    if ($population -gt 0) {
        $migrationRate = [math]::Round(($migrants / $population) * 1000, 2)
        $row.'Net Migration Rate (?)' = $migrationRate
        $row.'Migration Rate (?)' = $migrationRate
        $updates += 2
    }
    
    # Calculate Infant Mortality Rate (already have this, but ensure consistency)
    if ($row.'Infant Mortality') {
        $row.'Infant Mortality Rate (?)' = $row.'Infant Mortality'
        $updates++
    }
    
    # Calculate Urban Pop % (already have as Urbanization Ratio)
    if ($row.'Urbanization Ratio') {
        $row.'Urban Pop %' = $row.'Urbanization Ratio'
        $updates++
    }
}

# Save updated CSV
$csv | Export-Csv "src\data\vietnam_advance.csv" -NoTypeInformation -Encoding UTF8

Write-Host "`n✓ Calculated fields updated: $updates values" -ForegroundColor Green

# Verify calculations for 2022
Write-Host "`n=== Verification (Year 2022) ===" -ForegroundColor Yellow
$row2022 = $csv | Where-Object { $_.Year -eq '2022' }
if ($row2022) {
    Write-Host "Population: $($row2022.Population)" -ForegroundColor White
    Write-Host "Birth Rate: $($row2022.'Birth Rate (?)') ‰" -ForegroundColor White
    Write-Host "Calculated Births: $($row2022.Births)" -ForegroundColor White
    Write-Host "Death Rate: $($row2022.'Death Rate (?)') ‰" -ForegroundColor White
    Write-Host "Calculated Deaths: $($row2022.Deaths)" -ForegroundColor White
    Write-Host "Yearly Change: $($row2022.'Yearly Change')" -ForegroundColor White
    Write-Host "Yearly % Change: $($row2022.'Yearly % Change')%" -ForegroundColor White
    Write-Host "Migration Rate: $($row2022.'Migration Rate (?)') ‰" -ForegroundColor White
}
