# Integrate Remaining World Bank Indicators into CSV
Write-Host "Integrating remaining World Bank indicators into CSV..." -ForegroundColor Green

$indicatorsToIntegrate = @(
    @{File="wb_ilo_unemployment.json"; ColumnIndex=15; Description="Unemployment Rate (%)"},
    @{File="wb_fdi.json"; ColumnIndex=17; Description="FDI Net Inflows (million USD)"; Transform={ param($v) [math]::Round($v / 1000000, 0) }},
    @{File="wb_gdp_ppp.json"; ColumnIndex=18; Description="GDP PPP per Capita (Int$)"},
    @{File="wb_gni.json"; ColumnIndex=61; Description="GNI per Capita (USD)"},
    @{File="wb_migration.json"; ColumnIndex=38; Description="Net Migration"},
    @{File="wb_ilo_agriculture_employment.json"; ColumnIndex=23; Description="Employment Agriculture (%)"},
    @{File="wb_ilo_industry_employment.json"; ColumnIndex=24; Description="Employment Industry (%)"},
    @{File="wb_ilo_services_employment.json"; ColumnIndex=25; Description="Employment Services (%)"},
    @{File="wb_forest.json"; ColumnIndex=34; Description="Forest Area (% Land)"},
    @{File="wb_agri_land.json"; ColumnIndex=33; Description="Agricultural Land (% Land)"},
    @{File="wb_energy.json"; ColumnIndex=30; Description="Energy Consumption per Capita (kWh)"},
    @{File="wb_unesco_primary_completion.json"; ColumnIndex=85; Description="Primary Completion Rate (%)"}
)

$csvPath = 'src/data/vietnam_advance.csv'
$csvContent = Get-Content $csvPath -Encoding UTF8
$updatedLines = @()
$processedYears = 0

Write-Host "Processing CSV lines..." -ForegroundColor Yellow

foreach ($line in $csvContent) {
    $columns = $line -split ','
    $year = $columns[0].Trim('"')  # Remove quotes

    Write-Host "Raw year from CSV: '$year'" -ForegroundColor Gray

    if ($year -match '^\d{4}$' -and [int]$year -ge 2000 -and [int]$year -le 2024) {
        Write-Host "Processing year: $year" -ForegroundColor Cyan
        $processedYears++
        $updated = $false

        foreach ($indicator in $indicatorsToIntegrate) {
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
                        Write-Host "Updated ${description} for ${year}: ${value}" -ForegroundColor Green
                        $updated = $true
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
Write-Host "Remaining World Bank indicators integration completed!" -ForegroundColor Green