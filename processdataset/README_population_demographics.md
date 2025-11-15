# Population & Demographics Consolidated Dataset

## 📊 Tổng quan

File CSV này tổng hợp **17 chỉ số dân số & nhân khẩu** của Việt Nam từ năm **1960-2024** (65 năm), được trích xuất từ ~20 file nguồn khác nhau từ World Bank API.

## 📁 Thông tin file

- **Tên file**: `population_demographics_consolidated.csv`
- **Số dòng**: 65 năm (1960-2024)
- **Số cột**: 19 cột (1 cột Year + 18 chỉ số)
- **Định dạng**: UTF-8 CSV
- **Tỷ lệ dữ liệu hợp lệ**: ~85% (trung bình)

## 📋 Danh sách các cột

### 1. Year
- **Kiểu dữ liệu**: Integer
- **Khoảng giá trị**: 1960-2024
- **Mô tả**: Năm của dữ liệu

### 2. Cấu trúc dân số (Population Structure)

| Cột | Đơn vị | Mô tả | Fill Rate |
|-----|--------|-------|-----------|
| `PopulationDensity` | người/km² | Mật độ dân số trên diện tích đất | 96.9% |
| `Pop0to14Pct` | % | Tỷ lệ dân số 0-14 tuổi | 100% |
| `Pop15to64Pct` | % | Tỷ lệ dân số 15-64 tuổi | 100% |
| `Pop65PlusPct` | % | Tỷ lệ dân số 65+ tuổi | 100% |

### 3. Thống kê sinh tử (Vital Statistics)

| Cột | Đơn vị | Mô tả | Fill Rate |
|-----|--------|-------|-----------|
| `BirthsTotal` | số người | Tổng số sinh trong năm | 98.5% |
| `DeathsTotal` | số người | Tổng số tử vong trong năm | 98.5% |
| `BirthRatePer1000` | ‰ | Tỷ lệ sinh trên 1000 người | 98.5% |
| `DeathRatePer1000` | ‰ | Tỷ lệ tử vong trên 1000 người | 98.5% |

### 4. Đặc điểm nhân khẩu (Demographics)

| Cột | Đơn vị | Mô tả | Fill Rate |
|-----|--------|-------|-----------|
| `FertilityRate` | con/phụ nữ | Tỷ suất sinh (births per woman) | 98.5% |
| `MedianAge` | tuổi | Tuổi trung vị của dân số | 100% |
| `SexRatio` | tỷ lệ | Tỷ lệ nam/nữ | 98.5% |
| `DependencyRatio` | % | Tỷ lệ phụ thuộc [(0-14 + 65+) / 15-64] | 100% |

### 5. Di cư & tăng trưởng (Migration & Growth)

| Cột | Đơn vị | Mô tả | Fill Rate |
|-----|--------|-------|-----------|
| `NetMigration` | số người | Di cư ròng (nhập - xuất cư) | 0% ⚠️ |
| `PopulationGrowth` | % | Tốc độ tăng trưởng dân số | 0% ⚠️ |

### 6. Đô thị/Nông thôn (Urban/Rural)

| Cột | Đơn vị | Mô tả | Fill Rate |
|-----|--------|-------|-----------|
| `RuralPopulation` | số người | Dân số nông thôn | 100% |
| `UrbanPopulation` | số người | Dân số đô thị | 100% |
| `UrbanizationPct` | % | Tỷ lệ đô thị hóa | 100% |
| `UrbanGrowthRate` | % | Tốc độ tăng trưởng đô thị | 98.5% |

## 🔍 Nguồn dữ liệu

### JSON Files (17 files)
```
wb_population_density.json       → PopulationDensity
wb_pop_0_14.json                 → Pop0to14Pct
wb_pop_15_64.json                → Pop15to64Pct
wb_pop_65plus.json               → Pop65PlusPct
wb_births.json                   → BirthsTotal
wb_deaths.json                   → DeathsTotal
wb_birth_rate.json               → BirthRatePer1000
wb_death_rate.json               → DeathRatePer1000
wb_fertility_rate.json           → FertilityRate
wb_median_age.json               → MedianAge
wb_sex_ratio.json                → SexRatio
wb_migration.json                → NetMigration (empty)
wb_dependency_ratio.json         → DependencyRatio
wb_rural_population.json         → RuralPopulation
wb_urban_population.json         → UrbanPopulation
wb_urbanization.json             → UrbanizationPct
wb_urban_growth.json             → UrbanGrowthRate
```

