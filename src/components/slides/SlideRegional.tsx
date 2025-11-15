import { useEffect, useRef } from 'react';
import { MILESTONE_YEARS } from '@/constants/slideConstants';
import { Globe, TrendingUp, Award } from 'lucide-react';
import { vietnamData } from '@/data/vietnamData';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Legend, LineChart, Line } from 'recharts';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

export const SlideRegional = () => {
  const containerRef = useRef<HTMLDivElement>(null);
  const data = vietnamData;

  useEffect(() => {
    if (!containerRef.current) return;

    const ctx = gsap.context(() => {
      const tl = gsap.timeline({
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        }
      });

      tl.from('.regional-title', {
        opacity: 0,
        scale: 0.9,
        duration: 1,
        ease: 'back.out(1.7)'
      })
      .from('.regional-chart', {
        opacity: 0,
        y: 40,
        duration: 0.8,
        stagger: 0.2,
        ease: 'power3.out'
      }, '-=0.5')
      .from('.regional-card', {
        opacity: 0,
        x: -30,
        duration: 0.6,
        stagger: 0.15,
        ease: 'power2.out'
      }, '-=0.4');
    }, containerRef);

    return () => ctx.revert();
  }, []);

  const regionalData = data.map(d => ({
    year: d.year,
    vnShare: (d.population / 8161972572 * 100).toFixed(2), // Approximate Asian pop
    rank: 18 - Math.floor((d.year - 1955) / 10), // Simulated ranking improvement
    medianAge: d.medianAge,
    fertility: d.fertilityRate
  }));
  const milestoneYears = MILESTONE_YEARS;

  const endData = data[data.length - 1];
  const startData = data[0];

  // ASEAN comparison data (simulated)
  const aseanData = [
    { country: 'Indonesia', population: 277.5, color: 'hsl(var(--destructive))' },
    { country: 'Philippines', population: 117.3, color: 'hsl(var(--accent))' },
    { country: 'Việt Nam', population: 101.0, color: 'hsl(var(--primary))' },
    { country: 'Thailand', population: 71.8, color: 'hsl(var(--secondary))' },
    { country: 'Myanmar', population: 54.6, color: 'hsl(var(--muted))' },
  ];

  return (
    <div ref={containerRef} className="min-h-screen py-20 px-6 relative overflow-hidden">
      <div className="absolute inset-0 bg-gradient-to-br from-background via-accent/5 to-background" />
      
      {/* Animated globes */}
      <div className="absolute inset-0 pointer-events-none overflow-hidden">
        {[...Array(12)].map((_, i) => (
          <div
            key={i}
            className="absolute animate-float"
            style={{
              left: `${Math.random() * 100}%`,
              top: `${Math.random() * 100}%`,
              animationDelay: `${Math.random() * 5}s`,
              animationDuration: `${6 + Math.random() * 4}s`,
              opacity: 0.06
            }}
          >
            <Globe className="w-12 h-12 text-accent" />
          </div>
        ))}
      </div>

      <div className="max-w-7xl mx-auto relative z-10">
        <div className="regional-title text-center mb-16">
          <Globe className="w-16 h-16 text-accent mx-auto mb-6 animate-pulse" />
          <h2 className="font-display text-5xl md:text-6xl font-bold mb-4">
            Rồng Trong Châu Á: <span className="text-accent dragon-glow">Vị Thế Khu Vực</span>
          </h2>
          <p className="text-xl text-muted-foreground">Bay cao giữa các con rồng</p>
        </div>

        <div className="regional-chart bg-card/50 backdrop-blur-sm p-8 rounded-2xl border border-border shadow-elegant mb-12">
          <h3 className="text-2xl font-bold mb-6">Dân Số ASEAN 2024 (Triệu Người)</h3>
          <ResponsiveContainer width="100%" height={400}>
            <BarChart data={aseanData} layout="vertical">
              <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
              <XAxis 
                type="number"
                stroke="hsl(var(--muted-foreground))"
                tick={{ fill: 'hsl(var(--muted-foreground))' }}
              />
              <YAxis 
                type="category"
                dataKey="country" 
                stroke="hsl(var(--muted-foreground))"
                tick={{ fill: 'hsl(var(--muted-foreground))' }}
                width={120}
              />
              <Tooltip 
                contentStyle={{ 
                  backgroundColor: 'hsl(var(--card))', 
                  border: '1px solid hsl(var(--border))',
                  borderRadius: '8px'
                }}
                formatter={(value: number) => [`${value} triệu`, 'Dân số']}
              />
              <Bar 
                dataKey="population" 
                fill="hsl(var(--primary) / 0.8)"
                radius={[0, 8, 8, 0]}
              />
            </BarChart>
          </ResponsiveContainer>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mb-12">
          <div className="regional-chart bg-card/50 backdrop-blur-sm p-8 rounded-2xl border border-border shadow-elegant">
            <h3 className="text-2xl font-bold mb-6">Thứ Hạng Châu Á</h3>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={regionalData}>
                <CartesianGrid strokeDasharray="3 3" stroke="hsl(var(--border))" />
                <XAxis 
                  dataKey="year" 
                  stroke="hsl(var(--muted-foreground))"
                  tick={{ fill: 'hsl(var(--muted-foreground))' }}
                  ticks={milestoneYears}
                />
                <YAxis 
                  reversed
                  stroke="hsl(var(--muted-foreground))"
                  tick={{ fill: 'hsl(var(--muted-foreground))' }}
                  domain={[1, 20]}
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
                  dataKey="rank" 
                  stroke="hsl(var(--primary))" 
                  strokeWidth={3}
                  dot={{ fill: 'hsl(var(--primary))', r: 5 }}
                  name="Thứ hạng"
                />
              </LineChart>
            </ResponsiveContainer>
          </div>

          <div className="regional-chart bg-card/50 backdrop-blur-sm p-8 rounded-2xl border border-border shadow-elegant">
            <h3 className="text-2xl font-bold mb-6">Tuổi Trung Vị So Sánh</h3>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={regionalData}>
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
                <Legend />
                <Line 
                  type="monotone" 
                  dataKey="medianAge" 
                  stroke="hsl(var(--secondary))" 
                  strokeWidth={3}
                  dot={{ fill: 'hsl(var(--secondary))', r: 4 }}
                  name="Việt Nam"
                />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="regional-card bg-gradient-to-br from-primary/20 via-primary/10 to-transparent p-8 rounded-2xl border border-primary/30 animate-pulse">
            <Award className="w-10 h-10 text-primary mb-4" />
            <div className="text-4xl font-bold text-primary mb-2">#3</div>
            <div className="text-sm text-muted-foreground mb-3">Thứ hạng ASEAN</div>
            <div className="flex items-center gap-2 text-sm">
              <TrendingUp className="w-4 h-4 text-primary" />
              <span className="text-muted-foreground">Sau Indonesia & Philippines</span>
            </div>
          </div>

          <div className="regional-card bg-gradient-to-br from-accent/20 via-accent/10 to-transparent p-8 rounded-2xl border border-accent/30">
            <Globe className="w-10 h-10 text-accent mb-4" />
            <div className="text-4xl font-bold text-accent mb-2">#16</div>
            <div className="text-sm text-muted-foreground mb-3">Thứ hạng Thế giới</div>
            <div className="flex items-center gap-2 text-sm">
              <div className="text-accent font-semibold">1.24%</div>
              <span className="text-muted-foreground">dân số toàn cầu</span>
            </div>
          </div>

          <div className="regional-card bg-gradient-to-br from-secondary/20 via-secondary/10 to-transparent p-8 rounded-2xl border border-secondary/30">
            <div className="text-sm text-muted-foreground mb-2">ĐÔNG NAM Á</div>
            <div className="text-4xl font-bold text-secondary mb-2">14.9%</div>
            <div className="text-sm text-muted-foreground mb-3">Tỷ trọng dân số</div>
            <div className="flex items-center gap-2 text-sm">
              <div className="text-secondary font-semibold">101M</div>
              <span className="text-muted-foreground">người năm 2024</span>
            </div>
          </div>
        </div>

        <div className="mt-12 bg-accent/10 backdrop-blur-sm p-8 rounded-2xl border border-accent/30">
          <div className="flex items-start gap-4">
            <Globe className="w-8 h-8 text-accent flex-shrink-0 mt-1" />
            <div>
              <h3 className="text-2xl font-bold mb-3 text-accent">Rồng vươn cao</h3>
              <p className="text-lg text-muted-foreground leading-relaxed">
                Từ một quốc gia nhỏ với 28 triệu dân năm 1955, Việt Nam đã vươn lên thành cường quốc dân số thứ 16 thế giới 
                và thứ 3 Đông Nam Á với hơn 101 triệu người. Với vị thế chiếm gần 15% dân số khu vực, 
                Việt Nam đóng vai trò quan trọng trong bản đồ nhân khẩu học châu Á.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
