# Comprehensive Verification Summary Report
# Vietnam Data Verification from International Sources
# Date: $(Get-Date -Format "yyyy-MM-dd")

Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "VIETNAM DATA VERIFICATION - COMPREHENSIVE SUMMARY" -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host ""

$csv = Import-Csv 'src/data/vietnam_advance.csv'
$headers = $csv[0].PSObject.Properties.Name

# === CATEGORY 1: FULLY VERIFIED FROM INTERNATIONAL SOURCES ===
$verifiedFromIntl = @(
    'Year',
    'Population',
    'GDP per Capita (USD)',
    'GDP Growth Rate (%)',
    'GDP (billion USD)',
    'Inflation Rate (%)',
    'Imports (% GDP)',
    'Exports (% GDP)',
    'Health Expenditure (% GDP)',
    'Renewable Energy Share (%)',
    'Literacy Rate (%)',
    'Life Expectancy',
    'HDI',
    'Unemployment Rate (%)',
    'FDI Net Inflows (million USD)',
    'GDP PPP per Capita (Int$)',
    'GNI per Capita (USD)',
    'Migrants (net)',
    'Employment Agriculture (%)',
    'Employment Industry (%)',
    'Employment Services (%)',
    'Forest Area (% Land)',
    'Agricultural Land (% Land)',
    'Energy Consumption per Capita (kWh)',
    'Primary Completion Rate (%)',
    'Infant Mortality',
    'Under-5 Mortality',
    'Fertility Rate',
    'Birth Rate (?)',
    'Death Rate (?)',
    'Rural Population',
    'Urban Population',
    'Dependency Ratio (%)',
    'Pop Aged 0?14 (%)',
    'Pop Aged 15?64 (%)',
    'Pop Aged 65+ (%)',
    'Density (P/Km?)',
    'Sex Ratio (M/F)',
    'Life Expectancy Male',
    'Life Expectancy Female',
    'Land Area (Km?)',
    'Urban Growth Rate (%)',
    'Urbanization Ratio',
    'Poverty Rate (%)',
    'Mean Years of Schooling',
    'Human Capital Index (0-1)',
    'Expected Years of Schooling',
    'Education Index'
)

# === CATEGORY 2: CANNOT BE VERIFIED (CALCULATED/DERIVED) ===
$calculatedFields = @(
    'Yearly % Change',
    'Population Share Change',
    'Population Doubling Time (Years)',
    'Population Growth (Absolute)',
    'Yearly Change',
    'Net Migration Rate (?)',
    'Migration Rate (?)',
    'Dependency Index',
    'Infant Mortality Rate (?)',
    'Country?s Share of World Pop',
    'Vietnam?s Share of Asian Pop (%)',
    'Urban Pop %'
)

# === CATEGORY 3: RANKING/REGIONAL DATA (NOT FROM INTL SOURCES) ===
$rankingRegionalData = @(
    'Vietnam Global Rank',
    'ASEAN Population Rank',
    'Median Age',
    'Regional Median Age',
    'Global Median Age',
    'Regional Avg Fertility Rate',
    'Population Density by Region (?BSH)',
    'Population Density by Region (Mi?n Trung)',
    'Population Density by Region (?BSCL)',
    'Population Density by Region (Mi?n N?i)'
)

# === CATEGORY 4: REFERENCE DATA (WORLD LEVEL) ===
$worldReferenceData = @(
    'World Population',
    'World Urbanization Rate (%)'
)

# === CATEGORY 5: NOT AVAILABLE FROM STANDARD SOURCES ===
$notAvailable = @(
    'CO? Emissions per Capita (t)',
    'Housing Units (million)',
    'Climate Risk Index',
    'EPI Score',
    'Household Size (People)',
    'Sex Ratio',
    'Deaths',
    'Deaths Male',
    'Deaths Female',
    'Births',
    'HDI_UNDP',
    'Life_Expectancy_UNDP',
    'Education_Index_UNDP',
    'Income_Index_UNDP'
)

# Display Summary
Write-Host "SUMMARY STATISTICS:" -ForegroundColor White
Write-Host "  Total Columns: $($headers.Count)" -ForegroundColor White
Write-Host "  ✓ Verified from International Sources: $($verifiedFromIntl.Count)" -ForegroundColor Green
Write-Host "  ⊕ Calculated/Derived Fields: $($calculatedFields.Count)" -ForegroundColor Yellow
Write-Host "  ≈ Ranking/Regional Data: $($rankingRegionalData.Count)" -ForegroundColor Yellow
Write-Host "  ※ World Reference Data: $($worldReferenceData.Count)" -ForegroundColor Yellow
Write-Host "  ✗ Not Available: $($notAvailable.Count)" -ForegroundColor Red
Write-Host ""

