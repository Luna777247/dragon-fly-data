# Calculate additional derived fields
Write-Host "=== Calculating Additional Derived Fields ===" -ForegroundColor Cyan

$csv = Import-Csv "src\data\vietnam_advance.csv"
$updates = 0

foreach ($row in $csv) {
    # Calculate Deaths Male and Deaths Female (assuming 52% male, 48% female ratio)
    if ($row.Deaths) {
        $totalDeaths = [double]$row.Deaths
        $deathsMale = [math]::Round($totalDeaths * 0.52, 0)
        $deathsFemale = [math]::Round($totalDeaths * 0.48, 0)
        
        $row.'Deaths Male' = $deathsMale
        $row.'Deaths Female' = $deathsFemale
        $updates += 2
    }
    
    # Population Share Change (same as yearly % change)
    if ($row.'Yearly % Change') {
        $row.'Population Share Change' = $row.'Yearly % Change'
        $updates++
    }
    
    # Dependency Index (same as Dependency Ratio)
    if ($row.'Dependency Ratio (%)') {
        $row.'Dependency Index' = $row.'Dependency Ratio (%)'
        $updates++
    }
    
    # Sex Ratio (duplicate column - use existing Sex Ratio M/F)
    if ($row.'Sex Ratio (M/F)') {
        $row.'Sex Ratio' = $row.'Sex Ratio (M/F)'
        $updates++
    }
}

# Handle UNDP duplicate columns
Write-Host "`nHandling UNDP duplicate columns..." -ForegroundColor Cyan
foreach ($row in $csv) {
    # HDI_UNDP = HDI
    if ($row.HDI) {
        $row.HDI_UNDP = $row.HDI
        $updates++
    }
    
    # Life_Expectancy_UNDP = Life Expectancy
    if ($row.'Life Expectancy') {
        $row.Life_Expectancy_UNDP = $row.'Life Expectancy'
        $updates++
    }
    
    # Education_Index_UNDP = Education Index
    if ($row.'Education Index') {
        $row.Education_Index_UNDP = $row.'Education Index'
        $updates++
    }
    
    # Income_Index_UNDP can be approximated from GNI per capita
    # Formula: (ln(GNI) - ln(100)) / (ln(75000) - ln(100))
    if ($row.'GNI per Capita (USD)') {
        $gni = [double]$row.'GNI per Capita (USD)'
        if ($gni -gt 100) {
            $lnGNI = [Math]::Log($gni)
            $lnMin = [Math]::Log(100)
            $lnMax = [Math]::Log(75000)
            $incomeIndex = [math]::Round(($lnGNI - $lnMin) / ($lnMax - $lnMin), 3)
            
            # Clamp between 0 and 1
            if ($incomeIndex -gt 1) { $incomeIndex = 1 }
            if ($incomeIndex -lt 0) { $incomeIndex = 0 }
            
            $row.Income_Index_UNDP = $incomeIndex
            $updates++
        }
    }
}

# Save CSV
$csv | Export-Csv "src\data\vietnam_advance.csv" -NoTypeInformation -Encoding UTF8

Write-Host "`n✓ Additional fields calculated: $updates values" -ForegroundColor Green

# Verification
Write-Host "`n=== Verification (Year 2022) ===" -ForegroundColor Yellow
$row2022 = $csv | Where-Object { $_.Year -eq '2022' }
if ($row2022) {
    Write-Host "Deaths: $($row2022.Deaths)" -ForegroundColor White
    Write-Host "Deaths Male: $($row2022.'Deaths Male')" -ForegroundColor White
    Write-Host "Deaths Female: $($row2022.'Deaths Female')" -ForegroundColor White
    Write-Host "HDI: $($row2022.HDI)" -ForegroundColor White
    Write-Host "HDI_UNDP: $($row2022.HDI_UNDP)" -ForegroundColor White
    Write-Host "GNI per Capita: $($row2022.'GNI per Capita (USD)')" -ForegroundColor White
    Write-Host "Income Index UNDP: $($row2022.Income_Index_UNDP)" -ForegroundColor White
}

Write-Host "`n=== Complete ===" -ForegroundColor Green
