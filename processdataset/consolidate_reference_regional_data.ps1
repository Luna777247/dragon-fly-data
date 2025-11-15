# ============================================================================
# Consolidate Reference & Regional Data
# ============================================================================
# Purpose: Consolidate comparative and reference data for Vietnam including:
#   - World benchmarks (population, urbanization)
#   - Vietnam global and ASEAN rankings
#   - ASEAN regional aggregates
#   - Poverty and inequality indicators
#   - UNDP Human Development Report indicators
#
# Author: Data Processing Script
# Created: 2025
# ============================================================================

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Reference & Regional Data Consolidation" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$ErrorActionPreference = "Stop"

# Set working directory to project root
Set-Location "$PSScriptRoot\.."

$rawDataPath = "rawdataset"
$outputPath = "processdataset"
$outputFile = "$outputPath\reference_regional_consolidated.csv"

# ============================================================================
# Helper Functions
# ============================================================================

function Load-WBWorldData {
    param(
        [string]$FilePath,
        [string]$IndicatorName
    )
    
    Write-Host "  Loading World Bank World data: $IndicatorName..." -ForegroundColor Gray
    
    try {
        $jsonContent = Get-Content $FilePath -Raw | ConvertFrom-Json
        
        if ($jsonContent.Count -gt 1 -and $jsonContent[1].value) {
            $worldData = @{}
            
            foreach ($item in $jsonContent[1].value) {
                # Check if this is World data (country ID = "1W" or "WLD")
                if (($item.country.id -eq "1W" -or $item.countryiso3code -eq "WLD") -and $null -ne $item.value) {
                    $year = [int]$item.date
                    $worldData[$year] = [double]$item.value
                }
            }
            
            Write-Host "    ✓ Loaded $($worldData.Count) years" -ForegroundColor Green
            return $worldData
        }
        else {
            Write-Host "    ⚠ No data structure found" -ForegroundColor Yellow
            return @{}
        }
    }
    catch {
        Write-Host "    ✗ Error loading: $_" -ForegroundColor Red
        return @{}
    }
}

function Load-CustomJSONArray {
    param(
        [string]$FilePath,
        [string]$DataType
    )
    
    Write-Host "  Loading custom JSON: $DataType..." -ForegroundColor Gray
    
    try {
        $jsonContent = Get-Content $FilePath -Raw | ConvertFrom-Json
        
        if ($jsonContent -is [Array]) {
            $dataHash = @{}
            
            foreach ($item in $jsonContent) {
                if ($item.Year) {
                    $year = [int]$item.Year
                    $dataHash[$year] = $item
                }
            }
            
            Write-Host "    ✓ Loaded $($dataHash.Count) years" -ForegroundColor Green
            return $dataHash
        }
        else {
            Write-Host "    ⚠ Data is not an array" -ForegroundColor Yellow
            return @{}
        }
    }
    catch {
        Write-Host "    ✗ Error loading: $_" -ForegroundColor Red
        return @{}
    }
}

function Load-WBPovertyData {
    param(
        [string]$FilePath,
        [string]$IndicatorName
    )
    
    Write-Host "  Loading poverty indicator: $IndicatorName..." -ForegroundColor Gray
    
    try {
        $jsonContent = Get-Content $FilePath -Raw | ConvertFrom-Json
        
        if ($jsonContent.Count -gt 1 -and $jsonContent[1].value) {
            $povertyData = @{}
            
            foreach ($item in $jsonContent[1].value) {
                # Check if this is Vietnam data
                if (($item.country.id -eq "VN" -or $item.countryiso3code -eq "VNM") -and $null -ne $item.value) {
                    $year = [int]$item.date
                    $povertyData[$year] = [double]$item.value
                }
            }
            
            Write-Host "    ✓ Loaded $($povertyData.Count) data points" -ForegroundColor Green
            return $povertyData
        }
        else {
            Write-Host "    ⚠ No data structure found" -ForegroundColor Yellow
            return @{}
        }
    }
    catch {
        Write-Host "    ✗ Error loading: $_" -ForegroundColor Red
        return @{}
    }
}

