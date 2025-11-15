# =============================================================================
# Urbanization Data Consolidation Script
# =============================================================================
# Purpose: Consolidate Vietnam's urbanization indicators from multiple World Bank sources
# Dataset: Urbanization (Đô Thị Hóa)
# Indicators: 5 urbanization metrics
# Time Range: 1960-2024
#
# Input Files (5 sources):
#   - wb_urbanization.json (urban % of total population)
#   - wb_urban_population.json (total urban population)
#   - wb_urban_growth.json (urban population growth rate)
#   - wb_rural_population.json (total rural population)
#   - urban_growth.zip (backup urban growth data)
#
# Output: urbanization_consolidated.csv
# =============================================================================

# Helper function to load World Bank JSON data
function Load-WBData {
    param(
        [string]$FilePath,
        [string]$IndicatorName
    )
    
    if (-not (Test-Path $FilePath)) {
        Write-Host "File not found: $FilePath" -ForegroundColor Yellow
        return @{}
    }
    
    try {
        $jsonContent = Get-Content $FilePath -Raw -Encoding UTF8 | ConvertFrom-Json
        
        # World Bank API format: array with [metadata, data]
        $dataArray = $null
        if ($jsonContent -is [Array] -and $jsonContent.Count -ge 2) {
            $dataArray = $jsonContent[1].value
        } elseif ($jsonContent.value) {
            $dataArray = $jsonContent.value
        } else {
            Write-Host "Unexpected JSON structure in $FilePath" -ForegroundColor Yellow
            return @{}
        }
        
        # Create year -> value lookup
        $lookup = @{}
        foreach ($item in $dataArray) {
            # Check for Vietnam using multiple identifiers
            $isVietnam = $item.country.id -eq "VN" -or 
                         $item.country.id -eq "VNM" -or 
                         $item.countryiso3code -eq "VNM"
            
            if ($isVietnam -and $item.value -ne $null -and $item.value -ne "") {
                $year = $item.date
                $lookup[$year] = [decimal]$item.value
            }
        }
        
        $count = $lookup.Count
        Write-Host "  $IndicatorName : $count years" -ForegroundColor Cyan
        return $lookup
        
    } catch {
        Write-Host "Error parsing $FilePath : $_" -ForegroundColor Red
        return @{}
    }
}

# Helper function to load ZIP archive data
function Load-ZIPData {
    param(
        [string]$ZipPath,
        [string]$IndicatorName
    )
    
    if (-not (Test-Path $ZipPath)) {
        Write-Host "ZIP file not found: $ZipPath" -ForegroundColor Yellow
        return @{}
    }
    
    try {
        # Create temp extraction directory
        $tempDir = Join-Path $env:TEMP "urban_extract_$(Get-Random)"
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        
        # Extract ZIP
        Expand-Archive -Path $ZipPath -DestinationPath $tempDir -Force
        
        # Find CSV file
        $csvFile = Get-ChildItem -Path $tempDir -Filter "*.csv" -Recurse | Select-Object -First 1
        
        if (-not $csvFile) {
            Write-Host "No CSV found in $ZipPath" -ForegroundColor Yellow
            Remove-Item -Path $tempDir -Recurse -Force
            return @{}
        }
        
        # Read CSV
        $csvData = Import-Csv -Path $csvFile.FullName
        
        # Find Vietnam row
        $vnmRow = $csvData | Where-Object { 
            $_.'Country Code' -eq 'VNM' -or 
            $_.'Country Name' -like '*Vietnam*' -or
            $_.'Country Name' -eq 'Viet Nam'
        } | Select-Object -First 1
        
        if (-not $vnmRow) {
            Write-Host "Vietnam data not found in ZIP CSV" -ForegroundColor Yellow
            Remove-Item -Path $tempDir -Recurse -Force
            return @{}
        }
        
        # Extract year columns
        $lookup = @{}
        $vnmRow.PSObject.Properties | ForEach-Object {
            if ($_.Name -match '^\d{4}$') {
                $year = $_.Name
                $value = $_.Value
                if ($value -ne $null -and $value -ne "" -and $value -ne ".." -and $value -ne "N/A") {
                    $lookup[$year] = [decimal]$value
                }
            }
        }
        
        # Cleanup
        Remove-Item -Path $tempDir -Recurse -Force
        
        $count = $lookup.Count
        Write-Host "  $IndicatorName (ZIP): $count years" -ForegroundColor Cyan
        return $lookup
        
    } catch {
        Write-Host "Error extracting $ZipPath : $_" -ForegroundColor Red
        return @{}
    }
}

