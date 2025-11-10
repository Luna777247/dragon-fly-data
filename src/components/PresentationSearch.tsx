import { useState, useEffect } from 'react';
import { Search, X, Calendar, TrendingUp } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { vietnamData } from '@/data/vietnamData';
import { slidesConfig } from '@/config/slidesConfig';

interface SearchResult {
  type: 'slide' | 'data_year' | 'metric';
  title: string;
  subtitle?: string;
  slideIndex?: number;
  year?: number;
  highlight?: string;
}

interface PresentationSearchProps {
  isOpen: boolean;
  onClose: () => void;
  onNavigate: (slideIndex: number) => void;
}

export const PresentationSearch = ({ isOpen, onClose, onNavigate }: PresentationSearchProps) => {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState<SearchResult[]>([]);

  useEffect(() => {
    if (!query.trim()) {
      setResults([]);
      return;
    }

    const q = query.toLowerCase();
    const foundResults: SearchResult[] = [];

    // Search slides
    slidesConfig.forEach((slide, idx) => {
      if (slide.title.toLowerCase().includes(q)) {
        foundResults.push({
          type: 'slide',
          title: slide.title,
          slideIndex: idx
        });
      }
    });

    // Search years
    const yearMatch = query.match(/\d{4}/);
    if (yearMatch) {
      const year = parseInt(yearMatch[0]);
      const data = vietnamData.find(d => d.year === year);
      if (data) {
        foundResults.push({
          type: 'data_year',
          title: `Year ${year}`,
          subtitle: `Population: ${(data.population / 1000000).toFixed(1)}M • GDP: $${data.gdpBillion}B`,
          year: year
        });
      }
    }

    // Search metrics
    const metrics = [
      { name: 'population', label: 'Population Growth' },
      { name: 'gdp', label: 'Economic Growth' },
      { name: 'urbanization', label: 'Urbanization' },
      { name: 'literacy', label: 'Literacy Rate' },
      { name: 'life expectancy', label: 'Life Expectancy' },
      { name: 'hdi', label: 'Human Development Index' },
      { name: 'education', label: 'Education' },
      { name: 'trade', label: 'International Trade' }
    ];

    metrics.forEach(metric => {
      if (metric.label.toLowerCase().includes(q) || metric.name.includes(q)) {
        const slideIdx = slidesConfig.findIndex(s =>
          s.title.toLowerCase().includes(metric.name)
        );
        foundResults.push({
          type: 'metric',
          title: metric.label,
          highlight: metric.name,
          slideIndex: slideIdx >= 0 ? slideIdx : undefined
        });
      }
    });

    setResults(foundResults.slice(0, 8));
  }, [query]);

  const handleResultClick = (result: SearchResult) => {
    if (result.slideIndex !== undefined) {
      onNavigate(result.slideIndex);
    }
    onClose();
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 bg-black/50 backdrop-blur-sm flex items-start justify-center pt-20 p-4 animate-fade-in">
      <div className="bg-background border border-border rounded-2xl w-full max-w-2xl shadow-2xl overflow-hidden">
        {/* Search Input */}
        <div className="p-4 border-b border-border flex items-center gap-3">
          <Search className="w-5 h-5 text-muted-foreground" />
          <input
            type="text"
            placeholder="Search slides, years, metrics... (Cmd/Ctrl + K)"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            autoFocus
            className="flex-1 bg-transparent outline-none text-foreground placeholder:text-muted-foreground text-lg"
          />
          <Button
            variant="ghost"
            size="sm"
            onClick={onClose}
            className="rounded w-8 h-8 p-0"
          >
            <X className="w-4 h-4" />
          </Button>
        </div>

        {/* Results */}
        <div className="max-h-[500px] overflow-y-auto">
          {results.length > 0 ? (
            <div className="divide-y divide-border">
              {results.map((result, idx) => (
                <button
                  key={idx}
                  onClick={() => handleResultClick(result)}
                  className="w-full p-4 hover:bg-card/50 transition-colors text-left flex items-center gap-3 group"
                >
                  {result.type === 'slide' && (
                    <>
                      <TrendingUp className="w-5 h-5 text-primary flex-shrink-0" />
                      <div>
                        <div className="font-semibold text-foreground group-hover:text-primary transition-colors">
                          {result.title}
                        </div>
                        <div className="text-xs text-muted-foreground">Slide {(result.slideIndex || 0) + 1}</div>
                      </div>
                    </>
                  )}

                  {result.type === 'data_year' && (
                    <>
                      <Calendar className="w-5 h-5 text-secondary flex-shrink-0" />
                      <div>
                        <div className="font-semibold text-foreground group-hover:text-secondary transition-colors">
                          {result.title}
                        </div>
                        <div className="text-xs text-muted-foreground">{result.subtitle}</div>
                      </div>
                    </>
                  )}

                  {result.type === 'metric' && (
                    <>
                      <TrendingUp className="w-5 h-5 text-accent flex-shrink-0" />
                      <div>
                        <div className="font-semibold text-foreground group-hover:text-accent transition-colors">
                          {result.title}
                        </div>
                        <div className="text-xs text-muted-foreground">
                          {result.slideIndex !== undefined ? `Slide ${result.slideIndex + 1}` : 'Data metric'}
                        </div>
                      </div>
                    </>
                  )}

                  <div className="ml-auto text-xs text-muted-foreground opacity-0 group-hover:opacity-100 transition-opacity">
                    Press Enter
                  </div>
                </button>
              ))}
            </div>
          ) : query.trim() ? (
            <div className="p-8 text-center text-muted-foreground">
              No results found for "{query}"
            </div>
          ) : (
            <div className="p-8 text-center text-muted-foreground">
              <div className="mb-4">Type to search...</div>
              <div className="text-xs space-y-1">
                <div>🔍 Search slide titles</div>
                <div>📅 Search by year (e.g., "1986", "2024")</div>
                <div>📊 Search by metric name</div>
              </div>
            </div>
          )}
        </div>

        {/* Footer */}
        <div className="border-t border-border p-3 bg-card/30 flex justify-between text-xs text-muted-foreground">
          <div>Results: {results.length}</div>
          <div className="flex gap-3">
            <span className="flex items-center gap-1">
              <kbd className="px-2 py-1 bg-card rounded">↑↓</kbd> Navigate
            </span>
            <span className="flex items-center gap-1">
              <kbd className="px-2 py-1 bg-card rounded">Enter</kbd> Select
            </span>
            <span className="flex items-center gap-1">
              <kbd className="px-2 py-1 bg-card rounded">Esc</kbd> Close
            </span>
          </div>
        </div>
      </div>
    </div>
  );
};
