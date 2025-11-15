# Comprehensive value range validation for all columns
Write-Host "╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║           KIỂM TRA KHOẢNG GIÁ TRỊ HỢP LÝ CHO TỪNG CỘT                  ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$csv = Import-Csv "vietnam_population.csv" -Encoding UTF8

# Define expected ranges for each column type
$validationRules = @{
    # Percentages (0-100)
    "Vietnam's Share of Asian Pop (%)" = @{Min=0; Max=100; Type="Percentage"}
    "Country's Share of World Pop" = @{Min=0; Max=100; Type="Percentage"}
    "Dependency Ratio (%)" = @{Min=0; Max=200; Type="Percentage"}
    "Pop Aged 0–14 (%)" = @{Min=0; Max=100; Type="Percentage"}
    "Pop Aged 15–64 (%)" = @{Min=0; Max=100; Type="Percentage"}
    "Pop Aged 65+ (%)" = @{Min=0; Max=100; Type="Percentage"}
    "Unemployment Rate (%)" = @{Min=0; Max=100; Type="Percentage"}
    "GDP Growth Rate (%)" = @{Min=-50; Max=50; Type="Percentage"}
    "Employment Agriculture (%)" = @{Min=0; Max=100; Type="Percentage"}
    "Employment Industry (%)" = @{Min=0; Max=100; Type="Percentage"}
    "Employment Services (%)" = @{Min=0; Max=100; Type="Percentage"}
    "Poverty Rate (%)" = @{Min=0; Max=100; Type="Percentage"}
    "Health Expenditure (% GDP)" = @{Min=0; Max=50; Type="Percentage"}
    "Agricultural Land (% Land)" = @{Min=0; Max=100; Type="Percentage"}
    "Forest Area (% Land)" = @{Min=0; Max=100; Type="Percentage"}
    "Renewable Energy Share (%)" = @{Min=0; Max=100; Type="Percentage"}
    "Urban Pop %" = @{Min=0; Max=100; Type="Percentage"}
    
    # Ratios (0-5 typical)
    "Sex Ratio (M/F)" = @{Min=0.5; Max=1.5; Type="Ratio"}
    "Fertility Rate" = @{Min=1; Max=8; Type="Ratio"}
    
    # HDI (0-1)
    "HDI" = @{Min=0; Max=1; Type="Index"}
    "Human Capital Index (0-1)" = @{Min=0; Max=1; Type="Index"}
    
    # Age (0-100)
    "Median Age" = @{Min=10; Max=60; Type="Age"}
    "Regional Median Age" = @{Min=10; Max=60; Type="Age"}
    "Global Median Age" = @{Min=10; Max=60; Type="Age"}
    "Life Expectancy" = @{Min=30; Max=100; Type="Age"}
    
    # Birth/Death rates per 1000 (0-50)
    "Birth Rate (‰)" = @{Min=0; Max=50; Type="Rate"}
    "Death Rate (‰)" = @{Min=0; Max=50; Type="Rate"}
    
    # Large numbers
    "Population" = @{Min=10000000; Max=200000000; Type="Population"}
    "Rural Population" = @{Min=0; Max=150000000; Type="Population"}
    "Urban Population" = @{Min=0; Max=150000000; Type="Population"}
    "FDI Net Inflows (million USD)" = @{Min=-10000; Max=50000; Type="Money"}
    "GDP per Capita (USD)" = @{Min=0; Max=100000; Type="Money"}
    "GDP PPP per Capita (Int$)" = @{Min=0; Max=100000; Type="Money"}
    
    # Rankings (1-200)
    "Vietnam Global Rank" = @{Min=1; Max=200; Type="Rank"}
    "ASEAN Population Rank" = @{Min=1; Max=11; Type="Rank"}
    
    # Energy/Emissions
    "Energy Consumption per Capita (kWh)" = @{Min=0; Max=20000; Type="Energy"}
    "CO₂ Emissions per Capita (t)" = @{Min=0; Max=50; Type="Emissions"}
}

$issues = @()
$totalChecks = 0
$validValues = 0

Write-Host "`n🔍 Đang kiểm tra từng cột..." -ForegroundColor Yellow

foreach($column in $validationRules.Keys) {
    $rule = $validationRules[$column]
    $columnIssues = @()
    
    foreach($row in $csv) {
        $value = $row.$column
        
        if([string]::IsNullOrWhiteSpace($value) -or $value -eq "N/A" -or $value -eq "#N/A" -or $value -eq "0" -or $value -eq "0.0") {
            continue
        }
        
        try {
            $numValue = [double]$value
            $totalChecks++
            
            if($numValue -lt $rule.Min -or $numValue -gt $rule.Max) {
                $columnIssues += [PSCustomObject]@{
                    Year = $row.Year
                    Column = $column
                    Value = $numValue
                    Expected = "$($rule.Min) - $($rule.Max)"
                    Type = $rule.Type
                }
            } else {
                $validValues++
            }
        } catch {
            # Skip non-numeric values
        }
    }
    
    if($columnIssues.Count -gt 0) {
        $issues += $columnIssues
        Write-Host "   ⚠️  $column`: $($columnIssues.Count) giá trị ngoài khoảng" -ForegroundColor Yellow
    }
}

