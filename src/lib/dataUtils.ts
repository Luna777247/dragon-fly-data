import type { VietnamDataPoint, ChartDataPoint, TimelineData } from './types';

let cachedData: VietnamDataPoint[] | null = null;

export function getCachedData(): VietnamDataPoint[] | null {
  return cachedData;
}

export function setCachedData(data: VietnamDataPoint[]): void {
  cachedData = data;
}

export function clearCache(): void {
  cachedData = null;
}

export function parseCSVToData(csvRaw: string): VietnamDataPoint[] {
  const lines = csvRaw.trim().split('\n');
  if (lines.length < 2) {
    throw new Error('Invalid CSV format: missing header or data rows');
  }

  const data: VietnamDataPoint[] = [];

  for (let i = 1; i < lines.length; i++) {
    const values = lines[i].split(',');
    if (values.length < 72) {
      console.warn(`Skipping row ${i}: insufficient columns`);
      continue;
    }

    try {
      const point: VietnamDataPoint = {
        year: parseInt(values[0], 10),
        population: parseInt(values[1], 10),
        yearlyChangePercent: parseFloat(values[2]),
        yearlyChange: parseInt(values[3], 10),
        migrantsNet: parseInt(values[4], 10),
        medianAge: parseFloat(values[5]),
        fertilityRate: parseFloat(values[6]),
        densityPerKm2: parseFloat(values[7]),
        urbanPopPercent: parseFloat(values[8]),
        urbanPopulation: parseInt(values[9], 10),
        countryShareOfWorldPop: parseFloat(values[10]),
        worldPopulation: parseInt(values[11], 10),
        vietnamGlobalRank: parseInt(values[12], 10),
        gdpBillion: parseFloat(values[13]),
        gdpPerCapita: parseFloat(values[14]),
        gdpGrowthRate: parseFloat(values[15]),
        gniPerCapita: parseFloat(values[16]),
        unemploymentRate: parseFloat(values[17]),
        povertyRate: parseFloat(values[18]),
        hdi: parseFloat(values[19]),
        educationIndex: parseFloat(values[20]),
        lifeExpectancy: parseFloat(values[21]),
        healthExpenditurePercent: parseFloat(values[22]),
        literacyRate: parseFloat(values[23]),
        employmentAgriculture: parseFloat(values[24]),
        employmentIndustry: parseFloat(values[25]),
        employmentServices: parseFloat(values[26]),
        ruralPopulation: parseInt(values[27], 10),
        urbanGrowthRate: parseFloat(values[28]),
        householdSize: parseFloat(values[29]),
        housingUnits: parseFloat(values[30]),
        migrationRate: parseFloat(values[31]),
        landArea: parseInt(values[32], 10),
        forestAreaPercent: parseFloat(values[33]),
        co2PerCapita: parseFloat(values[34]),
        energyConsumptionPerCapita: parseFloat(values[35]),
        agriculturalLandPercent: parseFloat(values[36]),
        climateRiskIndex: parseFloat(values[37]),
        birthRate: parseFloat(values[38]),
        deathRate: parseFloat(values[39]),
        infantMortalityRate: parseFloat(values[40]),
        dependencyRatio: parseFloat(values[41]),
        popAged0to14: parseFloat(values[42]),
        popAged15to64: parseFloat(values[43]),
        popAged65Plus: parseFloat(values[44]),
        sexRatio: parseFloat(values[45]),
        densityDBSH: parseFloat(values[46]),
        densityDBSCL: parseFloat(values[47]),
        densityMienTrung: parseFloat(values[48]),
        densityMienNui: parseFloat(values[49]),
        vietnamShareOfAsianPop: parseFloat(values[50]),
        aseanPopulationRank: parseInt(values[51], 10),
        regionalAvgFertilityRate: parseFloat(values[52]),
        regionalMedianAge: parseFloat(values[53]),
        globalMedianAge: parseFloat(values[54]),
        worldUrbanizationRate: parseFloat(values[55]),
        populationGrowthAbsolute: parseInt(values[56], 10),
        populationDoublingTime: parseFloat(values[57]),
        netMigrationRate: parseFloat(values[58]),
        urbanizationRatio: parseFloat(values[59]),
        dependencyIndex: parseFloat(values[60]),
        populationShareChange: parseFloat(values[61]),
        inflationRate: parseFloat(values[62]),
        gdpPPPPerCapita: parseFloat(values[63]),
        fdiNetInflows: parseFloat(values[64]),
        exportsPercent: parseFloat(values[65]),
        importsPercent: parseFloat(values[66]),
        meanYearsOfSchooling: parseFloat(values[67]),
        expectedYearsOfSchooling: parseFloat(values[68]),
        humanCapitalIndex: parseFloat(values[69]),
        renewableEnergyShare: parseFloat(values[70]),
        epiScore: parseFloat(values[71]),
      };

      if (!isNaN(point.year)) {
        data.push(point);
      }
    } catch (error) {
      console.warn(`Failed to parse row ${i}:`, error);
    }
  }

  return data;
}

export function getTimelineData(data: VietnamDataPoint[]): TimelineData {
  if (data.length === 0) {
    throw new Error('No data available');
  }

  const years = data.map((d) => d.year).sort((a, b) => a - b);
  const minYear = years[0] || 1950;
  const maxYear = years[years.length - 1] || 2025;

  return {
    minYear,
    maxYear,
    years,
  };
}

export function filterDataByYearRange(
  data: VietnamDataPoint[],
  startYear: number,
  endYear: number,
): VietnamDataPoint[] {
  return data.filter((d) => d.year >= startYear && d.year <= endYear);
}

export function transformToChartData(data: VietnamDataPoint[]): ChartDataPoint[] {
  return data.map((d) => ({
    year: d.year,
    population: Math.round(d.population / 1000000),
    gdp: Math.round(d.gdpBillion),
    urbanization: Math.round(d.urbanPopPercent),
    hdi: Math.round(d.hdi * 100),
    literacy: Math.round(d.literacyRate),
    lifeExpectancy: Math.round(d.lifeExpectancy),
    gdpPerCapita: Math.round(d.gdpPerCapita),
  }));
}

export function getLatestDataPoint(data: VietnamDataPoint[]): VietnamDataPoint | null {
  if (data.length === 0) return null;
  return data[data.length - 1] || null;
}

export function findDataByYear(data: VietnamDataPoint[], year: number): VietnamDataPoint | null {
  return data.find((d) => d.year === year) || null;
}

export function formatNumber(value: number, decimals: number = 1): string {
  return value.toFixed(decimals);
}

export function formatPopulation(value: number): string {
  return formatNumber(value / 1000000, 1);
}

export function formatCurrency(value: number): string {
  return `$${formatNumber(value, 1)}B`;
}
