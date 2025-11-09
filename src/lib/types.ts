export interface VietnamDataPoint {
  year: number;
  population: number;
  yearlyChangePercent: number;
  yearlyChange: number;
  migrantsNet: number;
  medianAge: number;
  fertilityRate: number;
  densityPerKm2: number;
  urbanPopPercent: number;
  urbanPopulation: number;
  countryShareOfWorldPop: number;
  worldPopulation: number;
  vietnamGlobalRank: number;
  gdpBillion: number;
  gdpPerCapita: number;
  gdpGrowthRate: number;
  gniPerCapita: number;
  unemploymentRate: number;
  povertyRate: number;
  hdi: number;
  educationIndex: number;
  lifeExpectancy: number;
  healthExpenditurePercent: number;
  literacyRate: number;
  employmentAgriculture: number;
  employmentIndustry: number;
  employmentServices: number;
  ruralPopulation: number;
  urbanGrowthRate: number;
  householdSize: number;
  housingUnits: number;
  migrationRate: number;
  landArea: number;
  forestAreaPercent: number;
  co2PerCapita: number;
  energyConsumptionPerCapita: number;
  agriculturalLandPercent: number;
  climateRiskIndex: number;
  birthRate: number;
  deathRate: number;
  infantMortalityRate: number;
  dependencyRatio: number;
  popAged0to14: number;
  popAged15to64: number;
  popAged65Plus: number;
  sexRatio: number;
  densityDBSH: number;
  densityDBSCL: number;
  densityMienTrung: number;
  densityMienNui: number;
  vietnamShareOfAsianPop: number;
  aseanPopulationRank: number;
  regionalAvgFertilityRate: number;
  regionalMedianAge: number;
  globalMedianAge: number;
  worldUrbanizationRate: number;
  populationGrowthAbsolute: number;
  populationDoublingTime: number;
  netMigrationRate: number;
  urbanizationRatio: number;
  dependencyIndex: number;
  populationShareChange: number;
  inflationRate: number;
  gdpPPPPerCapita: number;
  fdiNetInflows: number;
  exportsPercent: number;
  importsPercent: number;
  meanYearsOfSchooling: number;
  expectedYearsOfSchooling: number;
  humanCapitalIndex: number;
  renewableEnergyShare: number;
  epiScore: number;
}

export interface ChartDataPoint {
  year: number;
  population?: number;
  gdp?: number;
  urbanization?: number;
  hdi?: number;
  literacy?: number;
  lifeExpectancy?: number;
  gdpPerCapita?: number;
  [key: string]: number | undefined;
}

export interface TimelineData {
  minYear: number;
  maxYear: number;
  years: number[];
}

export type MetricType = 'all' | 'population' | 'economy' | 'society' | 'education';

export interface AppError {
  code: string;
  message: string;
  details?: Record<string, unknown>;
}
