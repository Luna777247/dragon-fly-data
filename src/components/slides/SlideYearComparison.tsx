import { useEffect, useRef, useState } from 'react';
import { vietnamData } from '@/data/vietnamData';
import { GitCompare, TrendingUp, TrendingDown } from 'lucide-react';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

export const SlideYearComparison = () => {
  const containerRef = useRef<HTMLDivElement>(null);
  const [year1, setYear1] = useState(1955);
  const [year2, setYear2] = useState(2025);

  useEffect(() => {
    if (!containerRef.current) return;

    const ctx = gsap.context(() => {
      gsap.from('.compare-title', {
        opacity: 0,
        y: 50,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        duration: 1,
        ease: 'power3.out'
      });

      gsap.from('.compare-selector', {
        opacity: 0,
        scale: 0.9,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        duration: 0.8,
        stagger: 0.2,
        ease: 'back.out(1.2)'
      });

      gsap.from('.compare-card', {
        opacity: 0,
        y: 30,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        duration: 1,
        stagger: 0.1,
        ease: 'power2.out'
      });
    }, containerRef);

    return () => ctx.revert();
  }, []);

  const data1 = vietnamData.find(d => d.year === year1);
  const data2 = vietnamData.find(d => d.year === year2);

  if (!data1 || !data2) return null;

  const calculateChange = (val1: number, val2: number) => {
    const change = ((val2 - val1) / val1) * 100;
    return {
      value: change,
      isPositive: change > 0,
      formatted: `${change > 0 ? '+' : ''}${change.toFixed(1)}%`
    };
  };

  const metrics = [
    {
      label: 'Dân số',
      val1: (data1.population / 1000000).toFixed(1) + 'M',
      val2: (data2.population / 1000000).toFixed(1) + 'M',
      change: calculateChange(data1.population, data2.population),
      color: 'primary'
    },
    {
      label: 'GDP',
      val1: '$' + data1.gdpBillion + 'B',
      val2: '$' + data2.gdpBillion + 'B',
      change: calculateChange(data1.gdpBillion, data2.gdpBillion),
      color: 'secondary'
    },
    {
      label: 'GDP/người',
      val1: '$' + data1.gdpPerCapita,
      val2: '$' + data2.gdpPerCapita,
      change: calculateChange(data1.gdpPerCapita, data2.gdpPerCapita),
      color: 'accent'
    },
    {
      label: 'Đô thị hóa',
      val1: data1.urbanPopPercent + '%',
      val2: data2.urbanPopPercent + '%',
      change: calculateChange(data1.urbanPopPercent, data2.urbanPopPercent),
      color: 'primary'
    },
    {
      label: 'HDI',
      val1: (data1.hdi * 100).toFixed(1) + '%',
      val2: (data2.hdi * 100).toFixed(1) + '%',
      change: calculateChange(data1.hdi, data2.hdi),
      color: 'secondary'
    },
    {
      label: 'Tuổi thọ',
      val1: data1.lifeExpectancy + ' tuổi',
      val2: data2.lifeExpectancy + ' tuổi',
      change: calculateChange(data1.lifeExpectancy, data2.lifeExpectancy),
      color: 'accent'
    },
    {
      label: 'Biết chữ',
      val1: data1.literacyRate + '%',
      val2: data2.literacyRate + '%',
      change: calculateChange(data1.literacyRate, data2.literacyRate),
      color: 'primary'
    },
    {
      label: 'Tuổi trung vị',
      val1: data1.medianAge + ' tuổi',
      val2: data2.medianAge + ' tuổi',
      change: calculateChange(data1.medianAge, data2.medianAge),
      color: 'secondary'
    },
    {
      label: 'Tỷ lệ sinh',
      val1: data1.birthRate + '‰',
      val2: data2.birthRate + '‰',
      change: calculateChange(data1.birthRate, data2.birthRate),
      color: 'accent'
    },
    {
      label: 'Nông nghiệp',
      val1: data1.employmentAgriculture + '%',
      val2: data2.employmentAgriculture + '%',
      change: calculateChange(data1.employmentAgriculture, data2.employmentAgriculture),
      color: 'primary'
    },
    {
      label: 'Công nghiệp',
      val1: data1.employmentIndustry + '%',
      val2: data2.employmentIndustry + '%',
      change: calculateChange(data1.employmentIndustry, data2.employmentIndustry),
      color: 'secondary'
    },
    {
      label: 'Dịch vụ',
      val1: data1.employmentServices + '%',
      val2: data2.employmentServices + '%',
      change: calculateChange(data1.employmentServices, data2.employmentServices),
      color: 'accent'
    },
  ];

  const availableYears = vietnamData.map(d => d.year);

  return (
    <div ref={containerRef} className="min-h-screen py-20 px-6 relative overflow-hidden bg-gradient-to-br from-background via-accent/5 to-primary/10">
      <div className="max-w-7xl mx-auto relative z-10">
        {/* Header */}
        <div className="text-center mb-12">
          <GitCompare className="compare-title w-16 h-16 text-primary mx-auto mb-6 animate-pulse" />
          <h2 className="compare-title font-display text-5xl md:text-6xl font-bold mb-4">
            So Sánh <span className="text-primary dragon-glow">Qua Thời Gian</span>
          </h2>
          <p className="compare-title text-xl text-muted-foreground">Chọn 2 năm bất kỳ để so sánh toàn bộ chỉ số</p>
        </div>

        {/* Year Selectors */}
        <div className="grid md:grid-cols-2 gap-8 mb-12">
          {/* Year 1 */}
          <div className="compare-selector bg-card/50 backdrop-blur-sm p-8 rounded-2xl border border-border shadow-elegant">
            <h3 className="text-2xl font-bold text-center mb-6 text-primary">Năm thứ nhất</h3>
            <select
              value={year1}
              onChange={(e) => setYear1(parseInt(e.target.value))}
              className="w-full bg-background text-foreground border-2 border-primary rounded-xl px-6 py-4 text-3xl font-bold text-center cursor-pointer focus:outline-none focus:ring-2 focus:ring-primary"
            >
              {availableYears.map(y => (
                <option key={y} value={y} disabled={y === year2}>{y}</option>
              ))}
            </select>
            <div className="mt-6 text-center">
              <div className="text-4xl font-bold text-primary mb-2">{(data1.population / 1000000).toFixed(1)}M</div>
              <div className="text-sm text-muted-foreground">Dân số</div>
            </div>
          </div>

          {/* Year 2 */}
          <div className="compare-selector bg-card/50 backdrop-blur-sm p-8 rounded-2xl border border-border shadow-elegant">
            <h3 className="text-2xl font-bold text-center mb-6 text-secondary">Năm thứ hai</h3>
            <select
              value={year2}
              onChange={(e) => setYear2(parseInt(e.target.value))}
              className="w-full bg-background text-foreground border-2 border-secondary rounded-xl px-6 py-4 text-3xl font-bold text-center cursor-pointer focus:outline-none focus:ring-2 focus:ring-secondary"
            >
              {availableYears.map(y => (
                <option key={y} value={y} disabled={y === year1}>{y}</option>
              ))}
            </select>
            <div className="mt-6 text-center">
              <div className="text-4xl font-bold text-secondary mb-2">{(data2.population / 1000000).toFixed(1)}M</div>
              <div className="text-sm text-muted-foreground">Dân số</div>
            </div>
          </div>
        </div>

        {/* Comparison Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {metrics.map((metric, idx) => (
            <div
              key={idx}
              className="compare-card bg-card/30 backdrop-blur-sm p-6 rounded-xl border border-border hover:shadow-elegant transition-all duration-300 hover:scale-105"
            >
              <div className="text-sm font-semibold text-muted-foreground mb-3">{metric.label}</div>
              
              <div className="flex items-center justify-between mb-2">
                <div className="flex-1">
                  <div className="text-xs text-muted-foreground mb-1">{year1}</div>
                  <div className="text-xl font-bold text-primary">{metric.val1}</div>
                </div>
                
                <div className="mx-4 flex items-center gap-1">
                  {metric.change.isPositive ? (
                    <TrendingUp className="w-5 h-5 text-green-500" />
                  ) : (
                    <TrendingDown className="w-5 h-5 text-red-500" />
                  )}
                </div>
                
                <div className="flex-1 text-right">
                  <div className="text-xs text-muted-foreground mb-1">{year2}</div>
                  <div className="text-xl font-bold text-secondary">{metric.val2}</div>
                </div>
              </div>

              <div className={`text-center text-sm font-bold ${metric.change.isPositive ? 'text-green-500' : 'text-red-500'}`}>
                {metric.change.formatted}
              </div>
            </div>
          ))}
        </div>

        {/* Summary */}
        <div className="mt-12 bg-gradient-to-r from-primary/10 via-secondary/10 to-accent/10 backdrop-blur-sm p-8 rounded-2xl border border-primary/30">
          <h3 className="text-2xl font-bold mb-3 text-primary">Tóm Tắt Thay Đổi</h3>
          <p className="text-lg text-muted-foreground leading-relaxed">
            Từ năm {year1} đến {year2} ({year2 - year1} năm), Việt Nam đã trải qua nhiều thay đổi đáng kể. 
            Dân số tăng từ {(data1.population / 1000000).toFixed(1)}M lên {(data2.population / 1000000).toFixed(1)}M người, 
            GDP tăng từ ${data1.gdpBillion}B lên ${data2.gdpBillion}B, 
            và tỷ lệ đô thị hóa tăng từ {data1.urbanPopPercent}% lên {data2.urbanPopPercent}%. 
            Đây là minh chứng cho sự phát triển mạnh mẽ và bền vững của đất nước.
          </p>
        </div>
      </div>
    </div>
  );
};
