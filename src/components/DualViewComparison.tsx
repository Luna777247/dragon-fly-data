import { useState, useEffect } from 'react';
import { X, ChevronLeft, ChevronRight } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { vietnamData } from '@/data/vietnamData';
import type { VietnamDataPoint } from '@/lib/types';

interface DualViewComparisonProps {
  isOpen: boolean;
  onClose: () => void;
  defaultYear1?: number;
  defaultYear2?: number;
}

export const DualViewComparison = ({
  isOpen,
  onClose,
  defaultYear1 = 1955,
  defaultYear2 = 2024
}: DualViewComparisonProps) => {
  const [year1, setYear1] = useState(defaultYear1);
  const [year2, setYear2] = useState(defaultYear2);

  const data1 = vietnamData.find(d => d.year === year1);
  const data2 = vietnamData.find(d => d.year === year2);

  const years = vietnamData.map(d => d.year);

  const renderDataComparison = (d1: VietnamDataPoint | undefined, d2: VietnamDataPoint | undefined) => {
    if (!d1 || !d2) return null;

    const metrics = [
      {
        label: 'Population',
        value1: `${(d1.population / 1000000).toFixed(1)}M`,
        value2: `${(d2.population / 1000000).toFixed(1)}M`,
        change: ((d2.population / d1.population - 1) * 100).toFixed(1),
        unit: '%'
      },
      {
        label: 'GDP',
        value1: `$${d1.gdpBillion}B`,
        value2: `$${d2.gdpBillion}B`,
        change: ((d2.gdpBillion / d1.gdpBillion - 1) * 100).toFixed(1),
        unit: '%'
      },
      {
        label: 'Urbanization',
        value1: `${d1.urbanPopPercent}%`,
        value2: `${d2.urbanPopPercent}%`,
        change: (d2.urbanPopPercent - d1.urbanPopPercent).toFixed(1),
        unit: 'pp'
      },
      {
        label: 'Life Expectancy',
        value1: `${d1.lifeExpectancy} yrs`,
        value2: `${d2.lifeExpectancy} yrs`,
        change: (d2.lifeExpectancy - d1.lifeExpectancy).toFixed(1),
        unit: 'yrs'
      },
      {
        label: 'Literacy Rate',
        value1: `${d1.literacyRate}%`,
        value2: `${d2.literacyRate}%`,
        change: (d2.literacyRate - d1.literacyRate).toFixed(1),
        unit: 'pp'
      },
      {
        label: 'HDI',
        value1: (d1.hdi * 100).toFixed(1),
        value2: (d2.hdi * 100).toFixed(1),
        change: ((d2.hdi - d1.hdi) * 100).toFixed(1),
        unit: 'pts'
      }
    ];

    return (
      <div className="space-y-3">
        {metrics.map((metric, idx) => {
          const changeNum = parseFloat(metric.change);
          const isPositive = changeNum >= 0;

          return (
            <div key={idx} className="bg-card/50 p-4 rounded-lg border border-border">
              <h4 className="text-sm font-semibold text-muted-foreground mb-3">{metric.label}</h4>
              <div className="grid grid-cols-3 gap-3 items-end">
                <div className="text-center">
                  <div className="text-xs text-muted-foreground mb-1">{year1}</div>
                  <div className="text-2xl font-bold text-primary">{metric.value1}</div>
                </div>

                <div className="flex flex-col items-center justify-center">
                  <div className="text-xs font-bold mb-1">
                    <span className={isPositive ? 'text-green-400' : 'text-red-400'}>
                      {isPositive ? '+' : ''}{metric.change}{metric.unit}
                    </span>
                  </div>
                  <div className="w-12 h-1 bg-gradient-to-r from-primary via-secondary to-accent rounded-full"></div>
                </div>

                <div className="text-center">
                  <div className="text-xs text-muted-foreground mb-1">{year2}</div>
                  <div className="text-2xl font-bold text-secondary">{metric.value2}</div>
                </div>
              </div>
            </div>
          );
        })}
      </div>
    );
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4 animate-fade-in">
      <div className="bg-background border border-border rounded-2xl max-w-4xl w-full max-h-[90vh] overflow-y-auto shadow-2xl">
        {/* Header */}
        <div className="sticky top-0 bg-card/95 backdrop-blur-sm p-6 border-b border-border flex justify-between items-center">
          <h2 className="font-display text-3xl font-bold">Time Period Comparison</h2>
          <Button
            variant="ghost"
            size="sm"
            onClick={onClose}
            className="rounded-full w-10 h-10 p-0"
          >
            <X className="w-5 h-5" />
          </Button>
        </div>

        {/* Content */}
        <div className="p-6 space-y-6">
          {/* Year Selectors */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
              <label className="text-sm font-semibold text-muted-foreground mb-3 block">
                First Period
              </label>
              <div className="flex items-center gap-2">
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => {
                    const idx = years.indexOf(year1);
                    if (idx > 0) setYear1(years[idx - 1]);
                  }}
                  disabled={year1 === years[0]}
                >
                  <ChevronLeft className="w-4 h-4" />
                </Button>

                <div className="flex-1">
                  <input
                    type="range"
                    min={0}
                    max={years.length - 1}
                    value={years.indexOf(year1)}
                    onChange={(e) => setYear1(years[parseInt(e.target.value)])}
                    className="w-full"
                  />
                </div>

                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => {
                    const idx = years.indexOf(year1);
                    if (idx < years.length - 1) setYear1(years[idx + 1]);
                  }}
                  disabled={year1 === years[years.length - 1]}
                >
                  <ChevronRight className="w-4 h-4" />
                </Button>

                <div className="w-16 text-center">
                  <div className="text-2xl font-bold text-primary">{year1}</div>
                </div>
              </div>
            </div>

            <div>
              <label className="text-sm font-semibold text-muted-foreground mb-3 block">
                Second Period
              </label>
              <div className="flex items-center gap-2">
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => {
                    const idx = years.indexOf(year2);
                    if (idx > 0) setYear2(years[idx - 1]);
                  }}
                  disabled={year2 === years[0]}
                >
                  <ChevronLeft className="w-4 h-4" />
                </Button>

                <div className="flex-1">
                  <input
                    type="range"
                    min={0}
                    max={years.length - 1}
                    value={years.indexOf(year2)}
                    onChange={(e) => setYear2(years[parseInt(e.target.value)])}
                    className="w-full"
                  />
                </div>

                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => {
                    const idx = years.indexOf(year2);
                    if (idx < years.length - 1) setYear2(years[idx + 1]);
                  }}
                  disabled={year2 === years[years.length - 1]}
                >
                  <ChevronRight className="w-4 h-4" />
                </Button>

                <div className="w-16 text-center">
                  <div className="text-2xl font-bold text-secondary">{year2}</div>
                </div>
              </div>
            </div>
          </div>

          {/* Comparison Results */}
          <div className="border-t border-border pt-6">
            {renderDataComparison(data1, data2)}
          </div>

          {/* Summary */}
          {data1 && data2 && (
            <div className="bg-primary/10 p-6 rounded-lg border border-primary/30">
              <h3 className="font-bold text-primary mb-3">Transformation Summary</h3>
              <p className="text-muted-foreground leading-relaxed">
                Over {year2 - year1} years, Vietnam's population grew {((data2.population / data1.population - 1) * 100).toFixed(0)}%,
                while GDP expanded by {((data2.gdpBillion / data1.gdpBillion - 1) * 100).toFixed(0)}%.
                Urbanization increased from {data1.urbanPopPercent}% to {data2.urbanPopPercent}%,
                life expectancy rose from {data1.lifeExpectancy} to {data2.lifeExpectancy} years,
                and literacy improved from {data1.literacyRate}% to {data2.literacyRate}%.
              </p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};
