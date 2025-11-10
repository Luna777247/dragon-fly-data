# Implementation Guide: Advanced Enhancement Features

This guide explains how to integrate the newly added enhancement components into the existing presentation.

---

## Quick Start

### 1. Enable Service Worker

Add to `src/main.tsx`:
```typescript
import { useServiceWorker } from '@/hooks/useServiceWorker';

function App() {
  useServiceWorker(); // Registers SW on mount
  // ... rest of app
}
```

### 2. Add Supabase Integration

Ensure environment variables are set:
```env
VITE_SUPABASE_URL=your_url
VITE_SUPABASE_ANON_KEY=your_key
```

Then import services:
```typescript
import { bookmarkService, sessionService, sharingService } from '@/services/supabaseClient';
```

### 3. Update Main Index Component

```typescript
import { GuidedTourSystem } from '@/components/GuidedTourSystem';
import { PresentationSearch } from '@/components/PresentationSearch';
import { DualViewComparison } from '@/components/DualViewComparison';
import { NarrativeMilestoneMarker } from '@/components/NarrativeMilestoneMarker';
import { HISTORICAL_MILESTONES } from '@/constants/narrativeStructure';

export const Index = () => {
  const [showSearch, setShowSearch] = useState(false);
  const [showComparison, setShowComparison] = useState(false);
  const [currentSlide, setCurrentSlide] = useState(0);

  useEffect(() => {
    // Keyboard shortcut for search
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
        e.preventDefault();
        setShowSearch(true);
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, []);

  // Find relevant milestone for current slide
  const currentMilestone = HISTORICAL_MILESTONES.find(
    m => m.slideIndex === currentSlide
  );

  return (
    <>
      {/* Existing components */}

      {/* Add new components */}
      <GuidedTourSystem
        currentSlide={currentSlide}
        totalSlides={slidesConfig.length}
        onTourModeChange={(mode) => {
          // Store mode in preferences
          preferenceService.updatePreferences({ tour_mode: mode });
        }}
        onNavigate={(slideIndex) => goToSlide(slideIndex)}
      />

      <PresentationSearch
        isOpen={showSearch}
        onClose={() => setShowSearch(false)}
        onNavigate={(slideIndex) => goToSlide(slideIndex)}
      />

      <DualViewComparison
        isOpen={showComparison}
        onClose={() => setShowComparison(false)}
      />

      <NarrativeMilestoneMarker
        milestone={currentMilestone}
        isVisible={!!currentMilestone}
      />
    </>
  );
};
```

---

## Component Integration Details

### SlideChapterIntro Component

Use before starting each chapter section:

```typescript
import { SlideChapterIntro } from '@/components/slides/SlideChapterIntro';
import { NARRATIVE_CHAPTERS } from '@/constants/narrativeStructure';

// Show as slide 0, then slide 1 starts first real content
<SlideChapterIntro
  chapter={NARRATIVE_CHAPTERS[0]}
  onContinue={() => goToSlide(1)}
/>
```

**Placement**: Between sections in presentation flow
**Timing**: Before 3-4 major content groups

### ContentLayers Component

Add to existing slides for additional depth:

```typescript
import { ContentLayers, ContentLayer } from '@/components/ContentLayers';

const contentLayers: ContentLayer[] = [
  {
    id: 'population-story',
    type: 'human_story',
    title: 'A Growing Family',
    content: 'Vietnam\'s population grew from 40 million to 98 million - each person with their own story of change, challenge, and opportunity.',
    icon: <Users />,
    metadata: { growth: '2.45x', period: '70 years' }
  },
  {
    id: 'gdp-policy',
    type: 'policy_context',
    title: 'Doi Moi Economic Reforms',
    content: 'The 1986 Doi Moi reforms transitioned Vietnam from centrally planned to market-oriented economy, unleashing entrepreneurial spirit.',
    icon: <TrendingUp />,
    metadata: { year: 1986, gdp_acceleration: '9.5% avg' }
  }
];

<ContentLayers layers={contentLayers} defaultExpanded={false} />
```

**Usage**: Insert after main chart on relevant slides
**Configuration**: Customize for each slide's context

### EmotionalMoments Component

Highlight key achievements:

```typescript
import { EmotionalMoments } from '@/components/EmotionalMoments';

<EmotionalMoments
  currentYear={selectedYear}
  onShare={(moment) => {
    // Track share in analytics
    interactionService.trackInteraction('slide_id', 'share', 0, {
      shared_moment: moment.id
    });
  }}
/>
```

**Usage**: Add to Dashboard and Data Explorer slides
**Behavior**: Shows relevant moments based on selected year

### DualViewComparison Component

Add comparison button to slide headers:

```typescript
const [showComparison, setShowComparison] = useState(false);

<Button
  variant="ghost"
  onClick={() => setShowComparison(true)}
  className="gap-2"
>
  <ArrowsLeftRight className="w-4 h-4" />
  Compare Periods
</Button>

<DualViewComparison
  isOpen={showComparison}
  onClose={() => setShowComparison(false)}
  defaultYear1={1955}
  defaultYear2={2024}
/>
```

---

## Database Usage Examples

### Track User Session

```typescript
import { sessionService } from '@/services/supabaseClient';

// On app start
const session = await sessionService.startSession(
  'desktop', // or 'tablet', 'mobile'
  'direct'   // or 'referral', 'social', etc.
);

// Update as user navigates
sessionService.updateSession(
  session.id,
  currentSlide,
  totalSlidesViewed
);

// On app exit
sessionService.endSession(session.id);
```

