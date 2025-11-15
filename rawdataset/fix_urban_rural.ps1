# Fix Urban + Rural = Total Population
Write-Host "🔧 SỬA URBAN + RURAL = TOTAL" -ForegroundColor Cyan
Write-Host "=" * 72 -ForegroundColor DarkGray

$csv = Import-Csv "vietnam_population.csv" -Encoding UTF8

$fixCount = 0

foreach($row in $csv) {
    $year = [int]$row.Year
    $total = $row.Population
    $urban = $row.'Urban Population'
    $rural = $row.'Rural Population'
    
    # Skip if no population data
    if(!$total -or $total -eq "N/A") { continue }
    
    try {
        $totalNum = [long]$total
        $urbanNum = if($urban -and $urban -ne "N/A") {[double]$urban} else {0}
        $ruralNum = if($rural -and $rural -ne "N/A") {[double]$rural} else {0}
        
        # Current sum
        $currentSum = $urbanNum + $ruralNum
        
        # Check if there's a significant difference
        $diffPct = if($currentSum -gt 0) {([Math]::Abs($totalNum - $currentSum) / $totalNum) * 100} else {100}
        
        if($diffPct -gt 1) {
            # Strategy: Keep Urban as-is, calculate Rural = Total - Urban
            # (Urban data is more reliable as it's usually from census)
            
            if($urbanNum -gt 0) {
                $newRural = $totalNum - [long]$urbanNum
                
                # Update Rural Population
                $row.'Rural Population' = [string]$newRural
                $fixCount++
                
                Write-Host ("   • Năm {0}: Total={1:N0}, Urban={2:N0}, Rural {3:N0} → {4:N0}" -f `
                    $year, $totalNum, [long]$urbanNum, [long]$ruralNum, $newRural) -ForegroundColor Yellow
            }
            elseif($ruralNum -gt 0) {
                # If only Rural exists, calculate Urban = Total - Rural
                $newUrban = $totalNum - [long]$ruralNum
                
                # Update Urban Population
                $row.'Urban Population' = [string]$newUrban
                $fixCount++
                
                Write-Host ("   • Năm {0}: Total={1:N0}, Rural={2:N0}, Urban {3:N0} → {4:N0}" -f `
                    $year, $totalNum, [long]$ruralNum, [long]$urbanNum, $newUrban) -ForegroundColor Yellow
            }
        }
    } catch {
        Write-Host "   ⚠️  Năm $year`: Lỗi - $_" -ForegroundColor Red
    }
}

# Save fixed CSV
$csv | Export-Csv "vietnam_population.csv" -Encoding UTF8 -NoTypeInformation

Write-Host "`n✅ Đã sửa $fixCount giá trị" -ForegroundColor Green

# Final verification
Write-Host "`n🔍 XÁC MINH:" -ForegroundColor Cyan
$csv2 = Import-Csv "vietnam_population.csv" -Encoding UTF8
$problems = 0
foreach($row in $csv2) {
    $total = $row.Population
    $urban = $row.'Urban Population'
    $rural = $row.'Rural Population'
    
    if($total -and $total -ne "N/A" -and $urban -and $urban -ne "N/A" -and $rural -and $rural -ne "N/A") {
        try {
            $t = [long]$total
            $u = [long][double]$urban
            $r = [long][double]$rural
            $sum = $u + $r
            $diff = ([Math]::Abs($t - $sum) / $t) * 100
            
            if($diff -gt 0.1) {
                Write-Host ("   ⚠️  Năm {0}: Total={1:N0}, U+R={2:N0}, Chênh={3}%" -f $row.Year, $t, $sum, $diff.ToString("0.00")) -ForegroundColor Red
                $problems++
            }
        } catch {}
    }
}

if($problems -eq 0) {
    Write-Host "   ✅ Tất cả các năm đã khớp!" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Còn $problems năm chưa khớp" -ForegroundColor Red
}
