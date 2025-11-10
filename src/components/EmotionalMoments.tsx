import { useState } from 'react';
import { Share2, Heart, MessageCircle, Copy, Check } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { vietnamData } from '@/data/vietnamData';
import type { VietnamDataPoint } from '@/lib/types';

export interface EmotionalMoment {
  id: string;
  year: number;
  title: string;
  description: string;
  humanImpact: string;
  emotion: 'triumph' | 'resilience' | 'pride' | 'hope';
  metric: string;
  before: string;
  after: string;
}

const EMOTIONAL_MOMENTS: EmotionalMoment[] = [
  {
    id: 'unity_1975',
    year: 1975,
    title: 'Nation Unified',
    description: 'After 21 years of division, Vietnam became whole again.',
    humanImpact: 'Families separated by the war could finally reunite. A nation could focus its energy on building the future.',
    emotion: 'triumph',
    metric: 'Reunification',
    before: 'Divided nation',
    after: 'United nation'
  },
  {
    id: 'literacy_boom',
    year: 2024,
    title: 'A Nation Learns',
    description: 'Literacy rose from 15% to over 95% in just 70 years.',
    humanImpact: '98 million people gained the power to read, learn, and change their own destinies.',
    emotion: 'pride',
    metric: 'Literacy Rate',
    before: '15% literate',
    after: '95% literate'
  },
  {
    id: 'poverty_reduction',
    year: 2020,
    title: 'From Poverty to Progress',
    description: 'Extreme poverty dropped from 80% to under 5%.',
    humanImpact: 'Over 75 million people lifted out of poverty. Children now have opportunities their grandparents couldn\'t imagine.',
    emotion: 'hope',
    metric: 'Poverty Rate',
    before: '80% in poverty',
    after: '<5% in poverty'
  },
  {
    id: 'life_expectancy',
    year: 2024,
    title: 'Living Longer',
    description: 'Life expectancy increased from 35 to 73 years.',
    humanImpact: 'Grandparents now spend decades with their grandchildren. Careers and dreams span multiple decades.',
    emotion: 'resilience',
    metric: 'Life Expectancy',
    before: '35 years',
    after: '73 years'
  }
];

interface EmotionalMomentsProps {
  currentYear?: number;
  onShare?: (moment: EmotionalMoment) => void;
}

interface ShareableInsight {
  title: string;
  description: string;
  stats: string;
  emoji: string;
}

export const EmotionalMoments = ({ currentYear, onShare }: EmotionalMomentsProps) => {
  const [selectedMoment, setSelectedMoment] = useState<string | null>(null);
  const [copied, setCopied] = useState<string | null>(null);

  const emotionEmojis = {
    triumph: '🏆',
    resilience: '💪',
    pride: '🇻🇳',
    hope: '✨'
  };

  const emotionColors = {
    triumph: 'bg-yellow-500/20 border-yellow-500/50 text-yellow-400',
    resilience: 'bg-red-500/20 border-red-500/50 text-red-400',
    pride: 'bg-green-500/20 border-green-500/50 text-green-400',
    hope: 'bg-blue-500/20 border-blue-500/50 text-blue-400'
  };

  const getShareableInsight = (moment: EmotionalMoment): ShareableInsight => {
    return {
      title: moment.title,
      description: moment.humanImpact,
      stats: `${moment.before} → ${moment.after}`,
      emoji: emotionEmojis[moment.emotion]
    };
  };

  const handleShare = (moment: EmotionalMoment) => {
    const insight = getShareableInsight(moment);
    const text = `${insight.emoji} ${insight.title}\n\n${insight.description}\n\n📊 ${insight.stats}\n\nVietnام: Con Rồng Thức Tỉnh - 70 Years of Transformation`;

    if (navigator.share) {
      navigator.share({
        title: insight.title,
        text: text,
        url: window.location.href
      });
    } else {
      // Fallback: copy to clipboard
      navigator.clipboard.writeText(text);
      setCopied(moment.id);
      setTimeout(() => setCopied(null), 2000);
    }

    onShare?.(moment);
  };

  const relevantMoments = currentYear
    ? EMOTIONAL_MOMENTS.filter(m => Math.abs(m.year - currentYear) <= 5)
    : EMOTIONAL_MOMENTS;

  return (
    <div className="space-y-4">
      {relevantMoments.map((moment) => (
        <div
          key={moment.id}
          className={`border-l-4 p-6 rounded-lg transition-all duration-300 cursor-pointer hover:shadow-lg ${
            emotionColors[moment.emotion]
          } border-border`}
          onClick={() => setSelectedMoment(selectedMoment === moment.id ? null : moment.id)}
        >
          <div className="flex items-start justify-between mb-3">
            <div className="flex items-center gap-3">
              <span className="text-3xl">{emotionEmojis[moment.emotion]}</span>
              <div>
                <div className="text-sm font-bold text-muted-foreground uppercase">{moment.metric}</div>
                <h3 className="font-bold text-lg text-foreground">{moment.title}</h3>
              </div>
            </div>
            <Button
              variant="ghost"
              size="sm"
              className="opacity-0 group-hover:opacity-100 transition-opacity"
              onClick={(e) => {
                e.stopPropagation();
                handleShare(moment);
              }}
            >
              {copied === moment.id ? (
                <Check className="w-4 h-4 text-green-400" />
              ) : (
                <Share2 className="w-4 h-4" />
              )}
            </Button>
          </div>

          <p className="text-muted-foreground mb-3">{moment.description}</p>

          {selectedMoment === moment.id && (
            <div className="space-y-4 pt-4 border-t border-border/50 animate-fade-in">
              <div className="bg-background/50 p-4 rounded-lg">
                <h4 className="font-semibold text-foreground mb-2">Human Impact</h4>
                <p className="text-muted-foreground leading-relaxed">{moment.humanImpact}</p>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div className="text-center">
                  <div className="text-xs text-muted-foreground mb-1">Before</div>
                  <div className="font-bold text-foreground">{moment.before}</div>
                </div>
                <div className="text-center">
                  <div className="text-xs text-muted-foreground mb-1">Now</div>
                  <div className="font-bold text-foreground">{moment.after}</div>
                </div>
              </div>

              <div className="flex gap-2 pt-2">
                <Button
                  size="sm"
                  variant="outline"
                  className="flex-1 gap-2"
                  onClick={(e) => {
                    e.stopPropagation();
                    handleShare(moment);
                  }}
                >
                  <Share2 className="w-4 h-4" />
                  {copied === moment.id ? 'Copied!' : 'Share'}
                </Button>
                <Button
                  size="sm"
                  variant="outline"
                  className="gap-2"
                  onClick={(e) => {
                    e.stopPropagation();
                    // Would connect to saved moments in future
                  }}
                >
                  <Heart className="w-4 h-4" />
                </Button>
                <Button
                  size="sm"
                  variant="outline"
                  className="gap-2"
                  onClick={(e) => {
                    e.stopPropagation();
                    // Would open comment modal in future
                  }}
                >
                  <MessageCircle className="w-4 h-4" />
                </Button>
              </div>
            </div>
          )}
        </div>
      ))}
    </div>
  );
};