Write-Host "`n╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                         KẾT QUẢ KIỂM TRA                               ║" -ForegroundColor Cyan
Write-Host "╠════════════════════════════════════════════════════════════════════════╣" -ForegroundColor Cyan
Write-Host "║  📊 Tổng số giá trị kiểm tra: $totalChecks" -NoNewline -ForegroundColor White
Write-Host (" " * (41 - "$totalChecks".Length)) -NoNewline
Write-Host "║" -ForegroundColor Cyan
Write-Host "║  ✅ Giá trị hợp lệ: $validValues" -NoNewline -ForegroundColor White
Write-Host (" " * (50 - "$validValues".Length)) -NoNewline
Write-Host "║" -ForegroundColor Cyan
Write-Host "║  ⚠️  Giá trị ngoài khoảng: $($issues.Count)" -NoNewline -ForegroundColor $(if($issues.Count -eq 0){'Green'}else{'Yellow'})
Write-Host (" " * (43 - "$($issues.Count)".Length)) -NoNewline
Write-Host "║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

if($issues.Count -gt 0) {
    Write-Host "`n⚠️  CHI TIẾT CÁC GIÁ TRỊ BẤT THƯỜNG:" -ForegroundColor Yellow
    
    # Group by column
    $groupedIssues = $issues | Group-Object -Property Column
    
    foreach($group in $groupedIssues) {
        Write-Host "`n   📌 $($group.Name) ($($group.Count) giá trị):" -ForegroundColor Cyan
        $expectedRange = $group.Group[0].Expected
        Write-Host "      Khoảng hợp lý: $expectedRange" -ForegroundColor Gray
        
        # Show first 10 problematic values
        $samples = $group.Group | Select-Object -First 10
        foreach($sample in $samples) {
            Write-Host "      • Năm $($sample.Year): $($sample.Value)" -ForegroundColor Red
        }
        
        if($group.Count -gt 10) {
            Write-Host "      ... và $($group.Count - 10) giá trị khác" -ForegroundColor DarkGray
        }
    }
    
    # Export detailed report
    $issues | Export-Csv "value_range_validation_report.csv" -Encoding UTF8 -NoTypeInformation
    Write-Host "`n📄 Báo cáo chi tiết: value_range_validation_report.csv" -ForegroundColor Gray
} else {
    Write-Host "`n✅ TẤT CẢ GIÁ TRỊ ĐỀU NẰM TRONG KHOẢNG HỢP LÝ!" -ForegroundColor Green
}

# Additional checks
Write-Host "`n🔍 KIỂM TRA BỔ SUNG:" -ForegroundColor Cyan

# 1. Check if age percentages sum to 100
Write-Host "`n   1. Tổng phần trăm độ tuổi (0-14 + 15-64 + 65+) = 100%?" -ForegroundColor Yellow
$ageIssues = @()
foreach($row in $csv) {
    $age0_14 = $row.'Pop Aged 0–14 (%)'
    $age15_64 = $row.'Pop Aged 15–64 (%)'
    $age65plus = $row.'Pop Aged 65+ (%)'
    
    if($age0_14 -and $age15_64 -and $age65plus -and 
       $age0_14 -ne "N/A" -and $age15_64 -ne "N/A" -and $age65plus -ne "N/A") {
        try {
            $sum = [double]$age0_14 + [double]$age15_64 + [double]$age65plus
            if([Math]::Abs($sum - 100) -gt 1) { # Allow 1% tolerance
                $ageIssues += "Năm $($row.Year): $([Math]::Round($sum, 2))%"
            }
        } catch {}
    }
}

if($ageIssues.Count -gt 0) {
    Write-Host "      ⚠️  $($ageIssues.Count) năm có tổng khác 100%:" -ForegroundColor Yellow
    $ageIssues | Select-Object -First 5 | ForEach-Object { Write-Host "         $_" -ForegroundColor Red }
} else {
    Write-Host "      ✅ Tất cả các năm có tổng ~100%" -ForegroundColor Green
}

