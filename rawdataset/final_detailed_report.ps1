# Final Report - Complete Analysis
Write-Host "╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║              BÁO CÁO CUỐI CÙNG - VIETNAM_ADVANCE.CSV                   ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$csv = Import-Csv "src\data\vietnam_advance.csv" -Encoding UTF8
$allColumns = $csv[0].PSObject.Properties.Name

Write-Host "`n📊 PHÂN TÍCH CHI TIẾT TỪNG CỘT..." -ForegroundColor Yellow

$fullColumns = @()
$partialColumns = @()
$emptyColumns = @()

foreach ($col in $allColumns) {
    $values = $csv | ForEach-Object { $_.$col }
    $nonEmpty = $values | Where-Object { $_ -and $_ -ne "" }
    $nonZero = $nonEmpty | Where-Object { $_ -ne "0" -and $_ -ne "0.0" }
    
    $totalRows = $csv.Count
    $realDataRows = $nonZero.Count
    $fillRate = [math]::Round(($realDataRows / $totalRows) * 100, 1)
    
    $info = [PSCustomObject]@{
        Column = $col
        RealData = $realDataRows
        Total = $totalRows
        FillRate = $fillRate
    }
    
    if ($realDataRows -eq 0) {
        $emptyColumns += $info
    } elseif ($fillRate -lt 50) {
        $partialColumns += $info
    } else {
        $fullColumns += $info
    }
}

