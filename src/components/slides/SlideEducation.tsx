import { useEffect, useRef } from 'react';
import { GraduationCap, BookOpen, TrendingUp } from 'lucide-react';
import { vietnamData } from '@/data/vietnamData';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend, ComposedChart, Bar } from 'recharts';
import { CustomTooltip } from '@/components/ui/custom-tooltip';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

export const SlideEducation = () => {
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!containerRef.current) return;

    const ctx = gsap.context(() => {
      gsap.from('.edu-title', {
        opacity: 0,
        y: 50,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        duration: 1,
        ease: 'power3.out'
      });

      gsap.from('.edu-stat', {
        opacity: 0,
        scale: 0.8,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        duration: 0.8,
        stagger: 0.2,
        ease: 'back.out(1.7)'
      });

      gsap.from('.edu-chart', {
        opacity: 0,
        y: 30,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        duration: 1.2,
        delay: 0.5,
        ease: 'power2.out'
      });
    }, containerRef);

    return () => ctx.revert();
  }, []);

  const chartData = vietnamData;
  const latestData = vietnamData[vietnamData.length - 1];
  const firstData = vietnamData[0];

  return (
    <div ref={containerRef} className="min-h-screen flex items-center justify-center py-20 px-6">
      <div className="max-w-6xl w-full">
        <div className="text-center mb-12">
          <h2 className="edu-title font-display text-4xl md:text-6xl font-bold mb-4">
            Trí Tuệ <span className="text-primary">Rồng</span>: Giáo Dục & Phát Triển
          </h2>
          <p className="text-muted-foreground text-lg">Đầu tư vào con người, đầu tư vào tương lai</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
          <div className="edu-stat bg-gradient-to-br from-primary/20 to-primary/5 p-6 rounded-xl border border-primary/30 shadow-lg">
            <GraduationCap className="w-8 h-8 text-primary mb-2" />
            <div className="text-3xl font-bold text-primary">{latestData.hdi.toFixed(3)}</div>
            <p className="text-sm text-muted-foreground mt-1">Chỉ số Phát triển Con người</p>
          </div>
          
          <div className="edu-stat bg-gradient-to-br from-secondary/20 to-secondary/5 p-6 rounded-xl border border-secondary/30 shadow-lg">
            <BookOpen className="w-8 h-8 text-secondary mb-2" />
            <div className="text-3xl font-bold text-secondary">{latestData.literacyRate}%</div>
            <p className="text-sm text-muted-foreground mt-1">Tỷ lệ biết chữ</p>
          </div>

          <div className="edu-stat bg-gradient-to-br from-accent/20 to-accent/5 p-6 rounded-xl border border-accent/30 shadow-lg">
            <div className="text-3xl font-bold text-accent">{latestData.meanYearsOfSchooling}</div>
            <p className="text-sm text-muted-foreground mt-1">Số năm đi học TB</p>
          </div>

          <div className="edu-stat bg-gradient-to-br from-primary-glow/20 to-primary-glow/5 p-6 rounded-xl border border-primary-glow/30 shadow-lg">
            <div className="text-3xl font-bold text-primary-glow">{latestData.expectedYearsOfSchooling}</div>
            <p className="text-sm text-muted-foreground mt-1">Số năm học dự kiến</p>
          </div>
        </div>

        <div className="edu-chart bg-card/50 backdrop-blur-sm p-8 rounded-2xl border border-border shadow-[0_0_50px_rgba(0,0,0,0.3)] mb-8">
          <h3 className="text-xl font-semibold mb-6 text-center">Tiến Bộ Giáo Dục Qua Các Thế Hệ</h3>
          <ResponsiveContainer width="100%" height={400}>
            <ComposedChart data={chartData}>
              <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" opacity={0.3} />
              <XAxis 
                dataKey="year" 
                stroke="hsl(var(--muted-foreground))"
                tick={{ fill: 'hsl(var(--muted-foreground))' }}
              />
              <YAxis 
                yAxisId="left"
                stroke="hsl(var(--muted-foreground))"
                tick={{ fill: 'hsl(var(--muted-foreground))' }}
                domain={[0, 1]}
              />
              <YAxis 
                yAxisId="right"
                orientation="right"
                stroke="hsl(var(--secondary))"
                tick={{ fill: 'hsl(var(--secondary))' }}
                domain={[0, 100]}
              />
              <Tooltip content={<CustomTooltip />} />
              <Legend />
              <Line 
                yAxisId="left"
                type="monotone" 
                dataKey="hdi" 
                stroke="hsl(var(--primary))" 
                strokeWidth={3}
                dot={{ fill: 'hsl(var(--primary))', r: 4 }}
                name="Chỉ số Phát triển"
                animationDuration={2000}
              />
              <Line 
                yAxisId="left"
                type="monotone" 
                dataKey="educationIndex" 
                stroke="hsl(var(--accent))" 
                strokeWidth={2}
                dot={{ fill: 'hsl(var(--accent))', r: 3 }}
                name="Chỉ số Giáo dục"
                animationDuration={2000}
              />
              <Line 
                yAxisId="right"
                type="monotone" 
                dataKey="literacyRate" 
                stroke="hsl(var(--secondary))" 
                strokeWidth={2}
                dot={{ fill: 'hsl(var(--secondary))', r: 3 }}
                name="Tỷ lệ biết chữ (%)"
                animationDuration={2000}
              />
            </ComposedChart>
          </ResponsiveContainer>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="bg-muted/30 p-6 rounded-lg">
            <div className="flex items-center gap-2 mb-3">
              <TrendingUp className="w-5 h-5 text-primary" />
              <h4 className="font-semibold">Chỉ số Con người</h4>
            </div>
            <div className="flex items-baseline gap-3">
              <span className="text-2xl font-bold text-primary">{firstData.hdi.toFixed(3)}</span>
              <span className="text-muted-foreground">→</span>
              <span className="text-2xl font-bold text-primary">{latestData.hdi.toFixed(3)}</span>
            </div>
            <p className="text-sm text-muted-foreground mt-2">Tăng {((latestData.hdi - firstData.hdi) * 100).toFixed(1)}% từ 1955</p>
          </div>

          <div className="bg-muted/30 p-6 rounded-lg">
            <div className="flex items-center gap-2 mb-3">
              <BookOpen className="w-5 h-5 text-secondary" />
              <h4 className="font-semibold">Biết chữ</h4>
            </div>
            <div className="flex items-baseline gap-3">
              <span className="text-2xl font-bold text-secondary">{firstData.literacyRate}%</span>
              <span className="text-muted-foreground">→</span>
              <span className="text-2xl font-bold text-secondary">{latestData.literacyRate}%</span>
            </div>
            <p className="text-sm text-muted-foreground mt-2">Tăng {(latestData.literacyRate - firstData.literacyRate).toFixed(0)}% trong 70 năm</p>
          </div>

          <div className="bg-muted/30 p-6 rounded-lg">
            <div className="flex items-center gap-2 mb-3">
              <GraduationCap className="w-5 h-5 text-accent" />
              <h4 className="font-semibold">Vốn Con người</h4>
            </div>
            <div className="flex items-baseline gap-3">
              <span className="text-2xl font-bold text-accent">{latestData.humanCapitalIndex.toFixed(2)}</span>
            </div>
            <p className="text-sm text-muted-foreground mt-2">Chỉ số Vốn Con người 2024</p>
          </div>
        </div>
      </div>
    </div>
  );
};