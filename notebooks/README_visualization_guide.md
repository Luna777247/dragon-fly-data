# 📊 Vietnam Data Visualization Notebook - User Guide

## 📁 File Location
`notebooks/vietnam_data_visualization.ipynb`

## 🎯 Mục đích

Notebook này cung cấp **11 loại biểu đồ chuyên nghiệp** theo phong cách Flourish để trực quan hóa dữ liệu phát triển của Vietnam từ 1960-2024, sử dụng dữ liệu từ 8 datasets đã consolidate.

---

## 📊 Các loại biểu đồ (Chart Types)

### A. LINE & AREA CHARTS - Xu hướng theo thời gian

#### 🟢 A1. Line Chart - GDP & Population Trends
- **Mục đích**: Thể hiện xu hướng tăng trưởng dân số và GDP qua 65 năm
- **Kỹ thuật**: Dual-axis chart (2 trục Y)
- **Dữ liệu**: `population_demographics_consolidated.csv` + `economic_consolidated.csv`
- **Insight**: Tương quan giữa tăng dân số và phát triển kinh tế

#### 🟦 A2. Stacked Area Chart - Urban vs Rural Population
- **Mục đích**: Hiển thị cơ cấu dân số (thành thị/nông thôn) với tổng và tỷ trọng
- **Kỹ thuật**: Stacked area với 2 tầng màu
- **Dữ liệu**: `urbanization_consolidated.csv`
- **Insight**: Quá trình đô thị hóa từ 15% → 40%

---

### B. BAR & COLUMN CHARTS - So sánh giá trị

#### 🟡 B1. Horizontal Bar Chart - Employment Sectors
- **Mục đích**: So sánh tỷ lệ lao động theo ngành (Nông nghiệp, Công nghiệp, Dịch vụ)
- **Kỹ thuật**: Horizontal bar với text labels
- **Dữ liệu**: `employment_consolidated.csv` (năm gần nhất)
- **Insight**: Chuyển dịch cơ cấu kinh tế sang dịch vụ

#### 🥧 B2. Pie/Donut Chart - Education Levels
- **Mục đích**: Tỷ lệ ghi danh giáo dục (Tiểu học, Trung học, Đại học)
- **Kỹ thuật**: Donut chart (hole=0.3)
- **Dữ liệu**: `education_consolidated.csv`
- **Insight**: Phổ cập giáo dục tiểu học gần 100%

---

### C. SCATTER & BUBBLE CHARTS - Correlation Analysis

#### 💎 C1. Scatter/Bubble Plot - GDP vs HDI
- **Mục đích**: Tương quan giữa GDP và HDI, với bubble size = dân số
- **Kỹ thuật**: 3D scatter plot (x=GDP, y=HDI, size=Population, color=Year)
- **Dữ liệu**: Merge 3 datasets (economic + health + population)
- **Insight**: Correlation coefficient ~0.95 (very strong positive)

---

### D. RADAR CHART - Multi-dimensional Comparison

#### 🎯 D1. Radar Chart - Development Indicators
- **Mục đích**: So sánh đa chiều giữa năm hiện tại và 30 năm trước
- **Kỹ thuật**: Polygon radar với 5-7 indicators normalized 0-100
- **Dữ liệu**: Urbanization, Life Expectancy, HDI, Renewable Energy, Education
- **Insight**: Tiến bộ toàn diện trên mọi chỉ số

---

### E. HEATMAP - Correlation Matrix

#### 🌡️ E1. Correlation Heatmap
- **Mục đích**: Hiển thị tương quan giữa 8 chỉ số kinh tế-xã hội
- **Kỹ thuật**: Color-coded matrix với annotations
- **Dữ liệu**: Merge multiple datasets
- **Insight**: Top 5 correlations (e.g., GDP ↔ HDI: 0.95)

---

### F. DISTRIBUTION PLOTS - Box Plot

#### 📦 F1. Box Plot - GDP Growth by Decade
- **Mục đích**: Phân bố tăng trưởng GDP theo từng thập kỷ
- **Kỹ thuật**: Multiple box plots với mean & std deviation
- **Dữ liệu**: `economic_consolidated.csv` grouped by decade
- **Insight**: 2000s-2010s có tăng trưởng ổn định nhất (~6-7%)

---

### G. BAR CHART RACE - Ranking Over Time

