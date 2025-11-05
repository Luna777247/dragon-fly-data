import { useEffect, useRef } from 'react';
import { TrendingUp, DollarSign, ArrowUpRight, ArrowDownRight } from 'lucide-react';
import { vietnamData } from '@/data/vietnamData';
import { ComposedChart, Line, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend, Area, AreaChart } from 'recharts';
import { CustomTooltip } from '@/components/ui/custom-tooltip';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

export const SlideTrade = () => {
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!containerRef.current) return;

    const ctx = gsap.context(() => {
      gsap.from('.trade-title', {
        opacity: 0,
        y: 50,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        duration: 1,
        ease: 'power3.out'
      });

      gsap.from('.trade-stat', {
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

      gsap.from('.trade-chart', {
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

  const chartData = vietnamData;
  const latestData = vietnamData[vietnamData.length - 1];
  const firstData = vietnamData[0];

  return (
    <div ref={containerRef} className="min-h-screen flex items-center justify-center py-20 px-6">
      <div className="max-w-6xl w-full">
        <div className="text-center mb-12">
          <h2 className="trade-title font-display text-4xl md:text-6xl font-bold mb-4">
            Cánh <span className="text-primary">Thương Mại</span>: Xuất Nhập Khẩu & FDI
          </h2>
          <p className="text-muted-foreground text-lg">Hội nhập toàn cầu, thu hút đầu tư</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
          <div className="trade-stat bg-gradient-to-br from-primary/20 to-primary/5 p-6 rounded-xl border border-primary/30 shadow-lg">
            <ArrowUpRight className="w-8 h-8 text-primary mb-2" />
            <div className="text-3xl font-bold text-primary">{latestData.exportsPercent}%</div>
            <p className="text-sm text-muted-foreground mt-1">Xuất khẩu / GDP</p>
          </div>
          
          <div className="trade-stat bg-gradient-to-br from-secondary/20 to-secondary/5 p-6 rounded-xl border border-secondary/30 shadow-lg">
            <ArrowDownRight className="w-8 h-8 text-secondary mb-2" />
            <div className="text-3xl font-bold text-secondary">{latestData.importsPercent}%</div>
            <p className="text-sm text-muted-foreground mt-1">Nhập khẩu / GDP</p>
          </div>

          <div className="trade-stat bg-gradient-to-br from-accent/20 to-accent/5 p-6 rounded-xl border border-accent/30 shadow-lg">
            <DollarSign className="w-8 h-8 text-accent mb-2" />
            <div className="text-3xl font-bold text-accent">${latestData.fdiNetInflows}</div>
            <p className="text-sm text-muted-foreground mt-1">FDI (triệu USD) 2024</p>
          </div>

          <div className="trade-stat bg-gradient-to-br from-primary-glow/20 to-primary-glow/5 p-6 rounded-xl border border-primary-glow/30 shadow-lg">
            <TrendingUp className="w-8 h-8 text-primary-glow mb-2" />
            <div className="text-3xl font-bold text-primary-glow">${latestData.gdpPPPPerCapita}</div>
            <p className="text-sm text-muted-foreground mt-1">GDP PPP/người</p>
          </div>
        </div>

        <div className="trade-chart bg-card/50 backdrop-blur-sm p-8 rounded-2xl border border-border shadow-[0_0_50px_rgba(0,0,0,0.3)] mb-8">
          <h3 className="text-xl font-semibold mb-6 text-center">Xuất Nhập Khẩu Theo Thời Gian</h3>
          <ResponsiveContainer width="100%" height={400}>
            <AreaChart data={chartData}>
              <defs>
                <linearGradient id="exportsGradient" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="hsl(var(--primary))" stopOpacity={0.8}/>
                  <stop offset="95%" stopColor="hsl(var(--primary))" stopOpacity={0.1}/>
                </linearGradient>
                <linearGradient id="importsGradient" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="hsl(var(--secondary))" stopOpacity={0.8}/>
                  <stop offset="95%" stopColor="hsl(var(--secondary))" stopOpacity={0.1}/>
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" opacity={0.3} />
              <XAxis 
                dataKey="year" 
                stroke="hsl(var(--muted-foreground))"
                tick={{ fill: 'hsl(var(--muted-foreground))' }}
              />
              <YAxis 
                stroke="hsl(var(--muted-foreground))"
                tick={{ fill: 'hsl(var(--muted-foreground))' }}
                label={{ value: '% GDP', angle: -90, position: 'insideLeft', fill: 'hsl(var(--muted-foreground))' }}
              />
              <Tooltip content={<CustomTooltip />} />
              <Legend />
              <Area 
                type="monotone" 
                dataKey="exportsPercent" 
                stroke="hsl(var(--primary))" 
                strokeWidth={2}
                fill="url(#exportsGradient)"
                name="Xuất khẩu (%)"
                animationDuration={2000}
              />
              <Area 
                type="monotone" 
                dataKey="importsPercent" 
                stroke="hsl(var(--secondary))" 
                strokeWidth={2}
                fill="url(#importsGradient)"
                name="Nhập khẩu (%)"
                animationDuration={2000}
              />
            </AreaChart>
          </ResponsiveContainer>
        </div>

        <div className="trade-chart bg-card/50 backdrop-blur-sm p-8 rounded-2xl border border-border shadow-[0_0_50px_rgba(0,0,0,0.3)] mb-8">
          <h3 className="text-xl font-semibold mb-6 text-center">Dòng Vốn Đầu Tư Nước Ngoài (FDI)</h3>
          <ResponsiveContainer width="100%" height={350}>
            <ComposedChart data={chartData}>
              <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" opacity={0.3} />
              <XAxis 
                dataKey="year" 
                stroke="hsl(var(--muted-foreground))"
                tick={{ fill: 'hsl(var(--muted-foreground))' }}
              />
              <YAxis 
                stroke="hsl(var(--muted-foreground))"
                tick={{ fill: 'hsl(var(--muted-foreground))' }}
                tickFormatter={(value) => `$${value}`}
              />
              <Tooltip 
                content={<CustomTooltip 
                  formatter={(value: number) => [`$${value} triệu`, 'FDI']}
                />} 
              />
              <Bar 
                dataKey="fdiNetInflows" 
                fill="hsl(var(--accent))"
                radius={[8, 8, 0, 0]}
                animationDuration={1500}
              />
            </ComposedChart>
          </ResponsiveContainer>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="bg-muted/30 p-6 rounded-lg">
            <h4 className="font-semibold mb-3">Xuất khẩu</h4>
            <div className="flex items-baseline gap-3 mb-2">
              <span className="text-2xl font-bold text-primary">{firstData.exportsPercent}%</span>
              <span className="text-muted-foreground">→</span>
              <span className="text-2xl font-bold text-primary">{latestData.exportsPercent}%</span>
            </div>
            <p className="text-sm text-muted-foreground">Tăng {(latestData.exportsPercent - firstData.exportsPercent).toFixed(0)}% từ 1955</p>
          </div>

          <div className="bg-muted/30 p-6 rounded-lg">
            <h4 className="font-semibold mb-3">Nhập khẩu</h4>
            <div className="flex items-baseline gap-3 mb-2">
              <span className="text-2xl font-bold text-secondary">{firstData.importsPercent}%</span>
              <span className="text-muted-foreground">→</span>
              <span className="text-2xl font-bold text-secondary">{latestData.importsPercent}%</span>
            </div>
            <p className="text-sm text-muted-foreground">Tăng {(latestData.importsPercent - firstData.importsPercent).toFixed(0)}% từ 1955</p>
          </div>

          <div className="bg-muted/30 p-6 rounded-lg">
            <h4 className="font-semibold mb-3">FDI</h4>
            <div className="flex items-baseline gap-3 mb-2">
              <span className="text-2xl font-bold text-accent">${firstData.fdiNetInflows}</span>
              <span className="text-muted-foreground">→</span>
              <span className="text-2xl font-bold text-accent">${latestData.fdiNetInflows}</span>
            </div>
            <p className="text-sm text-muted-foreground">Tăng mạnh sau Đổi mới 1986</p>
          </div>
        </div>
      </div>
    </div>
  );
};