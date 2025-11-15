# ============================================================================
# SCRIPT: Consolidate Population & Demographics Data
# PURPOSE: Tổng hợp dữ liệu từ ~20 files JSON/ZIP thành 1 CSV duy nhất
# OUTPUT: population_demographics_consolidated.csv
# ============================================================================

Write-Host "╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     TỔNG HỢP DỮ LIỆU DÂN SỐ & NHÂN KHẨU (Population & Demographics)   ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

$rawPath = "..\rawdataset"
$outputPath = "."

# Ensure processdataset directory exists
if (-not (Test-Path $outputPath)) {
    New-Item -ItemType Directory -Path $outputPath | Out-Null
}

# ============================================================================
# FUNCTION: Load JSON data from World Bank format
# ============================================================================
function Load-WBData {
    param(
        [string]$FilePath,
        [string]$IndicatorName
    )
    
    if (-not (Test-Path $FilePath)) {
        Write-Host "  ⚠ Không tìm thấy: $FilePath" -ForegroundColor Yellow
        return @{}
    }
    
    try {
        $json = Get-Content $FilePath -Raw -Encoding UTF8 | ConvertFrom-Json
        $lookup = @{}
        
        if ($json.Count -gt 1 -and $json[1].value) {
            foreach ($item in $json[1].value) {
                if ($null -ne $item.value -and $item.date) {
                    $lookup[$item.date] = [double]$item.value
                }
            }
            Write-Host "  ✓ $IndicatorName : $($lookup.Count) năm" -ForegroundColor Green
        }
        
        return $lookup
    }
    catch {
        Write-Host "  ✗ Lỗi đọc $IndicatorName : $_" -ForegroundColor Red
        return @{}
    }
}

# ============================================================================
# FUNCTION: Extract and load data from ZIP files
# ============================================================================
function Load-ZIPData {
    param(
        [string]$ZipPath,
        [string]$IndicatorName
    )
    
    if (-not (Test-Path $ZipPath)) {
        Write-Host "  ⚠ Không tìm thấy: $ZipPath" -ForegroundColor Yellow
        return @{}
    }
    
    try {
        $extractPath = $ZipPath -replace '\.zip$', '_extracted'
        
        # Extract if not already extracted
        if (-not (Test-Path $extractPath)) {
            Expand-Archive -Path $ZipPath -DestinationPath $extractPath -Force
        }
        
        # Find CSV file in extracted folder
        $csvFile = Get-ChildItem -Path $extractPath -Filter "*.csv" | Select-Object -First 1
        
        if ($null -eq $csvFile) {
            Write-Host "  ✗ Không tìm thấy CSV trong $extractPath" -ForegroundColor Red
            return @{}
        }
        
        # Read CSV and create lookup
        $csv = Import-Csv $csvFile.FullName
        $lookup = @{}
        
        foreach ($row in $csv) {
            # Find Vietnam data (Country Code = VNM or VN)
            if ($row.'Country Code' -eq 'VNM' -or $row.'Country Code' -eq 'VN') {
                # Get all year columns (typically from 1960 onwards)
                $properties = $row.PSObject.Properties | Where-Object { $_.Name -match '^\d{4}$' }
                
                foreach ($prop in $properties) {
                    $year = $prop.Name
                    $value = $prop.Value
                    
                    if ($value -ne '' -and $value -ne '..' -and $null -ne $value) {
                        try {
                            $lookup[$year] = [double]$value
                        }
                        catch {
                            # Skip invalid values
                        }
                    }
                }
                break
            }
        }
        
        Write-Host "  ✓ $IndicatorName : $($lookup.Count) năm" -ForegroundColor Green
        return $lookup
    }
    catch {
        Write-Host "  ✗ Lỗi đọc ZIP $IndicatorName : $_" -ForegroundColor Red
        return @{}
    }
}

# ============================================================================
# LOAD ALL DATA SOURCES
# ============================================================================
Write-Host "`n[1/3] Đang tải dữ liệu từ JSON files..." -ForegroundColor Cyan