function Load-UNDPData {
    param(
        [string]$FilePath
    )
    
    Write-Host "  Loading UNDP HDR data..." -ForegroundColor Gray
    
    try {
        $csvData = Import-Csv $FilePath
        
        # Find Vietnam row (iso3 = VNM)
        $vnmRow = $csvData | Where-Object { $_.iso3 -eq "VNM" }
        
        if ($vnmRow) {
            Write-Host "    ✓ Found Vietnam data row" -ForegroundColor Green
            
            # Extract key indicators by year
            $undpData = @{}
            
            # Get all year-based columns (format: indicator_YYYY)
            $properties = $vnmRow.PSObject.Properties | Where-Object { $_.Name -match '_(\d{4})$' }
            
            foreach ($prop in $properties) {
                if ($prop.Name -match '_(\d{4})$') {
                    $year = [int]$Matches[1]
                    
                    if (-not $undpData.ContainsKey($year)) {
                        $undpData[$year] = @{}
                    }
                    
                    # Store value if not empty
                    if ($vnmRow.($prop.Name) -and $vnmRow.($prop.Name) -ne "") {
                        $indicator = $prop.Name -replace '_\d{4}$', ''
                        $undpData[$year][$indicator] = $vnmRow.($prop.Name)
                    }
                }
            }
            
            Write-Host "    ✓ Extracted data for $($undpData.Count) years" -ForegroundColor Green
            return $undpData
        }
        else {
            Write-Host "    ⚠ Vietnam row not found" -ForegroundColor Yellow
            return @{}
        }
    }
    catch {
        Write-Host "    ✗ Error loading: $_" -ForegroundColor Red
        return @{}
    }
}

# ============================================================================
# Load All Data Sources
# ============================================================================

Write-Host "Loading data sources..." -ForegroundColor Cyan

# 1. World Bank World Comparisons
Write-Host "`n1. World Comparisons" -ForegroundColor Yellow
$worldPopulation = Load-WBWorldData -FilePath "$rawDataPath\wb_world_population.json" -IndicatorName "World Population"
$worldUrbanization = Load-WBWorldData -FilePath "$rawDataPath\wb_world_urbanization.json" -IndicatorName "World Urbanization %"

# 2. Vietnam Rankings
Write-Host "`n2. Vietnam Rankings" -ForegroundColor Yellow
$globalRanks = Load-CustomJSONArray -FilePath "$rawDataPath\vietnam_global_ranks.json" -DataType "Global Rankings"
$aseanRanks = Load-CustomJSONArray -FilePath "$rawDataPath\vietnam_asean_ranks.json" -DataType "ASEAN Rankings"

# 3. ASEAN Regional Aggregates
Write-Host "`n3. ASEAN Aggregates" -ForegroundColor Yellow
$aseanFertility = Load-CustomJSONArray -FilePath "$rawDataPath\asean_fertility_rates.json" -DataType "ASEAN Fertility Rates"

# 4. Poverty & Inequality Indicators
Write-Host "`n4. Poverty & Inequality Indicators" -ForegroundColor Yellow
$povertyDDAY = Load-WBPovertyData -FilePath "$rawDataPath\wb_SI_POV_DDAY.json" -IndicatorName "Poverty $2.15/day"
$povertyGINI = Load-WBPovertyData -FilePath "$rawDataPath\wb_SI_POV_GINI.json" -IndicatorName "GINI Coefficient"
$povertyLMIC = Load-WBPovertyData -FilePath "$rawDataPath\wb_SI_POV_LMIC.json" -IndicatorName "Poverty LMIC"
$povertyNAHC = Load-WBPovertyData -FilePath "$rawDataPath\wb_SI_POV_NAHC.json" -IndicatorName "Poverty National"
$povertyUMIC = Load-WBPovertyData -FilePath "$rawDataPath\wb_SI_POV_UMIC.json" -IndicatorName "Poverty UMIC"
$povertyUMICGP = Load-WBPovertyData -FilePath "$rawDataPath\wb_SI_POV_UMIC_GP.json" -IndicatorName "Poverty UMIC Gini"
$incomeFirst10 = Load-WBPovertyData -FilePath "$rawDataPath\wb_SI_DST_FRST_10.json" -IndicatorName "Income Share First 10%"
$incomeTop10 = Load-WBPovertyData -FilePath "$rawDataPath\wb_SI_DST_10TH_10.json" -IndicatorName "Income Share Top 10%"

