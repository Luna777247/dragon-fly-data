# Round all numeric values to 2 decimal places
Write-Host "╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║              LÀM TRÒN DỮ LIỆU ĐẾN 2 CHỮ SỐ THẬP PHÂN                  ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

function Round-Value {
    param([string]$value)
    
    if ([string]::IsNullOrWhiteSpace($value) -or $value -eq "N/A" -or $value -eq "#N/A") {
        return $value
    }
    
    try {
        $num = [double]$value
        if ([Math]::Floor($num) -eq $num) {
            # Integer - keep as is
            return [string][long]$num
        } else {
            # Decimal - round to 2 places
            return [string][Math]::Round($num, 2)
        }
    } catch {
        return $value
    }
}

# Process vietnam_population.csv
Write-Host "`n📄 Đang xử lý vietnam_population.csv..." -ForegroundColor Yellow

$popCsv = Import-Csv "vietnam_population.csv" -Encoding UTF8
$roundedCount = 0

foreach ($row in $popCsv) {
    foreach ($prop in $row.PSObject.Properties) {
        if ($prop.Name -ne "Year") {
            $original = $prop.Value
            $rounded = Round-Value $original
            
            if ($original -ne $rounded) {
                $prop.Value = $rounded
                $roundedCount++
            }
        }
    }
}

$popCsv | Export-Csv "vietnam_population.csv" -Encoding UTF8 -NoTypeInformation
Write-Host "   ✅ Đã làm tròn $roundedCount giá trị" -ForegroundColor Green

# Process vietnam_advance.csv
Write-Host "`n📄 Đang xử lý src\data\vietnam_advance.csv..." -ForegroundColor Yellow

$advCsv = Import-Csv "src\data\vietnam_advance.csv" -Encoding UTF8
$roundedCount2 = 0

foreach ($row in $advCsv) {
    foreach ($prop in $row.PSObject.Properties) {
        if ($prop.Name -ne "Year") {
            $original = $prop.Value
            $rounded = Round-Value $original
            
            if ($original -ne $rounded) {
                $prop.Value = $rounded
                $roundedCount2++
            }
        }
    }
}

$advCsv | Export-Csv "src\data\vietnam_advance.csv" -Encoding UTF8 -NoTypeInformation
Write-Host "   ✅ Đã làm tròn $roundedCount2 giá trị" -ForegroundColor Green

Write-Host "`n╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                         HOÀN THÀNH                                     ║" -ForegroundColor Green
Write-Host "╠════════════════════════════════════════════════════════════════════════╣" -ForegroundColor Green
Write-Host "║  📊 vietnam_population.csv: $roundedCount giá trị được làm tròn" -NoNewline -ForegroundColor White
Write-Host (" " * (30 - "$roundedCount".Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "║  📊 vietnam_advance.csv: $roundedCount2 giá trị được làm tròn" -NoNewline -ForegroundColor White
Write-Host (" " * (33 - "$roundedCount2".Length)) -NoNewline
Write-Host "║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green

# Verify with sample
Write-Host "`n🔍 Kiểm tra mẫu (năm 2024):" -ForegroundColor Cyan
$sample = $popCsv | Where-Object {$_.Year -eq '2024'}
Write-Host "   • Median Age: $($sample.'Median Age')" -ForegroundColor Gray
Write-Host "   • GDP per Capita: $($sample.'GDP per Capita (USD)')" -ForegroundColor Gray
Write-Host "   • Life Expectancy: $($sample.'Life Expectancy')" -ForegroundColor Gray
Write-Host "   • CO₂ Emissions: $($sample.'CO₂ Emissions per Capita (t)')" -ForegroundColor Gray
Write-Host "   • Fertility Rate: $($sample.'Fertility Rate')" -ForegroundColor Gray

Write-Host "`n✅ Tất cả giá trị số đã được làm tròn đến 2 chữ số thập phân" -ForegroundColor Green
