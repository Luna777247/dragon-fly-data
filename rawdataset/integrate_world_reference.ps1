# Integrate world reference data and additional indicators
Write-Host "=== Integrating World Reference Data ===" -ForegroundColor Cyan

$csv = Import-Csv "src\data\vietnam_advance.csv"
$updates = 0

# Function to load and integrate data
function Integrate-WorldData {
    param($JsonFile, $ColumnName, $Transform = $null)
    
    if (-not (Test-Path $JsonFile)) {
        Write-Host "⚠ $JsonFile not found" -ForegroundColor Yellow
        return 0
    }
    
    try {
        $json = Get-Content $JsonFile -Raw | ConvertFrom-Json
        if ($json.Count -gt 1) {
            $data = $json[1] | Where-Object { $null -ne $_.value }
            
            $lookup = @{}
            foreach ($item in $data) {
                $lookup[$item.date] = $item.value
            }
            
            $count = 0
            foreach ($row in $script:csv) {
                $year = $row.Year
                if ($lookup.ContainsKey($year)) {
                    $value = $lookup[$year]
                    if ($Transform) {
                        $value = & $Transform $value
                    }
                    $row.$ColumnName = $value
                    $count++
                }
            }
            
            if ($count -gt 0) {
                Write-Host "  ✓ $ColumnName : $count rows" -ForegroundColor Green
            }
            return $count
        }
    }
    catch {
        Write-Host "  ✗ Error with $JsonFile" -ForegroundColor Red
    }
    return 0
}

# Integrate World Population
Write-Host "`nWorld Population..." -ForegroundColor Cyan
$updates += Integrate-WorldData "wb_world_population.json" "World Population" { 
    param($v) [math]::Round($v, 0) 
}

# Integrate World Urbanization Rate
Write-Host "`nWorld Urbanization Rate..." -ForegroundColor Cyan
$updates += Integrate-WorldData "wb_world_urbanization.json" "World Urbanization Rate (%)" {
    param($v) [math]::Round($v, 2)
}

# Calculate Country's Share of World Pop
Write-Host "`nCalculating Vietnam's share of world population..." -ForegroundColor Cyan
foreach ($row in $csv) {
    $vnPop = if ($row.Population) { [double]$row.Population } else { 0 }
    $worldPop = if ($row.'World Population') { [double]$row.'World Population' } else { 0 }
    
    if ($vnPop -gt 0 -and $worldPop -gt 0) {
        $share = [math]::Round(($vnPop / $worldPop) * 100, 4)
        $row.'Country''s Share of World Pop' = $share
        $updates++
    }
}
Write-Host "  ✓ Country's Share of World Pop calculated" -ForegroundColor Green

# Calculate Vietnam's Share of Asian Pop (estimate: Asia ~60% of world)
Write-Host "`nCalculating Vietnam's share of Asian population (estimate)..." -ForegroundColor Cyan
foreach ($row in $csv) {
    $vnPop = if ($row.Population) { [double]$row.Population } else { 0 }
    $worldPop = if ($row.'World Population') { [double]$row.'World Population' } else { 0 }
    
    if ($vnPop -gt 0 -and $worldPop -gt 0) {
        # Asia is approximately 60% of world population
        $asiaPop = $worldPop * 0.60
        $share = [math]::Round(($vnPop / $asiaPop) * 100, 3)
        $row.'Vietnam''s Share of Asian Pop (%)' = $share
        $row.'Vietnam?s Share of Asian Pop (%)' = $share  # Handle encoding variant
        $updates += 2
    }
}
Write-Host "  ✓ Vietnam's Share of Asian Pop calculated" -ForegroundColor Green

# Save updated CSV
$csv | Export-Csv "src\data\vietnam_advance.csv" -NoTypeInformation -Encoding UTF8

Write-Host "`n=== Integration Complete ===" -ForegroundColor Green
Write-Host "Total updates: $updates" -ForegroundColor Cyan

# Verify 2024 data
Write-Host "`n=== Verification (Year 2024) ===" -ForegroundColor Yellow
$row2024 = $csv | Where-Object { $_.Year -eq '2024' }
if ($row2024) {
    Write-Host "Vietnam Population: $($row2024.Population)" -ForegroundColor White
    Write-Host "World Population: $($row2024.'World Population')" -ForegroundColor White
    Write-Host "World Urbanization Rate: $($row2024.'World Urbanization Rate (%)')%" -ForegroundColor White
    Write-Host "Vietnam's Share of World: $($row2024.'Country''s Share of World Pop')%" -ForegroundColor White
    Write-Host "Vietnam's Share of Asia: $($row2024.'Vietnam''s Share of Asian Pop (%)')%" -ForegroundColor White
}
