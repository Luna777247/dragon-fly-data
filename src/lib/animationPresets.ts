import gsap from 'gsap';
import { ANIMATION_DURATION, ANIMATION_DELAY } from '@/constants/slideConstants';

export const animationPresets = {
  fadeInUp: (selector: string, trigger: HTMLDivElement | null, delay = 0) => {
    gsap.from(selector, {
      opacity: 0,
      y: 50,
      scrollTrigger: {
        trigger,
        start: 'top center',
      },
      duration: ANIMATION_DURATION.long,
      delay,
      ease: 'power3.out',
    });
  },

  fadeInScale: (selector: string, trigger: HTMLDivElement | null, delay = 0) => {
    gsap.from(selector, {
      opacity: 0,
      scale: 0.9,
      scrollTrigger: {
        trigger,
        start: 'top center',
      },
      duration: ANIMATION_DURATION.long,
      delay,
      ease: 'back.out(1.2)',
    });
  },

  fadeInRotate: (selector: string, trigger: HTMLDivElement | null, delay = 0) => {
    gsap.from(selector, {
      opacity: 0,
      scale: 0.5,
      rotation: -180,
      scrollTrigger: {
        trigger,
        start: 'top center',
      },
      duration: ANIMATION_DURATION.veryLong,
      delay,
      ease: 'back.out(1.2)',
    });
  },

  staggerFadeIn: (selector: string, trigger: HTMLDivElement | null, staggerDelay = ANIMATION_DELAY.small) => {
    gsap.from(selector, {
      opacity: 0,
      x: -30,
      scrollTrigger: {
        trigger,
        start: 'top center',
      },
      duration: ANIMATION_DURATION.medium,
      stagger: staggerDelay,
      ease: 'power2.out',
    });
  },

  staggerScale: (selector: string, trigger: HTMLDivElement | null, staggerDelay = ANIMATION_DELAY.small) => {
    gsap.from(selector, {
      opacity: 0,
      scale: 0.8,
      scrollTrigger: {
        trigger,
        start: 'top center',
      },
      duration: ANIMATION_DURATION.medium,
      stagger: staggerDelay,
      ease: 'back.out(1.7)',
    });
  },

  fadeInLeft: (selector: string, trigger: HTMLDivElement | null, delay = 0) => {
    gsap.from(selector, {
      opacity: 0,
      x: -30,
      scrollTrigger: {
        trigger,
        start: 'top center',
      },
      duration: ANIMATION_DURATION.medium,
      delay,
      ease: 'power2.out',
    });
  },

  timeline: (trigger: HTMLDivElement | null) => {
    return gsap.timeline({
      scrollTrigger: {
        trigger,
        start: 'top center',
      },
    });
  },
};
