import { useState, useEffect } from 'react';
import { BookOpen, Users, Briefcase, Target, X, ChevronRight } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { TourMode, TOUR_CONFIGURATIONS } from '@/constants/narrativeStructure';

interface TourStep {
  slideIndex: number;
  title: string;
  description: string;
  tips: string[];
  focusAreas: string[];
}

interface GuidedTourSystemProps {
  currentSlide: number;
  totalSlides: number;
  onTourModeChange: (mode: TourMode) => void;
  onNavigate: (slideIndex: number) => void;
}

const TOUR_PATHS: Record<TourMode, TourStep[]> = {
  none: [],
  student: [
    {
      slideIndex: 1,
      title: 'Dashboard Overview',
      description: 'Start here to understand key metrics and how Vietnam has changed',
      tips: ['Notice the overall trends', 'Compare multiple metrics', 'Use filters to focus on specific areas'],
      focusAreas: ['population', 'gdp', 'urbanization']
    },
    {
      slideIndex: 2,
      title: 'Population & Demographics',
      description: 'Learn how Vietnam\'s population structure evolved over 70 years',
      tips: ['Compare birth rates then vs now', 'Understand aging population challenges', 'See urbanization impact'],
      focusAreas: ['birth_rates', 'median_age', 'urbanization']
    },
    {
      slideIndex: 5,
      title: 'Economic Development',
      description: 'Discover how economic reforms transformed Vietnam\'s economy',
      tips: ['Identify the Doi Moi impact', 'See GDP growth acceleration', 'Understand employment shifts'],
      focusAreas: ['economic_growth', 'sectors', 'employment']
    },
    {
      slideIndex: 9,
      title: 'Trade & Global Integration',
      description: 'Explore Vietnam\'s transformation into a global trading partner',
      tips: ['Notice WTO entry impact', 'See trade volume growth', 'Compare with ASEAN neighbors'],
      focusAreas: ['trade_volumes', 'exports', 'global_rank']
    },
    {
      slideIndex: 11,
      title: 'Data Explorer',
      description: 'Deep dive into interactive analysis tools',
      tips: ['Use multiple tabs for different perspectives', 'Compare different time periods', 'Export insights you find interesting'],
      focusAreas: ['data_analysis', 'comparisons', 'trends']
    }
  ],
  researcher: [
    {
      slideIndex: 0,
      title: 'Data Foundation',
      description: 'Understand the data sources and methodologies',
      tips: ['Note the data quality indicators', 'Check time coverage', 'Identify data gaps'],
      focusAreas: ['data_sources', 'methodologies', 'coverage']
    },
    {
      slideIndex: 3,
      title: 'Demographic Transitions',
      description: 'Analyze demographic shift patterns and projections',
      tips: ['Study the demographic transition model', 'Note dependency ratio changes', 'Consider regional variations'],
      focusAreas: ['demographic_transition', 'fertility', 'aging']
    },
    {
      slideIndex: 6,
      title: 'Statistical Trends',
      description: 'Examine statistical patterns and correlations',
      tips: ['Look for inflection points', 'Consider causality vs correlation', 'Note anomalies and outliers'],
      focusAreas: ['trends', 'correlations', 'anomalies']
    },
    {
      slideIndex: 10,
      title: 'Comparative Analysis',
      description: 'Compare Vietnam with other nations in the region',
      tips: ['Use the comparison tools', 'Note regional differences', 'Contextualize within ASEAN'],
      focusAreas: ['regional_comparison', 'benchmarking', 'context']
    },
    {
      slideIndex: 11,
      title: 'Advanced Analytics',
      description: 'Use interactive tools for deeper investigation',
      tips: ['Export data for analysis', 'Create custom comparisons', 'Test hypotheses'],
      focusAreas: ['advanced_analytics', 'exports', 'customization']
    }
  ],
  policymaker: [
    {
      slideIndex: 1,
      title: 'Key Indicators Dashboard',
      description: 'Overview of critical policy metrics',
      tips: ['Focus on trend direction', 'Note recent momentum', 'Consider policy implications'],
      focusAreas: ['policy_metrics', 'trends', 'forecasts']
    },
    {
      slideIndex: 5,
      title: 'Policy Impacts: Economic Reforms',
      description: 'See the effects of major policy decisions like Doi Moi',
      tips: ['Identify policy inflection points', 'Measure policy effectiveness', 'Note unintended consequences'],
      focusAreas: ['policy_reforms', 'impacts', 'outcomes']
    },
    {
      slideIndex: 7,
      title: 'Social Outcomes',
      description: 'Evaluate progress on human development indices',
      tips: ['Check health and education gains', 'Monitor inequality measures', 'Consider sustainability'],
      focusAreas: ['social_outcomes', 'hdi', 'equity']
    },
    {
      slideIndex: 12,
      title: 'Future Scenarios',
      description: 'Explore policy options and future trajectories',
      tips: ['Consider different scenarios', 'Assess feasibility', 'Plan interventions strategically'],
      focusAreas: ['future_scenarios', 'policy_options', 'risk_mitigation']
    }
  ],
  general: [
    {
      slideIndex: 0,
      title: 'The Dragon Awakens',
      description: 'Vietnam\'s remarkable 70-year transformation story',
      tips: ['Notice the dramatic scale of change', 'Feel the momentum of progress', 'Connect with the human impact'],
      focusAreas: ['story', 'achievement', 'inspiration']
    },
    {
      slideIndex: 2,
      title: 'A Growing Nation',
      description: 'How Vietnam\'s population and cities transformed',
      tips: ['Visualize the population growth', 'See rapid urbanization', 'Understand the pace of change'],
      focusAreas: ['population_growth', 'urbanization', 'human_impact']
    },
    {
      slideIndex: 5,
      title: 'Economic Boom',
      description: 'From poverty to middle income: An economic miracle',
      tips: ['Appreciate the GDP transformation', 'See jobs created', 'Understand prosperity spread'],
      focusAreas: ['economic_growth', 'prosperity', 'job_creation']
    },
    {
      slideIndex: 9,
      title: 'Global Stage',
      description: 'Vietnam becomes a major player in world trade',
      tips: ['Marvel at trade growth', 'See exports everywhere', 'Recognize global influence'],
      focusAreas: ['global_reach', 'trade_success', 'influence']
    },
    {
      slideIndex: 14,
      title: 'The Future',
      description: 'What\'s next for the rising dragon?',
      tips: ['Consider the challenges ahead', 'Envision sustainable growth', 'Inspire optimism'],
      focusAreas: ['future_vision', 'opportunities', 'challenges']
    }
  ]
};

interface TourOverlayProps {
  step: TourStep;
  isComplete: boolean;
  onNext: () => void;
  onSkip: () => void;
  tourMode: TourMode;
  stepNumber: number;
  totalSteps: number;
}

const TourOverlay = ({ step, isComplete, onNext, onSkip, tourMode, stepNumber, totalSteps }: TourOverlayProps) => {
  const config = TOUR_CONFIGURATIONS[tourMode];

  return (
    <div className="fixed bottom-32 right-6 z-40 max-w-xs bg-card border-2 border-primary rounded-xl p-4 shadow-2xl animate-fade-in">
      <div className="flex justify-between items-start mb-3">
        <div className="flex-1">
          <div className="text-xs font-bold text-primary mb-1">GUIDED TOUR: {config.title}</div>
          <h3 className="font-bold text-foreground">{step.title}</h3>
        </div>
        <Button variant="ghost" size="sm" onClick={onSkip} className="w-6 h-6 p-0 -mt-2 -mr-2">
          <X className="w-4 h-4" />
        </Button>
      </div>

      <p className="text-sm text-muted-foreground mb-4">{step.description}</p>

      {step.tips.length > 0 && (
        <div className="mb-4 space-y-1">
          <div className="text-xs font-semibold text-primary mb-2">Tips for this section:</div>
          <ul className="text-xs text-muted-foreground space-y-1">
            {step.tips.map((tip, i) => (
              <li key={i}>• {tip}</li>
            ))}
          </ul>
        </div>
      )}

      <div className="flex items-center justify-between gap-2 pt-3 border-t border-border">
        <div className="text-xs text-muted-foreground">
          Step {stepNumber + 1} of {totalSteps}
        </div>
        <div className="flex gap-2">
          <Button variant="outline" size="sm" onClick={onSkip}>
            Skip Tour
          </Button>
          <Button
            size="sm"
            onClick={onNext}
            className="gap-1"
          >
            {isComplete ? 'Complete' : 'Next'} <ChevronRight className="w-3 h-3" />
          </Button>
        </div>
      </div>
    </div>
  );
};

