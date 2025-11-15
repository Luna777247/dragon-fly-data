# Comprehensive validation summary report
Write-Host "╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
Write-Host "║                BÁO CÁO XÁC MINH KHOẢNG GIÁ TRỊ                         ║" -ForegroundColor Red
Write-Host "║                    PHÁT HIỆN VẤN ĐỀ NGHIÊM TRỌNG                       ║" -ForegroundColor Red
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Red

$csv = Import-Csv "vietnam_population.csv" -Encoding UTF8

Write-Host "`n🔍 VẤN ĐỀ 1: EMPLOYMENT PERCENTAGES (NGHIÊM TRỌNG)" -ForegroundColor Red
Write-Host "=" * 72 -ForegroundColor DarkGray

$empIssues = @()
foreach($row in $csv) {
    $year = [int]$row.Year
    $agri = $row.'Employment Agriculture (%)'
    $ind = $row.'Employment Industry (%)'
    $serv = $row.'Employment Services (%)'
    
    if($agri -and $ind -and $serv -and 
       $agri -ne "N/A" -and $ind -ne "N/A" -and $serv -ne "N/A") {
        $sum = [double]$agri + [double]$ind + [double]$serv
        $diff = [Math]::Abs($sum - 100)
        
        if($diff -gt 2) {
            $empIssues += [PSCustomObject]@{
                Year = $year
                Agriculture = [double]$agri
                Industry = [double]$ind
                Services = [double]$serv
                Total = [Math]::Round($sum, 2)
                Difference = [Math]::Round($diff, 2)
            }
        }
    }
}

if($empIssues.Count -gt 0) {
    Write-Host "`n❌ Phát hiện $($empIssues.Count) năm có tổng Employment ≠ 100%" -ForegroundColor Red
    Write-Host "`nChi tiết:" -ForegroundColor Yellow
    
    # Show problematic years
    $empIssues | Sort-Object Year | ForEach-Object {
        $color = if($_.Total -lt 80) {"Red"} elseif($_.Total -lt 95) {"Yellow"} else {"DarkYellow"}
        Write-Host ("   Năm {0}: Agri={1}% + Ind={2}% + Serv={3}% = {4}% (Chênh: {5}%)" -f `
            $_.Year, $_.Agriculture, $_.Industry, $_.Services, $_.Total, $_.Difference) -ForegroundColor $color
    }
    
    # Analyze pattern
    $lowYears = $empIssues | Where-Object {$_.Total -lt 80}
    $highYears = $empIssues | Where-Object {$_.Total -gt 102}
    
    Write-Host "`n📊 Phân tích:" -ForegroundColor Cyan
    Write-Host "   • Số năm tổng <80%: $($lowYears.Count)" -ForegroundColor Red
    Write-Host "   • Số năm tổng >102%: $($highYears.Count)" -ForegroundColor Yellow
    
    if($lowYears.Count -gt 0) {
        $firstYear = $lowYears[0].Year
        $lastYear = $lowYears[-1].Year
        Write-Host "`n   ⚠️  Giai đoạn $firstYear-$lastYear`: Tổng quá thấp (57-81%)" -ForegroundColor Red
        Write-Host "       Nguyên nhân có thể:" -ForegroundColor Yellow
        Write-Host "       - Industry và Services có giá trị trùng nhau" -ForegroundColor Gray
        Write-Host "       - Thiếu một phần dữ liệu Services" -ForegroundColor Gray
        Write-Host "       - Lỗi nhập liệu trong file gốc" -ForegroundColor Gray
    }
} else {
    Write-Host "✅ Tất cả các năm có tổng Employment = 100%" -ForegroundColor Green
}

Write-Host "`n" + ("=" * 72) -ForegroundColor DarkGray
Write-Host "`n🔍 VẤN ĐỀ 2: URBAN + RURAL POPULATION" -ForegroundColor Yellow
Write-Host "=" * 72 -ForegroundColor DarkGray

$popIssues = @()
foreach($row in $csv) {
    $year = [int]$row.Year
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
            
            $diff = [Math]::Abs($totalNum - $sum)
            $diffPct = ($diff / $totalNum) * 100
            
            if($diffPct -gt 1) {
                $popIssues += [PSCustomObject]@{
                    Year = $year
                    Total = $totalNum
                    Urban = $urbanNum
                    Rural = $ruralNum
                    Sum = $sum
                    Difference = $diff
                    DiffPercent = [Math]::Round($diffPct, 2)
                }
            }
        } catch {}
    }
}

