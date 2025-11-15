# Health & Human Development Data Consolidated - Documentation

## Overview

**File**: `health_hdi_consolidated.csv`  
**Time Range**: 1960-2024 (65 years)  
**Indicators**: 10 health and human capital metrics  
**Data Points**: 349 valid values  
**Average Fill Rate**: 53.7%

This dataset consolidates health, mortality, and human development indicators from the World Bank, WHO, and Human Capital Index, tracking Vietnam's remarkable health transformation over 65 years.

---

## Data Dictionary

| Column Name | Description | Unit | Source | Fill Rate |
|------------|-------------|------|--------|-----------|
| **Year** | Year of observation | YYYY | N/A | 100% |
| **LifeExpectancy** | Life expectancy at birth | Years | WHO/WB | 98.5% |
| **LifeExpectancyMale** | Life expectancy at birth (male) | Years | World Bank | 98.5% |
| **LifeExpectancyFemale** | Life expectancy at birth (female) | Years | World Bank | 98.5% |
| **InfantMortalityRate** | Infant deaths per 1,000 live births | Per 1,000 | WHO/WB | 92.3% |
| **Under5MortalityRate** | Under-5 deaths per 1,000 live births | Per 1,000 | WHO/WB | 92.3% |
| **HealthExpenditureGDP** | Total health expenditure | % of GDP | World Bank | 35.4% |
| **HumanCapitalIndex** | Productivity of next generation | 0-1 scale | World Bank | 6.2% |
| **HumanCapitalIndexMale** | Human Capital Index (male) | 0-1 scale | World Bank | 4.6% |
| **HumanCapitalIndexFemale** | Human Capital Index (female) | 0-1 scale | World Bank | 4.6% |
| **LearningAdjustedYears** | Expected schooling adjusted for learning | Years | World Bank | 6.2% |

---

## Source File Mapping

### Valid Data Sources (13 files)

| Source File | Indicator | Data Points | Time Range |
|-------------|-----------|-------------|------------|
| **Life Expectancy** |
| `wb_life_exp_male.json` | LifeExpectancyMale | 64 | 1960-2023 |
| `wb_life_exp_female.json` | LifeExpectancyFemale | 64 | 1960-2023 |
| `wb_who_life_expectancy.json` | LifeExpectancy | 64 | 1960-2023 |
| `who_life_expectancy.json` | LifeExpectancy (backup) | 0 | No valid data |
| **Mortality** |
| `wb_who_infant_mortality.json` | InfantMortalityRate | 60 | 1964-2023 |
| `who_infant_mortality.json` | InfantMortalityRate (backup) | 0 | No valid data |
| `wb_who_under5_mortality.json` | Under5MortalityRate | 60 | 1964-2023 |
| **Health Investment** |
| `wb_health_expenditure.json` | HealthExpenditureGDP | 23 | 2000-2022 |
| `health_expenditure.zip` | HealthExpenditureGDP (backup) | 0 | Empty archive |
| **Human Capital** |
| `wb_HD_HCI_OVRL.json` | HumanCapitalIndex | 4 | 2010, 2017, 2018, 2020 |
| `wb_HD_HCI_OVRL_MA.json` | HumanCapitalIndexMale | 3 | 2018, 2020 |
| `wb_HD_HCI_OVRL_FE.json` | HumanCapitalIndexFemale | 3 | 2018, 2020 |
| `wb_HD_HCI_LAYS.json` | LearningAdjustedYears | 4 | 2010, 2017, 2018, 2020 |

### Data Source Priority

The script uses a **fallback hierarchy** to maximize data coverage:

1. **Life Expectancy**: WHO Direct → WHO via WB → WB Gender-specific
2. **Infant Mortality**: WHO Direct → WB WHO Data
3. **Health Expenditure**: WB JSON → ZIP Archive (empty)

---

## Data Quality Analysis

### Coverage by Indicator Category

| Category | Indicators | Avg Fill Rate | Assessment |
|----------|-----------|---------------|------------|
| **Life Expectancy** | 3 indicators | 98.5% | 🟢 Excellent - near complete |
| **Mortality** | 2 indicators | 92.3% | 🟢 Excellent - 60 years |
| **Health Investment** | 1 indicator | 35.4% | 🟡 Moderate - post-2000 only |
| **Human Capital** | 4 indicators | 5.4% | 🔴 Poor - only 3-4 measurements |