$data = @{
    PopulationDensity = Load-WBData "$rawPath\wb_population_density.json" "Population Density"
    Pop0to14 = Load-WBData "$rawPath\wb_pop_0_14.json" "Population 0-14"
    Pop15to64 = Load-WBData "$rawPath\wb_pop_15_64.json" "Population 15-64"
    Pop65Plus = Load-WBData "$rawPath\wb_pop_65plus.json" "Population 65+"
    Births = Load-WBData "$rawPath\wb_births.json" "Births"
    Deaths = Load-WBData "$rawPath\wb_deaths.json" "Deaths"
    BirthRate = Load-WBData "$rawPath\wb_birth_rate.json" "Birth Rate"
    DeathRate = Load-WBData "$rawPath\wb_death_rate.json" "Death Rate"
    FertilityRate = Load-WBData "$rawPath\wb_fertility_rate.json" "Fertility Rate"
    MedianAge = Load-WBData "$rawPath\wb_median_age.json" "Median Age"
    SexRatio = Load-WBData "$rawPath\wb_sex_ratio.json" "Sex Ratio"
    Migration = Load-WBData "$rawPath\wb_migration.json" "Net Migration"
    DependencyRatio = Load-WBData "$rawPath\wb_dependency_ratio.json" "Dependency Ratio"
    RuralPopulation = Load-WBData "$rawPath\wb_rural_population.json" "Rural Population"
    UrbanPopulation = Load-WBData "$rawPath\wb_urban_population.json" "Urban Population"
    Urbanization = Load-WBData "$rawPath\wb_urbanization.json" "Urbanization Rate"
    UrbanGrowth = Load-WBData "$rawPath\wb_urban_growth.json" "Urban Growth Rate"
}

Write-Host "`n[2/3] Đang tải dữ liệu từ ZIP files..." -ForegroundColor Cyan

$zipData = @{
    Age0to14ZIP = Load-ZIPData "$rawPath\age_0_14.zip" "Age 0-14 (ZIP)"
    Age15to64ZIP = Load-ZIPData "$rawPath\age_15_64.zip" "Age 15-64 (ZIP)"
    Age65UpZIP = Load-ZIPData "$rawPath\age_65_up.zip" "Age 65+ (ZIP)"
    BirthRateZIP = Load-ZIPData "$rawPath\birth_rate.zip" "Birth Rate (ZIP)"
    DeathRateZIP = Load-ZIPData "$rawPath\death_rate.zip" "Death Rate (ZIP)"
    DependencyRatioZIP = Load-ZIPData "$rawPath\dependency_ratio.zip" "Dependency Ratio (ZIP)"
    PopGrowthZIP = Load-ZIPData "$rawPath\pop_growth.zip" "Population Growth (ZIP)"
    FertilityZIP = Load-ZIPData "$rawPath\fertility.zip" "Fertility (ZIP)"
}

# ============================================================================
# MERGE DATA FROM MULTIPLE SOURCES (prefer JSON over ZIP)
# ============================================================================
Write-Host "`n[3/3] Đang hợp nhất dữ liệu..." -ForegroundColor Cyan

# Get all unique years from all sources
$allYears = @()
foreach ($dataset in $data.Values + $zipData.Values) {
    $allYears += $dataset.Keys
}
$uniqueYears = $allYears | Sort-Object -Unique

Write-Host "  → Tìm thấy $($uniqueYears.Count) năm từ $($allYears.Count) data points" -ForegroundColor White

# Create consolidated dataset
$consolidated = @()

