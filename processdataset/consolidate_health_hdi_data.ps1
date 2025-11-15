# ============================================================================
# Consolidate Health & Human Development Data
# ============================================================================
# Tạo file CSV tổng hợp từ dữ liệu nhóm Y Tế & Phát Triển Con Người
# Nguồn: World Bank, WHO, Human Capital Index
# Output: health_hdi_consolidated.csv
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
# Helper: Load WHO JSON data (different format)
# ----------------------------------------------------------------------------
function Load-WHOData {
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
        
        $lookup = @{}
        
        # WHO API format varies - try multiple structures
        if ($json -is [Array]) {
            foreach ($item in $json) {
                if ($null -ne $item.year -and $null -ne $item.value) {
                    $year = [int]$item.year
                    $lookup[$year] = [double]$item.value
                }
                elseif ($null -ne $item.TimeDim -and $null -ne $item.NumericValue) {
                    $year = [int]$item.TimeDim
                    $lookup[$year] = [double]$item.NumericValue
                }
            }
        }
        
        $validYears = $lookup.Count
        if ($validYears -gt 0) {
            Write-Host "✓ $IndicatorName : $validYears năm" -ForegroundColor Green
        } else {
            Write-Host "⚠ $IndicatorName : No data parsed" -ForegroundColor Yellow
        }
        return $lookup
        
    } catch {
        Write-Host "✗ Error loading $IndicatorName : $_" -ForegroundColor Red
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
        $tempDir = Join-Path $env:TEMP "health_zip_extract_$(Get-Random)"
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
Write-Host "   CONSOLIDATE HEALTH & HUMAN DEVELOPMENT DATA" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan

$rawDataPath = Join-Path $PSScriptRoot "..\rawdataset"

# Load all data sources
Write-Host "📥 Loading data sources..." -ForegroundColor Cyan

Write-Host "`n[Life Expectancy]" -ForegroundColor Yellow
$lifeExpMale = Load-WBData `
    -FilePath "$rawDataPath\wb_life_exp_male.json" `
    -IndicatorName "Life Expectancy - Male"

$lifeExpFemale = Load-WBData `
    -FilePath "$rawDataPath\wb_life_exp_female.json" `
    -IndicatorName "Life Expectancy - Female"

$lifeExpWHO_WB = Load-WBData `
    -FilePath "$rawDataPath\wb_who_life_expectancy.json" `
    -IndicatorName "Life Expectancy (WHO via WB)"

$lifeExpWHO = Load-WHOData `
    -FilePath "$rawDataPath\who_life_expectancy.json" `
    -IndicatorName "Life Expectancy (WHO Direct)"

Write-Host "`n[Mortality Indicators]" -ForegroundColor Yellow
$infantMortalityWB = Load-WBData `
    -FilePath "$rawDataPath\wb_who_infant_mortality.json" `
    -IndicatorName "Infant Mortality Rate (WB)"

$infantMortalityWHO = Load-WHOData `
    -FilePath "$rawDataPath\who_infant_mortality.json" `
    -IndicatorName "Infant Mortality Rate (WHO)"

$under5Mortality = Load-WBData `
    -FilePath "$rawDataPath\wb_who_under5_mortality.json" `
    -IndicatorName "Under-5 Mortality Rate"

Write-Host "`n[Health Expenditure]" -ForegroundColor Yellow
$healthExpenditure = Load-WBData `
    -FilePath "$rawDataPath\wb_health_expenditure.json" `
    -IndicatorName "Health Expenditure % GDP"

$healthExpenditureZIP = Load-ZIPData `
    -FilePath "$rawDataPath\health_expenditure.zip" `
    -IndicatorName "Health Expenditure (ZIP)"

Write-Host "`n[Human Capital Index]" -ForegroundColor Yellow
$hciOverall = Load-WBData `
    -FilePath "$rawDataPath\wb_HD_HCI_OVRL.json" `
    -IndicatorName "Human Capital Index (Overall)"

$hciMale = Load-WBData `
    -FilePath "$rawDataPath\wb_HD_HCI_OVRL_MA.json" `
    -IndicatorName "Human Capital Index - Male"

$hciFemale = Load-WBData `
    -FilePath "$rawDataPath\wb_HD_HCI_OVRL_FE.json" `
    -IndicatorName "Human Capital Index - Female"

$hciLAYS = Load-WBData `
    -FilePath "$rawDataPath\wb_HD_HCI_LAYS.json" `
    -IndicatorName "HCI - Learning-Adjusted Years"

# Determine year range (1960-2024 to match other datasets)
$startYear = 1960
$endYear = 2024
$years = $startYear..$endYear

Write-Host "`n📊 Consolidating data for $($years.Count) years ($startYear-$endYear)..." -ForegroundColor Cyan

# Build consolidated data structure
$consolidatedData = @{}
$totalDataPoints = 0

foreach ($year in $years) {
    # Use WHO data as primary, WB as fallback for life expectancy
    $lifeExp = if ($lifeExpWHO.ContainsKey($year)) { 
        $lifeExpWHO[$year] 
    } elseif ($lifeExpWHO_WB.ContainsKey($year)) { 
        $lifeExpWHO_WB[$year] 
    } else { 
        $null 
    }
    
    # Use WHO data as primary for infant mortality
    $infantMort = if ($infantMortalityWHO.ContainsKey($year)) {
        $infantMortalityWHO[$year]
    } elseif ($infantMortalityWB.ContainsKey($year)) {
        $infantMortalityWB[$year]
    } else {
        $null
    }
    
    # Use ZIP data as fallback for health expenditure
    $healthExp = if ($healthExpenditure.ContainsKey($year)) {
        $healthExpenditure[$year]
    } elseif ($healthExpenditureZIP.ContainsKey($year)) {
        $healthExpenditureZIP[$year]
    } else {
        $null
    }
    
    $consolidatedData[$year] = @{
        Year = $year
        
        # Life expectancy indicators
        LifeExpectancy = $lifeExp
        LifeExpectancyMale = if ($lifeExpMale.ContainsKey($year)) { $lifeExpMale[$year] } else { $null }
        LifeExpectancyFemale = if ($lifeExpFemale.ContainsKey($year)) { $lifeExpFemale[$year] } else { $null }
        
        # Mortality indicators
        InfantMortalityRate = $infantMort
        Under5MortalityRate = if ($under5Mortality.ContainsKey($year)) { $under5Mortality[$year] } else { $null }
        
        # Health investment
        HealthExpenditureGDP = $healthExp
        
        # Human Capital Index
        HumanCapitalIndex = if ($hciOverall.ContainsKey($year)) { $hciOverall[$year] } else { $null }
        HumanCapitalIndexMale = if ($hciMale.ContainsKey($year)) { $hciMale[$year] } else { $null }
        HumanCapitalIndexFemale = if ($hciFemale.ContainsKey($year)) { $hciFemale[$year] } else { $null }
        LearningAdjustedYears = if ($hciLAYS.ContainsKey($year)) { $hciLAYS[$year] } else { $null }
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

$outputPath = Join-Path $PSScriptRoot "health_hdi_consolidated.csv"
$csvLines = @()

# Header
$csvLines += "Year,LifeExpectancy,LifeExpectancyMale,LifeExpectancyFemale,InfantMortalityRate,Under5MortalityRate,HealthExpenditureGDP,HumanCapitalIndex,HumanCapitalIndexMale,HumanCapitalIndexFemale,LearningAdjustedYears"

# Data rows
foreach ($year in $years) {
    $row = $consolidatedData[$year]
    
    $csvLines += (@(
        $year,
        $(if ($null -ne $row.LifeExpectancy) { $row.LifeExpectancy.ToString("F2") } else { "N/A" }),
        $(if ($null -ne $row.LifeExpectancyMale) { $row.LifeExpectancyMale.ToString("F2") } else { "N/A" }),
        $(if ($null -ne $row.LifeExpectancyFemale) { $row.LifeExpectancyFemale.ToString("F2") } else { "N/A" }),
        $(if ($null -ne $row.InfantMortalityRate) { $row.InfantMortalityRate.ToString("F2") } else { "N/A" }),
        $(if ($null -ne $row.Under5MortalityRate) { $row.Under5MortalityRate.ToString("F2") } else { "N/A" }),
        $(if ($null -ne $row.HealthExpenditureGDP) { $row.HealthExpenditureGDP.ToString("F2") } else { "N/A" }),
        $(if ($null -ne $row.HumanCapitalIndex) { $row.HumanCapitalIndex.ToString("F4") } else { "N/A" }),
        $(if ($null -ne $row.HumanCapitalIndexMale) { $row.HumanCapitalIndexMale.ToString("F4") } else { "N/A" }),
        $(if ($null -ne $row.HumanCapitalIndexFemale) { $row.HumanCapitalIndexFemale.ToString("F4") } else { "N/A" }),
        $(if ($null -ne $row.LearningAdjustedYears) { $row.LearningAdjustedYears.ToString("F2") } else { "N/A" })
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
    "LifeExpectancy" = 0
    "LifeExpectancyMale" = 0
    "LifeExpectancyFemale" = 0
    "InfantMortalityRate" = 0
    "Under5MortalityRate" = 0
    "HealthExpenditureGDP" = 0
    "HumanCapitalIndex" = 0
    "HumanCapitalIndexMale" = 0
    "HumanCapitalIndexFemale" = 0
    "LearningAdjustedYears" = 0
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
Write-Host "   Data columns: 10" -ForegroundColor Gray

$totalCells = $years.Count * 10
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
    @{Name="LifeExpectancy"; Label="Life Expectancy"; Unit="years"},
    @{Name="InfantMortalityRate"; Label="Infant Mortality"; Unit="per 1,000"},
    @{Name="HealthExpenditureGDP"; Label="Health Spending"; Unit="% GDP"},
    @{Name="HumanCapitalIndex"; Label="Human Capital Index"; Unit="0-1"}
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
        $changeColor = if ($indicator.Name -eq "InfantMortalityRate") {
            if ($change -lt 0) { "Green" } else { "Red" }
        } else {
            if ($change -gt 0) { "Green" } else { "Red" }
        }
        
        Write-Host ("   {0,-25} : {1,6:F2} ({2}) → {3,6:F2} ({4}) | {5} {6} ({7:F1}%)" -f `
            $indicator.Label, `
            $first.Value, $first.Year, `
            $last.Value, $last.Year, `
            $changeStr, $indicator.Unit, $changePercent) -ForegroundColor $changeColor
    }
}

Write-Host "`n════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   CONSOLIDATION COMPLETE" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan
