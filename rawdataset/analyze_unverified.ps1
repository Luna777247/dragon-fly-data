# Analyze unverified columns in Vietnam dataset
$csv = Import-Csv 'src/data/vietnam_advance.csv'

# Get 2023 data
$row2023 = $csv | Where-Object { $_.Year -eq '2023' }

Write-Host "=== CAC COT CON CHUA XAC MINH (2023) ===" -ForegroundColor Yellow
Write-Host ""

# Columns that are likely unverified (have data but not from official sources)
$unverifiedColumns = @(
    "GDP per Capita (USD)",
    "Unemployment Rate (%)",
    "GDP Growth Rate (%)",
    "Employment Agriculture (%)",
    "Employment Industry (%)",
    "Employment Services (%)",
    "Poverty Rate (%)",
    "Health Expenditure (% GDP)",
    "CO? Emissions per Capita (t)",
    "Human Capital Index (0-1)",
    "Renewable Energy Share (%)",
    "Mean Years of Schooling",
    "Expected Years of Schooling",
    "Education Index",
    "Climate Risk Index",
    "EPI Score",
    "Imports (% GDP)",
    "Exports (% GDP)",
    "GDP (billion USD)",
    "Inflation Rate (%)",
    "Household Size (People)"
)

foreach ($col in $unverifiedColumns) {
    $value = $row2023.$col
    if ($value -and $value -ne "0.0" -and $value -ne "") {
        Write-Host "$col : $value" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== CAC COT DA XAC MINH ===" -ForegroundColor Green
Write-Host "✓ FDI Net Inflows (million USD): $($row2023.'FDI Net Inflows (million USD)')"
Write-Host "✓ GDP PPP per Capita (Int`$): $($row2023.'GDP PPP per Capita (Int$)')"
Write-Host "✓ GNI per Capita (USD): $($row2023.'GNI per Capita (USD)')"
Write-Host "✓ Energy Consumption per Capita (kWh): $($row2023.'Energy Consumption per Capita (kWh)')"
Write-Host "✓ Agricultural Land (% Land): $($row2023.'Agricultural Land (% Land)')"
Write-Host "✓ Forest Area (% Land): $($row2023.'Forest Area (% Land)')"
Write-Host "✓ Migrants (net): $($row2023.'Migrants (net)')"
Write-Host "✓ HDI: $($row2023.HDI)"
Write-Host "✓ Life Expectancy: $($row2023.'Life Expectancy')"
Write-Host "✓ Infant Mortality: $($row2023.'Infant Mortality')"
Write-Host "✓ Under-5 Mortality: $($row2023.'Under-5 Mortality')"
Write-Host "✓ HDI_UNDP: $($row2023.HDI_UNDP)"
Write-Host "✓ Life_Expectancy_UNDP: $($row2023.Life_Expectancy_UNDP)"
Write-Host "✓ Education_Index_UNDP: $($row2023.Education_Index_UNDP)"
Write-Host "✓ Income_Index_UNDP: $($row2023.Income_Index_UNDP)"