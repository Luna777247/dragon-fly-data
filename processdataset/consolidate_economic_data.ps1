# ============================================================================
# SCRIPT: Consolidate Economic Data
# PURPOSE: Tổng hợp dữ liệu từ ~15 files JSON/ZIP thành 1 CSV duy nhất
# OUTPUT: economic_consolidated.csv
# ============================================================================

Write-Host "╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║               TỔNG HỢP DỮ LIỆU KINH TẾ (Economic Data)                ║" -ForegroundColor Cyan
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
        $content = Get-Content $FilePath -Raw -Encoding UTF8
        $json = $content | ConvertFrom-Json
        $lookup = @{}
        
        # WB API format: [metadata, data_array] or [metadata, {value: data_array}]
        if ($json -is [Array] -and $json.Count -gt 1) {
            $dataElement = $json[1]
            
            # Check if data is directly an array or has 'value' property
            if ($dataElement -is [Array]) {
                $items = $dataElement
            } elseif ($dataElement.value -and $dataElement.value -is [Array]) {
                $items = $dataElement.value
            } else {
                $items = @()
            }
            
            foreach ($item in $items) {
                if ($item.date -and $null -ne $item.value) {
                    try {
                        $yearStr = $item.date.ToString()
                        $lookup[$yearStr] = [double]$item.value
                    } catch {
                        # Skip if conversion fails
                    }
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
    # GDP Indicators
    GDPTotal = Load-WBData "$rawPath\wb_gdp_total.json" "GDP Total (current US$)"
    GDPPerCapita = Load-WBData "$rawPath\wb_gdp_per_capita.json" "GDP per Capita"
    GDPPPP = Load-WBData "$rawPath\wb_gdp_ppp.json" "GDP PPP"
    GDPGrowth = Load-WBData "$rawPath\wb_gdp_growth.json" "GDP Growth Rate"
    
    # GNI Indicators
    GNI = Load-WBData "$rawPath\wb_gni.json" "GNI"
    GNIPerCapita = Load-WBData "$rawPath\wb_NY_GNP_PCAP_CD.json" "GNI per Capita (current US$)"
    GNIPerCapitaPPP = Load-WBData "$rawPath\wb_NY_GNP_PCAP_PP_CD.json" "GNI per Capita PPP"
    
    # Adjusted National Income
    AdjustedNNI = Load-WBData "$rawPath\wb_NY_ADJ_NNTY_PC_CD.json" "Adjusted Net National Income per Capita"
    
    # Inflation & Trade
    Inflation = Load-WBData "$rawPath\wb_inflation.json" "Inflation Rate"
    ExportsGDP = Load-WBData "$rawPath\wb_exports_gdp.json" "Exports (% of GDP)"
    ImportsGDP = Load-WBData "$rawPath\wb_imports_gdp.json" "Imports (% of GDP)"
    
    # FDI
    FDI = Load-WBData "$rawPath\wb_fdi.json" "FDI Net Inflows"
    FDIProcessed = Load-WBData "$rawPath\wb_fdi_processed.json" "FDI Processed"
    
    # Unemployment
    Unemployment = Load-WBData "$rawPath\wb_ilo_unemployment.json" "Unemployment Rate"
}

Write-Host "`n[2/3] Đang tải dữ liệu từ ZIP files..." -ForegroundColor Cyan

$zipData = @{
    GDPGrowthZIP = Load-ZIPData "$rawPath\gdp_growth.zip" "GDP Growth (ZIP)"
    UnemploymentZIP = Load-ZIPData "$rawPath\unemployment.zip" "Unemployment (ZIP)"
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
        
        # GDP Indicators (converted to billions for readability)
        GDPTotalBillion = if ($data.GDPTotal.ContainsKey($year)) { [math]::Round($data.GDPTotal[$year] / 1e9, 3) } else { "N/A" }
        GDPPerCapita = if ($data.GDPPerCapita.ContainsKey($year)) { [math]::Round($data.GDPPerCapita[$year], 2) } else { "N/A" }
        GDPPPPBillion = if ($data.GDPPPP.ContainsKey($year)) { [math]::Round($data.GDPPPP[$year] / 1e9, 3) } else { "N/A" }
        GDPGrowthRate = if ($data.GDPGrowth.ContainsKey($year)) { [math]::Round($data.GDPGrowth[$year], 2) } elseif ($zipData.GDPGrowthZIP.ContainsKey($year)) { [math]::Round($zipData.GDPGrowthZIP[$year], 2) } else { "N/A" }
        
        # GNI Indicators
        GNIBillion = if ($data.GNI.ContainsKey($year)) { [math]::Round($data.GNI[$year] / 1e9, 3) } else { "N/A" }
        GNIPerCapita = if ($data.GNIPerCapita.ContainsKey($year)) { [math]::Round($data.GNIPerCapita[$year], 2) } else { "N/A" }
        GNIPerCapitaPPP = if ($data.GNIPerCapitaPPP.ContainsKey($year)) { [math]::Round($data.GNIPerCapitaPPP[$year], 2) } else { "N/A" }
        
        # Adjusted National Income
        AdjustedNNIPerCapita = if ($data.AdjustedNNI.ContainsKey($year)) { [math]::Round($data.AdjustedNNI[$year], 2) } else { "N/A" }
        
        # Inflation
        InflationRate = if ($data.Inflation.ContainsKey($year)) { [math]::Round($data.Inflation[$year], 2) } else { "N/A" }
        
        # Trade (% of GDP)
        ExportsPercentGDP = if ($data.ExportsGDP.ContainsKey($year)) { [math]::Round($data.ExportsGDP[$year], 2) } else { "N/A" }
        ImportsPercentGDP = if ($data.ImportsGDP.ContainsKey($year)) { [math]::Round($data.ImportsGDP[$year], 2) } else { "N/A" }
        TradeBalance = if ($data.ExportsGDP.ContainsKey($year) -and $data.ImportsGDP.ContainsKey($year)) { 
            [math]::Round($data.ExportsGDP[$year] - $data.ImportsGDP[$year], 2) 
        } else { "N/A" }
        
        # FDI (converted to millions)
        FDINetInflowsMillion = if ($data.FDI.ContainsKey($year)) { [math]::Round($data.FDI[$year] / 1e6, 2) } elseif ($data.FDIProcessed.ContainsKey($year)) { [math]::Round($data.FDIProcessed[$year] / 1e6, 2) } else { "N/A" }
        
        # Unemployment
        UnemploymentRate = if ($data.Unemployment.ContainsKey($year)) { [math]::Round($data.Unemployment[$year], 2) } elseif ($zipData.UnemploymentZIP.ContainsKey($year)) { [math]::Round($zipData.UnemploymentZIP[$year], 2) } else { "N/A" }
    }
    
    $consolidated += $row
}

# ============================================================================
# EXPORT TO CSV
# ============================================================================
$outputFile = "$outputPath\economic_consolidated.csv"
$consolidated | Sort-Object Year | Export-Csv -Path $outputFile -NoTypeInformation -Encoding UTF8

Write-Host "`n╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                           HOÀN THÀNH                                   ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`n📊 Thống kê:" -ForegroundColor Cyan
Write-Host "  • Tổng số năm: $($consolidated.Count)" -ForegroundColor White
Write-Host "  • Tổng số chỉ số: 14 columns" -ForegroundColor White
Write-Host "  • File output: $outputFile" -ForegroundColor Yellow

# ============================================================================
# GENERATE DATA QUALITY REPORT
# ============================================================================
Write-Host "`n📈 Báo cáo chất lượng dữ liệu:" -ForegroundColor Cyan

$columns = @(
    "GDPTotalBillion", "GDPPerCapita", "GDPPPPBillion", "GDPGrowthRate",
    "GNIBillion", "GNIPerCapita", "GNIPerCapitaPPP",
    "AdjustedNNIPerCapita", "InflationRate",
    "ExportsPercentGDP", "ImportsPercentGDP", "TradeBalance",
    "FDINetInflowsMillion", "UnemploymentRate"
)

foreach ($col in $columns) {
    $validCount = ($consolidated | Where-Object { $_.$col -ne "N/A" }).Count
    $fillRate = [math]::Round(($validCount / $consolidated.Count) * 100, 1)
    
    $color = if ($fillRate -ge 80) { "Green" } elseif ($fillRate -ge 50) { "Yellow" } else { "Red" }
    Write-Host ("  • {0,-25} : {1,3}% ({2}/{3})" -f $col, $fillRate, $validCount, $consolidated.Count) -ForegroundColor $color
}

# ============================================================================
# GENERATE SUMMARY STATISTICS
# ============================================================================
Write-Host "`n📊 Tóm tắt số liệu (First vs Latest):" -ForegroundColor Cyan

$firstYear = $consolidated | Where-Object { $_.GDPTotalBillion -ne "N/A" } | Select-Object -First 1
$latestYear = $consolidated | Where-Object { $_.GDPTotalBillion -ne "N/A" } | Select-Object -Last 1

if ($firstYear -and $latestYear) {
    Write-Host "`n  GDP Total:" -ForegroundColor Yellow
    Write-Host "    • $($firstYear.Year): $($firstYear.GDPTotalBillion) tỷ USD" -ForegroundColor White
    Write-Host "    • $($latestYear.Year): $($latestYear.GDPTotalBillion) tỷ USD" -ForegroundColor White
    
    if ($firstYear.GDPPerCapita -ne "N/A" -and $latestYear.GDPPerCapita -ne "N/A") {
        Write-Host "`n  GDP per Capita:" -ForegroundColor Yellow
        Write-Host "    • $($firstYear.Year): `$$($firstYear.GDPPerCapita)" -ForegroundColor White
        Write-Host "    • $($latestYear.Year): `$$($latestYear.GDPPerCapita)" -ForegroundColor White
    }
}

Write-Host "`n✅ Script hoàn tất! Kiểm tra file: $outputFile" -ForegroundColor Green
