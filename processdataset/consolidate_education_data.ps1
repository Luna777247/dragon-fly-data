# ============================================================================
# Consolidate Education Data
# ============================================================================
# Tạo file CSV tổng hợp từ dữ liệu nhóm Giáo Dục
# Nguồn: World Bank UNESCO Institute for Statistics (UIS)
# Output: education_consolidated.csv
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

# ============================================================================
# Main Processing
# ============================================================================

Write-Host "`n════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   CONSOLIDATE EDUCATION DATA" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan

$rawDataPath = Join-Path $PSScriptRoot "..\rawdataset"

# Load all data sources
Write-Host "📥 Loading data sources..." -ForegroundColor Cyan

# UNESCO Files (wb_unesco_*.json)
$literacyRate = Load-WBData `
    -FilePath "$rawDataPath\wb_unesco_literacy.json" `
    -IndicatorName "Literacy Rate (Adult %)"

$primaryCompletion = Load-WBData `
    -FilePath "$rawDataPath\wb_unesco_primary_completion.json" `
    -IndicatorName "Primary Completion Rate %"

$meanSchooling = Load-WBData `
    -FilePath "$rawDataPath\wb_unesco_mean_schooling.json" `
    -IndicatorName "Mean Years of Schooling"

$expectedSchooling = Load-WBData `
    -FilePath "$rawDataPath\wb_unesco_expected_schooling.json" `
    -IndicatorName "Expected Years of Schooling"

# World Bank SE Files (wb_SE_*.json)
$adultLiteracy = Load-WBData `
    -FilePath "$rawDataPath\wb_SE_ADT_LITR_ZS.json" `
    -IndicatorName "Adult Literacy Rate (WB)"

$schoolLifeExpectancy = Load-WBData `
    -FilePath "$rawDataPath\wb_SE_SCH_LIFE.json" `
    -IndicatorName "School Life Expectancy"

$tertiaryEnrollment = Load-WBData `
    -FilePath "$rawDataPath\wb_SE_TER_ENRR.json" `
    -IndicatorName "Tertiary Enrollment Ratio"

$educationExpenditure = Load-WBData `
    -FilePath "$rawDataPath\wb_SE_XPD_TOTL_GD_ZS.json" `
    -IndicatorName "Education Expenditure % GDP"

# Determine year range (1960-2024 to match other datasets)
$startYear = 1960
$endYear = 2024
$years = $startYear..$endYear

Write-Host "`n📊 Consolidating data for $($years.Count) years ($startYear-$endYear)..." -ForegroundColor Cyan

# Build consolidated data structure
$consolidatedData = @{}
$totalDataPoints = 0

foreach ($year in $years) {
    $consolidatedData[$year] = @{
        Year = $year
        
        # Literacy indicators
        LiteracyRateAdult = if ($literacyRate.ContainsKey($year)) { $literacyRate[$year] } else { $null }
        AdultLiteracyWB = if ($adultLiteracy.ContainsKey($year)) { $adultLiteracy[$year] } else { $null }
        
        # School completion & attainment
        PrimaryCompletionRate = if ($primaryCompletion.ContainsKey($year)) { $primaryCompletion[$year] } else { $null }
        MeanYearsSchooling = if ($meanSchooling.ContainsKey($year)) { $meanSchooling[$year] } else { $null }
        ExpectedYearsSchooling = if ($expectedSchooling.ContainsKey($year)) { $expectedSchooling[$year] } else { $null }
        SchoolLifeExpectancy = if ($schoolLifeExpectancy.ContainsKey($year)) { $schoolLifeExpectancy[$year] } else { $null }
        
        # Tertiary education
        TertiaryEnrollmentRatio = if ($tertiaryEnrollment.ContainsKey($year)) { $tertiaryEnrollment[$year] } else { $null }
        
        # Investment
        EducationExpenditureGDP = if ($educationExpenditure.ContainsKey($year)) { $educationExpenditure[$year] } else { $null }
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

$outputPath = Join-Path $PSScriptRoot "education_consolidated.csv"
$csvLines = @()

# Header
$csvLines += "Year,LiteracyRateAdult,AdultLiteracyWB,PrimaryCompletionRate,MeanYearsSchooling,ExpectedYearsSchooling,SchoolLifeExpectancy,TertiaryEnrollmentRatio,EducationExpenditureGDP"

# Data rows
foreach ($year in $years) {
    $row = $consolidatedData[$year]
    
    $csvLines += (@(
        $year,
        $(if ($null -ne $row.LiteracyRateAdult) { $row.LiteracyRateAdult.ToString("F2") } else { "N/A" }),
        $(if ($null -ne $row.AdultLiteracyWB) { $row.AdultLiteracyWB.ToString("F2") } else { "N/A" }),
        $(if ($null -ne $row.PrimaryCompletionRate) { $row.PrimaryCompletionRate.ToString("F2") } else { "N/A" }),
        $(if ($null -ne $row.MeanYearsSchooling) { $row.MeanYearsSchooling.ToString("F2") } else { "N/A" }),
        $(if ($null -ne $row.ExpectedYearsSchooling) { $row.ExpectedYearsSchooling.ToString("F2") } else { "N/A" }),
        $(if ($null -ne $row.SchoolLifeExpectancy) { $row.SchoolLifeExpectancy.ToString("F2") } else { "N/A" }),
        $(if ($null -ne $row.TertiaryEnrollmentRatio) { $row.TertiaryEnrollmentRatio.ToString("F2") } else { "N/A" }),
        $(if ($null -ne $row.EducationExpenditureGDP) { $row.EducationExpenditureGDP.ToString("F2") } else { "N/A" })
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
    "LiteracyRateAdult" = 0
    "AdultLiteracyWB" = 0
    "PrimaryCompletionRate" = 0
    "MeanYearsSchooling" = 0
    "ExpectedYearsSchooling" = 0
    "SchoolLifeExpectancy" = 0
    "TertiaryEnrollmentRatio" = 0
    "EducationExpenditureGDP" = 0
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
Write-Host "   Data columns: 8" -ForegroundColor Gray

$totalCells = $years.Count * 8
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

Write-Host "`n════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   CONSOLIDATION COMPLETE" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan
