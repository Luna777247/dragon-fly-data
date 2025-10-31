import { useState, useEffect, useRef } from 'react';
import { SlideHero } from '@/components/slides/SlideHero';
import { SlidePopulation } from '@/components/slides/SlidePopulation';
import { SlideEconomy } from '@/components/slides/SlideEconomy';
import { SlideSociety } from '@/components/slides/SlideSociety';
import { SlideConclusion } from '@/components/slides/SlideConclusion';
import { ChevronLeft, ChevronRight } from 'lucide-react';
import { Button } from '@/components/ui/button';

const Index = () => {
  const [currentSlide, setCurrentSlide] = useState(0);
  const [showHero, setShowHero] = useState(true);
  const containerRef = useRef<HTMLDivElement>(null);

  const slides = [
    { component: SlidePopulation, title: 'Dân Số' },
    { component: SlideEconomy, title: 'Kinh Tế' },
    { component: SlideSociety, title: 'Xã Hội' },
    { component: SlideConclusion, title: 'Kết Luận' },
  ];

  const handleStart = () => {
    setShowHero(false);
  };

  const nextSlide = () => {
    if (currentSlide < slides.length - 1) {
      setCurrentSlide(currentSlide + 1);
      scrollToTop();
    }
  };

  const prevSlide = () => {
    if (currentSlide > 0) {
      setCurrentSlide(currentSlide - 1);
      scrollToTop();
    }
  };

  const scrollToTop = () => {
    containerRef.current?.scrollIntoView({ behavior: 'smooth', block: 'start' });
  };

  // Keyboard navigation
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (showHero) return;
      if (e.key === 'ArrowRight') nextSlide();
      if (e.key === 'ArrowLeft') prevSlide();
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [currentSlide, showHero]);

  if (showHero) {
    return <SlideHero onStart={handleStart} />;
  }

  const CurrentSlideComponent = slides[currentSlide].component;

  return (
    <div ref={containerRef} className="relative">
      {/* Progress bar */}
      <div className="fixed top-0 left-0 w-full h-1 bg-muted z-50">
        <div 
          className="h-full bg-gradient-to-r from-primary via-secondary to-accent transition-all duration-500"
          style={{ width: `${((currentSlide + 1) / slides.length) * 100}%` }}
        />
      </div>

      {/* Slide counter */}
      <div className="fixed top-6 right-6 z-50 bg-card/80 backdrop-blur-sm px-4 py-2 rounded-full border border-border shadow-lg">
        <span className="text-primary font-bold">{currentSlide + 1}</span>
        <span className="text-muted-foreground"> / {slides.length}</span>
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
      <div className="fixed bottom-6 left-1/2 -translate-x-1/2 z-50 flex gap-2">
        {slides.map((slide, index) => (
          <button
            key={index}
            onClick={() => {
              setCurrentSlide(index);
              scrollToTop();
            }}
            className={`w-3 h-3 rounded-full transition-all duration-300 ${
              index === currentSlide 
                ? 'bg-primary w-8 shadow-[0_0_10px_rgba(212,175,55,0.5)]' 
                : 'bg-muted-foreground/30 hover:bg-muted-foreground/50'
            }`}
            aria-label={`Go to ${slide.title}`}
          />
        ))}
      </div>

      {/* Current slide */}
      <div className="min-h-screen">
        <CurrentSlideComponent />
      </div>

      {/* Hint text */}
      <div className="fixed bottom-20 left-1/2 -translate-x-1/2 z-40 text-muted-foreground text-sm opacity-60">
        Sử dụng ← → hoặc nhấn vào các chấm để điều hướng
      </div>
    </div>
  );
};

export default Index;
