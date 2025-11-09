import { lazy, ComponentType } from 'react';

export interface SlideConfig {
  component: ComponentType;
  title: string;
}

const lazySlides = {
  SlideDashboard: lazy(() => import('@/components/slides/SlideDashboard').then((m) => ({ default: m.SlideDashboard }))),
  SlideYearComparison: lazy(() => import('@/components/slides/SlideYearComparison').then((m) => ({ default: m.SlideYearComparison }))),
  SlidePopulation: lazy(() => import('@/components/slides/SlidePopulation').then((m) => ({ default: m.SlidePopulation }))),
  SlideDemographics: lazy(() => import('@/components/slides/SlideDemographics').then((m) => ({ default: m.SlideDemographics }))),
  SlideBirthDeath: lazy(() => import('@/components/slides/SlideBirthDeath').then((m) => ({ default: m.SlideBirthDeath }))),
  SlideUrbanization: lazy(() => import('@/components/slides/SlideUrbanization').then((m) => ({ default: m.SlideUrbanization }))),
  SlideMigration: lazy(() => import('@/components/slides/SlideMigration').then((m) => ({ default: m.SlideMigration }))),
  SlideRegionalDensity: lazy(() => import('@/components/slides/SlideRegionalDensity').then((m) => ({ default: m.SlideRegionalDensity }))),
  SlideSunburst: lazy(() => import('@/components/slides/SlideSunburst').then((m) => ({ default: m.SlideSunburst }))),
  SlideRadialViz: lazy(() => import('@/components/slides/SlideRadialViz').then((m) => ({ default: m.SlideRadialViz }))),
  SlideEconomy: lazy(() => import('@/components/slides/SlideEconomy').then((m) => ({ default: m.SlideEconomy }))),
  SlideEmployment: lazy(() => import('@/components/slides/SlideEmployment').then((m) => ({ default: m.SlideEmployment }))),
  SlideFeatherViz: lazy(() => import('@/components/slides/SlideFeatherViz').then((m) => ({ default: m.SlideFeatherViz }))),
  SlideEducation: lazy(() => import('@/components/slides/SlideEducation').then((m) => ({ default: m.SlideEducation }))),
  SlideTrade: lazy(() => import('@/components/slides/SlideTrade').then((m) => ({ default: m.SlideTrade }))),
  Slide3DViz: lazy(() => import('@/components/slides/Slide3DViz').then((m) => ({ default: m.Slide3DViz }))),
  SlideSociety: lazy(() => import('@/components/slides/SlideSociety').then((m) => ({ default: m.SlideSociety }))),
  SlideEnvironment: lazy(() => import('@/components/slides/SlideEnvironment').then((m) => ({ default: m.SlideEnvironment }))),
  SlideRegional: lazy(() => import('@/components/slides/SlideRegional').then((m) => ({ default: m.SlideRegional }))),
  SlideFuture: lazy(() => import('@/components/slides/SlideFuture').then((m) => ({ default: m.SlideFuture }))),
  SlideConclusion: lazy(() => import('@/components/slides/SlideConclusion').then((m) => ({ default: m.SlideConclusion }))),
};

export const slidesConfig: SlideConfig[] = [
  { component: lazySlides.SlideDashboard, title: 'Dashboard' },
  { component: lazySlides.SlideYearComparison, title: 'So Sánh' },
  { component: lazySlides.SlidePopulation, title: 'Dân Số' },
  { component: lazySlides.SlideDemographics, title: 'Nhân Khẩu' },
  { component: lazySlides.SlideBirthDeath, title: 'Sinh Tử' },
  { component: lazySlides.SlideUrbanization, title: 'Đô Thị' },
  { component: lazySlides.SlideMigration, title: 'Di Cư' },
  { component: lazySlides.SlideRegionalDensity, title: 'Phân Bố Vùng' },
  { component: lazySlides.SlideSunburst, title: 'Sunburst' },
  { component: lazySlides.SlideRadialViz, title: 'Bông Hoa' },
  { component: lazySlides.SlideEconomy, title: 'Kinh Tế' },
  { component: lazySlides.SlideEmployment, title: 'Việc Làm' },
  { component: lazySlides.SlideFeatherViz, title: 'Lông Vũ' },
  { component: lazySlides.SlideEducation, title: 'Giáo Dục' },
  { component: lazySlides.SlideTrade, title: 'Thương Mại' },
  { component: lazySlides.Slide3DViz, title: '3D Viz' },
  { component: lazySlides.SlideSociety, title: 'Xã Hội' },
  { component: lazySlides.SlideEnvironment, title: 'Môi Trường' },
  { component: lazySlides.SlideRegional, title: 'Khu Vực' },
  { component: lazySlides.SlideFuture, title: 'Tương Lai' },
  { component: lazySlides.SlideConclusion, title: 'Kết Luận' },
];
