import { useState } from 'react';
import { ChevronDown, Users, BookOpen, TrendingUp } from 'lucide-react';
import { Button } from '@/components/ui/button';

export interface ContentLayer {
  id: string;
  type: 'human_story' | 'policy_context' | 'data_insight' | 'comparative_analysis';
  title: string;
  content: string;
  icon: React.ReactNode;
  metadata?: Record<string, string | number>;
}

interface ContentLayersProps {
  layers: ContentLayer[];
  defaultExpanded?: boolean;
}

export const ContentLayers = ({ layers, defaultExpanded = false }: ContentLayersProps) => {
  const [expandedId, setExpandedId] = useState<string | null>(defaultExpanded ? layers[0]?.id : null);

  const layerIcons = {
    human_story: <Users className="w-5 h-5" />,
    policy_context: <BookOpen className="w-5 h-5" />,
    data_insight: <TrendingUp className="w-5 h-5" />,
    comparative_analysis: <TrendingUp className="w-5 h-5" />
  };

  const layerColors = {
    human_story: 'border-primary/50 bg-primary/5',
    policy_context: 'border-secondary/50 bg-secondary/5',
    data_insight: 'border-accent/50 bg-accent/5',
    comparative_analysis: 'border-yellow-500/50 bg-yellow-500/5'
  };

  const layerLabels = {
    human_story: 'Human Impact',
    policy_context: 'Policy Context',
    data_insight: 'Data Insight',
    comparative_analysis: 'Regional Comparison'
  };

  return (
    <div className="space-y-4">
      {layers.map((layer) => (
        <div
          key={layer.id}
          className={`border-l-4 rounded-lg transition-all duration-300 ${layerColors[layer.type]}`}
        >
          <Button
            variant="ghost"
            className="w-full justify-between items-center p-4 hover:bg-transparent text-left h-auto"
            onClick={() => setExpandedId(expandedId === layer.id ? null : layer.id)}
          >
            <div className="flex items-center gap-3">
              <div className="text-muted-foreground">{layerIcons[layer.type]}</div>
              <div>
                <div className="text-xs font-semibold text-muted-foreground uppercase">
                  {layerLabels[layer.type]}
                </div>
                <div className="font-bold text-foreground text-left">{layer.title}</div>
              </div>
            </div>
            <ChevronDown
              className={`w-5 h-5 text-muted-foreground transition-transform duration-300 ${
                expandedId === layer.id ? 'rotate-180' : ''
              }`}
            />
          </Button>

          {expandedId === layer.id && (
            <div className="px-4 pb-4 pt-2 border-t border-border/50 animate-fade-in">
              <p className="text-foreground/90 leading-relaxed mb-4">{layer.content}</p>
              {layer.metadata && (
                <div className="grid grid-cols-2 gap-3 text-sm">
                  {Object.entries(layer.metadata).map(([key, value]) => (
                    <div key={key} className="bg-card/50 p-2 rounded">
                      <div className="text-xs text-muted-foreground capitalize">{key.replace(/_/g, ' ')}</div>
                      <div className="font-semibold text-foreground">{value}</div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}
        </div>
      ))}
    </div>
  );
};
