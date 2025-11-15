# Recreate vietnam_population.csv from fixed source with correct column mapping
Write-Host "🔄 Đang tạo lại vietnam_population.csv từ file gốc đã sửa..." -ForegroundColor Cyan

$csv = Import-Csv "src\data\vietnam_advance.csv" -Encoding UTF8

# Get actual column names from source
$headers = $csv[0].PSObject.Properties.Name

Write-Host "`n📋 Mapping cột chính xác..." -ForegroundColor Yellow

$population = $csv | Select-Object `
    Year,
    Population,
    @{N='Vietnam Global Rank';E={$_.'Vietnam Global Rank'}},
    @{N='ASEAN Population Rank';E={$_.'ASEAN Population Rank'}},
    @{N="Vietnam's Share of Asian Pop (%)";E={$_."Vietnam?s Share of Asian Pop (%)"}},
    @{N="Country's Share of World Pop";E={$_."Country's Share of World Pop"}},
    @{N='Median Age';E={$_.'Median Age'}},
    @{N='Regional Median Age';E={$_.'Regional Median Age'}},
    @{N='Global Median Age';E={$_.'Global Median Age'}},
    @{N='Dependency Ratio (%)';E={$_.'Dependency Ratio (%)'}},
    @{N='Sex Ratio (M/F)';E={$_.'Sex Ratio (M/F)'}},
    @{N='Pop Aged 0–14 (%)';E={$_.'Pop Aged 0?14 (%)'}},
    @{N='Pop Aged 15–64 (%)';E={$_.'Pop Aged 15?64 (%)'}},
    @{N='Pop Aged 65+ (%)';E={$_.'Pop Aged 65+ (%)'}},
    @{N='GDP per Capita (USD)';E={$_.'GDP per Capita (USD)'}},
    @{N='HDI';E={$_.HDI}},
    @{N='Unemployment Rate (%)';E={$_.'Unemployment Rate (%)'}},
    @{N='GDP Growth Rate (%)';E={$_.'GDP Growth Rate (%)'}},
    @{N='FDI Net Inflows (million USD)';E={$_.'FDI Net Inflows (million USD)'}},
    @{N='GDP PPP per Capita (Int$)';E={$_.'GDP PPP per Capita (Int$)'}},
    @{N='Fertility Rate';E={$_.'Fertility Rate'}},
    @{N='Life Expectancy';E={$_.'Life Expectancy'}},
    @{N='Birth Rate (‰)';E={$_.'Birth Rate (?)'}},
    @{N='Death Rate (‰)';E={$_.'Death Rate (?)'}},
    @{N='Employment Agriculture (%)';E={$_.'Employment Agriculture (%)'}},
    @{N='Employment Industry (%)';E={$_.'Employment Industry (%)'}},
    @{N='Employment Services (%)';E={$_.'Employment Services (%)'}},
    @{N='Poverty Rate (%)';E={$_.'Poverty Rate (%)'}},
    @{N='Health Expenditure (% GDP)';E={$_.'Health Expenditure (% GDP)'}},
    @{N='Rural Population';E={$_.'Rural Population'}},
    @{N='Urban Population';E={
        # Fix Urban Population for 2020-2022 (calculate from total * %)
        $year = [int]$_.Year
        if ($year -in @(2020, 2021, 2022)) {
            try {
                $pop = [double]$_.Population
                $urbanPct = [double]$_.'Urban Pop (%)'
                if ($pop -and $urbanPct) {
                    [long]($pop * $urbanPct / 100)
                } else {
                    $_.'Urban Population'
                }
            } catch {
                $_.'Urban Population'
            }
        } else {
            $_.'Urban Population'
        }
    }},
    @{N='Energy Consumption per Capita (kWh)';E={$_.'Energy Consumption per Capita (kWh)'}},
    @{N='CO₂ Emissions per Capita (t)';E={$_.'CO? Emissions per Capita (t)'}},
    @{N='Agricultural Land (% Land)';E={$_.'Agricultural Land (% Land)'}},
    @{N='Forest Area (% Land)';E={$_.'Forest Area (% Land)'}},
    @{N='Human Capital Index (0-1)';E={$_.'Human Capital Index (0-1)'}},
    @{N='Renewable Energy Share (%)';E={$_.'Renewable Energy Share (%)'}}

# Save to CSV
$population | Export-Csv "vietnam_population.csv" -Encoding UTF8 -NoTypeInformation

Write-Host "`n✅ Đã tạo lại file vietnam_population.csv" -ForegroundColor Green
Write-Host "📊 Số hàng: $($population.Count)" -ForegroundColor White
Write-Host "📋 Số cột: $(($population[0].PSObject.Properties | Measure-Object).Count)" -ForegroundColor White

# Quick verification
$sample2024 = $population | Where-Object {$_.Year -eq '2024'}
Write-Host "`n🔍 Mẫu dữ liệu năm 2024:" -ForegroundColor Cyan
Write-Host "   • Population: $($sample2024.Population)" -ForegroundColor Gray
Write-Host "   • Vietnam Global Rank: $($sample2024.'Vietnam Global Rank')" -ForegroundColor Gray
Write-Host "   • Urban Population: $($sample2024.'Urban Population')" -ForegroundColor Gray
Write-Host "   • CO₂ Emissions: $($sample2024.'CO₂ Emissions per Capita (t)')" -ForegroundColor Gray
Write-Host "   • HDI: $($sample2024.HDI)" -ForegroundColor Gray
