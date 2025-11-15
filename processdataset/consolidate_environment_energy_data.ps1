# ============================================================================
# Consolidate Environment & Energy Data
# ============================================================================
# Tạo file CSV tổng hợp từ dữ liệu nhóm Môi Trường & Năng Lượng
# Nguồn: World Bank Environment & Energy Indicators
# Output: environment_energy_consolidated.csv
# ============================================================================

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

# ----------------------------------------------------------------------------
# Helper: Load World Bank JSON data
# ----------------------------------------------------------------------------
function Load-WBData {
    param(
        [string]$FilePath,
        [string]$IndicatorName
    )
    
    if (-not (Test-Path $FilePath)) {
        Write-Host "⚠ File not found: $FilePath" -ForegroundColor Yellow
        return @{}
    }
    
    try {
        $jsonContent = Get-Content $FilePath -Raw -Encoding UTF8
        $json = ConvertFrom-Json $jsonContent
        
        # World Bank API format: [metadata, data_array] or [metadata, {value: data_array}]
        $dataElement = $json[1]
        $dataArray = if ($dataElement -is [Array]) { 
            $dataElement 
        } else { 
            $dataElement.value 
        }
        
        $lookup = @{}
        foreach ($item in $dataArray) {
            if ($null -ne $item.value -and $item.value -ne "") {
                $year = [int]$item.date
                $lookup[$year] = [double]$item.value
            }
        }
        
        $validYears = $lookup.Count
        Write-Host "✓ $IndicatorName : $validYears năm" -ForegroundColor Green
        return $lookup
        
    } catch {
        Write-Host "✗ Error loading $IndicatorName : $_" -ForegroundColor Red
        return @{}
    }
}

# ----------------------------------------------------------------------------
# Helper: Load World Bank CSV data (for CO2 emissions)
# ----------------------------------------------------------------------------
function Load-CSVData {
    param(
        [string]$FilePath,
        [string]$IndicatorName
    )
    
    if (-not (Test-Path $FilePath)) {
        Write-Host "⚠ CSV file not found: $FilePath" -ForegroundColor Yellow
        return @{}
    }
    
    try {
        # World Bank CSV files have metadata rows at the top
        # Real data starts around line 5
        $allLines = Get-Content $FilePath
        $headerLine = $allLines | Where-Object { $_ -match '^"Country Name",' } | Select-Object -First 1
        
        if (-not $headerLine) {
            Write-Host "⚠ $IndicatorName : Cannot find header row" -ForegroundColor Yellow
            return @{}
        }
        
        # Find the index of the header line
        $headerIndex = [array]::IndexOf($allLines, $headerLine)
        
        # Import CSV starting from header line
        $csvData = $allLines[$headerIndex..($allLines.Length-1)] | ConvertFrom-Csv
        
        $lookup = @{}
        foreach ($row in $csvData) {
            if ($row.'Country Name' -eq 'Vietnam' -or $row.'Country Code' -eq 'VNM') {
                foreach ($prop in $row.PSObject.Properties) {
                    if ($prop.Name -match '^\d{4}$') {
                        $year = [int]$prop.Name
                        $value = $prop.Value
                        if ($value -ne "" -and $null -ne $value) {
                            $lookup[$year] = [double]$value
                        }
                    }
                }
                break
            }
        }
        
        $validYears = $lookup.Count
        Write-Host "✓ $IndicatorName (CSV) : $validYears năm" -ForegroundColor Green
        return $lookup
        
    } catch {
        Write-Host "✗ Error loading CSV $IndicatorName : $_" -ForegroundColor Red
        return @{}
    }
}

# ----------------------------------------------------------------------------
# Helper: Load ZIP file data
# ----------------------------------------------------------------------------
function Load-ZIPData {
    param(
        [string]$FilePath,
        [string]$IndicatorName
    )
    
    if (-not (Test-Path $FilePath)) {
        Write-Host "⚠ ZIP file not found: $FilePath" -ForegroundColor Yellow
        return @{}
    }
    
    try {
        $tempDir = Join-Path $env:TEMP "env_zip_extract_$(Get-Random)"
        New-Item -ItemType Directory -Path $tempDir | Out-Null
        
        Expand-Archive -Path $FilePath -DestinationPath $tempDir -Force
        
        $csvFiles = Get-ChildItem -Path $tempDir -Filter "*.csv" -Recurse
        
        if ($csvFiles.Count -eq 0) {
            Write-Host "⚠ $IndicatorName : No CSV found in ZIP" -ForegroundColor Yellow
            Remove-Item -Path $tempDir -Recurse -Force
            return @{}
        }
        
        $csvFile = $csvFiles[0]
        $csvData = Import-Csv $csvFile.FullName
        
        $lookup = @{}
        foreach ($row in $csvData) {
            if ($row.'Country Name' -eq 'Vietnam' -or $row.'Country Code' -eq 'VNM') {
                foreach ($prop in $row.PSObject.Properties) {
                    if ($prop.Name -match '^\d{4}$') {
                        $year = [int]$prop.Name
                        $value = $prop.Value
                        if ($value -ne "" -and $null -ne $value) {
                            $lookup[$year] = [double]$value
                        }
                    }
                }
                break
            }
        }
        
        Remove-Item -Path $tempDir -Recurse -Force
        
        $validYears = $lookup.Count
        Write-Host "✓ $IndicatorName (ZIP) : $validYears năm" -ForegroundColor Green
        return $lookup
        
    } catch {
        Write-Host "✗ Error loading ZIP $IndicatorName : $_" -ForegroundColor Red
        return @{}
    }
}

