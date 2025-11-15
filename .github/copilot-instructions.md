# Vietnam Data Story - AI Agent Instructions

## Project Overview
Interactive data visualization of Vietnam's 70-year development (1955-2025) built with React/TypeScript/Vite. Combines 72 socioeconomic indicators into an animated slide presentation with GSAP animations and Recharts visualizations.

## Critical Architecture Decisions

### Data Flow (Single Source of Truth)
```
rawdataset/*.ps1 → wb_*.json → vietnam_advance.csv → vietnamData.ts → slides
```

**Never** create alternative CSVs or duplicate data pipelines. The CSV is loaded once at build time via Vite's `?raw` import:
```typescript
import csvRawData from './vietnam_advance.csv?raw';  // Static import
export const vietnamData = parseCSVToData(csvRawData); // Parsed once, cached
```

### Lazy Loading Architecture (15 Slides)
All slides are code-split using React.lazy() in `src/config/slidesConfig.ts`. New slides MUST follow this pattern:
```typescript
const lazySlides = {
  SlideNewFeature: lazy(() => 
    import('@/components/slides/SlideNewFeature').then(m => ({ default: m.SlideNewFeature }))
  ),
};
```

Then register in `slidesConfig` array. The `Index.tsx` controller wraps slides in `<LazySlide>` (Suspense boundary with skeleton loader).

### GSAP Animation Cleanup Pattern
**Critical for memory leaks:** All slides MUST use `gsap.context()` with proper cleanup:
```typescript
useEffect(() => {
  if (!containerRef.current) return;
  
  const ctx = gsap.context(() => {
    gsap.from('.element', {
      scrollTrigger: { trigger: containerRef.current, start: 'top center' },
      opacity: 0, y: 50, duration: 1
    });
  }, containerRef);
  
  return () => ctx.revert();  // Required: kills all ScrollTriggers
}, []);
```

## Development Workflows

### Running Commands (PowerShell 5.1)
```powershell
npm run dev              # Dev server → localhost:8080
npm run build            # Production build
cd rawdataset; .\validate_ranges.ps1  # Pre-commit data validation
```

### Data Pipeline Updates
When adding new indicators (e.g., "internet penetration"):
1. **Fetch**: `rawdataset/download_internet.ps1` → creates `wb_internet.json`
2. **Integrate**: `integrate_internet.ps1` reads JSON, updates CSV columns
3. **Validate**: `validate_ranges.ps1` checks new column against defined ranges
4. **Type**: Add `internetPenetration: number;` to `VietnamDataPoint` interface
5. **Zod**: Add `internetPenetration: z.number().min(0).max(100)` to validation schema

**Example validation rule** (from `validate_ranges.ps1`):
```powershell
$validationRules = @{
    "Urban Pop %" = @{Min=0; Max=100; Type="Percentage"}
    "HDI" = @{Min=0; Max=1; Type="Index"}
}
```

### PowerShell Script Patterns
- **Download scripts** use `Invoke-RestMethod` with World Bank API v2
- **Integration scripts** use lookup tables: `$lookup[$year] = $value`
- All scripts output colored status (`-ForegroundColor Green/Red/Yellow`)
- JSON files in `rawdataset/` are intermediaries, not source of truth

## Project-Specific Conventions

### Type Safety (Strict Mode Enabled)
- CSV parsing in `dataUtils.ts` validates 72-column structure
- Runtime validation via Zod schemas (`dataValidation.ts`)
- Missing values become `NaN` → render as "N/A" in UI

### Slide Component Anatomy
```typescript
export const SlideExample = () => {
  const containerRef = useRef<HTMLDivElement>(null);  // For GSAP context
  const data = vietnamData;  // Pre-parsed, cached data
  
  // Memoize expensive computations
  const chartData = useMemo(() => 
    data.map(d => ({ year: d.year, gdp: d.gdpBillion })), 
    []  // Empty deps: data never changes
  );

  useEffect(() => {
    const ctx = gsap.context(() => {
      gsap.from('.animated-element', {
        scrollTrigger: { trigger: containerRef.current, start: 'top center' },
        opacity: 0, duration: 0.8
      });
    }, containerRef);
    return () => ctx.revert();
  }, []);

  return <div ref={containerRef} className="min-h-screen">{/* JSX */}</div>;
};
```