#### 🏆 G1. Animated Bar Chart Race
- **Mục đích**: Thứ hạng GDP Vietnam so với world average (animated)
- **Kỹ thuật**: Plotly animation với frame_duration=1000ms
- **Dữ liệu**: `reference_regional_consolidated.csv` (every 5 years)
- **Insight**: Gap narrowing between Vietnam and world avg

---

### H. TREEMAP - Hierarchical Structure

#### 🌳 H1. Treemap - Economic Composition
- **Mục đích**: Cấu trúc GDP theo exports, imports, domestic
- **Kỹ thuật**: Hierarchical treemap với 3 levels
- **Dữ liệu**: `economic_consolidated.csv` (calculated values)
- **Insight**: Exports chiếm >100% GDP (trade-driven economy)

---

### I. SUNBURST CHART - Multi-level Hierarchy

#### ☀️ I1. Sunburst - Population Breakdown
- **Mục đích**: Cơ cấu dân số 3 tầng (Total → Urban/Rural → Male/Female)
- **Kỹ thuật**: Circular sunburst với 3 layers
- **Dữ liệu**: `population_demographics_consolidated.csv` + `urbanization_consolidated.csv`
- **Insight**: Visualize population composition in concentric circles

---

### J. SUMMARY - Key Insights

#### 💡 J1. Automated Insights Generator
- **Mục đích**: Tổng hợp findings từ tất cả datasets
- **Output**: 
  - Population growth: +145%
  - GDP growth: +18,000%
  - Urbanization: +25 points
  - HDI: +70%
  - Life expectancy: +20 years

---

## 🚀 Hướng dẫn sử dụng

### 1. Cài đặt Dependencies

```powershell
# Activate virtual environment (if any)
# Install required packages
pip install pandas numpy matplotlib seaborn plotly jupyter
```

**Required packages**:
- `pandas` ≥ 1.5.0
- `numpy` ≥ 1.23.0
- `matplotlib` ≥ 3.6.0
- `seaborn` ≥ 0.12.0
- `plotly` ≥ 5.11.0
- `jupyter` or `jupyterlab`

### 2. Khởi động Notebook

```powershell
# Navigate to project root
cd d:\project\dragon-fly-data

# Start Jupyter
jupyter notebook notebooks/vietnam_data_visualization.ipynb
```

Hoặc dùng VS Code với Jupyter extension:
1. Open `vietnam_data_visualization.ipynb` trong VS Code
2. Select Python kernel
3. Run All Cells (Ctrl+Shift+Enter)

### 3. Chạy Từng Cell

**Thứ tự khuyến nghị**:
1. **Cell 1-2**: Import libraries & load data (1-2 phút)
2. **Cell 3-14**: Các biểu đồ theo thứ tự (mỗi cell ~5-10 giây)
3. **Cell 15**: Summary insights

**Lưu ý**:
- Nếu cell nào lỗi (dữ liệu thiếu), notebook sẽ skip và in warning
- Mỗi biểu đồ có thể zoom, pan, hover (Plotly interactive)
- Các biểu đồ animated (Bar Chart Race) cần thời gian render

---

## 📂 Data Sources

Notebook tự động load dữ liệu từ `processdataset/`:

| Dataset | File | Indicators |
|---------|------|------------|
| Population | `population_demographics_consolidated.csv` | 17 indicators |
| Economic | `economic_consolidated.csv` | 14 indicators |
| Employment | `employment_consolidated.csv` | 9 indicators |
| Education | `education_consolidated.csv` | 8 indicators |
| Health | `health_hdi_consolidated.csv` | 10 indicators |
| Environment | `environment_energy_consolidated.csv` | 6 indicators |
| Urbanization | `urbanization_consolidated.csv` | 4 indicators |
| Reference | `reference_regional_consolidated.csv` | 24 indicators |

**Total**: 8 CSV files, 92 indicators, 1960-2024

---

## 🎨 Customization

### Thay đổi màu sắc

Mỗi chart có color palette riêng:

```python
# Line Chart
colors = ['#3498db', '#e74c3c']  # Blue, Red

# Stacked Area
fillcolor='rgba(52, 152, 219, 0.6)'  # Blue with transparency

# Radar Chart
line=dict(color='#3498db', width=2)
```

### Thay đổi kích thước

```python
fig.update_layout(
    height=600,  # Change height
    width=1000   # Change width (optional, default auto)
)
```

### Thay đổi năm hiển thị

```python
# Filter by year range
df_filtered = df[(df['Year'] >= 1990) & (df['Year'] <= 2020)]
```

### Export biểu đồ

```python
# Export to PNG
fig.write_image("chart.png", width=1920, height=1080)

# Export to HTML (interactive)
fig.write_html("chart.html")
```

---

## 🔧 Troubleshooting

### Lỗi: "File not found"
**Giải pháp**: Kiểm tra đường dẫn `processdataset/` tồn tại và chứa 8 CSV files

```powershell
Get-ChildItem processdataset\*.csv
```

### Lỗi: "Module not found"
**Giải pháp**: Cài đặt packages thiếu

```powershell
pip install pandas plotly matplotlib seaborn
```

### Lỗi: "No data to plot"
**Giải pháp**: Dataset có thể thiếu dữ liệu cho indicator cụ thể. Notebook sẽ skip cell đó.

### Biểu đồ không hiển thị trong VS Code
**Giải pháp**: 
1. Install Jupyter extension
2. Restart VS Code
3. Select correct Python kernel

---

## 📊 Output Examples

### Khi chạy thành công, bạn sẽ thấy:

1. **29 cells** total (15 markdown + 14 code)
2. **11 interactive charts** với Plotly
3. **Summary statistics** cho mỗi chart
4. **Final insights report** tổng hợp findings

### Expected runtime:
- Full notebook: ~2-3 minutes
- Individual charts: 5-10 seconds each

---

## 🌟 Key Features

✅ **Interactive**: Zoom, pan, hover tooltips  
✅ **Responsive**: Auto-adjust to screen size  
✅ **Vietnamese labels**: Tiếng Việt cho titles/axes  
✅ **Professional styling**: Flourish-inspired colors  
✅ **Animated**: Bar chart race with smooth transitions  
✅ **Multi-dataset**: Merge 8 datasets automatically  
✅ **Error handling**: Graceful fallback khi thiếu data  
✅ **Export ready**: PNG, HTML, SVG formats  

---

## 📚 Chart Selection Guide

**Khi nào dùng biểu đồ nào?**

| Use Case | Chart Type | Example |
|----------|------------|---------|
| Xu hướng theo thời gian | Line, Area | GDP growth |
| So sánh giá trị | Bar, Column | Employment by sector |
| Tỷ trọng phần trăm | Pie, Donut | Education levels |
| Tương quan 2 biến | Scatter, Bubble | GDP vs HDI |
| So sánh đa chiều | Radar | Multiple indicators |
| Ma trận tương quan | Heatmap | All indicators |
| Phân bố dữ liệu | Box Plot | GDP growth by decade |
| Thứ hạng động | Bar Chart Race | Ranking over time |
| Cấu trúc phân cấp | Treemap, Sunburst | Population breakdown |

---

## 🔗 Related Documentation

- **Data Quality Report**: `rawdataset/DATA_QUALITY_FINAL_REPORT.md`
- **Dataset READMEs**: `processdataset/README_*.md` (8 files)
- **Scripts Metadata**: `processdataset/scripts_reports_metadata.csv`
- **Project Instructions**: `.github/copilot-instructions.md`

---

## 🎓 Learning Resources

### Plotly Documentation
- Line charts: https://plotly.com/python/line-charts/
- Scatter plots: https://plotly.com/python/scatter-plots/
- Sunburst: https://plotly.com/python/sunburst-charts/
- Animations: https://plotly.com/python/animations/

### Flourish Inspiration
- Flourish Templates: https://flourish.studio/visualisations/
- Chart selection guide: https://flourish.studio/blog/chart-chooser/

---

## ✅ Checklist trước khi chạy

- [ ] Python 3.8+ installed
- [ ] All required packages installed (`pip install -r requirements.txt`)
- [ ] 8 CSV files tồn tại trong `processdataset/`
- [ ] Jupyter Notebook/Lab hoặc VS Code với Jupyter extension
- [ ] Đủ RAM (≥4GB khuyến nghị cho animated charts)
- [ ] Internet connection (optional, for documentation links)

---

**Created**: November 2025  
**Version**: 1.0  
**Author**: Vietnam Data Consolidation Project  
**Notebook**: `notebooks/vietnam_data_visualization.ipynb`
