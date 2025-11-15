# Fill empty cells with N/A for clarity
Write-Host "╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║           KIỂM TRA VÀ ĐIỀN GIÁ TRỊ NULL CHO CÁC Ô TRỐNG              ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$csv = Import-Csv "src\data\vietnam_advance.csv" -Encoding UTF8
$allColumns = $csv[0].PSObject.Properties.Name

Write-Host "`n📊 Đang kiểm tra từng cột..." -ForegroundColor Yellow

$stats = @()
$totalEmptyCells = 0

foreach ($col in $allColumns) {
    if ($col -eq "Year") { continue }  # Skip Year column
    
    $emptyCells = 0
    $zeroCells = 0
    $filledCells = 0
    
    foreach ($row in $csv) {
        $value = $row.$col
        
        if (-not $value -or $value -eq "") {
            $row.$col = "N/A"
            $emptyCells++
            $totalEmptyCells++
        } elseif ($value -eq "0" -or $value -eq "0.0" -or $value -eq "0.00") {
            $zeroCells++
        } else {
            $filledCells++
        }
    }
    
    $stats += [PSCustomObject]@{
        Column = $col
        Empty = $emptyCells
        Zero = $zeroCells
        Filled = $filledCells
        Total = $csv.Count
    }
}

# Save updated CSV
$csv | Export-Csv "src\data\vietnam_advance.csv" -Encoding UTF8 -NoTypeInformation

Write-Host "`n✓ Đã điền 'N/A' cho $totalEmptyCells ô trống" -ForegroundColor Green

Write-Host "`n╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                      THỐNG KÊ CHI TIẾT TỪNG CỘT                        ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green

# Show columns with many empty cells
$columnsWithMissingData = $stats | Where-Object { $_.Empty -gt 0 } | Sort-Object -Property Empty -Descending

if ($columnsWithMissingData.Count -gt 0) {
    Write-Host "`n⚠ CÁC CỘT CÓ DỮ LIỆU THIẾU (đã điền N/A):" -ForegroundColor Yellow
    Write-Host "`nColumn                                            Empty    Zero   Filled   Total" -ForegroundColor White
    Write-Host "------                                            -----    ----   ------   -----" -ForegroundColor White
    
    foreach ($stat in $columnsWithMissingData) {
        $fillRate = [math]::Round(($stat.Filled / $stat.Total) * 100, 1)
        $color = if ($fillRate -ge 50) { "Green" } elseif ($fillRate -ge 25) { "Yellow" } else { "Red" }
        
        $colName = $stat.Column
        if ($colName.Length -gt 45) { $colName = $colName.Substring(0, 42) + "..." }
        
        Write-Host ("{0,-45} {1,5}    {2,4}   {3,6}   {4,5}  ({5}%)" -f `
            $colName, $stat.Empty, $stat.Zero, $stat.Filled, $stat.Total, $fillRate) -ForegroundColor $color
    }
}

# Show fully complete columns
$completeColumns = $stats | Where-Object { $_.Empty -eq 0 -and $_.Filled -gt 0 }
Write-Host "`n✅ CÁC CỘT ĐẦY ĐỦ (không có N/A):" -ForegroundColor Green
Write-Host "   Số lượng: $($completeColumns.Count) cột" -ForegroundColor White

# Summary by data completeness
$veryComplete = ($stats | Where-Object { $_.Filled -ge ($_.Total * 0.9) }).Count
$mostlyComplete = ($stats | Where-Object { $_.Filled -ge ($_.Total * 0.5) -and $_.Filled -lt ($_.Total * 0.9) }).Count
$partialData = ($stats | Where-Object { $_.Filled -gt 0 -and $_.Filled -lt ($_.Total * 0.5) }).Count
$noData = ($stats | Where-Object { $_.Filled -eq 0 }).Count

Write-Host "`n╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                    TỔNG KẾT THEO MỨC ĐỘ ĐẦY ĐỦ                       ║" -ForegroundColor Cyan
Write-Host "╠════════════════════════════════════════════════════════════════════════╣" -ForegroundColor Cyan
Write-Host "║  Rất đầy đủ (≥90% data):         $veryComplete cột" -ForegroundColor Green -NoNewline
Write-Host (" " * (41 - $veryComplete.ToString().Length)) -NoNewline
Write-Host "║" -ForegroundColor Cyan
Write-Host "║  Khá đầy đủ (50-89% data):       $mostlyComplete cột" -ForegroundColor Yellow -NoNewline
Write-Host (" " * (41 - $mostlyComplete.ToString().Length)) -NoNewline
Write-Host "║" -ForegroundColor Cyan
Write-Host "║  Một phần (<50% data):           $partialData cột" -ForegroundColor Red -NoNewline
Write-Host (" " * (41 - $partialData.ToString().Length)) -NoNewline
Write-Host "║" -ForegroundColor Cyan
Write-Host "║  Không có dữ liệu:               $noData cột" -ForegroundColor Red -NoNewline
Write-Host (" " * (41 - $noData.ToString().Length)) -NoNewline
Write-Host "║" -ForegroundColor Cyan
Write-Host "╠════════════════════════════════════════════════════════════════════════╣" -ForegroundColor Cyan
Write-Host "║  Tổng số cột (trừ Year):         $($stats.Count) cột" -ForegroundColor White -NoNewline
Write-Host (" " * (41 - $stats.Count.ToString().Length)) -NoNewline
Write-Host "║" -ForegroundColor Cyan
Write-Host "║  Tổng ô trống đã điền N/A:       $totalEmptyCells ô" -ForegroundColor White -NoNewline
Write-Host (" " * (41 - $totalEmptyCells.ToString().Length)) -NoNewline
Write-Host "║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# Show sample of updated data
Write-Host "`n📋 MẪU DỮ LIỆU SAU KHI CẬP NHẬT (2020-2024):" -ForegroundColor Cyan
$sample = $csv | Where-Object { [int]$_.Year -ge 2020 -and [int]$_.Year -le 2024 }

foreach ($row in $sample) {
    Write-Host "`n  ═══ NĂM $($row.Year) ═══" -ForegroundColor Yellow
    Write-Host "    • Total Population: $($row.'Total Population (Million)')" -ForegroundColor White
    Write-Host "    • GDP per Capita: $($row.'GDP per Capita (USD)')" -ForegroundColor White
    Write-Host "    • Life Expectancy: $($row.'Life Expectancy (years)')" -ForegroundColor White
    Write-Host "    • Primary Completion: $($row.'Primary Completion Rate (%)')" -ForegroundColor $(if ($row.'Primary Completion Rate (%)' -eq 'N/A') { "Gray" } else { "Green" })
    Write-Host "    • HDI: $($row.'HDI')" -ForegroundColor White
    Write-Host "    • Urbanization: $($row.'Urbanization Rate - Vietnam (%)')" -ForegroundColor White
}

Write-Host "`n✅ HOÀN TẤT!" -ForegroundColor Green
Write-Host "   • Đã điền N/A cho tất cả ô trống" -ForegroundColor Gray
Write-Host "   • Dễ phân biệt: N/A (không có data) vs 0 (giá trị thực)" -ForegroundColor Gray
Write-Host "   • File đã được cập nhật: src\data\vietnam_advance.csv" -ForegroundColor Gray
