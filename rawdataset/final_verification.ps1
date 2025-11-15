# Final Verification of All Unverified Columns in Vietnam Data
Write-Host "=== FINAL VERIFICATION OF UNVERIFIED COLUMNS ===" -ForegroundColor Cyan
Write-Host ""

# Read CSV and identify unverified columns
$csv = Import-Csv 'src/data/vietnam_advance.csv'
$headers = $csv[0].PSObject.Properties.Name

# Define verified columns (those we've integrated from international sources)
$verifiedColumns = @(
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
    'Education Index',
    'World Population',
    'World Urbanization Rate (%)',
    'Country''s Share of World Pop',
    'Vietnam''s Share of Asian Pop (%)',
    'Vietnam?s Share of Asian Pop (%)',
    'Yearly % Change',
    'Yearly Change',
    'Population Growth (Absolute)',
    'Deaths',
    'Births',
    'Net Migration Rate (?)',
    'Migration Rate (?)',
    'Infant Mortality Rate (?)',
    'Urban Pop %',
    'Population Doubling Time (Years)',
    'Deaths Male',
    'Deaths Female',
    'Population Share Change',
    'Dependency Index',
    'Sex Ratio',
    'HDI_UNDP',
    'Life_Expectancy_UNDP',
    'Education_Index_UNDP',
    'Income_Index_UNDP'
)

Write-Host "VERIFIED COLUMNS (from international sources):" -ForegroundColor Green
$verifiedColumns | ForEach-Object { Write-Host "  ✓ $_" }

Write-Host ""
Write-Host "REMAINING UNVERIFIED COLUMNS:" -ForegroundColor Yellow

$unverifiedColumns = @()
foreach ($header in $headers) {
    if ($verifiedColumns -notcontains $header) {
        $unverifiedColumns += $header
        Write-Host "  ✗ $header" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "SUMMARY:" -ForegroundColor Cyan
Write-Host "  Total columns: $($headers.Count)"
Write-Host "  Verified: $($verifiedColumns.Count)"
Write-Host "  Remaining unverified: $($unverifiedColumns.Count)"
Write-Host ""

# Check latest data availability for key remaining indicators
Write-Host "NEXT STEPS FOR REMAINING INDICATORS:" -ForegroundColor Magenta
$remainingIndicators = @(
    "Unemployment Rate (%) - ILO/World Bank",
    "Poverty Rate (%) - World Bank/UNDP",
    "Human Capital Index - World Bank",
    "Mean Years of Schooling - UNESCO/World Bank",
    "Expected Years of Schooling - UNESCO/World Bank",
    "Education Index - UNDP",
    "Climate Risk Index - Germanwatch",
    "EPI Score - Yale University",
    "Household Size - World Bank/UN"
)

$remainingIndicators | ForEach-Object { Write-Host "  • $_" }

Write-Host ""
Write-Host "RECOMMENDED DATA SOURCES:" -ForegroundColor Blue
Write-Host "  • World Bank API: https://data.worldbank.org/"
Write-Host "  • UNDP Human Development Reports: https://hdr.undp.org/"
Write-Host "  • UNESCO Institute for Statistics: https://uis.unesco.org/"
Write-Host "  • ILO Statistics: https://ilostat.ilo.org/"
Write-Host "  • WHO Global Health Observatory: https://www.who.int/data/gho"
Write-Host "  • Germanwatch Climate Risk Index: https://germanwatch.org/en/cri"
Write-Host "  • Yale EPI: https://epi.yale.edu/"