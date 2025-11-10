import { useEffect, useRef } from 'react';
import { ArrowRight } from 'lucide-react';
import gsap from 'gsap';
import { Button } from '@/components/ui/button';
import { NarrativeChapter, NARRATIVE_INSIGHTS } from '@/constants/narrativeStructure';

interface SlideChapterIntroProps {
  chapter: NarrativeChapter;
  onContinue: () => void;
}

export const SlideChapterIntro = ({ chapter, onContinue }: SlideChapterIntroProps) => {
  const containerRef = useRef<HTMLDivElement>(null);
  const titleRef = useRef<HTMLHeadingElement>(null);
  const descriptionRef = useRef<HTMLParagraphElement>(null);
  const insightRef = useRef<HTMLDivElement>(null);
  const buttonRef = useRef<HTMLButtonElement>(null);

  const chapterId = chapter.id as keyof typeof NARRATIVE_INSIGHTS;
  const insight = NARRATIVE_INSIGHTS[chapterId];

  useEffect(() => {
    if (!containerRef.current) return;

    const tl = gsap.timeline({ delay: 0.3 });

    tl.from(titleRef.current, {
      opacity: 0,
      y: 50,
      duration: 1,
      ease: 'power3.out'
    })
    .from(descriptionRef.current, {
      opacity: 0,
      y: 30,
      duration: 0.8,
      ease: 'power2.out'
    }, '-=0.5')
    .from(insightRef.current, {
      opacity: 0,
      y: 40,
      duration: 1,
      ease: 'power3.out'
    }, '-=0.5')
    .from(buttonRef.current, {
      opacity: 0,
      scale: 0.9,
      duration: 0.6,
      ease: 'back.out(1.7)'
    }, '-=0.3');

    return () => tl.kill();
  }, []);

  return (
    <div
      ref={containerRef}
      className="relative min-h-screen flex items-center justify-center overflow-hidden py-20 px-6"
      style={{
        background: `linear-gradient(135deg, hsl(var(--background)), hsl(var(--background) / 0.8))`,
        borderLeft: `4px solid ${chapter.color}`
      }}
    >
      <div className="absolute inset-0 opacity-5">
        <div className="absolute top-0 left-0 w-96 h-96 bg-gradient-to-br from-primary to-transparent rounded-full blur-3xl"></div>
        <div className="absolute bottom-0 right-0 w-96 h-96 bg-gradient-to-tl from-accent to-transparent rounded-full blur-3xl"></div>
      </div>

      <div className="relative z-10 max-w-3xl mx-auto text-center">
        <div className="mb-8 text-6xl">{chapter.icon}</div>

        <h1
          ref={titleRef}
          className="font-display text-5xl md:text-6xl lg:text-7xl font-bold mb-6"
          style={{ color: chapter.color }}
        >
          {chapter.title}
        </h1>

        <p className="text-lg md:text-xl text-muted-foreground mb-4 italic">
          {chapter.vietnameseTitle}
        </p>

        <p
          ref={descriptionRef}
          className="text-xl md:text-2xl text-foreground mb-12 leading-relaxed font-light"
        >
          {chapter.description}
        </p>

        <div
          ref={insightRef}
          className="bg-card/40 backdrop-blur-sm border-l-4 p-8 rounded-lg mb-12"
          style={{ borderColor: chapter.color }}
        >
          <p className="text-lg text-foreground leading-relaxed">
            {insight.opening}
          </p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-12">
          <div className="bg-primary/10 p-6 rounded-lg border border-primary/30">
            <h3 className="font-bold text-primary mb-3">Theme</h3>
            <p className="text-muted-foreground capitalize">{chapter.emotionalTheme}</p>
          </div>
          <div className="bg-secondary/10 p-6 rounded-lg border border-secondary/30">
            <h3 className="font-bold text-secondary mb-3">Slides</h3>
            <p className="text-muted-foreground">{chapter.slideRange[0]} - {chapter.slideRange[1]}</p>
          </div>
        </div>

        <Button
          ref={buttonRef}
          onClick={onContinue}
          size="lg"
          className="bg-primary hover:bg-primary-glow text-primary-foreground px-12 py-6 rounded-full font-semibold shadow-lg hover:shadow-xl transition-all gap-2 group"
        >
          Begin Chapter
          <ArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
        </Button>
      </div>
    </div>
  );
};
