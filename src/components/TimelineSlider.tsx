import { useEffect, useRef, useState, useCallback } from 'react';
import { vietnamData } from '@/data/vietnamData';
import { ChevronLeft, ChevronRight, Calendar } from 'lucide-react';
import { useDebounce } from '@/hooks/useDebounce';
import gsap from 'gsap';

interface TimelineSliderProps {
  currentYear?: number;
  onYearSelect?: (year: number) => void;
}

export const TimelineSlider = ({ currentYear, onYearSelect }: TimelineSliderProps) => {
  const containerRef = useRef<HTMLDivElement>(null);
  const sliderRef = useRef<HTMLDivElement>(null);
  const [selectedYear, setSelectedYear] = useState<number>(currentYear || 2024);
  const [isExpanded, setIsExpanded] = useState<boolean>(false);

  const years = vietnamData.map((d) => d.year);
  const minYear = Math.min(...years);
  const maxYear = Math.max(...years);
  const debouncedYear = useDebounce(selectedYear, 300);

  useEffect(() => {
    if (currentYear) {
      setSelectedYear(currentYear);
      scrollToYear(currentYear);
    }
  }, [currentYear]);

  const scrollToYear = useCallback((year: number): void => {
    if (!sliderRef.current) return;
    const yearElements = sliderRef.current.querySelectorAll('[data-year]');
    const targetElement = Array.from(yearElements).find(
      (el) => (el as HTMLElement).getAttribute('data-year') === year.toString(),
    );
    if (targetElement) {
      targetElement.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'center' });
    }
  }, []);

  const handleYearClick = useCallback((year: number): void => {
    setSelectedYear(year);
    onYearSelect?.(year);
    scrollToYear(year);

    gsap.fromTo(
      `[data-year="${year}"]`,
      { scale: 1.2, opacity: 0.5 },
      { scale: 1, opacity: 1, duration: 0.5, ease: 'back.out(1.7)' },
    );
  }, [onYearSelect, scrollToYear]);

  const handlePrevYear = useCallback((): void => {
    const currentIndex = years.indexOf(selectedYear);
    if (currentIndex > 0) {
      handleYearClick(years[currentIndex - 1] || minYear);
    }
  }, [years, selectedYear, handleYearClick, minYear]);

  const handleNextYear = useCallback((): void => {
    const currentIndex = years.indexOf(selectedYear);
    if (currentIndex < years.length - 1) {
      handleYearClick(years[currentIndex + 1] || maxYear);
    }
  }, [years, selectedYear, handleYearClick, maxYear]);

  const getYearData = useCallback((year: number) => {
    return vietnamData.find((d) => d.year === year) || null;
  }, []);

  const currentData = getYearData(selectedYear);

  return (
    <div
      ref={containerRef}
      className={`fixed bottom-0 left-0 right-0 z-40 bg-card/95 backdrop-blur-lg border-t border-border shadow-elegant transition-all duration-500 ${
        isExpanded ? 'h-48 sm:h-56' : 'h-20'
      }`}
      role="region"
      aria-label="Timeline"
    >
      <button
        onClick={() => setIsExpanded(!isExpanded)}
        className="absolute -top-10 left-1/2 -translate-x-1/2 bg-primary text-primary-foreground px-6 py-2 rounded-t-xl font-semibold hover:bg-primary/90 transition-all duration-300 shadow-lg flex items-center gap-2 min-h-10"
        aria-expanded={isExpanded}
        aria-label={`Toggle timeline details. Timeline from ${minYear} to ${maxYear}`}
      >
        <Calendar className="w-4 h-4" aria-hidden="true" />
        Timeline {minYear} - {maxYear}
      </button>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 h-full flex flex-col justify-center">
        <div className="flex items-center justify-between mb-3 gap-2 sm:gap-4">
          <button
            onClick={handlePrevYear}
            disabled={selectedYear === minYear}
            className="p-2 rounded-full bg-secondary/20 hover:bg-secondary/40 disabled:opacity-30 disabled:cursor-not-allowed transition-all duration-300 min-h-10 min-w-10"
            aria-label={`Previous year. Current year: ${selectedYear}`}
            title="Năm trước"
          >
            <ChevronLeft className="w-5 h-5" aria-hidden="true" />
          </button>

          <div className="flex items-center gap-3 sm:gap-6 flex-1 justify-center">
            <div className="text-center">
              <div className="text-2xl sm:text-4xl font-bold text-primary animate-pulse" aria-live="polite">
                {selectedYear}
              </div>
              {currentData && (
                <div className="text-xs sm:text-sm text-muted-foreground">
                  {(currentData.population / 1000000).toFixed(1)}M dân • GDP ${currentData.gdpBillion}B
                </div>
              )}
            </div>
          </div>

          <button
            onClick={handleNextYear}
            disabled={selectedYear === maxYear}
            className="p-2 rounded-full bg-secondary/20 hover:bg-secondary/40 disabled:opacity-30 disabled:cursor-not-allowed transition-all duration-300 min-h-10 min-w-10"
            aria-label={`Next year. Current year: ${selectedYear}`}
            title="Năm sau"
          >
            <ChevronRight className="w-5 h-5" aria-hidden="true" />
          </button>
        </div>

        <div className="relative">
          <div
            ref={sliderRef}
            className="flex gap-1 overflow-x-auto scrollbar-thin scrollbar-thumb-primary/30 scrollbar-track-transparent pb-2"
            style={{ scrollbarWidth: 'thin' }}
            role="group"
            aria-label="Year selection"
          >
            {years.map((year) => {
              const isSelected = year === selectedYear;
              const isMilestone = year % 10 === 0 || year % 10 === 5;
              const data = getYearData(year);

              return (
                <button
                  key={year}
                  data-year={year}
                  onClick={() => handleYearClick(year)}
                  className={`relative flex-shrink-0 transition-all duration-300 min-h-10 ${
                    isSelected
                      ? 'w-14 sm:w-16 h-10 sm:h-12 bg-primary text-primary-foreground scale-110 shadow-lg'
                      : isMilestone
                        ? 'w-10 sm:w-12 h-8 sm:h-10 bg-secondary/30 hover:bg-secondary/50'
                        : 'w-7 sm:w-8 h-7 sm:h-8 bg-muted/30 hover:bg-muted/50'
                  } rounded-lg flex flex-col items-center justify-center text-xs font-bold focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2 focus:ring-offset-background`}
                  aria-pressed={isSelected}
                  aria-label={`Year ${year}. ${data ? `Population: ${(data.population / 1000000).toFixed(1)}M, GDP: $${data.gdpBillion}B` : ''}`}
                >
                  {(isSelected || isMilestone) && (
                    <span className={`${isSelected ? 'text-sm' : 'text-xs'} truncate`}>{year}</span>
                  )}

                  {data && (
                    <div className="absolute bottom-0 left-0 right-0 h-1 bg-background/20 rounded-b-lg overflow-hidden">
                      <div
                        className="h-full bg-accent transition-all duration-500"
                        style={{ width: `${(data.gdpGrowthRate / 10) * 100}%` }}
                      />
                    </div>
                  )}
                </button>
              );
            })}
          </div>

          {/* Progress line */}
          <div className="absolute bottom-8 left-0 right-0 h-0.5 bg-border pointer-events-none">
            <div
              className="h-full bg-gradient-to-r from-primary via-secondary to-accent transition-all duration-500"
              style={{ width: `${((selectedYear - minYear) / (maxYear - minYear)) * 100}%` }}
            />
          </div>
        </div>

        {isExpanded && currentData && (
          <div className="mt-4 grid grid-cols-2 sm:grid-cols-4 gap-2 sm:gap-4 animate-fade-in">
            <div className="bg-primary/10 p-3 rounded-lg">
              <div className="text-xs text-muted-foreground mb-1">Dân số</div>
              <div className="text-base sm:text-lg font-bold text-primary">{(currentData.population / 1000000).toFixed(1)}M</div>
            </div>
            <div className="bg-secondary/10 p-3 rounded-lg">
              <div className="text-xs text-muted-foreground mb-1">GDP</div>
              <div className="text-base sm:text-lg font-bold text-secondary">${currentData.gdpBillion}B</div>
            </div>
            <div className="bg-accent/10 p-3 rounded-lg">
              <div className="text-xs text-muted-foreground mb-1">Đô thị hóa</div>
              <div className="text-base sm:text-lg font-bold text-accent">{currentData.urbanPopPercent}%</div>
            </div>
            <div className="bg-primary/10 p-3 rounded-lg">
              <div className="text-xs text-muted-foreground mb-1">Tuổi thọ</div>
              <div className="text-base sm:text-lg font-bold text-primary">{currentData.lifeExpectancy} tuổi</div>
            </div>
          </div>
        )}
      </div>

      <style>{`
        .scrollbar-thin::-webkit-scrollbar {
          height: 6px;
        }
        .scrollbar-thin::-webkit-scrollbar-track {
          background: transparent;
        }
        .scrollbar-thin::-webkit-scrollbar-thumb {
          background: hsl(var(--primary) / 0.3);
          border-radius: 3px;
        }
        .scrollbar-thin::-webkit-scrollbar-thumb:hover {
          background: hsl(var(--primary) / 0.5);
        }
      `}</style>
    </div>
  );
};
