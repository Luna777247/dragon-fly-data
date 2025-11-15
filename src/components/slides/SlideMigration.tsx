import { useEffect, useRef, useMemo } from 'react';
import { MILESTONE_YEARS } from '@/constants/slideConstants';
import { ArrowRightLeft, TrendingDown, Building2, Home } from 'lucide-react';
import { vietnamData } from '@/data/vietnamData';
import { ComposedChart, Line, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend, Area, AreaChart } from 'recharts';
import { CustomTooltip } from '@/components/ui/custom-tooltip';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

export const SlideMigration = () => {
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!containerRef.current) return;

    const ctx = gsap.context(() => {
      gsap.from('.migration-title', {
        opacity: 0,
        y: 50,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        duration: 1,
        ease: 'power3.out'
      });

      gsap.from('.migration-stat', {
        opacity: 0,
        scale: 0.8,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        duration: 0.8,
        stagger: 0.2,
        ease: 'back.out(1.7)'
      });

      gsap.from('.migration-chart', {
        opacity: 0,
        y: 30,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        duration: 1.2,
        delay: 0.5,
        ease: 'power2.out'
      });
    }, containerRef);

    return () => ctx.revert();
  }, []);

  const chartData = useMemo(() => vietnamData, []);
  const milestoneYears = MILESTONE_YEARS;
  const latestData = useMemo(() => vietnamData[vietnamData.length - 1], []);
  const firstData = useMemo(() => vietnamData[0], []);

  return (
    <div ref={containerRef} className="min-h-screen flex items-center justify-center py-20 px-6">
      <div className="max-w-6xl w-full">
        <div className="text-center mb-12">
          <h2 className="migration-title font-display text-4xl md:text-6xl font-bold mb-4">
            Di Chuyển <span className="text-primary">Rồng</span>: Di Cư & Đô Thị Hóa
          </h2>
          <p className="text-muted-foreground text-lg">Từ nông thôn đến thành thị</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
          <div className="migration-stat bg-gradient-to-br from-primary/20 to-primary/5 p-6 rounded-xl border border-primary/30 shadow-lg">
            <Building2 className="w-8 h-8 text-primary mb-2" />
            <div className="text-3xl font-bold text-primary">{latestData.urbanPopPercent}%</div>
            <p className="text-sm text-muted-foreground mt-1">Dân số thành thị</p>
          </div>
          
          <div className="migration-stat bg-gradient-to-br from-secondary/20 to-secondary/5 p-6 rounded-xl border border-secondary/30 shadow-lg">
            <Home className="w-8 h-8 text-secondary mb-2" />
            <div className="text-3xl font-bold text-secondary">{(100 - latestData.urbanPopPercent).toFixed(1)}%</div>
            <p className="text-sm text-muted-foreground mt-1">Dân số nông thôn</p>
          </div>

          <div className="migration-stat bg-gradient-to-br from-accent/20 to-accent/5 p-6 rounded-xl border border-accent/30 shadow-lg">
            <TrendingDown className="w-8 h-8 text-accent mb-2" />
            <div className="text-3xl font-bold text-accent">{latestData.netMigrationRate.toFixed(1)}‰</div>
            <p className="text-sm text-muted-foreground mt-1">Tỷ lệ di cư ròng</p>
          </div>

          <div className="migration-stat bg-gradient-to-br from-primary-glow/20 to-primary-glow/5 p-6 rounded-xl border border-primary-glow/30 shadow-lg">
            <ArrowRightLeft className="w-8 h-8 text-primary-glow mb-2" />
            <div className="text-3xl font-bold text-primary-glow">{latestData.urbanGrowthRate.toFixed(1)}%</div>
            <p className="text-sm text-muted-foreground mt-1">Tốc độ đô thị hóa</p>
          </div>
        </div>

        <div className="migration-chart bg-card/50 backdrop-blur-sm p-8 rounded-2xl border border-border shadow-[0_0_50px_rgba(0,0,0,0.3)] mb-8">
          <h3 className="text-xl font-semibold mb-6 text-center">Quá Trình Đô Thị Hóa</h3>
          <ResponsiveContainer width="100%" height={400}>
            <AreaChart data={chartData}>
              <defs>
                <linearGradient id="urbanGradient" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="hsl(var(--primary))" stopOpacity={0.8}/>
                  <stop offset="95%" stopColor="hsl(var(--primary))" stopOpacity={0.1}/>
                </linearGradient>
                <linearGradient id="ruralGradient" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="hsl(var(--secondary))" stopOpacity={0.8}/>
                  <stop offset="95%" stopColor="hsl(var(--secondary))" stopOpacity={0.1}/>
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" opacity={0.3} />
              <XAxis 
                dataKey="year" 
                stroke="hsl(var(--muted-foreground))"
                tick={{ fill: 'hsl(var(--muted-foreground))' }}
                ticks={milestoneYears}
              />
              <YAxis 
                stroke="hsl(var(--muted-foreground))"
                tick={{ fill: 'hsl(var(--muted-foreground))' }}
                tickFormatter={(value) => `${(value / 1000000).toFixed(0)}M`}
              />
              <Tooltip 
                content={<CustomTooltip 
                  formatter={(value: number) => [`${(value / 1000000).toFixed(1)} triệu`, '']}
                />} 
              />
              <Legend />
              <Area 
                type="monotone" 
                dataKey="urbanPopulation" 
                stroke="hsl(var(--primary))" 
                strokeWidth={2}
                fill="url(#urbanGradient)"
                name="Dân số thành thị"
                animationDuration={2000}
              />
              <Area 
                type="monotone" 
                dataKey="ruralPopulation" 
                stroke="hsl(var(--secondary))" 
                strokeWidth={2}
                fill="url(#ruralGradient)"
                name="Dân số nông thôn"
                animationDuration={2000}
              />
            </AreaChart>
          </ResponsiveContainer>
        </div>

        <div className="migration-chart bg-card/50 backdrop-blur-sm p-8 rounded-2xl border border-border shadow-[0_0_50px_rgba(0,0,0,0.3)] mb-8">
          <h3 className="text-xl font-semibold mb-6 text-center">Di Cư Ròng Qua Các Năm</h3>
          <ResponsiveContainer width="100%" height={350}>
            <ComposedChart data={chartData}>
              <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" opacity={0.3} />
              <XAxis 
                dataKey="year" 
                stroke="hsl(var(--muted-foreground))"
                tick={{ fill: 'hsl(var(--muted-foreground))' }}
                ticks={milestoneYears}
              />
              <YAxis 
                stroke="hsl(var(--muted-foreground))"
                tick={{ fill: 'hsl(var(--muted-foreground))' }}
              />
              <Tooltip content={<CustomTooltip />} />
              <Legend />
              <Bar 
                dataKey="migrantsNet" 
                fill="hsl(var(--accent))"
                radius={[8, 8, 0, 0]}
                name="Di cư ròng (người)"
                animationDuration={1500}
              />
              <Line 
                type="monotone" 
                dataKey="netMigrationRate" 
                stroke="hsl(var(--primary))" 
                strokeWidth={2}
                dot={{ fill: 'hsl(var(--primary))', r: 3 }}
                name="Tỷ lệ di cư ròng (‰)"
                animationDuration={2000}
              />
            </ComposedChart>
          </ResponsiveContainer>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="bg-muted/30 p-6 rounded-lg">
            <div className="flex items-center gap-2 mb-3">
              <Building2 className="w-5 h-5 text-primary" />
              <h4 className="font-semibold">Đô thị hóa</h4>
            </div>
            <div className="flex items-baseline gap-3 mb-2">
              <span className="text-2xl font-bold text-primary">{firstData.urbanPopPercent}%</span>
              <span className="text-muted-foreground">→</span>
              <span className="text-2xl font-bold text-primary">{latestData.urbanPopPercent}%</span>
            </div>
            <p className="text-sm text-muted-foreground">Tăng {(latestData.urbanPopPercent - firstData.urbanPopPercent).toFixed(1)}% trong 70 năm</p>
          </div>

          <div className="bg-muted/30 p-6 rounded-lg">
            <div className="flex items-center gap-2 mb-3">
              <Home className="w-5 h-5 text-secondary" />
              <h4 className="font-semibold">Quy mô hộ gia đình</h4>
            </div>
            <div className="flex items-baseline gap-3 mb-2">
              <span className="text-2xl font-bold text-secondary">{firstData.householdSize}</span>
              <span className="text-muted-foreground">→</span>
              <span className="text-2xl font-bold text-secondary">{latestData.householdSize}</span>
            </div>
            <p className="text-sm text-muted-foreground">Người/hộ giảm theo thời gian</p>
          </div>

          <div className="bg-muted/30 p-6 rounded-lg">
            <div className="flex items-center gap-2 mb-3">
              <ArrowRightLeft className="w-5 h-5 text-accent" />
              <h4 className="font-semibold">Di cư quốc tế</h4>
            </div>
            <div className="flex items-baseline gap-3 mb-2">
              <span className="text-2xl font-bold text-accent">{latestData.migrantsNet.toLocaleString()}</span>
            </div>
            <p className="text-sm text-muted-foreground">Di cư ròng năm 2024</p>
          </div>
        </div>

        <div className="mt-8 bg-card/30 backdrop-blur-sm p-6 rounded-xl border border-border">
          <h4 className="font-semibold mb-3 flex items-center gap-2">
            <Building2 className="w-5 h-5 text-primary" />
            Xu Hướng Đô Thị Hóa
          </h4>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm text-muted-foreground">
            <div>
              <strong className="text-foreground">Tốc độ nhanh:</strong> Từ {firstData.urbanPopPercent}% (1955) lên {latestData.urbanPopPercent}% (2024), cao hơn trung bình thế giới
            </div>
            <div>
              <strong className="text-foreground">Thành phố lớn:</strong> TP.HCM, Hà Nội, Đà Nẵng, Hải Phòng, Cần Thơ thu hút di cư mạnh
            </div>
            <div>
              <strong className="text-foreground">Thách thức:</strong> Áp lực hạ tầng, ô nhiễm, giao thông, nhà ở tại các đô thị lớn
            </div>
            <div>
              <strong className="text-foreground">Cơ hội:</strong> Phát triển kinh tế, nâng cao đời sống, hiện đại hóa xã hội
            </div>
          </div>
        </div>

        <div className="mt-12 bg-accent/10 backdrop-blur-sm p-8 rounded-2xl border border-accent/30">
          <div className="flex items-start gap-4">
            <ArrowRightLeft className="w-8 h-8 text-accent flex-shrink-0 mt-1" />
            <div>
              <h3 className="text-2xl font-bold mb-3 text-accent">Di Cư Nội Bộ và Đô Thị Hóa</h3>
              <p className="text-lg text-muted-foreground leading-relaxed">
                Tỷ lệ đô thị hóa tăng từ {firstData.urbanPopPercent}% (1955) lên {latestData.urbanPopPercent}% (2024) - tăng gần {((latestData.urbanPopPercent / firstData.urbanPopPercent)).toFixed(1)} lần. 
                Dân số thành thị tăng từ {(firstData.population * firstData.urbanPopPercent / 100 / 1000000).toFixed(1)} triệu lên {(latestData.population * latestData.urbanPopPercent / 100 / 1000000).toFixed(1)} triệu người. 
                Làn sóng di cư từ nông thôn ra thành thị đang định hình lại bản đồ dân cư Việt Nam, 
                tạo ra cả cơ hội phát triển lẫn thách thức về hạ tầng đô thị và quản lý.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};