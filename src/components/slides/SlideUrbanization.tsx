import { useEffect, useRef } from 'react';
import { Building2, MapPin, TrendingUp } from 'lucide-react';
import { parseVietnamData } from '@/data/vietnamData';
import { ComposedChart, Area, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend } from 'recharts';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

export const SlideUrbanization = () => {
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

      tl.from('.urban-title', {
        opacity: 0,
        scale: 0.8,
        duration: 1,
        ease: 'back.out(1.7)'
      })
      .from('.urban-chart', {
        opacity: 0,
        y: 50,
        duration: 0.8,
        ease: 'power3.out'
      }, '-=0.5')
      .from('.urban-highlight', {
        opacity: 0,
        x: -30,
        duration: 0.6,
        stagger: 0.15,
        ease: 'power2.out'
      }, '-=0.3');
    }, containerRef);

    return () => ctx.revert();
  }, []);

  const urbanData = data.map(d => {
    const urbanPop = (d.population * d.urbanPopPercent / 100) / 1000000;
    const ruralPop = (d.population * (100 - d.urbanPopPercent) / 100) / 1000000;
    return {
      year: d.year,
      urbanPopPercent: d.urbanPopPercent,
      ruralPop,
      urbanPop
    };
  });
  const milestoneYears = [1955, 1960, 1965, 1970, 1975, 1980, 1985, 1990, 1995, 2000, 2005, 2010, 2015, 2020, 2025];

  const startData = data[0];
  const endData = data[data.length - 1];

  return (
    <div ref={containerRef} className="min-h-screen py-20 px-6 relative overflow-hidden">
      <div className="absolute inset-0 bg-gradient-to-br from-background via-accent/5 to-background" />
      
      {/* Animated city silhouette */}
      <div className="absolute bottom-0 left-0 right-0 h-32 opacity-10">
        {[...Array(20)].map((_, i) => (
          <div
            key={i}
            className="absolute bottom-0 bg-accent animate-breathe"
            style={{
              left: `${i * 5}%`,
              width: `${2 + Math.random() * 3}%`,
              height: `${30 + Math.random() * 70}%`,
              animationDelay: `${Math.random() * 2}s`,
              animationDuration: `${3 + Math.random() * 2}s`
            }}
          />
        ))}
      </div>

      <div className="max-w-7xl mx-auto relative z-10">
        <div className="urban-title text-center mb-16">
          <Building2 className="w-16 h-16 text-accent mx-auto mb-6 animate-pulse" />
          <h2 className="font-display text-5xl md:text-6xl font-bold mb-4">
            Móng Vuốt Đô Thị: <span className="text-accent dragon-glow">Sự Chuyển Dịch Thành Thị</span>
          </h2>
          <p className="text-xl text-muted-foreground">Từ làng quê đến thành phố</p>
        </div>

        <div className="urban-chart bg-card/50 backdrop-blur-sm p-8 rounded-2xl border border-border shadow-elegant mb-12">
          <ResponsiveContainer width="100%" height={400}>
            <ComposedChart data={urbanData}>
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
                label={{ value: 'Dân số (triệu)', angle: -90, position: 'insideLeft', fill: 'hsl(var(--muted-foreground))' }}
              />
              <YAxis 
                yAxisId="right"
                orientation="right"
                stroke="hsl(var(--muted-foreground))"
                tick={{ fill: 'hsl(var(--muted-foreground))' }}
                label={{ value: '% Đô thị', angle: 90, position: 'insideRight', fill: 'hsl(var(--muted-foreground))' }}
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
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="urban-highlight bg-gradient-to-br from-accent/20 via-accent/10 to-transparent p-8 rounded-2xl border border-accent/30">
            <MapPin className="w-10 h-10 text-accent mb-4" />
            <div className="text-4xl font-bold text-accent mb-2">{startData.urbanPopPercent}%</div>
            <div className="text-sm text-muted-foreground mb-4">Đô thị hóa năm 1955</div>
            <div className="text-2xl font-semibold">{(startData.population * startData.urbanPopPercent / 100 / 1000000).toFixed(1)}M người</div>
          </div>

          <div className="urban-highlight bg-gradient-to-br from-primary/20 via-primary/10 to-transparent p-8 rounded-2xl border border-primary/30">
            <Building2 className="w-10 h-10 text-primary mb-4 animate-pulse" />
            <div className="text-4xl font-bold text-primary mb-2">{endData.urbanPopPercent}%</div>
            <div className="text-sm text-muted-foreground mb-4">Đô thị hóa năm 2024</div>
            <div className="text-2xl font-semibold">{(endData.population * endData.urbanPopPercent / 100 / 1000000).toFixed(1)}M người</div>
          </div>

          <div className="urban-highlight bg-gradient-to-br from-secondary/20 via-secondary/10 to-transparent p-8 rounded-2xl border border-secondary/30">
            <TrendingUp className="w-10 h-10 text-secondary mb-4" />
            <div className="text-4xl font-bold text-secondary mb-2">×{((endData.population * endData.urbanPopPercent) / (startData.population * startData.urbanPopPercent)).toFixed(1)}</div>
            <div className="text-sm text-muted-foreground mb-4">Tăng trưởng</div>
            <div className="text-2xl font-semibold">+{(endData.urbanPopPercent - startData.urbanPopPercent).toFixed(1)}%</div>
          </div>
        </div>

        <div className="mt-12 bg-accent/10 backdrop-blur-sm p-8 rounded-2xl border border-accent/30">
          <div className="flex items-start gap-4">
            <Building2 className="w-8 h-8 text-accent flex-shrink-0 mt-1" />
            <div>
              <h3 className="text-2xl font-bold mb-3 text-accent">Cuộc Cách Mạng Đô Thị Hóa</h3>
              <p className="text-lg text-muted-foreground leading-relaxed">
                Dân số đô thị tăng từ {(startData.population * startData.urbanPopPercent / 100 / 1000000).toFixed(1)} triệu ({startData.urbanPopPercent}%) 
                lên {(endData.population * endData.urbanPopPercent / 100 / 1000000).toFixed(1)} triệu ({endData.urbanPopPercent}%) - 
                tăng {((endData.population * endData.urbanPopPercent) / (startData.population * startData.urbanPopPercent)).toFixed(1)} lần trong 70 năm. 
                Đô thị hóa là động lực mạnh mẽ cho tăng trưởng kinh tế, nhưng cũng đặt ra thách thức lớn về hạ tầng, 
                môi trường và quản lý đô thị bền vững.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