foreach ($year in $uniqueYears) {
    $row = [PSCustomObject]@{
        Year = $year
        
        # Population Structure
        PopulationDensity = if ($data.PopulationDensity.ContainsKey($year)) { $data.PopulationDensity[$year] } else { "N/A" }
        Pop0to14Pct = if ($data.Pop0to14.ContainsKey($year)) { $data.Pop0to14[$year] } elseif ($zipData.Age0to14ZIP.ContainsKey($year)) { $zipData.Age0to14ZIP[$year] } else { "N/A" }
        Pop15to64Pct = if ($data.Pop15to64.ContainsKey($year)) { $data.Pop15to64[$year] } elseif ($zipData.Age15to64ZIP.ContainsKey($year)) { $zipData.Age15to64ZIP[$year] } else { "N/A" }
        Pop65PlusPct = if ($data.Pop65Plus.ContainsKey($year)) { $data.Pop65Plus[$year] } elseif ($zipData.Age65UpZIP.ContainsKey($year)) { $zipData.Age65UpZIP[$year] } else { "N/A" }
        
        # Vital Statistics
        BirthsTotal = if ($data.Births.ContainsKey($year)) { $data.Births[$year] } else { "N/A" }
        DeathsTotal = if ($data.Deaths.ContainsKey($year)) { $data.Deaths[$year] } else { "N/A" }
        BirthRatePer1000 = if ($data.BirthRate.ContainsKey($year)) { $data.BirthRate[$year] } elseif ($zipData.BirthRateZIP.ContainsKey($year)) { $zipData.BirthRateZIP[$year] } else { "N/A" }
        DeathRatePer1000 = if ($data.DeathRate.ContainsKey($year)) { $data.DeathRate[$year] } elseif ($zipData.DeathRateZIP.ContainsKey($year)) { $zipData.DeathRateZIP[$year] } else { "N/A" }
        
        # Demographics
        FertilityRate = if ($data.FertilityRate.ContainsKey($year)) { $data.FertilityRate[$year] } elseif ($zipData.FertilityZIP.ContainsKey($year)) { $zipData.FertilityZIP[$year] } else { "N/A" }
        MedianAge = if ($data.MedianAge.ContainsKey($year)) { $data.MedianAge[$year] } else { "N/A" }
        SexRatio = if ($data.SexRatio.ContainsKey($year)) { $data.SexRatio[$year] } else { "N/A" }
        DependencyRatio = if ($data.DependencyRatio.ContainsKey($year)) { $data.DependencyRatio[$year] } elseif ($zipData.DependencyRatioZIP.ContainsKey($year)) { $zipData.DependencyRatioZIP[$year] } else { "N/A" }
        
        # Migration & Growth
        NetMigration = if ($data.Migration.ContainsKey($year)) { $data.Migration[$year] } else { "N/A" }
        PopulationGrowth = if ($zipData.PopGrowthZIP.ContainsKey($year)) { $zipData.PopGrowthZIP[$year] } else { "N/A" }
        
        # Urban/Rural
        RuralPopulation = if ($data.RuralPopulation.ContainsKey($year)) { $data.RuralPopulation[$year] } else { "N/A" }
        UrbanPopulation = if ($data.UrbanPopulation.ContainsKey($year)) { $data.UrbanPopulation[$year] } else { "N/A" }
        UrbanizationPct = if ($data.Urbanization.ContainsKey($year)) { $data.Urbanization[$year] } else { "N/A" }
        UrbanGrowthRate = if ($data.UrbanGrowth.ContainsKey($year)) { $data.UrbanGrowth[$year] } else { "N/A" }
    }
    
    $consolidated += $row
}

# ============================================================================
# EXPORT TO CSV
# ============================================================================
$outputFile = "$outputPath\population_demographics_consolidated.csv"
$consolidated | Sort-Object Year | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8

Write-Host "`n╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                           HOÀN THÀNH                                   ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`n📊 Thống kê:" -ForegroundColor Cyan
Write-Host "  • Tổng số năm: $($consolidated.Count)" -ForegroundColor White
Write-Host "  • Tổng số chỉ số: 17 columns" -ForegroundColor White
Write-Host "  • File output: $outputFile" -ForegroundColor Yellow

# ============================================================================
# GENERATE DATA QUALITY REPORT
# ============================================================================
Write-Host "`n📈 Báo cáo chất lượng dữ liệu:" -ForegroundColor Cyan

$columns = @(
    "PopulationDensity", "Pop0to14Pct", "Pop15to64Pct", "Pop65PlusPct",
    "BirthsTotal", "DeathsTotal", "BirthRatePer1000", "DeathRatePer1000",
    "FertilityRate", "MedianAge", "SexRatio", "DependencyRatio",
    "NetMigration", "PopulationGrowth", "RuralPopulation", 
    "UrbanPopulation", "UrbanizationPct", "UrbanGrowthRate"
)

foreach ($col in $columns) {
    $validCount = ($consolidated | Where-Object { $_.$col -ne "N/A" }).Count
    $fillRate = [math]::Round(($validCount / $consolidated.Count) * 100, 1)
    
    $color = if ($fillRate -ge 80) { "Green" } elseif ($fillRate -ge 50) { "Yellow" } else { "Red" }
    Write-Host ("  • {0,-25} : {1,3}% ({2}/{3})" -f $col, $fillRate, $validCount, $consolidated.Count) -ForegroundColor $color
}

Write-Host "`n✅ Script hoàn tất! Kiểm tra file: $outputFile" -ForegroundColor Green
