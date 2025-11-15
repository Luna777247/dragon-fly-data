# Convert invalid zeros to N/A for economic indicators before 1985
Write-Host "╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║          CHUYỂN ĐỔI ZEROS KHÔNG HỢP LỆ THÀNH N/A                      ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$csv = Import-Csv "vietnam_population.csv" -Encoding UTF8

Write-Host "`n🔍 Xử lý các cột kinh tế..." -ForegroundColor Yellow

$columns = @(
    "GDP per Capita (USD)",
    "GDP PPP per Capita (Int`$)",
    "GDP Growth Rate (%)",
    "Unemployment Rate (%)"
)

$updateCount = @{}
foreach ($col in $columns) {
    $updateCount[$col] = 0
}

foreach ($row in $csv) {
    $year = [int]$row.Year
    
    foreach ($col in $columns) {
        $value = $row.$col
        
        # Convert zeros before 1985 to N/A (World Bank data starts from ~1985 for Vietnam)
        # For GDP per Capita and GDP Growth, data starts from 1985
        # For GDP PPP, data starts from 1990
        # For Unemployment, data starts from 1991
        
        $shouldConvert = $false
        
        if ($col -eq "GDP per Capita (USD)" -and $year -lt 1985) {
            $shouldConvert = $true
        } elseif ($col -eq "GDP Growth Rate (%)" -and $year -lt 1985) {
            $shouldConvert = $true
        } elseif ($col -eq "GDP PPP per Capita (Int`$)" -and $year -lt 1990) {
            $shouldConvert = $true
        } elseif ($col -eq "Unemployment Rate (%)" -and $year -lt 1991) {
            $shouldConvert = $true
        }
        
        if ($shouldConvert -and ($value -eq "0" -or $value -eq "0.0" -or $value -eq "0.00")) {
            $row.$col = "N/A"
            $updateCount[$col]++
        }
    }
}

# Handle FDI separately - zeros before 1970 should be N/A
$fdiCol = "FDI Net Inflows (million USD)"
$fdiCount = 0

foreach ($row in $csv) {
    $year = [int]$row.Year
    $value = $row.$fdiCol
    
    if ($year -lt 1970 -and ($value -eq "0" -or $value -eq "0.0" -or $value -eq "0.00")) {
        $row.$fdiCol = "N/A"
        $fdiCount++
    }
}

# Save updated CSV
$csv | Export-Csv "vietnam_population.csv" -Encoding UTF8 -NoTypeInformation

Write-Host "`n✅ Chuyển đổi hoàn tất!" -ForegroundColor Green
Write-Host "`n📊 Số lượng chuyển đổi:" -ForegroundColor Cyan

foreach ($col in $columns | Sort-Object) {
    $count = $updateCount[$col]
    Write-Host "   • $col`: $count → N/A" -ForegroundColor Green
}
Write-Host "   • FDI Net Inflows (million USD): $fdiCount → N/A" -ForegroundColor Green

$totalConverted = ($updateCount.Values | Measure-Object -Sum).Sum + $fdiCount
Write-Host "`n   📊 Tổng: $totalConverted giá trị đã chuyển" -ForegroundColor White

Write-Host "`n✅ File đã được lưu: vietnam_population.csv" -ForegroundColor Green
