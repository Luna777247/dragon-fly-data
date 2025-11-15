# Fix Primary Completion Rate - replace 0 with N/A where appropriate
Write-Host "=== Fixing Primary Completion Rate Column ===" -ForegroundColor Cyan

$csv = Import-Csv "src\data\vietnam_advance.csv" -Encoding UTF8

Write-Host "`nTrước khi sửa:" -ForegroundColor Yellow
$before = ($csv | Where-Object { $_.'Primary Completion Rate (%)' -and $_.'Primary Completion Rate (%)' -ne "0" }).Count
Write-Host "  Có dữ liệu thực: $before rows" -ForegroundColor White

# Replace 0 with N/A in Primary Completion Rate
$fixed = 0
foreach ($row in $csv) {
    $val = $row.'Primary Completion Rate (%)'
    if ($val -eq "0" -or $val -eq "0.0" -or $val -eq "0.00") {
        $row.'Primary Completion Rate (%)' = "N/A"
        $fixed++
    }
}

# Save
$csv | Export-Csv "src\data\vietnam_advance.csv" -Encoding UTF8 -NoTypeInformation

Write-Host "`n✓ Đã chuyển $fixed giá trị '0' thành 'N/A'" -ForegroundColor Green

Write-Host "`nSau khi sửa:" -ForegroundColor Yellow
$csv = Import-Csv "src\data\vietnam_advance.csv" -Encoding UTF8
$after = ($csv | Where-Object { $_.'Primary Completion Rate (%)' -and $_.'Primary Completion Rate (%)' -ne "N/A" }).Count
$naCount = ($csv | Where-Object { $_.'Primary Completion Rate (%)' -eq "N/A" }).Count

Write-Host "  Có dữ liệu thực: $after rows" -ForegroundColor Green
Write-Host "  Giá trị N/A: $naCount rows" -ForegroundColor Gray

Write-Host "`n📋 Các năm có dữ liệu Primary Completion Rate:" -ForegroundColor Cyan
$withData = $csv | Where-Object { $_.'Primary Completion Rate (%)' -ne "N/A" }
foreach ($row in $withData) {
    Write-Host "  Year $($row.Year): $($row.'Primary Completion Rate (%)')%" -ForegroundColor White
}

Write-Host "`n✅ Hoàn tất!" -ForegroundColor Green
