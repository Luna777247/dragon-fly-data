import { useEffect, useRef, useState } from 'react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Bar, BarChart, ComposedChart } from 'recharts';
import { vietnamData } from '@/data/vietnamData';
import { TrendingUp, DollarSign, Maximize2 } from 'lucide-react';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import { ExportButtons } from '@/components/ExportButtons';
import { FullscreenChart } from '@/components/FullscreenChart';
import { Button } from '@/components/ui/button';

gsap.registerPlugin(ScrollTrigger);

export const SlideEconomy = () => {
  const containerRef = useRef<HTMLDivElement>(null);
  const [isFullscreen, setIsFullscreen] = useState(false);

  useEffect(() => {
    if (!containerRef.current) return;

    const ctx = gsap.context(() => {
      gsap.from('.econ-title', {
        opacity: 0,
        y: 50,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        duration: 1,
        ease: 'power3.out'
      });

      gsap.from('.econ-stat', {
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

      gsap.from('.econ-chart', {
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

  // Use all data points from 1955-2024
  const chartData = vietnamData;
  const milestoneYears = [1955, 1960, 1965, 1970, 1975, 1980, 1985, 1990, 1995, 2000, 2005, 2010, 2015, 2020, 2025];

  return (
    <div ref={containerRef} className="min-h-screen flex items-center justify-center py-20 px-6">
      <div className="max-w-6xl w-full">
        <div className="text-center mb-12">
          <h2 className="econ-title font-display text-4xl md:text-6xl font-bold mb-4">
            Cánh <span className="text-primary">Kinh Tế</span>: GDP Và Tăng Trưởng
          </h2>
          <p className="text-muted-foreground text-lg">Cánh rồng mở rộng, kinh tế cất cánh</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
          <div className="econ-stat bg-gradient-to-br from-primary/20 to-primary/5 p-6 rounded-xl border border-primary/30 shadow-lg">
            <DollarSign className="w-8 h-8 text-primary mb-2" />
            <div className="text-3xl font-bold text-primary">$476.4B</div>
            <p className="text-sm text-muted-foreground mt-1">GDP 2024</p>
          </div>
          
          <div className="econ-stat bg-gradient-to-br from-secondary/20 to-secondary/5 p-6 rounded-xl border border-secondary/30 shadow-lg">
            <TrendingUp className="w-8 h-8 text-secondary mb-2" />
            <div className="text-3xl font-bold text-secondary">$4,717</div>
            <p className="text-sm text-muted-foreground mt-1">GDP/người 2024</p>
          </div>

          <div className="econ-stat bg-gradient-to-br from-accent/20 to-accent/5 p-6 rounded-xl border border-accent/30 shadow-lg">
            <div className="text-3xl font-bold text-accent">×227</div>
            <p className="text-sm text-muted-foreground mt-1">Tăng GDP so với 1955</p>
          </div>

          <div className="econ-stat bg-gradient-to-br from-primary-glow/20 to-primary-glow/5 p-6 rounded-xl border border-primary-glow/30 shadow-lg">
            <div className="text-3xl font-bold text-primary-glow">×63</div>
            <p className="text-sm text-muted-foreground mt-1">Tăng thu nhập/người</p>
          </div>
        </div>

        <div id="economy-chart" className="econ-chart bg-card/50 backdrop-blur-sm p-8 rounded-2xl border border-border shadow-[0_0_50px_rgba(0,0,0,0.3)]">
          <div className="flex justify-between items-center mb-6">
            <h3 className="text-xl font-semibold">Hành Trình Tăng Trưởng GDP</h3>
            <div className="flex gap-2">
              <Button
                variant="outline"
                size="sm"
                onClick={() => setIsFullscreen(true)}
                className="gap-2"
              >
                <Maximize2 className="w-4 h-4" />
                Toàn màn hình
              </Button>
              <ExportButtons 
                elementId="economy-chart" 
                filename="gdp-viet-nam"
                data={chartData}
              />
            </div>
          </div>
          <ResponsiveContainer width="100%" height={400}>
            <ComposedChart data={chartData}>
              <defs>
                <linearGradient id="gdpGradient" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="hsl(var(--primary))" stopOpacity={0.8}/>
                  <stop offset="95%" stopColor="hsl(var(--primary))" stopOpacity={0.1}/>
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
                  color: 'hsl(var(--foreground))'
                }}
              />
              <Bar 
                yAxisId="left"
                dataKey="gdpBillion" 
                fill="url(#gdpGradient)"
                radius={[8, 8, 0, 0]}
                animationDuration={1500}
              />
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
        </div>

        <div className="mt-12 bg-gradient-to-r from-primary/10 via-secondary/10 to-accent/10 backdrop-blur-sm p-8 rounded-2xl border border-primary/30">
          <div className="flex items-start gap-4">
            <TrendingUp className="w-8 h-8 text-primary flex-shrink-0 mt-1" />
            <div>
              <h3 className="text-2xl font-bold mb-3 text-primary">Phép Màu Kinh Tế Việt Nam</h3>
              <p className="text-lg text-muted-foreground leading-relaxed">
                GDP tăng từ $2.1 tỷ (1955) lên $476.4 tỷ (2024) - tăng 227 lần trong 70 năm. 
                Thu nhập bình quân đầu người từ $75 lên $4,717 - tăng 63 lần. 
                Từ một nền kinh tế nông nghiệp nghèo nàn, Việt Nam đã chuyển mình thành một trong những nền kinh tế năng động nhất khu vực, 
                với tốc độ tăng trưởng bình quân 6-7%/năm kể từ Đổi Mới 1986.
              </p>
            </div>
          </div>
        </div>
      </div>

      <FullscreenChart
        isOpen={isFullscreen}
        onClose={() => setIsFullscreen(false)}
        title="Hành Trình Tăng Trưởng GDP"
      >
        <ResponsiveContainer width="100%" height="80%">
          <ComposedChart data={chartData}>
            <defs>
              <linearGradient id="gdpGradient" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="hsl(var(--primary))" stopOpacity={0.8}/>
                <stop offset="95%" stopColor="hsl(var(--primary))" stopOpacity={0.1}/>
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
                color: 'hsl(var(--foreground))'
              }}
            />
            <Bar 
              yAxisId="left"
              dataKey="gdpBillion" 
              fill="url(#gdpGradient)"
              radius={[8, 8, 0, 0]}
              animationDuration={1500}
            />
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
