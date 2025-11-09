import { useState, useEffect, useRef, useCallback } from 'react';
import { SlideHero } from '@/components/slides/SlideHero';
import { ChevronLeft, ChevronRight, Play, Pause } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { ThemeToggle } from '@/components/ThemeToggle';
import { TimelineSlider } from '@/components/TimelineSlider';
import { LazySlide } from '@/components/LazySlide';
import { slidesConfig } from '@/config/slidesConfig';

const Index = () => {
  const [currentSlide, setCurrentSlide] = useState<number>(0);
  const [showHero, setShowHero] = useState<boolean>(true);
  const [isAutoPlaying, setIsAutoPlaying] = useState<boolean>(false);
  const [autoPlaySpeed, setAutoPlaySpeed] = useState<number>(5000);
  const [direction, setDirection] = useState<'next' | 'prev'>('next');
  const [selectedTimelineYear, setSelectedTimelineYear] = useState<number | undefined>(undefined);
  const [isTransitioning, setIsTransitioning] = useState<boolean>(false);
  const containerRef = useRef<HTMLDivElement>(null);
  const autoPlayTimerRef = useRef<NodeJS.Timeout | null>(null);
  const touchStartRef = useRef<number>(0);
  const touchEndRef = useRef<number>(0);

  const slides = slidesConfig;

  const handleStart = useCallback((): void => {
    setShowHero(false);
  }, []);

  const scrollToTop = useCallback((): void => {
    containerRef.current?.scrollIntoView({ behavior: 'smooth', block: 'start' });
  }, []);

  const nextSlide = useCallback((): void => {
    setCurrentSlide((prev) => {
      if (isTransitioning || prev >= slides.length - 1) return prev;
      setIsTransitioning(true);
      setDirection('next');
      setTimeout(() => {
        scrollToTop();
        setTimeout(() => setIsTransitioning(false), 600);
      }, 50);
      return prev + 1;
    });
  }, [isTransitioning, slides.length, scrollToTop]);

  const prevSlide = useCallback((): void => {
    setCurrentSlide((prev) => {
      if (isTransitioning || prev <= 0) return prev;
      setIsTransitioning(true);
      setDirection('prev');
      setTimeout(() => {
        scrollToTop();
        setTimeout(() => setIsTransitioning(false), 600);
      }, 50);
      return prev - 1;
    });
  }, [isTransitioning, scrollToTop]);

  const goToSlide = useCallback((index: number): void => {
    setCurrentSlide((prev) => {
      if (isTransitioning || index === prev) return prev;
      setIsTransitioning(true);
      setDirection(index > prev ? 'next' : 'prev');
      setTimeout(() => {
        scrollToTop();
        setTimeout(() => setIsTransitioning(false), 600);
      }, 50);
      return index;
    });
  }, [isTransitioning, scrollToTop]);

  const toggleAutoPlay = useCallback((): void => {
    setIsAutoPlaying((prev) => !prev);
  }, []);

  const handleTouchStart = useCallback((e: React.TouchEvent): void => {
    touchStartRef.current = e.touches[0]?.clientX || 0;
  }, []);

  const handleTouchMove = useCallback((e: React.TouchEvent): void => {
    touchEndRef.current = e.touches[0]?.clientX || 0;
  }, []);

  const handleTouchEnd = useCallback((): void => {
    if (!touchStartRef.current || !touchEndRef.current) return;

    const distance = touchStartRef.current - touchEndRef.current;
    const minSwipeDistance = 50;

    if (Math.abs(distance) < minSwipeDistance) return;

    if (distance > 0) {
      nextSlide();
    } else {
      prevSlide();
    }

    touchStartRef.current = 0;
    touchEndRef.current = 0;
  }, [nextSlide, prevSlide]);

  const handleTimelineYearSelect = useCallback((year: number): void => {
    setSelectedTimelineYear(year);
  }, []);

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
  }, [isAutoPlaying, autoPlaySpeed, showHero, nextSlide]);

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent): void => {
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
  }, [showHero, nextSlide, prevSlide, toggleAutoPlay]);

  if (showHero) {
    return <SlideHero onStart={handleStart} />;
  }

  const CurrentSlideComponent = slides[currentSlide]?.component;
  if (!CurrentSlideComponent) {
    return <div className="min-h-screen flex items-center justify-center">Slide not found</div>;
  }

  return (
    <div
      ref={containerRef}
      className="relative"
      onTouchStart={handleTouchStart}
      onTouchMove={handleTouchMove}
      onTouchEnd={handleTouchEnd}
    >
      <ThemeToggle />

      <div className="fixed top-0 left-0 w-full h-1 bg-muted z-50">
        <div
          className="h-full bg-gradient-to-r from-primary via-secondary to-accent transition-all duration-500"
          style={{ width: `${((currentSlide + 1) / slides.length) * 100}%` }}
        />
      </div>

      <div className="fixed top-6 right-6 z-50 flex items-center gap-3">
        <div className="bg-card/80 backdrop-blur-sm px-4 py-2 rounded-full border border-border shadow-lg">
          <span className="text-primary font-bold">{currentSlide + 1}</span>
          <span className="text-muted-foreground"> / {slides.length}</span>
        </div>

        <div className="bg-card/80 backdrop-blur-sm rounded-full border border-border shadow-lg flex items-center gap-2 px-2 py-1">
          <Button
            onClick={toggleAutoPlay}
            variant="ghost"
            size="sm"
            className="h-8 w-8 p-0 rounded-full hover:bg-primary/20"
            title={isAutoPlaying ? 'Pause' : 'Auto-play'}
            aria-label={isAutoPlaying ? 'Pause slideshow' : 'Start slideshow'}
          >
            {isAutoPlaying ? <Pause className="w-4 h-4" /> : <Play className="w-4 h-4" />}
          </Button>

          <select
            value={autoPlaySpeed}
            onChange={(e) => setAutoPlaySpeed(Number(e.target.value))}
            className="bg-transparent text-xs text-foreground border-none outline-none cursor-pointer pr-1"
            title="Speed"
            aria-label="Slideshow speed"
          >
            <option value={3000}>Nhanh</option>
            <option value={5000}>Bình thường</option>
            <option value={8000}>Chậm</option>
          </select>
        </div>
      </div>

      {currentSlide > 0 && (
        <Button
          onClick={prevSlide}
          className="fixed left-6 top-1/2 -translate-y-1/2 z-50 bg-primary/20 hover:bg-primary/40 backdrop-blur-sm border border-primary/30 rounded-full w-12 h-12 p-0"
          aria-label="Previous slide"
          title="Slide trước"
        >
          <ChevronLeft className="w-6 h-6" />
        </Button>
      )}

      {currentSlide < slides.length - 1 && (
        <Button
          onClick={nextSlide}
          className="fixed right-6 top-1/2 -translate-y-1/2 z-50 bg-primary/20 hover:bg-primary/40 backdrop-blur-sm border border-primary/30 rounded-full w-12 h-12 p-0 pulse-glow"
          aria-label="Next slide"
          title="Slide sau"
        >
          <ChevronRight className="w-6 h-6" />
        </Button>
      )}

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
            aria-label={`Go to slide ${index + 1}: ${slide.title}`}
            aria-pressed={index === currentSlide}
          />
        ))}
      </div>

      <LazySlide>
        <div
          className={`min-h-screen ${
            direction === 'next' ? 'animate-slideInFromRight' : 'animate-slideInFromLeft'
          }`}
          key={currentSlide}
          style={{
            animationFillMode: 'both',
          }}
        >
          <CurrentSlideComponent />
        </div>
      </LazySlide>

      <div className="fixed bottom-32 left-1/2 -translate-x-1/2 z-40 text-muted-foreground text-sm opacity-60 hidden md:block">
        Sử dụng ← → hoặc Space để điều hướng • Vuốt màn hình trên mobile
      </div>

      <TimelineSlider currentYear={selectedTimelineYear} onYearSelect={handleTimelineYearSelect} />
    </div>
  );
};

export default Index;
