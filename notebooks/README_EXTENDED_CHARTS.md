# 📊 Vietnam Data Visualization - Extended Edition (25+ Chart Types)

## 🎯 Tổng quan

**Notebook mở rộng** với **25+ loại biểu đồ** chuyên nghiệp phong cách Flourish, phân tích dữ liệu phát triển Việt Nam (1960-2024).

### 📈 Thống kê
- **Total Cells**: 59 (29 markdown + 30 code)
- **Chart Types**: 25+
- **Datasets**: 8 consolidated CSVs
- **Time Range**: 1960-2024 (65 years)
- **Data Points**: 68 socioeconomic indicators

---

## 📚 Danh sách Biểu đồ (25+ Types)

### 📈 GROUP 1: LINE & AREA CHARTS (4 types)

#### 1. Line Chart (Dual-axis) ⭐ Original
**Mô tả**: Xu hướng dân số và GDP với 2 trục Y  
**Dữ liệu**: Population + Economic  
**Kỹ thuật**: `make_subplots` với `secondary_y=True`

#### 2. Line Chart with Projection 🆕 NEW
**Mô tả**: Dự báo GDP 10 năm tới bằng Linear Regression  
**Dữ liệu**: Economic (GDP historical)  
**Kỹ thuật**: sklearn LinearRegression + confidence interval  
**Highlights**: 
- Forecast 2025-2034
- 95% confidence band (shaded area)
- Growth rate projection

#### 3. Stacked Area Chart ⭐ Original
**Mô tả**: Cơ cấu dân số thành thị/nông thôn  
**Dữ liệu**: Population (Urban/Rural %)  
**Kỹ thuật**: `stackgroup='one'` với màu gradient

#### 4. Streamgraph 🆕 NEW
**Mô tả**: Diễn biến cơ cấu lao động theo ngành (Agriculture/Industry/Services)  
**Dữ liệu**: Economic (Employment by sector)  
**Kỹ thuật**: Stacked area với `groupnorm='percent'`  
**Highlights**: 
- Smooth curves
- Normalized to 100%
- Shows structural shift

---

### 📊 GROUP 2: BAR & COLUMN CHARTS (5 types)

#### 5. Horizontal Bar Chart ⭐ Original
**Mô tả**: So sánh việc làm theo ngành (latest year)  
**Dữ liệu**: Economic (Employment %)  
**Kỹ thuật**: Simple horizontal bar

#### 6. Grouped Column Chart 🆕 NEW
**Mô tả**: Tỷ lệ nhập học 3 cấp qua các thập kỷ  
**Dữ liệu**: Education (Primary/Secondary/Tertiary enrollment)  
**Kỹ thuật**: `barmode='group'` với 3 series  
**Highlights**: 
- Decades: 1970, 1980, 1990, 2000, 2010, 2020
- Color-coded by education level
- Text labels on bars

#### 7. Diverging Bar Chart 🆕 NEW
**Mô tả**: Tốc độ tăng trưởng GDP so với trung bình 20 năm  
**Dữ liệu**: Economic (GDP Growth Rate %)  
**Kỹ thuật**: Horizontal bars colored by deviation (green/red)  
**Highlights**: 
- Center line at average
- Above average = green
- Below average = red

#### 8. Waterfall Chart 🆕 NEW
**Mô tả**: Phân tích đóng góp các thành phần vào tăng trưởng GDP 2010-2020  
**Dữ liệu**: Economic (GDP components)  
**Kỹ thuật**: `go.Waterfall` với measure types  
**Highlights**: 
- Start: GDP 2010
- Contributions: Agriculture, Industry, Services, Net Exports
- End: GDP 2020
- Connector lines

#### 9. Lollipop Chart 🆕 NEW
**Mô tả**: So sánh Việt Nam vs ASEAN (5 indicators)  
**Dữ liệu**: Health + Economic (HDI, Life Expectancy, GDP/capita, Urbanization, Enrollment)  
**Kỹ thuật**: Lines + markers (ASEAN = diamond, Vietnam = circle)  
**Highlights**: 
- ASEAN average as baseline
- Vietnam relative position
- Color by performance

---

### 🥧 GROUP 3: PIE & DISTRIBUTION (4 types)

#### 10. Pie/Donut Chart ⭐ Original
**Mô tả**: Tỷ lệ nhập học các cấp (latest year)  
**Dữ liệu**: Education  
**Kỹ thuật**: `hole=0.3` for donut style

#### 11. Histogram 🆕 NEW
**Mô tả**: Phân phối tần suất tốc độ tăng trưởng GDP  
**Dữ liệu**: Economic (GDP Growth Rate)  
**Kỹ thuật**: `go.Histogram` với 15 bins  
**Highlights**: 
- Mean line (red dashed)
- Median line (green dotted)
- Statistics printed

