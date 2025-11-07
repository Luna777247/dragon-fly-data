import { useEffect, useRef } from 'react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, RadarChart, PolarGrid, PolarAngleAxis, PolarRadiusAxis, Radar } from 'recharts';
import { vietnamData } from '@/data/vietnamData';
import { Heart, GraduationCap, TrendingUp } from 'lucide-react';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

export const SlideSociety = () => {
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!containerRef.current) return;

    const ctx = gsap.context(() => {
      gsap.from('.soc-title', {
        opacity: 0,
        y: 50,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        duration: 1,
        ease: 'power3.out'
      });

      gsap.from('.soc-card', {
        opacity: 0,
        y: 30,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        duration: 0.8,
        stagger: 0.15,
        ease: 'power2.out'
      });
    }, containerRef);

    return () => ctx.revert();
  }, []);

  const lifeExpData = vietnamData;
  const milestoneYears = [1955, 1960, 1965, 1970, 1975, 1980, 1985, 1990, 1995, 2000, 2005, 2010, 2015, 2020, 2025];
  
  const radarData = [
    { subject: 'HDI', value: 0.84, fullMark: 1 },
    { subject: 'Tuổi thọ', value: 75.9, fullMark: 85 },
    { subject: 'Đô thị hóa', value: 40.6, fullMark: 100 },
    { subject: 'GDP/người', value: 4717, fullMark: 10000 },
  ];

  return (
    <div ref={containerRef} className="min-h-screen flex items-center justify-center py-20 px-6">
      <div className="max-w-6xl w-full">
        <div className="text-center mb-12">
          <h2 className="soc-title font-display text-4xl md:text-6xl font-bold mb-4">
            Hồn <span className="text-primary">Rồng</span>: Phát Triển Con Người
          </h2>
          <p className="text-muted-foreground text-lg">Sức mạnh thực sự đến từ sự phát triển toàn diện</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <div className="soc-card bg-gradient-to-br from-primary/20 to-primary/5 p-8 rounded-2xl border border-primary/30 shadow-lg text-center">
            <Heart className="w-12 h-12 text-primary mx-auto mb-4" />
            <div className="text-4xl font-bold text-primary mb-2">75.9</div>
            <p className="text-muted-foreground">Tuổi thọ trung bình</p>
            <div className="mt-4 text-sm">
              <span className="text-secondary">+17.9 năm</span>
              <p className="text-muted-foreground text-xs mt-1">so với 1955</p>
            </div>
          </div>

          <div className="soc-card bg-gradient-to-br from-secondary/20 to-secondary/5 p-8 rounded-2xl border border-secondary/30 shadow-lg text-center">
            <GraduationCap className="w-12 h-12 text-secondary mx-auto mb-4" />
            <div className="text-4xl font-bold text-secondary mb-2">0.84</div>
            <p className="text-muted-foreground">Chỉ số HDI</p>
            <div className="mt-4 text-sm">
              <span className="text-primary">+140%</span>
              <p className="text-muted-foreground text-xs mt-1">Tăng từ 0.35 (1955)</p>
            </div>
          </div>

          <div className="soc-card bg-gradient-to-br from-accent/20 to-accent/5 p-8 rounded-2xl border border-accent/30 shadow-lg text-center">
            <TrendingUp className="w-12 h-12 text-accent mx-auto mb-4" />
            <div className="text-4xl font-bold text-accent mb-2">40.6%</div>
            <p className="text-muted-foreground">Dân số đô thị</p>
            <div className="mt-4 text-sm">
              <span className="text-secondary">×3.1</span>
              <p className="text-muted-foreground text-xs mt-1">so với 1955 (13.1%)</p>
            </div>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="bg-card/50 backdrop-blur-sm p-6 rounded-2xl border border-border shadow-[0_0_50px_rgba(0,0,0,0.3)]">
            <h3 className="text-xl font-semibold mb-4 text-center">Tuổi Thọ Qua Các Thập Kỷ</h3>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={lifeExpData}>
                <defs>
                  <linearGradient id="lifeGradient" x1="0" y1="0" x2="0" y2="1">
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
                  domain={[55, 80]}
                  stroke="hsl(var(--muted-foreground))"
                  tick={{ fill: 'hsl(var(--muted-foreground))' }}
                />
                <Tooltip 
                  contentStyle={{ 
                    backgroundColor: 'hsl(var(--card))',
                    border: '1px solid hsl(var(--border))',
                    borderRadius: '8px',
                  }}
                />
                <Line 
                  type="monotone" 
                  dataKey="lifeExpectancy" 
                  stroke="hsl(var(--primary))" 
                  strokeWidth={3}
                  fill="url(#lifeGradient)"
                  dot={{ fill: 'hsl(var(--primary))', r: 5 }}
                />
              </LineChart>
            </ResponsiveContainer>
          </div>

          <div className="bg-card/50 backdrop-blur-sm p-6 rounded-2xl border border-border shadow-[0_0_50px_rgba(0,0,0,0.3)]">
            <h3 className="text-xl font-semibold mb-4 text-center">Chỉ Số Phát Triển 2024</h3>
            <ResponsiveContainer width="100%" height={300}>
              <RadarChart data={radarData}>
                <PolarGrid stroke="hsl(var(--border))" />
                <PolarAngleAxis 
                  dataKey="subject" 
                  tick={{ fill: 'hsl(var(--foreground))' }}
                />
                <PolarRadiusAxis angle={90} domain={[0, 'dataMax']} />
                <Radar 
                  name="Việt Nam" 
                  dataKey="value" 
                  stroke="hsl(var(--primary))" 
                  fill="hsl(var(--primary))" 
                  fillOpacity={0.6}
                />
              </RadarChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="mt-12 bg-primary/10 backdrop-blur-sm p-8 rounded-2xl border border-primary/30">
          <div className="flex items-start gap-4">
            <Heart className="w-8 h-8 text-primary flex-shrink-0 mt-1" />
            <div>
              <h3 className="text-2xl font-bold mb-3 text-primary">Phát Triển Con Người Toàn Diện</h3>
              <p className="text-lg text-muted-foreground leading-relaxed">
                Tuổi thọ tăng từ {vietnamData[0].lifeExpectancy} lên {vietnamData[vietnamData.length - 1].lifeExpectancy} tuổi (+{(vietnamData[vietnamData.length - 1].lifeExpectancy - vietnamData[0].lifeExpectancy).toFixed(1)} năm), 
                HDI tăng từ {vietnamData[0].hdi.toFixed(2)} lên {vietnamData[vietnamData.length - 1].hdi.toFixed(2)} (+{((vietnamData[vietnamData.length - 1].hdi / vietnamData[0].hdi - 1) * 100).toFixed(0)}%). 
                Những con số này phản ánh sự tiến bộ vượt bậc về chất lượng cuộc sống, y tế và giáo dục. 
                Việt Nam đã chứng minh rằng tăng trưởng kinh tế đi đôi với phát triển con người là hoàn toàn khả thi.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
