# Integrate UNDP/HDR indicators into vietnam_advance.csv
Write-Host "=== Integrating UNDP/HDR indicators ===" -ForegroundColor Cyan

# Load the main CSV
$csv = Import-Csv "src\data\vietnam_advance.csv"

# Column mappings based on CSV header
$columnMappings = @{
    # Poverty indicators
    "SI_POV_DDAY" = @{Column=27; File="wb_SI_POV_DDAY.json"; Name="Poverty Rate ($1.90/day)"}
    "SI_POV_NAHC" = @{Column=27; File="wb_SI_POV_NAHC.json"; Name="Poverty Rate (National)"}
    
    # Education indicators
    "HD_HCI_LAYS" = @{Column=59; File="wb_HD_HCI_LAYS.json"; Name="Mean Years of Schooling"}
    "SE_SCH_LIFE" = @{Column=69; File="wb_SE_SCH_LIFE.json"; Name="Expected Years of Schooling"}
    
    # Human Capital Index
    "HD_HCI_OVRL" = @{Column=35; File="wb_HD_HCI_OVRL.json"; Name="Human Capital Index"}
    
    # Additional useful indicators
    "SI_POV_GINI" = @{Column=74; File="wb_SI_POV_GINI.json"; Name="Gini coefficient"}  # Can use Education Index column
    "NY_GNP_PCAP_PP_CD" = @{Column=60; File="wb_NY_GNP_PCAP_PP_CD.json"; Name="GNI per Capita PPP"}
}

$totalUpdates = 0

foreach ($mapping in $columnMappings.GetEnumerator()) {
    $columnIndex = $mapping.Value.Column
    $fileName = $mapping.Value.File
    $indicatorName = $mapping.Value.Name
    
    if (-not (Test-Path $fileName)) {
        Write-Host "⚠ File not found: $fileName" -ForegroundColor Yellow
        continue
    }
    
    Write-Host "`nProcessing $indicatorName..." -ForegroundColor Cyan
    
    try {
        $jsonContent = Get-Content $fileName -Raw | ConvertFrom-Json
        
        if ($jsonContent.Count -gt 1) {
            $data = $jsonContent[1] | Where-Object { $_.countryiso3code -eq 'VNM' -and $null -ne $_.value }
            
            # Create a hashtable for quick lookup
            $dataHash = @{}
            foreach ($item in $data) {
                $dataHash[$item.date] = $item.value
            }
            
            $updates = 0
            foreach ($row in $csv) {
                $year = $row.Year.Trim('"')
                
                if ($dataHash.ContainsKey($year)) {
                    $value = $dataHash[$year]
                    
                    # Round appropriately
                    if ($mapping.Key -eq "HD_HCI_OVRL") {
                        $value = [math]::Round($value, 3)  # Human Capital Index: 3 decimals
                    } elseif ($mapping.Key -like "SI_POV_*") {
                        $value = [math]::Round($value, 2)  # Poverty rates: 2 decimals
                    } elseif ($mapping.Key -like "*LAYS" -or $mapping.Key -like "*LIFE") {
                        $value = [math]::Round($value, 2)  # Years of schooling: 2 decimals
                    } else {
                        $value = [math]::Round($value, 2)
                    }
                    
                    # Get the column header name
                    $columns = $row.PSObject.Properties.Name
                    $columnName = $columns[$columnIndex]
                    
                    # Update the value
                    $row.$columnName = $value
                    $updates++
                    $totalUpdates++
                }
            }
            
            if ($updates -gt 0) {
                Write-Host "  ✓ Updated $updates rows for $indicatorName" -ForegroundColor Green
            } else {
                Write-Host "  ⚠ No matching years found" -ForegroundColor Yellow
            }
        }
    } catch {
        Write-Host "  ✗ Error processing $fileName : $_" -ForegroundColor Red
    }
}

# Save the updated CSV
$csv | Export-Csv "src\data\vietnam_advance.csv" -NoTypeInformation -Encoding UTF8
Write-Host "`n=== Integration Complete ===" -ForegroundColor Green
Write-Host "Total updates: $totalUpdates" -ForegroundColor Cyan

# Verify some data
Write-Host "`nVerifying integrated data (year 2022):" -ForegroundColor Yellow
$row2022 = $csv | Where-Object { $_.Year -eq '"2022"' -or $_.Year -eq '2022' }
if ($row2022) {
    Write-Host "  Poverty Rate: $($row2022.'Poverty Rate (%)')" -ForegroundColor White
    Write-Host "  Mean Years of Schooling: $($row2022.'Mean Years of Schooling')" -ForegroundColor White
    Write-Host "  Human Capital Index: $($row2022.'Human Capital Index (0-1)')" -ForegroundColor White
    Write-Host "  GNI per Capita: $($row2022.'GNI per Capita (USD)')" -ForegroundColor White
}