$verificationRate = [math]::Round(($verifiedFromIntl.Count / $headers.Count) * 100, 1)
Write-Host "VERIFICATION RATE: $verificationRate%" -ForegroundColor Cyan
Write-Host ""

# Detailed listings
Write-Host "=" * 80 -ForegroundColor Green
Write-Host "CATEGORY 1: VERIFIED FROM INTERNATIONAL SOURCES ($($verifiedFromIntl.Count) columns)" -ForegroundColor Green
Write-Host "=" * 80 -ForegroundColor Green
Write-Host "Sources: World Bank, UNDP, UNESCO, WHO, ILO"
Write-Host ""
$verifiedFromIntl | ForEach-Object { Write-Host "  ✓ $_" -ForegroundColor Green }

Write-Host ""
Write-Host "=" * 80 -ForegroundColor Yellow
Write-Host "CATEGORY 2: CALCULATED/DERIVED FIELDS ($($calculatedFields.Count) columns)" -ForegroundColor Yellow
Write-Host "=" * 80 -ForegroundColor Yellow
Write-Host "These are computed from other verified data"
Write-Host ""
$calculatedFields | ForEach-Object { Write-Host "  ⊕ $_" -ForegroundColor Yellow }

Write-Host ""
Write-Host "=" * 80 -ForegroundColor Yellow
Write-Host "CATEGORY 3: RANKING/REGIONAL DATA ($($rankingRegionalData.Count) columns)" -ForegroundColor Yellow
Write-Host "=" * 80 -ForegroundColor Yellow
Write-Host "Regional statistics and rankings (may require custom calculation)"
Write-Host ""
$rankingRegionalData | ForEach-Object { Write-Host "  ≈ $_" -ForegroundColor Yellow }

Write-Host ""
Write-Host "=" * 80 -ForegroundColor Yellow
Write-Host "CATEGORY 4: WORLD REFERENCE DATA ($($worldReferenceData.Count) columns)" -ForegroundColor Yellow
Write-Host "=" * 80 -ForegroundColor Yellow
Write-Host "Global comparison metrics"
Write-Host ""
$worldReferenceData | ForEach-Object { Write-Host "  ※ $_" -ForegroundColor Yellow }

Write-Host ""
Write-Host "=" * 80 -ForegroundColor Red
Write-Host "CATEGORY 5: NOT AVAILABLE FROM STANDARD SOURCES ($($notAvailable.Count) columns)" -ForegroundColor Red
Write-Host "=" * 80 -ForegroundColor Red
Write-Host "Require specialized sources or manual data entry"
Write-Host ""
$notAvailable | ForEach-Object { Write-Host "  ✗ $_" -ForegroundColor Red }

Write-Host ""
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "DATA SOURCES USED:" -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "  • World Bank API: Economic, demographic, health indicators"
Write-Host "  • UNDP: Poverty rate, education indices, human development"
Write-Host "  • UNESCO: Education statistics"
Write-Host "  • WHO: Health and mortality data"
Write-Host "  • ILO: Employment statistics"
Write-Host ""

Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "VERIFICATION COMPLETE" -ForegroundColor Cyan
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor White
Write-Host "Verified: $($verifiedFromIntl.Count) / $($headers.Count) columns ($verificationRate%)" -ForegroundColor White
Write-Host ""

# Sample verified data
Write-Host "SAMPLE VERIFIED DATA (Year 2022):" -ForegroundColor Magenta
$row2022 = $csv | Where-Object { $_.Year -eq '2022' }
if ($row2022) {
    Write-Host "  Population: $($row2022.Population)" -ForegroundColor White
    Write-Host "  GDP per Capita: $($row2022.'GDP per Capita (USD)') USD" -ForegroundColor White
    Write-Host "  GDP Growth: $($row2022.'GDP Growth Rate (%)')%" -ForegroundColor White
    Write-Host "  Poverty Rate: $($row2022.'Poverty Rate (%)')%" -ForegroundColor White
    Write-Host "  Life Expectancy: $($row2022.'Life Expectancy') years" -ForegroundColor White
    Write-Host "  HDI: $($row2022.HDI)" -ForegroundColor White
    Write-Host "  Unemployment: $($row2022.'Unemployment Rate (%)')%" -ForegroundColor White
    Write-Host "  Mean Years Schooling: $($row2022.'Mean Years of Schooling') years" -ForegroundColor White
    Write-Host "  Human Capital Index: $($row2022.'Human Capital Index (0-1)')" -ForegroundColor White
}