# 5. UNDP Human Development Report Data
Write-Host "`n5. UNDP HDR Data" -ForegroundColor Yellow
$undpData = Load-UNDPData -FilePath "$rawDataPath\undp_hdr_data.csv"

# ============================================================================
# Create Consolidated Dataset
# ============================================================================

Write-Host "`nCreating consolidated dataset..." -ForegroundColor Cyan

# Define year range
$startYear = 1960
$endYear = 2024
$years = $startYear..$endYear

# Initialize results array
$results = @()

foreach ($year in $years) {
    $row = [PSCustomObject]@{
        Year = $year
        
        # World Comparisons
        World_Population = if ($worldPopulation.ContainsKey($year)) { [math]::Round($worldPopulation[$year] / 1000000, 2) } else { "" }  # Convert to millions
        World_Urbanization_Pct = if ($worldUrbanization.ContainsKey($year)) { [math]::Round($worldUrbanization[$year], 2) } else { "" }
        
        # Vietnam Rankings
        VN_Global_Rank = if ($globalRanks.ContainsKey($year)) { $globalRanks[$year].Rank } else { "" }
        VN_Global_Rank_Population = if ($globalRanks.ContainsKey($year)) { [math]::Round($globalRanks[$year].Population / 1000000, 2) } else { "" }
        VN_ASEAN_Rank = if ($aseanRanks.ContainsKey($year)) { $aseanRanks[$year].Rank } else { "" }
        VN_ASEAN_Rank_Population = if ($aseanRanks.ContainsKey($year)) { [math]::Round($aseanRanks[$year].Population / 1000000, 2) } else { "" }
        
        # ASEAN Aggregates
        ASEAN_Avg_Fertility_Rate = if ($aseanFertility.ContainsKey($year)) { [math]::Round($aseanFertility[$year].Average, 3) } else { "" }
        ASEAN_Countries_Count = if ($aseanFertility.ContainsKey($year)) { $aseanFertility[$year].Countries } else { "" }
        
        # Poverty & Inequality (World Bank)
        Poverty_Rate_215_Day = if ($povertyDDAY.ContainsKey($year)) { [math]::Round($povertyDDAY[$year], 2) } else { "" }
        Poverty_GINI_Index = if ($povertyGINI.ContainsKey($year)) { [math]::Round($povertyGINI[$year], 2) } else { "" }
        Poverty_LMIC = if ($povertyLMIC.ContainsKey($year)) { [math]::Round($povertyLMIC[$year], 2) } else { "" }
        Poverty_National = if ($povertyNAHC.ContainsKey($year)) { [math]::Round($povertyNAHC[$year], 2) } else { "" }
        Poverty_UMIC = if ($povertyUMIC.ContainsKey($year)) { [math]::Round($povertyUMIC[$year], 2) } else { "" }
        Poverty_UMIC_Gini = if ($povertyUMICGP.ContainsKey($year)) { [math]::Round($povertyUMICGP[$year], 2) } else { "" }
        Income_Share_First_10Pct = if ($incomeFirst10.ContainsKey($year)) { [math]::Round($incomeFirst10[$year], 2) } else { "" }
        Income_Share_Top_10Pct = if ($incomeTop10.ContainsKey($year)) { [math]::Round($incomeTop10[$year], 2) } else { "" }
        
        # UNDP HDR Indicators (selected key indicators)
        HDI = if ($undpData.ContainsKey($year) -and $undpData[$year].ContainsKey('hdi')) { $undpData[$year]['hdi'] } else { "" }
        HDI_Rank = if ($undpData.ContainsKey($year) -and $undpData[$year].ContainsKey('hdi_rank')) { $undpData[$year]['hdi_rank'] } else { "" }
        Life_Expectancy = if ($undpData.ContainsKey($year) -and $undpData[$year].ContainsKey('le')) { $undpData[$year]['le'] } else { "" }
        Expected_Years_School = if ($undpData.ContainsKey($year) -and $undpData[$year].ContainsKey('eys')) { $undpData[$year]['eys'] } else { "" }
        Mean_Years_School = if ($undpData.ContainsKey($year) -and $undpData[$year].ContainsKey('mys')) { $undpData[$year]['mys'] } else { "" }
        GNI_Per_Capita = if ($undpData.ContainsKey($year) -and $undpData[$year].ContainsKey('gnipc')) { $undpData[$year]['gnipc'] } else { "" }
        GII = if ($undpData.ContainsKey($year) -and $undpData[$year].ContainsKey('gii')) { $undpData[$year]['gii'] } else { "" }
        GII_Rank = if ($undpData.ContainsKey($year) -and $undpData[$year].ContainsKey('gii_rank')) { $undpData[$year]['gii_rank'] } else { "" }
    }
    
    $results += $row
}

