# Create comprehensive Vietnam dataset from World Bank API and UNDP data
Write-Host "🔧 TẠO VIETNAM DATASET TỪ CÁC NGUỒN DỮ LIỆU" -ForegroundColor Cyan
Write-Host "=" * 72 -ForegroundColor DarkGray

# Initialize data structure
$yearStart = 1960
$yearEnd = 2025
$allYears = $yearStart..$yearEnd

# Create base dataset with years
$dataset = @()
foreach($year in $allYears) {
    $dataset += [PSCustomObject]@{
        Year = $year
        Population = $null
        'Vietnam Global Rank' = $null
        'ASEAN Population Rank' = $null
        "Vietnam's Share of Asian Pop (%)" = $null
        "Country's Share of World Pop" = $null
        'Median Age' = $null
        'Regional Median Age' = $null
        'Global Median Age' = $null
        'Dependency Ratio (%)' = $null
        'Sex Ratio (M/F)' = $null
        'Pop Aged 0–14 (%)' = $null
        'Pop Aged 15–64 (%)' = $null
        'Pop Aged 65+ (%)' = $null
        'GDP per Capita (USD)' = $null
        'HDI' = $null
        'Unemployment Rate (%)' = $null
        'GDP Growth Rate (%)' = $null
        'FDI Net Inflows (million USD)' = $null
        'GDP PPP per Capita (Int$)' = $null
        'Fertility Rate' = $null
        'Life Expectancy' = $null
        'Birth Rate (‰)' = $null
        'Death Rate (‰)' = $null
        'Employment Agriculture (%)' = $null
        'Employment Industry (%)' = $null
        'Employment Services (%)' = $null
        'Poverty Rate (%)' = $null
        'Health Expenditure (% GDP)' = $null
        'Rural Population' = $null
        'Urban Population' = $null
        'Energy Consumption per Capita (kWh)' = $null
        'CO₂ Emissions per Capita (t)' = $null
        'Agricultural Land (% Land)' = $null
        'Forest Area (% Land)' = $null
        'Human Capital Index (0-1)' = $null
        'Renewable Energy Share (%)' = $null
    }
}

Write-Host "`n📊 Đang thu thập dữ liệu từ World Bank API..." -ForegroundColor Yellow

# Function to safely get value
function Get-SafeValue($row, $year) {
    $value = $row.$year
    if($value -and $value -ne '' -and $value -ne '..') {
        try {
            $num = [double]$value
            if($num -eq 0) { return 'N/A' }
            return [Math]::Round($num, 2).ToString()
        } catch {
            return 'N/A'
        }
    }
    return 'N/A'
}

# Load World Bank data files
$wbFiles = @{
    'API_NY.GDP.MKTP.KD.ZG_DS2_en_csv_v2_216044.csv' = 'GDP Growth Rate (%)'
    'API_SL.UEM.TOTL.ZS_DS2_en_csv_v2_130165.csv' = 'Unemployment Rate (%)'
    'API_SH.XPD.CHEX.GD.ZS_DS2_en_csv_v2_127434.csv' = 'Health Expenditure (% GDP)'
    'API_EN.ATM.CO2E.PC_DS57_en_csv_v2_123436.csv' = 'CO₂ Emissions per Capita (t)'
    'API_SP.DYN.CDRT.IN_DS2_en_csv_v2_125471.csv' = 'Death Rate (‰)'
    'API_EG.FEC.RNEW.ZS_DS2_en_csv_v2_130800.csv' = 'Renewable Energy Share (%)'
}

foreach($file in $wbFiles.Keys) {
    $columnName = $wbFiles[$file]
    Write-Host "  • $columnName..." -ForegroundColor Gray
    
    try {
        # Read and skip first 2 header rows
        $content = Get-Content $file -Encoding UTF8
        $csvContent = $content | Select-Object -Skip 2
        $csv = $csvContent | ConvertFrom-Csv
        
        $vnRow = $csv | Where-Object {$_.'Country Code' -eq 'VNM'} | Select-Object -First 1
        
        if($vnRow) {
            $dataCount = 0
            for($i = 0; $i -lt $dataset.Count; $i++) {
                $year = $dataset[$i].Year
                $value = Get-SafeValue $vnRow $year
                if($value -ne 'N/A') {
                    $dataset[$i].$columnName = $value
                    $dataCount++
                }
            }
            Write-Host "    ✓ $dataCount giá trị" -ForegroundColor Green
        }
    } catch {
        Write-Host "    ⚠️ Lỗi: $_" -ForegroundColor Yellow
    }
}

Write-Host "`n📊 Đang thu thập dữ liệu từ UNDP HDR..." -ForegroundColor Yellow

# Load UNDP HDR data
try {
    $hdrCsv = Import-Csv "undp_hdr_data.csv" -Encoding UTF8
    $vnHdr = $hdrCsv | Where-Object {$_.iso3 -eq 'VNM'}
    
    if($vnHdr.Count -gt 0) {
        Write-Host "  • Tìm thấy $($vnHdr.Count) dòng dữ liệu UNDP" -ForegroundColor Green
        
        # Map UNDP columns to dataset
        $hdrMapping = @{
            'hdi' = 'HDI'
            'le' = 'Life Expectancy'
            'gnipc' = 'GDP per Capita (USD)'
        }
        
        foreach($row in $vnHdr) {
            $year = $null
            try {
                $year = [int]$row.year
            } catch { continue }
            
            $dataRow = $dataset | Where-Object {$_.Year -eq $year} | Select-Object -First 1
            if($dataRow) {
                foreach($hdrCol in $hdrMapping.Keys) {
                    $targetCol = $hdrMapping[$hdrCol]
                    if($row.$hdrCol -and $row.$hdrCol -ne '' -and $row.$hdrCol -ne '..') {
                        try {
                            $value = [double]$row.$hdrCol
                            if($value -ne 0) {
                                $dataRow.$targetCol = [Math]::Round($value, 2).ToString()
                            }
                        } catch {}
                    }
                }
            }
        }
    }
} catch {
    Write-Host "  ⚠️ Lỗi đọc UNDP data: $_" -ForegroundColor Yellow
}