# 2. Check if employment percentages sum to 100
Write-Host "`n   2. Tổng phần trăm việc làm (Agriculture + Industry + Services) = 100%?" -ForegroundColor Yellow
$empIssues = @()
foreach($row in $csv) {
    $agri = $row.'Employment Agriculture (%)'
    $ind = $row.'Employment Industry (%)'
    $serv = $row.'Employment Services (%)'
    
    if($agri -and $ind -and $serv -and 
       $agri -ne "N/A" -and $ind -ne "N/A" -and $serv -ne "N/A") {
        try {
            $sum = [double]$agri + [double]$ind + [double]$serv
            if([Math]::Abs($sum - 100) -gt 1) { # Allow 1% tolerance
                $empIssues += "Năm $($row.Year): $([Math]::Round($sum, 2))%"
            }
        } catch {}
    }
}

if($empIssues.Count -gt 0) {
    Write-Host "      ⚠️  $($empIssues.Count) năm có tổng khác 100%:" -ForegroundColor Yellow
    $empIssues | Select-Object -First 5 | ForEach-Object { Write-Host "         $_" -ForegroundColor Red }
} else {
    Write-Host "      ✅ Tất cả các năm có tổng ~100%" -ForegroundColor Green
}

# 3. Check if Urban + Rural = Total Population
Write-Host "`n   3. Urban Population + Rural Population = Total Population?" -ForegroundColor Yellow
$popIssues = @()
foreach($row in $csv) {
    $total = $row.Population
    $urban = $row.'Urban Population'
    $rural = $row.'Rural Population'
    
    if($total -and $urban -and $rural -and 
       $total -ne "N/A" -and $urban -ne "N/A" -and $rural -ne "N/A" -and
       $urban -ne "0" -and $rural -ne "0") {
        try {
            $totalNum = [long]$total
            $urbanNum = [long]$urban
            $ruralNum = [long]$rural
            $sum = $urbanNum + $ruralNum
            
            # Allow 1% difference
            $diff = [Math]::Abs($totalNum - $sum)
            $diffPct = ($diff / $totalNum) * 100
            
            if($diffPct -gt 1) {
                $popIssues += "Năm $($row.Year): Total=$totalNum, Urban+Rural=$sum, Chênh lệch=$([Math]::Round($diffPct, 2))%"
            }
        } catch {}
    }
}

if($popIssues.Count -gt 0) {
    Write-Host "      ⚠️  $($popIssues.Count) năm có chênh lệch >1%:" -ForegroundColor Yellow
    $popIssues | Select-Object -First 5 | ForEach-Object { Write-Host "         $_" -ForegroundColor Red }
} else {
    Write-Host "      ✅ Tất cả các năm có tổng dân số khớp" -ForegroundColor Green
}

# 4. Check logical trends
Write-Host "`n   4. Kiểm tra xu hướng logic:" -ForegroundColor Yellow

# Life expectancy should generally increase
$lifeExpValues = $csv | Where-Object {$_.'Life Expectancy' -and $_.'Life Expectancy' -ne "N/A"} | 
    Sort-Object {[int]$_.Year} | 
    Select-Object -ExpandProperty 'Life Expectancy' | 
    ForEach-Object {[double]$_}

$decreases = 0
for($i = 1; $i -lt $lifeExpValues.Count; $i++) {
    if($lifeExpValues[$i] -lt $lifeExpValues[$i-1] - 5) { # More than 5 years decrease
        $decreases++
    }
}

if($decreases -gt 2) {
    Write-Host "      ⚠️  Tuổi thọ có $decreases lần giảm mạnh (>5 năm)" -ForegroundColor Yellow
} else {
    Write-Host "      ✅ Tuổi thọ có xu hướng tăng hợp lý" -ForegroundColor Green
}

Write-Host "`n╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                         TỔNG KẾT                                       ║" -ForegroundColor Green
Write-Host "╠════════════════════════════════════════════════════════════════════════╣" -ForegroundColor Green

$validationPct = [Math]::Round(($validValues / $totalChecks) * 100, 2)
Write-Host "║  📊 Tỷ lệ giá trị hợp lệ: $validationPct%" -NoNewline -ForegroundColor White
Write-Host (" " * (45 - "$validationPct".Length)) -NoNewline
Write-Host "║" -ForegroundColor Green

if($issues.Count -eq 0 -and $ageIssues.Count -eq 0 -and $empIssues.Count -eq 0 -and $popIssues.Count -eq 0) {
    Write-Host "║  ✅ Dataset có chất lượng cao, tất cả giá trị hợp lý                   ║" -ForegroundColor White
} elseif($issues.Count -lt 10) {
    Write-Host "║  ⚠️  Dataset có chất lượng tốt, một số giá trị cần xem xét             ║" -ForegroundColor Yellow
} else {
    Write-Host "║  ⚠️  Dataset có một số vấn đề cần khắc phục                            ║" -ForegroundColor Yellow
}

Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
