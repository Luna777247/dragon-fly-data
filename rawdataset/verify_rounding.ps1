# Final verification of rounded values
Write-Host "╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║               BÁO CÁO XÁC MINH LÀM TRÒN DỮ LIỆU                        ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`n📊 KIỂM TRA vietnam_population.csv:" -ForegroundColor Cyan

$popCsv = Import-Csv "vietnam_population.csv" -Encoding UTF8

# Count decimal values
$stats = @{
    "Integer" = 0
    "1 decimal" = 0
    "2 decimals" = 0
    ">2 decimals" = 0
    "Non-numeric" = 0
}

foreach($row in $popCsv) {
    foreach($prop in $row.PSObject.Properties) {
        if($prop.Name -ne 'Year') {
            $val = $prop.Value
            if([string]::IsNullOrWhiteSpace($val) -or $val -eq 'N/A' -or $val -eq '#N/A') {
                $stats["Non-numeric"]++
            } elseif($val -match '^\d+$') {
                $stats["Integer"]++
            } elseif($val -match '^\d+\.\d+$') {
                $decimals = ($val -split '\.')[1].Length
                if($decimals -eq 1) {
                    $stats["1 decimal"]++
                } elseif($decimals -eq 2) {
                    $stats["2 decimals"]++
                } else {
                    $stats[">2 decimals"]++
                }
            } else {
                $stats["Non-numeric"]++
            }
        }
    }
}

$total = ($stats.Values | Measure-Object -Sum).Sum
Write-Host "   • Tổng số giá trị: $total" -ForegroundColor White
Write-Host "   • Số nguyên: $($stats['Integer'])" -ForegroundColor White
Write-Host "   • 1 chữ số thập phân: $($stats['1 decimal'])" -ForegroundColor White
Write-Host "   • 2 chữ số thập phân: $($stats['2 decimals'])" -ForegroundColor White
Write-Host "   • >2 chữ số thập phân: $($stats['>2 decimals'])" -ForegroundColor $(if($stats['>2 decimals'] -eq 0){'Green'}else{'Red'})
Write-Host "   • Không phải số: $($stats['Non-numeric'])" -ForegroundColor Gray

Write-Host "`n📊 KIỂM TRA src\data\vietnam_advance.csv:" -ForegroundColor Cyan

$advCsv = Import-Csv "src\data\vietnam_advance.csv" -Encoding UTF8

$stats2 = @{
    "Integer" = 0
    "1 decimal" = 0
    "2 decimals" = 0
    ">2 decimals" = 0
    "Non-numeric" = 0
}

foreach($row in $advCsv) {
    foreach($prop in $row.PSObject.Properties) {
        if($prop.Name -ne 'Year') {
            $val = $prop.Value
            if([string]::IsNullOrWhiteSpace($val) -or $val -eq 'N/A' -or $val -eq '#N/A') {
                $stats2["Non-numeric"]++
            } elseif($val -match '^\d+$') {
                $stats2["Integer"]++
            } elseif($val -match '^\d+\.\d+$') {
                $decimals = ($val -split '\.')[1].Length
                if($decimals -eq 1) {
                    $stats2["1 decimal"]++
                } elseif($decimals -eq 2) {
                    $stats2["2 decimals"]++
                } else {
                    $stats2[">2 decimals"]++
                }
            } else {
                $stats2["Non-numeric"]++
            }
        }
    }
}

$total2 = ($stats2.Values | Measure-Object -Sum).Sum
Write-Host "   • Tổng số giá trị: $total2" -ForegroundColor White
Write-Host "   • Số nguyên: $($stats2['Integer'])" -ForegroundColor White
Write-Host "   • 1 chữ số thập phân: $($stats2['1 decimal'])" -ForegroundColor White
Write-Host "   • 2 chữ số thập phân: $($stats2['2 decimals'])" -ForegroundColor White
Write-Host "   • >2 chữ số thập phân: $($stats2['>2 decimals'])" -ForegroundColor $(if($stats2['>2 decimals'] -eq 0){'Green'}else{'Red'})
Write-Host "   • Không phải số: $($stats2['Non-numeric'])" -ForegroundColor Gray

Write-Host "`n🔍 MẪU DỮ LIỆU (năm 2024):" -ForegroundColor Cyan
$sample = $popCsv | Where-Object {$_.Year -eq '2024'}

