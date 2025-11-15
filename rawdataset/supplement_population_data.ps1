# Fetch data from World Bank API for GOOD columns
Write-Host "╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║      BỔ SUNG DỮ LIỆU TỪ WORLD BANK API - VIETNAM_POPULATION.CSV       ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$indicators = @{
    "NY.GDP.PCAP.CD" = "GDP per Capita (USD)"
    "NY.GDP.PCAP.PP.CD" = "GDP PPP per Capita (Int$)"
    "NY.GDP.MKTP.KD.ZG" = "GDP Growth Rate (%)"
    "BX.KLT.DINV.CD.WD" = "FDI Net Inflows (million USD)"
    "SL.UEM.TOTL.ZS" = "Unemployment Rate (%)"
}

$allData = @{}

foreach ($indicator in $indicators.Keys) {
    $columnName = $indicators[$indicator]
    Write-Host "`n🔍 Đang tải: $columnName ($indicator)..." -ForegroundColor Yellow
    
    try {
        $url = "https://api.worldbank.org/v2/country/VNM/indicator/$indicator`?format=json&per_page=100&date=1955:2025"
        $response = Invoke-RestMethod -Uri $url -Method Get -ErrorAction Stop
        
        if ($response -and $response.Count -gt 1 -and $response[1]) {
            $data = $response[1]
            Write-Host "   ✓ Tải thành công: $($data.Count) bản ghi" -ForegroundColor Green
            
            $allData[$columnName] = @{}
            foreach ($item in $data) {
                if ($item.value -ne $null) {
                    $year = [int]$item.date
                    $value = $item.value
                    
                    # Convert FDI from current USD to million USD
                    if ($columnName -eq "FDI Net Inflows (million USD)") {
                        $value = [math]::Round($value / 1000000, 2)
                    }
                    
                    $allData[$columnName][$year] = $value
                }
            }
            
            Write-Host "   → Số năm có dữ liệu: $($allData[$columnName].Count)" -ForegroundColor Gray
            
            # Show sample years
            $sampleYears = $allData[$columnName].Keys | Sort-Object | Select-Object -First 3
            $latestYears = $allData[$columnName].Keys | Sort-Object -Descending | Select-Object -First 3
            Write-Host "   → Năm đầu: $($sampleYears -join ', ')" -ForegroundColor DarkGray
            Write-Host "   → Năm gần: $($latestYears -join ', ')" -ForegroundColor DarkGray
        } else {
            Write-Host "   ⚠ Không có dữ liệu" -ForegroundColor Red
        }
        
        Start-Sleep -Milliseconds 500  # Rate limiting
        
    } catch {
        Write-Host "   ✗ Lỗi: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Update CSV file
Write-Host "`n📝 Đang cập nhật file CSV..." -ForegroundColor Cyan

$csv = Import-Csv "vietnam_population.csv" -Encoding UTF8

$updateCount = @{}
foreach ($col in $indicators.Values) {
    $updateCount[$col] = 0
}

foreach ($row in $csv) {
    $year = [int]$row.Year
    
    foreach ($columnName in $indicators.Values) {
        if ($allData.ContainsKey($columnName) -and $allData[$columnName].ContainsKey($year)) {
            $currentValue = $row.$columnName
            
            # Only update if current value is 0, 0.0, or empty
            if ($currentValue -eq "0" -or $currentValue -eq "0.0" -or $currentValue -eq "0.00" -or $currentValue -eq "") {
                $newValue = $allData[$columnName][$year]
                $row.$columnName = $newValue
                $updateCount[$columnName]++
            }
        }
    }
}

# Save updated CSV
$csv | Export-Csv "vietnam_population.csv" -Encoding UTF8 -NoTypeInformation

Write-Host "`n✅ Cập nhật hoàn tất!" -ForegroundColor Green
Write-Host "`n📊 Thống kê cập nhật:" -ForegroundColor Cyan

foreach ($col in $indicators.Values | Sort-Object) {
    $count = $updateCount[$col]
    Write-Host "   • $col`: $count giá trị" -ForegroundColor $(if ($count -gt 0) { "Green" } else { "Gray" })
}

Write-Host "`n✅ File đã được lưu: vietnam_population.csv" -ForegroundColor Green
Write-Host "   Chạy lại verify_population_csv.ps1 để kiểm tra kết quả" -ForegroundColor Gray
