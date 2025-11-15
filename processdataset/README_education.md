# Education Data Consolidated - Documentation

## Overview

**File**: `education_consolidated.csv`  
**Time Range**: 1960-2024 (65 years)  
**Indicators**: 8 education metrics  
**Data Points**: 91 valid values  
**Average Fill Rate**: 17.5%

This dataset consolidates education indicators from the World Bank and UNESCO Institute for Statistics (UIS), tracking Vietnam's educational development over 65 years.

---

## Data Dictionary

| Column Name | Description | Unit | Source | Fill Rate |
|------------|-------------|------|--------|-----------|
| **Year** | Year of observation | YYYY | N/A | 100% |
| **LiteracyRateAdult** | Adult literacy rate (15+ years) | Percentage | UNESCO | 10.8% |
| **AdultLiteracyWB** | Adult literacy rate (alternate source) | Percentage | World Bank | 10.8% |
| **PrimaryCompletionRate** | Primary school completion rate | Percentage | UNESCO | 26.2% |
| **MeanYearsSchooling** | Average years of education completed | Years | UNESCO | 0% |
| **ExpectedYearsSchooling** | Expected years of education for children | Years | UNESCO | 0% |
| **SchoolLifeExpectancy** | Expected years in education system | Years | World Bank | 7.7% |
| **TertiaryEnrollmentRatio** | Tertiary education enrollment ratio | Percentage | World Bank | 61.5% |
| **EducationExpenditureGDP** | Government education spending | % of GDP | World Bank | 23.1% |

---

## Source File Mapping

### Valid Data Sources (8 files)

| Source File | Indicator | Data Points | Years |
|-------------|-----------|-------------|-------|
| `wb_unesco_literacy.json` | LiteracyRateAdult | 7 | 1979, 1989, 1999, 2009, 2019, 2022 |
| `wb_SE_ADT_LITR_ZS.json` | AdultLiteracyWB | 7 | (Same as above) |
| `wb_unesco_primary_completion.json` | PrimaryCompletionRate | 17 | 1979-2024 (sporadic) |
| `wb_SE_SCH_LIFE.json` | SchoolLifeExpectancy | 5 | 1976, 1977, 1980 |
| `wb_SE_TER_ENRR.json` | TertiaryEnrollmentRatio | 40 | 1976-2024 (most complete) |
| `wb_SE_XPD_TOTL_GD_ZS.json` | EducationExpenditureGDP | 15 | 1995-2022 |
| `wb_unesco_mean_schooling.json` | MeanYearsSchooling | 0 | Empty file |
| `wb_unesco_expected_schooling.json` | ExpectedYearsSchooling | 0 | Empty file |

### Excluded Sources (5 files)

❌ **Excluded due to data quality issues:**
- `unesco_sdg4.csv` (302 bytes) - HTML page, not actual CSV data
- `unesco_sdg4_bulk.csv` (109KB) - XLSX file misnamed as CSV
- `unesco_sdg4_direct.csv` (109KB) - XLSX file misnamed as CSV
- `primary_completion_rates.json` (0 bytes) - Empty file
- `unesco_sdg4.xlsx` (109KB) - Valid Excel file, but requires Import-Excel cmdlet

---

## Data Quality Analysis

### Coverage by Decade

| Decade | Data Points | Coverage % | Notable Events |
|--------|-------------|------------|----------------|
| 1960s | 0 | 0% | War period, limited data collection |
| 1970s | 9 | 17.3% | Post-reunification (1975), first measurements |
| 1980s | 6 | 11.5% | Economic crisis, education data gaps |
| 1990s | 20 | 30.8% | Đổi Mới reforms, increased reporting |
| 2000s | 24 | 37.5% | WTO accession, improved data systems |
| 2010s | 26 | 40.6% | Strong tertiary expansion |
| 2020s | 6 | 23.1% | COVID-19 impact, incomplete data |

### Indicator Quality Assessment

**🟢 Strong Coverage (>25%)**
- **TertiaryEnrollmentRatio** (61.5%): Most complete indicator, 1976-2024
- **PrimaryCompletionRate** (26.2%): Reliable since 1979

