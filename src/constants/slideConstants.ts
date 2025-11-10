export const MILESTONE_YEARS = [1955, 1960, 1965, 1970, 1975, 1980, 1985, 1990, 1995, 2000, 2005, 2010, 2015, 2020, 2025];

export const KEY_YEARS = [1955, 1965, 1975, 1985, 1995, 2005, 2015, 2024];

export const ANIMATION_DURATION = {
  short: 0.6,
  medium: 0.8,
  long: 1,
  veryLong: 1.5,
} as const;

export const ANIMATION_DELAY = {
  minimal: 0.05,
  small: 0.1,
  medium: 0.15,
  large: 0.2,
} as const;

export const CHART_COLORS = {
  primary: 'hsl(var(--primary))',
  secondary: 'hsl(var(--secondary))',
  accent: 'hsl(var(--accent))',
  destructive: 'hsl(var(--destructive))',
  muted: 'hsl(var(--muted-foreground))',
} as const;

export const GRID_LAYOUT = {
  xs: 1,
  md: 2,
  lg: 3,
  xl: 4,
} as const;
