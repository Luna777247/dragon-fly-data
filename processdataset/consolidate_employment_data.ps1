# ============================================================================
# Consolidate Employment & Labor Data
# ============================================================================
# Tạo file CSV tổng hợp từ dữ liệu nhóm Lao Động & Việc Làm
# Nguồn: World Bank ILO estimates + employment_issues.csv
# Output: employment_consolidated.csv
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
# Helper: Load employment_issues.csv
# ----------------------------------------------------------------------------
function Load-EmploymentIssuesCSV {
    param([string]$FilePath)
    
    if (-not (Test-Path $FilePath)) {
        Write-Host "⚠ File not found: $FilePath" -ForegroundColor Yellow
        return @{}
    }
    
    try {
        $csv = Import-Csv $FilePath
        $lookup = @{}
        
        foreach ($row in $csv) {
            $year = [int]$row.Year
            $lookup[$year] = @{
                Agriculture = if ($row.Agriculture -ne "") { [double]$row.Agriculture } else { $null }
                Industry = if ($row.Industry -ne "") { [double]$row.Industry } else { $null }
                Services = if ($row.Services -ne "") { [double]$row.Services } else { $null }
                Total = if ($row.Total -ne "") { [double]$row.Total } else { $null }
                Difference = if ($row.Difference -ne "") { [double]$row.Difference } else { $null }
            }
        }
        
        Write-Host "✓ Employment Issues CSV : $($lookup.Count) năm" -ForegroundColor Green
        return $lookup
        
    } catch {
        Write-Host "✗ Error loading employment_issues.csv: $_" -ForegroundColor Red
        return @{}
    }
}

# ============================================================================
# Main Processing
# ============================================================================

Write-Host "`n════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   CONSOLIDATE EMPLOYMENT & LABOR DATA" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan

$rawDataPath = Join-Path $PSScriptRoot "..\rawdataset"

# Load all data sources
Write-Host "📥 Loading data sources..." -ForegroundColor Cyan

$agriculture = Load-WBData `
    -FilePath "$rawDataPath\wb_ilo_agriculture_employment.json" `
    -IndicatorName "Agriculture Employment %"

$industry = Load-WBData `
    -FilePath "$rawDataPath\wb_ilo_industry_employment.json" `
    -IndicatorName "Industry Employment %"

$services = Load-WBData `
    -FilePath "$rawDataPath\wb_ilo_services_employment.json" `
    -IndicatorName "Services Employment %"

$unemployment = Load-WBData `
    -FilePath "$rawDataPath\wb_ilo_unemployment.json" `
    -IndicatorName "Unemployment Rate"

$employmentIssues = Load-EmploymentIssuesCSV `
    -FilePath "$rawDataPath\employment_issues.csv"

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
        
        # Employment by sector (% of total employment) - ILO modeled estimates
        AgricultureEmploymentPct = if ($agriculture.ContainsKey($year)) { $agriculture[$year] } else { $null }
        IndustryEmploymentPct = if ($industry.ContainsKey($year)) { $industry[$year] } else { $null }
        ServicesEmploymentPct = if ($services.ContainsKey($year)) { $services[$year] } else { $null }
        
        # Unemployment rate (% of labor force)
        UnemploymentRate = if ($unemployment.ContainsKey($year)) { $unemployment[$year] } else { $null }
        
        # Employment issues data (additional metrics)
        AgricultureMillions = if ($employmentIssues.ContainsKey($year)) { $employmentIssues[$year].Agriculture } else { $null }
        IndustryMillions = if ($employmentIssues.ContainsKey($year)) { $employmentIssues[$year].Industry } else { $null }
        ServicesMillions = if ($employmentIssues.ContainsKey($year)) { $employmentIssues[$year].Services } else { $null }
        TotalEmploymentMillions = if ($employmentIssues.ContainsKey($year)) { $employmentIssues[$year].Total } else { $null }
        UnemployedMillions = if ($employmentIssues.ContainsKey($year)) { $employmentIssues[$year].Difference } else { $null }
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

$outputPath = Join-Path $PSScriptRoot "employment_consolidated.csv"
$csvLines = @()

# Header
$csvLines += "Year,AgricultureEmploymentPct,IndustryEmploymentPct,ServicesEmploymentPct,UnemploymentRate,AgricultureMillions,IndustryMillions,ServicesMillions,TotalEmploymentMillions,UnemployedMillions"

# Data rows
foreach ($year in $years) {
    $row = $consolidatedData[$year]
    
    $csvLines += (@(
        $year,
        $(if ($null -ne $row.AgricultureEmploymentPct) { $row.AgricultureEmploymentPct.ToString("F2") } else { "N/A" }),
        $(if ($null -ne $row.IndustryEmploymentPct) { $row.IndustryEmploymentPct.ToString("F2") } else { "N/A" }),
        $(if ($null -ne $row.ServicesEmploymentPct) { $row.ServicesEmploymentPct.ToString("F2") } else { "N/A" }),
        $(if ($null -ne $row.UnemploymentRate) { $row.UnemploymentRate.ToString("F2") } else { "N/A" }),
        $(if ($null -ne $row.AgricultureMillions) { $row.AgricultureMillions.ToString("F2") } else { "N/A" }),
        $(if ($null -ne $row.IndustryMillions) { $row.IndustryMillions.ToString("F2") } else { "N/A" }),
        $(if ($null -ne $row.ServicesMillions) { $row.ServicesMillions.ToString("F2") } else { "N/A" }),
        $(if ($null -ne $row.TotalEmploymentMillions) { $row.TotalEmploymentMillions.ToString("F2") } else { "N/A" }),
        $(if ($null -ne $row.UnemployedMillions) { $row.UnemployedMillions.ToString("F2") } else { "N/A" })
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
    "AgricultureEmploymentPct" = 0
    "IndustryEmploymentPct" = 0
    "ServicesEmploymentPct" = 0
    "UnemploymentRate" = 0
    "AgricultureMillions" = 0
    "IndustryMillions" = 0
    "ServicesMillions" = 0
    "TotalEmploymentMillions" = 0
    "UnemployedMillions" = 0
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
Write-Host "   Data columns: 9" -ForegroundColor Gray

$totalCells = $years.Count * 9
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
