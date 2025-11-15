# Economic Data Consolidated Dataset

## 📊 Tổng quan

File CSV này tổng hợp **14 chỉ số kinh tế** của Việt Nam từ năm **1970-2024** (55 năm), được trích xuất từ ~15 file nguồn khác nhau từ World Bank API.

## 📁 Thông tin file

- **Tên file**: `economic_consolidated.csv`
- **Số dòng**: 55 năm (1970-2024)
- **Số cột**: 15 cột (1 cột Year + 14 chỉ số)
- **Định dạng**: UTF-8 CSV
- **Tỷ lệ dữ liệu hợp lệ**: ~66% (trung bình)

## 📋 Danh sách các cột

### 1. Year
- **Kiểu dữ liệu**: Integer
- **Khoảng giá trị**: 1970-2024
- **Mô tả**: Năm của dữ liệu

### 2. GDP Indicators (4 chỉ số)

| Cột | Đơn vị | Mô tả | Fill Rate |
|-----|--------|-------|-----------|
| `GDPTotalBillion` | tỷ USD | Tổng GDP theo giá hiện hành | 72.7% |
| `GDPPerCapita` | USD | GDP bình quân đầu người | 72.7% |
| `GDPPPPBillion` | tỷ USD PPP | GDP theo sức mua tương đương | 63.6% |
| `GDPGrowthRate` | % | Tốc độ tăng trưởng GDP thực | 72.7% |

**Ghi chú**: 
- GDP data bắt đầu từ 1985 (Đổi Mới 1986)
- GDP 1985: $14.1B → 2024: $476.4B (tăng 33.8 lần)
- GDP per capita 1985: $239 → 2024: $4,717 (tăng 19.7 lần)

### 3. GNI Indicators (4 chỉ số)

| Cột | Đơn vị | Mô tả | Fill Rate |
|-----|--------|-------|-----------|
| `GNIBillion` | tỷ USD | Tổng thu nhập quốc dân | 65.5% |
| `GNIPerCapita` | USD | GNI bình quân đầu người | 65.5% |
| `GNIPerCapitaPPP` | USD PPP | GNI per capita theo PPP | 63.6% |
| `AdjustedNNIPerCapita` | USD | Thu nhập quốc dân ròng điều chỉnh | 60.0% |

**Ghi chú**: GNI thường gần bằng GDP, nhưng tính thêm thu nhập ròng từ nước ngoài

### 4. Inflation (1 chỉ số)

| Cột | Đơn vị | Mô tả | Fill Rate |
|-----|--------|-------|-----------|
| `InflationRate` | % | Tỷ lệ lạm phát (CPI) | 40.0% ⚠️ |

**Ghi chú**: Dữ liệu lạm phát bị thiếu nhiều năm (1970-1990s)

### 5. Trade Indicators (3 chỉ số)

| Cột | Đơn vị | Mô tả | Fill Rate |
|-----|--------|-------|-----------|
| `ExportsPercentGDP` | % | Xuất khẩu (% GDP) | 69.1% |
| `ImportsPercentGDP` | % | Nhập khẩu (% GDP) | 69.1% |
| `TradeBalance` | % | Cán cân thương mại (Export - Import) | 69.1% |

**Ghi chú**: 
- TradeBalance được tính tự động từ Exports - Imports
- Giá trị âm = nhập khẩu > xuất khẩu (thâm hụt thương mại)
- Giá trị dương = xuất khẩu > nhập khẩu (thặng dư thương mại)

### 6. Investment (1 chỉ số)

| Cột | Đơn vị | Mô tả | Fill Rate |
|-----|--------|-------|-----------|
| `FDINetInflowsMillion` | triệu USD | Vốn đầu tư nước ngoài ròng (FDI) | 100% ✅ |

**Ghi chú**: Chỉ số duy nhất có 100% fill rate (1970-2024)

### 7. Labor Market (1 chỉ số)

| Cột | Đơn vị | Mô tả | Fill Rate |
|-----|--------|-------|-----------|
| `UnemploymentRate` | % | Tỷ lệ thất nghiệp | 61.8% |

**Ghi chú**: Dữ liệu thất nghiệp có từ những năm 1990s

## 🔍 Nguồn dữ liệu

