import { useEffect, useRef, useState } from 'react';
import { vietnamData } from '@/data/vietnamData';
import { LayoutDashboard, TrendingUp, Users, Briefcase, GraduationCap } from 'lucide-react';
import { LineChart, Line, BarChart, Bar, AreaChart, Area, RadarChart, Radar, PolarGrid, PolarAngleAxis, PolarRadiusAxis, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { CustomTooltip } from '@/components/ui/custom-tooltip';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import { ExportButtons } from '@/components/ExportButtons';

gsap.registerPlugin(ScrollTrigger);

type MetricType = 'all' | 'population' | 'economy' | 'society' | 'education';

export const SlideDashboard = () => {
  const containerRef = useRef<HTMLDivElement>(null);
  const [selectedMetric, setSelectedMetric] = useState<MetricType>('all');
  const [yearRange, setYearRange] = useState({ start: 1955, end: 2025 });

  useEffect(() => {
    if (!containerRef.current) return;

    const ctx = gsap.context(() => {
      gsap.from('.dash-title', {
        opacity: 0,
        y: 50,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        duration: 1,
        ease: 'power3.out'
      });

      gsap.from('.dash-filter', {
        opacity: 0,
        x: -30,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        duration: 0.8,
        stagger: 0.1,
        ease: 'power2.out'
      });

      gsap.from('.dash-chart', {
        opacity: 0,
        scale: 0.9,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        duration: 1,
        stagger: 0.15,
        ease: 'back.out(1.2)'
      });
    }, containerRef);

    return () => ctx.revert();
  }, []);

  // Filter data by year range
  const filteredData = vietnamData.filter(
    d => d.year >= yearRange.start && d.year <= yearRange.end
  );

  // Prepare chart data based on selected metric
  const getChartData = () => {
    return filteredData.map(d => ({
      year: d.year,
      population: d.population / 1000000,
      gdp: d.gdpBillion,
      urbanization: d.urbanPopPercent,
      hdi: d.hdi * 100,
      literacy: d.literacyRate,
      lifeExpectancy: d.lifeExpectancy,
      gdpPerCapita: d.gdpPerCapita,
    }));
  };

  const chartData = getChartData();

  // Radar data for latest year
  const latestYear = filteredData[filteredData.length - 1];
  const radarData = [
    { indicator: 'HDI', value: latestYear.hdi * 100, fullMark: 100 },
    { indicator: 'Đô thị', value: latestYear.urbanPopPercent, fullMark: 100 },
    { indicator: 'Biết chữ', value: latestYear.literacyRate, fullMark: 100 },
    { indicator: 'Tuổi thọ', value: (latestYear.lifeExpectancy / 90) * 100, fullMark: 100 },
    { indicator: 'Giáo dục', value: latestYear.educationIndex * 100, fullMark: 100 },
  ];

  const filters: { id: MetricType; label: string; icon: any }[] = [
    { id: 'all', label: 'Tất cả', icon: LayoutDashboard },
    { id: 'population', label: 'Dân số', icon: Users },
    { id: 'economy', label: 'Kinh tế', icon: TrendingUp },
    { id: 'society', label: 'Xã hội', icon: Users },
    { id: 'education', label: 'Giáo dục', icon: GraduationCap },
  ];

  return (
    <div ref={containerRef} className="min-h-screen py-20 px-6 relative overflow-hidden bg-gradient-to-br from-background via-secondary/5 to-primary/10">
      <div className="max-w-7xl mx-auto relative z-10">
        {/* Header */}
        <div className="text-center mb-12">
          <LayoutDashboard className="dash-title w-16 h-16 text-primary mx-auto mb-6 animate-pulse" />
          <h2 className="dash-title font-display text-5xl md:text-6xl font-bold mb-4">
            Dashboard <span className="text-primary dragon-glow">Tổng Quan</span>
          </h2>
          <p className="dash-title text-xl text-muted-foreground">Khám phá dữ liệu với bộ lọc động và biểu đồ tương tác</p>
        </div>

        {/* Filters */}
        <div className="mb-8 flex flex-wrap gap-3 justify-center">
          {filters.map(filter => {
            const Icon = filter.icon;
            return (
              <button
                key={filter.id}
                onClick={() => setSelectedMetric(filter.id)}
                className={`dash-filter flex items-center gap-2 px-6 py-3 rounded-xl font-semibold transition-all duration-300 ${
                  selectedMetric === filter.id
                    ? 'bg-primary text-primary-foreground shadow-elegant scale-105'
                    : 'bg-card/50 text-muted-foreground hover:bg-card border border-border'
                }`}
              >
                <Icon className="w-5 h-5" />
                {filter.label}
              </button>
            );
          })}
        </div>

        {/* Year Range Slider */}
        <div className="dash-filter mb-12 bg-card/50 backdrop-blur-sm p-6 rounded-2xl border border-border">
          <h3 className="text-lg font-bold mb-4 text-center">Khoảng thời gian: {yearRange.start} - {yearRange.end}</h3>
          <div className="flex gap-6 items-center">
            <div className="flex-1">
              <label className="text-sm text-muted-foreground mb-2 block">Từ năm</label>
              <input
                type="range"
                min={1955}
                max={yearRange.end - 1}
                value={yearRange.start}
                onChange={(e) => setYearRange({ ...yearRange, start: parseInt(e.target.value) })}
                className="w-full h-2 bg-muted rounded-lg appearance-none cursor-pointer accent-primary"
              />
              <div className="text-center text-sm font-bold text-primary mt-1">{yearRange.start}</div>
            </div>
            <div className="flex-1">
              <label className="text-sm text-muted-foreground mb-2 block">Đến năm</label>
              <input
                type="range"
                min={yearRange.start + 1}
                max={2025}
                value={yearRange.end}
                onChange={(e) => setYearRange({ ...yearRange, end: parseInt(e.target.value) })}
                className="w-full h-2 bg-muted rounded-lg appearance-none cursor-pointer accent-primary"
              />
              <div className="text-center text-sm font-bold text-primary mt-1">{yearRange.end}</div>
            </div>
          </div>
        </div>

        {/* Charts Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-12">
          {/* Population & GDP Trend */}
          {(selectedMetric === 'all' || selectedMetric === 'population' || selectedMetric === 'economy') && (
            <div id="dashboard-population-gdp" className="dash-chart bg-card/30 backdrop-blur-sm p-6 rounded-2xl border border-border shadow-elegant">
              <div className="flex justify-between items-center mb-4">
                <h3 className="text-xl font-bold flex items-center gap-2">
                  <TrendingUp className="w-5 h-5 text-primary" />
                  Dân Số & GDP
                </h3>
                <ExportButtons 
                  elementId="dashboard-population-gdp" 
                  filename="dashboard-dan-so-gdp"
                  data={chartData}
                  variant="ghost"
                />
              </div>
              <ResponsiveContainer width="100%" height={300}>
                <LineChart data={chartData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
                  <XAxis dataKey="year" stroke="hsl(var(--muted-foreground))" />
                  <YAxis yAxisId="left" stroke="hsl(var(--primary))" />
                  <YAxis yAxisId="right" orientation="right" stroke="hsl(var(--secondary))" />
                  <Tooltip content={<CustomTooltip />} />
                  <Legend />
                  <Line yAxisId="left" type="monotone" dataKey="population" stroke="hsl(var(--primary))" strokeWidth={3} name="Dân số (M)" dot={{ fill: 'hsl(var(--primary))' }} />
                  <Line yAxisId="right" type="monotone" dataKey="gdp" stroke="hsl(var(--secondary))" strokeWidth={3} name="GDP ($B)" dot={{ fill: 'hsl(var(--secondary))' }} />
                </LineChart>
              </ResponsiveContainer>
            </div>
          )}

          {/* Urbanization Area Chart */}
          {(selectedMetric === 'all' || selectedMetric === 'society') && (
            <div className="dash-chart bg-card/30 backdrop-blur-sm p-6 rounded-2xl border border-border shadow-elegant">
              <h3 className="text-xl font-bold mb-4">Đô Thị Hóa</h3>
              <ResponsiveContainer width="100%" height={300}>
                <AreaChart data={chartData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
                  <XAxis dataKey="year" stroke="hsl(var(--muted-foreground))" />
                  <YAxis stroke="hsl(var(--muted-foreground))" />
                  <Tooltip content={<CustomTooltip />} />
                  <Legend />
                  <Area type="monotone" dataKey="urbanization" stroke="hsl(var(--accent))" fill="hsl(var(--accent) / 0.3)" strokeWidth={2} name="Tỷ lệ đô thị (%)" />
                </AreaChart>
              </ResponsiveContainer>
            </div>
          )}

          {/* HDI & Literacy */}
          {(selectedMetric === 'all' || selectedMetric === 'education' || selectedMetric === 'society') && (
            <div className="dash-chart bg-card/30 backdrop-blur-sm p-6 rounded-2xl border border-border shadow-elegant">
              <h3 className="text-xl font-bold mb-4">HDI & Biết Chữ</h3>
              <ResponsiveContainer width="100%" height={300}>
                <BarChart data={chartData.filter((_, i) => i % 5 === 0)}>
                  <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
                  <XAxis dataKey="year" stroke="hsl(var(--muted-foreground))" />
                  <YAxis stroke="hsl(var(--muted-foreground))" />
                  <Tooltip content={<CustomTooltip />} />
                  <Legend />
                  <Bar dataKey="hdi" fill="hsl(var(--primary))" name="HDI (%)" />
                  <Bar dataKey="literacy" fill="hsl(var(--secondary))" name="Biết chữ (%)" />
                </BarChart>
              </ResponsiveContainer>
            </div>
          )}

          {/* Development Radar */}
          {(selectedMetric === 'all') && (
            <div className="dash-chart bg-card/30 backdrop-blur-sm p-6 rounded-2xl border border-border shadow-elegant">
              <h3 className="text-xl font-bold mb-4">Chỉ Số Phát Triển {latestYear.year}</h3>
              <ResponsiveContainer width="100%" height={300}>
                <RadarChart data={radarData}>
                  <PolarGrid stroke="hsl(var(--border))" />
                  <PolarAngleAxis dataKey="indicator" stroke="hsl(var(--muted-foreground))" />
                  <PolarRadiusAxis angle={90} domain={[0, 100]} stroke="hsl(var(--muted-foreground))" />
                  <Radar name="Phát triển" dataKey="value" stroke="hsl(var(--primary))" fill="hsl(var(--primary) / 0.5)" strokeWidth={2} />
                  <Tooltip />
                </RadarChart>
              </ResponsiveContainer>
            </div>
          )}
        </div>

        {/* Summary Stats */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          <div className="dash-chart bg-gradient-to-br from-primary/20 to-primary/5 p-6 rounded-xl border border-primary/30">
            <div className="text-3xl font-bold text-primary mb-2">{(latestYear.population / 1000000).toFixed(1)}M</div>
            <div className="text-sm text-muted-foreground">Dân số {latestYear.year}</div>
          </div>
          <div className="dash-chart bg-gradient-to-br from-secondary/20 to-secondary/5 p-6 rounded-xl border border-secondary/30">
            <div className="text-3xl font-bold text-secondary mb-2">${latestYear.gdpBillion}B</div>
            <div className="text-sm text-muted-foreground">GDP {latestYear.year}</div>
          </div>
          <div className="dash-chart bg-gradient-to-br from-accent/20 to-accent/5 p-6 rounded-xl border border-accent/30">
            <div className="text-3xl font-bold text-accent mb-2">{latestYear.urbanPopPercent}%</div>
            <div className="text-sm text-muted-foreground">Đô thị hóa</div>
          </div>
          <div className="dash-chart bg-gradient-to-br from-primary/20 to-secondary/10 p-6 rounded-xl border border-primary/30">
            <div className="text-3xl font-bold text-primary mb-2">{(latestYear.hdi * 100).toFixed(1)}%</div>
            <div className="text-sm text-muted-foreground">HDI</div>
          </div>
        </div>
      </div>
    </div>
  );
};