# Add estimated population data (from World Bank)
Write-Host "`n📊 Đang thu thập dữ liệu dân số..." -ForegroundColor Yellow
try {
    # Try to find population file
    $popFiles = Get-ChildItem -Filter "*population*.csv" | Where-Object {$_.Name -like "API_*"}
    
    if($popFiles.Count -eq 0) {
        Write-Host "  ⚠️ Không tìm thấy file population, sử dụng ước tính" -ForegroundColor Yellow
        
        # Use estimated values for key years
        $popData = @{
            1960 = 32670000
            1970 = 43404500
            1980 = 54373000
            1990 = 67589000
            2000 = 77154011
            2010 = 87455152
            2015 = 92823254
            2020 = 98079191
            2025 = 99460000
        }
        
        foreach($year in $popData.Keys) {
            $dataRow = $dataset | Where-Object {$_.Year -eq $year} | Select-Object -First 1
            if($dataRow) {
                $dataRow.Population = $popData[$year].ToString()
            }
        }
        
        # Linear interpolation for missing years
        for($i = 1; $i -lt $dataset.Count; $i++) {
            if(!$dataset[$i].Population -or $dataset[$i].Population -eq 'N/A') {
                # Find previous and next known values
                $prevIdx = $i - 1
                while($prevIdx -ge 0 -and (!$dataset[$prevIdx].Population -or $dataset[$prevIdx].Population -eq 'N/A')) {
                    $prevIdx--
                }
                
                $nextIdx = $i + 1
                while($nextIdx -lt $dataset.Count -and (!$dataset[$nextIdx].Population -or $dataset[$nextIdx].Population -eq 'N/A')) {
                    $nextIdx++
                }
                
                if($prevIdx -ge 0 -and $nextIdx -lt $dataset.Count) {
                    $prevPop = [long]$dataset[$prevIdx].Population
                    $nextPop = [long]$dataset[$nextIdx].Population
                    $prevYear = [int]$dataset[$prevIdx].Year
                    $nextYear = [int]$dataset[$nextIdx].Year
                    $currentYear = [int]$dataset[$i].Year
                    
                    $ratio = ($currentYear - $prevYear) / ($nextYear - $prevYear)
                    $interpolated = [long]($prevPop + ($nextPop - $prevPop) * $ratio)
                    $dataset[$i].Population = $interpolated.ToString()
                }
            }
        }
    }
} catch {
    Write-Host "  ⚠️ Lỗi xử lý population: $_" -ForegroundColor Yellow
}

# Filter out years with no significant data
Write-Host "`n🔍 Lọc các năm có dữ liệu..." -ForegroundColor Yellow
$filteredDataset = @()
foreach($row in $dataset) {
    $nonNullCount = 0
    foreach($prop in $row.PSObject.Properties) {
        if($prop.Name -ne 'Year' -and $prop.Value -and $prop.Value -ne 'N/A' -and $prop.Value -ne '') {
            $nonNullCount++
        }
    }
    
    # Keep years with at least 3 data points
    if($nonNullCount -ge 3) {
        $filteredDataset += $row
    }
}

Write-Host "  • Giữ lại $($filteredDataset.Count) năm có dữ liệu (từ $($dataset.Count) năm)" -ForegroundColor Green

# Export to CSV
$outputFile = "vietnam.csv"
$filteredDataset | Sort-Object {[int]$_.Year} | Export-Csv $outputFile -Encoding UTF8 -NoTypeInformation

Write-Host "`n✅ ĐÃ TẠO DATASET MỚI: $outputFile" -ForegroundColor Green
Write-Host "=" * 72 -ForegroundColor DarkGray

# Summary
$finalCsv = Import-Csv $outputFile -Encoding UTF8
Write-Host "`n📊 TỔNG QUAN DATASET:" -ForegroundColor Cyan
Write-Host "  • Số năm: $($finalCsv.Count)" -ForegroundColor Gray
Write-Host "  • Năm đầu: $($finalCsv[0].Year)" -ForegroundColor Gray
Write-Host "  • Năm cuối: $($finalCsv[-1].Year)" -ForegroundColor Gray
Write-Host "  • Số cột: $($finalCsv[0].PSObject.Properties.Count)" -ForegroundColor Gray

# Calculate fill rate
$totalCells = $finalCsv.Count * ($finalCsv[0].PSObject.Properties.Count - 1)
$filledCells = 0
foreach($row in $finalCsv) {
    foreach($prop in $row.PSObject.Properties) {
        if($prop.Name -ne 'Year' -and $prop.Value -and $prop.Value -ne 'N/A' -and $prop.Value -ne '') {
            $filledCells++
        }
    }
}
$fillRate = [Math]::Round(($filledCells / $totalCells) * 100, 2)
Write-Host "  • Fill rate: $fillRate%" -ForegroundColor $(if($fillRate -ge 50){'Green'}elseif($fillRate -ge 30){'Yellow'}else{'Red'})

Write-Host "`n✅ HOÀN THÀNH!" -ForegroundColor Green