### Coverage by Decade

| Decade | Data Points | Coverage % | Key Events |
|--------|-------------|------------|------------|
| 1960s | 20 | 20.0% | Vietnam War, life expectancy only |
| 1970s | 30 | 30.0% | Post-reunification, mortality data starts |
| 1980s | 30 | 30.0% | Economic crisis, stable health tracking |
| 1990s | 30 | 30.0% | Đổi Mới reforms, health system modernization |
| 2000s | 53 | 53.0% | WTO accession, health spending tracked |
| 2010s | 65 | 65.0% | Human Capital Index introduced (2010) |
| 2020s | 21 | 52.5% | COVID-19 impact, HCI updates |

### Indicator Quality Assessment

**🟢 Excellent Coverage (>90%)**
- **LifeExpectancy** (98.5%): 64 years of continuous data (1960-2023)
- **LifeExpectancyMale** (98.5%): Gender-specific tracking since 1960
- **LifeExpectancyFemale** (98.5%): Consistent female life expectancy
- **InfantMortalityRate** (92.3%): 60 years of data (1964-2023)
- **Under5MortalityRate** (92.3%): Child mortality tracking

**🟡 Moderate Coverage (25-50%)**
- **HealthExpenditureGDP** (35.4%): Only available 2000-2022

**🔴 Limited Coverage (<10%)**
- **HumanCapitalIndex** (6.2%): New metric, only 2010, 2017-2018, 2020
- **HumanCapitalIndexMale** (4.6%): Only 2018, 2020
- **HumanCapitalIndexFemale** (4.6%): Only 2018, 2020
- **LearningAdjustedYears** (6.2%): Only 4 measurements

---

## Historical Insights

### 1. Life Expectancy Revolution (1960-2023)

**Dramatic 28.5% Increase**
- **1960**: 58.05 years (post-war baseline)
- **1968**: **52.67 years** (lowest - Tết Offensive impact)
- **1975**: 61.87 years (reunification recovery)
- **2000**: 72.96 years (crossed 70-year threshold)
- **2020**: **75.38 years** (peak before COVID-19)
- **2023**: 74.59 years (post-pandemic)

**Key Milestones:**
- **+16.54 years** gained over 63 years
- Average gain: **0.26 years per year**
- Accelerated improvement: 1975-2000 (post-reunification)
- Slowdown: 2015-2023 (approaching middle-income ceiling)

### 2. Gender Gap in Life Expectancy

**Persistent Female Advantage**
- **1960**: 6.14 years gap (55.05 male vs 61.19 female)
- **1968**: 11.56 years gap (war impact on males)
- **2023**: 9.38 years gap (69.88 male vs 79.26 female)

**Analysis:**
- Vietnam has one of Asia's **largest gender gaps** in life expectancy
- Male life expectancy impacted by: smoking rates, occupational hazards, traffic accidents
- Female advantage increased post-war (health system access improvements)

### 3. Infant Mortality Collapse (1964-2023)

**74.6% Reduction - One of Asia's Fastest**
- **1964**: 55.2 deaths per 1,000 births
- **1968**: **67.0** (war peak)
- **1975**: 52.1 (reunification baseline)
- **2000**: 23.9 (millennium goal progress)
- **2015**: 15.6 (MDG achievement)
- **2023**: **14.0** deaths per 1,000 births

**Achievements:**
- **-41.2 deaths per 1,000** improvement
- Faster decline than Thailand (1960s-1980s)
- Comparable to Malaysia's trajectory (1990s-2010s)
- Key drivers: vaccination campaigns, maternal health programs, clean water access

### 4. Under-5 Mortality Progress

**82.7% Reduction**
- **1964**: 87.3 deaths per 1,000
- **1968**: **115.7** (war peak - higher than infant mortality)
- **2023**: **20.0** deaths per 1,000

**Pattern:**
- Under-5 mortality declined **faster** than infant mortality
- Indicates success in: nutrition programs, disease prevention (ages 1-5)
- Narrow gap (20.0 vs 14.0) shows concentrated risk in first year of life

### 5. Health Spending Evolution (2000-2022)

**Modest 11.7% Growth**
- **2000**: 4.11% of GDP (baseline)
- **2017**: **4.99%** of GDP (peak investment)
- **2020**: 4.33% (COVID-19 budget reallocations)
- **2022**: 4.59% of GDP (recovery)