**Animation class naming**: Use descriptive prefixes (`.dash-chart`, `.regional-title`, `.future-card`) to avoid GSAP conflicts.

### Chart Standards
- Use `recharts` (LineChart, BarChart, AreaChart, RadarChart)
- Always provide `ResponsiveContainer` wrapper
- Use `CustomTooltip` from `@/components/ui/custom-tooltip` for consistency
- Vietnamese labels: "Năm", "Dân số (triệu)", "GDP (tỷ USD)"

## Integration Points

### Lovable.dev Sync
- Any `git push` triggers automatic deployment to Lovable
- Component tagger plugin (`lovable-tagger`) only runs in dev mode
- Project URL: https://lovable.dev/projects/9611ccb1-0eb0-47ca-b90a-c3d7cc51ef29

### Supabase (Optional)
Check `import.meta.env.VITE_SUPABASE_URL` before using services. Features degrade gracefully if undefined. Services in `src/services/supabaseClient.ts`:
- `sessionService`: Track slide views, durations
- `bookmarkService`: User-saved slides
- `sharingService`: Share presentations via tokens

### Path Alias
`@/` → `src/` (configured in `vite.config.ts` and `tsconfig.json`)

## Common Tasks

### Adding New Slide
1. Create `src/components/slides/SlideFeatureName.tsx` using template above
2. Add lazy import to `slidesConfig.ts`:
   ```typescript
   SlideFeatureName: lazy(() => import('@/components/slides/SlideFeatureName').then(m => ({ default: m.SlideFeatureName }))),
   ```
3. Add to `slidesConfig` array: `{ component: lazySlides.SlideFeatureName, title: 'Vietnamese Title' }`
4. Rebuild to verify code splitting: `npm run build` (check `dist/assets/` for separate chunk)

### Debugging Data Parsing Issues
```powershell
# Check CSV column count
(Import-Csv "src\data\vietnam_advance.csv")[0].PSObject.Properties.Count  # Should be 72

# Validate ranges
cd rawdataset; .\validate_ranges.ps1

# Browser console will show:
# "Skipping row 45: insufficient columns" → CSV structure broken
# "Invalid value for fertilityRate at row 12" → Out-of-range value
```

### Performance Checks
- Initial bundle target: <500KB (current: ~430KB gzipped)
- Each slide chunk: 2-10KB
- Vite build generates report: `npm run build` → check sizes in output

## Anti-Patterns to Avoid

❌ **Don't** import slides directly in `Index.tsx` (breaks code splitting):
```typescript
import { SlideDashboard } from '@/components/slides/SlideDashboard';  // BAD
```

❌ **Don't** parse CSV multiple times (use cached `vietnamData`):
```typescript
const data = parseCSVToData(csvRawData);  // BAD: re-parses 71 rows
const data = vietnamData;  // GOOD: uses cached parse
```

❌ **Don't** use inline GSAP animations without `gsap.context()`:
```typescript
gsap.from('.element', { opacity: 0 });  // BAD: orphaned ScrollTrigger
```

❌ **Don't** modify CSV manually. Use PowerShell integration scripts.

❌ **Don't** add dependencies to GSAP animation `useEffect` deps arrays unless absolutely necessary (causes re-registration).

## Documentation Map
- `rawdataset/DATA_QUALITY_FINAL_REPORT.md`: Data validation audit (79 fixes, 100% valid)
- `IMPROVEMENTS.md`: Code quality enhancements (lazy loading, type safety)
- `ENHANCEMENTS.md`: Visual design & narrative structure decisions
- `package.json` scripts: Standard Vite commands + custom build modes

## Quick Reference Commands
```powershell
npm run dev                              # Start dev server
npm run build                            # Production build
npm run build:dev                        # Dev mode build
cd rawdataset; .\validate_ranges.ps1    # Validate CSV
Get-Content src\data\vietnam_advance.csv | Measure-Object -Line  # Count rows (should be 72 headers + 71 data)
```
