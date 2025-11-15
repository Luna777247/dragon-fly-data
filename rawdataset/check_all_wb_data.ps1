# Check latest data availability in all World Bank JSON files
Write-Host "Checking latest data availability in all World Bank files..." -ForegroundColor Green
Write-Host ""

$files = Get-ChildItem "wb_*.json"

$results = @()

foreach ($file in $files) {
    $fileName = $file.Name -replace 'wb_', '' -replace '.json', ''
    $filePath = $file.FullName

    try {
        $data = Get-Content $filePath | ConvertFrom-Json
        $vietnamData = $data[1] | Where-Object { $_.countryiso3code -eq 'VNM' -and $null -ne $_.value } | Sort-Object date -Descending
        $latest = $vietnamData | Select-Object -First 1

        if ($latest) {
            $results += @{
                FileName = $fileName
                Year = $latest.date
                Value = $latest.value
                Indicator = $latest.indicator.id
                Description = $latest.indicator.value
            }
        }
    }
    catch {
        Write-Host "Error reading ${fileName}: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Display results sorted by year (newest first)
$results | Sort-Object Year -Descending | ForEach-Object {
    $fileName = $_.FileName
    $year = $_.Year
    $value = $_.Value
    $description = $_.Description

    Write-Host "${fileName}: ${year} = ${value} (${description})" -ForegroundColor Green
}

Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "Total files with data: $($results.Count)"
$latestYear = ($results | Sort-Object Year -Descending | Select-Object -First 1).Year
Write-Host "Most recent data year: $latestYear"

# Group by year to see data availability
Write-Host ""
Write-Host "Data by year:" -ForegroundColor Yellow
$results | Group-Object Year | Sort-Object Name -Descending | Select-Object -First 5 | ForEach-Object {
    Write-Host "  $($_.Name): $($_.Count) indicators"
}