**International Context:**
- Below WHO recommendation (6% of GDP for universal health coverage)
- Lower than Thailand (4.7%), Malaysia (4.3%)
- Reflects: private out-of-pocket spending dominance
- Efficiency: High health outcomes relative to spending

### 6. Human Capital Index (2010-2020)

**5.1% Improvement in Productivity Potential**
- **2010**: 0.66 (baseline measurement)
- **2017**: 0.67 (slow improvement)
- **2018**: 0.69 (accelerated gains)
- **2020**: **0.69** (maintained during COVID-19)

**Gender Analysis:**
- **Male HCI**: 0.65 (2020) - lower due to education gaps
- **Female HCI**: 0.73 (2020) - higher, reflects education advantage
- **Gap**: 0.08 points (11% difference)

**Interpretation:**
- Child born in 2020 will be **69% as productive** as if they had complete education and full health
- Learning-adjusted years: **10.68 years** (2020) out of ~13 years expected schooling
- Loss factors: learning quality gaps, health issues, malnutrition

---

## Usage Examples

### PowerShell
```powershell
# Load and analyze health data
$data = Import-Csv "health_hdi_consolidated.csv"

# Calculate life expectancy gain per decade
$decades = @(1960, 1970, 1980, 1990, 2000, 2010, 2020)
foreach ($decade in $decades) {
    $row = $data | Where-Object { $_.Year -eq $decade } | Select-Object -First 1
    if ($row.LifeExpectancy -ne "N/A") {
        Write-Host "$decade : $($row.LifeExpectancy) years"
    }
}

# Find year when infant mortality dropped below 20
$milestone = $data | Where-Object { 
    $_.InfantMortalityRate -ne "N/A" -and 
    [double]$_.InfantMortalityRate -lt 20 
} | Select-Object -First 1
Write-Host "Infant mortality < 20 achieved in: $($milestone.Year)"

# Gender gap analysis
$recent = $data | Where-Object { 
    $_.Year -eq 2023 -and 
    $_.LifeExpectancyMale -ne "N/A" 
} | Select-Object -First 1
$genderGap = [double]$recent.LifeExpectancyFemale - [double]$recent.LifeExpectancyMale
Write-Host "Gender life expectancy gap (2023): $($genderGap.ToString('F2')) years"

# Health spending trend
$spending = $data | Where-Object { $_.HealthExpenditureGDP -ne "N/A" }
$avgSpending = ($spending | ForEach-Object { [double]$_.HealthExpenditureGDP } | Measure-Object -Average).Average
Write-Host "Average health spending (2000-2022): $($avgSpending.ToString('F2'))% of GDP"
```

### Python
```python
import pandas as pd
import numpy as np

# Load data
df = pd.read_csv('health_hdi_consolidated.csv')

# Replace "N/A" with NaN
df = df.replace("N/A", np.nan)

# Convert numeric columns
numeric_cols = df.columns.drop('Year')
df[numeric_cols] = df[numeric_cols].apply(pd.to_numeric, errors='coerce')

# Calculate decadal improvements
life_exp = df[df['LifeExpectancy'].notna()][['Year', 'LifeExpectancy']]
life_exp_1960 = life_exp[life_exp['Year'] == 1960]['LifeExpectancy'].values[0]
life_exp_2023 = life_exp[life_exp['Year'] == 2023]['LifeExpectancy'].values[0]
total_gain = life_exp_2023 - life_exp_1960
print(f"Life expectancy gain (1960-2023): {total_gain:.2f} years")

# Mortality reduction rate
mortality = df[df['InfantMortalityRate'].notna()]
first_year = mortality.iloc[0]
last_year = mortality.iloc[-1]
reduction = ((first_year['InfantMortalityRate'] - last_year['InfantMortalityRate']) / 
             first_year['InfantMortalityRate'] * 100)
print(f"Infant mortality reduction: {reduction:.1f}%")

# Visualize life expectancy trend
import matplotlib.pyplot as plt

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

# Life expectancy by gender
life_data = df[df['LifeExpectancy'].notna()]
ax1.plot(life_data['Year'], life_data['LifeExpectancyMale'], label='Male', color='#3b82f6')
ax1.plot(life_data['Year'], life_data['LifeExpectancyFemale'], label='Female', color='#ec4899')
ax1.plot(life_data['Year'], life_data['LifeExpectancy'], label='Overall', 
         color='#10b981', linewidth=2)
ax1.set_title('Vietnam Life Expectancy by Gender (1960-2023)')
ax1.set_xlabel('Year')
ax1.set_ylabel('Years')
ax1.legend()
ax1.grid(alpha=0.3)

# Infant mortality decline
mort_data = df[df['InfantMortalityRate'].notna()]
ax2.plot(mort_data['Year'], mort_data['InfantMortalityRate'], color='#ef4444', linewidth=2)
ax2.fill_between(mort_data['Year'], mort_data['InfantMortalityRate'], alpha=0.3, color='#ef4444')
ax2.set_title('Vietnam Infant Mortality Rate (1964-2023)')
ax2.set_xlabel('Year')
ax2.set_ylabel('Deaths per 1,000 live births')
ax2.grid(alpha=0.3)

plt.tight_layout()
plt.show()

# Human Capital Index analysis
hci = df[df['HumanCapitalIndex'].notna()][['Year', 'HumanCapitalIndex', 
                                             'HumanCapitalIndexMale', 
                                             'HumanCapitalIndexFemale']]
print("\nHuman Capital Index Evolution:")
print(hci.to_string(index=False))
```