# ============================================================================
# Main Processing
# ============================================================================

Write-Host "`n════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   CONSOLIDATE ENVIRONMENT & ENERGY DATA" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan

$rawDataPath = Join-Path $PSScriptRoot "..\rawdataset"

# Load all data sources
Write-Host "📥 Loading data sources..." -ForegroundColor Cyan

Write-Host "`n[Emissions & Climate]" -ForegroundColor Yellow
$co2EmissionsJSON = Load-WBData `
    -FilePath "$rawDataPath\wb_co2_emissions.json" `
    -IndicatorName "CO2 Emissions (JSON)"

$co2EmissionsCSV = Load-CSVData `
    -FilePath "$rawDataPath\API_EN.ATM.CO2E.PC_DS57_en_csv_v2_123436.csv" `
    -IndicatorName "CO2 Emissions per Capita"

$co2EmissionsZIP = Load-ZIPData `
    -FilePath "$rawDataPath\co2_emissions.zip" `
    -IndicatorName "CO2 Emissions"

Write-Host "`n[Energy]" -ForegroundColor Yellow
$energyUse = Load-WBData `
    -FilePath "$rawDataPath\wb_energy.json" `
    -IndicatorName "Energy Use per Capita"

$renewableEnergyJSON = Load-WBData `
    -FilePath "$rawDataPath\wb_renewable_energy.json" `
    -IndicatorName "Renewable Energy %"

$renewableEnergyZIP = Load-ZIPData `
    -FilePath "$rawDataPath\renewable_energy.zip" `
    -IndicatorName "Renewable Energy (ZIP)"

Write-Host "`n[Land Use & Forest]" -ForegroundColor Yellow
$forestArea = Load-WBData `
    -FilePath "$rawDataPath\wb_forest.json" `
    -IndicatorName "Forest Area %"

$agriLand = Load-WBData `
    -FilePath "$rawDataPath\wb_agri_land.json" `
    -IndicatorName "Agricultural Land %"

$landArea = Load-WBData `
    -FilePath "$rawDataPath\wb_land_area.json" `
    -IndicatorName "Land Area (sq km)"

# Determine year range (1960-2024 to match other datasets)
$startYear = 1960
$endYear = 2024
$years = $startYear..$endYear

Write-Host "`n📊 Consolidating data for $($years.Count) years ($startYear-$endYear)..." -ForegroundColor Cyan

# Build consolidated data structure
$consolidatedData = @{}
$totalDataPoints = 0

foreach ($year in $years) {
    # Use CSV as primary for CO2 (most complete), fallback to ZIP then JSON
    $co2 = if ($co2EmissionsCSV.ContainsKey($year)) {
        $co2EmissionsCSV[$year]
    } elseif ($co2EmissionsZIP.ContainsKey($year)) {
        $co2EmissionsZIP[$year]
    } elseif ($co2EmissionsJSON.ContainsKey($year)) {
        $co2EmissionsJSON[$year]
    } else {
        $null
    }
    
    # Use ZIP as primary for renewable energy (more complete), fallback to JSON
    $renewable = if ($renewableEnergyZIP.ContainsKey($year)) {
        $renewableEnergyZIP[$year]
    } elseif ($renewableEnergyJSON.ContainsKey($year)) {
        $renewableEnergyJSON[$year]
    } else {
        $null
    }
    
    $consolidatedData[$year] = @{
        Year = $year
        
        # Emissions
        CO2EmissionsPerCapita = $co2
        
        # Energy
        EnergyUsePerCapita = if ($energyUse.ContainsKey($year)) { $energyUse[$year] } else { $null }
        RenewableEnergyPercent = $renewable
        
        # Land use
        ForestAreaPercent = if ($forestArea.ContainsKey($year)) { $forestArea[$year] } else { $null }
        AgriLandPercent = if ($agriLand.ContainsKey($year)) { $agriLand[$year] } else { $null }
        LandAreaSqKm = if ($landArea.ContainsKey($year)) { $landArea[$year] } else { $null }
    }
    
    # Count non-null values
    foreach ($key in $consolidatedData[$year].Keys) {
        if ($key -ne "Year" -and $null -ne $consolidatedData[$year][$key]) {
            $totalDataPoints++
        }
    }
}

