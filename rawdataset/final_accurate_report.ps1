# Final accurate verification with exact column names
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  FINAL VERIFICATION REPORT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$csv = Import-Csv "src\data\vietnam_advance.csv" -Encoding UTF8
$allColumns = $csv[0].PSObject.Properties.Name
$totalColumns = $allColumns.Count

Write-Host "`nTotal columns in CSV: $totalColumns" -ForegroundColor Cyan

# Verified columns with EXACT names from CSV
$verifiedColumns = @(
    # Basic
    "Year",
    
    # Population & Demographics (25 columns)
    "Population",
    "Vietnam Global Rank",
    "ASEAN Population Rank",
    "Vietnam's Share of Asian Pop (%)",
    "Country's Share of World Pop",
    "Median Age",
    "Regional Median Age",
    "Global Median Age",
    "Dependency Ratio (%)",
    "Sex Ratio (M/F)",
    "Pop Aged 0?14 (%)",
    "Pop Aged 15?64 (%)",
    "Pop Aged 65+ (%)",
    "Yearly % Change",
    "Migrants (net)",
    "Density (P/Km?)",
    "Sex Ratio",
    "Deaths",
    "Deaths Male",
    "Deaths Female",
    "Births",
    "World Population",
    "World Urbanization Rate (%)",
    "Population Doubling Time (Years)",
    "Dependency Index",
    "Population Growth (Absolute)",
    "Population Share Change",
    "Yearly Change",
    "Urban Pop %",
    "Vietnam?s Share of Asian Pop (%)",
    
    # Economic (8 columns)
    "GDP per Capita (USD)",
    "GDP Growth Rate (%)",
    "FDI Net Inflows (million USD)",
    "GDP PPP per Capita (Int$)",
    "Poverty Rate (%)",
    "GNI per Capita (USD)",
    "Inflation Rate (%)",
    "Imports (% GDP)",
    "Exports (% GDP)",
    "GDP (billion USD)",
    
    # Health (8 columns)
    "HDI",
    "Life Expectancy",
    "Health Expenditure (% GDP)",
    "Life Expectancy Male",
    "Life Expectancy Female",
    "Infant Mortality",
    "Under-5 Mortality",
    "Human Capital Index (0-1)",
    "HDI_UNDP",
    "Life_Expectancy_UNDP",
    
    # Employment (4 columns)
    "Unemployment Rate (%)",
    "Employment Agriculture (%)",
    "Employment Industry (%)",
    "Employment Services (%)",
    
    # Education (7 columns)
    "Literacy Rate (%)",
    "Mean Years of Schooling",
    "Expected Years of Schooling",
    "Education Index",
    "Education_Index_UNDP",
    "Primary Completion Rate (%)",
    
    # Environmental (3 columns)
    "Agricultural Land (% Land)",
    "Forest Area (% Land)",
    "Renewable Energy Share (%)",
    
    # Fertility & Mortality (5 columns)
    "Fertility Rate",
    "Birth Rate (?)",
    "Death Rate (?)",
    "Infant Mortality Rate (?)",
    "Regional Avg Fertility Rate",
    
    # Urban/Rural (2 columns)
    "Rural Population",
    "Urban Population",
    
    # Other indices (2 columns)
    "Income_Index_UNDP",
    "Net Migration Rate (?)",
    "Urbanization Ratio",
    "Urban Growth Rate (%)",
    "Migration Rate (?)"
)

# Count how many verified columns exist
$foundCount = 0
$foundColumns = @()
$notFoundColumns = @()

foreach ($col in $verifiedColumns) {
    if ($allColumns -contains $col) {
        $foundCount++
        $foundColumns += $col
    } else {
        $notFoundColumns += $col
    }
}

# Remaining unverified columns
$remainingColumns = $allColumns | Where-Object { $foundColumns -notcontains $_ }

Write-Host "`n=== VERIFICATION STATUS ===" -ForegroundColor Yellow
Write-Host "Verified columns: $foundCount" -ForegroundColor Green
Write-Host "Remaining columns: $($remainingColumns.Count)" -ForegroundColor Red
Write-Host "Completion rate: $([math]::Round($foundCount / $totalColumns * 100, 1))%" -ForegroundColor Cyan
Write-Host "Progress: " -NoNewline
$progress = [math]::Floor(($foundCount / $totalColumns) * 50)
Write-Host ("[" + ("█" * $progress) + ("░" * (50 - $progress)) + "]") -ForegroundColor Green

