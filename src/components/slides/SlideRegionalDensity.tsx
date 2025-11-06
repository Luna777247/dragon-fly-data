import { useEffect, useRef } from 'react';
import { Map, Users } from 'lucide-react';
import { vietnamData } from '@/data/vietnamData';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend } from 'recharts';
import { CustomTooltip } from '@/components/ui/custom-tooltip';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

export const SlideRegionalDensity = () => {
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!containerRef.current) return;

    const ctx = gsap.context(() => {
      gsap.from('.regional-title', {
        opacity: 0,
        y: 50,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        duration: 1,
        ease: 'power3.out'
      });

      gsap.from('.regional-stat', {
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

      gsap.from('.regional-chart', {
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
  const milestoneYears = [1955, 1960, 1965, 1970, 1975, 1980, 1985, 1990, 1995, 2000, 2005, 2010, 2015, 2020, 2025];
  const latestData = vietnamData[vietnamData.length - 1];

  return (
    <div ref={containerRef} className="min-h-screen flex items-center justify-center py-20 px-6">
      <div className="max-w-6xl w-full">
        <div className="text-center mb-12">
          <h2 className="regional-title font-display text-4xl md:text-6xl font-bold mb-4">
            Vảy <span className="text-primary">Rồng</span>: Phân Bố Dân Số Theo Vùng
          </h2>
          <p className="text-muted-foreground text-lg">Mật độ dân số qua các vùng miền</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
          <div className="regional-stat bg-gradient-to-br from-primary/20 to-primary/5 p-6 rounded-xl border border-primary/30 shadow-lg">
            <Map className="w-8 h-8 text-primary mb-2" />
            <div className="text-3xl font-bold text-primary">{latestData.densityDBSH}</div>
            <p className="text-sm text-muted-foreground mt-1">ĐBSH (người/km²)</p>
          </div>
          
          <div className="regional-stat bg-gradient-to-br from-secondary/20 to-secondary/5 p-6 rounded-xl border border-secondary/30 shadow-lg">
            <Map className="w-8 h-8 text-secondary mb-2" />
            <div className="text-3xl font-bold text-secondary">{latestData.densityDBSCL}</div>
            <p className="text-sm text-muted-foreground mt-1">ĐBSCL (người/km²)</p>
          </div>

          <div className="regional-stat bg-gradient-to-br from-accent/20 to-accent/5 p-6 rounded-xl border border-accent/30 shadow-lg">
            <Map className="w-8 h-8 text-accent mb-2" />
            <div className="text-3xl font-bold text-accent">{latestData.densityMienTrung}</div>
            <p className="text-sm text-muted-foreground mt-1">Miền Trung (người/km²)</p>
          </div>

          <div className="regional-stat bg-gradient-to-br from-primary-glow/20 to-primary-glow/5 p-6 rounded-xl border border-primary-glow/30 shadow-lg">
            <Map className="w-8 h-8 text-primary-glow mb-2" />
            <div className="text-3xl font-bold text-primary-glow">{latestData.densityMienNui}</div>
            <p className="text-sm text-muted-foreground mt-1">Miền Núi (người/km²)</p>
          </div>
        </div>

        <div className="regional-chart bg-card/50 backdrop-blur-sm p-8 rounded-2xl border border-border shadow-[0_0_50px_rgba(0,0,0,0.3)] mb-8">
          <h3 className="text-xl font-semibold mb-6 text-center">Mật Độ Dân Số Theo Vùng Qua Thời Gian</h3>
          <ResponsiveContainer width="100%" height={400}>
            <LineChart data={chartData}>
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
                label={{ value: 'Người/km²', angle: -90, position: 'insideLeft', fill: 'hsl(var(--muted-foreground))' }}
              />
              <Tooltip content={<CustomTooltip />} />
              <Legend />
              <Line 
                type="monotone" 
                dataKey="densityDBSH" 
                stroke="hsl(var(--primary))" 
                strokeWidth={3}
                dot={{ fill: 'hsl(var(--primary))', r: 4 }}
                name="Đồng bằng Sông Hồng"
                animationDuration={2000}
              />
              <Line 
                type="monotone" 
                dataKey="densityDBSCL" 
                stroke="hsl(var(--secondary))" 
                strokeWidth={2}
                dot={{ fill: 'hsl(var(--secondary))', r: 3 }}
                name="Đồng bằng Sông Cửu Long"
                animationDuration={2000}
              />
              <Line 
                type="monotone" 
                dataKey="densityMienTrung" 
                stroke="hsl(var(--accent))" 
                strokeWidth={2}
                dot={{ fill: 'hsl(var(--accent))', r: 3 }}
                name="Miền Trung"
                animationDuration={2000}
              />
              <Line 
                type="monotone" 
                dataKey="densityMienNui" 
                stroke="hsl(var(--primary-glow))" 
                strokeWidth={2}
                dot={{ fill: 'hsl(var(--primary-glow))', r: 3 }}
                name="Miền Núi"
                animationDuration={2000}
              />
            </LineChart>
          </ResponsiveContainer>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div className="bg-muted/30 p-6 rounded-lg">
            <div className="flex items-center gap-2 mb-4">
              <Users className="w-6 h-6 text-primary" />
              <h4 className="font-semibold text-lg">Vùng Đông Dân Nhất</h4>
            </div>
            <div className="space-y-3">
              <div className="flex justify-between items-center">
                <span className="text-muted-foreground">1. Đồng bằng Sông Hồng</span>
                <span className="text-xl font-bold text-primary">{latestData.densityDBSH}</span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-muted-foreground">2. Đồng bằng SCL</span>
                <span className="text-xl font-bold text-secondary">{latestData.densityDBSCL}</span>
              </div>
            </div>
          </div>

          <div className="bg-muted/30 p-6 rounded-lg">
            <div className="flex items-center gap-2 mb-4">
              <Map className="w-6 h-6 text-accent" />
              <h4 className="font-semibold text-lg">Chênh Lệch Mật Độ</h4>
            </div>
            <div className="space-y-3">
              <div className="flex justify-between items-center">
                <span className="text-muted-foreground">Cao nhất / Thấp nhất</span>
                <span className="text-xl font-bold text-accent">
                  ×{(latestData.densityDBSH / latestData.densityMienNui).toFixed(1)}
                </span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-muted-foreground">Mật độ TB toàn quốc</span>
                <span className="text-xl font-bold text-primary-glow">{latestData.densityPerKm2}</span>
              </div>
            </div>
          </div>
        </div>

        <div className="mt-8 bg-card/30 backdrop-blur-sm p-6 rounded-xl border border-border">
          <h4 className="font-semibold mb-3 flex items-center gap-2">
            <Users className="w-5 h-5 text-primary" />
            Phân Tích Vùng Miền
          </h4>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm text-muted-foreground">
            <div>
              <strong className="text-foreground">Đồng bằng Sông Hồng:</strong> Vùng đông dân nhất, trung tâm chính trị, văn hóa với Hà Nội
            </div>
            <div>
              <strong className="text-foreground">Đồng bằng SCL:</strong> "Vựa lúa" của Việt Nam, mật độ cao, phát triển nông nghiệp
            </div>
            <div>
              <strong className="text-foreground">Miền Trung:</strong> Dải đất hẹp, mật độ trung bình, nhiều thành phố ven biển
            </div>
            <div>
              <strong className="text-foreground">Miền Núi:</strong> Mật độ thấp nhất, địa hình khó khăn, đa dạng dân tộc
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};