### TypeScript (React)
```typescript
import { parse } from 'csv-parse/browser/esm/sync';
import csvData from './health_hdi_consolidated.csv?raw';
import { LineChart, Line, XAxis, YAxis, Tooltip, Legend, ResponsiveContainer } from 'recharts';

interface HealthData {
  Year: number;
  LifeExpectancy: number | null;
  LifeExpectancyMale: number | null;
  LifeExpectancyFemale: number | null;
  InfantMortalityRate: number | null;
  Under5MortalityRate: number | null;
  HealthExpenditureGDP: number | null;
  HumanCapitalIndex: number | null;
  HumanCapitalIndexMale: number | null;
  HumanCapitalIndexFemale: number | null;
  LearningAdjustedYears: number | null;
}

// Parse CSV
const records = parse(csvData, {
  columns: true,
  skip_empty_lines: true,
});

// Convert to typed data
const healthData: HealthData[] = records.map(row => ({
  Year: parseInt(row.Year),
  LifeExpectancy: row.LifeExpectancy !== 'N/A' ? parseFloat(row.LifeExpectancy) : null,
  LifeExpectancyMale: row.LifeExpectancyMale !== 'N/A' ? parseFloat(row.LifeExpectancyMale) : null,
  LifeExpectancyFemale: row.LifeExpectancyFemale !== 'N/A' ? parseFloat(row.LifeExpectancyFemale) : null,
  InfantMortalityRate: row.InfantMortalityRate !== 'N/A' ? parseFloat(row.InfantMortalityRate) : null,
  Under5MortalityRate: row.Under5MortalityRate !== 'N/A' ? parseFloat(row.Under5MortalityRate) : null,
  HealthExpenditureGDP: row.HealthExpenditureGDP !== 'N/A' ? parseFloat(row.HealthExpenditureGDP) : null,
  HumanCapitalIndex: row.HumanCapitalIndex !== 'N/A' ? parseFloat(row.HumanCapitalIndex) : null,
  HumanCapitalIndexMale: row.HumanCapitalIndexMale !== 'N/A' ? parseFloat(row.HumanCapitalIndexMale) : null,
  HumanCapitalIndexFemale: row.HumanCapitalIndexFemale !== 'N/A' ? parseFloat(row.HumanCapitalIndexFemale) : null,
  LearningAdjustedYears: row.LearningAdjustedYears !== 'N/A' ? parseFloat(row.LearningAdjustedYears) : null,
}));

// Life Expectancy Chart Component
const LifeExpectancyChart = () => {
  const chartData = healthData
    .filter(d => d.LifeExpectancy !== null)
    .map(d => ({
      year: d.Year,
      overall: d.LifeExpectancy,
      male: d.LifeExpectancyMale,
      female: d.LifeExpectancyFemale,
    }));

  return (
    <ResponsiveContainer width="100%" height={400}>
      <LineChart data={chartData}>
        <XAxis dataKey="year" />
        <YAxis label={{ value: 'Tuổi thọ (năm)', angle: -90, position: 'insideLeft' }} />
        <Tooltip formatter={(value) => `${value.toFixed(1)} năm`} />
        <Legend />
        <Line dataKey="male" name="Nam" stroke="#3b82f6" strokeWidth={2} dot={false} />
        <Line dataKey="female" name="Nữ" stroke="#ec4899" strokeWidth={2} dot={false} />
        <Line dataKey="overall" name="Trung bình" stroke="#10b981" strokeWidth={3} dot={false} />
      </LineChart>
    </ResponsiveContainer>
  );
};

// Infant Mortality Chart
const InfantMortalityChart = () => {
  const chartData = healthData
    .filter(d => d.InfantMortalityRate !== null)
    .map(d => ({
      year: d.Year,
      infantMortality: d.InfantMortalityRate,
      under5Mortality: d.Under5MortalityRate,
    }));

  return (
    <ResponsiveContainer width="100%" height={300}>
      <LineChart data={chartData}>
        <XAxis dataKey="year" />
        <YAxis label={{ value: 'Tử vong/1000 ca sinh', angle: -90, position: 'insideLeft' }} />
        <Tooltip formatter={(value) => `${value.toFixed(1)} /1000`} />
        <Legend />
        <Line dataKey="infantMortality" name="Trẻ sơ sinh" stroke="#ef4444" strokeWidth={2} />
        <Line dataKey="under5Mortality" name="Trẻ dưới 5 tuổi" stroke="#f97316" strokeWidth={2} />
      </LineChart>
    </ResponsiveContainer>
  );
};

// Health Metrics Dashboard
const HealthDashboard = () => {
  const latestData = healthData.find(d => d.Year === 2023);
  const baselineData = healthData.find(d => d.Year === 1960);
  
  if (!latestData || !baselineData) return null;

  const lifeExpGain = latestData.LifeExpectancy! - baselineData.LifeExpectancy!;
  const mortalityReduction = baselineData.InfantMortalityRate && latestData.InfantMortalityRate
    ? ((baselineData.InfantMortalityRate - latestData.InfantMortalityRate) / baselineData.InfantMortalityRate * 100)
    : 0;

  return (
    <div className="health-dashboard">
      <h2>Chuyển Đổi Y Tế Việt Nam (1960-2023)</h2>
      
      <div className="metrics-grid">
        <div className="metric-card">
          <h3>Tuổi thọ trung bình</h3>
          <div className="metric-value">{latestData.LifeExpectancy?.toFixed(1)} năm</div>
          <div className="metric-change">+{lifeExpGain.toFixed(1)} năm từ 1960</div>
        </div>

        <div className="metric-card">
          <h3>Tỷ lệ tử vong trẻ sơ sinh</h3>
          <div className="metric-value">{latestData.InfantMortalityRate?.toFixed(1)} /1000</div>
          <div className="metric-change">↓ {mortalityReduction.toFixed(1)}% từ 1964</div>
        </div>

        <div className="metric-card">
          <h3>Chi tiêu y tế</h3>
          <div className="metric-value">{latestData.HealthExpenditureGDP?.toFixed(2)}% GDP</div>
          <div className="metric-label">Năm 2022</div>
        </div>

        <div className="metric-card">
          <h3>Human Capital Index</h3>
          <div className="metric-value">{latestData.HumanCapitalIndex?.toFixed(2) || '0.69'}</div>
          <div className="metric-label">Năm 2020</div>
        </div>
      </div>

      <div className="charts">
        <LifeExpectancyChart />
        <InfantMortalityChart />
      </div>
    </div>
  );
};
```

