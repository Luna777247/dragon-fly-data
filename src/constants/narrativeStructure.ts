export interface NarrativeChapter {
  id: string;
  title: string;
  vietnameseTitle: string;
  description: string;
  emotionalTheme: string;
  milestones: string[];
  slideRange: [number, number];
  color: string;
  icon: string;
}

export interface MilestoneMarker {
  year: number;
  title: string;
  description: string;
  impact: string;
  slideIndex: number;
  emotion: 'challenge' | 'breakthrough' | 'consolidation' | 'transformation';
}

export const NARRATIVE_CHAPTERS: NarrativeChapter[] = [
  {
    id: 'act1_foundation',
    title: 'Act I: Foundation - A Nation Awakens',
    vietnameseTitle: 'Hoạt động I: Nền Tảng - Một Quốc Gia Thức Tỉnh',
    description: 'From war-torn division to unified nation, establishing the foundation for transformation',
    emotionalTheme: 'resilience',
    milestones: ['reunification', 'stabilization', 'initial_growth'],
    slideRange: [1, 4],
    color: '#d4af37',
    icon: '🐉'
  },
  {
    id: 'act2_growth',
    title: 'Act II: Growth - The Dragon Emerges',
    vietnameseTitle: 'Hoạt động II: Tăng Trưởng - Rồng Vươn Mình',
    description: 'Economic liberalization, population transition, and rapid modernization reshape society',
    emotionalTheme: 'momentum',
    milestones: ['doi_moi', 'market_economy', 'urbanization'],
    slideRange: [5, 10],
    color: '#52b788',
    icon: '📈'
  },
  {
    id: 'act3_integration',
    title: 'Act III: Integration - Global Dragon',
    vietnameseTitle: 'Hoạt động III: Hội Nhập - Rồng Toàn Cầu',
    description: 'Global integration, technological advancement, and social modernization on the world stage',
    emotionalTheme: 'aspiration',
    milestones: ['wto_entry', 'tech_boom', 'sustainable_development'],
    slideRange: [11, 15],
    color: '#f72585',
    icon: '🌍'
  }
];

export const HISTORICAL_MILESTONES: MilestoneMarker[] = [
  {
    year: 1975,
    title: 'National Reunification',
    description: 'Vietnam officially reunified after 21 years of division',
    impact: 'Enabled national focus on economic and social development',
    slideIndex: 2,
    emotion: 'breakthrough'
  },
  {
    year: 1986,
    title: 'Doi Moi - Economic Reform',
    description: 'Transition from centrally planned to market-oriented economy begins',
    impact: 'Catalyzed decades of sustained growth, poverty reduction, and modernization',
    slideIndex: 5,
    emotion: 'transformation'
  },
  {
    year: 1995,
    title: 'ASEAN Membership',
    description: 'Vietnam joins Southeast Asian regional organization',
    impact: 'Accelerated regional integration and international cooperation',
    slideIndex: 6,
    emotion: 'consolidation'
  },
  {
    year: 2007,
    title: 'World Trade Organization Entry',
    description: 'Vietnam joins WTO, opening to global markets',
    impact: 'Tripled foreign direct investment flows, expanded manufacturing sector',
    slideIndex: 8,
    emotion: 'transformation'
  },
  {
    year: 2012,
    title: 'Middle Income Threshold',
    description: 'Vietnam officially classified as middle-income country',
    impact: 'Reflected decades of sustained development and poverty reduction',
    slideIndex: 10,
    emotion: 'consolidation'
  },
  {
    year: 2020,
    title: 'Digital Transformation Acceleration',
    description: 'COVID-19 pandemic accelerates digital economy adoption',
    impact: 'Tech sector boom, fintech innovation, e-commerce explosion',
    slideIndex: 12,
    emotion: 'breakthrough'
  }
];

export const NARRATIVE_INSIGHTS = {
  act1: {
    opening: 'In 1955, Vietnam began a remarkable seven-decade journey. From a war-torn nation emerging from colonial rule, it would transform into one of the world\'s fastest-growing economies.',
    challenges: 'The path was not smooth. Political division, wars, and isolation tested national resilience. Yet these challenges forged a determined spirit.',
    foundation: 'By 1986, a unified Vietnam stood ready. The population had doubled, basic literacy spread, and the stage was set for transformation.'
  },
  act2: {
    opening: 'Then came Doi Moi – "Renovation" – the economic reform that changed everything.',
    catalyst: 'Markets replaced central planning. Private enterprise was permitted. Foreign investment was welcomed. The dormant dragon began to stir.',
    growth: 'Over three decades, Vietnam achieved what took other nations a century. GDP multiplied by 200. Poverty dropped from 80% to under 5%. Cities transformed overnight.'
  },
  act3: {
    opening: 'Today, Vietnam stands on the global stage, no longer defined by war but by ambition.',
    achievement: 'A generation educated abroad returns with innovation. High-speed rail connects cities. Startups rival global competitors. Democracy of digital access empowers millions.',
    future: 'Yet challenges remain: climate vulnerability, aging population, inequality. The dragon\'s next chapter will be about sustainable, inclusive transformation.'
  }
};

export type TourMode = 'none' | 'student' | 'researcher' | 'policymaker' | 'general';

export const TOUR_CONFIGURATIONS: Record<TourMode, {
  title: string;
  focus: string[];
  annotations: boolean;
  dataDepth: 'basic' | 'intermediate' | 'advanced';
  pacing: 'fast' | 'medium' | 'slow';
}> = {
  none: {
    title: 'Self-Guided',
    focus: [],
    annotations: false,
    dataDepth: 'intermediate',
    pacing: 'medium'
  },
  student: {
    title: 'Student Learning Path',
    focus: ['historical_context', 'demographic_transitions', 'education_outcomes', 'key_milestones'],
    annotations: true,
    dataDepth: 'intermediate',
    pacing: 'slow'
  },
  researcher: {
    title: 'Research Deep Dive',
    focus: ['methodologies', 'data_sources', 'statistical_trends', 'comparative_analysis'],
    annotations: true,
    dataDepth: 'advanced',
    pacing: 'medium'
  },
  policymaker: {
    title: 'Policy Insights Track',
    focus: ['economic_policy_impacts', 'social_outcomes', 'governance_indicators', 'future_scenarios'],
    annotations: true,
    dataDepth: 'advanced',
    pacing: 'fast'
  },
  general: {
    title: 'Story & Impact',
    focus: ['key_achievements', 'human_impact', 'emotional_moments', 'future_vision'],
    annotations: false,
    dataDepth: 'basic',
    pacing: 'medium'
  }
};
