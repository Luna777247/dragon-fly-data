import { useEffect, useRef } from 'react';
import { ChevronDown, TrendingUp, Users, Leaf, Building2 } from 'lucide-react';
import { Button } from '@/components/ui/button';
import dragonHero from '@/assets/dragon-hero.jpg';
import gsap from 'gsap';

interface SlideHeroProps {
  onStart: () => void;
}

export const SlideHero = ({ onStart }: SlideHeroProps) => {
  const titleRef = useRef<HTMLHeadingElement>(null);
  const subtitleRef = useRef<HTMLParagraphElement>(null);
  const iconsRef = useRef<HTMLDivElement>(null);
  const btnRef = useRef<HTMLButtonElement>(null);

  useEffect(() => {
    const tl = gsap.timeline({ delay: 0.5 });
    
    tl.from(titleRef.current, {
      opacity: 0,
      y: 50,
      duration: 1,
      ease: 'power3.out'
    })
    .from(subtitleRef.current, {
      opacity: 0,
      y: 30,
      duration: 0.8,
      ease: 'power2.out'
    }, '-=0.5')
    .from(iconsRef.current?.children || [], {
      opacity: 0,
      scale: 0.8,
      y: 20,
      duration: 0.6,
      stagger: 0.1,
      ease: 'back.out(1.7)'
    }, '-=0.4')
    .from(btnRef.current, {
      opacity: 0,
      scale: 0.9,
      duration: 0.5,
      ease: 'back.out(1.7)'
    }, '-=0.2');
  }, []);

  const dragonIcons = [
    { icon: Users, label: 'Dân số', color: 'text-primary' },
    { icon: TrendingUp, label: 'Kinh tế', color: 'text-secondary' },
    { icon: Building2, label: 'Xã hội', color: 'text-accent' },
    { icon: Leaf, label: 'Môi trường', color: 'text-secondary-bright' },
  ];

  return (
    <div className="relative min-h-screen flex items-center justify-center overflow-hidden">
      {/* Background with Parallax */}
      <div 
        className="absolute inset-0 z-0"
        style={{
          backgroundImage: `linear-gradient(135deg, rgba(18, 28, 32, 0.95), rgba(18, 33, 36, 0.9)), url(${dragonHero})`,
          backgroundSize: 'cover',
          backgroundPosition: 'center',
        }}
      >
        <div className="absolute inset-0 bg-gradient-to-b from-transparent via-background/50 to-background" />
      </div>

      {/* Animated particles */}
      <div className="absolute inset-0 z-10">
        {[...Array(20)].map((_, i) => (
          <div
            key={i}
            className="absolute w-1 h-1 bg-primary rounded-full opacity-30 animate-pulse"
            style={{
              left: `${Math.random() * 100}%`,
              top: `${Math.random() * 100}%`,
              animationDelay: `${Math.random() * 3}s`,
              animationDuration: `${2 + Math.random() * 3}s`,
            }}
          />
        ))}
      </div>

      {/* Content */}
      <div className="relative z-20 text-center px-6 max-w-5xl mx-auto">
        <h1 
          ref={titleRef}
          className="font-display text-5xl md:text-7xl lg:text-8xl font-bold mb-6 dragon-glow"
        >
          Việt Nam: Con <span className="text-primary">Rồng</span> Thức Tỉnh
        </h1>
        
        <p 
          ref={subtitleRef}
          className="text-xl md:text-2xl text-muted-foreground mb-12 font-light"
        >
          70 năm dữ liệu – 1 hành trình bay
        </p>

        {/* Dragon Icons */}
        <div ref={iconsRef} className="flex justify-center gap-8 mb-12 flex-wrap">
          {dragonIcons.map(({ icon: Icon, label, color }, index) => (
            <div 
              key={index}
              className="group cursor-pointer transform transition-all duration-300 hover:scale-110"
            >
              <div className={`${color} mb-2 flex justify-center`}>
                <Icon className="w-12 h-12 group-hover:drop-shadow-[0_0_10px_currentColor] transition-all" />
              </div>
              <p className="text-sm text-muted-foreground">{label}</p>
            </div>
          ))}
        </div>

        <Button
          ref={btnRef}
          onClick={onStart}
          size="lg"
          className="pulse-glow bg-primary hover:bg-primary-glow text-primary-foreground text-lg px-12 py-6 rounded-full font-semibold shadow-[0_0_30px_rgba(212,175,55,0.4)] hover:shadow-[0_0_50px_rgba(212,175,55,0.6)] transition-all duration-300"
        >
          BẮT ĐẦU HÀNH TRÌNH
        </Button>

        <div className="absolute bottom-10 left-1/2 -translate-x-1/2 animate-bounce">
          <ChevronDown className="w-8 h-8 text-primary opacity-60" />
        </div>
      </div>
    </div>
  );
};