### Save Bookmarks

```typescript
import { bookmarkService } from '@/services/supabaseClient';

// Save a slide
await bookmarkService.addBookmark(
  'slide-0',
  'slide',
  'Great intro to Vietnam\'s journey',
  { country: 'Vietnam', focus: 'development' }
);

// Get user's bookmarks
const bookmarks = await bookmarkService.getBookmarks();

// Remove bookmark
await bookmarkService.removeBookmark(bookmarkId);
```

### Track Interactions

```typescript
import { interactionService } from '@/services/supabaseClient';

// Track when user exports data
await interactionService.trackInteraction(
  'slide-dashboard',
  'export',
  45, // seconds spent
  { format: 'csv', metrics: ['population', 'gdp'] }
);

// Get interaction stats
const stats = await interactionService.getInteractionStats('slide-dashboard');
```

### Create Shareable Links

```typescript
import { sharingService } from '@/services/supabaseClient';

// Create share
const share = await sharingService.createShare(
  'slide-5',
  { selectedYear: 2024, metric: 'gdp' }
);

// Share token is: share.share_token
// Full URL: window.location.origin + `?share=${share.share_token}`

// Retrieve shared insight
const insight = await sharingService.getSharedInsight(shareToken);
// Note: view_count auto-increments
```

---

## Keyboard Shortcuts

Add these to your navigation:

```typescript
useEffect(() => {
  const handleKeyDown = (e: KeyboardEvent) => {
    // Search: Cmd/Ctrl+K
    if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
      e.preventDefault();
      setShowSearch(true);
    }

    // Compare: Cmd/Ctrl+Shift+C
    if ((e.ctrlKey || e.metaKey) && e.shiftKey && e.key === 'C') {
      e.preventDefault();
      setShowComparison(true);
    }

    // Share: Cmd/Ctrl+Shift+S
    if ((e.ctrlKey || e.metaKey) && e.shiftKey && e.key === 'S') {
      e.preventDefault();
      handleShare();
    }
  };

  window.addEventListener('keydown', handleKeyDown);
  return () => window.removeEventListener('keydown', handleKeyDown);
}, []);
```

---

## Styling & Theming

All components use existing Tailwind classes and CSS variables:

```css
/* Dragon Gold Primary */
color: hsl(var(--primary));

/* Secondary Green */
color: hsl(var(--secondary));

/* Accent Red/Pink */
color: hsl(var(--accent));

/* Animations from tailwind config */
@apply animate-fade-in
```

No additional styling imports needed - components integrate seamlessly.

---

## Mobile Responsiveness

Components automatically adapt to screen size:

```typescript
// Mobile-first approach
// Components use:
- min-h-10 for touch targets (44px minimum)
- Responsive grid layouts (1 col mobile → 2+ col desktop)
- Flexible modals that scale to viewport
- Touch-friendly spacing
```

Test on:
- iPhone (375px)
- iPad (768px)
- Desktop (1024px+)

---

## Performance Considerations

### Code Splitting
Each slide component is lazy-loaded separately. New components don't add to main bundle if not used.

### Database Query Optimization
```typescript
// These are indexed for performance:
- user_sessions(user_id)
- bookmarks(user_id, slide_id)
- slide_interactions(user_id, slide_id)
- shared_insights(share_token)
```

### Caching Strategy
```typescript
// Service Worker caches:
- JS chunks (2-10KB each)
- CSS (82KB)
- Images and fonts
- CSV data

// Cache busts automatically on new deployment
```

---

## Testing Checklist

- [ ] Service Worker registers in console
- [ ] Offline mode works (DevTools Network → Offline)
- [ ] Supabase tables created and accessible
- [ ] Search finds slides and years
- [ ] Tours complete without errors
- [ ] Bookmarks save and load
- [ ] Dual comparison loads both periods
- [ ] Emotional moments display correctly
- [ ] Mobile layout responsive
- [ ] Keyboard shortcuts work
- [ ] Sharing creates valid tokens

---

## Troubleshooting

### Service Worker Not Registering
- Check if PROD build: SW only works in production
- Clear cache: DevTools → Application → Clear Storage
- Check browser console for errors

### Supabase Errors
- Verify environment variables are set
- Check Row Level Security policies
- Look for auth errors in browser console
- Check Supabase dashboard for quota issues

### Search Not Finding Results
- Ensure slide titles match search terms
- Check that years are in vietnamData
- Clear browser cache if slides updated

### Comparison Shows No Data
- Verify year exists in vietnamData
- Check that year range is valid (1955-2024)
- Test with default years first

---

## Additional Resources

- **Supabase Docs**: https://supabase.com/docs
- **Service Workers**: https://web.dev/service-workers/
- **React Hooks**: https://react.dev/reference/react
- **GSAP Animations**: https://gsap.com/docs/

---

## Support & Maintenance

### Feature Requests
Add to Phase 2/3 in ENHANCEMENTS.md

### Bug Reports
Include:
- Browser and OS
- Steps to reproduce
- Expected vs actual behavior
- Console errors

### Performance Issues
Check:
- Network tab (waterfall chart)
- Performance tab (Web Vitals)
- Lighthouse score
- Database query times

---

