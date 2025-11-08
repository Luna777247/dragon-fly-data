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

// Import CSV as raw text using Vite's ?raw suffix
import csvRawData from './vietnam_advance.csv?raw';

export const parseVietnamData = (): VietnamDataPoint[] => {
  const lines = csvRawData.trim().split('\n');
  const headers = lines[0].split(',');
  
  return lines.slice(1).map(line => {
    const values = line.split(',');
    return {
      year: parseInt(values[0]),
      population: parseInt(values[1]),
      yearlyChangePercent: parseFloat(values[2]),
      yearlyChange: parseInt(values[3]),
      migrantsNet: parseInt(values[4]),
      medianAge: parseFloat(values[5]),
      fertilityRate: parseFloat(values[6]),
      densityPerKm2: parseFloat(values[7]),
      urbanPopPercent: parseFloat(values[8]),
      urbanPopulation: parseInt(values[9]),
      countryShareOfWorldPop: parseFloat(values[10]),
      worldPopulation: parseInt(values[11]),
      vietnamGlobalRank: parseInt(values[12]),
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
      ruralPopulation: parseInt(values[27]),
      urbanGrowthRate: parseFloat(values[28]),
      householdSize: parseFloat(values[29]),
      housingUnits: parseFloat(values[30]),
      migrationRate: parseFloat(values[31]),
      landArea: parseInt(values[32]),
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
      aseanPopulationRank: parseInt(values[51]),
      regionalAvgFertilityRate: parseFloat(values[52]),
      regionalMedianAge: parseFloat(values[53]),
      globalMedianAge: parseFloat(values[54]),
      worldUrbanizationRate: parseFloat(values[55]),
      populationGrowthAbsolute: parseInt(values[56]),
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
  });
};

export const vietnamData = parseVietnamData();