# ============================================================================
# Export to CSV
# ============================================================================

Write-Host "`nExporting to CSV..." -ForegroundColor Cyan

# Ensure output directory exists
if (-not (Test-Path $outputPath)) {
    New-Item -ItemType Directory -Path $outputPath | Out-Null
}

# Export to CSV
$results | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8

Write-Host "  ✓ Exported to: $outputFile" -ForegroundColor Green

# ============================================================================
# Calculate Statistics
# ============================================================================

Write-Host "`nCalculating fill statistics..." -ForegroundColor Cyan

$indicatorCount = ($results[0].PSObject.Properties | Measure-Object).Count - 1  # Exclude Year column
$totalCells = $results.Count * $indicatorCount
$filledCells = 0

foreach ($row in $results) {
    foreach ($prop in $row.PSObject.Properties) {
        if ($prop.Name -ne "Year" -and $prop.Value -ne "") {
            $filledCells++
        }
    }
}

$fillRate = [math]::Round(($filledCells / $totalCells) * 100, 2)

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Consolidation Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Total Years:          $($results.Count)" -ForegroundColor White
Write-Host "Total Indicators:     $indicatorCount" -ForegroundColor White
Write-Host "Total Cells:          $totalCells" -ForegroundColor White
Write-Host "Filled Cells:         $filledCells" -ForegroundColor White
Write-Host "Fill Rate:            $fillRate%" -ForegroundColor $(if ($fillRate -ge 50) { "Green" } elseif ($fillRate -ge 25) { "Yellow" } else { "Red" })

# Detailed statistics by category
Write-Host "`nFill Statistics by Category:" -ForegroundColor Cyan

$categories = @{
    "World Comparisons" = @("World_Population", "World_Urbanization_Pct")
    "Vietnam Rankings" = @("VN_Global_Rank", "VN_Global_Rank_Population", "VN_ASEAN_Rank", "VN_ASEAN_Rank_Population")
    "ASEAN Aggregates" = @("ASEAN_Avg_Fertility_Rate", "ASEAN_Countries_Count")
    "Poverty & Inequality" = @("Poverty_Rate_215_Day", "Poverty_GINI_Index", "Poverty_LMIC", "Poverty_National", "Poverty_UMIC", "Poverty_UMIC_Gini", "Income_Share_First_10Pct", "Income_Share_Top_10Pct")
    "UNDP HDR" = @("HDI", "HDI_Rank", "Life_Expectancy", "Expected_Years_School", "Mean_Years_School", "GNI_Per_Capita", "GII", "GII_Rank")
}

foreach ($category in $categories.GetEnumerator()) {
    $categoryFilled = 0
    $categoryTotal = $results.Count * $category.Value.Count
    
    foreach ($row in $results) {
        foreach ($indicator in $category.Value) {
            if ($row.$indicator -ne "") {
                $categoryFilled++
            }
        }
    }
    
    $categoryFillRate = [math]::Round(($categoryFilled / $categoryTotal) * 100, 2)
    $color = if ($categoryFillRate -ge 50) { "Green" } elseif ($categoryFillRate -ge 25) { "Yellow" } else { "Red" }
    
    Write-Host ("  {0,-25} {1,6}% ({2}/{3})" -f $category.Key, $categoryFillRate, $categoryFilled, $categoryTotal) -ForegroundColor $color
}

Write-Host "`n✓ Reference & Regional data consolidation complete!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan
