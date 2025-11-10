import { useEffect, useRef } from 'react';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import { animationPresets } from '@/lib/animationPresets';

gsap.registerPlugin(ScrollTrigger);

interface AnimationConfig {
  title?: boolean;
  charts?: boolean;
  cards?: boolean;
  stagger?: boolean;
}

export const useSlideAnimation = (config: AnimationConfig = { title: true, charts: true, cards: false, stagger: false }) => {
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (!containerRef.current) return;

    const ctx = gsap.context(() => {
      if (config.title) {
        animationPresets.fadeInUp('.slide-title', containerRef.current);
      }

      if (config.charts) {
        if (config.stagger) {
          animationPresets.staggerScale('.slide-chart', containerRef.current, 0.15);
        } else {
          animationPresets.fadeInScale('.slide-chart', containerRef.current, 0.3);
        }
      }

      if (config.cards) {
        animationPresets.staggerScale('.slide-card', containerRef.current, 0.1);
      }
    }, containerRef);

    return () => ctx.revert();
  }, [config]);

  return containerRef;
};
