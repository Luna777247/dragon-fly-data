import { useCallback, useRef, useEffect } from 'react';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

export function useLazyAnimation() {
  const containerRef = useRef<HTMLDivElement>(null);

  const animateFromTop = useCallback((selector: string, delay = 0) => {
    if (!containerRef.current) return;

    gsap.from(selector, {
      opacity: 0,
      y: 50,
      scrollTrigger: {
        trigger: containerRef.current,
        start: 'top center',
      },
      duration: 0.8,
      delay,
      ease: 'power3.out',
    });
  }, []);

  const animateScale = useCallback((selector: string, delay = 0) => {
    if (!containerRef.current) return;

    gsap.from(selector, {
      opacity: 0,
      scale: 0.9,
      scrollTrigger: {
        trigger: containerRef.current,
        start: 'top center',
      },
      duration: 0.8,
      delay,
      ease: 'back.out(1.2)',
    });
  }, []);

  const animateStagger = useCallback((selector: string, staggerAmount = 0.1) => {
    if (!containerRef.current) return;

    gsap.from(selector, {
      opacity: 0,
      y: 30,
      scrollTrigger: {
        trigger: containerRef.current,
        start: 'top center',
      },
      duration: 0.6,
      stagger: staggerAmount,
      ease: 'power2.out',
    });
  }, []);

  useEffect(() => {
    return () => {
      const triggers = ScrollTrigger.getAll();
      triggers.forEach((trigger) => trigger.kill());
    };
  }, []);

  return {
    containerRef,
    animateFromTop,
    animateScale,
    animateStagger,
  };
}