# =============================================================================
# Main Consolidation Process
# =============================================================================

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Vietnam Urbanization Data Consolidation" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

$rawDataPath = "..\rawdataset"

# Load urbanization indicators
Write-Host "Loading urbanization data sources..." -ForegroundColor Yellow

$urbanPercent = Load-WBData -FilePath "$rawDataPath\wb_urbanization.json" -IndicatorName "Urban Population %"
$urbanPopulation = Load-WBData -FilePath "$rawDataPath\wb_urban_population.json" -IndicatorName "Urban Population (total)"
$urbanGrowth = Load-WBData -FilePath "$rawDataPath\wb_urban_growth.json" -IndicatorName "Urban Population Growth Rate"
$ruralPopulation = Load-WBData -FilePath "$rawDataPath\wb_rural_population.json" -IndicatorName "Rural Population (total)"

# Load ZIP backup
$urbanGrowthZip = Load-ZIPData -ZipPath "$rawDataPath\urban_growth.zip" -IndicatorName "Urban Growth Rate (ZIP)"

# Merge urban growth data (prefer JSON, fallback to ZIP)
if ($urbanGrowth.Count -eq 0 -and $urbanGrowthZip.Count -gt 0) {
    Write-Host "Using ZIP data for Urban Growth Rate" -ForegroundColor Cyan
    $urbanGrowth = $urbanGrowthZip
}

Write-Host "`nData loading complete!`n" -ForegroundColor Green

# =============================================================================
# Generate Consolidated CSV
# =============================================================================

Write-Host "Generating consolidated CSV..." -ForegroundColor Yellow

# Define year range
$startYear = 1960
$endYear = 2024
$allYears = $startYear..$endYear

# Create output array
$output = @()

foreach ($year in $allYears) {
    $row = [PSCustomObject]@{
        Year = $year
        UrbanPopulationPercent = if ($urbanPercent.ContainsKey("$year")) { $urbanPercent["$year"] } else { "N/A" }
        UrbanPopulation = if ($urbanPopulation.ContainsKey("$year")) { $urbanPopulation["$year"] } else { "N/A" }
        UrbanGrowthRate = if ($urbanGrowth.ContainsKey("$year")) { $urbanGrowth["$year"] } else { "N/A" }
        RuralPopulation = if ($ruralPopulation.ContainsKey("$year")) { $ruralPopulation["$year"] } else { "N/A" }
    }
    $output += $row
}

# Export to CSV
$outputPath = "urbanization_consolidated.csv"
$output | Export-Csv -Path $outputPath -NoTypeInformation -Encoding UTF8

Write-Host "CSV exported: $outputPath" -ForegroundColor Green

# =============================================================================
# Data Quality Report
# =============================================================================

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Data Quality Summary" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

# Calculate fill rates
$totalCells = $allYears.Count * 4  # 4 indicators
$filledCells = 0

foreach ($row in $output) {
    if ($row.UrbanPopulationPercent -ne "N/A") { $filledCells++ }
    if ($row.UrbanPopulation -ne "N/A") { $filledCells++ }
    if ($row.UrbanGrowthRate -ne "N/A") { $filledCells++ }
    if ($row.RuralPopulation -ne "N/A") { $filledCells++ }
}

$fillRate = [math]::Round(($filledCells / $totalCells) * 100, 1)

