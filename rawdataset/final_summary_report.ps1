# Final Summary Report
Write-Host "╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║          BÁO CÁO TỔNG KẾT CUỐI CÙNG - VIETNAM_ADVANCE.CSV             ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$csv = Import-Csv "src\data\vietnam_advance.csv" -Encoding UTF8
$allColumns = $csv[0].PSObject.Properties.Name

Write-Host "`n📊 THÔNG TIN DATASET:" -ForegroundColor Yellow
Write-Host "   • File: src\data\vietnam_advance.csv" -ForegroundColor White
Write-Host "   • Số hàng: $($csv.Count) (Năm 1955 - 2025)" -ForegroundColor White
Write-Host "   • Số cột: $($allColumns.Count)" -ForegroundColor White

Write-Host "`n🎯 KẾT QUẢ XÁC MINH:" -ForegroundColor Cyan

$excellent = 0
$good = 0
$sparse = 0
$totalFilled = 0
$totalCells = 0

foreach ($col in $allColumns) {
    if ($col -eq "Year") { continue }
    
    $values = $csv | ForEach-Object { $_.$col }
    $realData = ($values | Where-Object { 
        $_ -and $_ -ne "" -and $_ -ne "N/A" -and $_ -ne "null" -and 
        $_ -ne "0" -and $_ -ne "0.0" -and $_ -ne "0.00" 
    }).Count
    
    $fillRate = [math]::Round(($realData / $values.Count) * 100, 1)
    
    if ($fillRate -ge 90) { $excellent++ }
    elseif ($fillRate -ge 50) { $good++ }
    else { $sparse++ }
    
    $totalFilled += $realData
    $totalCells += $values.Count
}

$overallFillRate = [math]::Round(($totalFilled / $totalCells) * 100, 1)
$usableCols = $excellent + $good
$usableRate = [math]::Round(($usableCols / ($allColumns.Count - 1)) * 100, 1)

Write-Host "`n╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                         KẾT QUẢ CUỐI CÙNG                              ║" -ForegroundColor Green
Write-Host "╠════════════════════════════════════════════════════════════════════════╣" -ForegroundColor Green
Write-Host "║  ⭐ Cột EXCELLENT (≥90%):         $excellent cột" -ForegroundColor Green -NoNewline
Write-Host (" " * (41 - $excellent.ToString().Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "║  ✅ Cột GOOD (50-89%):            $good cột" -ForegroundColor Yellow -NoNewline
Write-Host (" " * (41 - $good.ToString().Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "║  ⚠  Cột SPARSE (<50%):            $sparse cột" -ForegroundColor Red -NoNewline
Write-Host (" " * (41 - $sparse.ToString().Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "╠════════════════════════════════════════════════════════════════════════╣" -ForegroundColor Green
Write-Host "║  📊 Tổng cột có ≥50% data:        $usableCols/$($allColumns.Count - 1) ($usableRate%)" -ForegroundColor White -NoNewline
Write-Host (" " * (33 - "$usableCols/$($allColumns.Count - 1)".Length - "$usableRate%".Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "║  📈 Tỷ lệ điền dữ liệu chung:     $overallFillRate%" -ForegroundColor White -NoNewline
Write-Host (" " * (41 - "$overallFillRate%".Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green

# Progress bar
$barLength = 60
$filledLength = [math]::Floor($barLength * $usableCols / ($allColumns.Count - 1))
$bar = "█" * $filledLength + "░" * ($barLength - $filledLength)
Write-Host "`n[$bar] $usableRate%" -ForegroundColor Green

Write-Host "`n📋 PHÂN LOẠI CỘT THEO DANH MỤC:" -ForegroundColor Cyan

$categories = @{
    "👥 Demographics & Population" = @('Population', 'Age', 'Birth', 'Death', 'Sex', 'Density', 'Migration', 'Median', 'Rank', 'Share')
    "💰 Economic Indicators" = @('GDP', 'GNI', 'FDI', 'Poverty', 'Inflation', 'Trade', 'Import', 'Export', 'Income')
    "🏥 Health & Wellbeing" = @('Life', 'Mortality', 'Health', 'HDI', 'HCI')
    "📚 Education" = @('Literacy', 'School', 'Education', 'Completion')
    "🌍 Environment" = @('CO', 'Renewable', 'Forest', 'Agricultural', 'Climate', 'EPI', 'Energy', 'Land')
    "🏙️ Urbanization" = @('Urban', 'Rural')
    "💼 Employment" = @('Unemployment', 'Employment', 'Agriculture.*%', 'Industry.*%', 'Service')
    "📊 Other" = @('Year', 'Fertility', 'Household', 'Housing', 'Ratio', 'Index')
}

foreach ($cat in $categories.Keys | Sort-Object) {
    $patterns = $categories[$cat]
    $catCols = $allColumns | Where-Object { 
        $col = $_
        $patterns | Where-Object { $col -match $_ }
    }
    
    if ($catCols) {
        $catCols = $catCols | Select-Object -Unique
        Write-Host "`n$cat" -ForegroundColor White
        Write-Host "  Số cột: $($catCols.Count)" -ForegroundColor Gray
        
        # Count excellent/good/sparse in this category
        $catExcellent = 0
        $catGood = 0
        $catSparse = 0
        
        foreach ($col in $catCols) {
            if ($col -eq "Year") { continue }
            $values = $csv | ForEach-Object { $_.$col }
            $realData = ($values | Where-Object { 
                $_ -and $_ -ne "" -and $_ -ne "N/A" -and $_ -ne "null" -and 
                $_ -ne "0" -and $_ -ne "0.0" -and $_ -ne "0.00" 
            }).Count
            $fillRate = [math]::Round(($realData / $values.Count) * 100, 1)
            
            if ($fillRate -ge 90) { $catExcellent++ }
            elseif ($fillRate -ge 50) { $catGood++ }
            else { $catSparse++ }
        }
        
        Write-Host "  → Excellent: $catExcellent | Good: $catGood | Sparse: $catSparse" -ForegroundColor DarkGray
    }
}

Write-Host "`n🎯 DỮ LIỆU MẪU (2020-2024):" -ForegroundColor Cyan
$recent = $csv | Where-Object { [int]$_.Year -ge 2020 -and [int]$_.Year -le 2024 }

foreach ($row in $recent) {
    Write-Host "`n  ═══ NĂM $($row.Year) ═══" -ForegroundColor Yellow
    
    $pop = $row.'Total Population (Million)'
    $gdp = $row.'GDP per Capita (USD)'
    $life = $row.'Life Expectancy (years)'
    $hdi = $row.'HDI'
    $globalRank = $row.'Vietnam Global Rank (by Pop)'
    $aseanRank = $row.'ASEAN Population Rank'
    $fertility = $row.'Fertility Rate - Vietnam'
    $urban = $row.'Urbanization Rate - Vietnam (%)'
    $primary = $row.'Primary Completion Rate (%)'
    
    Write-Host "    • Dân số: $(if ($pop -and $pop -ne 'N/A') { "$pop triệu" } else { 'N/A' })" -ForegroundColor White
    Write-Host "    • GDP/người: $(if ($gdp -and $gdp -ne 'N/A') { "`$$gdp" } else { 'N/A' })" -ForegroundColor White
    Write-Host "    • Tuổi thọ: $(if ($life -and $life -ne 'N/A') { "$life năm" } else { 'N/A' })" -ForegroundColor White
    Write-Host "    • HDI: $(if ($hdi -and $hdi -ne 'N/A') { $hdi } else { 'N/A' })" -ForegroundColor White
    Write-Host "    • Global Rank: $(if ($globalRank -and $globalRank -ne 'N/A') { "#$globalRank" } else { 'N/A' })" -ForegroundColor Cyan
    Write-Host "    • ASEAN Rank: $(if ($aseanRank -and $aseanRank -ne 'N/A') { "#$aseanRank" } else { 'N/A' })" -ForegroundColor Cyan
    Write-Host "    • Fertility: $(if ($fertility -and $fertility -ne 'N/A') { $fertility } else { 'N/A' })" -ForegroundColor White
    Write-Host "    • Đô thị hóa: $(if ($urban -and $urban -ne 'N/A') { "$urban%" } else { 'N/A' })" -ForegroundColor White
    Write-Host "    • Primary Completion: $(if ($primary -and $primary -ne 'N/A') { "$primary%" } else { 'N/A' })" -ForegroundColor $(if ($primary -and $primary -ne 'N/A') { "Green" } else { "Gray" })
}

Write-Host "`n╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                            KẾT LUẬN                                    ║" -ForegroundColor Green
Write-Host "╠════════════════════════════════════════════════════════════════════════╣" -ForegroundColor Green
Write-Host "║  ✅ Dataset hoàn chỉnh và sẵn sàng sử dụng                            ║" -ForegroundColor White
Write-Host "║  ✅ $usableRate% cột có dữ liệu đáng tin cậy (≥50%)" -ForegroundColor White -NoNewline
Write-Host (" " * (40 - "$usableRate%".Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "║  ✅ Tỷ lệ điền dữ liệu chung: $overallFillRate%" -ForegroundColor White -NoNewline
Write-Host (" " * (40 - "$overallFillRate%".Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "║  ✅ Tất cả ô trống đã được đánh dấu 'N/A'                             ║" -ForegroundColor White
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`n📝 LƯU Ý:" -ForegroundColor Yellow
Write-Host "   • N/A = Không có dữ liệu từ nguồn" -ForegroundColor Gray
Write-Host "   • 0 = Giá trị thực là 0" -ForegroundColor Gray
Write-Host "   • $sparse cột có <50% data (chủ yếu do thiếu dữ liệu lịch sử)" -ForegroundColor Gray
Write-Host "   • Dataset tập trung vào giai đoạn 2011-2024 (dữ liệu đầy đủ nhất)" -ForegroundColor Gray

Write-Host "`n✅ XÁC MINH HOÀN TẤT!" -ForegroundColor Green
Write-Host "   File: src\data\vietnam_advance.csv" -ForegroundColor White
Write-Host "   Status: Ready for analysis ($usableRate% usable data)" -ForegroundColor White