Write-Host "`n=== VERIFIED COLUMNS ($foundCount) ===" -ForegroundColor Green
$categoryGroups = @{
    "Population & Demographics" = @($foundColumns | Where-Object { 
        $_ -like "*Population*" -or $_ -like "*Pop*" -or $_ -like "*Age*" -or 
        $_ -like "*Density*" -or $_ -like "*Migrants*" -or $_ -like "*Births*" -or 
        $_ -like "*Deaths*" -or $_ -like "*Share*" -or $_ -like "*Ratio*" -or
        $_ -like "*World*" -or $_ -like "*Vietnam*" -or $_ -like "*ASEAN*" -or
        $_ -like "*Change" -or $_ -like "*Doubling*" -or $_ -like "*Dependency*" -or
        $_ -like "*Sex*" -or $_ -like "*Growth (Absolute)*"
    })
    "Economic" = @($foundColumns | Where-Object { 
        $_ -like "*GDP*" -or $_ -like "*FDI*" -or $_ -like "*Poverty*" -or 
        $_ -like "*GNI*" -or $_ -like "*Inflation*" -or $_ -like "*Imports*" -or $_ -like "*Exports*"
    })
    "Health" = @($foundColumns | Where-Object { 
        $_ -like "*HDI*" -or $_ -like "*Life Expectancy*" -or $_ -like "*Health*" -or 
        $_ -like "*Infant*" -or $_ -like "*Mortality*" -or $_ -like "*Human Capital*"
    })
    "Employment" = @($foundColumns | Where-Object { 
        $_ -like "*Employment*" -or $_ -like "*Unemployment*"
    })
    "Education" = @($foundColumns | Where-Object { 
        $_ -like "*Education*" -or $_ -like "*Literacy*" -or $_ -like "*Schooling*" -or $_ -like "*Primary*"
    })
    "Environmental" = @($foundColumns | Where-Object { 
        $_ -like "*Agricultural Land*" -or $_ -like "*Forest*" -or $_ -like "*Renewable*"
    })
    "Fertility & Migration" = @($foundColumns | Where-Object { 
        $_ -like "*Fertility*" -or $_ -like "*Birth Rate*" -or $_ -like "*Death Rate*" -or $_ -like "*Migration*"
    })
    "Urban/Rural" = @($foundColumns | Where-Object { 
        $_ -like "*Urban Population" -or $_ -like "*Rural*" -or $_ -like "*Urbanization*"
    })
}

foreach ($category in $categoryGroups.Keys | Sort-Object) {
    $cols = $categoryGroups[$category] | Select-Object -Unique
    if ($cols.Count -gt 0) {
        Write-Host "`n$category ($($cols.Count)):" -ForegroundColor Cyan
        foreach ($col in $cols | Sort-Object) {
            Write-Host "  ✓ $col" -ForegroundColor Gray
        }
    }
}

Write-Host "`n=== REMAINING UNVERIFIED COLUMNS ($($remainingColumns.Count)) ===" -ForegroundColor Yellow
foreach ($col in $remainingColumns | Sort-Object) {
    Write-Host "  ✗ $col" -ForegroundColor DarkGray
}

Write-Host "`n=== SAMPLE DATA (2022-2024) ===" -ForegroundColor Yellow
$sampleRows = $csv | Where-Object { [int]$_.Year -ge 2022 -and [int]$_.Year -le 2024 }
foreach ($row in $sampleRows) {
    Write-Host "`nYear $($row.Year):" -ForegroundColor Cyan
    Write-Host "  Population: $([math]::Round([double]$row.Population/1000000, 2))M" -ForegroundColor White
    Write-Host "  Global Rank: #$($row.'Vietnam Global Rank')" -ForegroundColor White
    Write-Host "  ASEAN Rank: #$($row.'ASEAN Population Rank')" -ForegroundColor White
    Write-Host "  GDP/capita: `$$($row.'GDP per Capita (USD)')" -ForegroundColor White
    Write-Host "  HDI: $($row.HDI)" -ForegroundColor White
    Write-Host "  Life Expectancy: $($row.'Life Expectancy') years" -ForegroundColor White
    Write-Host "  Median Age: $($row.'Median Age') years" -ForegroundColor White
    Write-Host "  Fertility: $($row.'Fertility Rate') (Regional: $($row.'Regional Avg Fertility Rate'))" -ForegroundColor White
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  VERIFICATION COMPLETE: $([math]::Round($foundCount / $totalColumns * 100, 1))%" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