Write-Host "Total Years: $($allYears.Count)" -ForegroundColor Cyan
Write-Host "Total Indicators: 4" -ForegroundColor Cyan
Write-Host "Total Cells: $totalCells" -ForegroundColor Cyan
Write-Host "Filled Cells: $filledCells" -ForegroundColor Green
Write-Host "Average Fill Rate: $fillRate%" -ForegroundColor $(if ($fillRate -ge 70) { "Green" } elseif ($fillRate -ge 50) { "Yellow" } else { "Red" })

# Individual indicator fill rates
Write-Host "`nIndicator Fill Rates:" -ForegroundColor Yellow
$urbanPercentFill = ($output | Where-Object { $_.UrbanPopulationPercent -ne "N/A" }).Count
$urbanPopFill = ($output | Where-Object { $_.UrbanPopulation -ne "N/A" }).Count
$urbanGrowthFill = ($output | Where-Object { $_.UrbanGrowthRate -ne "N/A" }).Count
$ruralPopFill = ($output | Where-Object { $_.RuralPopulation -ne "N/A" }).Count

Write-Host "  Urban Population %: $urbanPercentFill/$($allYears.Count) ($([math]::Round($urbanPercentFill/$allYears.Count*100, 1))%)" -ForegroundColor Cyan
Write-Host "  Urban Population: $urbanPopFill/$($allYears.Count) ($([math]::Round($urbanPopFill/$allYears.Count*100, 1))%)" -ForegroundColor Cyan
Write-Host "  Urban Growth Rate: $urbanGrowthFill/$($allYears.Count) ($([math]::Round($urbanGrowthFill/$allYears.Count*100, 1))%)" -ForegroundColor Cyan
Write-Host "  Rural Population: $ruralPopFill/$($allYears.Count) ($([math]::Round($ruralPopFill/$allYears.Count*100, 1))%)" -ForegroundColor Cyan

# =============================================================================
# Historical Analysis
# =============================================================================

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Historical Urbanization Analysis" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

# Get data with values
$validUrbanPercent = $output | Where-Object { $_.UrbanPopulationPercent -ne "N/A" }
$validUrbanPop = $output | Where-Object { $_.UrbanPopulation -ne "N/A" }
$validUrbanGrowth = $output | Where-Object { $_.UrbanGrowthRate -ne "N/A" }

if ($validUrbanPercent.Count -gt 0) {
    $firstUrbanPercent = $validUrbanPercent | Select-Object -First 1
    $lastUrbanPercent = $validUrbanPercent | Select-Object -Last 1
    $urbanPercentChange = [decimal]$lastUrbanPercent.UrbanPopulationPercent - [decimal]$firstUrbanPercent.UrbanPopulationPercent
    $urbanPercentChangePercent = ($urbanPercentChange / [decimal]$firstUrbanPercent.UrbanPopulationPercent) * 100
    
    Write-Host "Urban Population % Trend:" -ForegroundColor Yellow
    Write-Host "  First: $($firstUrbanPercent.Year) = $($firstUrbanPercent.UrbanPopulationPercent)%" -ForegroundColor White
    Write-Host "  Last: $($lastUrbanPercent.Year) = $($lastUrbanPercent.UrbanPopulationPercent)%" -ForegroundColor White
    Write-Host "  Change: +$([math]::Round($urbanPercentChange, 2)) percentage points (+$([math]::Round($urbanPercentChangePercent, 1))%)" -ForegroundColor Green
}

