# Fix Urban Population - Version 2: Calculate Urban% first, then recalculate Urban/Rural
Write-Host "🔧 SỬA URBAN POPULATION V2" -ForegroundColor Cyan
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
    
    # Skip if no population data
    if(!$total -or $total -eq "N/A") { continue }
    
    try {
        $totalNum = [long]$total
        $urbanNum = if($urban -and $urban -ne "N/A") {[double]$urban} else {0}
        $ruralNum = if($rural -and $rural -ne "N/A") {[double]$rural} else {0}
        
        # Current sum
        $currentSum = $urbanNum + $ruralNum
        
        # Check if there's a significant difference (>1% or sum=0)
        $diffPct = if($currentSum -gt 0) {([Math]::Abs($totalNum - $currentSum) / $totalNum) * 100} else {100}
        
        if($diffPct -gt 1) {
            # Calculate Urban% from Urban/Total if available, otherwise use existing Urban%
            $correctUrbanPct = 0
            
            if($urbanPct -and $urbanPct -ne "N/A" -and $urbanPct -ne "") {
                $correctUrbanPct = [double]$urbanPct
            }
            elseif($urbanNum -gt 0 -and $totalNum -gt 0) {
                # Calculate Urban% from Urban/Total
                $correctUrbanPct = ($urbanNum / $totalNum) * 100
                # Update Urban% column
                $row.'Urban Pop %' = [Math]::Round($correctUrbanPct, 2).ToString()
            }
            else {
                # No Urban data available, skip
                continue
            }
            
            # Calculate correct urban and rural populations
            $correctUrban = [long]($totalNum * $correctUrbanPct / 100)
            $correctRural = $totalNum - $correctUrban
            
            $oldUrban = $urbanNum
            $oldRural = $ruralNum
            
            # Update values
            $row.'Urban Population' = [string]$correctUrban
            $row.'Rural Population' = [string]$correctRural
            $fixCount++
            
            $issues += [PSCustomObject]@{
                Year = $year
                Total = $totalNum
                UrbanPct = [Math]::Round($correctUrbanPct, 2)
                OldUrban = [long]$oldUrban
                OldRural = [long]$oldRural
                NewUrban = $correctUrban
                NewRural = $correctRural
                OldSum = [long]$currentSum
                DiffPct = [Math]::Round($diffPct, 2)
            }
            
            Write-Host ("   • Năm {0}: Urban% {1}%, Old U+R={2:N0} (chênh {3}%), New U={4:N0}, R={5:N0}" -f `
                $year, $correctUrbanPct.ToString("0.00"), [long]$currentSum, $diffPct.ToString("0.00"), $correctUrban, $correctRural) -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   ⚠️  Năm $year`: Lỗi - $_" -ForegroundColor Red
    }
}

# Save fixed CSV
$csv | Export-Csv "vietnam_population.csv" -Encoding UTF8 -NoTypeInformation

Write-Host "`n✅ Đã sửa $fixCount giá trị Urban/Rural" -ForegroundColor Green

if($issues.Count -gt 0) {
    Write-Host "`n📊 Chi tiết (10 năm đầu):" -ForegroundColor Cyan
    $issues | Select-Object -First 10 | Format-Table Year, Total, UrbanPct, OldSum, NewUrban, NewRural, DiffPct -AutoSize
}

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
            
            if($diff -gt 1) {
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
