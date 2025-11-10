import { Building2, Heart, TrendingDown } from 'lucide-react';
import { LineChart, Line, AreaChart, Area, ComposedChart, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { useSlideAnimation } from '@/hooks/useSlideAnimation';
import { useSlideData } from '@/hooks/useSlideData';
import { ChartContainer } from '@/components/ChartContainer';
import { MILESTONE_YEARS } from '@/constants/slideConstants';

export const SlideSocialTransition = () => {
  const containerRef = useSlideAnimation({ title: true, charts: true, cards: true, stagger: true });
  const { allData, latestData, earliestData } = useSlideData();

  const vitalData = allData.map((d) => ({
    year: d.year,
    birthRate: d.birthRate,
    deathRate: d.deathRate,
    fertilityRate: d.fertilityRate,
    dependencyRatio: d.dependencyRatio,
  }));

  const urbanData = allData.map((d) => {
    const urbanPop = (d.population * d.urbanPopPercent) / 100 / 1000000;
    const ruralPop = (d.population * (100 - d.urbanPopPercent)) / 100 / 1000000;
    return {
      year: d.year,
      urbanPopPercent: d.urbanPopPercent,
      ruralPop,
      urbanPop,
    };
  });

  return (
    <div ref={containerRef} className="min-h-screen py-20 px-6 relative overflow-hidden bg-gradient-to-br from-background via-accent/5 to-primary/10">
      <div className="max-w-7xl mx-auto relative z-10">
        <div className="text-center mb-12">
          <Heart className="slide-title w-16 h-16 text-primary mx-auto mb-6 animate-pulse" fill="currentColor" />
          <h2 className="slide-title font-display text-5xl md:text-6xl font-bold mb-4">
            Trái Tim & Móng Vuốt: <span className="text-accent dragon-glow">Chuyển Đổi Xã Hội</span>
          </h2>
          <p className="slide-title text-xl text-muted-foreground">Từ bùng nổ dân số đến đô thị hóa</p>
        </div>

        {/* Vital Statistics Charts */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-12">
          <ChartContainer id="vital-rates-chart" title="Tỷ Lệ Sinh - Tử (‰)">
            <ResponsiveContainer width="100%" height={350}>
              <AreaChart data={vitalData}>
                <defs>
                  <linearGradient id="birthGradient" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="hsl(var(--primary))" stopOpacity={0.8} />
                    <stop offset="95%" stopColor="hsl(var(--primary))" stopOpacity={0.1} />
                  </linearGradient>
                  <linearGradient id="deathGradient" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="hsl(var(--destructive))" stopOpacity={0.8} />
                    <stop offset="95%" stopColor="hsl(var(--destructive))" stopOpacity={0.1} />
                  </linearGradient>
                </defs>
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
                    value: '‰ (phần nghìn)',
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
                  dataKey="birthRate"
                  stroke="hsl(var(--primary))"
                  fill="url(#birthGradient)"
                  strokeWidth={3}
                  name="Tỷ lệ sinh"
                />
                <Area
                  type="monotone"
                  dataKey="deathRate"
                  stroke="hsl(var(--destructive))"
                  fill="url(#deathGradient)"
                  strokeWidth={3}
                  name="Tỷ lệ tử"
                />
              </AreaChart>
            </ResponsiveContainer>
          </ChartContainer>

          <ChartContainer id="urbanization-chart" title="Dân Số Đô Thị vs Nông Thôn">
            <ResponsiveContainer width="100%" height={350}>
              <ComposedChart data={urbanData}>
                <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
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
                  label={{
                    value: 'Dân số (triệu)',
                    angle: -90,
                    position: 'insideLeft',
                    fill: 'hsl(var(--muted-foreground))',
                  }}
                />
                <YAxis
                  yAxisId="right"
                  orientation="right"
                  stroke="hsl(var(--muted-foreground))"
                  tick={{ fill: 'hsl(var(--muted-foreground))' }}
                  label={{
                    value: '% Đô thị',
                    angle: 90,
                    position: 'insideRight',
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
                  yAxisId="left"
                  type="monotone"
                  dataKey="urbanPop"
                  fill="hsl(var(--accent) / 0.3)"
                  stroke="hsl(var(--accent))"
                  strokeWidth={2}
                  name="Dân số đô thị (triệu)"
                />
                <Area
                  yAxisId="left"
                  type="monotone"
                  dataKey="ruralPop"
                  fill="hsl(var(--secondary) / 0.2)"
                  stroke="hsl(var(--secondary))"
                  strokeWidth={2}
                  name="Dân số nông thôn (triệu)"
                />
                <Line
                  yAxisId="right"
                  type="monotone"
                  dataKey="urbanPopPercent"
                  stroke="hsl(var(--primary))"
                  strokeWidth={3}
                  dot={{ fill: 'hsl(var(--primary))', r: 5 }}
                  name="% Đô thị hóa"
                />
              </ComposedChart>
            </ResponsiveContainer>
          </ChartContainer>
        </div>

        {/* Secondary Vital Charts */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-12">
          <ChartContainer id="fertility-chart" title="Tỷ Suất Sinh (Con/Phụ Nữ)">
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={vitalData}>
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
                  dataKey="fertilityRate"
                  stroke="hsl(var(--secondary))"
                  strokeWidth={3}
                  dot={{ fill: 'hsl(var(--secondary))', r: 4 }}
                  name="Tỷ suất sinh"
                />
              </LineChart>
            </ResponsiveContainer>
          </ChartContainer>

          <ChartContainer id="dependency-chart" title="Tỷ Lệ Phụ Thuộc (%)">
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={vitalData}>
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
                  dataKey="dependencyRatio"
                  stroke="hsl(var(--accent))"
                  strokeWidth={3}
                  dot={{ fill: 'hsl(var(--accent))', r: 4 }}
                  name="Tỷ lệ phụ thuộc"
                />
              </LineChart>
            </ResponsiveContainer>
          </ChartContainer>
        </div>

        {/* Key Indicators Grid */}
        <div className="grid grid-cols-2 md:grid-cols-3 gap-4 mb-12">
          <div className="slide-card bg-gradient-to-br from-primary/20 via-primary/10 to-transparent p-6 rounded-2xl border border-primary/30">
            <Heart className="w-8 h-8 text-primary mb-3" fill="currentColor" />
            <div className="text-sm text-muted-foreground mb-2">TỶ LỆ SINH</div>
            <div className="text-3xl font-bold text-primary mb-1">{earliestData.birthRate}‰</div>
            <div className="text-xs text-muted-foreground">→ {latestData.birthRate}‰</div>
          </div>

          <div className="slide-card bg-gradient-to-br from-secondary/20 via-secondary/10 to-transparent p-6 rounded-2xl border border-secondary/30">
            <div className="text-sm text-muted-foreground mb-2">TỶ SUẤT SINH</div>
            <div className="text-3xl font-bold text-secondary mb-1">{earliestData.fertilityRate}</div>
            <div className="text-xs text-muted-foreground">→ {latestData.fertilityRate} con/phụ nữ</div>
          </div>

          <div className="slide-card bg-gradient-to-br from-accent/20 via-accent/10 to-transparent p-6 rounded-2xl border border-accent/30">
            <Building2 className="w-8 h-8 text-accent mb-3" />
            <div className="text-sm text-muted-foreground mb-2">ĐÔ THỊ HÓA</div>
            <div className="text-3xl font-bold text-accent mb-1">{earliestData.urbanPopPercent}%</div>
            <div className="text-xs text-muted-foreground">→ {latestData.urbanPopPercent}%</div>
          </div>
        </div>

        {/* Urbanization Impact Cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12">
          <div className="slide-card bg-gradient-to-br from-accent/20 via-accent/10 to-transparent p-8 rounded-2xl border border-accent/30">
            <Building2 className="w-10 h-10 text-accent mb-4" />
            <div className="text-4xl font-bold text-accent mb-2">
              {(earliestData.population * earliestData.urbanPopPercent / 100 / 1000000).toFixed(1)}M
            </div>
            <div className="text-sm text-muted-foreground mb-2">Dân số đô thị năm 1955</div>
            <div className="text-xs text-muted-foreground">{earliestData.urbanPopPercent}%</div>
          </div>

          <div className="slide-card bg-gradient-to-br from-primary/20 via-primary/10 to-transparent p-8 rounded-2xl border border-primary/30 animate-pulse">
            <Building2 className="w-10 h-10 text-primary mb-4" />
            <div className="text-4xl font-bold text-primary mb-2">
              {(latestData.population * latestData.urbanPopPercent / 100 / 1000000).toFixed(1)}M
            </div>
            <div className="text-sm text-muted-foreground mb-2">Dân số đô thị năm 2024</div>
            <div className="text-xs text-muted-foreground">{latestData.urbanPopPercent}%</div>
          </div>

          <div className="slide-card bg-gradient-to-br from-secondary/20 via-secondary/10 to-transparent p-8 rounded-2xl border border-secondary/30">
            <TrendingDown className="w-10 h-10 text-secondary mb-4 rotate-180" />
            <div className="text-4xl font-bold text-secondary mb-2">
              ×{((latestData.population * latestData.urbanPopPercent) / (earliestData.population * earliestData.urbanPopPercent)).toFixed(1)}
            </div>
            <div className="text-sm text-muted-foreground mb-2">Tăng trưởng</div>
            <div className="text-xs text-muted-foreground">+{(latestData.urbanPopPercent - earliestData.urbanPopPercent).toFixed(1)}%</div>
          </div>
        </div>

        {/* Analysis */}
        <div className="bg-primary/10 backdrop-blur-sm p-8 rounded-2xl border border-primary/30">
          <div className="flex items-start gap-4">
            <Heart className="w-8 h-8 text-primary flex-shrink-0 mt-1" fill="currentColor" />
            <div>
              <h3 className="text-2xl font-bold mb-3 text-primary">Chuyển Đổi Nhân Khẩu & Đô Thị Hóa Xã Hội</h3>
              <p className="text-lg text-muted-foreground leading-relaxed">
                Tỷ lệ sinh giảm từ {earliestData.birthRate}‰ xuống {latestData.birthRate}‰, tỷ suất sinh từ {earliestData.fertilityRate} xuống{' '}
                {latestData.fertilityRate} con/phụ nữ. Đồng thời, dân số đô thị tăng từ{' '}
                {(earliestData.population * earliestData.urbanPopPercent / 100 / 1000000).toFixed(1)}M ({earliestData.urbanPopPercent}%) lên{' '}
                {(latestData.population * latestData.urbanPopPercent / 100 / 1000000).toFixed(1)}M ({latestData.urbanPopPercent}%) - tăng
                {((latestData.population * latestData.urbanPopPercent) / (earliestData.population * earliestData.urbanPopPercent)).toFixed(1)} lần.
                Việt Nam đã hoàn thành chuyển đổi nhân khẩu thành công và đang trải qua quá trình đô thị hóa nhanh chóng, mang lại cơ hội phát triển
                nhưng cũng đặt ra thách thức lớn về quản lý hạ tầng, môi trường và an sinh xã hội.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
