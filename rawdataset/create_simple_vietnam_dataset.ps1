# Create simple Vietnam dataset from known sources
Write-Host "🔧 TẠO VIETNAM DATASET ĐƠN GIẢN" -ForegroundColor Cyan
Write-Host "=" * 72 -ForegroundColor DarkGray

# Base dataset with manual key data points
$dataset = @()

# Historical population data (from census and estimates)
$popData = @{
    1955 = 27367000
    1960 = 32670000
    1965 = 38581000
    1970 = 43404500
    1975 = 48738000
    1980 = 54373000
    1985 = 60225000
    1990 = 67589000
    1995 = 72001000
    2000 = 77635000
    2005 = 83108000
    2010 = 87411000
    2015 = 91713000
    2020 = 97339000
    2023 = 98187000
}

Write-Host "`n📊 Tạo dataset từ năm 1955 đến 2023..." -ForegroundColor Yellow

foreach($year in 1955..2023) {
    $row = [PSCustomObject]@{
        Year = $year
        Population = if($popData[$year]) { $popData[$year] } else { 'N/A' }
        'GDP Growth Rate (%)' = 'N/A'
        'GDP per Capita (USD)' = 'N/A'
        'HDI' = 'N/A'
        'Life Expectancy' = 'N/A'
        'Fertility Rate' = 'N/A'
        'Birth Rate (‰)' = 'N/A'
        'Death Rate (‰)' = 'N/A'
        'Unemployment Rate (%)' = 'N/A'
        'Health Expenditure (% GDP)' = 'N/A'
        'CO₂ Emissions per Capita (t)' = 'N/A'
        'Renewable Energy Share (%)' = 'N/A'
        'FDI Net Inflows (million USD)' = 'N/A'
        'Employment Agriculture (%)' = 'N/A'
        'Employment Industry (%)' = 'N/A'
        'Employment Services (%)' = 'N/A'
        'Poverty Rate (%)' = 'N/A'
        'Urban Population' = 'N/A'
        'Rural Population' = 'N/A'
    }
    $dataset += $row
}

# Interpolate missing population data
Write-Host "  • Nội suy dân số..." -ForegroundColor Gray
for($i = 0; $i -lt $dataset.Count; $i++) {
    if($dataset[$i].Population -eq 'N/A') {
        # Find previous and next known values
        $prevIdx = $i - 1
        while($prevIdx -ge 0 -and $dataset[$prevIdx].Population -eq 'N/A') {
            $prevIdx--
        }
        
        $nextIdx = $i + 1
        while($nextIdx -lt $dataset.Count -and $dataset[$nextIdx].Population -eq 'N/A') {
            $nextIdx++
        }
        
        if($prevIdx -ge 0 -and $nextIdx -lt $dataset.Count) {
            $prevPop = [long]$dataset[$prevIdx].Population
            $nextPop = [long]$dataset[$nextIdx].Population
            $prevYear = [int]$dataset[$prevIdx].Year
            $nextYear = [int]$dataset[$nextIdx].Year
            $currentYear = [int]$dataset[$i].Year
            
            $ratio = ($currentYear - $prevYear) / ($nextYear - $prevYear)
            $interpolated = [long]($prevPop + ($nextPop - $prevPop) * $ratio)
            $dataset[$i].Population = $interpolated
        }
    }
}

# Add some known HDI values
$hdiData = @{
    1990 = 0.475
    1995 = 0.534
    2000 = 0.579
    2005 = 0.619
    2010 = 0.655
    2015 = 0.683
    2019 = 0.704
    2020 = 0.703
    2021 = 0.703
    2022 = 0.726
}

Write-Host "  • Thêm HDI..." -ForegroundColor Gray
foreach($year in $hdiData.Keys) {
    $row = $dataset | Where-Object {$_.Year -eq $year}
    if($row) {
        $row.HDI = $hdiData[$year]
    }
}