### JSON Files (13 files)
```
wb_gdp_total.json                → GDPTotalBillion (40 năm: 1985-2024)
wb_gdp_per_capita.json           → GDPPerCapita (40 năm)
wb_gdp_ppp.json                  → GDPPPPBillion (35 năm: 1990-2024)
wb_gdp_growth.json               → GDPGrowthRate (40 năm)

wb_gni.json                      → GNIBillion (36 năm: 1989-2024)
wb_NY_GNP_PCAP_CD.json           → GNIPerCapita (36 năm)
wb_NY_GNP_PCAP_PP_CD.json        → GNIPerCapitaPPP (35 năm)
wb_NY_ADJ_NNTY_PC_CD.json        → AdjustedNNIPerCapita (33 năm: 1992-2024)

wb_inflation.json                → InflationRate (22 năm)
wb_exports_gdp.json              → ExportsPercentGDP (38 năm: 1986-2023)
wb_imports_gdp.json              → ImportsPercentGDP (38 năm)

wb_fdi.json                      → FDINetInflowsMillion (55 năm: 1970-2024) ✅
wb_fdi_processed.json            → FDINetInflowsMillion (backup)

wb_ilo_unemployment.json         → UnemploymentRate (34 năm: 1991-2024)
```

### ZIP Files (2 files - empty/backup)
```
gdp_growth.zip                   → GDPGrowthRate (backup - empty)
unemployment.zip                 → UnemploymentRate (backup - empty)
```

## ⚠️ Lưu ý về chất lượng dữ liệu

### Dữ liệu thiếu nhiều (Low Fill Rate)
- **InflationRate**: 40% - thiếu dữ liệu những năm 1970-1990
- **AdjustedNNIPerCapita**: 60% - chỉ có từ 1992

### Dữ liệu tốt (Good Fill Rate)
- **FDINetInflowsMillion**: 100% ✅ - duy nhất có đầy đủ 55 năm
- **GDP/GNI indicators**: ~65-73% - có từ 1985-1989 trở đi
- **Trade indicators**: ~69% - có từ 1986 (Đổi Mới)

### Giá trị "N/A"
- Các giá trị thiếu được đánh dấu là `"N/A"` trong CSV
- Khi import, cần xử lý: `value === "N/A" ? null : parseFloat(value)`

### Giai đoạn dữ liệu

**1970-1984 (Pre-Đổi Mới)**
- Chỉ có FDI data (rất thấp, gần 0)
- GDP, GNI, Trade data không có (kinh tế kế hoạch hóa tập trung)

**1985-1991 (Đổi Mới sớm)**
- GDP bắt đầu có (1985)
- Trade data bắt đầu có (1986)
- FDI tăng dần
- Lạm phát cao (hyperinflation 1986-1989)

**1992-2024 (Kinh tế thị trường)**
- Đầy đủ hầu hết các chỉ số
- Tăng trưởng ổn định 6-7%/năm
- Hội nhập quốc tế (WTO 2007)

## 🔧 Cách sử dụng

### PowerShell
```powershell
$data = Import-Csv "economic_consolidated.csv"

# Filter dữ liệu có GDP
$validData = $data | Where-Object { $_.GDPTotalBillion -ne "N/A" }

# So sánh GDP 1985 vs 2024
$first = $validData | Select-Object -First 1
$last = $validData | Select-Object -Last 1

Write-Host "GDP 1985: $($first.GDPTotalBillion) tỷ USD"
Write-Host "GDP 2024: $($last.GDPTotalBillion) tỷ USD"
Write-Host "Tăng: $([math]::Round($last.GDPTotalBillion / $first.GDPTotalBillion, 1))x"
```

### Python (pandas)
```python
import pandas as pd
import numpy as np

df = pd.read_csv('economic_consolidated.csv')
df = df.replace('N/A', np.nan)

# Convert to numeric
numeric_cols = ['GDPTotalBillion', 'GDPPerCapita', 'GDPGrowthRate', 
                'FDINetInflowsMillion', 'UnemploymentRate']
df[numeric_cols] = df[numeric_cols].apply(pd.to_numeric)

# Calculate average GDP growth since Doi Moi
doi_moi = df[df['Year'] >= 1986]
avg_growth = doi_moi['GDPGrowthRate'].mean()
print(f"Average GDP Growth (1986-2024): {avg_growth:.2f}%")

# Visualize trade balance
import matplotlib.pyplot as plt
plt.plot(df['Year'], df['TradeBalance'])
plt.axhline(y=0, color='r', linestyle='--')
plt.title('Vietnam Trade Balance (% GDP)')
plt.show()
```

