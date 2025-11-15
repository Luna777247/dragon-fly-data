# Debug: Check what data we have for recent years
Write-Host "Checking data availability for recent years..." -ForegroundColor Green

$indicators = @(
    @{File="wb_ilo_unemployment.json"; Name="Unemployment"},
    @{File="wb_fdi.json"; Name="FDI"},
    @{File="wb_gdp_ppp.json"; Name="GDP PPP"},
    @{File="wb_gni.json"; Name="GNI"},
    @{File="wb_migration.json"; Name="Migration"}
)

foreach ($indicator in $indicators) {
    $file = $indicator.File
    $name = $indicator.Name

    if (Test-Path $file) {
        Write-Host "${name} data:" -ForegroundColor Yellow
        try {
            $data = Get-Content $file | ConvertFrom-Json
            $vietnamData = $data[1] | Where-Object { $_.countryiso3code -eq 'VNM' -and $null -ne $_.value } | Sort-Object date -Descending | Select-Object -First 5

            $vietnamData | ForEach-Object {
                Write-Host "  $($_.date): $($_.value)"
            }
        }
        catch {
            Write-Host "  Error reading file" -ForegroundColor Red
        }
    } else {
        Write-Host "${name}: File not found" -ForegroundColor Red
    }
    Write-Host ""
}

# Check CSV years
Write-Host "CSV years available:" -ForegroundColor Cyan
$csv = Import-Csv 'src/data/vietnam_advance.csv'
$years = $csv | Select-Object -ExpandProperty Year | Where-Object { $_ -match '^\d{4}$' -and $_ -ge '2020' }
$years | Sort-Object -Descending | Select-Object -First 10