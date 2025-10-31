import { useEffect, useRef } from 'react';
import { Sparkles, Share2, Download } from 'lucide-react';
import { Button } from '@/components/ui/button';
import gsap from 'gsap';

export const SlideConclusion = () => {
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!containerRef.current) return;

    const ctx = gsap.context(() => {
      const tl = gsap.timeline({
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        }
      });

      tl.from('.conclusion-title', {
        opacity: 0,
        scale: 0.8,
        duration: 1,
        ease: 'back.out(1.7)'
      })
      .from('.conclusion-slogan', {
        opacity: 0,
        y: 30,
        duration: 0.8,
        ease: 'power2.out'
      }, '-=0.5')
      .from('.conclusion-cta', {
        opacity: 0,
        y: 20,
        duration: 0.6,
        stagger: 0.2,
        ease: 'power2.out'
      }, '-=0.3');
    }, containerRef);

    return () => ctx.revert();
  }, []);

  const handleShare = () => {
    if (navigator.share) {
      navigator.share({
        title: 'Việt Nam – Hành Trình Từ Rồng Bay',
        text: '70 năm dữ liệu – Câu chuyện tăng trưởng và phát triển bền vững của Việt Nam',
        url: window.location.href
      });
    }
  };

  return (
    <div ref={containerRef} className="min-h-screen flex items-center justify-center py-20 px-6 relative overflow-hidden">
      {/* Animated background particles */}
      <div className="absolute inset-0">
        {[...Array(30)].map((_, i) => (
          <div
            key={i}
            className="absolute w-2 h-2 bg-primary rounded-full opacity-20 animate-pulse"
            style={{
              left: `${Math.random() * 100}%`,
              top: `${Math.random() * 100}%`,
              animationDelay: `${Math.random() * 3}s`,
              animationDuration: `${2 + Math.random() * 3}s`,
            }}
          />
        ))}
      </div>

      <div className="max-w-4xl w-full text-center relative z-10">
        <div className="conclusion-title mb-8">
          <Sparkles className="w-16 h-16 text-primary mx-auto mb-6 animate-pulse" />
          <h2 className="font-display text-5xl md:text-7xl font-bold mb-6">
            Hành Trình Kết Thúc,<br />
            Câu Chuyện <span className="text-primary dragon-glow">Tiếp Tục</span>
          </h2>
        </div>

        <div className="conclusion-slogan bg-gradient-to-r from-primary/20 via-secondary/20 to-accent/20 p-8 rounded-2xl border border-primary/30 mb-12 backdrop-blur-sm">
          <p className="text-3xl md:text-4xl font-display font-bold dragon-glow">
            "Bay cao, nhưng phải bay xanh"
          </p>
          <p className="text-muted-foreground mt-4 text-lg">
            #RongBayXanh #VietNam70Nam
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12">
          <div className="bg-card/50 backdrop-blur-sm p-6 rounded-xl border border-border">
            <div className="text-4xl font-bold text-primary mb-2">28M → 101M</div>
            <p className="text-sm text-muted-foreground">Dân số tăng × 3.6</p>
          </div>
          <div className="bg-card/50 backdrop-blur-sm p-6 rounded-xl border border-border">
            <div className="text-4xl font-bold text-secondary mb-2">$2.1B → $476B</div>
            <p className="text-sm text-muted-foreground">GDP tăng × 227</p>
          </div>
          <div className="bg-card/50 backdrop-blur-sm p-6 rounded-xl border border-border">
            <div className="text-4xl font-bold text-accent mb-2">0.35 → 0.84</div>
            <p className="text-sm text-muted-foreground">HDI tăng +140%</p>
          </div>
        </div>

        <div className="flex flex-col sm:flex-row gap-4 justify-center">
          <Button
            className="conclusion-cta bg-primary hover:bg-primary-glow text-primary-foreground px-8 py-6 text-lg rounded-full shadow-[0_0_30px_rgba(212,175,55,0.4)] hover:shadow-[0_0_50px_rgba(212,175,55,0.6)] transition-all"
            onClick={handleShare}
          >
            <Share2 className="mr-2 w-5 h-5" />
            Chia sẻ câu chuyện
          </Button>
          
          <Button
            variant="outline"
            className="conclusion-cta border-primary/50 text-primary hover:bg-primary/10 px-8 py-6 text-lg rounded-full"
          >
            <Download className="mr-2 w-5 h-5" />
            Tải báo cáo PDF
          </Button>
        </div>

        <div className="mt-16 pt-8 border-t border-border/50">
          <p className="text-muted-foreground text-sm">
            Nguồn dữ liệu: Worldometer, World Bank, UN Population Division (1955-2024)
          </p>
        </div>
      </div>
    </div>
  );
};
