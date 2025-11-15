# Fix Urban Population specifically
Write-Host "🔧 SỬA URBAN POPULATION" -ForegroundColor Cyan
Write-Host "=" * 72 -ForegroundColor DarkGray

$csv = Import-Csv "vietnam_population.csv" -Encoding UTF8

$fixCount = 0
$issues = @()

foreach($row in $csv) {
    $year = [int]$row.Year
    $total = $row.Population
    $urbanPct = $row.'Urban Pop %'
    $urban = $row.'Urban Population'
    $rural = $row.'Rural Population'
    
    if($total -and $urbanPct -and $total -ne "N/A" -and $urbanPct -ne "N/A") {
        try {
            $totalNum = [long]$total
            $urbanPctNum = [double]$urbanPct
            $urbanNum = if($urban -and $urban -ne "N/A" -and $urban -ne "0") {[long]$urban} else {0}
            $ruralNum = if($rural -and $rural -ne "N/A" -and $rural -ne "0") {[long]$rural} else {0}
            
            # Calculate correct urban population from percentage
            $correctUrban = [long]($totalNum * $urbanPctNum / 100)
            $correctRural = $totalNum - $correctUrban
            
            # Calculate current sum
            $currentSum = $urbanNum + $ruralNum
            
            # Check if there's a significant difference
            if($currentSum -eq 0) {
                # No data, fill it in
                $row.'Urban Population' = [string]$correctUrban
                $row.'Rural Population' = [string]$correctRural
                $fixCount++
                Write-Host "   • Năm $year`: Tính mới Urban=$('{0:N0}' -f $correctUrban), Rural=$('{0:N0}' -f $correctRural)" -ForegroundColor Green
            }
            else {
                $diffPct = ([Math]::Abs($totalNum - $currentSum) / $totalNum) * 100
                
                if($diffPct -gt 1) {
                    $oldUrban = $urbanNum
                    $oldRural = $ruralNum
                    $row.'Urban Population' = [string]$correctUrban
                    $row.'Rural Population' = [string]$correctRural
                    $fixCount++
                    
                    $issues += [PSCustomObject]@{
                        Year = $year
                        Total = $totalNum
                        OldUrban = $oldUrban
                        OldRural = $oldRural
                        NewUrban = $correctUrban
                        NewRural = $correctRural
                        OldSum = $currentSum
                        DiffPct = [Math]::Round($diffPct, 2)
                    }
                    
                    Write-Host "   • Năm $year`: Urban $('{0:N0}' -f $oldUrban) → $('{0:N0}' -f $correctUrban)" -ForegroundColor Yellow
                }
            }
        } catch {
            Write-Host "   ⚠️  Năm $year`: Lỗi xử lý - $_" -ForegroundColor Red
        }
    }
}

# Save fixed CSV
$csv | Export-Csv "vietnam_population.csv" -Encoding UTF8 -NoTypeInformation

Write-Host "`n✅ Đã sửa $fixCount giá trị Urban/Rural Population" -ForegroundColor Green

if($issues.Count -gt 0) {
    Write-Host "`n📊 Chi tiết các năm đã sửa:" -ForegroundColor Cyan
    $issues | Select-Object -First 10 | ForEach-Object {
        Write-Host ("   {0}: Total={1:N0}, Old U+R={2:N0} (chênh {3}%), New U+R={4:N0}" -f `
            $_.Year, $_.Total, $_.OldSum, $_.DiffPct, ($_.NewUrban + $_.NewRural)) -ForegroundColor Gray
    }
    
    if($issues.Count -gt 10) {
        Write-Host "   ... và $($issues.Count - 10) năm khác" -ForegroundColor DarkGray
    }
}

# Verify
Write-Host "`n🔍 XÁC MINH:" -ForegroundColor Cyan
$stillBad = 0
foreach($row in $csv) {
    $total = $row.Population
    $urban = $row.'Urban Population'
    $rural = $row.'Rural Population'
    
    if($total -and $urban -and $rural -and 
       $total -ne "N/A" -and $urban -ne "N/A" -and $rural -ne "N/A" -and
       $urban -ne "0" -and $rural -ne "0") {
        try {
            $totalNum = [long]$total
            $sum = [long]$urban + [long]$rural
            $diffPct = ([Math]::Abs($totalNum - $sum) / $totalNum) * 100
            if($diffPct -gt 1) {
                $stillBad++
                Write-Host "   ⚠️  Năm $($row.Year): Total=$totalNum, U+R=$sum, Chênh=$diffPct%" -ForegroundColor Red
            }
        } catch {}
    }
}

if($stillBad -eq 0) {
    Write-Host "   ✅ Tất cả các năm đã khớp (Urban + Rural = Total)" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Còn $stillBad năm chưa khớp" -ForegroundColor Yellow
}
