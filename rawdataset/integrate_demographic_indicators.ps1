# Integrate all demographic indicators into CSV
Write-Host "Integrating demographic indicators into CSV..." -ForegroundColor Green

$demographicIndicators = @(
    @{File="wb_fertility_rate.json"; ColumnIndex=19; Description="Fertility Rate"},
    @{File="wb_birth_rate.json"; ColumnIndex=21; Description="Birth Rate (‰)"},
    @{File="wb_death_rate.json"; ColumnIndex=22; Description="Death Rate (‰)"},
    @{File="wb_rural_population.json"; ColumnIndex=28; Description="Rural Population"; Transform={ param($v) [math]::Round($v, 0) }},
    @{File="wb_urban_population.json"; ColumnIndex=29; Description="Urban Population"; Transform={ param($v) [math]::Round($v, 0) }},
    @{File="wb_population_density.json"; ColumnIndex=39; Description="Density (P/Km²)"},
    @{File="wb_pop_0_14.json"; ColumnIndex=10; Description="Pop Aged 0–14 (%)"},
    @{File="wb_pop_15_64.json"; ColumnIndex=11; Description="Pop Aged 15–64 (%)"},
    @{File="wb_pop_65plus.json"; ColumnIndex=12; Description="Pop Aged 65+ (%)"},
    @{File="wb_dependency_ratio.json"; ColumnIndex=8; Description="Dependency Ratio (%)"}
)

$csvPath = 'src/data/vietnam_advance.csv'
$csvContent = Get-Content $csvPath -Encoding UTF8
$updatedLines = @()

Write-Host "Processing CSV..." -ForegroundColor Yellow
$updateCount = 0

foreach ($line in $csvContent) {
    $columns = $line -split ','
    $year = $columns[0].Trim('"')

    if ($year -match '^\d{4}$' -and [int]$year -ge 1960 -and [int]$year -le 2024) {
        $updated = $false
        
        Write-Host "Processing year: $year" -ForegroundColor Gray

        foreach ($indicator in $demographicIndicators) {
            $filePath = $indicator.File
            $colIndex = $indicator.ColumnIndex
            $description = $indicator.Description
            $transform = $indicator.Transform

            if (Test-Path $filePath) {
                try {
                    $data = Get-Content $filePath | ConvertFrom-Json
                    $vietnamData = $data[1] | Where-Object { $_.countryiso3code -eq 'VNM' -and $_.date -eq $year -and $null -ne $_.value }

                    if ($vietnamData) {
                        $value = $vietnamData.value
                        if ($transform) {
                            $value = & $transform $value
                        } else {
                            $value = [math]::Round([double]$value, 2)
                        }

                        $columns[$colIndex] = $value
                        if ([int]$year -ge 2020) {
                            Write-Host "Updated ${description} for ${year}: ${value}" -ForegroundColor Green
                        }
                        $updated = $true
                        $updateCount++
                    }
                }
                catch {
                    Write-Host "Error processing ${description} for ${year}: $($_.Exception.Message)" -ForegroundColor Red
                }
            }
        }

        if ($updated) {
            $updatedLines += ($columns -join ',')
        } else {
            $updatedLines += $line
        }
    } else {
        $updatedLines += $line
    }
}

$updatedLines | Out-File $csvPath -Encoding UTF8
Write-Host ""
Write-Host "Integration completed!" -ForegroundColor Green
Write-Host "Total updates: $updateCount" -ForegroundColor Cyan