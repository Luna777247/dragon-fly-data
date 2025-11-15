# Check value ranges for all columns in vietnam_population.csv
Write-Host "╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║       KIỂM TRA PHẠM VI GIÁ TRỊ - VIETNAM_POPULATION.CSV               ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$csv = Import-Csv "vietnam_population.csv" -Encoding UTF8

Write-Host "`n🔍 Phân tích phạm vi giá trị từng cột:" -ForegroundColor Yellow

$columns = ($csv[0].PSObject.Properties.Name)
$issues = @()

foreach ($col in $columns) {
    if ($col -eq "Year") { continue }
    
    # Get numeric values only
    $numericValues = $csv | ForEach-Object { 
        $val = $_.$col
        if ($val -and $val -ne "" -and $val -ne "N/A" -and $val -ne "null") {
            try {
                [double]$val
            } catch {
                $null
            }
        }
    } | Where-Object { $_ -ne $null }
    
    if ($numericValues.Count -gt 0) {
        $min = ($numericValues | Measure-Object -Minimum).Minimum
        $max = ($numericValues | Measure-Object -Maximum).Maximum
        $avg = [math]::Round(($numericValues | Measure-Object -Average).Average, 2)
        
        # Check for suspicious values
        $suspicious = $false
        $reason = ""
        
        # Population should be millions
        if ($col -eq "Population" -and ($min -lt 10000000 -or $max -gt 200000000)) {
            $suspicious = $true
            $reason = "Dân số nên từ 10-200 triệu"
        }
        
        # GDP per capita typically $100-$20000 for Vietnam
        if ($col -match "GDP per Capita" -and ($min -lt 0 -or $max -gt 50000)) {
            $suspicious = $true
            $reason = "GDP/người nên từ 0-50000 USD"
        }
        
        # Rates/percentages should be 0-100
        if ($col -match "Rate|Ratio|%|\(%\)" -and $col -notmatch "Sex Ratio" -and ($min -lt -10 -or $max -gt 150)) {
            $suspicious = $true
            $reason = "Tỷ lệ % nên từ 0-100"
        }
        
        # HDI should be 0-1
        if ($col -eq "HDI" -and ($min -lt 0 -or $max -gt 10)) {
            $suspicious = $true
            $reason = "HDI nên từ 0-1"
        }
        
        # Life expectancy 40-90 years
        if ($col -match "Life Expectancy" -and ($min -lt 40 -or $max -gt 100)) {
            $suspicious = $true
            $reason = "Tuổi thọ nên từ 40-100 năm"
        }
        
        # Age 15-50 years
        if ($col -match "Median Age" -and ($min -lt 15 -or $max -gt 60)) {
            $suspicious = $true
            $reason = "Tuổi trung vị nên từ 15-60"
        }
        
        # Fertility rate 1-7
        if ($col -match "Fertility" -and ($min -lt 0.5 -or $max -gt 10)) {
            $suspicious = $true
            $reason = "Tỷ lệ sinh nên từ 1-7"
        }
        
        $color = if ($suspicious) { "Red" } else { "White" }
        $status = if ($suspicious) { "⚠️" } else { "✓" }
        
        Write-Host "`n$status $col" -ForegroundColor $color
        Write-Host "   Min: $min | Max: $max | Avg: $avg" -ForegroundColor Gray
        
        if ($suspicious) {
            Write-Host "   → Cảnh báo: $reason" -ForegroundColor Yellow
            
            # Show sample values
            $sample = $csv | Where-Object { 
                $val = $_.$col
                $val -and $val -ne "" -and $val -ne "N/A"
            } | Select-Object -First 3 | ForEach-Object { "$($_.Year): $($_.$col)" }
            
            Write-Host "   → Mẫu: $($sample -join ', ')" -ForegroundColor DarkGray
            
            $issues += [PSCustomObject]@{
                Column = $col
                Min = $min
                Max = $max
                Avg = $avg
                Reason = $reason
            }
        }
    } else {
        Write-Host "`n○ $col" -ForegroundColor DarkGray
        Write-Host "   → Không có giá trị số" -ForegroundColor DarkGray
    }
}

if ($issues.Count -gt 0) {
    Write-Host "`n╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║                    CÁC CỘT CẦN KIỂM TRA                                ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Red
    
    foreach ($issue in $issues) {
        Write-Host "`n⚠️ $($issue.Column)" -ForegroundColor Yellow
        Write-Host "   Min: $($issue.Min) | Max: $($issue.Max) | Avg: $($issue.Avg)" -ForegroundColor White
        Write-Host "   Lý do: $($issue.Reason)" -ForegroundColor Gray
    }
    
    Write-Host "`n📝 Tổng số cột có vấn đề: $($issues.Count)" -ForegroundColor Red
    
    # Export issues
    $issues | Export-Csv "value_range_issues.csv" -Encoding UTF8 -NoTypeInformation
    Write-Host "✅ Đã lưu báo cáo: value_range_issues.csv" -ForegroundColor Green
} else {
    Write-Host "`n✅ Tất cả các cột đều có giá trị hợp lý!" -ForegroundColor Green
}
