# Fix all identified data issues
Write-Host "╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                    SỬA CÁC VẤN ĐỀ DỮ LIỆU                             ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$csv = Import-Csv "vietnam_population.csv" -Encoding UTF8

$fixCount = @{
    "Employment" = 0
    "Urban Population" = 0
    "CO2 Emissions" = 0
    "Death Rate" = 0
}

Write-Host "`n🔧 VẤN ĐỀ 1: SỬA EMPLOYMENT PERCENTAGES" -ForegroundColor Yellow
Write-Host "=" * 72 -ForegroundColor DarkGray

# First, let's check if the issue is Industry = Services (duplication)
Write-Host "`nKiểm tra xem Industry và Services có bị trùng không..." -ForegroundColor Cyan

$duplicateYears = @()
foreach($row in $csv) {
    $ind = $row.'Employment Industry (%)'
    $serv = $row.'Employment Services (%)'
    
    if($ind -and $serv -and $ind -ne "N/A" -and $serv -ne "N/A") {
        $indVal = [double]$ind
        $servVal = [double]$serv
        
        # Check if values are very similar (within 0.5%)
        if([Math]::Abs($indVal - $servVal) -lt 0.5) {
            $duplicateYears += $row.Year
        }
    }
}

Write-Host "   → Tìm thấy $($duplicateYears.Count) năm có Industry ≈ Services" -ForegroundColor Yellow

# Strategy: For years with sum != 100%, mark Services as N/A (need to find correct data)
foreach($row in $csv) {
    $year = [int]$row.Year
    $agri = $row.'Employment Agriculture (%)'
    $ind = $row.'Employment Industry (%)'
    $serv = $row.'Employment Services (%)'
    
    if($agri -and $ind -and $serv -and 
       $agri -ne "N/A" -and $ind -ne "N/A" -and $serv -ne "N/A") {
        
        $sum = [double]$agri + [double]$ind + [double]$serv
        
        # If total is significantly off (>2% difference)
        if([Math]::Abs($sum - 100) -gt 2) {
            # Mark Services as N/A since it appears to be duplicated or incorrect
            $row.'Employment Services (%)' = "N/A"
            $fixCount["Employment"]++
            Write-Host "   • Năm $year`: Services $serv% → N/A (Tổng cũ: $sum%)" -ForegroundColor Gray
        }
    }
}

Write-Host "`n✅ Đã sửa $($fixCount['Employment']) giá trị Employment Services" -ForegroundColor Green

Write-Host "`n🔧 VẤN ĐỀ 2: SỬA URBAN POPULATION" -ForegroundColor Yellow
Write-Host "=" * 72 -ForegroundColor DarkGray

foreach($row in $csv) {
    $year = [int]$row.Year
    $total = $row.Population
    $urbanPct = $row.'Urban Pop %'
    $urban = $row.'Urban Population'
    $rural = $row.'Rural Population'
    
    if($total -and $urbanPct -and $total -ne "N/A" -and $urbanPct -ne "N/A") {
        try {
            $totalNum = [long]$total
            $urbanPctNum = [double]$urbanPct
            $urbanNum = if($urban -and $urban -ne "N/A") {[long]$urban} else {0}
            $ruralNum = if($rural -and $rural -ne "N/A") {[long]$rural} else {0}
            
            # Calculate correct urban population
            $correctUrban = [long]($totalNum * $urbanPctNum / 100)
            
            # Check if current value is significantly different
            if($urbanNum -eq 0 -or [Math]::Abs($urbanNum - $correctUrban) / $totalNum -gt 0.01) {
                $oldUrban = $urbanNum
                $row.'Urban Population' = [string]$correctUrban
                
                # Recalculate rural
                $correctRural = $totalNum - $correctUrban
                $row.'Rural Population' = [string]$correctRural
                
                $fixCount["Urban Population"]++
                Write-Host "   • Năm $year`: Urban $('{0:N0}' -f $oldUrban) → $('{0:N0}' -f $correctUrban)" -ForegroundColor Gray
            }
        } catch {}
    }
}

Write-Host "`n✅ Đã tính lại $($fixCount['Urban Population']) giá trị Urban Population" -ForegroundColor Green

Write-Host "`n🔧 VẤN ĐỀ 3: SỬA GIÁ TRỊ NGOÀI KHOẢNG CHUẨN" -ForegroundColor Yellow
Write-Host "=" * 72 -ForegroundColor DarkGray

# 3A. Fix CO2 Emissions (seems like values are in different units)
Write-Host "`n3A. CO₂ Emissions per Capita:" -ForegroundColor Cyan

$co2Issues = @()
foreach($row in $csv) {
    $co2 = $row.'CO₂ Emissions per Capita (t)'
    
    if($co2 -and $co2 -ne "N/A") {
        try {
            $co2Val = [double]$co2
            
            # Values >50 are abnormal (likely in kg or different unit)
            if($co2Val -gt 50) {
                $co2Issues += [PSCustomObject]@{
                    Year = $row.Year
                    OldValue = $co2Val
                    NewValue = [Math]::Round($co2Val / 100, 2) # Divide by 100 if it seems to be in kg
                }
            }
        } catch {}
    }
}

