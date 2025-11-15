# Integrate remaining available indicators into CSV
Write-Host "Integrating remaining available indicators..." -ForegroundColor Green

$additionalIndicators = @(
    @{File="wb_who_infant_mortality.json"; ColumnIndex=43; Description="Infant Mortality"},
    @{File="wb_who_under5_mortality.json"; ColumnIndex=44; Description="Under-5 Mortality"}
)

$csvPath = 'src/data/vietnam_advance.csv'
$csvContent = Get-Content $csvPath -Encoding UTF8
$updatedLines = @()

Write-Host "Processing CSV..." -ForegroundColor Yellow

foreach ($line in $csvContent) {
    $columns = $line -split ','
    $year = $columns[0].Trim('"')

    if ($year -match '^\d{4}$' -and [int]$year -ge 2000 -and [int]$year -le 2024) {
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
Write-Host "Integration completed!" -ForegroundColor Green