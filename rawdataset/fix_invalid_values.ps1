# Fix invalid values in vietnam_population.csv
Write-Host "╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║          SỬA CÁC GIÁ TRỊ KHÔNG HỢP LỆ - VIETNAM_POPULATION.CSV         ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$csv = Import-Csv "vietnam_population.csv" -Encoding UTF8

Write-Host "`n🔧 Đang sửa các giá trị bất thường..." -ForegroundColor Yellow

$fixes = @{
    "GDP Growth Rate (%)" = 0
    "Poverty Rate (%)" = 0
    "HDI" = 0
}

foreach ($row in $csv) {
    $year = [int]$row.Year
    
    # Fix GDP Growth Rate - should be between -10% and 20%
    $gdpGrowth = $row.'GDP Growth Rate (%)'
    if ($gdpGrowth -and $gdpGrowth -ne "N/A") {
        try {
            $value = [double]$gdpGrowth
            if ($value -gt 20 -or $value -lt -10) {
                Write-Host "   Năm $year`: GDP Growth $value% → N/A" -ForegroundColor Red
                $row.'GDP Growth Rate (%)' = "N/A"
                $fixes["GDP Growth Rate (%)"]++
            }
        } catch {}
    }
    
    # Fix Poverty Rate - should be 0-100%
    $poverty = $row.'Poverty Rate (%)'
    if ($poverty -and $poverty -ne "N/A") {
        try {
            $value = [double]$poverty
            if ($value -gt 100) {
                Write-Host "   Năm $year`: Poverty Rate $value% → N/A" -ForegroundColor Red
                $row.'Poverty Rate (%)' = "N/A"
                $fixes["Poverty Rate (%)"]++
            }
        } catch {}
    }
    
    # Fix HDI - should be 0-1
    # Values > 1 seem to be HDI Growth Rate %, not HDI itself
    $hdi = $row.HDI
    if ($hdi -and $hdi -ne "N/A") {
        try {
            $value = [double]$hdi
            if ($value -gt 1) {
                Write-Host "   Năm $year`: HDI $value → N/A (có thể là HDI Growth Rate %)" -ForegroundColor Red
                $row.HDI = "N/A"
                $fixes["HDI"]++
            }
        } catch {}
    }
}

# Save fixed CSV
$csv | Export-Csv "vietnam_population.csv" -Encoding UTF8 -NoTypeInformation

Write-Host "`n╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                        KẾT QUẢ SỬA CHỮA                                ║" -ForegroundColor Green
Write-Host "╠════════════════════════════════════════════════════════════════════════╣" -ForegroundColor Green
Write-Host "║  • GDP Growth Rate (%): $($fixes['GDP Growth Rate (%)']) giá trị → N/A" -ForegroundColor White -NoNewline
Write-Host (" " * (36 - "$($fixes['GDP Growth Rate (%)'])".Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "║  • Poverty Rate (%): $($fixes['Poverty Rate (%)']) giá trị → N/A" -ForegroundColor White -NoNewline
Write-Host (" " * (40 - "$($fixes['Poverty Rate (%)'])".Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "║  • HDI: $($fixes['HDI']) giá trị → N/A" -ForegroundColor White -NoNewline
Write-Host (" " * (51 - "$($fixes['HDI'])".Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "╠════════════════════════════════════════════════════════════════════════╣" -ForegroundColor Green

$totalFixed = ($fixes.Values | Measure-Object -Sum).Sum
Write-Host "║  📊 Tổng: $totalFixed giá trị đã sửa" -ForegroundColor White -NoNewline
Write-Host (" " * (46 - "$totalFixed".Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`n✅ File đã được lưu: vietnam_population.csv" -ForegroundColor Green
Write-Host "⚠️ LƯU Ý: Dữ liệu trong file gốc vietnam_advance.csv có vấn đề:" -ForegroundColor Yellow
Write-Host "   • GDP Growth Rate (%) từ 2000-2024 có giá trị 1298-20170 (không hợp lệ)" -ForegroundColor Gray
Write-Host "   • Poverty Rate (%) từ 1955-1980 có giá trị 101-151 (không hợp lệ)" -ForegroundColor Gray
Write-Host "   • HDI từ 2000-2024 có giá trị >1 (có thể là HDI Growth Rate %)" -ForegroundColor Gray
Write-Host "`n💡 Khuyến nghị: Cần kiểm tra và sửa file gốc vietnam_advance.csv" -ForegroundColor Cyan