**🟡 Moderate Coverage (10-25%)**
- **EducationExpenditureGDP** (23.1%): Fiscal data since 1995
- **LiteracyRateAdult** (10.8%): Decadal surveys only

**🔴 Limited Coverage (<10%)**
- **SchoolLifeExpectancy** (7.7%): Only 3 measurements in 1970s-1980s
- **AdultLiteracyWB** (10.8%): Duplicate of UNESCO data

**❌ No Data**
- **MeanYearsSchooling** (0%): Source file empty
- **ExpectedYearsSchooling** (0%): Source file empty

---

## Historical Insights

### 1. Literacy Transformation (1979-2022)
- **1979**: 83.8% literacy (post-war baseline)
- **1989**: 83.8% (stagnant during economic crisis)
- **2022**: **96.1%** literacy (near-universal adult literacy)
- **Change**: +12.3 percentage points over 43 years

### 2. Primary Education Achievement
- **1979**: 90.1% completion rate (strong foundation)
- **2022**: **100.8%** completion rate (exceeds 100% due to older students completing)
- Vietnam achieved universal primary education by 2016

### 3. Tertiary Education Explosion (1976-2024)
- **1976**: 1.68% enrollment (elite access only)
- **2021**: **41.96%** enrollment (mass higher education)
- **Growth**: 25x increase in 45 years
- Key milestones:
  - 1986: Đổi Mới reforms open private universities
  - 2000s: Rapid expansion phase
  - 2021: Peak enrollment during COVID-19 (online learning)

### 4. Education Investment Trends
- **1995**: 3.0% of GDP (post-reform increase)
- **Peak**: 4.53% in 2013 (major expansion phase)
- **2022**: 2.89% of GDP (efficiency focus)
- Cyclical pattern: expansion (2000s) → optimization (2010s) → stabilization (2020s)

---

## Usage Examples

### PowerShell
```powershell
# Load and analyze education data
$data = Import-Csv "education_consolidated.csv"

# Filter years with complete literacy data
$literacy = $data | Where-Object { $_.LiteracyRateAdult -ne "N/A" }
Write-Host "Literacy measurements: $($literacy.Count) years"

# Calculate tertiary enrollment growth
$tertiary = $data | Where-Object { $_.TertiaryEnrollmentRatio -ne "N/A" }
$earliest = [double]($tertiary | Select-Object -First 1).TertiaryEnrollmentRatio
$latest = [double]($tertiary | Select-Object -Last 1).TertiaryEnrollmentRatio
$growth = (($latest - $earliest) / $earliest) * 100
Write-Host "Tertiary enrollment growth: $($growth.ToString('F1'))%"

# Find peak education spending year
$spending = $data | Where-Object { $_.EducationExpenditureGDP -ne "N/A" }
$peak = $spending | Sort-Object { [double]$_.EducationExpenditureGDP } -Descending | Select-Object -First 1
Write-Host "Peak spending: $($peak.EducationExpenditureGDP)% in $($peak.Year)"
```

### Python
```python
import pandas as pd

# Load data
df = pd.read_csv('education_consolidated.csv')

# Replace "N/A" with NaN
df = df.replace("N/A", pd.NA)

# Convert columns to numeric
numeric_cols = df.columns.drop('Year')
df[numeric_cols] = df[numeric_cols].apply(pd.to_numeric, errors='coerce')

# Analyze literacy rate progression
literacy = df[df['LiteracyRateAdult'].notna()][['Year', 'LiteracyRateAdult']]
print(f"Literacy measurements: {len(literacy)} years")
print(f"Literacy change: {literacy['LiteracyRateAdult'].iloc[-1] - literacy['LiteracyRateAdult'].iloc[0]:.2f}%")

# Visualize tertiary enrollment trend
import matplotlib.pyplot as plt
tertiary = df[df['TertiaryEnrollmentRatio'].notna()]
plt.plot(tertiary['Year'], tertiary['TertiaryEnrollmentRatio'])
plt.title('Vietnam Tertiary Education Enrollment (1976-2024)')
plt.xlabel('Year')
plt.ylabel('Enrollment Ratio (%)')
plt.show()

# Calculate average education spending (post-2000)
modern_spending = df[df['Year'] >= 2000]['EducationExpenditureGDP']
print(f"Average education spending (2000-2024): {modern_spending.mean():.2f}% of GDP")
```

