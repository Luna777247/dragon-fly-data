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
    <div className="bg-card/95 backdrop-blur-md border border-primary/30 rounded-xl p-4 shadow-[0_0_30px_rgba(212,175,55,0.2)] animate-scale-in">
      <p className="text-foreground font-semibold mb-2 text-sm border-b border-border pb-2">
        {labelFormatter ? labelFormatter(label) : label}
      </p>
      <div className="space-y-1">
        {payload.map((entry, index) => {
          const [displayValue, displayName] = formatter 
            ? formatter(entry.value as number, entry.name as string)
            : [entry.value, entry.name];
          
          return (
            <div key={index} className="flex items-center gap-2">
              <div 
                className="w-3 h-3 rounded-full" 
                style={{ backgroundColor: entry.color }}
              />
              <span className="text-muted-foreground text-sm">{displayName}:</span>
              <span className="text-foreground font-bold text-sm ml-auto">{displayValue}</span>
            </div>
          );
        })}
      </div>
    </div>
  );
};