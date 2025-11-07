import { TooltipProps } from 'recharts';

interface CustomTooltipProps extends TooltipProps<number, string> {
  formatter?: (value: number, name: string) => [string, string];
  labelFormatter?: (label: string) => string;
}

export const CustomTooltip = ({ 
  active, 
  payload, 
  label,
  formatter,
  labelFormatter 
}: CustomTooltipProps) => {
  if (!active || !payload || !payload.length) return null;

  return (
    <div className="bg-card/95 backdrop-blur-md border border-primary/30 rounded-xl p-4 shadow-[0_0_30px_rgba(212,175,55,0.2)] animate-scale-in max-w-xs">
      <p className="text-foreground font-semibold mb-2 text-sm border-b border-border pb-2">
        {labelFormatter ? labelFormatter(label) : `Năm ${label}`}
      </p>
      <div className="space-y-1.5">
        {payload.map((entry, index) => {
          const [displayValue, displayName] = formatter 
            ? formatter(entry.value as number, entry.name as string)
            : [entry.value?.toLocaleString() || 'N/A', entry.name];
          
          return (
            <div key={index} className="flex items-center gap-2 text-sm">
              <div 
                className="w-3 h-3 rounded-full flex-shrink-0 shadow-sm" 
                style={{ backgroundColor: entry.color }}
              />
              <span className="text-muted-foreground min-w-0 flex-1">{displayName}:</span>
              <span className="text-foreground font-bold whitespace-nowrap">{displayValue}</span>
            </div>
          );
        })}
      </div>
    </div>
  );
};