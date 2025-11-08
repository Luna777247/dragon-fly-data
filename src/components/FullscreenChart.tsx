import { useState } from 'react';
import { X, ZoomIn, ZoomOut, RotateCcw } from 'lucide-react';
import { Button } from '@/components/ui/button';

interface FullscreenChartProps {
  isOpen: boolean;
  onClose: () => void;
  children: React.ReactNode;
  title?: string;
}

export const FullscreenChart = ({ isOpen, onClose, children, title }: FullscreenChartProps) => {
  const [zoom, setZoom] = useState(1);

  if (!isOpen) return null;

  const handleZoomIn = () => {
    setZoom(prev => Math.min(prev + 0.2, 2));
  };

  const handleZoomOut = () => {
    setZoom(prev => Math.max(prev - 0.2, 0.6));
  };

  const handleReset = () => {
    setZoom(1);
  };

  return (
    <div className="fixed inset-0 z-50 bg-background/95 backdrop-blur-sm animate-fade-in">
      <div className="absolute top-4 right-4 flex items-center gap-2 z-10">
        <div className="flex items-center gap-1 bg-card/80 backdrop-blur-sm border border-border rounded-lg p-1">
          <Button
            variant="ghost"
            size="icon"
            onClick={handleZoomOut}
            disabled={zoom <= 0.6}
            className="h-8 w-8"
          >
            <ZoomOut className="w-4 h-4" />
          </Button>
          <span className="text-sm font-medium px-2 min-w-[3rem] text-center">
            {Math.round(zoom * 100)}%
          </span>
          <Button
            variant="ghost"
            size="icon"
            onClick={handleZoomIn}
            disabled={zoom >= 2}
            className="h-8 w-8"
          >
            <ZoomIn className="w-4 h-4" />
          </Button>
          <Button
            variant="ghost"
            size="icon"
            onClick={handleReset}
            className="h-8 w-8"
          >
            <RotateCcw className="w-4 h-4" />
          </Button>
        </div>
        <Button
          variant="ghost"
          size="icon"
          onClick={onClose}
          className="bg-card/80 backdrop-blur-sm border border-border h-9 w-9"
        >
          <X className="w-5 h-5" />
        </Button>
      </div>

      {title && (
        <div className="absolute top-4 left-4 z-10">
          <h2 className="text-2xl font-bold text-foreground bg-card/80 backdrop-blur-sm border border-border rounded-lg px-4 py-2">
            {title}
          </h2>
        </div>
      )}

      <div className="w-full h-full overflow-auto flex items-center justify-center p-16">
        <div 
          className="transition-transform duration-300 ease-out w-full h-full flex items-center justify-center"
          style={{ transform: `scale(${zoom})` }}
        >
          {children}
        </div>
      </div>
    </div>
  );
};
