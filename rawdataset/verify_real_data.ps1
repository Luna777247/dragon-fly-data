# Detailed Column Verification - Check for REAL data (not just 0 or empty)
Write-Host "╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║           KIỂM TRA CHI TIẾT CÁC CỘT - DỮ LIỆU THỰC TẾ                 ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$csv = Import-Csv "src\data\vietnam_advance.csv" -Encoding UTF8
$allColumns = $csv[0].PSObject.Properties.Name

Write-Host "`n📊 Đang kiểm tra từng cột..." -ForegroundColor Yellow

$verifiedColumns = @()
$emptyColumns = @()
$suspiciousColumns = @()

foreach ($col in $allColumns) {
    $values = $csv | ForEach-Object { $_.$col }
    $nonEmpty = $values | Where-Object { $_ -and $_ -ne "" }
    $nonZero = $nonEmpty | Where-Object { $_ -ne "0" -and $_ -ne "0.0" -and $_ -ne "0.00" }
    
    $totalRows = $csv.Count
    $filledRows = $nonEmpty.Count
    $realDataRows = $nonZero.Count
    $fillRate = if ($totalRows -gt 0) { [math]::Round(($realDataRows / $totalRows) * 100, 1) } else { 0 }
    
    if ($realDataRows -eq 0) {
        $emptyColumns += [PSCustomObject]@{
            Column = $col
            FilledRows = $filledRows
            RealDataRows = $realDataRows
            FillRate = "$fillRate%"
            Status = "EMPTY"
        }
    } elseif ($realDataRows -lt ($totalRows * 0.5)) {
        $suspiciousColumns += [PSCustomObject]@{
            Column = $col
            FilledRows = $filledRows
            RealDataRows = $realDataRows
            FillRate = "$fillRate%"
            Status = "PARTIAL"
        }
    } else {
        $verifiedColumns += [PSCustomObject]@{
            Column = $col
            FilledRows = $filledRows
            RealDataRows = $realDataRows
            FillRate = "$fillRate%"
            Status = "VERIFIED"
        }
    }
}

