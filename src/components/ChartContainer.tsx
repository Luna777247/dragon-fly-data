import { ReactNode } from 'react';
import { Maximize2 } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { ExportButtons } from '@/components/ExportButtons';

interface ChartContainerProps {
  id: string;
  title: string;
  children: ReactNode;
  onFullscreen?: () => void;
  data?: unknown;
  filename?: string;
  showExport?: boolean;
  className?: string;
}

export const ChartContainer = ({
  id,
  title,
  children,
  onFullscreen,
  data,
  filename,
  showExport = true,
  className = '',
}: ChartContainerProps) => {
  return (
    <div id={id} className={`slide-chart bg-card/50 backdrop-blur-sm p-8 rounded-2xl border border-border shadow-elegant ${className}`}>
      <div className="flex justify-between items-center mb-6">
        <h3 className="text-xl font-semibold">{title}</h3>
        <div className="flex gap-2">
          {onFullscreen && (
            <Button variant="outline" size="sm" onClick={onFullscreen} className="gap-2">
              <Maximize2 className="w-4 h-4" />
              Toàn màn hình
            </Button>
          )}
          {showExport && data && filename && (
            <ExportButtons elementId={id} filename={filename} data={data} />
          )}
        </div>
      </div>
      {children}
    </div>
  );
};
