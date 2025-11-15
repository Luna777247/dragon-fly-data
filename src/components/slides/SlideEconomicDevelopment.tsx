import { useState, useMemo } from 'react';
import { DollarSign, Briefcase, TrendingUp } from 'lucide-react';
import { LineChart, Line, AreaChart, Area, ComposedChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { useSlideAnimation } from '@/hooks/useSlideAnimation';
import { useSlideData } from '@/hooks/useSlideData';
import { ChartContainer } from '@/components/ChartContainer';
import { FullscreenChart } from '@/components/FullscreenChart';
import { MILESTONE_YEARS } from '@/constants/slideConstants';

export const SlideEconomicDevelopment = () => {
  const containerRef = useSlideAnimation({ title: true, charts: true, cards: true });
  const { allData, latestData, earliestData } = useSlideData();
  const [fullscreenChart, setFullscreenChart] = useState<string | null>(null);

  const economyData = useMemo(() => allData, [allData]);
  const employmentData = useMemo(() => allData.map((d) => ({
    year: d.year,
    agriculture: d.employmentAgriculture || 0,
    industry: d.employmentIndustry || 0,
    services: d.employmentServices || 0,
  })), [allData]);

  return (
    <div ref={containerRef} className="min-h-screen py-20 px-6 relative overflow-hidden bg-gradient-to-br from-background via-secondary/5 to-primary/10">
      <div className="max-w-7xl mx-auto relative z-10">
        <div className="text-center mb-12">
          <DollarSign className="slide-title w-16 h-16 text-primary mx-auto mb-6 animate-pulse" />
          <h2 className="slide-title font-display text-5xl md:text-6xl font-bold mb-4">
            Cánh Kinh Tế: <span className="text-primary dragon-glow">GDP & Cơ Cấu Lao Động</span>
          </h2>
          <p className="slide-title text-xl text-muted-foreground">Từ nền kinh tế nông nghiệp đến dịch vụ hiện đại</p>
        </div>

        {/* Key Stats */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
          <div className="slide-card bg-gradient-to-br from-primary/20 to-primary/5 p-6 rounded-xl border border-primary/30">
            <DollarSign className="w-8 h-8 text-primary mb-2" />
            <div className="text-3xl font-bold text-primary">${latestData.gdpBillion}B</div>
            <p className="text-sm text-muted-foreground mt-1">GDP 2024</p>
          </div>

          <div className="slide-card bg-gradient-to-br from-secondary/20 to-secondary/5 p-6 rounded-xl border border-secondary/30">
            <TrendingUp className="w-8 h-8 text-secondary mb-2" />
            <div className="text-3xl font-bold text-secondary">${latestData.gdpPerCapita}</div>
            <p className="text-sm text-muted-foreground mt-1">GDP/người 2024</p>
          </div>

          <div className="slide-card bg-gradient-to-br from-accent/20 to-accent/5 p-6 rounded-xl border border-accent/30">
            <div className="text-3xl font-bold text-accent">×{((latestData.gdpBillion || 0) / (earliestData.gdpBillion || 1)).toFixed(0)}</div>
            <p className="text-sm text-muted-foreground mt-1">Tăng GDP so với 1955</p>
          </div>

          <div className="slide-card bg-gradient-to-br from-primary-glow/20 to-primary-glow/5 p-6 rounded-xl border border-primary-glow/30">
            <div className="text-3xl font-bold text-primary-glow">×{((latestData.gdpPerCapita || 0) / (earliestData.gdpPerCapita || 1)).toFixed(0)}</div>
            <p className="text-sm text-muted-foreground mt-1">Tăng thu nhập/người</p>
          </div>
        </div>

        {/* GDP Chart */}
        <ChartContainer
          id="economy-gdp-chart"
          title="Hành Trình Tăng Trưởng GDP"
          onFullscreen={() => setFullscreenChart('gdp')}
          data={economyData}
          filename="gdp-viet-nam"
        >
          <ResponsiveContainer width="100%" height={400}>
            <ComposedChart data={economyData}>
              <defs>
                <linearGradient id="gdpGradient" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="hsl(var(--primary))" stopOpacity={0.8} />
                  <stop offset="95%" stopColor="hsl(var(--primary))" stopOpacity={0.1} />
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" opacity={0.3} />
              <XAxis
                dataKey="year"
                stroke="hsl(var(--muted-foreground))"
                tick={{ fill: 'hsl(var(--muted-foreground))' }}
                ticks={MILESTONE_YEARS}
              />
              <YAxis
                yAxisId="left"
                stroke="hsl(var(--muted-foreground))"
                tick={{ fill: 'hsl(var(--muted-foreground))' }}
                tickFormatter={(value) => `$${value}B`}
              />
              <YAxis
                yAxisId="right"
                orientation="right"
                stroke="hsl(var(--secondary))"
                tick={{ fill: 'hsl(var(--secondary))' }}
                tickFormatter={(value) => `$${value}`}
              />
              <Tooltip
                contentStyle={{
                  backgroundColor: 'hsl(var(--card))',
                  border: '1px solid hsl(var(--border))',
                  borderRadius: '8px',
                  color: 'hsl(var(--foreground))',
                }}
              />
              <Bar yAxisId="left" dataKey="gdpBillion" fill="url(#gdpGradient)" radius={[8, 8, 0, 0]} animationDuration={1500} />
              <Line
                yAxisId="right"
                type="monotone"
                dataKey="gdpPerCapita"
                stroke="hsl(var(--secondary))"
                strokeWidth={3}
                dot={{ fill: 'hsl(var(--secondary))', r: 4 }}
                animationDuration={2000}
              />
            </ComposedChart>
          </ResponsiveContainer>
        </ChartContainer>

        {/* Employment Structure */}
        <ChartContainer id="employment-chart" title="Cơ Cấu Lao Động Theo Ngành (%)" className="mt-12">
          <ResponsiveContainer width="100%" height={400}>
            <AreaChart data={employmentData}>
              <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
              <XAxis
                dataKey="year"
                stroke="hsl(var(--muted-foreground))"
                tick={{ fill: 'hsl(var(--muted-foreground))' }}
                ticks={MILESTONE_YEARS}
              />
              <YAxis
                stroke="hsl(var(--muted-foreground))"
                tick={{ fill: 'hsl(var(--muted-foreground))' }}
                label={{
                  value: '% Lao động',
                  angle: -90,
                  position: 'insideLeft',
                  fill: 'hsl(var(--muted-foreground))',
                }}
              />
              <Tooltip
                contentStyle={{
                  backgroundColor: 'hsl(var(--card))',
                  border: '1px solid hsl(var(--border))',
                  borderRadius: '8px',
                }}
              />
              <Legend />
              <Area
                type="monotone"
                dataKey="services"
                stackId="1"
                stroke="hsl(var(--primary))"
                fill="hsl(var(--primary) / 0.6)"
                name="Dịch vụ"
              />
              <Area
                type="monotone"
                dataKey="industry"
                stackId="1"
                stroke="hsl(var(--accent))"
                fill="hsl(var(--accent) / 0.6)"
                name="Công nghiệp"
              />
              <Area
                type="monotone"
                dataKey="agriculture"
                stackId="1"
                stroke="hsl(var(--secondary))"
                fill="hsl(var(--secondary) / 0.6)"
                name="Nông nghiệp"
              />
            </AreaChart>
          </ResponsiveContainer>
        </ChartContainer>

        {/* Employment Comparison Cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mt-12">
          <div className="slide-card bg-gradient-to-br from-secondary/20 via-secondary/10 to-transparent p-8 rounded-2xl border border-secondary/30">
            <div className="text-sm text-muted-foreground mb-2">NÔNG NGHIỆP</div>
            <div className="flex items-baseline gap-4 mb-4">
              <div className="text-4xl font-bold text-secondary">{earliestData.employmentAgriculture}%</div>
              <div className="text-2xl text-muted-foreground">→</div>
              <div className="text-4xl font-bold text-secondary">{latestData.employmentAgriculture}%</div>
            </div>
            <div className="flex items-center gap-2 text-sm">
              <TrendingUp className="w-4 h-4 text-secondary rotate-180" />
              <span className="text-muted-foreground">
                Giảm {(earliestData.employmentAgriculture - latestData.employmentAgriculture).toFixed(0)}%
              </span>
            </div>
          </div>

          <div className="slide-card bg-gradient-to-br from-accent/20 via-accent/10 to-transparent p-8 rounded-2xl border border-accent/30">
            <div className="text-sm text-muted-foreground mb-2">CÔNG NGHIỆP</div>
            <div className="flex items-baseline gap-4 mb-4">
              <div className="text-4xl font-bold text-accent">{earliestData.employmentIndustry}%</div>
              <div className="text-2xl text-muted-foreground">→</div>
              <div className="text-4xl font-bold text-accent">{latestData.employmentIndustry}%</div>
            </div>
            <div className="flex items-center gap-2 text-sm">
              <TrendingUp className="w-4 h-4 text-accent rotate-180" />
              <span className="text-muted-foreground">
                Giảm {(earliestData.employmentIndustry - latestData.employmentIndustry).toFixed(0)}%
              </span>
            </div>
          </div>

          <div className="slide-card bg-gradient-to-br from-primary/20 via-primary/10 to-transparent p-8 rounded-2xl border border-primary/30 animate-pulse">
            <div className="text-sm text-muted-foreground mb-2">DỊCH VỤ</div>
            <div className="flex items-baseline gap-4 mb-4">
              <div className="text-4xl font-bold text-primary">{earliestData.employmentServices}%</div>
              <div className="text-2xl text-muted-foreground">→</div>
              <div className="text-4xl font-bold text-primary">{latestData.employmentServices}%</div>
            </div>
            <div className="flex items-center gap-2 text-sm">
              <TrendingUp className="w-4 h-4 text-primary" />
              <span className="text-muted-foreground">
                Tăng {(latestData.employmentServices - earliestData.employmentServices).toFixed(0)}%
              </span>
            </div>
          </div>
        </div>

        {/* Analysis */}
        <div className="mt-12 bg-gradient-to-r from-primary/10 via-secondary/10 to-accent/10 backdrop-blur-sm p-8 rounded-2xl border border-primary/30">
          <div className="flex items-start gap-4">
            <TrendingUp className="w-8 h-8 text-primary flex-shrink-0 mt-1" />
            <div>
              <h3 className="text-2xl font-bold mb-3 text-primary">Phép Màu Kinh Tế & Chuyển Dịch Lao Động</h3>
              <p className="text-lg text-muted-foreground leading-relaxed">
                GDP tăng từ ${earliestData.gdpBillion}B (1955) lên ${latestData.gdpBillion}B (2024) - tăng
                {((latestData.gdpBillion || 0) / (earliestData.gdpBillion || 1)).toFixed(0)} lần. Thu nhập bình quân đầu người tăng
                {((latestData.gdpPerCapita || 0) / (earliestData.gdpPerCapita || 1)).toFixed(0)} lần. Cùng lúc, tỷ trọng lao động nông nghiệp
                giảm từ {earliestData.employmentAgriculture}% xuống {latestData.employmentAgriculture}%, trong khi lao động dịch vụ tăng từ{' '}
                {earliestData.employmentServices}% lên {latestData.employmentServices}%. Sự chuyển dịch này phản ánh quá trình công nghiệp hóa,
                hiện đại hóa thành công của Việt Nam.
              </p>
            </div>
          </div>
        </div>
      </div>

      <FullscreenChart isOpen={fullscreenChart === 'gdp'} onClose={() => setFullscreenChart(null)} title="Tăng Trưởng GDP Việt Nam">
        <ResponsiveContainer width="100%" height="80%">
          <ComposedChart data={economyData}>
            <defs>
              <linearGradient id="gdpGradient2" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="hsl(var(--primary))" stopOpacity={0.8} />
                <stop offset="95%" stopColor="hsl(var(--primary))" stopOpacity={0.1} />
              </linearGradient>
            </defs>
            <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" opacity={0.3} />
            <XAxis
              dataKey="year"
              stroke="hsl(var(--muted-foreground))"
              tick={{ fill: 'hsl(var(--muted-foreground))' }}
              ticks={MILESTONE_YEARS}
            />
            <YAxis
              yAxisId="left"
              stroke="hsl(var(--muted-foreground))"
              tick={{ fill: 'hsl(var(--muted-foreground))' }}
              tickFormatter={(value) => `$${value}B`}
            />
            <YAxis
              yAxisId="right"
              orientation="right"
              stroke="hsl(var(--secondary))"
              tick={{ fill: 'hsl(var(--secondary))' }}
              tickFormatter={(value) => `$${value}`}
            />
            <Tooltip
              contentStyle={{
                backgroundColor: 'hsl(var(--card))',
                border: '1px solid hsl(var(--border))',
                borderRadius: '8px',
                color: 'hsl(var(--foreground))',
              }}
            />
            <Bar yAxisId="left" dataKey="gdpBillion" fill="url(#gdpGradient2)" radius={[8, 8, 0, 0]} animationDuration={1500} />
            <Line
              yAxisId="right"
              type="monotone"
              dataKey="gdpPerCapita"
              stroke="hsl(var(--secondary))"
              strokeWidth={3}
              dot={{ fill: 'hsl(var(--secondary))', r: 4 }}
              animationDuration={2000}
            />
          </ComposedChart>
        </ResponsiveContainer>
      </FullscreenChart>
    </div>
  );
};
