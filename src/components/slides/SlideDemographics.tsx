import { useEffect, useRef } from 'react';
import { Users, TrendingUp } from 'lucide-react';
import { parseVietnamData } from '@/data/vietnamData';
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, LineChart, Line } from 'recharts';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

export const SlideDemographics = () => {
  const containerRef = useRef<HTMLDivElement>(null);
  const data = parseVietnamData();

  // Sample data for key years
  const keyYears = data.filter(d => 
    d.year === 1955 || d.year === 1975 || d.year === 1990 || d.year === 2000 || d.year === 2024
  );

  useEffect(() => {
    if (!containerRef.current) return;

    const ctx = gsap.context(() => {
      const tl = gsap.timeline({
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        }
      });

      tl.from('.demo-title', {
        opacity: 0,
        y: 50,
        duration: 1,
        ease: 'power3.out'
      })
      .from('.demo-chart', {
        opacity: 0,
        scale: 0.9,
        duration: 0.8,
        stagger: 0.2,
        ease: 'back.out(1.7)'
      }, '-=0.5')
      .from('.demo-stat', {
        opacity: 0,
        y: 20,
        duration: 0.6,
        stagger: 0.1,
        ease: 'power2.out'
      }, '-=0.4');
    }, containerRef);

    return () => ctx.revert();
  }, []);

  // Use all data points from 1955-2024
  const medianAgeData = data.map(d => ({
    year: d.year,
    medianAge: d.medianAge,
    fertility: d.fertilityRate
  }));

  return (
    <div ref={containerRef} className="min-h-screen py-20 px-6 relative overflow-hidden">
      <div className="absolute inset-0 bg-gradient-to-br from-background via-background/95 to-primary/5" />
      
      <div className="max-w-7xl mx-auto relative z-10">
        <div className="demo-title text-center mb-16">
          <Users className="w-16 h-16 text-secondary mx-auto mb-6 animate-pulse" />
          <h2 className="font-display text-5xl md:text-6xl font-bold mb-4">
            Cánh Bay: <span className="text-secondary dragon-glow">Di Chuyển & Tuổi Tác</span>
          </h2>
          <p className="text-xl text-muted-foreground">Dân số trưởng thành cùng đất nước</p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-12">
          <div className="demo-chart bg-card/50 backdrop-blur-sm p-8 rounded-2xl border border-border shadow-elegant">
            <h3 className="text-2xl font-bold mb-6 flex items-center gap-3">
              <TrendingUp className="w-6 h-6 text-secondary" />
              Tuổi Trung Vị Qua Thời Gian
            </h3>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={medianAgeData}>
                <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
                <XAxis 
                  dataKey="year" 
                  stroke="hsl(var(--muted-foreground))"
                  tick={{ fill: 'hsl(var(--muted-foreground))' }}
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
                  dataKey="medianAge" 
                  stroke="hsl(var(--secondary))" 
                  strokeWidth={3}
                  dot={{ fill: 'hsl(var(--secondary))', r: 4 }}
                  name="Tuổi trung vị"
                />
              </LineChart>
            </ResponsiveContainer>
          </div>

          <div className="demo-chart bg-card/50 backdrop-blur-sm p-8 rounded-2xl border border-border shadow-elegant">
            <h3 className="text-2xl font-bold mb-6">Tỷ Lệ Sinh Con</h3>
            <ResponsiveContainer width="100%" height={300}>
              <AreaChart data={medianAgeData}>
                <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
                <XAxis 
                  dataKey="year" 
                  stroke="hsl(var(--muted-foreground))"
                  tick={{ fill: 'hsl(var(--muted-foreground))' }}
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
                <Area 
                  type="monotone" 
                  dataKey="fertility" 
                  stroke="hsl(var(--accent))" 
                  fill="hsl(var(--accent) / 0.3)"
                  strokeWidth={2}
                  name="Tỷ lệ sinh"
                />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
          {keyYears.map((d, idx) => (
            <div 
              key={d.year}
              className="demo-stat bg-gradient-to-br from-card/80 to-card/40 backdrop-blur-sm p-6 rounded-xl border border-border hover:border-secondary transition-all duration-300 hover:scale-105"
              style={{ animationDelay: `${idx * 100}ms` }}
            >
              <div className="text-sm text-muted-foreground mb-2">Năm {d.year}</div>
              <div className="text-3xl font-bold text-secondary mb-1">{d.medianAge} tuổi</div>
              <div className="text-xs text-muted-foreground">Tuổi trung vị</div>
              <div className="mt-3 pt-3 border-t border-border">
                <div className="text-sm font-semibold text-accent">{d.fertilityRate} con/người</div>
                <div className="text-xs text-muted-foreground">Tỷ lệ sinh</div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};