# ============================================================================
# Generate CSV Output
# ============================================================================

Write-Host "💾 Generating CSV file..." -ForegroundColor Cyan

$outputPath = Join-Path $PSScriptRoot "environment_energy_consolidated.csv"
$csvLines = @()

# Header
$csvLines += "Year,CO2EmissionsPerCapita,EnergyUsePerCapita,RenewableEnergyPercent,ForestAreaPercent,AgriLandPercent,LandAreaSqKm"

# Data rows
foreach ($year in $years) {
    $row = $consolidatedData[$year]
    
    $csvLines += (@(
        $year,
        $(if ($null -ne $row.CO2EmissionsPerCapita) { $row.CO2EmissionsPerCapita.ToString("F2") } else { "N/A" }),
        $(if ($null -ne $row.EnergyUsePerCapita) { $row.EnergyUsePerCapita.ToString("F2") } else { "N/A" }),
        $(if ($null -ne $row.RenewableEnergyPercent) { $row.RenewableEnergyPercent.ToString("F2") } else { "N/A" }),
        $(if ($null -ne $row.ForestAreaPercent) { $row.ForestAreaPercent.ToString("F2") } else { "N/A" }),
        $(if ($null -ne $row.AgriLandPercent) { $row.AgriLandPercent.ToString("F2") } else { "N/A" }),
        $(if ($null -ne $row.LandAreaSqKm) { $row.LandAreaSqKm.ToString("F0") } else { "N/A" })
    ) -join ",")
}

$csvLines | Out-File -FilePath $outputPath -Encoding UTF8

# ============================================================================
# Quality Report
# ============================================================================

Write-Host "`n✅ CSV file created successfully!" -ForegroundColor Green
Write-Host "   Output: $outputPath" -ForegroundColor Gray

# Calculate fill rates
$columnFillRates = @{
    "CO2EmissionsPerCapita" = 0
    "EnergyUsePerCapita" = 0
    "RenewableEnergyPercent" = 0
    "ForestAreaPercent" = 0
    "AgriLandPercent" = 0
    "LandAreaSqKm" = 0
}

foreach ($year in $years) {
    $row = $consolidatedData[$year]
    $colKeys = @($columnFillRates.Keys)
    foreach ($col in $colKeys) {
        if ($null -ne $row[$col]) {
            $columnFillRates[$col]++
        }
    }
}

Write-Host "`n📈 Data Quality Report:" -ForegroundColor Cyan
Write-Host "   Total years: $($years.Count) ($startYear-$endYear)" -ForegroundColor Gray
Write-Host "   Total data points: $totalDataPoints" -ForegroundColor Gray
Write-Host "   Data columns: 6" -ForegroundColor Gray

$totalCells = $years.Count * 6
$avgFillRate = ($totalDataPoints / $totalCells) * 100

Write-Host "`n   Column Fill Rates:" -ForegroundColor Cyan
$sortedColumns = @($columnFillRates.Keys) | Sort-Object
foreach ($col in $sortedColumns) {
    $fillRate = ($columnFillRates[$col] / $years.Count) * 100
    $bar = "█" * [Math]::Floor($fillRate / 5)
    Write-Host ("   {0,-30} : {1,2} years ({2,5:F1}%) {3}" -f $col, $columnFillRates[$col], $fillRate, $bar) -ForegroundColor $(
        if ($fillRate -ge 80) { "Green" }
        elseif ($fillRate -ge 50) { "Yellow" }
        else { "Red" }
    )
}

Write-Host "`n   Average Fill Rate: $($avgFillRate.ToString('F1'))%" -ForegroundColor $(
    if ($avgFillRate -ge 70) { "Green" }
    elseif ($avgFillRate -ge 50) { "Yellow" }
    else { "Red" }
)

# Display value ranges for key indicators
Write-Host "`n📊 Value Ranges (First → Latest):" -ForegroundColor Cyan

$indicators = @(
    @{Name="CO2EmissionsPerCapita"; Label="CO2 Emissions per Capita"; Unit="metric tons"},
    @{Name="RenewableEnergyPercent"; Label="Renewable Energy"; Unit="% of total"},
    @{Name="ForestAreaPercent"; Label="Forest Area"; Unit="% of land"},
    @{Name="AgriLandPercent"; Label="Agricultural Land"; Unit="% of land"}
)

