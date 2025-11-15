import { useState, useMemo } from 'react';
import { Users, TrendingUp } from 'lucide-react';
import { LineChart, Line, AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { useSlideAnimation } from '@/hooks/useSlideAnimation';
import { useSlideData } from '@/hooks/useSlideData';
import { ChartContainer } from '@/components/ChartContainer';
import { FullscreenChart } from '@/components/FullscreenChart';
import { MILESTONE_YEARS } from '@/constants/slideConstants';

export const SlidePopulationDemographics = () => {
  const containerRef = useSlideAnimation({ title: true, charts: true, cards: true });
  const { allData, latestData, earliestData } = useSlideData();
  const [fullscreenChart, setFullscreenChart] = useState<string | null>(null);

  const populationData = useMemo(() => allData, [allData]);
  const demographicData = useMemo(() => allData.map((d) => ({
    year: d.year,
    medianAge: d.medianAge,
    fertility: d.fertilityRate,
  })), [allData]);

  const counter = useMemo(() => latestData.population / 1000000, [latestData]);

  return (
    <div ref={containerRef} className="min-h-screen py-20 px-6 relative overflow-hidden bg-gradient-to-br from-background via-primary/5 to-background">
      <div className="max-w-7xl mx-auto relative z-10">
        <div className="text-center mb-12">
          <Users className="slide-title w-16 h-16 text-primary mx-auto mb-6 animate-pulse" />
          <h2 className="slide-title font-display text-5xl md:text-6xl font-bold mb-4">
            Cơ Thể Rồng: <span className="text-primary dragon-glow">Dân Số & Nhân Khẩu</span>
          </h2>
          <p className="slide-title text-xl text-muted-foreground">
            Tăng trưởng dân số, lão hóa dân số, và cấu trúc độ tuổi
          </p>
        </div>

        {/* Population Growth Overview */}
        <div className="text-center mb-12">
          <div className="flex items-center justify-center gap-8">
            <div className="text-center">
              <div className="text-5xl md:text-7xl font-bold text-primary dragon-glow mb-2">
                {counter.toFixed(1)}M
              </div>
              <p className="text-muted-foreground">Năm 2024</p>
            </div>
            <div className="text-4xl text-muted-foreground">←</div>
            <div className="text-center">
              <div className="text-3xl md:text-5xl font-bold text-secondary mb-2">
                {(earliestData.population / 1000000).toFixed(1)}M
              </div>
              <p className="text-muted-foreground">Năm 1955</p>
            </div>
          </div>
          <div className="text-2xl font-bold text-accent mt-6">
            Tăng ×{(counter / (earliestData.population / 1000000)).toFixed(1)} trong 70 năm
          </div>
        </div>

        {/* Population Chart */}
        <ChartContainer
          id="population-demographics-growth"
          title="Biểu Đồ Tăng Trưởng Dân Số"
          onFullscreen={() => setFullscreenChart('population-growth')}
          data={populationData}
          filename="dan-so-viet-nam"
        >
          <ResponsiveContainer width="100%" height={400}>
            <AreaChart data={populationData}>
              <defs>
                <linearGradient id="populationGradient" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="hsl(var(--primary))" stopOpacity={0.8} />
                  <stop offset="95%" stopColor="hsl(var(--primary))" stopOpacity={0} />
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
                stroke="hsl(var(--muted-foreground))"
                tick={{ fill: 'hsl(var(--muted-foreground))' }}
                tickFormatter={(value) => `${(value / 1000000).toFixed(0)}M`}
              />
              <Tooltip
                contentStyle={{
                  backgroundColor: 'hsl(var(--card))',
                  border: '1px solid hsl(var(--border))',
                  borderRadius: '8px',
                  color: 'hsl(var(--foreground))',
                }}
                formatter={(value: number) => [`${(value / 1000000).toFixed(1)} triệu`, 'Dân số']}
              />
              <Area
                type="monotone"
                dataKey="population"
                stroke="hsl(var(--primary))"
                strokeWidth={3}
                fill="url(#populationGradient)"
                animationDuration={2000}
              />
            </AreaChart>
          </ResponsiveContainer>
        </ChartContainer>

        {/* Demographic Charts Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mt-12 mb-12">
          <ChartContainer id="median-age-chart" title="Tuổi Trung Vị Qua Thời Gian">
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={demographicData}>
                <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
                <XAxis
                  dataKey="year"
                  stroke="hsl(var(--muted-foreground))"
                  tick={{ fill: 'hsl(var(--muted-foreground))' }}
                  ticks={MILESTONE_YEARS}
                />
                <YAxis stroke="hsl(var(--muted-foreground))" tick={{ fill: 'hsl(var(--muted-foreground))' }} />
                <Tooltip
                  contentStyle={{
                    backgroundColor: 'hsl(var(--card))',
                    border: '1px solid hsl(var(--border))',
                    borderRadius: '8px',
                  }}
                />
                <Line
                  type="monotone"
                  dataKey="medianAge"
                  stroke="hsl(var(--secondary))"
                  strokeWidth={3}
                  dot={{ fill: 'hsl(var(--secondary))', r: 4 }}
                  name="Tuổi trung vị"
                />
              </LineChart>
            </ResponsiveContainer>
          </ChartContainer>

          <ChartContainer id="fertility-chart" title="Tỷ Lệ Sinh Con">
            <ResponsiveContainer width="100%" height={300}>
              <AreaChart data={demographicData}>
                <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
                <XAxis
                  dataKey="year"
                  stroke="hsl(var(--muted-foreground))"
                  tick={{ fill: 'hsl(var(--muted-foreground))' }}
                  ticks={MILESTONE_YEARS}
                />
                <YAxis stroke="hsl(var(--muted-foreground))" tick={{ fill: 'hsl(var(--muted-foreground))' }} />
                <Tooltip
                  contentStyle={{
                    backgroundColor: 'hsl(var(--card))',
                    border: '1px solid hsl(var(--border))',
                    borderRadius: '8px',
                  }}
                />
                <Area
                  type="monotone"
                  dataKey="fertility"
                  stroke="hsl(var(--accent))"
                  fill="hsl(var(--accent) / 0.3)"
                  strokeWidth={2}
                  name="Tỷ lệ sinh"
                />
              </AreaChart>
            </ResponsiveContainer>
          </ChartContainer>
        </div>

        {/* Key Statistics */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-12">
          <div className="slide-card bg-gradient-to-br from-primary/20 to-primary/5 p-6 rounded-xl border border-primary/30">
            <div className="text-sm text-muted-foreground mb-2">DÂN SỐ 2024</div>
            <div className="text-3xl font-bold text-primary mb-1">{counter.toFixed(1)}M</div>
            <div className="text-xs text-muted-foreground">+{((counter / (earliestData.population / 1000000) - 1) * 100).toFixed(0)}%</div>
          </div>

          <div className="slide-card bg-gradient-to-br from-secondary/20 to-secondary/5 p-6 rounded-xl border border-secondary/30">
            <div className="text-sm text-muted-foreground mb-2">TUỔI TRUNG VỊ</div>
            <div className="text-3xl font-bold text-secondary mb-1">{latestData.medianAge} tuổi</div>
            <div className="text-xs text-muted-foreground">+{(latestData.medianAge - earliestData.medianAge).toFixed(0)} tuổi</div>
          </div>

          <div className="slide-card bg-gradient-to-br from-accent/20 to-accent/5 p-6 rounded-xl border border-accent/30">
            <div className="text-sm text-muted-foreground mb-2">TỶ LỆ SINH</div>
            <div className="text-3xl font-bold text-accent mb-1">{latestData.fertilityRate}</div>
            <div className="text-xs text-muted-foreground">-{(earliestData.fertilityRate - latestData.fertilityRate).toFixed(1)}</div>
          </div>

          <div className="slide-card bg-gradient-to-br from-primary-glow/20 to-primary-glow/5 p-6 rounded-xl border border-primary-glow/30">
            <div className="text-sm text-muted-foreground mb-2">TỶ LỆ TRẺ PHỤ THUỘC</div>
            <div className="text-3xl font-bold text-primary-glow mb-1">{latestData.dependencyRatio}%</div>
            <div className="text-xs text-muted-foreground">-{(earliestData.dependencyRatio - latestData.dependencyRatio).toFixed(0)}%</div>
          </div>
        </div>

        {/* Analysis */}
        <div className="bg-primary/10 backdrop-blur-sm p-8 rounded-2xl border border-primary/30">
          <div className="flex items-start gap-4">
            <Users className="w-8 h-8 text-primary flex-shrink-0 mt-1" />
            <div>
              <h3 className="text-2xl font-bold mb-3 text-primary">Quá Trình Chuyển Đổi Nhân Khẩu Học</h3>
              <p className="text-lg text-muted-foreground leading-relaxed">
                Dân số Việt Nam tăng gấp {(counter / (earliestData.population / 1000000)).toFixed(1)} lần từ {(earliestData.population / 1000000).toFixed(1)}M (1955) lên {counter.toFixed(1)}M (2024).
                Tuổi trung vị tăng từ {earliestData.medianAge} tuổi lên {latestData.medianAge} tuổi, trong khi tỷ suất sinh giảm từ {earliestData.fertilityRate} xuống {latestData.fertilityRate} con/phụ nữ.
                Điều này phản ánh sự chuyển đổi từ giai đoạn dân số mở rộng sang giai đoạn ổn định và lão hóa - một thách thức lớn cho chính sách an sinh xã hội.
              </p>
            </div>
          </div>
        </div>
      </div>

      <FullscreenChart
        isOpen={fullscreenChart === 'population-growth'}
        onClose={() => setFullscreenChart(null)}
        title="Tăng Trưởng Dân Số Việt Nam"
      >
        <ResponsiveContainer width="100%" height="80%">
          <AreaChart data={populationData}>
            <defs>
              <linearGradient id="populationGradient2" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="hsl(var(--primary))" stopOpacity={0.8} />
                <stop offset="95%" stopColor="hsl(var(--primary))" stopOpacity={0} />
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
              stroke="hsl(var(--muted-foreground))"
              tick={{ fill: 'hsl(var(--muted-foreground))' }}
              tickFormatter={(value) => `${(value / 1000000).toFixed(0)}M`}
            />
            <Tooltip
              contentStyle={{
                backgroundColor: 'hsl(var(--card))',
                border: '1px solid hsl(var(--border))',
                borderRadius: '8px',
                color: 'hsl(var(--foreground))',
              }}
              formatter={(value: number) => [`${(value / 1000000).toFixed(1)} triệu`, 'Dân số']}
            />
            <Area
              type="monotone"
              dataKey="population"
              stroke="hsl(var(--primary))"
              strokeWidth={3}
              fill="url(#populationGradient2)"
              animationDuration={2000}
            />
          </AreaChart>
        </ResponsiveContainer>
      </FullscreenChart>
    </div>
  );
};