### TypeScript (React)
```typescript
import { parse } from 'csv-parse/browser/esm/sync';
import csvData from './education_consolidated.csv?raw';

interface EducationData {
  Year: number;
  LiteracyRateAdult: number | null;
  AdultLiteracyWB: number | null;
  PrimaryCompletionRate: number | null;
  MeanYearsSchooling: number | null;
  ExpectedYearsSchooling: number | null;
  SchoolLifeExpectancy: number | null;
  TertiaryEnrollmentRatio: number | null;
  EducationExpenditureGDP: number | null;
}

// Parse CSV
const records = parse(csvData, {
  columns: true,
  skip_empty_lines: true,
});

// Convert to typed data
const educationData: EducationData[] = records.map(row => ({
  Year: parseInt(row.Year),
  LiteracyRateAdult: row.LiteracyRateAdult !== 'N/A' ? parseFloat(row.LiteracyRateAdult) : null,
  AdultLiteracyWB: row.AdultLiteracyWB !== 'N/A' ? parseFloat(row.AdultLiteracyWB) : null,
  PrimaryCompletionRate: row.PrimaryCompletionRate !== 'N/A' ? parseFloat(row.PrimaryCompletionRate) : null,
  MeanYearsSchooling: row.MeanYearsSchooling !== 'N/A' ? parseFloat(row.MeanYearsSchooling) : null,
  ExpectedYearsSchooling: row.ExpectedYearsSchooling !== 'N/A' ? parseFloat(row.ExpectedYearsSchooling) : null,
  SchoolLifeExpectancy: row.SchoolLifeExpectancy !== 'N/A' ? parseFloat(row.SchoolLifeExpectancy) : null,
  TertiaryEnrollmentRatio: row.TertiaryEnrollmentRatio !== 'N/A' ? parseFloat(row.TertiaryEnrollmentRatio) : null,
  EducationExpenditureGDP: row.EducationExpenditureGDP !== 'N/A' ? parseFloat(row.EducationExpenditureGDP) : null,
}));

// Example: Tertiary enrollment chart
const TertiaryEnrollmentChart = () => {
  const chartData = educationData
    .filter(d => d.TertiaryEnrollmentRatio !== null)
    .map(d => ({
      year: d.Year,
      enrollment: d.TertiaryEnrollmentRatio,
    }));

  return (
    <LineChart data={chartData}>
      <XAxis dataKey="year" />
      <YAxis label="Enrollment Ratio (%)" />
      <Line dataKey="enrollment" stroke="#2563eb" />
      <Tooltip formatter={(value) => `${value.toFixed(1)}%`} />
    </LineChart>
  );
};

// Example: Education spending gauge
const SpendingGauge = ({ year }: { year: number }) => {
  const data = educationData.find(d => d.Year === year);
  const spending = data?.EducationExpenditureGDP;
  
  return (
    <div className="education-gauge">
      <h3>Education Spending {year}</h3>
      <div className="gauge-value">
        {spending !== null ? `${spending.toFixed(2)}% of GDP` : 'No data'}
      </div>
      <div className="gauge-label">
        {spending && spending > 4.0 ? 'High Investment' : 
         spending && spending > 3.0 ? 'Moderate Investment' : 'Limited Data'}
      </div>
    </div>
  );
};
```

---

## Integration with Main Dataset

To merge this education data with the main `vietnam_advance.csv`:

