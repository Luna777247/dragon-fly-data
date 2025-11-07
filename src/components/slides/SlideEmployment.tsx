import { useEffect, useRef } from 'react';
import { Briefcase, TrendingUp } from 'lucide-react';
import { parseVietnamData } from '@/data/vietnamData';
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend } from 'recharts';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

export const SlideEmployment = () => {
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

      tl.from('.emp-title', {
        opacity: 0,
        y: 50,
        duration: 1,
        ease: 'power3.out'
      })
      .from('.emp-chart', {
        opacity: 0,
        scale: 0.9,
        duration: 0.8,
        ease: 'back.out(1.7)'
      }, '-=0.5')
      .from('.emp-card', {
        opacity: 0,
        y: 30,
        duration: 0.6,
        stagger: 0.15,
        ease: 'power2.out'
      }, '-=0.4');
    }, containerRef);

    return () => ctx.revert();
  }, []);

  const employmentData = data.map(d => ({
    year: d.year,
    agriculture: d.employmentAgriculture || 0,
    industry: d.employmentIndustry || 0,
    services: d.employmentServices || 0
  }));
  const milestoneYears = [1955, 1960, 1965, 1970, 1975, 1980, 1985, 1990, 1995, 2000, 2005, 2010, 2015, 2020, 2025];

  const startData = data[0];
  const endData = data[data.length - 1];

  return (
    <div ref={containerRef} className="min-h-screen py-20 px-6 relative overflow-hidden">
      <div className="absolute inset-0 bg-gradient-to-br from-background via-secondary/5 to-background" />
      
      <div className="max-w-7xl mx-auto relative z-10">
        <div className="emp-title text-center mb-16">
          <Briefcase className="w-16 h-16 text-secondary mx-auto mb-6 animate-pulse" />
          <h2 className="font-display text-5xl md:text-6xl font-bold mb-4">
            Sức Mạnh Rồng: <span className="text-secondary dragon-glow">Các Ngành Nghề</span>
          </h2>
          <p className="text-xl text-muted-foreground">Chuyển dịch cơ cấu lao động</p>
        </div>

        <div className="emp-chart bg-card/50 backdrop-blur-sm p-8 rounded-2xl border border-border shadow-elegant mb-12">
          <h3 className="text-2xl font-bold mb-6">Cơ Cấu Lao Động Theo Ngành (%)</h3>
          <ResponsiveContainer width="100%" height={400}>
            <AreaChart data={employmentData}>
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
                label={{ value: '% Lao động', angle: -90, position: 'insideLeft', fill: 'hsl(var(--muted-foreground))' }}
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
                dataKey="services" 
                stackId="1"
                stroke="hsl(var(--primary))" 
                fill="hsl(var(--primary) / 0.6)"
                name="Dịch vụ"
              />
              <Area 
                type="monotone" 
                dataKey="industry" 
                stackId="1"
                stroke="hsl(var(--accent))" 
                fill="hsl(var(--accent) / 0.6)"
                name="Công nghiệp"
              />
              <Area 
                type="monotone" 
                dataKey="agriculture" 
                stackId="1"
                stroke="hsl(var(--secondary))" 
                fill="hsl(var(--secondary) / 0.6)"
                name="Nông nghiệp"
              />
            </AreaChart>
          </ResponsiveContainer>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="emp-card bg-gradient-to-br from-secondary/20 via-secondary/10 to-transparent p-8 rounded-2xl border border-secondary/30">
            <div className="text-sm text-muted-foreground mb-2">NÔNG NGHIỆP</div>
            <div className="flex items-baseline gap-4 mb-4">
              <div className="text-4xl font-bold text-secondary">{startData.employmentAgriculture}%</div>
              <div className="text-2xl text-muted-foreground">→</div>
              <div className="text-4xl font-bold text-secondary">{endData.employmentAgriculture}%</div>
            </div>
            <div className="flex items-center gap-2 text-sm">
              <TrendingUp className="w-4 h-4 text-secondary rotate-180" />
              <span className="text-muted-foreground">Giảm {(startData.employmentAgriculture - endData.employmentAgriculture).toFixed(0)}%</span>
            </div>
          </div>

          <div className="emp-card bg-gradient-to-br from-accent/20 via-accent/10 to-transparent p-8 rounded-2xl border border-accent/30">
            <div className="text-sm text-muted-foreground mb-2">CÔNG NGHIỆP</div>
            <div className="flex items-baseline gap-4 mb-4">
              <div className="text-4xl font-bold text-accent">{startData.employmentIndustry}%</div>
              <div className="text-2xl text-muted-foreground">→</div>
              <div className="text-4xl font-bold text-accent">{endData.employmentIndustry}%</div>
            </div>
            <div className="flex items-center gap-2 text-sm">
              <TrendingUp className="w-4 h-4 text-accent rotate-180" />
              <span className="text-muted-foreground">Giảm {(startData.employmentIndustry - endData.employmentIndustry).toFixed(0)}%</span>
            </div>
          </div>

          <div className="emp-card bg-gradient-to-br from-primary/20 via-primary/10 to-transparent p-8 rounded-2xl border border-primary/30 animate-pulse">
            <div className="text-sm text-muted-foreground mb-2">DỊCH VỤ</div>
            <div className="flex items-baseline gap-4 mb-4">
              <div className="text-4xl font-bold text-primary">{startData.employmentServices}%</div>
              <div className="text-2xl text-muted-foreground">→</div>
              <div className="text-4xl font-bold text-primary">{endData.employmentServices}%</div>
            </div>
            <div className="flex items-center gap-2 text-sm">
              <TrendingUp className="w-4 h-4 text-primary" />
              <span className="text-muted-foreground">Tăng {(endData.employmentServices - startData.employmentServices).toFixed(0)}%</span>
            </div>
          </div>
        </div>

        <div className="mt-12 bg-secondary/10 backdrop-blur-sm p-8 rounded-2xl border border-secondary/30">
          <div className="flex items-start gap-4">
            <Briefcase className="w-8 h-8 text-secondary flex-shrink-0 mt-1" />
            <div>
              <h3 className="text-2xl font-bold mb-3 text-secondary">Chuyển Dịch Cơ Cấu Lao Động</h3>
              <p className="text-lg text-muted-foreground leading-relaxed">
                Tỷ trọng lao động nông nghiệp giảm từ {startData.employmentAgriculture}% (1955) xuống {endData.employmentAgriculture}% (2024), 
                trong khi lao động dịch vụ tăng từ {startData.employmentServices}% lên {endData.employmentServices}%. 
                Sự chuyển dịch này phản ánh quá trình công nghiệp hóa và hiện đại hóa thành công của Việt Nam. 
                Tuy nhiên, năng suất lao động vẫn còn thấp so với khu vực, đòi hỏi đầu tư mạnh hơn vào đào tạo nghề và công nghệ.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