# Add some known GDP Growth Rate
$gdpGrowthData = @{
    1990 = 5.1
    1995 = 9.5
    2000 = 6.8
    2005 = 7.5
    2010 = 6.4
    2015 = 7.0
    2019 = 7.0
    2020 = 2.9
    2021 = 2.6
    2022 = 8.0
    2023 = 5.0
}

Write-Host "  • Thêm GDP Growth Rate..." -ForegroundColor Gray
foreach($year in $gdpGrowthData.Keys) {
    $row = $dataset | Where-Object {$_.Year -eq $year}
    if($row) {
        $row.'GDP Growth Rate (%)' = $gdpGrowthData[$year]
    }
}

# Add Life Expectancy data
$lifeExpData = @{
    1960 = 47.7
    1970 = 54.2
    1980 = 61.1
    1990 = 69.1
    2000 = 72.8
    2010 = 75.0
    2015 = 75.6
    2020 = 75.4
    2021 = 73.6
    2022 = 74.0
}

Write-Host "  • Thêm Life Expectancy..." -ForegroundColor Gray
foreach($year in $lifeExpData.Keys) {
    $row = $dataset | Where-Object {$_.Year -eq $year}
    if($row) {
        $row.'Life Expectancy' = $lifeExpData[$year]
    }
}

# Add Fertility Rate
$fertilityData = @{
    1960 = 6.38
    1970 = 6.50
    1980 = 4.63
    1990 = 3.63
    2000 = 2.07
    2010 = 1.96
    2015 = 2.06
    2020 = 2.05
    2022 = 2.01
}

Write-Host "  • Thêm Fertility Rate..." -ForegroundColor Gray
foreach($year in $fertilityData.Keys) {
    $row = $dataset | Where-Object {$_.Year -eq $year}
    if($row) {
        $row.'Fertility Rate' = $fertilityData[$year]
    }
}

# Export to CSV
$outputFile = "vietnam.csv"
$dataset | Export-Csv $outputFile -Encoding UTF8 -NoTypeInformation

Write-Host "`n✅ ĐÃ TẠO DATASET: $outputFile" -ForegroundColor Green
Write-Host "=" * 72 -ForegroundColor DarkGray

# Summary
$finalCsv = Import-Csv $outputFile -Encoding UTF8
Write-Host "`n📊 TỔNG QUAN DATASET:" -ForegroundColor Cyan
Write-Host "  • Số năm: $($finalCsv.Count)" -ForegroundColor Green
Write-Host "  • Năm đầu: $($finalCsv[0].Year)" -ForegroundColor Gray
Write-Host "  • Năm cuối: $($finalCsv[-1].Year)" -ForegroundColor Gray
Write-Host "  • Số cột: $($finalCsv[0].PSObject.Properties.Count)" -ForegroundColor Gray

# Calculate fill rate
$totalCells = $finalCsv.Count * ($finalCsv[0].PSObject.Properties.Count - 1)
$filledCells = 0
foreach($row in $finalCsv) {
    foreach($prop in $row.PSObject.Properties) {
        if($prop.Name -ne 'Year' -and $prop.Value -and $prop.Value -ne 'N/A' -and $prop.Value -ne '') {
            $filledCells++
        }
    }
}
$fillRate = [Math]::Round(($filledCells / $totalCells) * 100, 2)
Write-Host "  • Fill rate: $fillRate%" -ForegroundColor $(if($fillRate -ge 30){'Green'}elseif($fillRate -ge 20){'Yellow'}else{'Red'})

# Show sample data
Write-Host "`n📋 Dữ liệu mẫu (5 năm gần nhất):" -ForegroundColor Cyan
$finalCsv | Select-Object -Last 5 | Format-Table Year, Population, HDI, 'GDP Growth Rate (%)', 'Life Expectancy' -AutoSize

Write-Host "`n✅ HOÀN THÀNH!" -ForegroundColor Green
Write-Host "   File đã được lưu: $outputFile" -ForegroundColor Gray
