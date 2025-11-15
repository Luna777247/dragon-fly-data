# Integrate available UNESCO education data into CSV
Write-Host "Integrating available UNESCO education data..." -ForegroundColor Green

$educationIndicators = @(
    @{File="wb_unesco_literacy.json"; ColumnIndex=54; Description="Literacy Rate (%)"},
    @{File="wb_unesco_primary_completion.json"; ColumnIndex=85; Description="Primary Completion Rate (%)"}
)

$csvPath = 'src/data/vietnam_advance.csv'
$csvContent = Get-Content $csvPath -Encoding UTF8
$updatedLines = @()

foreach ($line in $csvContent) {
    $columns = $line -split ','
    $year = $columns[0].Trim('"')

    if ($year -match '^\d{4}$' -and [int]$year -ge 2000 -and [int]$year -le 2024) {
        $updated = $false

        foreach ($indicator in $educationIndicators) {
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
Write-Host "UNESCO education data integration completed!" -ForegroundColor Green

# Note about missing data
Write-Host ""
Write-Host "Note: Mean Years of Schooling and Expected Years of Schooling are UNDP indicators" -ForegroundColor Yellow
Write-Host "These will be addressed in the next step with UNDP data download."