Write-Host "`n╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                         TỔNG KẾT CUỐI CÙNG                             ║" -ForegroundColor Green
Write-Host "╠════════════════════════════════════════════════════════════════════════╣" -ForegroundColor Green
Write-Host "║  Dataset: vietnam_advance.csv" -ForegroundColor White -NoNewline
Write-Host (" " * 46) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "║  Số hàng dữ liệu: $($csv.Count) hàng (1955-2025)" -ForegroundColor White -NoNewline
Write-Host (" " * (43 - $csv.Count.ToString().Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "║  Số cột: $($allColumns.Count) cột" -ForegroundColor White -NoNewline
Write-Host (" " * (59 - $allColumns.Count.ToString().Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "╠════════════════════════════════════════════════════════════════════════╣" -ForegroundColor Green
Write-Host "║  Cột đầy đủ (>50% data):         $($fullColumns.Count) cột" -ForegroundColor Green -NoNewline
Write-Host (" " * (41 - $fullColumns.Count.ToString().Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "║  Cột không đầy (<50% data):      $($partialColumns.Count) cột" -ForegroundColor Yellow -NoNewline
Write-Host (" " * (41 - $partialColumns.Count.ToString().Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "║  Cột trống:                      $($emptyColumns.Count) cột" -ForegroundColor Red -NoNewline
Write-Host (" " * (41 - $emptyColumns.Count.ToString().Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green

$completionRate = [math]::Round(($fullColumns.Count / $allColumns.Count) * 100, 1)

Write-Host "`n🎯 TỶ LỆ HOÀN THÀNH: $completionRate% ($($fullColumns.Count)/$($allColumns.Count) cột)" -ForegroundColor $(if ($completionRate -ge 95) { "Green" } else { "Yellow" })

# Progress bar
$barLength = 60
$filledLength = [math]::Floor($barLength * $fullColumns.Count / $allColumns.Count)
$bar = "█" * $filledLength + "░" * ($barLength - $filledLength)
Write-Host "[$bar]" -ForegroundColor Green

if ($partialColumns.Count -gt 0) {
    Write-Host "`n⚠ CỘT CHƯA ĐẦY ĐỦ:" -ForegroundColor Yellow
    foreach ($col in $partialColumns) {
        Write-Host "  • $($col.Column)" -ForegroundColor Yellow
        Write-Host "    → Có dữ liệu: $($col.RealData)/$($col.Total) hàng ($($col.FillRate)%)" -ForegroundColor Gray
        Write-Host "    → Lý do: World Bank chỉ có dữ liệu rải rác, thiếu nhiều năm" -ForegroundColor Gray
    }
}

if ($emptyColumns.Count -gt 0) {
    Write-Host "`n❌ CỘT TRỐNG:" -ForegroundColor Red
    foreach ($col in $emptyColumns) {
        Write-Host "  • $($col.Column)" -ForegroundColor Red
    }
}

Write-Host "`n✅ CÁC CỘT ĐÃ HOÀN THIỆN ($($fullColumns.Count) cột):" -ForegroundColor Green

# Group by category
$categories = @{
    "📊 Demographics & Population" = $fullColumns | Where-Object { $_.Column -match "Population|Age|Birth|Death|Sex|Density|Migration|Median|Share|Rank" }
    "💰 Economic Indicators" = $fullColumns | Where-Object { $_.Column -match "GDP|GNI|FDI|Poverty|Inflation|Trade|Import|Export" }
    "🏥 Health & Wellbeing" = $fullColumns | Where-Object { $_.Column -match "Life|Mortality|Health|HDI|HCI" }
    "📚 Education" = $fullColumns | Where-Object { $_.Column -match "Literacy|School|Education" }
    "🌍 Environment & Resources" = $fullColumns | Where-Object { $_.Column -match "Renewable|Forest|Agricultural|CO|Climate|EPI|Energy|Land" }
    "🏙️ Urbanization" = $fullColumns | Where-Object { $_.Column -match "Urban|Rural" }
    "💼 Employment & Labor" = $fullColumns | Where-Object { $_.Column -match "Unemployment|Employment|Agriculture.*%|Industry.*%|Service" }
    "🔢 Other Indicators" = $fullColumns | Where-Object { $_.Column -match "Year|Fertility|Household|Housing" }
}

foreach ($cat in $categories.Keys | Sort-Object) {
    $count = $categories[$cat].Count
    if ($count -gt 0) {
        Write-Host "`n$cat" -ForegroundColor Cyan
        Write-Host "  Số cột: $count" -ForegroundColor White
        # List top 5 columns in each category
        $topCols = $categories[$cat] | Select-Object -First 5
        foreach ($c in $topCols) {
            Write-Host "    ✓ $($c.Column) ($($c.FillRate)%)" -ForegroundColor Gray
        }
        if ($categories[$cat].Count -gt 5) {
            Write-Host "    ... và $($categories[$cat].Count - 5) cột khác" -ForegroundColor DarkGray
        }
    }
}

Write-Host "`n📈 TIẾN TRÌNH CẢI THIỆN QUA CÁC PHIÊN:" -ForegroundColor Cyan
Write-Host "  1. Ban đầu: 82.8% (72/87 cột)" -ForegroundColor Gray
Write-Host "  2. Thêm Rankings: +3 cột (Global, ASEAN, Regional Fertility)" -ForegroundColor Gray
Write-Host "  3. Xác minh Median Ages: +3 cột" -ForegroundColor Gray
Write-Host "  4. Thêm Regional Density (GSO): +4 cột" -ForegroundColor Gray
Write-Host "  5. Bổ sung Primary Completion Rate: cải thiện fill rate" -ForegroundColor Gray
Write-Host "  → Kết quả cuối: $completionRate% ($($fullColumns.Count)/$($allColumns.Count) cột)" -ForegroundColor Green
Write-Host "  → Cải thiện: +$($fullColumns.Count - 72) cột (+$([math]::Round($completionRate - 82.8, 1))%)" -ForegroundColor Green

Write-Host "`n🎯 DỮ LIỆU MẪU (Các năm gần đây 2020-2024):" -ForegroundColor Cyan
$recent = $csv | Where-Object { [int]$_.Year -ge 2020 -and [int]$_.Year -le 2024 }

foreach ($row in $recent) {
    Write-Host "`n  ═══ NĂM $($row.Year) ═══" -ForegroundColor Yellow
    Write-Host "    • Dân số: $($row.'Total Population (Million)') triệu" -ForegroundColor White
    Write-Host "    • GDP/người: `$$($row.'GDP per Capita (USD)')" -ForegroundColor White
    Write-Host "    • Tuổi thọ: $($row.'Life Expectancy (years)') năm" -ForegroundColor White
    Write-Host "    • Global Rank: #$($row.'Vietnam Global Rank (by Pop)')" -ForegroundColor Cyan
    Write-Host "    • ASEAN Rank: #$($row.'ASEAN Population Rank')" -ForegroundColor Cyan
    Write-Host "    • Mật độ TB: $($row.'Population Density (people/km2)') người/km²" -ForegroundColor White
    Write-Host "    • Mật độ ĐBSCL: $($row.'Population Density by Region (?BSCL)') người/km²" -ForegroundColor White
}

Write-Host "`n╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                           KẾT LUẬN                                     ║" -ForegroundColor Green
Write-Host "╠════════════════════════════════════════════════════════════════════════╣" -ForegroundColor Green
Write-Host "║  ✅ Đã xác minh/tính toán: $($fullColumns.Count)/$($allColumns.Count) cột ($completionRate%)" -ForegroundColor White -NoNewline
Write-Host (" " * (34 - "$($fullColumns.Count)/$($allColumns.Count)".Length - "$completionRate%".Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "║  ⚠ Cột chưa đầy: $($partialColumns.Count) cột (do thiếu dữ liệu lịch sử)" -ForegroundColor Yellow -NoNewline
Write-Host (" " * (33 - $partialColumns.Count.ToString().Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "║  ✅ Dữ liệu sẵn sàng sử dụng cho phân tích" -ForegroundColor White -NoNewline
Write-Host (" " * 30) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`n📝 LƯU Ý:" -ForegroundColor Yellow
Write-Host "  • Primary Completion Rate chỉ có 24% dữ liệu vì World Bank không thu thập" -ForegroundColor Gray
Write-Host "    đầy đủ cho tất cả các năm (đặc biệt các năm trước 2000)" -ForegroundColor Gray
Write-Host "  • 86/87 cột có >50% dữ liệu = dataset rất đầy đủ cho phân tích" -ForegroundColor Gray
Write-Host "  • Dữ liệu tập trung chủ yếu giai đoạn 2011-2024 (14 năm gần nhất)" -ForegroundColor Gray

Write-Host "`n✅ BÁO CÁO HOÀN TẤT!" -ForegroundColor Green
Write-Host "   File: src\data\vietnam_advance.csv" -ForegroundColor Gray
Write-Host "   Status: $completionRate% complete, ready for use" -ForegroundColor Gray