if($popIssues.Count -gt 0) {
    Write-Host "`n⚠️  Phát hiện $($popIssues.Count) năm có Urban + Rural ≠ Total" -ForegroundColor Yellow
    Write-Host "`nMẫu các năm có vấn đề:" -ForegroundColor Yellow
    $popIssues | Select-Object -First 10 | ForEach-Object {
        Write-Host ("   Năm {0}: Total={1:N0}, Urban+Rural={2:N0}, Chênh={3}%" -f `
            $_.Year, $_.Total, $_.Sum, $_.DiffPercent) -ForegroundColor Red
    }
    
    Write-Host "`n   💡 Gợi ý: Có thể cần tính lại Urban Population từ Total × Urban %" -ForegroundColor Cyan
} else {
    Write-Host "✅ Tất cả các năm có Urban + Rural = Total" -ForegroundColor Green
}

Write-Host "`n" + ("=" * 72) -ForegroundColor DarkGray
Write-Host "`n🔍 VẤN ĐỀ 3: CÁC GIÁ TRỊ NGOÀI KHOẢNG CHUẨN" -ForegroundColor Yellow
Write-Host "=" * 72 -ForegroundColor DarkGray

# Check report file
if(Test-Path "value_range_validation_report.csv") {
    $rangeIssues = Import-Csv "value_range_validation_report.csv" -Encoding UTF8
    
    $byColumn = $rangeIssues | Group-Object -Property Column
    
    Write-Host "`n⚠️  Phát hiện $($rangeIssues.Count) giá trị ngoài khoảng chuẩn trong $($byColumn.Count) cột" -ForegroundColor Yellow
    
    foreach($group in $byColumn) {
        Write-Host "`n   📌 $($group.Name) ($($group.Count) giá trị):" -ForegroundColor Cyan
        $expected = $group.Group[0].Expected
        Write-Host "      Khoảng chuẩn: $expected" -ForegroundColor Gray
        
        $samples = $group.Group | Select-Object -First 5
        foreach($sample in $samples) {
            Write-Host "      • Năm $($sample.Year): $($sample.Value)" -ForegroundColor Red
        }
        
        if($group.Count -gt 5) {
            Write-Host "      ... và $($group.Count - 5) giá trị khác" -ForegroundColor DarkGray
        }
    }
}

Write-Host "`n╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
Write-Host "║                         KHUYẾN NGHỊ                                    ║" -ForegroundColor Red
Write-Host "╠════════════════════════════════════════════════════════════════════════╣" -ForegroundColor Red

if($empIssues.Count -gt 0) {
    Write-Host "║  🔴 NGHIÊM TRỌNG: Employment data có vấn đề trong $($empIssues.Count) năm                ║" -ForegroundColor White
    Write-Host "║     → Cần kiểm tra và sửa lại dữ liệu trong file gốc                  ║" -ForegroundColor White
    Write-Host "║     → Các năm 2000-2020 có dữ liệu không chính xác                    ║" -ForegroundColor White
    Write-Host "║                                                                        ║" -ForegroundColor Red
}

if($popIssues.Count -gt 0) {
    Write-Host "║  ⚠️  Urban/Rural Population chênh lệch trong $($popIssues.Count) năm                    ║" -ForegroundColor White
    Write-Host "║     → Nên tính lại từ công thức: Urban = Total × Urban %              ║" -ForegroundColor White
    Write-Host "║                                                                        ║" -ForegroundColor Red
}

Write-Host "║  📊 Tổng quan:                                                         ║" -ForegroundColor White
Write-Host "║     • $(if($empIssues.Count -eq 0){'✅'}else{'❌'}) Employment percentages" -NoNewline -ForegroundColor White
Write-Host (" " * (44 - (if($empIssues.Count -eq 0){'✅'}else{'❌'}).Length)) -NoNewline
Write-Host "║" -ForegroundColor Red
Write-Host "║     • $(if($popIssues.Count -eq 0){'✅'}else{'⚠️ '}) Urban + Rural = Total" -NoNewline -ForegroundColor White
Write-Host (" " * (44 - (if($popIssues.Count -eq 0){'✅'}else{'⚠️ '}).Length)) -NoNewline
Write-Host "║" -ForegroundColor Red
Write-Host "║     • $(if((Test-Path 'value_range_validation_report.csv')){'⚠️ '}else{'✅'}) Value ranges" -NoNewline -ForegroundColor White
Write-Host (" " * (44 - (if((Test-Path 'value_range_validation_report.csv')){'⚠️ '}else{'✅'}).Length)) -NoNewline
Write-Host "║" -ForegroundColor Red
Write-Host "║                                                                        ║" -ForegroundColor Red

if($empIssues.Count -gt 20 -or ($empIssues | Where-Object {$_.Total -lt 70}).Count -gt 0) {
    Write-Host "║  ⛔ Dataset CẦN SỬA GẤP trước khi sử dụng!                             ║" -ForegroundColor White
} elseif($empIssues.Count -gt 0 -or $popIssues.Count -gt 0) {
    Write-Host "║  ⚠️  Dataset có một số vấn đề nên được xem xét                        ║" -ForegroundColor White
} else {
    Write-Host "║  ✅ Dataset có chất lượng tốt, sẵn sàng sử dụng                        ║" -ForegroundColor White
}

Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Red

# Export employment issues
if($empIssues.Count -gt 0) {
    $empIssues | Export-Csv "employment_issues.csv" -Encoding UTF8 -NoTypeInformation
    Write-Host "`n📄 Chi tiết Employment issues: employment_issues.csv" -ForegroundColor Gray
}

if($popIssues.Count -gt 0) {
    $popIssues | Export-Csv "population_sum_issues.csv" -Encoding UTF8 -NoTypeInformation
    Write-Host "📄 Chi tiết Population issues: population_sum_issues.csv" -ForegroundColor Gray
}