export const GuidedTourSystem = ({
  currentSlide,
  totalSlides,
  onTourModeChange,
  onNavigate
}: GuidedTourSystemProps) => {
  const [tourMode, setTourMode] = useState<TourMode>('none');
  const [currentStepIndex, setCurrentStepIndex] = useState(0);

  const tourSteps = TOUR_PATHS[tourMode];
  const isActive = tourMode !== 'none' && tourSteps.length > 0;
  const currentStep = tourSteps[currentStepIndex];
  const isOnCorrectSlide = currentStep && currentSlide === currentStep.slideIndex;

  useEffect(() => {
    if (isActive && currentStep && currentSlide === currentStep.slideIndex) {
      // Automatically move to next step when arriving at the correct slide
      const timer = setTimeout(() => {
        // User has time to read before moving on
      }, 500);
      return () => clearTimeout(timer);
    }
  }, [currentSlide, isActive, currentStep]);

  const handleTourModeSelect = (mode: TourMode) => {
    setTourMode(mode);
    setCurrentStepIndex(0);
    onTourModeChange(mode);
    if (mode !== 'none' && TOUR_PATHS[mode].length > 0) {
      onNavigate(TOUR_PATHS[mode][0].slideIndex);
    }
  };

  const handleNextStep = () => {
    if (currentStepIndex < tourSteps.length - 1) {
      const nextStep = tourSteps[currentStepIndex + 1];
      setCurrentStepIndex(currentStepIndex + 1);
      onNavigate(nextStep.slideIndex);
    } else {
      setTourMode('none');
      setCurrentStepIndex(0);
    }
  };

  const handleSkipTour = () => {
    setTourMode('none');
    setCurrentStepIndex(0);
  };

  return (
    <>
      {/* Tour Mode Selector - Only show when not in a tour */}
      {tourMode === 'none' && (
        <div className="fixed bottom-6 left-6 z-40 space-y-2 bg-card/95 backdrop-blur-sm border border-border rounded-lg p-3 shadow-lg">
          <div className="text-xs font-semibold text-muted-foreground">Choose your journey:</div>
          <div className="space-y-1">
            {(['student', 'researcher', 'policymaker', 'general'] as const).map((mode) => (
              <Button
                key={mode}
                variant="ghost"
                size="sm"
                className="w-full justify-start text-xs gap-2"
                onClick={() => handleTourModeSelect(mode)}
              >
                {mode === 'student' && <BookOpen className="w-4 h-4" />}
                {mode === 'researcher' && <Target className="w-4 h-4" />}
                {mode === 'policymaker' && <Briefcase className="w-4 h-4" />}
                {mode === 'general' && <Users className="w-4 h-4" />}
                {TOUR_CONFIGURATIONS[mode].title}
              </Button>
            ))}
          </div>
        </div>
      )}

      {/* Active Tour Overlay */}
      {isActive && currentStep && (
        <TourOverlay
          step={currentStep}
          isComplete={currentStepIndex === tourSteps.length - 1}
          onNext={handleNextStep}
          onSkip={handleSkipTour}
          tourMode={tourMode}
          stepNumber={currentStepIndex}
          totalSteps={tourSteps.length}
        />
      )}
    </>
  );
};