if ($validUrbanPop.Count -gt 0) {
    $firstUrbanPop = $validUrbanPop | Select-Object -First 1
    $lastUrbanPop = $validUrbanPop | Select-Object -Last 1
    $urbanPopGrowth = ([decimal]$lastUrbanPop.UrbanPopulation / [decimal]$firstUrbanPop.UrbanPopulation - 1) * 100
    $urbanPopMillions = [decimal]$lastUrbanPop.UrbanPopulation / 1000000
    
    Write-Host "`nUrban Population Growth:" -ForegroundColor Yellow
    Write-Host "  First: $($firstUrbanPop.Year) = $([math]::Round([decimal]$firstUrbanPop.UrbanPopulation / 1000000, 2)) million" -ForegroundColor White
    Write-Host "  Last: $($lastUrbanPop.Year) = $([math]::Round($urbanPopMillions, 2)) million" -ForegroundColor White
    Write-Host "  Growth: +$([math]::Round($urbanPopGrowth, 1))%" -ForegroundColor Green
}

if ($validUrbanGrowth.Count -gt 0) {
    $avgUrbanGrowth = ($validUrbanGrowth | Measure-Object -Property UrbanGrowthRate -Average).Average
    $maxGrowth = ($validUrbanGrowth | Sort-Object { [decimal]$_.UrbanGrowthRate } -Descending | Select-Object -First 1)
    $minGrowth = ($validUrbanGrowth | Sort-Object { [decimal]$_.UrbanGrowthRate } | Select-Object -First 1)
    
    Write-Host "`nUrban Growth Rate Statistics:" -ForegroundColor Yellow
    Write-Host "  Average: $([math]::Round($avgUrbanGrowth, 2))% per year" -ForegroundColor White
    Write-Host "  Peak: $($maxGrowth.Year) = $($maxGrowth.UrbanGrowthRate)% per year" -ForegroundColor White
    Write-Host "  Minimum: $($minGrowth.Year) = $($minGrowth.UrbanGrowthRate)% per year" -ForegroundColor White
}

# Urbanization velocity (percentage point change per decade)
if ($validUrbanPercent.Count -gt 10) {
    $recent10Years = $validUrbanPercent | Select-Object -Last 11
    if ($recent10Years.Count -eq 11) {
        $decade10Start = [decimal]$recent10Years[0].UrbanPopulationPercent
        $decade10End = [decimal]$recent10Years[10].UrbanPopulationPercent
        $decade10Change = $decade10End - $decade10Start
        
        Write-Host "`nRecent Urbanization Velocity (Last 10 Years):" -ForegroundColor Yellow
        Write-Host "  Change: +$([math]::Round($decade10Change, 2)) percentage points" -ForegroundColor White
        Write-Host "  Rate: $([math]::Round($decade10Change / 10, 2)) pp per year" -ForegroundColor White
    }
}

# Rural-Urban balance
$latestData = $output | Where-Object { $_.UrbanPopulation -ne "N/A" -and $_.RuralPopulation -ne "N/A" } | Select-Object -Last 1
if ($latestData) {
    $urbanPop = [decimal]$latestData.UrbanPopulation
    $ruralPop = [decimal]$latestData.RuralPopulation
    $totalPop = $urbanPop + $ruralPop
    $urbanPercent = ($urbanPop / $totalPop) * 100
    $ruralPercent = ($ruralPop / $totalPop) * 100
    
    Write-Host "`nCurrent Urban-Rural Balance ($($latestData.Year)):" -ForegroundColor Yellow
    Write-Host "  Urban: $([math]::Round($urbanPop / 1000000, 2)) million ($([math]::Round($urbanPercent, 1))%)" -ForegroundColor Cyan
    Write-Host "  Rural: $([math]::Round($ruralPop / 1000000, 2)) million ($([math]::Round($ruralPercent, 1))%)" -ForegroundColor Cyan
    Write-Host "  Total: $([math]::Round($totalPop / 1000000, 2)) million" -ForegroundColor White
}

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Consolidation Complete!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Review urbanization_consolidated.csv" -ForegroundColor White
Write-Host "  2. Analyze urbanization trends and patterns" -ForegroundColor White
Write-Host "  3. Compare with regional urbanization rates" -ForegroundColor White
Write-Host "  4. Integrate with main vietnam_advance.csv dataset" -ForegroundColor White
