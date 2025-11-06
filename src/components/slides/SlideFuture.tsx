import { useEffect, useRef } from 'react';
import { Sparkles, TrendingUp, AlertCircle, Target } from 'lucide-react';
import { parseVietnamData } from '@/data/vietnamData';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend, Area, AreaChart } from 'recharts';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

export const SlideFuture = () => {
  const containerRef = useRef<HTMLDivElement>(null);
  const data = parseVietnamData();

  useEffect(() => {
    if (!containerRef.current) return;

    const ctx = gsap.context(() => {
      const tl = gsap.timeline({
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        }
      });

      tl.from('.future-title', {
        opacity: 0,
        y: 50,
        duration: 1,
        ease: 'power3.out'
      })
      .from('.future-chart', {
        opacity: 0,
        scale: 0.95,
        duration: 0.8,
        ease: 'back.out(1.7)'
      }, '-=0.5')
      .from('.future-card', {
        opacity: 0,
        y: 30,
        duration: 0.6,
        stagger: 0.15,
        ease: 'power2.out'
      }, '-=0.4');
    }, containerRef);

    return () => ctx.revert();
  }, []);

  // Historical data + forecast
  const historicalData = data;
  const milestoneYears = [1955, 1960, 1965, 1970, 1975, 1980, 1985, 1990, 1995, 2000, 2005, 2010, 2015, 2020, 2025, 2030, 2035];
  
  // Simple forecast to 2035 (linear projection)
  const lastPoint = data[data.length - 1];
  const growthRate = 0.005; // ~0.5% annual growth
  const gdpGrowth = 1.06; // 6% GDP growth
  
  const forecastData = [
    ...historicalData.map(d => ({
      year: d.year,
      population: d.population / 1000000,
      gdp: d.gdpBillion,
      type: 'historical'
    })),
    {
      year: 2025,
      population: lastPoint.population * (1 + growthRate) / 1000000,
      gdp: lastPoint.gdpBillion * gdpGrowth,
      type: 'forecast'
    },
    {
      year: 2030,
      population: lastPoint.population * Math.pow(1 + growthRate, 6) / 1000000,
      gdp: lastPoint.gdpBillion * Math.pow(gdpGrowth, 6),
      type: 'forecast'
    },
    {
      year: 2035,
      population: lastPoint.population * Math.pow(1 + growthRate, 11) / 1000000,
      gdp: lastPoint.gdpBillion * Math.pow(gdpGrowth, 11),
      type: 'forecast'
    }
  ];

  const forecast2030 = forecastData.find(d => d.year === 2030);

  return (
    <div ref={containerRef} className="min-h-screen py-20 px-6 relative overflow-hidden">
      <div className="absolute inset-0 bg-gradient-to-br from-background via-primary/10 to-accent/10" />
      
      {/* Animated sparkles */}
      <div className="absolute inset-0 pointer-events-none overflow-hidden">
        {[...Array(30)].map((_, i) => (
          <div
            key={i}
            className="absolute animate-shimmer"
            style={{
              left: `${Math.random() * 100}%`,
              top: `${Math.random() * 100}%`,
              animationDelay: `${Math.random() * 3}s`,
              animationDuration: `${2 + Math.random() * 2}s`,
            }}
          >
            <Sparkles className="w-4 h-4 text-primary" />
          </div>
        ))}
      </div>

      <div className="max-w-7xl mx-auto relative z-10">
        <div className="future-title text-center mb-16">
          <Sparkles className="w-16 h-16 text-primary mx-auto mb-6 animate-pulse" />
          <h2 className="font-display text-5xl md:text-6xl font-bold mb-4">
            Bay Về Tương Lai: <span className="text-primary dragon-glow">Dự Báo 2035</span>
          </h2>
          <p className="text-xl text-muted-foreground">Rồng sẽ bay đến đâu?</p>
        </div>

        <div className="future-chart bg-card/50 backdrop-blur-sm p-8 rounded-2xl border border-border shadow-elegant mb-12">
          <h3 className="text-2xl font-bold mb-6">Dự Báo Dân Số (Triệu Người)</h3>
          <ResponsiveContainer width="100%" height={400}>
            <AreaChart data={forecastData}>
              <defs>
                <linearGradient id="popGradient" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="hsl(var(--primary))" stopOpacity={0.8}/>
                  <stop offset="95%" stopColor="hsl(var(--primary))" stopOpacity={0.1}/>
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
              <XAxis 
                dataKey="year" 
                stroke="hsl(var(--muted-foreground))"
                tick={{ fill: 'hsl(var(--muted-foreground))' }}
                ticks={milestoneYears}
              />
              <YAxis 
                stroke="hsl(var(--muted-foreground))"
                tick={{ fill: 'hsl(var(--muted-foreground))' }}
                label={{ value: 'Triệu người', angle: -90, position: 'insideLeft', fill: 'hsl(var(--muted-foreground))' }}
              />
              <Tooltip 
                contentStyle={{ 
                  backgroundColor: 'hsl(var(--card))', 
                  border: '1px solid hsl(var(--border))',
                  borderRadius: '8px'
                }}
                formatter={(value: number) => [value.toFixed(1), 'Dân số (triệu)']}
              />
              <Area 
                type="monotone" 
                dataKey="population" 
                stroke="hsl(var(--primary))" 
                fill="url(#popGradient)"
                strokeWidth={3}
              />
            </AreaChart>
          </ResponsiveContainer>
          <div className="mt-4 text-sm text-muted-foreground text-center">
            <span className="inline-flex items-center gap-2">
              <div className="w-8 h-0.5 bg-primary" />
              Lịch sử
              <div className="w-8 h-0.5 bg-primary" style={{ backgroundImage: 'repeating-linear-gradient(to right, hsl(var(--primary)) 0, hsl(var(--primary)) 5px, transparent 5px, transparent 10px)' }} />
              Dự báo
            </span>
          </div>
        </div>

        <div className="future-chart bg-card/50 backdrop-blur-sm p-8 rounded-2xl border border-border shadow-elegant mb-12">
          <h3 className="text-2xl font-bold mb-6">Dự Báo GDP (Tỷ USD)</h3>
          <ResponsiveContainer width="100%" height={400}>
            <LineChart data={forecastData}>
              <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
              <XAxis 
                dataKey="year" 
                stroke="hsl(var(--muted-foreground))"
                tick={{ fill: 'hsl(var(--muted-foreground))' }}
                ticks={milestoneYears}
              />
              <YAxis 
                stroke="hsl(var(--muted-foreground))"
                tick={{ fill: 'hsl(var(--muted-foreground))' }}
                label={{ value: 'Tỷ USD', angle: -90, position: 'insideLeft', fill: 'hsl(var(--muted-foreground))' }}
              />
              <Tooltip 
                contentStyle={{ 
                  backgroundColor: 'hsl(var(--card))', 
                  border: '1px solid hsl(var(--border))',
                  borderRadius: '8px'
                }}
                formatter={(value: number) => [`$${value.toFixed(1)}B`, 'GDP']}
              />
              <Line 
                type="monotone" 
                dataKey="gdp" 
                stroke="hsl(var(--accent))" 
                strokeWidth={3}
                dot={{ fill: 'hsl(var(--accent))', r: 5 }}
              />
            </LineChart>
          </ResponsiveContainer>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12">
          <div className="future-card bg-gradient-to-br from-primary/20 via-primary/10 to-transparent p-8 rounded-2xl border border-primary/30 animate-pulse">
            <Target className="w-10 h-10 text-primary mb-4" />
            <div className="text-4xl font-bold text-primary mb-2">{forecast2030?.population.toFixed(1)}M</div>
            <div className="text-sm text-muted-foreground mb-3">Dân số dự báo 2030</div>
            <div className="flex items-center gap-2 text-sm">
              <TrendingUp className="w-4 h-4 text-primary" />
              <span className="text-muted-foreground">+{((forecast2030!.population - lastPoint.population / 1000000) / (lastPoint.population / 1000000) * 100).toFixed(1)}% từ 2024</span>
            </div>
          </div>

          <div className="future-card bg-gradient-to-br from-accent/20 via-accent/10 to-transparent p-8 rounded-2xl border border-accent/30">
            <Sparkles className="w-10 h-10 text-accent mb-4" />
            <div className="text-4xl font-bold text-accent mb-2">${forecast2030?.gdp.toFixed(0)}B</div>
            <div className="text-sm text-muted-foreground mb-3">GDP dự báo 2030</div>
            <div className="flex items-center gap-2 text-sm">
              <TrendingUp className="w-4 h-4 text-accent" />
              <span className="text-muted-foreground">×{(forecast2030!.gdp / lastPoint.gdpBillion).toFixed(1)} so với 2024</span>
            </div>
          </div>

          <div className="future-card bg-gradient-to-br from-secondary/20 via-secondary/10 to-transparent p-8 rounded-2xl border border-secondary/30">
            <AlertCircle className="w-10 h-10 text-secondary mb-4" />
            <div className="text-4xl font-bold text-secondary mb-2">~36</div>
            <div className="text-sm text-muted-foreground mb-3">Tuổi trung vị 2030</div>
            <div className="flex items-center gap-2 text-sm">
              <div className="text-secondary font-semibold">Già hóa</div>
              <span className="text-muted-foreground">Thách thức lớn</span>
            </div>
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="future-card bg-gradient-to-br from-primary/10 via-primary/5 to-transparent p-8 rounded-2xl border border-primary/20">
            <h3 className="text-xl font-bold mb-4 text-primary flex items-center gap-2">
              <TrendingUp className="w-6 h-6" />
              Cơ Hội
            </h3>
            <ul className="space-y-3 text-muted-foreground">
              <li className="flex items-start gap-2">
                <span className="text-primary mt-1">•</span>
                <span>Dân số trẻ, năng động với hơn 100 triệu người</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-primary mt-1">•</span>
                <span>Tăng trưởng kinh tế ổn định 6-7%/năm</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-primary mt-1">•</span>
                <span>Chuyển đổi số và công nghiệp hóa mạnh mẽ</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-primary mt-1">•</span>
                <span>Vị thế chiến lược trong khu vực ASEAN</span>
              </li>
            </ul>
          </div>

          <div className="future-card bg-gradient-to-br from-destructive/10 via-destructive/5 to-transparent p-8 rounded-2xl border border-destructive/20">
            <h3 className="text-xl font-bold mb-4 text-destructive flex items-center gap-2">
              <AlertCircle className="w-6 h-6" />
              Thách Thức
            </h3>
            <ul className="space-y-3 text-muted-foreground">
              <li className="flex items-start gap-2">
                <span className="text-destructive mt-1">•</span>
                <span>Già hóa dân số nhanh (tuổi trung vị tăng)</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-destructive mt-1">•</span>
                <span>Tỷ lệ sinh giảm xuống dưới mức thay thế</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-destructive mt-1">•</span>
                <span>Áp lực môi trường và biến đổi khí hậu</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-destructive mt-1">•</span>
                <span>Cần cân bằng tăng trưởng và bền vững</span>
              </li>
            </ul>
          </div>
        </div>

        <div className="mt-12 bg-gradient-to-r from-primary/20 via-accent/20 to-secondary/20 backdrop-blur-sm p-8 rounded-2xl border border-primary/30">
          <div className="flex items-start gap-4">
            <Sparkles className="w-8 h-8 text-primary flex-shrink-0 mt-1" />
            <div>
              <h3 className="text-2xl font-bold mb-3 text-primary">Sứ mệnh thế kỷ 21</h3>
              <p className="text-lg text-muted-foreground leading-relaxed">
                Đến năm 2030, Việt Nam dự kiến đạt {forecast2030?.population.toFixed(0)} triệu dân 
                và GDP ${forecast2030?.gdp.toFixed(0)} tỷ. Để duy trì đà phát triển, 
                chúng ta cần <strong className="text-foreground">bay cao nhưng phải bay xanh</strong> - 
                cân bằng hoàn hảo giữa tăng trưởng kinh tế, phát triển xã hội và bảo vệ môi trường. 
                Đây là thách thức và cũng là cơ hội để Việt Nam trở thành một "con rồng xanh" thực sự của châu Á.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
