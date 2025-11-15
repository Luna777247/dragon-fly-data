# Integrate UNESCO Primary Completion Rate from World Bank API
$data = Get-Content 'wb_unesco_primary_completion.json' | ConvertFrom-Json

# Extract Vietnam data (VNM)
$vietnamData = $data[1] | Where-Object { $_.countryiso3code -eq 'VNM' }

# Create hashtable for year -> value mapping
$primaryCompletion = @{}
foreach ($entry in $vietnamData) {
    $year = $entry.date
    $value = $entry.value
    if ($null -ne $value -and $value) {
        $primaryCompletion[$year] = [math]::Round($value, 1)
    }
}

Write-Host "UNESCO Primary Completion Rate data for Vietnam:" -ForegroundColor Green
$primaryCompletion.GetEnumerator() | Sort-Object Name | ForEach-Object {
    Write-Host "$($_.Key): $($_.Value)%"
}

# Update CSV - add the column if it doesn't exist
$csv = Import-Csv 'src/data/vietnam_advance.csv'

# Check if column exists, if not add it
$columnExists = $csv[0].PSObject.Properties.Name -contains 'Primary Completion Rate (%)'
if (-not $columnExists) {
    Write-Host "Adding 'Primary Completion Rate (%)' column to CSV..." -ForegroundColor Yellow
    # Add the column to each row
    foreach ($row in $csv) {
        $row | Add-Member -MemberType NoteProperty -Name 'Primary Completion Rate (%)' -Value $null -Force
    }
}

foreach ($row in $csv) {
    $year = $row.Year
    if ($primaryCompletion.ContainsKey($year)) {
        $row.'Primary Completion Rate (%)' = $primaryCompletion[$year]
    }
}

$csv | Export-Csv 'src/data/vietnam_advance.csv' -NoTypeInformation -Encoding UTF8

Write-Host ""
Write-Host "UNESCO Primary Completion Rate integrated successfully!" -ForegroundColor Green