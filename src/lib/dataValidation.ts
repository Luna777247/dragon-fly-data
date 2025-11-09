import { z } from 'zod';
import type { VietnamDataPoint, AppError } from './types';

const VietnamDataPointSchema = z.object({
  year: z.number().int().min(1950).max(2100),
  population: z.number().nonnegative(),
  yearlyChangePercent: z.number(),
  yearlyChange: z.number(),
  migrantsNet: z.number(),
  medianAge: z.number().nonnegative(),
  fertilityRate: z.number().nonnegative(),
  densityPerKm2: z.number().nonnegative(),
  urbanPopPercent: z.number().min(0).max(100),
  urbanPopulation: z.number().nonnegative(),
  countryShareOfWorldPop: z.number().nonnegative(),
  worldPopulation: z.number().nonnegative(),
  vietnamGlobalRank: z.number().int().nonnegative(),
  gdpBillion: z.number().nonnegative(),
  gdpPerCapita: z.number().nonnegative(),
  gdpGrowthRate: z.number(),
  gniPerCapita: z.number().nonnegative(),
  unemploymentRate: z.number().min(0).max(100),
  povertyRate: z.number().min(0).max(100),
  hdi: z.number().min(0).max(1),
  educationIndex: z.number().min(0).max(1),
  lifeExpectancy: z.number().nonnegative(),
  healthExpenditurePercent: z.number().nonnegative(),
  literacyRate: z.number().min(0).max(100),
  employmentAgriculture: z.number().nonnegative(),
  employmentIndustry: z.number().nonnegative(),
  employmentServices: z.number().nonnegative(),
  ruralPopulation: z.number().nonnegative(),
  urbanGrowthRate: z.number(),
  householdSize: z.number().nonnegative(),
  housingUnits: z.number().nonnegative(),
  migrationRate: z.number(),
  landArea: z.number().nonnegative(),
  forestAreaPercent: z.number().min(0).max(100),
  co2PerCapita: z.number().nonnegative(),
  energyConsumptionPerCapita: z.number().nonnegative(),
  agriculturalLandPercent: z.number().min(0).max(100),
  climateRiskIndex: z.number().nonnegative(),
  birthRate: z.number().nonnegative(),
  deathRate: z.number().nonnegative(),
  infantMortalityRate: z.number().nonnegative(),
  dependencyRatio: z.number().nonnegative(),
  popAged0to14: z.number().nonnegative(),
  popAged15to64: z.number().nonnegative(),
  popAged65Plus: z.number().nonnegative(),
  sexRatio: z.number().nonnegative(),
  densityDBSH: z.number().nonnegative(),
  densityDBSCL: z.number().nonnegative(),
  densityMienTrung: z.number().nonnegative(),
  densityMienNui: z.number().nonnegative(),
  vietnamShareOfAsianPop: z.number().nonnegative(),
  aseanPopulationRank: z.number().int().nonnegative(),
  regionalAvgFertilityRate: z.number().nonnegative(),
  regionalMedianAge: z.number().nonnegative(),
  globalMedianAge: z.number().nonnegative(),
  worldUrbanizationRate: z.number().min(0).max(100),
  populationGrowthAbsolute: z.number(),
  populationDoublingTime: z.number().nonnegative(),
  netMigrationRate: z.number(),
  urbanizationRatio: z.number().nonnegative(),
  dependencyIndex: z.number().nonnegative(),
  populationShareChange: z.number(),
  inflationRate: z.number(),
  gdpPPPPerCapita: z.number().nonnegative(),
  fdiNetInflows: z.number(),
  exportsPercent: z.number(),
  importsPercent: z.number(),
  meanYearsOfSchooling: z.number().nonnegative(),
  expectedYearsOfSchooling: z.number().nonnegative(),
  humanCapitalIndex: z.number().nonnegative(),
  renewableEnergyShare: z.number().min(0).max(100),
  epiScore: z.number().nonnegative(),
});

export function validateVietnamData(data: unknown): data is VietnamDataPoint {
  try {
    VietnamDataPointSchema.parse(data);
    return true;
  } catch {
    return false;
  }
}

export function validateAndParseVietnamData(dataArray: unknown[]): VietnamDataPoint[] {
  return dataArray.filter((item) => validateVietnamData(item)) as VietnamDataPoint[];
}

export function createError(code: string, message: string, details?: Record<string, unknown>): AppError {
  return {
    code,
    message,
    details,
  };
}

export function handleError(error: unknown): AppError {
  if (error instanceof Error) {
    return createError('ERROR', error.message);
  }

  if (typeof error === 'string') {
    return createError('ERROR', error);
  }

  return createError('UNKNOWN_ERROR', 'An unknown error occurred');
}
