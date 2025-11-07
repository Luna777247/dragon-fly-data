import { useEffect, useRef } from 'react';
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { vietnamData } from '@/data/vietnamData';
import { CustomTooltip } from '@/components/ui/custom-tooltip';
import { Feather, Sparkles } from 'lucide-react';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

export const SlideFeatherViz = () => {
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!containerRef.current) return;

    const ctx = gsap.context(() => {
      gsap.from('.feather-title', {
        opacity: 0,
        y: 50,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        duration: 1,
        ease: 'power3.out'
      });

      gsap.from('.feather-chart', {
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

      gsap.from('.feather-stat', {
        opacity: 0,
        x: -30,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        duration: 0.8,
        stagger: 0.1,
        ease: 'power2.out'
      });
    }, containerRef);

    return () => ctx.revert();
  }, []);

  const milestoneYears = [1955, 1960, 1965, 1970, 1975, 1980, 1985, 1990, 1995, 2000, 2005, 2010, 2015, 2020, 2025];

  // Prepare streaming data for multiple metrics
  const streamData = vietnamData.map(d => ({
    year: d.year,
    agriculture: d.employmentAgriculture,
    industry: d.employmentIndustry,
    services: d.employmentServices,
  }));

  const educationStreamData = vietnamData.map(d => ({
    year: d.year,
    literacy: d.literacyRate,
    education: d.educationIndex * 100,
    schooling: d.meanYearsOfSchooling * 10,
  }));

  const latestData = vietnamData[vietnamData.length - 1];

  return (
    <div ref={containerRef} className="min-h-screen py-20 px-6 relative overflow-hidden">
      <div className="absolute inset-0 bg-gradient-to-br from-background via-secondary/5 to-accent/5" />
      
      <div className="max-w-7xl mx-auto relative z-10">
        <div className="feather-title text-center mb-16">
          <Feather className="w-16 h-16 text-secondary mx-auto mb-6 animate-pulse" />
          <h2 className="font-display text-5xl md:text-6xl font-bold mb-4">
            Lông Vũ <span className="text-secondary dragon-glow">Chuyển Đổi</span>
          </h2>
          <p className="text-xl text-muted-foreground">Dòng chảy của sự thay đổi cấu trúc</p>
        </div>

        {/* Employment Structure Stream */}
        <div className="feather-chart bg-card/50 backdrop-blur-sm p-8 rounded-2xl border border-border shadow-elegant mb-12">
          <h3 className="text-2xl font-bold mb-6 flex items-center gap-3">
            <Sparkles className="w-6 h-6 text-primary" />
            Cơ Cấu Việc Làm - Dòng Chảy Chuyển Đổi
          </h3>
          <ResponsiveContainer width="100%" height={400}>
            <AreaChart data={streamData}>
              <defs>
                <linearGradient id="agriGradient" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="hsl(var(--accent))" stopOpacity={0.8}/>
                  <stop offset="95%" stopColor="hsl(var(--accent))" stopOpacity={0.1}/>
                </linearGradient>
                <linearGradient id="industryGradient" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="hsl(var(--secondary))" stopOpacity={0.8}/>
                  <stop offset="95%" stopColor="hsl(var(--secondary))" stopOpacity={0.1}/>
                </linearGradient>
                <linearGradient id="servicesGradient" x1="0" y1="0" x2="0" y2="1">
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
                stroke="hsl(var(--muted-foreground))"
                tick={{ fill: 'hsl(var(--muted-foreground))' }}
                label={{ value: '% Lao động', angle: -90, position: 'insideLeft' }}
              />
              <Tooltip content={<CustomTooltip />} />
              <Area 
                type="monotone" 
                dataKey="agriculture" 
                stackId="1"
                stroke="hsl(var(--accent))" 
                fill="url(#agriGradient)"
                name="Nông nghiệp"
              />
              <Area 
                type="monotone" 
                dataKey="industry" 
                stackId="1"
                stroke="hsl(var(--secondary))" 
                fill="url(#industryGradient)"
                name="Công nghiệp"
              />
              <Area 
                type="monotone" 
                dataKey="services" 
                stackId="1"
                stroke="hsl(var(--primary))" 
                fill="url(#servicesGradient)"
                name="Dịch vụ"
              />
            </AreaChart>
          </ResponsiveContainer>
        </div>

        {/* Education Stream */}
        <div className="feather-chart bg-card/50 backdrop-blur-sm p-8 rounded-2xl border border-border shadow-elegant mb-12">
          <h3 className="text-2xl font-bold mb-6 flex items-center gap-3">
            <Sparkles className="w-6 h-6 text-secondary" />
            Giáo Dục - Dòng Chảy Phát Triển
          </h3>
          <ResponsiveContainer width="100%" height={400}>
            <AreaChart data={educationStreamData}>
              <defs>
                <linearGradient id="literacyGradient" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="hsl(var(--primary))" stopOpacity={0.8}/>
                  <stop offset="95%" stopColor="hsl(var(--primary))" stopOpacity={0.1}/>
                </linearGradient>
                <linearGradient id="eduIndexGradient" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="hsl(var(--secondary))" stopOpacity={0.8}/>
                  <stop offset="95%" stopColor="hsl(var(--secondary))" stopOpacity={0.1}/>
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
              />
              <Tooltip content={<CustomTooltip />} />
              <Area 
                type="monotone" 
                dataKey="literacy" 
                stroke="hsl(var(--primary))" 
                fill="url(#literacyGradient)"
                name="Tỷ lệ biết chữ (%)"
              />
              <Area 
                type="monotone" 
                dataKey="education" 
                stroke="hsl(var(--secondary))" 
                fill="url(#eduIndexGradient)"
                name="Chỉ số giáo dục"
              />
            </AreaChart>
          </ResponsiveContainer>
        </div>

        {/* Stats Cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12">
          <div className="feather-stat bg-gradient-to-br from-accent/20 to-accent/5 p-6 rounded-xl border border-accent/30 shadow-lg">
            <div className="text-sm text-muted-foreground mb-2">Nông nghiệp</div>
            <div className="text-3xl font-bold text-accent">{latestData.employmentAgriculture}%</div>
            <div className="text-xs text-muted-foreground mt-2">Giảm từ 75% (1955)</div>
          </div>
          <div className="feather-stat bg-gradient-to-br from-secondary/20 to-secondary/5 p-6 rounded-xl border border-secondary/30 shadow-lg">
            <div className="text-sm text-muted-foreground mb-2">Công nghiệp</div>
            <div className="text-3xl font-bold text-secondary">{latestData.employmentIndustry}%</div>
            <div className="text-xs text-muted-foreground mt-2">Tăng từ 10% (1955)</div>
          </div>
          <div className="feather-stat bg-gradient-to-br from-primary/20 to-primary/5 p-6 rounded-xl border border-primary/30 shadow-lg">
            <div className="text-sm text-muted-foreground mb-2">Dịch vụ</div>
            <div className="text-3xl font-bold text-primary">{latestData.employmentServices}%</div>
            <div className="text-xs text-muted-foreground mt-2">Tăng từ 15% (1955)</div>
          </div>
        </div>

        {/* Insight */}
        <div className="bg-gradient-to-r from-secondary/10 via-primary/10 to-accent/10 backdrop-blur-sm p-8 rounded-2xl border border-secondary/30">
          <div className="flex items-start gap-4">
            <Feather className="w-8 h-8 text-secondary flex-shrink-0 mt-1" />
            <div>
              <h3 className="text-2xl font-bold mb-3 text-secondary">Dòng Chảy Chuyển Đổi Cấu Trúc</h3>
              <p className="text-lg text-muted-foreground leading-relaxed">
                Như những sợi lông vũ mềm mại nhưng mạnh mẽ, nền kinh tế Việt Nam đã chuyển đổi cơ cấu một cách linh hoạt. 
                Từ nền kinh tế nông nghiệp với 75% lao động (1955) sang nền kinh tế công nghiệp - dịch vụ với chỉ {latestData.employmentAgriculture}% 
                lao động nông nghiệp (2024). Dịch vụ giờ chiếm {latestData.employmentServices}%, công nghiệp {latestData.employmentIndustry}% - 
                một sự chuyển mình đáng kinh ngạc trong 70 năm.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