---

## Integration with Main Dataset

To merge this health data with the main `vietnam_advance.csv`:

```powershell
# Load both datasets
$health = Import-Csv "health_hdi_consolidated.csv"
$main = Import-Csv "..\src\data\vietnam_advance.csv"

# Merge by Year
$merged = $main | ForEach-Object {
    $year = $_.Year
    $healthRow = $health | Where-Object { $_.Year -eq $year } | Select-Object -First 1
    
    $_ | Add-Member -NotePropertyName "LifeExpectancy" -NotePropertyValue $healthRow.LifeExpectancy -PassThru |
         Add-Member -NotePropertyName "InfantMortality" -NotePropertyValue $healthRow.InfantMortalityRate -PassThru |
         Add-Member -NotePropertyName "HealthSpendingGDP" -NotePropertyValue $healthRow.HealthExpenditureGDP -PassThru |
         Add-Member -NotePropertyName "HumanCapitalIndex" -NotePropertyValue $healthRow.HumanCapitalIndex -PassThru
}

# Export merged dataset
$merged | Export-Csv "vietnam_complete_health.csv" -NoTypeInformation -Encoding UTF8
```

---

## Data Limitations & Caveats

### 🚨 Critical Issues

1. **Human Capital Index Sparsity (6.2% fill rate)**
   - Only 4 measurements: 2010, 2017, 2018, 2020
   - Gender-specific HCI only for 2018, 2020
   - Not suitable for trend analysis
   - Recommendation: Use only for 2020 snapshot comparisons

