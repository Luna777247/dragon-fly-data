import { useEffect, useRef } from 'react';
import gsap from 'gsap';
import { MilestoneMarker } from '@/constants/narrativeStructure';

interface NarrativeMilestoneMarkerProps {
  milestone: MilestoneMarker;
  isVisible: boolean;
}

export const NarrativeMilestoneMarker = ({ milestone, isVisible }: NarrativeMilestoneMarkerProps) => {
  const containerRef = useRef<HTMLDivElement>(null);
  const contentRef = useRef<HTMLDivElement>(null);

  const emotionColors = {
    challenge: { bg: 'bg-red-500/20', border: 'border-red-500/50', text: 'text-red-400' },
    breakthrough: { bg: 'bg-green-500/20', border: 'border-green-500/50', text: 'text-green-400' },
    consolidation: { bg: 'bg-blue-500/20', border: 'border-blue-500/50', text: 'text-blue-400' },
    transformation: { bg: 'bg-purple-500/20', border: 'border-purple-500/50', text: 'text-purple-400' }
  };

  const emotionIcons = {
    challenge: '⚡',
    breakthrough: '🚀',
    consolidation: '✓',
    transformation: '🔄'
  };

  const colors = emotionColors[milestone.emotion];
  const icon = emotionIcons[milestone.emotion];

  useEffect(() => {
    if (!containerRef.current || !isVisible) return;

    const tl = gsap.timeline();

    tl.from(contentRef.current, {
      opacity: 0,
      x: -50,
      duration: 0.8,
      ease: 'power3.out'
    })
    .to(contentRef.current, {
      boxShadow: `0 0 30px rgba(212, 175, 55, 0.3)`,
      duration: 0.6,
      ease: 'power2.inOut'
    }, 0);

    return () => tl.kill();
  }, [isVisible]);

  return (
    <div
      ref={containerRef}
      className={`fixed right-6 top-1/3 z-40 pointer-events-none ${isVisible ? 'opacity-100' : 'opacity-0'} transition-opacity duration-500`}
    >
      <div
        ref={contentRef}
        className={`${colors.bg} ${colors.border} border-l-4 rounded-lg p-6 max-w-xs backdrop-blur-sm`}
      >
        <div className="flex items-start gap-3">
          <span className="text-3xl flex-shrink-0">{icon}</span>
          <div>
            <div className="flex items-center gap-2 mb-1">
              <span className={`text-sm font-bold ${colors.text}`}>{milestone.year}</span>
              <span className="text-xs text-muted-foreground capitalize">{milestone.emotion}</span>
            </div>
            <h4 className="font-bold text-foreground mb-2">{milestone.title}</h4>
            <p className="text-sm text-muted-foreground mb-2">{milestone.description}</p>
            <p className="text-xs font-semibold text-primary">Impact: {milestone.impact}</p>
          </div>
        </div>
      </div>
    </div>
  );
};
