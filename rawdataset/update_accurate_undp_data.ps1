# Update CSV with accurate UNDP/HDR data from World Bank
Write-Host "=== Updating with accurate UNDP/HDR data ===" -ForegroundColor Cyan

# Load CSV
$csv = Import-Csv "src\data\vietnam_advance.csv"

# Function to update column with data
function Update-Column {
    param($JsonFile, $ColumnName, $Transform = $null)
    
    if (-not (Test-Path $JsonFile)) {
        Write-Host "⚠ File not found: $JsonFile" -ForegroundColor Yellow
        return 0
    }
    
    try {
        $json = Get-Content $JsonFile -Raw | ConvertFrom-Json
        
        # Handle different JSON structures
        if ($json.Count -gt 1 -and $json[1].value) {
            # New format: data is in json[1].value array
            $data = $json[1].value | Where-Object { $null -ne $_.value }
        } else {
            # Old format: data is in json[1] directly
            $data = $json[1] | Where-Object { $_.countryiso3code -eq 'VNM' -and $null -ne $_.value }
        }
        
        # Create lookup hashtable
        $lookup = @{}
        foreach ($item in $data) {
            $lookup[$item.date] = $item.value
        }
        
        $updates = 0
        foreach ($row in $csv) {
            $year = $row.Year
            if ($lookup.ContainsKey($year)) {
                $value = $lookup[$year]
                if ($Transform) {
                    $value = & $Transform $value
                }
                $row.$ColumnName = $value
                $updates++
            }
        }
        
        Write-Host "  ✓ $ColumnName : $updates rows updated" -ForegroundColor Green
        return $updates
    }
    catch {
        Write-Host "  ✗ Error with $JsonFile : $_" -ForegroundColor Red
        return 0
    }
}

$totalUpdates = 0

# Update Poverty Rate with $2.15/day (more recent standard)
Write-Host "`nUpdating Poverty Rate..." -ForegroundColor Cyan
$totalUpdates += Update-Column "wb_SI_POV_LMIC.json" "Poverty Rate (%)" { param($v) [math]::Round($v, 2) }

# Update Mean Years of Schooling
Write-Host "`nUpdating Mean Years of Schooling..." -ForegroundColor Cyan
$totalUpdates += Update-Column "wb_HD_HCI_LAYS.json" "Mean Years of Schooling" { param($v) [math]::Round($v, 2) }

# Update Human Capital Index
Write-Host "`nUpdating Human Capital Index..." -ForegroundColor Cyan
$totalUpdates += Update-Column "wb_HD_HCI_OVRL.json" "Human Capital Index (0-1)" { param($v) [math]::Round($v, 3) }

# Update GNI per Capita (PPP)
Write-Host "`nUpdating GNI per Capita..." -ForegroundColor Cyan
$totalUpdates += Update-Column "wb_NY_GNP_PCAP_PP_CD.json" "GNI per Capita (USD)" { param($v) [math]::Round($v, 0) }

# Update Expected Years of Schooling (if available)
Write-Host "`nUpdating Expected Years of Schooling..." -ForegroundColor Cyan
$totalUpdates += Update-Column "wb_SE_SCH_LIFE.json" "Expected Years of Schooling" { param($v) [math]::Round($v, 2) }

# Update Education Index (using Education Expenditure as proxy)
Write-Host "`nUpdating Education Index..." -ForegroundColor Cyan
$totalUpdates += Update-Column "wb_SE_XPD_TOTL_GD_ZS.json" "Education Index" { param($v) [math]::Round($v, 2) }

# Save updated CSV
$csv | Export-Csv "src\data\vietnam_advance.csv" -NoTypeInformation -Encoding UTF8

Write-Host "`n=== Update Complete ===" -ForegroundColor Green
Write-Host "Total updates: $totalUpdates" -ForegroundColor Cyan

# Verify 2020 data
Write-Host "`n=== Verification (2020 data) ===" -ForegroundColor Yellow
$row2020 = $csv | Where-Object { $_.Year -eq '2020' }
if ($row2020) {
    Write-Host "Poverty Rate: $($row2020.'Poverty Rate (%)') %" -ForegroundColor White
    Write-Host "Mean Years of Schooling: $($row2020.'Mean Years of Schooling') years" -ForegroundColor White
    Write-Host "Human Capital Index: $($row2020.'Human Capital Index (0-1)')" -ForegroundColor White
    Write-Host "GNI per Capita: `$$($row2020.'GNI per Capita (USD)')" -ForegroundColor White
    Write-Host "Expected Years Schooling: $($row2020.'Expected Years of Schooling') years" -ForegroundColor White
    Write-Host "Education Index: $($row2020.'Education Index')" -ForegroundColor White
}

# Verify 2022 data
Write-Host "`n=== Verification (2022 data) ===" -ForegroundColor Yellow
$row2022 = $csv | Where-Object { $_.Year -eq '2022' }
if ($row2022) {
    Write-Host "Poverty Rate: $($row2022.'Poverty Rate (%)') %" -ForegroundColor White
    Write-Host "GNI per Capita: `$$($row2022.'GNI per Capita (USD)')" -ForegroundColor White
    Write-Host "Education Index: $($row2022.'Education Index')" -ForegroundColor White
}
