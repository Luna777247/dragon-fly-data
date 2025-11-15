# Fix invalid data in vietnam_advance.csv
Write-Host "╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║           SỬA LỖI DỮ LIỆU - VIETNAM_ADVANCE.CSV                        ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$csv = Import-Csv "src\data\vietnam_advance.csv" -Encoding UTF8

Write-Host "`n🔍 Kiểm tra các cột bị lỗi..." -ForegroundColor Yellow

# 1. Check GDP Growth Rate
Write-Host "`n1. GDP Growth Rate (%):" -ForegroundColor Cyan
$badGDP = $csv | Where-Object { 
    $_.'GDP Growth Rate (%)' -and $_.'GDP Growth Rate (%)' -ne 'N/A' -and $_.'GDP Growth Rate (%)' -ne '0.0'
} | Where-Object {
    try {
        [double]$_.'GDP Growth Rate (%)' -gt 20
    } catch { $false }
}
Write-Host "   → Tìm thấy $($badGDP.Count) giá trị >20%" -ForegroundColor Yellow
$badGDP | Select-Object -First 5 | ForEach-Object {
    Write-Host "      Năm $($_.Year): $($_.'GDP Growth Rate (%)')" -ForegroundColor Gray
}

# 2. Check Poverty Rate
Write-Host "`n2. Poverty Rate (%):" -ForegroundColor Cyan
$badPoverty = $csv | Where-Object { 
    $_.'Poverty Rate (%)' -and $_.'Poverty Rate (%)' -ne 'N/A'
} | Where-Object {
    try {
        [double]$_.'Poverty Rate (%)' -gt 100
    } catch { $false }
}
Write-Host "   → Tìm thấy $($badPoverty.Count) giá trị >100%" -ForegroundColor Yellow
$badPoverty | Select-Object -First 5 | ForEach-Object {
    Write-Host "      Năm $($_.Year): $($_.'Poverty Rate (%)')" -ForegroundColor Gray
}

# 3. Check HDI
Write-Host "`n3. HDI:" -ForegroundColor Cyan
$badHDI = $csv | Where-Object { 
    $_.HDI -and $_.HDI -ne 'N/A'
} | Where-Object {
    try {
        [double]$_.HDI -gt 1
    } catch { $false }
}
Write-Host "   → Tìm thấy $($badHDI.Count) giá trị >1" -ForegroundColor Yellow
$badHDI | Select-Object -First 5 | ForEach-Object {
    Write-Host "      Năm $($_.Year): $($_.HDI)" -ForegroundColor Gray
}

Write-Host "`n🔧 Đang sửa lỗi..." -ForegroundColor Yellow

$fixCount = @{
    "GDP Growth Rate" = 0
    "Poverty Rate" = 0
    "HDI" = 0
}

foreach ($row in $csv) {
    # Fix GDP Growth Rate
    $gdpGrowth = $row.'GDP Growth Rate (%)'
    if ($gdpGrowth -and $gdpGrowth -ne "N/A" -and $gdpGrowth -ne "0.0") {
        try {
            $value = [double]$gdpGrowth
            if ($value -gt 20 -or $value -lt -10) {
                $row.'GDP Growth Rate (%)' = "N/A"
                $fixCount["GDP Growth Rate"]++
            }
        } catch {}
    }
    
    # Fix Poverty Rate
    $poverty = $row.'Poverty Rate (%)'
    if ($poverty -and $poverty -ne "N/A") {
        try {
            $value = [double]$poverty
            if ($value -gt 100) {
                $row.'Poverty Rate (%)' = "N/A"
                $fixCount["Poverty Rate"]++
            }
        } catch {}
    }
    
    # Fix HDI - values >1 are incorrect (HDI range is 0-1)
    $hdi = $row.HDI
    if ($hdi -and $hdi -ne "N/A") {
        try {
            $value = [double]$hdi
            if ($value -gt 1) {
                $row.HDI = "N/A"
                $fixCount["HDI"]++
            }
        } catch {}
    }
}

# Backup original file
$backupFile = "src\data\vietnam_advance_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
Copy-Item "src\data\vietnam_advance.csv" $backupFile
Write-Host "`n💾 Đã backup file gốc: $backupFile" -ForegroundColor Gray

# Save fixed CSV
$csv | Export-Csv "src\data\vietnam_advance.csv" -Encoding UTF8 -NoTypeInformation

Write-Host "`n╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                      KẾT QUẢ SỬA LỖI                                   ║" -ForegroundColor Green
Write-Host "╠════════════════════════════════════════════════════════════════════════╣" -ForegroundColor Green
Write-Host "║  • GDP Growth Rate (%): $($fixCount['GDP Growth Rate']) giá trị → N/A" -ForegroundColor White -NoNewline
Write-Host (" " * (36 - "$($fixCount['GDP Growth Rate'])".Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "║  • Poverty Rate (%): $($fixCount['Poverty Rate']) giá trị → N/A" -ForegroundColor White -NoNewline
Write-Host (" " * (40 - "$($fixCount['Poverty Rate'])".Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "║  • HDI: $($fixCount['HDI']) giá trị → N/A" -ForegroundColor White -NoNewline
Write-Host (" " * (51 - "$($fixCount['HDI'])".Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "╠════════════════════════════════════════════════════════════════════════╣" -ForegroundColor Green

$totalFixed = ($fixCount.Values | Measure-Object -Sum).Sum
Write-Host "║  📊 Tổng: $totalFixed giá trị đã sửa" -ForegroundColor White -NoNewline
Write-Host (" " * (46 - "$totalFixed".Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`n✅ File gốc đã được sửa: src\data\vietnam_advance.csv" -ForegroundColor Green
Write-Host "📦 Backup: $backupFile" -ForegroundColor Gray

Write-Host "`n💡 Bước tiếp theo:" -ForegroundColor Cyan
Write-Host "   Tạo lại file vietnam_population.csv từ file gốc đã sửa" -ForegroundColor White