#### 12. Box Plot ⭐ Original
**Mô tả**: Phân phối tăng trưởng GDP theo thập kỷ  
**Dữ liệu**: Economic  
**Kỹ thuật**: Grouped box plots

#### 13. Violin Plot 🆕 NEW
**Mô tả**: Phân phối tăng trưởng theo 5 giai đoạn lịch sử  
**Dữ liệu**: Economic  
**Kỹ thuật**: `go.Violin` với box + meanline  
**Highlights**: 
- Periods: War (1960-74), Reconstruction (75-85), Reform (86-99), Integration (2000-19), COVID (2020-24)
- Shows distribution shape
- Mean + median visible

---

### 🔵 GROUP 4: SCATTER & CORRELATION (2 types)

#### 14. Scatter/Bubble Chart (3D) ⭐ Original
**Mô tả**: GDP vs HDI, size=Population, color=Year  
**Dữ liệu**: Economic + Health + Population (merged)  
**Kỹ thuật**: `px.scatter` with 4 dimensions  
**Highlights**: 
- Correlation coefficient: r≈0.95
- Bubble size = population
- Color gradient by year

#### 15. Heatmap (Correlation Matrix) ⭐ Original
**Mô tả**: Ma trận tương quan 8 indicators  
**Dữ liệu**: Merged 8 datasets  
**Kỹ thuật**: `go.Heatmap` với RdBu colorscale  
**Highlights**: 
- 8×8 matrix
- Annotated values
- Top 5 correlations printed

---

### 🎯 GROUP 5: MULTI-DIMENSIONAL (3 types)

#### 16. Radar Chart ⭐ Original
**Mô tả**: So sánh đa chiều latest year vs 30 years ago  
**Dữ liệu**: 5-7 indicators normalized to 0-100  
**Kỹ thuật**: `go.Scatterpolar` với polygon fill

#### 17. Parallel Coordinates 🆕 NEW
**Mô tả**: Phân tích 7 chiều cùng lúc (Year, GDP, Growth, HDI, Life Exp, Urbanization, Population)  
**Dữ liệu**: Merged datasets (2000-2024)  
**Kỹ thuật**: `go.Parcoords` với color by year  
**Highlights**: 
- 7 parallel axes
- Color gradient (Viridis)
- Interactive filtering
- Top 3 correlations printed

#### 18. Bump Chart 🆕 NEW
**Mô tả**: Xếp hạng GDP của 5 nước ASEAN (2000-2020)  
**Dữ liệu**: Simulated ASEAN comparison  
**Kỹ thuật**: Lines with markers, y-axis reversed  
**Highlights**: 
- Rank 1 at top
- Vietnam: #5→#3 (improved 2 ranks)
- Shows competitive position changes

---

### 👥 GROUP 6: DEMOGRAPHIC (2 types)

#### 19. Population Pyramid 🆕 NEW
**Mô tả**: Cơ cấu dân số theo 7 nhóm tuổi và giới tính  
**Dữ liệu**: Population (estimated distribution)  
**Kỹ thuật**: Horizontal bars (male=negative, female=positive)  
**Highlights**: 
- Age groups: 0-14, 15-24, 25-34, 35-44, 45-54, 55-64, 65+
- Male (blue, left) vs Female (red, right)
- Gender ratio calculated

#### 20. Sunburst ⭐ Original
**Mô tả**: Phân cấp dân số (Vietnam → Urban/Rural → Male/Female)  
**Dữ liệu**: Population (hierarchical structure)  
**Kỹ thuật**: `go.Sunburst` với 3 levels

---

### 📉 GROUP 7: COMPARISON & TRENDS (2 types)

#### 21. Slope Chart 🆕 NEW
**Mô tả**: Chuyển dịch cơ cấu lao động 1990→2020  
**Dữ liệu**: Economic (Employment by sector)  
**Kỹ thuật**: Lines connecting 2 time points  
**Highlights**: 
- Start (1990) labels on left
- End (2020) labels on right
- Color by trend (green=increase, red=decrease)
- Shows structural transformation

#### 22. Cycle Plot 🆕 NEW
**Mô tả**: Mẫu hình tăng trưởng GDP theo vị trí trong thập kỷ  
**Dữ liệu**: Economic (GDP Growth by year 0-9 in each decade)  
**Kỹ thuật**: Multiple lines (one per decade) on same x-axis  
**Highlights**: 
- X-axis: Year 0-9 within decade
- 6 lines: 1960s, 70s, 80s, 90s, 2000s, 2010s
- Identifies cyclical patterns
- Most volatile decade calculated

---

### 🌳 GROUP 8: HIERARCHICAL (2 types)

#### 23. Treemap ⭐ Original
**Mô tá**: Cơ cấu kinh tế 3 cấp (Economy → GDP/Trade → Components)  
**Dữ liệu**: Economic  
**Kỹ thuật**: `px.treemap` với path hierarchy

#### 24. Sunburst ⭐ (Listed above in Demographics)

---

### 🏆 GROUP 9: ANIMATED & INTERACTIVE (2 types)

#### 25. Bar Chart Race ⭐ Original
**Mô tả**: Vietnam GDP vs World Average (animated)  
**Dữ liệu**: Economic  
**Kỹ thuật**: `px.bar` với `animation_frame`  
**Highlights**: 
- Sample every 5 years
- Frame duration: 1000ms
- Transition: 500ms

#### 26. Gauge Chart (Multiple) 🆕 NEW
**Mô tả**: Đo tiến độ đạt mục tiêu phát triển (HDI 0.75, Life Exp 80, Urbanization 50%)  
**Dữ liệu**: Health + Population  
**Kỹ thuật**: 3 gauges in subplots  
**Highlights**: 
- Color zones: Red (low), Yellow (medium), Green (high)
- Threshold lines at targets
- Delta from target shown
- % completion calculated

---

### 🔢 GROUP 10: DASHBOARDS (1 type)

#### 27. Grid of Charts (2×2 Dashboard) 🆕 NEW
**Mô tả**: 4-panel dashboard tổng quan phát triển  
**Dữ liệu**: Economic + Health + Population + Education  
**Kỹ thuật**: `make_subplots` 2 rows × 2 cols  
**Highlights**: 
- Panel 1: GDP Growth Rate (area chart)
- Panel 2: Life Expectancy (area chart)
- Panel 3: Urban Population (bar chart, sampled by decade)
- Panel 4: Primary Enrollment (line chart)
- Unified layout

---

## 🎨 Các loại biểu đồ chưa triển khai (từ danh sách Flourish)

### Map-based (Chưa có dữ liệu địa lý)
- ❌ Projection Map (World/Region maps)
- ❌ Choropleth Map
- ❌ Point/Marker Map
- ❌ 3D Map
- ❌ Connection/Arc Map

### Advanced Interactive (Yêu cầu dữ liệu đặc biệt)
- ❌ Sankey Diagram (flow data)
- ❌ Alluvial Diagram
- ❌ Network Graph
- ❌ Tournament Bracket
- ❌ Quiz/Calculator
- ❌ Photo Slider
- ❌ Interactive SVG

### Specialized Charts (Không phù hợp với dữ liệu hiện tại)
- ❌ Pictogram/Icon charts
- ❌ Sports visualizations
- ❌ Survey bars (need survey data)
- ❌ Gantt chart (need project data)
- ❌ Calendar heatmap

---

## 🚀 Cách sử dụng

### 1. Cài đặt Dependencies

```bash
pip install pandas numpy plotly matplotlib seaborn jupyter scikit-learn
```

### 2. Mở Notebook

```bash
cd d:\project\dragon-fly-data
jupyter notebook notebooks/vietnam_data_visualization.ipynb
```

### 3. Chạy Notebook

- **Run All Cells**: Kernel → Restart & Run All
- **Run Individual Chart**: Click cell → Shift+Enter
- **Explore Interactively**: Hover, zoom, pan on Plotly charts

---

## 📊 Cấu trúc Notebook

```
Cell 1: Title & Overview
Cell 2-5: Setup (imports, load 8 datasets)

[ORIGINAL CHARTS - Cells 6-29]
Cell 6-9: Line & Stacked Area
Cell 10-13: Bar & Pie
Cell 14-15: Bubble chart
Cell 16-17: Radar
Cell 18-19: Heatmap
Cell 20-21: Box plot
Cell 22-23: Bar Chart Race
Cell 24-25: Treemap
Cell 26-27: Sunburst
Cell 28-29: Summary (OLD VERSION)

[NEW CHARTS - Cells 30-59]
Cell 30-31: Line with Projection (Forecast)
Cell 32-33: Grouped Column Chart (Education decades)
Cell 34-35: Population Pyramid
Cell 36-37: Waterfall Chart (GDP components)
Cell 38-39: Diverging Bar Chart (Growth vs average)
Cell 40-41: Histogram (Growth distribution)
Cell 42-43: Lollipop Chart (Vietnam vs ASEAN)
Cell 44-45: Slope Chart (1990→2020 structure)
Cell 46-47: Streamgraph (Labor by sector)
Cell 48-49: Gauge Charts (3 targets)
Cell 50-51: Parallel Coordinates (7 dimensions)
Cell 52-53: Bump Chart (ASEAN rankings)
Cell 54-55: Grid of Charts (2×2 dashboard)
Cell 56-57: Violin Plot (Growth by period)
Cell 58-59: Cycle Plot (Decade patterns)

Cell 29 (UPDATED): Extended Summary (25+ charts)
```

---

## 🔧 Tùy chỉnh

### Thay đổi màu sắc
```python
# Trong cell của biểu đồ, tìm dòng:
marker_color='#3498db'

# Đổi thành màu khác:
marker_color='#e74c3c'  # Đỏ
marker_color='#27ae60'  # Xanh lá
marker_color='#f39c12'  # Vàng
```

### Thay đổi kích thước
```python
fig.update_layout(
    height=600,  # Thay đổi từ 500→600
    width=1000   # Thêm chiều rộng cố định
)
```

### Lọc năm
```python
# Chỉ hiển thị từ 1990 trở đi
data_filtered = data[data['Year'] >= 1990]
```

### Export biểu đồ
```python
# PNG (static image)
fig.write_image("chart.png", width=1920, height=1080)

# HTML (interactive)
fig.write_html("chart.html")

# SVG (vector)
fig.write_image("chart.svg")
```

---

## 🐛 Troubleshooting

### Lỗi: "File not found"
```bash
# Kiểm tra đường dẫn
cd d:\project\dragon-fly-data
ls processdataset/*.csv
```

### Lỗi: "Module not found"
```bash
# Cài thiếu package
pip install plotly scikit-learn
```

### Lỗi: "No data to plot"
- Một số biểu đồ cần dữ liệu cụ thể (Employment by sector, Education enrollment)
- Nếu thiếu, biểu đồ sẽ bỏ qua và in warning
- Không ảnh hưởng các biểu đồ khác

### Biểu đồ không hiển thị trong VS Code
```bash
# Cài extension Jupyter
code --install-extension ms-toolsai.jupyter

# Hoặc mở trong trình duyệt
jupyter notebook
```

---

## 📈 So sánh với Bản gốc

| Feature | Original (11 charts) | Extended (25+ charts) |
|---------|---------------------|----------------------|
| **Cells** | 29 | 59 |
| **Chart Types** | 11 | 25+ |
| **Line Charts** | 1 | 2 |
| **Bar Charts** | 2 | 5 |
| **Distribution** | 1 (Box) | 3 (Box, Histogram, Violin) |
| **Demographic** | 0 | 2 (Pyramid, Sunburst) |
| **Multi-dimensional** | 1 (Radar) | 3 (Radar, Parallel, Bump) |
| **Forecasting** | ❌ | ✅ |
| **Comparison** | Limited | Extensive (Slope, Lollipop, Diverging) |
| **Dashboards** | ❌ | ✅ (2×2 Grid) |
| **Interactive** | Basic | Advanced (Gauges, Cycle plots) |

---

## 📚 Tài liệu tham khảo

### Plotly Documentation
- [Plotly Express](https://plotly.com/python/plotly-express/)
- [Plotly Graph Objects](https://plotly.com/python/graph-objects/)
- [Subplots](https://plotly.com/python/subplots/)
- [Statistical Charts](https://plotly.com/python/statistical-charts/)

### Flourish Inspiration
- [Flourish Chart Types](https://flourish.studio/examples/)
- [Data Visualization Best Practices](https://flourish.studio/blog/)

### Data Sources
- [World Bank Open Data](https://data.worldbank.org/)
- [UNDP Human Development Reports](http://hdr.undp.org/)
- [UNESCO Institute for Statistics](http://uis.unesco.org/)

---

## ✅ Checklist trước khi chạy

- [ ] Đã cài đặt Python 3.8+
- [ ] Đã cài đặt tất cả dependencies (`pip install ...`)
- [ ] Thư mục `processdataset/` tồn tại và có 8 CSV files
- [ ] Jupyter Notebook hoặc VS Code với Jupyter extension đã cài đặt
- [ ] Đủ RAM (khuyến nghị 4GB+) cho 25+ biểu đồ

---

## 🎉 Kết luận

Notebook Extended Edition cung cấp **bộ công cụ trực quan hóa toàn diện nhất** cho dữ liệu phát triển Việt Nam, phù hợp cho:

- 📊 **Nghiên cứu học thuật**: Báo cáo, luận văn, paper
- 📈 **Phân tích chính sách**: Đánh giá tác động, dự báo
- 🎨 **Truyền thông dữ liệu**: Infographic, presentation
- 🏫 **Giáo dục**: Dạy về data visualization và phát triển kinh tế

**Total:** 25+ professional-grade interactive charts, ready to use! 🚀

---

**Phiên bản**: Extended Edition v2.0  
**Ngày cập nhật**: 2024  
**Tác giả**: Vietnam Data Story Project  
**License**: Open Source