```powershell
# Load both datasets
$education = Import-Csv "education_consolidated.csv"
$main = Import-Csv "..\src\data\vietnam_advance.csv"

# Merge by Year
$merged = $main | ForEach-Object {
    $year = $_.Year
    $eduRow = $education | Where-Object { $_.Year -eq $year } | Select-Object -First 1
    
    $_ | Add-Member -NotePropertyName "LiteracyRate" -NotePropertyValue $eduRow.LiteracyRateAdult -PassThru |
         Add-Member -NotePropertyName "TertiaryEnrollment" -NotePropertyValue $eduRow.TertiaryEnrollmentRatio -PassThru |
         Add-Member -NotePropertyName "EducationSpendingGDP" -NotePropertyValue $eduRow.EducationExpenditureGDP -PassThru
}

# Export merged dataset
$merged | Export-Csv "vietnam_complete.csv" -NoTypeInformation -Encoding UTF8
```

---

## Data Limitations & Caveats

### 🚨 Critical Issues

1. **Very Low Fill Rate (17.5%)**
   - Only 91 data points across 520 cells (65 years × 8 columns)
   - Most pre-1976 data completely absent
   - War period (1960-1975) has zero measurements

2. **Empty Source Files**
   - `MeanYearsSchooling` and `ExpectedYearsSchooling` have no data
   - Consider removing these columns or finding alternative sources

3. **Duplicate Indicators**
   - `LiteracyRateAdult` and `AdultLiteracyWB` have identical values
   - Both source UNESCO data through World Bank API
   - Recommend using only one in final analysis

4. **Sparse Time Series**
   - Literacy data: only 7 measurements in 65 years
   - School life expectancy: only 5 measurements (all pre-1981)
   - Not suitable for continuous trend analysis

### 📊 Data Quality Improvements Needed

**Priority 1: Find Alternative Sources**
- UNESCO SDG4 XLSX file (109KB) contains more data but requires parsing
- Consider Vietnamese government sources (Ministry of Education)
- UNDP Human Development Reports may have additional education metrics

**Priority 2: Fill Historical Gaps**
- Pre-1975 data from North Vietnam archives
- Post-reunification data from Vietnamese statistical yearbooks
- Academic studies on Vietnam's education system

**Priority 3: Validation**
- Cross-check literacy rates with census data
- Verify tertiary enrollment with university admission statistics
- Compare spending figures with government budget reports

### 🎯 Recommended Usage

**✅ Suitable For:**
- Long-term trend analysis (1979-2022 literacy improvement)
- Tertiary education expansion visualization (40-year series)
- Education investment cycles (1995-2022)

**❌ Not Suitable For:**
- Year-over-year change analysis (too many gaps)
- Pre-Đổi Mới education system analysis (no data)
- Mean schooling years or expected schooling (empty datasets)

---

## Future Enhancement Opportunities

1. **Parse UNESCO XLSX File** (`unesco_sdg4.xlsx`)
   - Contains 109KB of SDG4 education indicators
   - Requires PowerShell Import-Excel module
   - May provide 10+ additional education metrics

2. **Integrate Vietnamese Government Data**
   - Ministry of Education annual reports
   - General Statistics Office education surveys
   - Provincial-level education data for regional analysis

3. **Add Derived Indicators**
   - Education Gini coefficient (inequality measure)
   - Gender parity index for tertiary enrollment
   - Education ROI metrics (earnings by education level)

4. **Historical Reconstruction**
   - Academic sources for 1960-1975 education data
   - Interpolation models for missing years (with caveats)
   - Comparison with regional peers (Thailand, Malaysia, Philippines)

---

## Citation & Attribution

**Data Sources:**
- UNESCO Institute for Statistics (UIS) via World Bank API
- World Bank Education Statistics Database
- World Development Indicators (WDI)

**Last Updated:** 2024 (data collected through World Bank API)

**Recommended Citation:**
```
Vietnam Education Data Consolidated (1960-2024). 
Compiled from World Bank and UNESCO Institute for Statistics.
Dragon Fly Data Project, 2024.
```

**License:** CC BY 4.0 (Creative Commons Attribution)

---

## Contact & Contribution

Found data quality issues? Have additional sources? Want to contribute?

- **GitHub Issues**: Report data discrepancies or missing sources
- **Pull Requests**: Contribute additional education indicators
- **Data Sources**: Share Vietnamese government education statistics

**Maintained by:** Dragon Fly Data Project  
**Last Review:** 2024-01-XX