### ZIP Files (8 files - backup sources)
```
age_0_14.zip                     → Pop0to14Pct (fallback)
age_15_64.zip                    → Pop15to64Pct (fallback)
age_65_up.zip                    → Pop65PlusPct (fallback)
birth_rate.zip                   → BirthRatePer1000 (fallback)
death_rate.zip                   → DeathRatePer1000 (fallback)
dependency_ratio.zip             → DependencyRatio (fallback)
pop_growth.zip                   → PopulationGrowth (empty)
fertility.zip                    → FertilityRate (fallback)
```

## ⚠️ Lưu ý về chất lượng dữ liệu

### Dữ liệu thiếu (Missing Data)
- **NetMigration**: 100% thiếu - file `wb_migration.json` không có dữ liệu
- **PopulationGrowth**: 100% thiếu - file ZIP không chứa dữ liệu Vietnam
- Các chỉ số khác có fill rate >96%

### Giá trị "N/A"
- Các giá trị thiếu được đánh dấu là `"N/A"` trong CSV
- Khi import vào TypeScript/Python, cần xử lý: `value === "N/A" ? null : parseFloat(value)`

### Khuyến nghị
1. **Tính toán NetMigration**: Có thể tính từ công thức: `PopulationGrowth - (BirthRate - DeathRate)`
2. **Tính toán PopulationGrowth**: Có thể tính từ sự thay đổi dân số theo năm
3. **Kiểm tra tổng phần trăm**: `Pop0to14Pct + Pop15to64Pct + Pop65PlusPct ≈ 100%`

## 🔧 Cách sử dụng

### PowerShell
```powershell
$data = Import-Csv "population_demographics_consolidated.csv"
$data | Where-Object { $_.Year -ge 2000 } | Format-Table Year, FertilityRate, MedianAge
```

### Python (pandas)
```python
import pandas as pd

df = pd.read_csv('population_demographics_consolidated.csv')
df = df.replace('N/A', pd.NA)
df[['PopulationDensity', 'FertilityRate', 'MedianAge']] = df[['PopulationDensity', 'FertilityRate', 'MedianAge']].apply(pd.to_numeric)

print(df.describe())
```

### TypeScript
```typescript
import { parse } from 'csv-parse/sync';
import fs from 'fs';

const csvData = fs.readFileSync('population_demographics_consolidated.csv', 'utf-8');
const records = parse(csvData, { columns: true });

const data = records.map((row: any) => ({
  year: parseInt(row.Year),
  populationDensity: row.PopulationDensity === 'N/A' ? null : parseFloat(row.PopulationDensity),
  fertilityRate: row.FertilityRate === 'N/A' ? null : parseFloat(row.FertilityRate),
  // ... other fields
}));
```

## 📈 Thống kê tóm tắt (1960-2024)

| Chỉ số | 1960 | 2024 | Thay đổi |
|--------|------|------|----------|
| Dân số đô thị (%) | 14.7% | 39.2% | +24.5% |
| Fertility Rate | 6.27 | 1.94 | -4.33 |
| Median Age | 19.0 | 33.3 | +14.3 |
| Pop 0-14 (%) | 41.1% | 22.9% | -18.2% |
| Pop 65+ (%) | 4.8% | 8.1% | +3.3% |

## 🔄 Cập nhật dữ liệu

Để cập nhật dữ liệu mới:
```powershell
cd D:\project\dragon-fly-data\processdataset
.\consolidate_population_demographics.ps1
```

Script sẽ:
1. Đọc tất cả JSON files từ `rawdataset/`
2. Giải nén và đọc ZIP files nếu cần
3. Hợp nhất dữ liệu (ưu tiên JSON > ZIP)
4. Xuất ra CSV với báo cáo chất lượng

## 📝 Changelog

- **2024-11-13**: Tạo file consolidated đầu tiên từ 25 nguồn dữ liệu
  - 17 JSON files (1031 data points)
  - 8 ZIP files (0 data points - backup only)
  - Kết quả: 65 năm × 17 chỉ số = 1,105 data cells

## 📧 Liên hệ

Nếu phát hiện lỗi dữ liệu hoặc cần bổ sung chỉ số, vui lòng tạo issue tại repository.