if($co2Issues.Count -gt 0) {
    Write-Host "   → Phát hiện $($co2Issues.Count) giá trị >50 (có thể đơn vị sai)" -ForegroundColor Yellow
    Write-Host "   → Kiểm tra xem có phải đơn vị kg không..." -ForegroundColor Cyan
    
    # Show samples
    $co2Issues | Select-Object -First 5 | ForEach-Object {
        Write-Host "      Năm $($_.Year): $($_.OldValue)t → $($_.NewValue)t (÷100)" -ForegroundColor Gray
    }
    
    # Ask if this pattern makes sense - for now mark as N/A to be safe
    foreach($issue in $co2Issues) {
        $row = $csv | Where-Object {$_.Year -eq $issue.Year}
        if($row) {
            $row.'CO₂ Emissions per Capita (t)' = "N/A"
            $fixCount["CO2 Emissions"]++
        }
    }
    
    Write-Host "   → Đã đánh dấu N/A (cần xác minh đơn vị)" -ForegroundColor Yellow
}

Write-Host "`n3B. Death Rate (‰):" -ForegroundColor Cyan

$deathIssues = @()
foreach($row in $csv) {
    $death = $row.'Death Rate (‰)'
    
    if($death -and $death -ne "N/A") {
        try {
            $deathVal = [double]$death
            
            # Death rate >50‰ is abnormal (Vietnam typically 5-10‰)
            if($deathVal -gt 50) {
                $deathIssues += [PSCustomObject]@{
                    Year = $row.Year
                    Value = $deathVal
                }
                
                $row.'Death Rate (‰)' = "N/A"
                $fixCount["Death Rate"]++
            }
        } catch {}
    }
}

if($deathIssues.Count -gt 0) {
    Write-Host "   → Phát hiện $($deathIssues.Count) giá trị >50‰ (bất thường)" -ForegroundColor Yellow
    $deathIssues | ForEach-Object {
        Write-Host "      Năm $($_.Year): $($_.Value)‰ → N/A" -ForegroundColor Gray
    }
}

# Save fixed CSV
$csv | Export-Csv "vietnam_population.csv" -Encoding UTF8 -NoTypeInformation

Write-Host "`n╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                         KẾT QUẢ SỬA LỖI                                ║" -ForegroundColor Green
Write-Host "╠════════════════════════════════════════════════════════════════════════╣" -ForegroundColor Green
Write-Host "║  📊 Employment Services: $($fixCount['Employment']) giá trị → N/A" -NoNewline -ForegroundColor White
Write-Host (" " * (42 - "$($fixCount['Employment'])".Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "║  📊 Urban Population: $($fixCount['Urban Population']) giá trị tính lại" -NoNewline -ForegroundColor White
Write-Host (" " * (43 - "$($fixCount['Urban Population'])".Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "║  📊 CO₂ Emissions: $($fixCount['CO2 Emissions']) giá trị → N/A" -NoNewline -ForegroundColor White
Write-Host (" " * (47 - "$($fixCount['CO2 Emissions'])".Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "║  📊 Death Rate: $($fixCount['Death Rate']) giá trị → N/A" -NoNewline -ForegroundColor White
Write-Host (" " * (50 - "$($fixCount['Death Rate'])".Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green

$totalFixed = ($fixCount.Values | Measure-Object -Sum).Sum
Write-Host "`n✅ Tổng cộng: $totalFixed giá trị đã được sửa" -ForegroundColor Green
Write-Host "📄 File đã cập nhật: vietnam_population.csv" -ForegroundColor Gray

# Verify fixes
Write-Host "`n🔍 XÁC MINH SAU KHI SỬA:" -ForegroundColor Cyan

$empStillBad = 0
$popStillBad = 0

foreach($row in $csv) {
    # Check employment
    $agri = $row.'Employment Agriculture (%)'
    $ind = $row.'Employment Industry (%)'
    $serv = $row.'Employment Services (%)'
    
    if($agri -and $ind -and $serv -and 
       $agri -ne "N/A" -and $ind -ne "N/A" -and $serv -ne "N/A") {
        $sum = [double]$agri + [double]$ind + [double]$serv
        if([Math]::Abs($sum - 100) -gt 2) {
            $empStillBad++
        }
    }
    
    # Check population
    $total = $row.Population
    $urban = $row.'Urban Population'
    $rural = $row.'Rural Population'
    
    if($total -and $urban -and $rural -and 
       $total -ne "N/A" -and $urban -ne "N/A" -and $rural -ne "N/A" -and
       $urban -ne "0" -and $rural -ne "0") {
        try {
            $totalNum = [long]$total
            $sum = [long]$urban + [long]$rural
            $diffPct = ([Math]::Abs($totalNum - $sum) / $totalNum) * 100
            if($diffPct -gt 1) {
                $popStillBad++
            }
        } catch {}
    }
}

Write-Host "   • Employment còn $empStillBad năm có vấn đề" -ForegroundColor $(if($empStillBad -eq 0){'Green'}else{'Yellow'})
Write-Host "   • Urban+Rural còn $popStillBad năm có vấn đề" -ForegroundColor $(if($popStillBad -eq 0){'Green'}else{'Yellow'})

if($empStillBad -eq 0 -and $popStillBad -eq 0) {
    Write-Host "`n🎉 Tất cả vấn đề đã được khắc phục!" -ForegroundColor Green
} else {
    Write-Host "`n⚠️  Một số vấn đề cần kiểm tra thêm" -ForegroundColor Yellow
}
