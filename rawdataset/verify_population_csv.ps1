# Comprehensive verification for vietnam_population.csv
$csv = Import-Csv "vietnam_population.csv" -Encoding UTF8

Write-Host "╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║       XÁC MINH DỮ LIỆU - VIETNAM_POPULATION.CSV                       ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`n📊 Thông tin cơ bản:" -ForegroundColor Cyan
Write-Host "   • Số hàng: $($csv.Count) (năm 1955-2025)" -ForegroundColor White
$columns = ($csv[0].PSObject.Properties.Name)
Write-Host "   • Số cột: $($columns.Count)" -ForegroundColor White

Write-Host "`n🔍 Kiểm tra chất lượng dữ liệu:" -ForegroundColor Cyan

$report = @()
foreach ($col in $columns) {
    if ($col -eq "Year") { continue }
    
    $values = $csv | ForEach-Object { $_.$col }
    $total = $values.Count
    
    $empty = ($values | Where-Object { $_ -eq "" -or $_ -eq $null }).Count
    $na = ($values | Where-Object { $_ -eq "N/A" }).Count
    $zeros = ($values | Where-Object { $_ -eq "0" -or $_ -eq "0.0" -or $_ -eq "0.00" }).Count
    $realData = ($values | Where-Object { 
        $_ -and $_ -ne "" -and $_ -ne "N/A" -and $_ -ne "null" -and 
        $_ -ne "0" -and $_ -ne "0.0" -and $_ -ne "0.00" 
    }).Count
    
    $fillRate = [math]::Round(($realData / $total) * 100, 1)
    
    $status = if ($fillRate -ge 90) { "✅ EXCELLENT" } 
              elseif ($fillRate -ge 50) { "⚠ GOOD" } 
              elseif ($fillRate -ge 25) { "🔶 PARTIAL" } 
              elseif ($fillRate -gt 0) { "❌ SPARSE" } 
              else { "🚫 EMPTY" }
    
    $report += [PSCustomObject]@{
        Column = $col
        Status = $status
        FillRate = $fillRate
        RealData = $realData
        Total = $total
        Empty = $empty
        NA = $na
        Zeros = $zeros
    }
}

# Show only problematic columns
Write-Host "`n⚠️ CÁC CỘT CẦN CHÚ Ý (<90%):" -ForegroundColor Yellow
$problematic = $report | Where-Object { $_.FillRate -lt 90 } | Sort-Object FillRate

if ($problematic.Count -eq 0) {
    Write-Host "   ✅ Không có cột nào cần chú ý! Tất cả đều ≥90%" -ForegroundColor Green
} else {
    foreach ($item in $problematic) {
        $color = if ($item.FillRate -ge 50) { "Yellow" } 
                elseif ($item.FillRate -gt 0) { "Red" } 
                else { "DarkRed" }
        
        Write-Host "   $($item.Status) $($item.Column)" -ForegroundColor $color
        Write-Host "      → $($item.RealData)/$($item.Total) ($($item.FillRate)%)" -ForegroundColor Gray
        if ($item.Empty -gt 0) { Write-Host "      → Empty: $($item.Empty)" -ForegroundColor DarkGray }
        if ($item.Zeros -gt 0) { Write-Host "      → Zeros: $($item.Zeros)" -ForegroundColor DarkGray }
    }
}

# Summary statistics
$excellent = ($report | Where-Object { $_.FillRate -ge 90 }).Count
$good = ($report | Where-Object { $_.FillRate -ge 50 -and $_.FillRate -lt 90 }).Count
$partial = ($report | Where-Object { $_.FillRate -ge 25 -and $_.FillRate -lt 50 }).Count
$sparse = ($report | Where-Object { $_.FillRate -gt 0 -and $_.FillRate -lt 25 }).Count
$empty = ($report | Where-Object { $_.FillRate -eq 0 }).Count

$avgFillRate = [math]::Round(($report.FillRate | Measure-Object -Average).Average, 1)

