import { useEffect, useRef } from 'react';
import { RadialBarChart, RadialBar, Legend, ResponsiveContainer, PolarAngleAxis } from 'recharts';
import { vietnamData } from '@/data/vietnamData';
import { Flower2, TrendingUp } from 'lucide-react';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

export const SlideRadialViz = () => {
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!containerRef.current) return;

    const ctx = gsap.context(() => {
      gsap.from('.radial-title', {
        opacity: 0,
        y: 50,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        duration: 1,
        ease: 'power3.out'
      });

      gsap.from('.radial-petal', {
        opacity: 0,
        scale: 0,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        duration: 1.2,
        stagger: 0.1,
        ease: 'back.out(1.7)'
      });

      gsap.from('.radial-insight', {
        opacity: 0,
        y: 30,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        duration: 0.8,
        delay: 0.5,
        ease: 'power2.out'
      });
    }, containerRef);

    return () => ctx.revert();
  }, []);

  // Select key milestone years
  const milestoneYears = [1955, 1975, 1990, 2000, 2010, 2024];
  const radialData = vietnamData
    .filter(d => milestoneYears.includes(d.year))
    .map(d => ({
      year: d.year.toString(),
      population: Math.round(d.population / 1000000), // in millions
      gdp: Math.round(d.gdpBillion),
      urbanization: Math.round(d.urbanPopPercent),
      literacy: Math.round(d.literacyRate),
      lifeExpectancy: Math.round(d.lifeExpectancy),
      fill: getYearColor(d.year)
    }));

  function getYearColor(year: number): string {
    const colors = [
      'hsl(var(--primary))',
      'hsl(var(--secondary))',
      'hsl(var(--accent))',
      'hsl(220, 70%, 50%)',
      'hsl(160, 70%, 50%)',
      'hsl(280, 70%, 60%)',
    ];
    const index = milestoneYears.indexOf(year);
    return colors[index] || colors[0];
  }

  return (
    <div ref={containerRef} className="min-h-screen flex items-center justify-center py-20 px-6 relative overflow-hidden">
      <div className="absolute inset-0 bg-gradient-radial from-primary/5 via-background to-background" />
      
      <div className="max-w-7xl w-full relative z-10">
        <div className="text-center mb-12">
          <Flower2 className="radial-title w-16 h-16 text-primary mx-auto mb-6 animate-pulse" />
          <h2 className="radial-title font-display text-4xl md:text-6xl font-bold mb-4">
            Bông Hoa <span className="text-primary">Phát Triển</span>
          </h2>
          <p className="radial-title text-muted-foreground text-lg">
            Mỗi cánh hoa là một thập kỷ tăng trưởng
          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
          {/* Radial Chart - Population Growth */}
          <div className="radial-petal bg-card/50 backdrop-blur-sm p-8 rounded-2xl border border-border shadow-elegant">
            <h3 className="text-2xl font-bold mb-6 text-center flex items-center justify-center gap-2">
              <TrendingUp className="w-6 h-6 text-primary" />
              Dân Số Qua Các Mốc Thời Gian
            </h3>
            <ResponsiveContainer width="100%" height={400}>
              <RadialBarChart 
                cx="50%" 
                cy="50%" 
                innerRadius="20%" 
                outerRadius="90%" 
                data={radialData}
                startAngle={180}
                endAngle={-180}
              >
                <PolarAngleAxis type="number" domain={[0, 105]} angleAxisId={0} tick={false} />
                <RadialBar
                  background
                  dataKey="population"
                  cornerRadius={10}
                  label={{ position: 'insideStart', fill: '#fff', fontSize: 14, fontWeight: 'bold' }}
                />
                <Legend 
                  iconSize={10} 
                  layout="vertical" 
                  verticalAlign="middle" 
                  align="right"
                  formatter={(value, entry: any) => `${entry.payload.year} (${entry.payload.population}M người)`}
                />
              </RadialBarChart>
            </ResponsiveContainer>
          </div>

          {/* Radial Chart - GDP Growth */}
          <div className="radial-petal bg-card/50 backdrop-blur-sm p-8 rounded-2xl border border-border shadow-elegant">
            <h3 className="text-2xl font-bold mb-6 text-center flex items-center justify-center gap-2">
              <TrendingUp className="w-6 h-6 text-secondary" />
              GDP Qua Các Mốc Thời Gian
            </h3>
            <ResponsiveContainer width="100%" height={400}>
              <RadialBarChart 
                cx="50%" 
                cy="50%" 
                innerRadius="20%" 
                outerRadius="90%" 
                data={radialData}
                startAngle={180}
                endAngle={-180}
              >
                <PolarAngleAxis type="number" domain={[0, 500]} angleAxisId={0} tick={false} />
                <RadialBar
                  background
                  dataKey="gdp"
                  cornerRadius={10}
                  label={{ position: 'insideStart', fill: '#fff', fontSize: 14, fontWeight: 'bold' }}
                />
                <Legend 
                  iconSize={10} 
                  layout="vertical" 
                  verticalAlign="middle" 
                  align="right"
                  formatter={(value, entry: any) => `${entry.payload.year} ($${entry.payload.gdp}B)`}
                />
              </RadialBarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Petal Stats Grid */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mt-12">
          {radialData.map((d, idx) => (
            <div 
              key={d.year}
              className="radial-petal bg-gradient-to-br from-card/80 to-card/40 backdrop-blur-sm p-6 rounded-xl border border-border hover:border-primary transition-all duration-300 hover:scale-105 hover:shadow-lg"
              style={{ animationDelay: `${idx * 100}ms` }}
            >
              <div className="text-sm text-muted-foreground mb-2">Năm {d.year}</div>
              <div className="space-y-2">
                <div>
                  <div className="text-2xl font-bold text-primary">{d.population}M</div>
                  <div className="text-xs text-muted-foreground">Dân số</div>
                </div>
                <div className="pt-2 border-t border-border">
                  <div className="text-lg font-semibold text-secondary">{d.urbanization}%</div>
                  <div className="text-xs text-muted-foreground">Đô thị hóa</div>
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* Insight Panel */}
        <div className="radial-insight mt-12 bg-gradient-to-r from-primary/10 via-secondary/10 to-accent/10 backdrop-blur-sm p-8 rounded-2xl border border-primary/30">
          <div className="flex items-start gap-4">
            <Flower2 className="w-8 h-8 text-primary flex-shrink-0 mt-1" />
            <div>
              <h3 className="text-2xl font-bold mb-3 text-primary">Hình Dạng Bông Hoa Phát Triển</h3>
              <p className="text-lg text-muted-foreground leading-relaxed">
                Mỗi "cánh hoa" đại diện cho một giai đoạn phát triển của đất nước. Từ năm 1955 với dân số {radialData[0].population} triệu người 
                đến 2024 với {radialData[radialData.length - 1].population} triệu người - bông hoa Việt Nam đã nở rộ với tốc độ đáng kinh ngạc. 
                GDP tăng từ ${radialData[0].gdp}B lên ${radialData[radialData.length - 1].gdp}B, đô thị hóa từ {radialData[0].urbanization}% 
                lên {radialData[radialData.length - 1].urbanization}% - mỗi cánh hoa là một câu chuyện thành công.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
