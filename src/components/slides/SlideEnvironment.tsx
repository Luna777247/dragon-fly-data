import { useEffect, useRef } from 'react';
import { Leaf, AlertTriangle } from 'lucide-react';
import { parseVietnamData } from '@/data/vietnamData';
import { ComposedChart, Line, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend } from 'recharts';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

export const SlideEnvironment = () => {
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

      tl.from('.env-title', {
        opacity: 0,
        scale: 0.9,
        duration: 1,
        ease: 'back.out(1.7)'
      })
      .from('.env-chart', {
        opacity: 0,
        y: 40,
        duration: 0.8,
        ease: 'power3.out'
      }, '-=0.5')
      .from('.env-stat', {
        opacity: 0,
        x: -20,
        duration: 0.6,
        stagger: 0.1,
        ease: 'power2.out'
      }, '-=0.4');
    }, containerRef);

    return () => ctx.revert();
  }, []);

  const envData = data.map(d => ({
    year: d.year,
    forestArea: d.forestAreaPercent,
    co2: d.co2PerCapita
  }));
  const milestoneYears = [1955, 1960, 1965, 1970, 1975, 1980, 1985, 1990, 1995, 2000, 2005, 2010, 2015, 2020, 2025];

  const startData = data[0];
  const endData = data[data.length - 1];

  return (
    <div ref={containerRef} className="min-h-screen py-20 px-6 relative overflow-hidden">
      <div className="absolute inset-0 bg-gradient-to-br from-background via-background to-secondary/10" />
      
      {/* Animated leaves */}
      <div className="absolute inset-0 pointer-events-none overflow-hidden">
        {[...Array(15)].map((_, i) => (
          <div
            key={i}
            className="absolute animate-float"
            style={{
              left: `${Math.random() * 100}%`,
              top: `${Math.random() * 100}%`,
              animationDelay: `${Math.random() * 5}s`,
              animationDuration: `${5 + Math.random() * 5}s`,
              opacity: 0.1
            }}
          >
            <Leaf className="w-8 h-8 text-secondary" />
          </div>
        ))}
      </div>

      <div className="max-w-7xl mx-auto relative z-10">
        <div className="env-title text-center mb-16">
          <Leaf className="w-16 h-16 text-secondary mx-auto mb-6 animate-pulse" />
          <h2 className="font-display text-5xl md:text-6xl font-bold mb-4">
            Móng Vuốt Xanh: <span className="text-secondary dragon-glow">Thách Thức Thiên Nhiên</span>
          </h2>
          <p className="text-xl text-muted-foreground">Bay cao, nhưng phải bay xanh</p>
        </div>

        <div className="env-chart bg-card/50 backdrop-blur-sm p-8 rounded-2xl border border-border shadow-elegant mb-12">
          <ResponsiveContainer width="100%" height={400}>
            <ComposedChart data={envData}>
              <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
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
                label={{ value: '% Rừng', angle: -90, position: 'insideLeft', fill: 'hsl(var(--muted-foreground))' }}
              />
              <YAxis 
                yAxisId="right"
                orientation="right"
                stroke="hsl(var(--muted-foreground))"
                tick={{ fill: 'hsl(var(--muted-foreground))' }}
                label={{ value: 'CO₂ (tấn/người)', angle: 90, position: 'insideRight', fill: 'hsl(var(--muted-foreground))' }}
              />
              <Tooltip 
                contentStyle={{ 
                  backgroundColor: 'hsl(var(--card))', 
                  border: '1px solid hsl(var(--border))',
                  borderRadius: '8px'
                }}
              />
              <Legend />
              <Bar 
                yAxisId="left"
                dataKey="forestArea" 
                fill="hsl(var(--secondary) / 0.6)" 
                name="Diện tích rừng (%)"
              />
              <Line 
                yAxisId="right"
                type="monotone" 
                dataKey="co2" 
                stroke="hsl(var(--destructive))" 
                strokeWidth={3}
                dot={{ fill: 'hsl(var(--destructive))', r: 5 }}
                name="CO₂/người (tấn)"
              />
            </ComposedChart>
          </ResponsiveContainer>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="env-stat bg-gradient-to-br from-secondary/20 via-secondary/10 to-transparent p-8 rounded-2xl border border-secondary/30">
            <Leaf className="w-10 h-10 text-secondary mb-4" />
            <div className="text-4xl font-bold text-secondary mb-2">{endData.forestAreaPercent}%</div>
            <div className="text-sm text-muted-foreground mb-3">Diện tích rừng 2024</div>
            <div className="flex items-center gap-2 text-sm">
              <div className="text-secondary font-semibold">+{(endData.forestAreaPercent - startData.forestAreaPercent).toFixed(1)}%</div>
              <span className="text-muted-foreground">so với 1955</span>
            </div>
          </div>

          <div className="env-stat bg-gradient-to-br from-destructive/20 via-destructive/10 to-transparent p-8 rounded-2xl border border-destructive/30">
            <AlertTriangle className="w-10 h-10 text-destructive mb-4 animate-pulse" />
            <div className="text-4xl font-bold text-destructive mb-2">{endData.co2PerCapita}t</div>
            <div className="text-sm text-muted-foreground mb-3">CO₂/người năm 2024</div>
            <div className="flex items-center gap-2 text-sm">
              <div className="text-destructive font-semibold">×{(endData.co2PerCapita / startData.co2PerCapita).toFixed(0)}</div>
              <span className="text-muted-foreground">tăng từ 1955</span>
            </div>
          </div>

          <div className="env-stat bg-gradient-to-br from-accent/20 via-accent/10 to-transparent p-8 rounded-2xl border border-accent/30">
            <div className="text-sm text-muted-foreground mb-2">PHÁT TRIỂN</div>
            <div className="text-4xl font-bold text-accent mb-2">{endData.hdi.toFixed(3)}</div>
            <div className="text-sm text-muted-foreground mb-3">Chỉ số HDI năm 2024</div>
            <div className="flex items-center gap-2 text-sm">
              <div className="text-accent font-semibold">×{(endData.hdi / startData.hdi).toFixed(1)}</div>
              <span className="text-muted-foreground">tăng từ 1955</span>
            </div>
          </div>
        </div>

        <div className="mt-12 bg-secondary/10 backdrop-blur-sm p-8 rounded-2xl border border-secondary/30">
          <div className="flex items-start gap-4">
            <Leaf className="w-8 h-8 text-secondary flex-shrink-0 mt-1" />
            <div>
              <h3 className="text-2xl font-bold mb-3 text-secondary">Thông điệp xanh</h3>
              <p className="text-lg text-muted-foreground leading-relaxed">
                Việt Nam đã tăng diện tích rừng từ {startData.forestAreaPercent}% lên {endData.forestAreaPercent}%, 
                nhưng phát thải CO₂ cũng tăng {(endData.co2PerCapita / startData.co2PerCapita).toFixed(0)}× 
                cùng với phát triển kinh tế. Thách thức lớn nhất là cân bằng giữa tăng trưởng và bảo vệ môi trường.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