Write-Host "`n╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                           TỔNG KẾT                                     ║" -ForegroundColor Cyan
Write-Host "╠════════════════════════════════════════════════════════════════════════╣" -ForegroundColor Cyan
Write-Host "║  ✅ EXCELLENT (≥90%):      $excellent/$($columns.Count - 1) cột" -ForegroundColor Green -NoNewline
Write-Host (" " * (38 - "$excellent/$($columns.Count - 1)".Length)) -NoNewline
Write-Host "║" -ForegroundColor Cyan
Write-Host "║  ⚠ GOOD (50-89%):         $good cột" -ForegroundColor Yellow -NoNewline
Write-Host (" " * (38 - "$good".Length)) -NoNewline
Write-Host "║" -ForegroundColor Cyan
Write-Host "║  🔶 PARTIAL (25-49%):      $partial cột" -ForegroundColor DarkYellow -NoNewline
Write-Host (" " * (38 - "$partial".Length)) -NoNewline
Write-Host "║" -ForegroundColor Cyan
Write-Host "║  ❌ SPARSE (1-24%):        $sparse cột" -ForegroundColor Red -NoNewline
Write-Host (" " * (38 - "$sparse".Length)) -NoNewline
Write-Host "║" -ForegroundColor Cyan
Write-Host "║  🚫 EMPTY (0%):            $empty cột" -ForegroundColor DarkRed -NoNewline
Write-Host (" " * (38 - "$empty".Length)) -NoNewline
Write-Host "║" -ForegroundColor Cyan
Write-Host "╠════════════════════════════════════════════════════════════════════════╣" -ForegroundColor Cyan
Write-Host "║  📊 Tỷ lệ điền TB:         $avgFillRate%" -ForegroundColor White -NoNewline
Write-Host (" " * (38 - "$avgFillRate%".Length)) -NoNewline
Write-Host "║" -ForegroundColor Cyan
Write-Host "║  📁 File:                  vietnam_population.csv" -ForegroundColor White -NoNewline
Write-Host (" " * 7) -NoNewline
Write-Host "║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# Sample data preview
Write-Host "`n📋 DỮ LIỆU MẪU (2020-2024):" -ForegroundColor Cyan
$recent = $csv | Where-Object { [int]$_.Year -ge 2020 -and [int]$_.Year -le 2024 }

foreach ($row in $recent) {
    Write-Host "`n  ═══ NĂM $($row.Year) ═══" -ForegroundColor Yellow
    Write-Host "    • Dân số: $([math]::Round([double]$row.Population / 1000000, 2)) triệu" -ForegroundColor White
    Write-Host "    • Global Rank: #$($row.'Vietnam Global Rank')" -ForegroundColor Cyan
    Write-Host "    • ASEAN Rank: #$($row.'ASEAN Population Rank')" -ForegroundColor Cyan
    Write-Host "    • Median Age: $($row.'Median Age') tuổi" -ForegroundColor White
    Write-Host "    • GDP/người: `$$($row.'GDP per Capita (USD)')" -ForegroundColor Green
    Write-Host "    • HDI: $($row.HDI)" -ForegroundColor White
    Write-Host "    • Fertility Rate: $($row.'Fertility Rate')" -ForegroundColor White
    Write-Host "    • Life Expectancy: $($row.'Life Expectancy') năm" -ForegroundColor White
    Write-Host "    • Urban Pop: $([math]::Round([double]$row.'Urban Population' / 1000000, 2)) triệu" -ForegroundColor White
}

if ($excellent -eq ($columns.Count - 1)) {
    Write-Host "`n✅ HOÀN HẢO! Dataset đã đầy đủ 100%!" -ForegroundColor Green
} elseif ($excellent + $good -ge ($columns.Count - 1) * 0.9) {
    Write-Host "`n✅ Dataset ở trạng thái tốt! Sẵn sàng sử dụng." -ForegroundColor Green
} else {
    Write-Host "`n⚠️ Cần bổ sung thêm $($good + $partial + $sparse + $empty) cột" -ForegroundColor Yellow
}

# Export detailed report
$report | Export-Csv "vietnam_population_report.csv" -Encoding UTF8 -NoTypeInformation
Write-Host "`n📄 Báo cáo chi tiết: vietnam_population_report.csv" -ForegroundColor Gray
