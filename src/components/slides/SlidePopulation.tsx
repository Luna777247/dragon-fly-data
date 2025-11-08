import { useEffect, useRef, useState } from 'react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Area, AreaChart } from 'recharts';
import { vietnamData } from '@/data/vietnamData';
import { Users, Maximize2 } from 'lucide-react';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import { ExportButtons } from '@/components/ExportButtons';
import { FullscreenChart } from '@/components/FullscreenChart';
import { Button } from '@/components/ui/button';

gsap.registerPlugin(ScrollTrigger);

export const SlidePopulation = () => {
  const containerRef = useRef<HTMLDivElement>(null);
  const [counter, setCounter] = useState(28);
  const [isFullscreen, setIsFullscreen] = useState(false);

  useEffect(() => {
    if (!containerRef.current) return;

    const ctx = gsap.context(() => {
      // Counter animation
      gsap.to({ value: 28 }, {
        value: 101,
        duration: 2,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        onUpdate: function() {
          setCounter(Math.round(this.targets()[0].value));
        },
        ease: 'power2.out'
      });

      // Title animation
      gsap.from('.pop-title', {
        opacity: 0,
        y: 50,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        duration: 1,
        ease: 'power3.out'
      });

      // Chart animation
      gsap.from('.pop-chart', {
        opacity: 0,
        scale: 0.95,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        duration: 1.2,
        delay: 0.3,
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
          <h2 className="pop-title font-display text-4xl md:text-6xl font-bold mb-4">
            Cơ Thể <span className="text-primary">Rồng</span>: Tăng Trưởng Dân Số
          </h2>
          <div className="flex items-center justify-center gap-4 mt-8">
            <div className="text-center">
              <div className="text-5xl md:text-7xl font-bold text-primary dragon-glow">
                {counter}
              </div>
              <p className="text-muted-foreground mt-2">triệu người (2024)</p>
            </div>
            <div className="text-4xl text-muted-foreground">←</div>
            <div className="text-center">
              <div className="text-3xl md:text-5xl font-bold text-secondary">
                28
              </div>
              <p className="text-muted-foreground mt-2">triệu người (1955)</p>
            </div>
          </div>
        </div>

        <div id="population-chart" className="pop-chart bg-card/50 backdrop-blur-sm p-8 rounded-2xl border border-border shadow-[0_0_50px_rgba(0,0,0,0.3)]">
          <div className="flex justify-between items-center mb-4">
            <h3 className="text-xl font-semibold">Biểu Đồ Tăng Trưởng Dân Số</h3>
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
                elementId="population-chart" 
                filename="dan-so-viet-nam"
                data={chartData}
              />
            </div>
          </div>
          <ResponsiveContainer width="100%" height={400}>
            <AreaChart data={chartData}>
              <defs>
                <linearGradient id="populationGradient" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="hsl(var(--primary))" stopOpacity={0.8}/>
                  <stop offset="95%" stopColor="hsl(var(--primary))" stopOpacity={0}/>
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
                contentStyle={{ 
                  backgroundColor: 'hsl(var(--card))',
                  border: '1px solid hsl(var(--border))',
                  borderRadius: '8px',
                  color: 'hsl(var(--foreground))'
                }}
                formatter={(value: number) => [
                  `${(value / 1000000).toFixed(1)} triệu`,
                  'Dân số'
                ]}
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

          <div className="mt-6 grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="bg-muted/30 p-4 rounded-lg text-center">
              <div className="text-2xl font-bold text-primary">3.09%</div>
              <p className="text-sm text-muted-foreground">Tăng trưởng cao nhất (1955)</p>
            </div>
            <div className="bg-muted/30 p-4 rounded-lg text-center">
              <div className="text-2xl font-bold text-accent">0.63%</div>
              <p className="text-sm text-muted-foreground">Tăng trưởng hiện tại (2024)</p>
            </div>
            <div className="bg-muted/30 p-4 rounded-lg text-center">
              <div className="text-2xl font-bold text-secondary">×3.6</div>
              <p className="text-sm text-muted-foreground">Gấp 3.6 lần trong 70 năm</p>
            </div>
          </div>
        </div>

        <div className="mt-12 bg-primary/10 backdrop-blur-sm p-8 rounded-2xl border border-primary/30">
          <div className="flex items-start gap-4">
            <Users className="w-8 h-8 text-primary flex-shrink-0 mt-1" />
            <div>
              <h3 className="text-2xl font-bold mb-3 text-primary">Phân Tích Tăng Trưởng Dân Số</h3>
              <p className="text-lg text-muted-foreground leading-relaxed">
                Trong 70 năm (1955-2024), dân số Việt Nam tăng gấp 3.6 lần từ 28 triệu lên 101 triệu người. 
                Tốc độ tăng trưởng cao nhất đạt 3.09% vào năm 1955 trong giai đoạn bùng nổ dân số, 
                sau đó giảm dần xuống 0.63% năm 2024 khi chuyển sang giai đoạn ổn định. 
                Sự chuyển đổi này phản ánh thành công của chính sách dân số và sự phát triển kinh tế - xã hội.
              </p>
            </div>
          </div>
        </div>
      </div>

      <FullscreenChart
        isOpen={isFullscreen}
        onClose={() => setIsFullscreen(false)}
        title="Biểu Đồ Tăng Trưởng Dân Số"
      >
        <ResponsiveContainer width="100%" height="80%">
          <AreaChart data={chartData}>
            <defs>
              <linearGradient id="populationGradient" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="hsl(var(--primary))" stopOpacity={0.8}/>
                <stop offset="95%" stopColor="hsl(var(--primary))" stopOpacity={0}/>
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
              contentStyle={{ 
                backgroundColor: 'hsl(var(--card))',
                border: '1px solid hsl(var(--border))',
                borderRadius: '8px',
                color: 'hsl(var(--foreground))'
              }}
              formatter={(value: number) => [
                `${(value / 1000000).toFixed(1)} triệu`,
                'Dân số'
              ]}
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
      </FullscreenChart>
    </div>
  );
};