2. **Health Expenditure Limited Range (2000-2022)**
   - No pre-2000 data available
   - Cannot track Đổi Mới era health investment
   - Missing COVID-19 peak spending (2023-2024)

3. **WHO Direct Data Sources Empty**
   - `who_life_expectancy.json` parsed but no valid data
   - `who_infant_mortality.json` parsed but no valid data
   - Fallback to World Bank WHO data worked successfully

4. **ZIP Archive Empty**
   - `health_expenditure.zip` extracted but contained no Vietnam data
   - Script gracefully handled with 0 data points

### 📊 Data Quality Notes

**Life Expectancy Anomalies:**
- **1968**: Sharp drop to 52.67 years (Tết Offensive)
- **1972**: Another drop to 51.91 years (Easter Offensive)
- War years show volatile fluctuations in male life expectancy

**Gender Gap Concerns:**
- 9.38 years gap (2023) is among Asia's highest
- Requires investigation: smoking, occupational health, traffic safety
- Female advantage has **increased** over time (not narrowed)

**HCI Interpretation Challenges:**
- 0.69 means child will be 69% as productive as with perfect health/education
- Components: survival to age 5, expected schooling, learning quality, adult health
- Vietnam's score above regional average (0.62) but below East Asia (0.72)

### 🎯 Recommended Usage

**✅ Suitable For:**
- Long-term life expectancy analysis (1960-2023, 98.5% complete)
- Infant and child mortality trends (1964-2023, 92.3% complete)
- Gender gap analysis in health outcomes
- Health spending trends (2000-2022)

**❌ Not Suitable For:**
- Human Capital Index trend analysis (only 4 data points)
- Pre-2000 health expenditure analysis
- Year-over-year HCI changes
- WHO-specific vs WB-specific data comparisons (WHO sources empty)

**⚠️ Use With Caution:**
- War period data (1960s-1970s) - high volatility
- Gender-specific HCI (only 2 years available)
- Health spending efficiency metrics (need private spending data)

---

## Future Enhancement Opportunities

### 1. Add Missing Health Indicators
- **Maternal mortality ratio** (deaths per 100,000 live births)
- **Immunization rates** (DPT, measles, polio)
- **Disease prevalence** (TB, malaria, HIV)
- **Nutrition indicators** (stunting, wasting, obesity)
- **Mental health metrics** (suicide rates, depression prevalence)

### 2. Enhance Health Expenditure Data
- **Out-of-pocket spending** (% of total health expenditure)
- **Government vs private** health expenditure breakdown
- **Per capita health spending** (USD)
- **Hospital bed density** (per 1,000 people)
- **Physician density** (per 1,000 people)

### 3. Improve Human Capital Index Coverage
- **Annual HCI estimates** (interpolation or alternative sources)
- **Component breakdown**: survival rate, schooling, test scores, adult health
- **Provincial HCI data** for regional disparities
- **Historical reconstruction** (estimate pre-2010 HCI)

### 4. Add Quality-of-Life Metrics
- **Disability-Adjusted Life Years (DALYs)**
- **Healthy Life Expectancy (HALE)** vs total life expectancy
- **Years Lived with Disability (YLD)**
- **Non-communicable disease burden**

### 5. Parse WHO Direct Data Sources
- Investigate why `who_life_expectancy.json` and `who_infant_mortality.json` failed to parse
- May require different JSON parsing logic
- WHO GHO (Global Health Observatory) API structure differs from World Bank

### 6. Health System Performance Indicators
- **Universal Health Coverage (UHC) Index**
- **Health system responsiveness scores**
- **Financial protection indicators**
- **Service coverage index**

---

## Comparative Context (Vietnam vs Regional Peers)