Write-Host "`n   Nhân khẩu học:" -ForegroundColor Yellow
Write-Host "      • Population: $('{0:N0}' -f [long]$sample.Population)" -ForegroundColor White
Write-Host "      • Median Age: $($sample.'Median Age') tuổi" -ForegroundColor White
Write-Host "      • Dependency Ratio: $($sample.'Dependency Ratio (%)')%" -ForegroundColor White
Write-Host "      • Sex Ratio: $($sample.'Sex Ratio (M/F)')" -ForegroundColor White

Write-Host "`n   Kinh tế:" -ForegroundColor Yellow
Write-Host "      • GDP per Capita: `$$($sample.'GDP per Capita (USD)')" -ForegroundColor White
Write-Host "      • Unemployment: $($sample.'Unemployment Rate (%)')%" -ForegroundColor White
Write-Host "      • GDP PPP per Capita: `$$($sample.'GDP PPP per Capita (Int$)')" -ForegroundColor White

Write-Host "`n   Xã hội:" -ForegroundColor Yellow
Write-Host "      • Life Expectancy: $($sample.'Life Expectancy') năm" -ForegroundColor White
Write-Host "      • Fertility Rate: $($sample.'Fertility Rate')" -ForegroundColor White
Write-Host "      • Birth Rate: $($sample.'Birth Rate (‰)')‰" -ForegroundColor White
Write-Host "      • Death Rate: $($sample.'Death Rate (‰)')‰" -ForegroundColor White

Write-Host "`n   Môi trường:" -ForegroundColor Yellow
Write-Host "      • CO₂ Emissions: $($sample.'CO₂ Emissions per Capita (t)') t/người" -ForegroundColor White
Write-Host "      • Energy Consumption: $($sample.'Energy Consumption per Capita (kWh)') kWh" -ForegroundColor White
Write-Host "      • Forest Area: $($sample.'Forest Area (% Land)')%" -ForegroundColor White

Write-Host "`n╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                           ✅ KẾT LUẬN                                   ║" -ForegroundColor Green
Write-Host "╠════════════════════════════════════════════════════════════════════════╣" -ForegroundColor Green

if($stats['>2 decimals'] -eq 0 -and $stats2['>2 decimals'] -eq 0) {
    Write-Host "║  ✅ TẤT CẢ DỮ LIỆU ĐÃ ĐƯỢC LÀM TRÒN ĐẾN 2 CHỮ SỐ THẬP PHÂN            ║" -ForegroundColor White
    Write-Host "║                                                                        ║" -ForegroundColor Green
    Write-Host "║  📊 vietnam_population.csv:                                            ║" -ForegroundColor White
    Write-Host "║     • $($stats['2 decimals']) giá trị có 2 chữ số thập phân" -NoNewline -ForegroundColor White
    Write-Host (" " * (35 - "$($stats['2 decimals'])".Length)) -NoNewline
    Write-Host "║" -ForegroundColor Green
    Write-Host "║     • $($stats['1 decimal']) giá trị có 1 chữ số thập phân" -NoNewline -ForegroundColor White
    Write-Host (" " * (36 - "$($stats['1 decimal'])".Length)) -NoNewline
    Write-Host "║" -ForegroundColor Green
    Write-Host "║                                                                        ║" -ForegroundColor Green
    Write-Host "║  📊 src\data\vietnam_advance.csv:                                      ║" -ForegroundColor White
    Write-Host "║     • $($stats2['2 decimals']) giá trị có 2 chữ số thập phân" -NoNewline -ForegroundColor White
    Write-Host (" " * (34 - "$($stats2['2 decimals'])".Length)) -NoNewline
    Write-Host "║" -ForegroundColor Green
    Write-Host "║     • $($stats2['1 decimal']) giá trị có 1 chữ số thập phân" -NoNewline -ForegroundColor White
    Write-Host (" " * (35 - "$($stats2['1 decimal'])".Length)) -NoNewline
    Write-Host "║" -ForegroundColor Green
    Write-Host "║                                                                        ║" -ForegroundColor Green
    Write-Host "║  🎯 Dataset sẵn sàng cho phân tích và visualization!                  ║" -ForegroundColor White
} else {
    Write-Host "║  ⚠️  CÒN $($stats['>2 decimals'] + $stats2['>2 decimals']) GIÁ TRỊ CẦN LÀM TRÒN                                  ║" -ForegroundColor Yellow
}

Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
