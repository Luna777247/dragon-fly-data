import { useEffect, useRef } from 'react';
import { Heart, TrendingDown } from 'lucide-react';
import { parseVietnamData } from '@/data/vietnamData';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend, Area, AreaChart } from 'recharts';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

export const SlideBirthDeath = () => {
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

      tl.from('.birth-title', {
        opacity: 0,
        scale: 0.9,
        duration: 1,
        ease: 'back.out(1.7)'
      })
      .from('.birth-chart', {
        opacity: 0,
        y: 40,
        duration: 0.8,
        ease: 'power3.out'
      }, '-=0.5')
      .from('.birth-card', {
        opacity: 0,
        scale: 0.8,
        duration: 0.6,
        stagger: 0.15,
        ease: 'back.out(1.7)'
      }, '-=0.4');
    }, containerRef);

    return () => ctx.revert();
  }, []);

  const vitalData = data.map(d => ({
    year: d.year,
    birthRate: d.birthRate,
    deathRate: d.deathRate,
    fertilityRate: d.fertilityRate,
    dependencyRatio: d.dependencyRatio
  }));
  const milestoneYears = [1955, 1960, 1965, 1970, 1975, 1980, 1985, 1990, 1995, 2000, 2005, 2010, 2015, 2020, 2025];

  const startData = data[0];
  const endData = data[data.length - 1];

  return (
    <div ref={containerRef} className="min-h-screen py-20 px-6 relative overflow-hidden">
      <div className="absolute inset-0 bg-gradient-to-br from-background via-primary/5 to-background" />
      
      {/* Animated hearts */}
      <div className="absolute inset-0 pointer-events-none overflow-hidden">
        {[...Array(20)].map((_, i) => (
          <div
            key={i}
            className="absolute animate-float"
            style={{
              left: `${Math.random() * 100}%`,
              top: `${Math.random() * 100}%`,
              animationDelay: `${Math.random() * 5}s`,
              animationDuration: `${8 + Math.random() * 4}s`,
              opacity: 0.08
            }}
          >
            <Heart className="w-6 h-6 text-primary" fill="currentColor" />
          </div>
        ))}
      </div>

      <div className="max-w-7xl mx-auto relative z-10">
        <div className="birth-title text-center mb-16">
          <Heart className="w-16 h-16 text-primary mx-auto mb-6 animate-pulse" fill="currentColor" />
          <h2 className="font-display text-5xl md:text-6xl font-bold mb-4">
            Trái Tim Rồng: <span className="text-primary dragon-glow">Sinh Sản & Sức Sống</span>
          </h2>
          <p className="text-xl text-muted-foreground">Từ bùng nổ đến ổn định</p>
        </div>

        <div className="birth-chart bg-card/50 backdrop-blur-sm p-8 rounded-2xl border border-border shadow-elegant mb-12">
          <h3 className="text-2xl font-bold mb-6">Tỷ Lệ Sinh - Tử (‰)</h3>
          <ResponsiveContainer width="100%" height={400}>
            <AreaChart data={vitalData}>
              <defs>
                <linearGradient id="birthGradient" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="hsl(var(--primary))" stopOpacity={0.8}/>
                  <stop offset="95%" stopColor="hsl(var(--primary))" stopOpacity={0.1}/>
                </linearGradient>
                <linearGradient id="deathGradient" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="hsl(var(--destructive))" stopOpacity={0.8}/>
                  <stop offset="95%" stopColor="hsl(var(--destructive))" stopOpacity={0.1}/>
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
                label={{ value: '‰ (phần nghìn)', angle: -90, position: 'insideLeft', fill: 'hsl(var(--muted-foreground))' }}
              />
              <Tooltip 
                contentStyle={{ 
                  backgroundColor: 'hsl(var(--card))', 
                  border: '1px solid hsl(var(--border))',
                  borderRadius: '8px'
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
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mb-12">
          <div className="birth-chart bg-card/50 backdrop-blur-sm p-8 rounded-2xl border border-border shadow-elegant">
            <h3 className="text-2xl font-bold mb-6">Tỷ Suất Sinh (Con/Phụ Nữ)</h3>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={vitalData}>
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
                />
                <Tooltip 
                  contentStyle={{ 
                    backgroundColor: 'hsl(var(--card))', 
                    border: '1px solid hsl(var(--border))',
                    borderRadius: '8px'
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
          </div>

          <div className="birth-chart bg-card/50 backdrop-blur-sm p-8 rounded-2xl border border-border shadow-elegant">
            <h3 className="text-2xl font-bold mb-6">Tỷ Lệ Phụ Thuộc (%)</h3>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={vitalData}>
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
                />
                <Tooltip 
                  contentStyle={{ 
                    backgroundColor: 'hsl(var(--card))', 
                    border: '1px solid hsl(var(--border))',
                    borderRadius: '8px'
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
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="birth-card bg-gradient-to-br from-primary/20 via-primary/10 to-transparent p-8 rounded-2xl border border-primary/30">
            <div className="text-sm text-muted-foreground mb-2">TỶ LỆ SINH</div>
            <div className="flex items-baseline gap-4 mb-4">
              <div className="text-4xl font-bold text-primary">{startData.birthRate}‰</div>
              <div className="text-2xl text-muted-foreground">→</div>
              <div className="text-4xl font-bold text-primary">{endData.birthRate}‰</div>
            </div>
            <div className="flex items-center gap-2 text-sm">
              <TrendingDown className="w-4 h-4 text-primary" />
              <span className="text-muted-foreground">Giảm {((startData.birthRate - endData.birthRate) / startData.birthRate * 100).toFixed(0)}%</span>
            </div>
          </div>

          <div className="birth-card bg-gradient-to-br from-secondary/20 via-secondary/10 to-transparent p-8 rounded-2xl border border-secondary/30">
            <div className="text-sm text-muted-foreground mb-2">TỶ SUẤT SINH</div>
            <div className="flex items-baseline gap-4 mb-4">
              <div className="text-4xl font-bold text-secondary">{startData.fertilityRate}</div>
              <div className="text-2xl text-muted-foreground">→</div>
              <div className="text-4xl font-bold text-secondary">{endData.fertilityRate}</div>
            </div>
            <div className="flex items-center gap-2 text-sm">
              <TrendingDown className="w-4 h-4 text-secondary" />
              <span className="text-muted-foreground">con/phụ nữ</span>
            </div>
          </div>

          <div className="birth-card bg-gradient-to-br from-accent/20 via-accent/10 to-transparent p-8 rounded-2xl border border-accent/30 animate-pulse">
            <div className="text-sm text-muted-foreground mb-2">PHỤ THUỘC</div>
            <div className="flex items-baseline gap-4 mb-4">
              <div className="text-4xl font-bold text-accent">{startData.dependencyRatio}%</div>
              <div className="text-2xl text-muted-foreground">→</div>
              <div className="text-4xl font-bold text-accent">{endData.dependencyRatio}%</div>
            </div>
            <div className="flex items-center gap-2 text-sm">
              <TrendingDown className="w-4 h-4 text-accent" />
              <span className="text-muted-foreground">Giảm {(startData.dependencyRatio - endData.dependencyRatio).toFixed(0)}%</span>
            </div>
          </div>
        </div>

        <div className="mt-12 bg-primary/10 backdrop-blur-sm p-8 rounded-2xl border border-primary/30">
          <div className="flex items-start gap-4">
            <Heart className="w-8 h-8 text-primary flex-shrink-0 mt-1" fill="currentColor" />
            <div>
              <h3 className="text-2xl font-bold mb-3 text-primary">Chuyển đổi nhân khẩu học</h3>
              <p className="text-lg text-muted-foreground leading-relaxed">
                Tỷ lệ sinh giảm từ {startData.birthRate}‰ xuống {endData.birthRate}‰, 
                tỷ suất sinh từ {startData.fertilityRate} xuống {endData.fertilityRate} con/phụ nữ. 
                Việt Nam đã hoàn thành chuyển đổi nhân khẩu học thành công, 
                từ bùng nổ dân số sang tăng trưởng ổn định và bền vững.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
