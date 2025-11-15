# Count exact verified columns
Write-Host "=== Counting Verified Columns ===" -ForegroundColor Cyan

$verifiedColumns = @(
    # Basic (1)
    "Year",
    
    # Economic Indicators (12)
    "GDP (current US$)", "GDP per Capita", "GDP Growth Rate (%)",
    "Inflation Rate (%)", "Trade Balance", "Unemployment Rate (%)",
    "FDI Net Inflows", "Poverty Rate", "Gini Index",
    "GNI per Capita", "Income Index", "Income_Index_UNDP",
    
    # Population & Demographics (21)
    "Population", "Population Growth Rate (%)", "Sex Ratio", "Urban Population (%)",
    "Pop Aged 0?14 (%)", "Pop Aged 15?64 (%)", "Pop Aged 65+ (%)",
    "Dependency Index", "Median Age", "Regional Median Age", "Global Median Age",
    "World Population", "World Urbanization Rate (%)",
    "Vietnam Share of World Pop (%)", "Vietnam Share of Asia Pop (%)",
    "Population Share Change",
    "Births", "Deaths", "Deaths Male", "Deaths Female",
    "Yearly Change",
    
    # Fertility & Mortality (5)
    "Birth Rate", "Death Rate", "Fertility Rate", "Regional Avg Fertility Rate",
    "Infant Mortality Rate",
    
    # Migration & Rankings (5)
    "Net Migration Rate", "Population Doubling Time",
    "Vietnam Global Rank", "ASEAN Population Rank", "Yearly % Change",
    
    # Health (6)
    "Life Expectancy", "Life_Expectancy_UNDP", "Health Expenditure (% of GDP)",
    "Physicians (per 1000)", "Hospital Beds (per 1000)",
    "Human Capital Index",
    
    # Education (7)
    "Mean Years of Schooling", "Expected Years of Schooling",
    "Education Index", "Education_Index_UNDP",
    "Primary Completion Rate (%)", "Education Expenditure (% of GDP)",
    "Literacy Rate (%)",
    
    # Employment (3)
    "Labor Force Participation (%)", "Employment in Services (%)", "Employment in Agriculture (%)",
    
    # Environmental (3)
    "Renewable Energy (%)", "Forest Area (%)", "Agricultural Land (%)",
    
    # Development (2)
    "HDI", "HDI_UNDP"
)

Write-Host "`nTotal verified: $($verifiedColumns.Count) columns" -ForegroundColor Green

# Verify columns exist in CSV
$csv = Import-Csv "src\data\vietnam_advance.csv" -Encoding UTF8
$actualColumns = $csv[0].PSObject.Properties.Name

Write-Host "`nChecking which verified columns exist in CSV..." -ForegroundColor Yellow
$found = 0
$notFound = @()

foreach ($col in $verifiedColumns) {
    if ($actualColumns -contains $col) {
        $found++
    } else {
        $notFound += $col
    }
}

Write-Host "  Found in CSV: $found columns" -ForegroundColor Green
if ($notFound.Count -gt 0) {
    Write-Host "  Not found: $($notFound.Count) columns" -ForegroundColor Red
    foreach ($col in $notFound) {
        Write-Host "    - $col" -ForegroundColor DarkGray
    }
}

Write-Host "`nTotal columns in CSV: $($actualColumns.Count)" -ForegroundColor Cyan
Write-Host "Verified columns: $found" -ForegroundColor Green
Write-Host "Remaining: $($actualColumns.Count - $found)" -ForegroundColor Yellow
Write-Host "Completion rate: $([math]::Round($found / $actualColumns.Count * 100, 1))%" -ForegroundColor Cyan