foreach ($indicator in $indicators) {
    $values = @($years | ForEach-Object { 
        $val = $consolidatedData[$_][$indicator.Name]
        if ($null -ne $val) { @{Year=$_; Value=$val} }
    }) | Where-Object { $_ }
    
    if ($values.Count -gt 0) {
        $first = $values[0]
        $last = $values[-1]
        $change = $last.Value - $first.Value
        $changePercent = if ($first.Value -ne 0) { ($change / $first.Value) * 100 } else { 0 }
        
        $changeStr = if ($change -gt 0) { "+$($change.ToString('F2'))" } else { $change.ToString('F2') }
        
        # Color coding: Green for good environmental outcomes
        $changeColor = if ($indicator.Name -eq "CO2EmissionsPerCapita") {
            if ($change -lt 0) { "Green" } else { "Red" }  # Less CO2 = good
        } elseif ($indicator.Name -eq "ForestAreaPercent") {
            if ($change -gt 0) { "Green" } else { "Red" }  # More forest = good
        } elseif ($indicator.Name -eq "RenewableEnergyPercent") {
            if ($change -gt 0) { "Green" } else { "Red" }  # More renewable = good
        } else {
            "Yellow"  # Neutral for agricultural land
        }
        
        Write-Host ("   {0,-30} : {1,6:F2} ({2}) → {3,6:F2} ({4}) | {5} {6} ({7:F1}%)" -f `
            $indicator.Label, `
            $first.Value, $first.Year, `
            $last.Value, $last.Year, `
            $changeStr, $indicator.Unit, $changePercent) -ForegroundColor $changeColor
    }
}

# Calculate derived metrics
Write-Host "`n🌍 Environmental Insights:" -ForegroundColor Cyan

# Forest loss analysis
$forestValues = @($years | ForEach-Object { 
    $val = $consolidatedData[$_].ForestAreaPercent
    if ($null -ne $val) { @{Year=$_; Value=$val} }
}) | Where-Object { $_ }

if ($forestValues.Count -gt 0) {
    $forestFirst = $forestValues[0]
    $forestLast = $forestValues[-1]
    $forestLoss = $forestFirst.Value - $forestLast.Value
    $forestLossPercent = ($forestLoss / $forestFirst.Value) * 100
    
    Write-Host ("   Forest loss: {0:F2} percentage points ({1:F1}% reduction)" -f $forestLoss, $forestLossPercent) -ForegroundColor $(
        if ($forestLoss -gt 5) { "Red" } elseif ($forestLoss -gt 2) { "Yellow" } else { "Green" }
    )
}

# CO2 growth rate
$co2Values = @($years | ForEach-Object { 
    $val = $consolidatedData[$_].CO2EmissionsPerCapita
    if ($null -ne $val) { @{Year=$_; Value=$val} }
}) | Where-Object { $_ }

if ($co2Values.Count -gt 1) {
    $co2First = $co2Values[0]
    $co2Last = $co2Values[-1]
    $yearsSpan = $co2Last.Year - $co2First.Year
    $annualGrowth = if ($yearsSpan -gt 0) { 
        [Math]::Pow(($co2Last.Value / $co2First.Value), (1.0 / $yearsSpan)) - 1 
    } else { 0 }
    
    Write-Host ("   CO2 emissions annual growth: {0:F2}% per year ({1}-{2})" -f ($annualGrowth * 100), $co2First.Year, $co2Last.Year) -ForegroundColor $(
        if ($annualGrowth -gt 0.05) { "Red" } elseif ($annualGrowth -gt 0.02) { "Yellow" } else { "Green" }
    )
}

# Energy intensity (if population data available, this would be energy per GDP)
$energyValues = @($years | ForEach-Object { 
    $val = $consolidatedData[$_].EnergyUsePerCapita
    if ($null -ne $val) { @{Year=$_; Value=$val} }
}) | Where-Object { $_ }

if ($energyValues.Count -gt 0) {
    $energyFirst = $energyValues[0]
    $energyLast = $energyValues[-1]
    $energyGrowth = (($energyLast.Value - $energyFirst.Value) / $energyFirst.Value) * 100
    
    Write-Host ("   Energy use per capita growth: {0:F1}% ({1}-{2})" -f $energyGrowth, $energyFirst.Year, $energyLast.Year) -ForegroundColor $(
        if ($energyGrowth -gt 200) { "Red" } elseif ($energyGrowth -gt 100) { "Yellow" } else { "Green" }
    )
}

Write-Host "`n════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   CONSOLIDATION COMPLETE" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan
