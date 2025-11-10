import { useState } from 'react';
import { BarChart, Bar, LineChart, Line, RadarChart, Radar, PolarGrid, PolarAngleAxis, PolarRadiusAxis, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { Sparkles, TrendingUp } from 'lucide-react';
import { useSlideAnimation } from '@/hooks/useSlideAnimation';
import { useSlideData } from '@/hooks/useSlideData';
import { ChartContainer } from '@/components/ChartContainer';
import { MILESTONE_YEARS, KEY_YEARS } from '@/constants/slideConstants';

export const SlideDataExplorer = () => {
  const containerRef = useSlideAnimation({ title: true, charts: true, cards: true });
  const { getMilestoneData, latestData } = useSlideData();
  const [activeTab, setActiveTab] = useState<'overview' | 'indicators' | 'comparison'>('overview');

  const keyYearData = getMilestoneData(KEY_YEARS);
  const latestYear = latestData.year;

  const radarData = [
    { indicator: 'HDI', value: latestData.hdi * 100, fullMark: 100 },
    { indicator: 'Đô thị', value: latestData.urbanPopPercent, fullMark: 100 },
    { indicator: 'Biết chữ', value: latestData.literacyRate, fullMark: 100 },
    { indicator: 'Tuổi thọ', value: (latestData.lifeExpectancy / 90) * 100, fullMark: 100 },
    { indicator: 'Giáo dục', value: latestData.educationIndex * 100, fullMark: 100 },
  ];

  const comparisonData = keyYearData.map((d) => ({
    year: d.year.toString(),
    population: Math.round(d.population / 1000000),
    gdp: Math.round(d.gdpBillion),
    hdi: (d.hdi * 100).toFixed(0),
    literacy: d.literacyRate,
  }));

  const tabs = [
    { id: 'overview', label: 'Tổng Quan', icon: '📊' },
    { id: 'indicators', label: 'Chỉ Số Phát Triển', icon: '📈' },
    { id: 'comparison', label: 'So Sánh Thập Kỷ', icon: '🔄' },
  ];

  return (
    <div ref={containerRef} className="min-h-screen py-20 px-6 relative overflow-hidden bg-gradient-to-br from-background via-secondary/5 to-accent/5">
      <div className="max-w-7xl mx-auto relative z-10">
        <div className="text-center mb-12">
          <Sparkles className="slide-title w-16 h-16 text-primary mx-auto mb-6 animate-pulse" />
          <h2 className="slide-title font-display text-5xl md:text-6xl font-bold mb-4">
            Khám Phá Dữ Liệu: <span className="text-secondary dragon-glow">Các Góc Nhìn Khác Nhau</span>
          </h2>
          <p className="slide-title text-xl text-muted-foreground">Phân tích đa chiều phát triển Việt Nam</p>
        </div>

        {/* Tab Navigation */}
        <div className="flex flex-wrap gap-3 justify-center mb-8 bg-card/30 backdrop-blur-sm p-4 rounded-2xl border border-border w-fit mx-auto">
          {tabs.map((tab) => (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id as any)}
              className={`px-6 py-3 rounded-xl font-semibold transition-all duration-300 flex items-center gap-2 ${
                activeTab === tab.id
                  ? 'bg-primary text-primary-foreground shadow-elegant scale-105'
                  : 'bg-background/50 text-muted-foreground hover:bg-background border border-border'
              }`}
            >
              <span>{tab.icon}</span>
              {tab.label}
            </button>
          ))}
        </div>

        {/* Tab Content */}
        {activeTab === 'overview' && (
          <div className="space-y-8">
            <ChartContainer
              id="overview-population-gdp"
              title="Dân Số & GDP - Mối Liên Hệ"
              data={keyYearData}
              filename="data-overview"
              className="slide-chart"
            >
              <ResponsiveContainer width="100%" height={350}>
                <BarChart data={comparisonData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
                  <XAxis dataKey="year" stroke="hsl(var(--muted-foreground))" />
                  <YAxis yAxisId="left" stroke="hsl(var(--primary))" />
                  <YAxis yAxisId="right" orientation="right" stroke="hsl(var(--secondary))" />
                  <Tooltip
                    contentStyle={{
                      backgroundColor: 'hsl(var(--card))',
                      border: '1px solid hsl(var(--border))',
                      borderRadius: '8px',
                    }}
                  />
                  <Legend />
                  <Bar yAxisId="left" dataKey="population" fill="hsl(var(--primary))" name="Dân số (triệu)" />
                  <Bar yAxisId="right" dataKey="gdp" fill="hsl(var(--secondary))" name="GDP ($B)" />
                </BarChart>
              </ResponsiveContainer>
            </ChartContainer>

            <ChartContainer
              id="overview-literacy-life"
              title="Giáo Dục & Sức Khỏe"
              data={keyYearData}
              filename="education-health"
              className="slide-chart"
            >
              <ResponsiveContainer width="100%" height={350}>
                <LineChart data={comparisonData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
                  <XAxis dataKey="year" stroke="hsl(var(--muted-foreground))" />
                  <YAxis yAxisId="left" stroke="hsl(var(--accent))" />
                  <YAxis yAxisId="right" orientation="right" stroke="hsl(var(--primary))" />
                  <Tooltip
                    contentStyle={{
                      backgroundColor: 'hsl(var(--card))',
                      border: '1px solid hsl(var(--border))',
                      borderRadius: '8px',
                    }}
                  />
                  <Legend />
                  <Line
                    yAxisId="left"
                    type="monotone"
                    dataKey="literacy"
                    stroke="hsl(var(--accent))"
                    strokeWidth={3}
                    name="Tỷ lệ biết chữ (%)"
                  />
                  <Line
                    yAxisId="right"
                    type="monotone"
                    dataKey="hdi"
                    stroke="hsl(var(--primary))"
                    strokeWidth={3}
                    name="HDI"
                  />
                </LineChart>
              </ResponsiveContainer>
            </ChartContainer>
          </div>
        )}

        {activeTab === 'indicators' && (
          <div className="space-y-8">
            <ChartContainer
              id="indicators-radar"
              title={`Chỉ Số Phát Triển Năm ${latestYear}`}
              className="slide-chart"
              showExport={false}
            >
              <ResponsiveContainer width="100%" height={400}>
                <RadarChart data={radarData}>
                  <PolarGrid stroke="hsl(var(--border))" />
                  <PolarAngleAxis dataKey="indicator" stroke="hsl(var(--muted-foreground))" />
                  <PolarRadiusAxis angle={90} domain={[0, 100]} stroke="hsl(var(--muted-foreground))" />
                  <Radar
                    name="Phát triển"
                    dataKey="value"
                    stroke="hsl(var(--primary))"
                    fill="hsl(var(--primary) / 0.5)"
                    strokeWidth={2}
                  />
                  <Tooltip
                    contentStyle={{
                      backgroundColor: 'hsl(var(--card))',
                      border: '1px solid hsl(var(--border))',
                      borderRadius: '8px',
                    }}
                  />
                </RadarChart>
              </ResponsiveContainer>
            </ChartContainer>

            <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
              <div className="slide-card bg-gradient-to-br from-primary/20 to-primary/5 p-6 rounded-xl border border-primary/30">
                <div className="text-sm text-muted-foreground mb-2">HDI</div>
                <div className="text-3xl font-bold text-primary">{(latestData.hdi * 100).toFixed(1)}%</div>
                <div className="text-xs text-muted-foreground">Chỉ số phát triển con người</div>
              </div>

              <div className="slide-card bg-gradient-to-br from-secondary/20 to-secondary/5 p-6 rounded-xl border border-secondary/30">
                <div className="text-sm text-muted-foreground mb-2">TUỔI THỌ</div>
                <div className="text-3xl font-bold text-secondary">{latestData.lifeExpectancy}</div>
                <div className="text-xs text-muted-foreground">Năm (năm 2024)</div>
              </div>

              <div className="slide-card bg-gradient-to-br from-accent/20 to-accent/5 p-6 rounded-xl border border-accent/30">
                <div className="text-sm text-muted-foreground mb-2">GIÁO DỤC</div>
                <div className="text-3xl font-bold text-accent">{(latestData.educationIndex * 100).toFixed(1)}%</div>
                <div className="text-xs text-muted-foreground">Chỉ số giáo dục</div>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'comparison' && (
          <div className="space-y-8">
            <ChartContainer
              id="comparison-trends"
              title="Xu Hướng Qua Các Thập Kỷ"
              data={keyYearData}
              filename="thap-ky-comparison"
              className="slide-chart"
            >
              <ResponsiveContainer width="100%" height={400}>
                <LineChart data={comparisonData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
                  <XAxis dataKey="year" stroke="hsl(var(--muted-foreground))" />
                  <YAxis yAxisId="left" stroke="hsl(var(--primary))" />
                  <YAxis yAxisId="right" orientation="right" stroke="hsl(var(--secondary))" />
                  <Tooltip
                    contentStyle={{
                      backgroundColor: 'hsl(var(--card))',
                      border: '1px solid hsl(var(--border))',
                      borderRadius: '8px',
                    }}
                  />
                  <Legend />
                  <Line
                    yAxisId="left"
                    type="monotone"
                    dataKey="population"
                    stroke="hsl(var(--primary))"
                    strokeWidth={3}
                    dot={{ fill: 'hsl(var(--primary))', r: 6 }}
                    name="Dân số (triệu)"
                  />
                  <Line
                    yAxisId="right"
                    type="monotone"
                    dataKey="gdp"
                    stroke="hsl(var(--secondary))"
                    strokeWidth={3}
                    dot={{ fill: 'hsl(var(--secondary))', r: 6 }}
                    name="GDP ($B)"
                  />
                </LineChart>
              </ResponsiveContainer>
            </ChartContainer>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="slide-card bg-card/50 backdrop-blur-sm p-6 rounded-xl border border-border">
                <h4 className="font-bold mb-4 text-primary">Dân Số Qua Thập Kỷ</h4>
                <div className="space-y-2">
                  {keyYearData.map((d) => (
                    <div key={d.year} className="flex justify-between items-center pb-2 border-b border-border/50">
                      <span className="text-sm font-medium">{d.year}</span>
                      <span className="font-bold text-primary">{(d.population / 1000000).toFixed(1)}M</span>
                    </div>
                  ))}
                </div>
              </div>

              <div className="slide-card bg-card/50 backdrop-blur-sm p-6 rounded-xl border border-border">
                <h4 className="font-bold mb-4 text-secondary">GDP Qua Thập Kỷ</h4>
                <div className="space-y-2">
                  {keyYearData.map((d) => (
                    <div key={d.year} className="flex justify-between items-center pb-2 border-b border-border/50">
                      <span className="text-sm font-medium">{d.year}</span>
                      <span className="font-bold text-secondary">${d.gdpBillion}B</span>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          </div>
        )}

        {/* Analysis */}
        <div className="mt-12 bg-gradient-to-r from-primary/10 via-secondary/10 to-accent/10 backdrop-blur-sm p-8 rounded-2xl border border-primary/30">
          <div className="flex items-start gap-4">
            <TrendingUp className="w-8 h-8 text-primary flex-shrink-0 mt-1" />
            <div>
              <h3 className="text-2xl font-bold mb-3 text-primary">Những Khám Phá Chính</h3>
              <p className="text-lg text-muted-foreground leading-relaxed">
                Dữ liệu Việt Nam từ 1955 đến 2024 cho thấy sự phát triển toàn diện: dân số tăng gấp 3.6 lần, GDP tăng gấp hơn 200 lần,
                tỷ lệ biết chữ từ ~15% lên trên 95%, và tuổi thọ tăng từ 35 lên 73 tuổi. Đây là những số liệu minh chứng cho sự hành động
                quyết liệt của Việt Nam trong phát triển kinh tế xã hội và nâng cao chất lượng cuộc sống nhân dân.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
