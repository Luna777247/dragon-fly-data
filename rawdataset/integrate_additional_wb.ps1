# Integrate additional World Bank indicators
Write-Host "Integrating additional indicators into CSV..." -ForegroundColor Green

$additionalIndicators = @(
    @{File="wb_sex_ratio.json"; ColumnIndex=9; Description="Sex Ratio (M/F)"},
    @{File="wb_life_exp_male.json"; ColumnIndex=40; Description="Life Expectancy Male"},
    @{File="wb_life_exp_female.json"; ColumnIndex=41; Description="Life Expectancy Female"},
    @{File="wb_land_area.json"; ColumnIndex=53; Description="Land Area (Km²)"},
    @{File="wb_urban_growth.json"; ColumnIndex=66; Description="Urban Growth Rate (%)"},
    @{File="wb_urbanization.json"; ColumnIndex=58; Description="Urbanization Ratio"}
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

        foreach ($indicator in $additionalIndicators) {
            $filePath = $indicator.File
            $colIndex = $indicator.ColumnIndex
            $description = $indicator.Description

            if (Test-Path $filePath) {
                try {
                    $data = Get-Content $filePath | ConvertFrom-Json
                    $vietnamData = $data[1] | Where-Object { $_.countryiso3code -eq 'VNM' -and $_.date -eq $year -and $null -ne $_.value }

                    if ($vietnamData) {
                        $value = [math]::Round([double]$vietnamData.value, 2)
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