### TypeScript
```typescript
import { parse } from 'csv-parse/sync';
import fs from 'fs';

const csvData = fs.readFileSync('economic_consolidated.csv', 'utf-8');
const records = parse(csvData, { columns: true });

interface EconomicData {
  year: number;
  gdpTotal: number | null;
  gdpPerCapita: number | null;
  gdpGrowth: number | null;
  fdi: number | null;
}

const data: EconomicData[] = records.map((row: any) => ({
  year: parseInt(row.Year),
  gdpTotal: row.GDPTotalBillion === 'N/A' ? null : parseFloat(row.GDPTotalBillion),
  gdpPerCapita: row.GDPPerCapita === 'N/A' ? null : parseFloat(row.GDPPerCapita),
  gdpGrowth: row.GDPGrowthRate === 'N/A' ? null : parseFloat(row.GDPGrowthRate),
  fdi: row.FDINetInflowsMillion === 'N/A' ? null : parseFloat(row.FDINetInflowsMillion),
}));

// Calculate compound annual growth rate (CAGR)
const first = data.find(d => d.gdpTotal !== null);
const last = data[data.length - 1];
const years = last.year - first.year;
const cagr = (Math.pow(last.gdpTotal / first.gdpTotal, 1/years) - 1) * 100;
console.log(`GDP CAGR (${first.year}-${last.year}): ${cagr.toFixed(2)}%`);
```

## 📈 Thống kê nổi bật (1985-2024)

| Chỉ số | 1985 | 2024 | Thay đổi | CAGR |
|--------|------|------|----------|------|
| GDP Total | $14.1B | $476.4B | +33.8x | 9.4% |
| GDP per Capita | $239 | $4,717 | +19.7x | 7.9% |
| FDI Net Inflows | -$0.08M | $19,324M | - | - |
| Exports (% GDP) | ~10% | ~95% | +85pp | - |
| Imports (% GDP) | ~15% | ~85% | +70pp | - |

**Ghi chú**:
- CAGR = Compound Annual Growth Rate (tốc độ tăng trưởng kép hàng năm)
- pp = percentage points (điểm phần trăm)

## 💡 Phân tích insights

### 1. Kỳ tích tăng trưởng
- GDP tăng 33.8 lần trong 39 năm (1985-2024)
- Duy trì tăng trưởng 6-7%/năm gần như liên tục
- Chỉ giảm tốc trong khủng hoảng 2008-2009 và COVID 2020-2021

### 2. Hội nhập kinh tế
- Tỷ trọng xuất khẩu tăng từ ~10% lên ~95% GDP
- FDI tăng từ gần 0 lên >$19B/năm
- Việt Nam trở thành nền kinh tế mở

### 3. Chuyển đổi cơ cấu
- Từ kinh tế kế hoạch hóa → kinh tế thị trường (1986)
- Từ nông nghiệp → công nghiệp và dịch vụ
- Thu nhập bình quân tăng 19.7 lần

### 4. Thách thức còn lại
- Lạm phát chưa ổn định hoàn toàn
- Thất nghiệp vẫn còn (2-3%)
- Cần tăng năng suất lao động để thoát bẫy thu nhập trung bình

## 🔄 Cập nhật dữ liệu

Để cập nhật dữ liệu mới:
```powershell
cd D:\project\dragon-fly-data\processdataset
.\consolidate_economic_data.ps1
```

Script sẽ:
1. Đọc 13 JSON files từ `rawdataset/`
2. Parse World Bank API format `[metadata, data_array]`
3. Hợp nhất dữ liệu từ nhiều nguồn
4. Tính toán TradeBalance tự động
5. Làm tròn số cho dễ đọc
6. Xuất ra CSV với báo cáo chất lượng

## 📝 Changelog

- **2024-11-13**: Tạo file consolidated đầu tiên
  - 13 JSON files (482 data points)
  - 2 ZIP files (backup, không dùng)
  - Kết quả: 55 năm × 14 chỉ số = 770 data cells
  - Fill rate: 66% trung bình

## 📧 Liên hệ

Nếu phát hiện lỗi dữ liệu hoặc cần bổ sung chỉ số, vui lòng tạo issue tại repository.
