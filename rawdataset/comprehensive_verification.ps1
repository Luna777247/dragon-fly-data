# Comprehensive verification report
Write-Host "╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║              BÁO CÁO XÁC MINH CHI TIẾT TẤT CẢ CÁC CỘT                 ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$csv = Import-Csv "src\data\vietnam_advance.csv" -Encoding UTF8
$allColumns = $csv[0].PSObject.Properties.Name

Write-Host "`n📊 Dataset Information:" -ForegroundColor Yellow
Write-Host "   Rows: $($csv.Count) (Years: $($csv[0].Year) - $($csv[-1].Year))" -ForegroundColor White
Write-Host "   Columns: $($allColumns.Count)" -ForegroundColor White

Write-Host "`n🔍 Đang phân tích chi tiết từng cột..." -ForegroundColor Yellow

$report = @()

foreach ($col in $allColumns) {
    $values = $csv | ForEach-Object { $_.$col }
    
    $totalRows = $values.Count
    $emptyOrNull = ($values | Where-Object { -not $_ -or $_ -eq "" -or $_ -eq "N/A" -or $_ -eq "null" }).Count
    $zeroValues = ($values | Where-Object { $_ -eq "0" -or $_ -eq "0.0" -or $_ -eq "0.00" }).Count
    $realData = $totalRows - $emptyOrNull - $zeroValues
    
    $fillRate = if ($totalRows -gt 0) { [math]::Round(($realData / $totalRows) * 100, 1) } else { 0 }
    
    # Determine status
    $status = if ($realData -eq 0) { 
        "EMPTY" 
    } elseif ($fillRate -ge 90) { 
        "EXCELLENT" 
    } elseif ($fillRate -ge 50) { 
        "GOOD" 
    } elseif ($fillRate -ge 25) { 
        "PARTIAL" 
    } else { 
        "SPARSE" 
    }
    
    $report += [PSCustomObject]@{
        Column = $col
        TotalRows = $totalRows
        RealData = $realData
        Zeros = $zeroValues
        EmptyNA = $emptyOrNull
        FillRate = $fillRate
        Status = $status
    }
}

# Group by status
$excellent = $report | Where-Object { $_.Status -eq "EXCELLENT" }
$good = $report | Where-Object { $_.Status -eq "GOOD" }
$partial = $report | Where-Object { $_.Status -eq "PARTIAL" }
$sparse = $report | Where-Object { $_.Status -eq "SPARSE" }
$empty = $report | Where-Object { $_.Status -eq "EMPTY" }

