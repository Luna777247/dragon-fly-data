# Check all available indicators and their latest data
Write-Host "=== CHECKING ALL AVAILABLE INDICATORS ===" -ForegroundColor Cyan
Write-Host ""

$allIndicators = @(
    @{File="wb_unesco_mean_schooling.json"; Description="Mean Years of Schooling"},
    @{File="wb_unesco_expected_schooling.json"; Description="Expected Years of Schooling"},
    @{File="wb_co2_emissions.json"; Description="CO2 Emissions per Capita"},
    @{File="wb_who_infant_mortality.json"; Description="Infant Mortality"},
    @{File="wb_who_under5_mortality.json"; Description="Under-5 Mortality"}
)

$results = @()

foreach ($indicator in $allIndicators) {
    $file = $indicator.File
    $description = $indicator.Description

    if (Test-Path $file) {
        try {
            $data = Get-Content $file | ConvertFrom-Json
            $vietnamData = $data[1] | Where-Object { $_.countryiso3code -eq 'VNM' -and $null -ne $_.value } | Sort-Object date -Descending
            
            if ($vietnamData.Count -gt 0) {
                $latest = $vietnamData | Select-Object -First 1
                $recent5 = $vietnamData | Select-Object -First 5
                
                Write-Host "${description}:" -ForegroundColor Green
                Write-Host "  Latest: $($latest.date) = $($latest.value)" -ForegroundColor Yellow
                Write-Host "  Recent 5 years:" -ForegroundColor Gray
                $recent5 | ForEach-Object {
                    Write-Host "    $($_.date): $($_.value)"
                }
                Write-Host ""
                
                $results += @{
                    Indicator = $description
                    File = $file
                    LatestYear = $latest.date
                    LatestValue = $latest.value
                    Available = $true
                }
            } else {
                Write-Host "${description}: No data available" -ForegroundColor Red
                $results += @{
                    Indicator = $description
                    File = $file
                    Available = $false
                }
            }
        }
        catch {
            Write-Host "${description}: Error reading file - $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "${description}: File not found" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== SUMMARY ===" -ForegroundColor Cyan
$availableCount = ($results | Where-Object { $_.Available -eq $true }).Count
Write-Host "Total indicators checked: $($results.Count)"
Write-Host "Available with data: $availableCount"
Write-Host "Not available: $($results.Count - $availableCount)"