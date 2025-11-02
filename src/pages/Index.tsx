import { useState, useEffect, useRef } from 'react';
import { SlideHero } from '@/components/slides/SlideHero';
import { SlidePopulation } from '@/components/slides/SlidePopulation';
import { SlideDemographics } from '@/components/slides/SlideDemographics';
import { SlideBirthDeath } from '@/components/slides/SlideBirthDeath';
import { SlideUrbanization } from '@/components/slides/SlideUrbanization';
import { SlideEconomy } from '@/components/slides/SlideEconomy';
import { SlideEmployment } from '@/components/slides/SlideEmployment';
import { SlideSociety } from '@/components/slides/SlideSociety';
import { SlideEnvironment } from '@/components/slides/SlideEnvironment';
import { SlideRegional } from '@/components/slides/SlideRegional';
import { SlideFuture } from '@/components/slides/SlideFuture';
import { SlideConclusion } from '@/components/slides/SlideConclusion';
import { ChevronLeft, ChevronRight, Play, Pause } from 'lucide-react';
import { Button } from '@/components/ui/button';

const Index = () => {
  const [currentSlide, setCurrentSlide] = useState(0);
  const [showHero, setShowHero] = useState(true);
  const [isAutoPlaying, setIsAutoPlaying] = useState(false);
  const [autoPlaySpeed, setAutoPlaySpeed] = useState(5000); // 5s default
  const [direction, setDirection] = useState<'next' | 'prev'>('next');
  const containerRef = useRef<HTMLDivElement>(null);
  const autoPlayTimerRef = useRef<NodeJS.Timeout | null>(null);
  const touchStartRef = useRef<number>(0);
  const touchEndRef = useRef<number>(0);

  const slides = [
    { component: SlidePopulation, title: 'Dân Số' },
    { component: SlideDemographics, title: 'Nhân Khẩu' },
    { component: SlideBirthDeath, title: 'Sinh Tử' },
    { component: SlideUrbanization, title: 'Đô Thị' },
    { component: SlideEconomy, title: 'Kinh Tế' },
    { component: SlideEmployment, title: 'Việc Làm' },
    { component: SlideSociety, title: 'Xã Hội' },
    { component: SlideEnvironment, title: 'Môi Trường' },
    { component: SlideRegional, title: 'Khu Vực' },
    { component: SlideFuture, title: 'Tương Lai' },
    { component: SlideConclusion, title: 'Kết Luận' },
  ];

  const handleStart = () => {
    setShowHero(false);
  };

  const nextSlide = () => {
    if (currentSlide < slides.length - 1) {
      setDirection('next');
      setCurrentSlide(currentSlide + 1);
      scrollToTop();
    } else if (isAutoPlaying) {
      setIsAutoPlaying(false);
    }
  };

  const prevSlide = () => {
    if (currentSlide > 0) {
      setDirection('prev');
      setCurrentSlide(currentSlide - 1);
      scrollToTop();
    }
  };

  const goToSlide = (index: number) => {
    setDirection(index > currentSlide ? 'next' : 'prev');
    setCurrentSlide(index);
    scrollToTop();
  };

  const toggleAutoPlay = () => {
    setIsAutoPlaying(!isAutoPlaying);
  };

  const handleTouchStart = (e: React.TouchEvent) => {
    touchStartRef.current = e.touches[0].clientX;
  };

  const handleTouchMove = (e: React.TouchEvent) => {
    touchEndRef.current = e.touches[0].clientX;
  };

  const handleTouchEnd = () => {
    if (!touchStartRef.current || !touchEndRef.current) return;
    
    const distance = touchStartRef.current - touchEndRef.current;
    const minSwipeDistance = 50;

    if (Math.abs(distance) < minSwipeDistance) return;

    if (distance > 0) {
      // Swipe left - next slide
      nextSlide();
    } else {
      // Swipe right - prev slide
      prevSlide();
    }

    touchStartRef.current = 0;
    touchEndRef.current = 0;
  };

  const scrollToTop = () => {
    containerRef.current?.scrollIntoView({ behavior: 'smooth', block: 'start' });
  };

  // Auto-play functionality
  useEffect(() => {
    if (!isAutoPlaying || showHero) {
      if (autoPlayTimerRef.current) {
        clearInterval(autoPlayTimerRef.current);
        autoPlayTimerRef.current = null;
      }
      return;
    }

    autoPlayTimerRef.current = setInterval(() => {
      nextSlide();
    }, autoPlaySpeed);

    return () => {
      if (autoPlayTimerRef.current) {
        clearInterval(autoPlayTimerRef.current);
        autoPlayTimerRef.current = null;
      }
    };
  }, [isAutoPlaying, currentSlide, autoPlaySpeed, showHero]);

  // Keyboard navigation
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (showHero) return;
      if (e.key === 'ArrowRight') nextSlide();
      if (e.key === 'ArrowLeft') prevSlide();
      if (e.key === ' ') {
        e.preventDefault();
        toggleAutoPlay();
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [currentSlide, showHero, isAutoPlaying]);

  if (showHero) {
    return <SlideHero onStart={handleStart} />;
  }

  const CurrentSlideComponent = slides[currentSlide].component;

  return (
    <div 
      ref={containerRef} 
      className="relative"
      onTouchStart={handleTouchStart}
      onTouchMove={handleTouchMove}
      onTouchEnd={handleTouchEnd}
    >
      {/* Progress bar */}
      <div className="fixed top-0 left-0 w-full h-1 bg-muted z-50">
        <div 
          className="h-full bg-gradient-to-r from-primary via-secondary to-accent transition-all duration-500"
          style={{ width: `${((currentSlide + 1) / slides.length) * 100}%` }}
        />
      </div>

      {/* Slide counter and auto-play controls */}
      <div className="fixed top-6 right-6 z-50 flex items-center gap-3">
        <div className="bg-card/80 backdrop-blur-sm px-4 py-2 rounded-full border border-border shadow-lg">
          <span className="text-primary font-bold">{currentSlide + 1}</span>
          <span className="text-muted-foreground"> / {slides.length}</span>
        </div>
        
        {/* Auto-play controls */}
        <div className="bg-card/80 backdrop-blur-sm rounded-full border border-border shadow-lg flex items-center gap-2 px-2 py-1">
          <Button
            onClick={toggleAutoPlay}
            variant="ghost"
            size="sm"
            className="h-8 w-8 p-0 rounded-full hover:bg-primary/20"
            title={isAutoPlaying ? 'Pause' : 'Auto-play'}
          >
            {isAutoPlaying ? (
              <Pause className="w-4 h-4" />
            ) : (
              <Play className="w-4 h-4" />
            )}
          </Button>
          
          <select
            value={autoPlaySpeed}
            onChange={(e) => setAutoPlaySpeed(Number(e.target.value))}
            className="bg-transparent text-xs text-foreground border-none outline-none cursor-pointer pr-1"
            title="Speed"
          >
            <option value={3000}>Nhanh</option>
            <option value={5000}>Bình thường</option>
            <option value={8000}>Chậm</option>
          </select>
        </div>
      </div>

      {/* Navigation buttons */}
      {currentSlide > 0 && (
        <Button
          onClick={prevSlide}
          className="fixed left-6 top-1/2 -translate-y-1/2 z-50 bg-primary/20 hover:bg-primary/40 backdrop-blur-sm border border-primary/30 rounded-full w-12 h-12 p-0"
        >
          <ChevronLeft className="w-6 h-6" />
        </Button>
      )}

      {currentSlide < slides.length - 1 && (
        <Button
          onClick={nextSlide}
          className="fixed right-6 top-1/2 -translate-y-1/2 z-50 bg-primary/20 hover:bg-primary/40 backdrop-blur-sm border border-primary/30 rounded-full w-12 h-12 p-0 pulse-glow"
        >
          <ChevronRight className="w-6 h-6" />
        </Button>
      )}

      {/* Slide navigation dots */}
      <div className="fixed bottom-6 left-1/2 -translate-x-1/2 z-50 flex gap-2 bg-card/60 backdrop-blur-sm px-4 py-2 rounded-full border border-border/50">
        {slides.map((slide, index) => (
          <button
            key={index}
            onClick={() => goToSlide(index)}
            className={`w-3 h-3 rounded-full transition-all duration-300 ${
              index === currentSlide 
                ? 'bg-primary w-8 shadow-[0_0_10px_rgba(212,175,55,0.5)]' 
                : 'bg-muted-foreground/30 hover:bg-muted-foreground/50'
            }`}
            aria-label={`Go to ${slide.title}`}
          />
        ))}
      </div>

      {/* Current slide with smooth transitions */}
      <div 
        className={`min-h-screen transition-all duration-700 ease-out ${
          direction === 'next' 
            ? 'animate-[slideInFromRight_0.7s_ease-out]' 
            : 'animate-[slideInFromLeft_0.7s_ease-out]'
        }`}
        key={currentSlide}
      >
        <CurrentSlideComponent />
      </div>

      {/* Hint text */}
      <div className="fixed bottom-20 left-1/2 -translate-x-1/2 z-40 text-muted-foreground text-sm opacity-60 hidden md:block">
        Sử dụng ← → hoặc Space để điều hướng • Vuốt màn hình trên mobile
      </div>
    </div>
  );
};

export default Index;