Write-Host "`n╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                      TỔNG KẾT THEO TRẠNG THÁI                          ║" -ForegroundColor Green
Write-Host "╠════════════════════════════════════════════════════════════════════════╣" -ForegroundColor Green
Write-Host "║  ⭐ EXCELLENT (≥90%):             $($excellent.Count) cột" -ForegroundColor Green -NoNewline
Write-Host (" " * (41 - $excellent.Count.ToString().Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "║  ✅ GOOD (50-89%):                $($good.Count) cột" -ForegroundColor Yellow -NoNewline
Write-Host (" " * (41 - $good.Count.ToString().Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "║  ⚠  PARTIAL (25-49%):             $($partial.Count) cột" -ForegroundColor Yellow -NoNewline
Write-Host (" " * (41 - $partial.Count.ToString().Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "║  ⚠  SPARSE (<25%):                $($sparse.Count) cột" -ForegroundColor Red -NoNewline
Write-Host (" " * (41 - $sparse.Count.ToString().Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "║  ❌ EMPTY (0%):                   $($empty.Count) cột" -ForegroundColor Red -NoNewline
Write-Host (" " * (41 - $empty.Count.ToString().Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green

$avgFillRate = [math]::Round(($report | Measure-Object -Property FillRate -Average).Average, 1)
Write-Host "`n📊 Tỷ lệ điền dữ liệu trung bình: $avgFillRate%" -ForegroundColor Cyan

# Show columns by status
if ($excellent.Count -gt 0) {
    Write-Host "`n⭐ CÁC CỘT EXCELLENT (≥90% dữ liệu thực):" -ForegroundColor Green
    Write-Host "   Tổng: $($excellent.Count) cột" -ForegroundColor White
    $excellent | Select-Object -First 10 | ForEach-Object {
        Write-Host "   ✓ $($_.Column): $($_.FillRate)% ($($_.RealData)/$($_.TotalRows))" -ForegroundColor Gray
    }
    if ($excellent.Count -gt 10) {
        Write-Host "   ... và $($excellent.Count - 10) cột khác" -ForegroundColor DarkGray
    }
}

if ($good.Count -gt 0) {
    Write-Host "`n✅ CÁC CỘT GOOD (50-89% dữ liệu thực):" -ForegroundColor Yellow
    $good | ForEach-Object {
        Write-Host "   • $($_.Column): $($_.FillRate)% ($($_.RealData)/$($_.TotalRows))" -ForegroundColor White
        Write-Host "      → Empty/NA: $($_.EmptyNA), Zeros: $($_.Zeros)" -ForegroundColor Gray
    }
}

if ($partial.Count -gt 0) {
    Write-Host "`n⚠ CÁC CỘT PARTIAL (25-49% dữ liệu thực):" -ForegroundColor Yellow
    $partial | ForEach-Object {
        Write-Host "   • $($_.Column): $($_.FillRate)% ($($_.RealData)/$($_.TotalRows))" -ForegroundColor White
        Write-Host "      → Empty/NA: $($_.EmptyNA), Zeros: $($_.Zeros)" -ForegroundColor Gray
    }
}

if ($sparse.Count -gt 0) {
    Write-Host "`n⚠ CÁC CỘT SPARSE (<25% dữ liệu thực):" -ForegroundColor Red
    $sparse | ForEach-Object {
        Write-Host "   • $($_.Column): $($_.FillRate)% ($($_.RealData)/$($_.TotalRows))" -ForegroundColor White
        Write-Host "      → Empty/NA: $($_.EmptyNA), Zeros: $($_.Zeros)" -ForegroundColor Gray
        
        # Show which years have data
        $yearsWithData = @()
        for ($i = 0; $i -lt $csv.Count; $i++) {
            $val = $csv[$i].$($_.Column)
            if ($val -and $val -ne "" -and $val -ne "0" -and $val -ne "0.0" -and $val -ne "N/A") {
                $yearsWithData += $csv[$i].Year
            }
        }
        if ($yearsWithData.Count -gt 0 -and $yearsWithData.Count -le 20) {
            Write-Host "      → Có data cho năm: $($yearsWithData -join ', ')" -ForegroundColor Cyan
        }
    }
}

if ($empty.Count -gt 0) {
    Write-Host "`n❌ CÁC CỘT EMPTY (không có dữ liệu thực):" -ForegroundColor Red
    $empty | ForEach-Object {
        Write-Host "   ✗ $($_.Column)" -ForegroundColor Red
        Write-Host "      → Empty/NA: $($_.EmptyNA), Zeros: $($_.Zeros)" -ForegroundColor Gray
    }
}

# Export detailed report to CSV
$report | Export-Csv "column_verification_report.csv" -Encoding UTF8 -NoTypeInformation
Write-Host "`n💾 Đã xuất báo cáo chi tiết: column_verification_report.csv" -ForegroundColor Green

# Show recommendation
Write-Host "`n╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                            KHUYẾN NGHỊ                                 ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$usableColumns = $excellent.Count + $good.Count
$usableRate = [math]::Round(($usableColumns / $allColumns.Count) * 100, 1)

Write-Host "`n✅ Dataset sẵn sàng sử dụng!" -ForegroundColor Green
Write-Host "   • $usableColumns/$($allColumns.Count) cột có ≥50% dữ liệu thực ($usableRate%)" -ForegroundColor White
Write-Host "   • Tỷ lệ điền trung bình: $avgFillRate%" -ForegroundColor White

if ($sparse.Count -gt 0 -or $empty.Count -gt 0) {
    Write-Host "`n⚠ Lưu ý:" -ForegroundColor Yellow
    Write-Host "   • $($sparse.Count + $empty.Count) cột có <25% dữ liệu" -ForegroundColor Gray
    Write-Host "   • Nên loại bỏ hoặc bổ sung dữ liệu cho các cột này" -ForegroundColor Gray
}

Write-Host "`n✅ Xác minh hoàn tất!" -ForegroundColor Green
