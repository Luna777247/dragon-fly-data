# Employment & Labor Consolidated Dataset

## Overview
This dataset consolidates Vietnam's employment and labor market data from 1960-2024 (65 years), combining World Bank ILO modeled estimates with absolute employment figures.

**Generated**: November 2025  
**Source Script**: `consolidate_employment_data.ps1`  
**Output File**: `employment_consolidated.csv`

---

## Data Summary

- **Time Period**: 1960-2024 (65 years)
- **Data Columns**: 9 indicators
- **Total Data Points**: 248
- **Average Fill Rate**: 42.4%

---

## Data Dictionary

### Percentage-Based Indicators (ILO Modeled Estimates)

| Column Name | Description | Unit | Value Range | Fill Rate | Years Available |
|-------------|-------------|------|-------------|-----------|-----------------|
| `Year` | Calendar year | Year | 1960-2024 | 100% | 65 |
| `AgricultureEmploymentPct` | Employment in agriculture sector | % of total employment | 29.0-73.9% | 50.8% | 33 (1991-2023) |
| `IndustryEmploymentPct` | Employment in industry sector | % of total employment | 9.1-27.4% | 50.8% | 33 (1991-2023) |
| `ServicesEmploymentPct` | Employment in services sector | % of total employment | 17.0-61.0% | 50.8% | 33 (1991-2023) |
| `UnemploymentRate` | Unemployment rate | % of labor force | 1.0-2.9% | 52.3% | 34 (1991-2024) |

### Absolute Employment Figures (Millions of People)

| Column Name | Description | Unit | Value Range | Fill Rate | Years Available |
|-------------|-------------|------|-------------|-----------|-----------------|
| `AgricultureMillions` | Agricultural sector employment | Millions | 12.4-29.8 | 35.4% | 23 (2000-2022) |
| `IndustryMillions` | Industry sector employment | Millions | 22.1-30.6 | 35.4% | 23 (2000-2022) |
| `ServicesMillions` | Services sector employment | Millions | 22.1-31.5 | 35.4% | 23 (2000-2022) |
| `TotalEmploymentMillions` | Total employed population | Millions | 57.0-91.2 | 35.4% | 23 (2000-2022) |
| `UnemployedMillions` | Calculated unemployed/diff | Millions | 8.8-43.0 | 35.4% | 23 (2000-2022) |

---

## Source Files Mapping

| Indicator | Source File | Data Type | Notes |
|-----------|-------------|-----------|-------|
| AgricultureEmploymentPct | `wb_ilo_agriculture_employment.json` | World Bank API | ILO modeled estimate |
| IndustryEmploymentPct | `wb_ilo_industry_employment.json` | World Bank API | ILO modeled estimate |
| ServicesEmploymentPct | `wb_ilo_services_employment.json` | World Bank API | ILO modeled estimate |
| UnemploymentRate | `wb_ilo_unemployment.json` | World Bank API | ILO modeled estimate |
| All "Millions" columns | `employment_issues.csv` | Custom CSV | Absolute employment figures |

---

## Key Insights

### Structural Transformation (1991-2023)
- **Agriculture**: 73.9% (1991) → 32.9% (2023) = **-41 percentage points**
  - Reflects Vietnam's rapid industrialization post-Đổi Mới
  - Declined from 3 out of 4 workers to 1 out of 3
  
- **Services**: 17.0% (1991) → 45.0% (2023) = **+28 percentage points**
  - Fastest-growing sector, driven by urbanization and tertiary economy
  
- **Industry**: 9.1% (1991) → 22.1% (2023) = **+13 percentage points**
  - Steady growth supporting manufacturing exports

### Unemployment Trends
- **Lowest**: 1.0% (2011-2012) - during high economic growth period
- **Highest**: 2.9% (1997) - Asian Financial Crisis impact
- **Recent**: 1.4% (2024) - remarkably low, though may not capture underemployment

### Absolute Employment Growth (2000-2022)
- **Total Employment**: 57.0M (2000) → 91.2M (2022) = **+60% growth**
- **Services Sector**: 22.3M → 31.5M (+41%)
- **Industry Sector**: 22.3M → 30.6M (+37%)
- **Agriculture Sector**: 12.4M → 29.8M (+140%)
  - Despite declining percentage, absolute numbers grew due to population increase

