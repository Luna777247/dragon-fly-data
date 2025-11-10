import { lazy, ComponentType } from 'react';

export interface SlideConfig {
  component: ComponentType;
  title: string;
}

const lazySlides = {
  SlideDashboard: lazy(() => import('@/components/slides/SlideDashboard').then((m) => ({ default: m.SlideDashboard }))),
  SlideYearComparison: lazy(() => import('@/components/slides/SlideYearComparison').then((m) => ({ default: m.SlideYearComparison }))),
  SlidePopulationDemographics: lazy(() => import('@/components/slides/SlidePopulationDemographics').then((m) => ({ default: m.SlidePopulationDemographics }))),
  SlideSocialTransition: lazy(() => import('@/components/slides/SlideSocialTransition').then((m) => ({ default: m.SlideSocialTransition }))),
  SlideMigration: lazy(() => import('@/components/slides/SlideMigration').then((m) => ({ default: m.SlideMigration }))),
  SlideRegionalDensity: lazy(() => import('@/components/slides/SlideRegionalDensity').then((m) => ({ default: m.SlideRegionalDensity }))),
  SlideDataExplorer: lazy(() => import('@/components/slides/SlideDataExplorer').then((m) => ({ default: m.SlideDataExplorer }))),
  SlideEconomicDevelopment: lazy(() => import('@/components/slides/SlideEconomicDevelopment').then((m) => ({ default: m.SlideEconomicDevelopment }))),
  SlideTrade: lazy(() => import('@/components/slides/SlideTrade').then((m) => ({ default: m.SlideTrade }))),
  SlideEducation: lazy(() => import('@/components/slides/SlideEducation').then((m) => ({ default: m.SlideEducation }))),
  SlideSociety: lazy(() => import('@/components/slides/SlideSociety').then((m) => ({ default: m.SlideSociety }))),
  SlideEnvironment: lazy(() => import('@/components/slides/SlideEnvironment').then((m) => ({ default: m.SlideEnvironment }))),
  SlideRegional: lazy(() => import('@/components/slides/SlideRegional').then((m) => ({ default: m.SlideRegional }))),
  SlideFuture: lazy(() => import('@/components/slides/SlideFuture').then((m) => ({ default: m.SlideFuture }))),
  SlideConclusion: lazy(() => import('@/components/slides/SlideConclusion').then((m) => ({ default: m.SlideConclusion }))),
};

export const slidesConfig: SlideConfig[] = [
  { component: lazySlides.SlideDashboard, title: 'Dashboard' },
  { component: lazySlides.SlideYearComparison, title: 'So Sánh' },
  { component: lazySlides.SlidePopulationDemographics, title: 'Dân Số' },
  { component: lazySlides.SlideSocialTransition, title: 'Chuyển Đổi Xã Hội' },
  { component: lazySlides.SlideMigration, title: 'Di Cư' },
  { component: lazySlides.SlideRegionalDensity, title: 'Phân Bố Vùng' },
  { component: lazySlides.SlideEconomicDevelopment, title: 'Kinh Tế' },
  { component: lazySlides.SlideTrade, title: 'Thương Mại' },
  { component: lazySlides.SlideEducation, title: 'Giáo Dục' },
  { component: lazySlides.SlideDataExplorer, title: 'Khám Phá Dữ Liệu' },
  { component: lazySlides.SlideSociety, title: 'Xã Hội' },
  { component: lazySlides.SlideEnvironment, title: 'Môi Trường' },
  { component: lazySlides.SlideRegional, title: 'Khu Vực' },
  { component: lazySlides.SlideFuture, title: 'Tương Lai' },
  { component: lazySlides.SlideConclusion, title: 'Kết Luận' },
];