Write-Host "`n╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                           TỔNG KẾT KIỂM TRA                            ║" -ForegroundColor Green
Write-Host "╠════════════════════════════════════════════════════════════════════════╣" -ForegroundColor Green
Write-Host "║  Tổng số cột:                    $($allColumns.Count) cột" -ForegroundColor White -NoNewline
Write-Host (" " * (42 - $allColumns.Count.ToString().Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "║  Cột có dữ liệu thực (>50%):     $($verifiedColumns.Count) cột" -ForegroundColor Green -NoNewline
Write-Host (" " * (42 - $verifiedColumns.Count.ToString().Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "║  Cột dữ liệu không đầy (<50%):   $($suspiciousColumns.Count) cột" -ForegroundColor Yellow -NoNewline
Write-Host (" " * (42 - $suspiciousColumns.Count.ToString().Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "║  Cột trống/chỉ có 0:             $($emptyColumns.Count) cột" -ForegroundColor Red -NoNewline
Write-Host (" " * (42 - $emptyColumns.Count.ToString().Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green

if ($emptyColumns.Count -gt 0) {
    Write-Host "`n❌ CÁC CỘT TRỐNG HOẶC CHỈ CÓ GIÁ TRỊ 0:" -ForegroundColor Red
    $emptyColumns | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor Gray
    
    Write-Host "`n📋 Chi tiết các cột cần bổ sung:" -ForegroundColor Yellow
    foreach ($col in $emptyColumns) {
        Write-Host "  ⚠ $($col.Column)" -ForegroundColor Red
        # Show sample values
        $sampleVals = ($csv | Select-Object -First 5 | ForEach-Object { $_.$($col.Column) }) -join ", "
        Write-Host "     Sample: [$sampleVals]" -ForegroundColor Gray
    }
}

if ($suspiciousColumns.Count -gt 0) {
    Write-Host "`n⚠ CÁC CỘT CÓ DỮ LIỆU KHÔNG ĐẦY ĐỦ (<50%):" -ForegroundColor Yellow
    $suspiciousColumns | Format-Table -AutoSize | Out-String | Write-Host -ForegroundColor Gray
    
    Write-Host "`n📋 Chi tiết các cột cần kiểm tra:" -ForegroundColor Yellow
    foreach ($col in $suspiciousColumns) {
        Write-Host "  ⚠ $($col.Column) - Fill rate: $($col.FillRate)" -ForegroundColor Yellow
        # Show sample non-empty values
        $sampleVals = ($csv | Where-Object { $_.$($col.Column) -and $_.$($col.Column) -ne "0" } | Select-Object -First 3 | ForEach-Object { $_.$($col.Column) }) -join ", "
        Write-Host "     Sample non-zero: [$sampleVals]" -ForegroundColor Gray
    }
}

Write-Host "`n✅ CÁC CỘT ĐÃ XÁC MINH ĐẦY ĐỦ (>50% dữ liệu thực):" -ForegroundColor Green
Write-Host "   Tổng: $($verifiedColumns.Count) cột" -ForegroundColor White

# Group by category
$categories = @{
    "Demographics" = $verifiedColumns | Where-Object { $_.Column -match "Population|Age|Birth|Death|Sex|Density|Migration|Median" }
    "Economics" = $verifiedColumns | Where-Object { $_.Column -match "GDP|GNI|FDI|Poverty|Inflation|Trade|Import|Export" }
    "Health" = $verifiedColumns | Where-Object { $_.Column -match "Life|Mortality|Health|HDI|HCI" }
    "Education" = $verifiedColumns | Where-Object { $_.Column -match "Literacy|School|Education" }
    "Environment" = $verifiedColumns | Where-Object { $_.Column -match "Renewable|Forest|Agricultural|CO|Climate|EPI|Energy|Land" }
    "Urban" = $verifiedColumns | Where-Object { $_.Column -match "Urban|Rural" }
    "Employment" = $verifiedColumns | Where-Object { $_.Column -match "Unemployment|Employment|Agriculture.*%|Industry.*%|Service" }
    "Other" = $verifiedColumns | Where-Object { $_.Column -match "Year|Rank|Fertility|Household|Housing" }
}

Write-Host "`n📊 Phân loại theo danh mục:" -ForegroundColor Cyan
foreach ($cat in $categories.Keys | Sort-Object) {
    $count = $categories[$cat].Count
    if ($count -gt 0) {
        Write-Host "  ✓ $cat : $count cột" -ForegroundColor White
    }
}

# Calculate real completion rate
$totalCols = $allColumns.Count
$verifiedCols = $verifiedColumns.Count
$realCompletionRate = [math]::Round(($verifiedCols / $totalCols) * 100, 1)

Write-Host "`n╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                    TỶ LỆ HOÀN THÀNH THỰC TẾ                           ║" -ForegroundColor Cyan
Write-Host "╠════════════════════════════════════════════════════════════════════════╣" -ForegroundColor Cyan
Write-Host "║  $realCompletionRate% ($verifiedCols/$totalCols cột có dữ liệu thực >50%)" -ForegroundColor Yellow -NoNewline
Write-Host (" " * (42 - "$realCompletionRate%".Length - "$verifiedCols/$totalCols".Length - 24)) -NoNewline
Write-Host "║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

# Progress bar
$barLength = 60
$filledLength = [math]::Floor($barLength * $verifiedCols / $totalCols)
$bar = "█" * $filledLength + "░" * ($barLength - $filledLength)
Write-Host "`n[$bar] $realCompletionRate%" -ForegroundColor $(if ($realCompletionRate -ge 90) { "Green" } elseif ($realCompletionRate -ge 75) { "Yellow" } else { "Red" })

Write-Host "`n✅ Kiểm tra hoàn tất!" -ForegroundColor Green