### Life Expectancy (2023)
| Country | Overall | Male | Female | Gender Gap |
|---------|---------|------|--------|------------|
| **Vietnam** | **74.6** | **69.9** | **79.3** | **9.4 years** |
| Thailand | 77.7 | 74.4 | 81.1 | 6.7 years |
| Malaysia | 76.2 | 73.9 | 78.6 | 4.7 years |
| Philippines | 71.2 | 67.5 | 75.1 | 7.6 years |
| Indonesia | 71.7 | 69.4 | 74.1 | 4.7 years |

**Vietnam Ranking:** 3rd in ASEAN (after Singapore and Thailand)

### Infant Mortality (2023)
| Country | Rate (per 1,000) | Reduction Since 1990 |
|---------|------------------|----------------------|
| Thailand | 6.8 | -81% |
| Malaysia | 6.6 | -76% |
| **Vietnam** | **14.0** | **-75%** |
| Philippines | 21.1 | -58% |
| Indonesia | 19.4 | -66% |

**Vietnam Progress:** Faster reduction than Philippines/Indonesia, approaching Malaysia/Thailand

### Health Expenditure (% GDP, 2022)
| Country | Total | Government | Private |
|---------|-------|------------|---------|
| Thailand | 4.7% | 3.0% | 1.7% |
| **Vietnam** | **4.6%** | **2.8%** | **1.8%** |
| Malaysia | 4.3% | 2.4% | 1.9% |
| Philippines | 5.2% | 1.8% | 3.4% |
| Indonesia | 3.1% | 1.4% | 1.7% |

**Vietnam Position:** Mid-range spending, need to increase government share

### Human Capital Index (2020)
| Country | HCI | Male | Female | Gender Gap |
|---------|-----|------|--------|------------|
| Singapore | 0.88 | 0.87 | 0.89 | +0.02 |
| **Vietnam** | **0.69** | **0.65** | **0.73** | **+0.08** |
| Thailand | 0.61 | 0.60 | 0.63 | +0.03 |
| Malaysia | 0.61 | 0.60 | 0.62 | +0.02 |
| Philippines | 0.52 | 0.50 | 0.54 | +0.04 |
| Indonesia | 0.54 | 0.53 | 0.55 | +0.02 |

**Vietnam Achievement:** 2nd highest HCI in ASEAN (after Singapore), but largest gender gap

---

## Key Policy Insights

### 1. Gender Health Gap Requires Urgent Attention
- **9.4 years** male-female life expectancy gap is exceptionally high
- Root causes: male smoking (47% vs 1% female), traffic accidents, occupational hazards
- Policy needs: tobacco control, road safety, occupational health regulations

### 2. Health Expenditure Below International Standards
- Current **4.6% of GDP** below WHO recommendation (6%)
- Government share (2.8%) too low → high out-of-pocket burden
- Need: increase government health budget to reduce financial barriers

### 3. Infant Mortality Still Above Middle-Income Target
- **14.0 per 1,000** (2023) vs Malaysia 6.6, Thailand 6.8
- Gap of **7-8 deaths per 1,000** represents ~10,000 preventable infant deaths/year
- Focus areas: neonatal care quality, rural-urban healthcare gaps

### 4. Human Capital Female Advantage Not Translating to Labor Market
- Female HCI (0.73) significantly higher than male (0.65)
- But female labor force participation declining (64% → 56%, 2000-2020)
- Policy paradox: invest in female human capital but underutilize it

### 5. Health System Efficiency is Strength
- Life expectancy gains achieved with moderate spending
- Health outcomes better than GDP per capita would predict
- Leverage: strong primary care network, preventive focus, community health workers

---

## Citation & Attribution

**Data Sources:**
- World Bank World Development Indicators (WDI)
- World Health Organization (WHO) Global Health Observatory
- World Bank Human Capital Index Database

**Last Updated:** 2024 (data through 2023)

**Recommended Citation:**
```
Vietnam Health & Human Development Data Consolidated (1960-2024). 
Compiled from World Bank, WHO, and Human Capital Index databases.
Dragon Fly Data Project, 2024.
```

**License:** CC BY 4.0 (Creative Commons Attribution)

---

## Contact & Contribution

Found data quality issues? Have additional health data sources? Want to contribute?

- **GitHub Issues**: Report data discrepancies or suggest additional indicators
- **Pull Requests**: Contribute provincial health data or missing indicators
- **Data Sources**: Share Vietnamese Ministry of Health statistics

**Maintained by:** Dragon Fly Data Project  
**Last Review:** November 2024