---

## Data Quality Notes

### High Coverage (>50%)
- ✅ **Unemployment Rate**: 52.3% coverage (1991-2024)
- ✅ **Employment by Sector %**: 50.8% coverage (1991-2023)

### Limited Coverage (35-40%)
- ⚠️ **Absolute Employment Figures**: 35.4% coverage (2000-2022)
  - Only available from `employment_issues.csv`
  - Missing pre-2000 and post-2022 data
  - Note: "UnemployedMillions" may represent difference from labor force, not true unemployment

### Missing Data Patterns
- **Pre-1991**: No ILO estimates (before Vietnam's ASEAN integration)
- **Pre-2000**: No absolute employment figures
- **Post-2022**: No absolute employment figures (only percentages available)

---

## Usage Examples

### PowerShell
```powershell
# Load and analyze employment structure transformation
$data = Import-Csv "employment_consolidated.csv"

# Compare 1991 vs 2023 employment structure
$year1991 = $data | Where-Object { $_.Year -eq 1991 }
$year2023 = $data | Where-Object { $_.Year -eq 2023 }

Write-Host "Agriculture: $($year1991.AgricultureEmploymentPct)% (1991) → $($year2023.AgricultureEmploymentPct)% (2023)"
Write-Host "Services: $($year1991.ServicesEmploymentPct)% (1991) → $($year2023.ServicesEmploymentPct)% (2023)"

# Calculate average unemployment rate 2010-2024
$avgUnemployment = ($data | 
    Where-Object { [int]$_.Year -ge 2010 -and $_.UnemploymentRate -ne "N/A" } | 
    Measure-Object -Property UnemploymentRate -Average).Average
Write-Host "Average Unemployment (2010-2024): $($avgUnemployment.ToString('F2'))%"
```

### Python (pandas)
```python
import pandas as pd
import numpy as np

# Load data
df = pd.read_csv('employment_consolidated.csv')
df.replace('N/A', np.nan, inplace=True)

# Convert to numeric
numeric_cols = df.columns.drop('Year')
df[numeric_cols] = df[numeric_cols].apply(pd.to_numeric, errors='coerce')

# Analyze sectoral employment shift
recent = df[df['Year'] == 2023].iloc[0]
print(f"2023 Employment Structure:")
print(f"  Agriculture: {recent['AgricultureEmploymentPct']:.1f}%")
print(f"  Industry: {recent['IndustryEmploymentPct']:.1f}%")
print(f"  Services: {recent['ServicesEmploymentPct']:.1f}%")

# Plot employment transformation
import matplotlib.pyplot as plt
valid_data = df.dropna(subset=['AgricultureEmploymentPct'])
plt.plot(valid_data['Year'], valid_data['AgricultureEmploymentPct'], label='Agriculture')
plt.plot(valid_data['Year'], valid_data['IndustryEmploymentPct'], label='Industry')
plt.plot(valid_data['Year'], valid_data['ServicesEmploymentPct'], label='Services')
plt.xlabel('Year')
plt.ylabel('Employment Share (%)')
plt.title('Vietnam Employment Structure Transformation (1991-2023)')
plt.legend()
plt.grid(True, alpha=0.3)
plt.show()
```

### TypeScript
```typescript
import Papa from 'papaparse';
import { readFileSync } from 'fs';

interface EmploymentData {
  Year: number;
  AgricultureEmploymentPct: number | null;
  IndustryEmploymentPct: number | null;
  ServicesEmploymentPct: number | null;
  UnemploymentRate: number | null;
  AgricultureMillions: number | null;
  IndustryMillions: number | null;
  ServicesMillions: number | null;
  TotalEmploymentMillions: number | null;
  UnemployedMillions: number | null;
}

// Parse CSV
const csvContent = readFileSync('employment_consolidated.csv', 'utf-8');
const parsed = Papa.parse<EmploymentData>(csvContent, {
  header: true,
  dynamicTyping: true,
  transform: (value: string) => value === 'N/A' ? null : value
});

// Calculate employment structure for each decade
const decades = [1990, 2000, 2010, 2020];
decades.forEach(decade => {
  const yearData = parsed.data.find(d => d.Year === decade);
  if (yearData && yearData.AgricultureEmploymentPct) {
    console.log(`${decade}: Agri=${yearData.AgricultureEmploymentPct.toFixed(1)}%, ` +
                `Ind=${yearData.IndustryEmploymentPct?.toFixed(1)}%, ` +
                `Svc=${yearData.ServicesEmploymentPct?.toFixed(1)}%`);
  }
});

// Find years with highest/lowest unemployment
const validUnemployment = parsed.data
  .filter(d => d.UnemploymentRate !== null)
  .sort((a, b) => a.UnemploymentRate! - b.UnemploymentRate!);

console.log(`Lowest Unemployment: ${validUnemployment[0].UnemploymentRate}% (${validUnemployment[0].Year})`);
console.log(`Highest Unemployment: ${validUnemployment[validUnemployment.length-1].UnemploymentRate}% ` +
            `(${validUnemployment[validUnemployment.length-1].Year})`);
```

---

## Integration with Main Dataset

To merge with `vietnam_advance.csv`:
```powershell
# Load both datasets
$main = Import-Csv "vietnam_advance.csv"
$employment = Import-Csv "employment_consolidated.csv"

# Create lookup hashtable
$empLookup = @{}
$employment | ForEach-Object { $empLookup[[int]$_.Year] = $_ }

# Add employment columns to main dataset
$enhanced = $main | ForEach-Object {
    $year = [int]$_.Year
    $emp = $empLookup[$year]
    
    $_ | Add-Member -NotePropertyName "AgricultureEmploymentPct" -NotePropertyValue $emp.AgricultureEmploymentPct -PassThru |
         Add-Member -NotePropertyName "IndustryEmploymentPct" -NotePropertyValue $emp.IndustryEmploymentPct -PassThru |
         Add-Member -NotePropertyName "ServicesEmploymentPct" -NotePropertyValue $emp.ServicesEmploymentPct -PassThru |
         Add-Member -NotePropertyName "UnemploymentRate" -NotePropertyValue $emp.UnemploymentRate -PassThru
}

$enhanced | Export-Csv "vietnam_with_employment.csv" -NoTypeInformation
```

---

## Limitations & Considerations

1. **ILO Modeled Estimates**: Not directly measured data, but statistical models based on surveys and censuses
2. **Pre-1991 Gap**: No employment structure data before Vietnam's economic reforms
3. **Informal Employment**: Percentages may not capture informal/grey economy workers
4. **UnemployedMillions Column**: May represent difference calculation, not direct unemployment measurement
5. **Data Discontinuity**: Absolute figures (millions) only available 2000-2022, limiting long-term analysis
6. **Low Unemployment**: May reflect underemployment issues not captured in official statistics

---

## Historical Context

### Đổi Mới Era (1986-Present)
- **1991**: First ILO data available - 74% agricultural employment
- **1997**: Asian Financial Crisis spike (2.9% unemployment)
- **2007**: WTO accession - accelerated structural transformation
- **2020**: COVID-19 impact (2.1% unemployment, up from 1.7% in 2019)
- **2023**: Services sector surpassed agriculture (45% vs 33%)

---

## Changelog

**Version 1.0** (November 2025)
- Initial consolidation from 5 source files
- 65 years of data (1960-2024)
- 9 employment indicators
- 42.4% average data coverage

---

## References

- **World Bank**: [ILO Modeled Estimates Database](https://data.worldbank.org/indicator)
  - `SL.AGR.EMPL.ZS`: Employment in agriculture
  - `SL.IND.EMPL.ZS`: Employment in industry
  - `SL.SRV.EMPL.ZS`: Employment in services
  - `SL.UEM.TOTL.ZS`: Unemployment, total
- **ILO**: [ILOSTAT Database](https://ilostat.ilo.org/)
- **Source Files**: See `rawdataset/` folder

---

*For questions or data issues, refer to the consolidation script: `consolidate_employment_data.ps1`*
