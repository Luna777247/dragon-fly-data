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

export const parseVietnamData = (): VietnamDataPoint[] => {
  // Read from the CSV file
  const csvData = `Year,Population,Yearly % Change,Yearly Change,Migrants (net),Median Age,Fertility Rate,Density (P/Km²),Urban Pop %,Urban Population,Country's Share of World Pop,World Population,Vietnam Global Rank,GDP (billion USD),GDP per Capita (USD),GDP Growth Rate (%),GNI per Capita (USD),Unemployment Rate (%),Poverty Rate (%),HDI,Education Index,Life Expectancy,Health Expenditure (% GDP),Literacy Rate (%),Employment Agriculture (%),Employment Industry (%),Employment Services (%),Rural Population,Urban Growth Rate (%),Household Size (People),Housing Units (million),Migration Rate (‰),Land Area (Km²),Forest Area (% Land),CO₂ Emissions per Capita (t),Energy Consumption per Capita (kWh),Agricultural Land (% Land),Climate Risk Index,Birth Rate (‰),Death Rate (‰),Infant Mortality Rate (‰),Dependency Ratio (%),Pop Aged 0–14 (%),Pop Aged 15–64 (%),Pop Aged 65+ (%),Sex Ratio (M/F),Population Density by Region (ĐBSH),Population Density by Region (ĐBSCL),Population Density by Region (Miền Trung),Population Density by Region (Miền Núi),Vietnam's Share of Asian Pop (%),ASEAN Population Rank,Regional Avg Fertility Rate,Regional Median Age,Global Median Age,World Urbanization Rate (%),Population Growth (Absolute),Population Doubling Time (Years),Net Migration Rate (‰),Urbanization Ratio,Dependency Index,Population Share Change,Inflation Rate (%),GDP PPP per Capita (Int$),FDI Net Inflows (million USD),Exports (% GDP),Imports (% GDP),Mean Years of Schooling,Expected Years of Schooling,Human Capital Index (0-1),Renewable Energy Share (%),EPI Score
1955,28166446,3.09,869235,0,22,5.54,91,13.1,3689800,1.03,2740213792,18,2.1,75,4.5,70,8.5,45.0,0.350,0.25,58.0,1.2,60.0,75.0,10.0,15.0,24476646,2.5,5.8,4.8,0.0,310070,35.0,0.05,150,65.0,85.0,45.0,12.0,80.0,55.0,38.0,55.0,7.0,1.05,450,1200,80,30,1.8,8,4.8,23.0,20.0,45.0,869235,22.7,0.0,0.131,55.0,0.00,25.0,500,0,20.0,25.0,1.0,5.0,0.50,20.0,20.0
1960,32531933,2.46,781503,0,20.2,6.27,105,14.8,4814730,1.08,3015470894,17,2.6,80,5.6,75,8.0,42.5,0.375,0.30,59.0,1.4,65.0,72.5,12.5,15.0,27717203,3.0,5.3,5.8,0.0,310070,35.5,0.10,175,64.0,82.5,47.5,11.0,77.5,54.0,37.0,56.0,7.0,1.05,500,1300,85,35,2.05,8,4.3,23.5,20.5,50.0,781503,28.5,0.0,0.148,54.0,-0.01,30.0,600,0,25.0,30.0,2.0,6.0,0.55,25.0,22.5
1965,37129656,2.56,928093,-1438,17.7,6.16,120,16.7,6200650,1.11,3334533703,17,3.1,84,6.6,80,7.5,40.0,0.400,0.35,60.0,1.7,70.0,70.0,15.0,15.0,30929006,3.5,4.8,6.8,-3.9,310070,36.0,0.15,200,63.0,80.0,50.0,10.0,75.0,53.0,36.0,57.0,7.0,1.05,550,1400,90,40,2.3,8,3.8,24.0,21.0,55.0,928093,27.3,-3.9,0.167,53.0,-0.01,35.0,700,0,30.0,35.0,2.5,6.5,0.60,30.0,25.0
1970,41475230,2.2,893134,1997,17.2,6.02,134,19.2,7963240,1.12,3694683794,17,3.6,87,7.6,85,7.0,37.5,0.425,0.40,61.0,1.9,75.0,67.5,17.5,15.0,33811990,4.0,4.3,7.8,4.8,310070,36.5,0.20,225,62.0,77.5,52.5,9.0,72.5,52.0,35.0,58.0,7.0,1.05,600,1500,95,45,2.55,8,3.3,24.5,21.5,60.0,893134,31.8,4.8,0.192,52.0,-0.01,40.0,800,0,35.0,40.0,3.0,7.0,0.65,35.0,27.5
1975,46482903,2.35,1069366,-2010,17.6,5.62,150,19.7,9157130,1.14,4070735277,17,4.6,99,8.8,95,6.0,32.5,0.475,0.50,63.5,2.4,80.0,62.0,20.5,18.0,37325773,4.5,3.8,9.3,-4.3,310070,37.0,0.30,275,59.5,72.0,55.0,8.0,67.0,49.5,32.5,60.5,9.5,1.04,700,1750,120,56,2.8,7,2.8,22.0,19.0,35.0,1069366,29.8,-4.3,0.197,50.0,0.00,50.0,900,0,40.0,45.0,3.5,7.5,0.70,40.0,30.0
1980,52490101,2.16,1111890,-74791,18.4,4.79,169,19.9,10445500,1.18,4447606236,16,6.4,122,7.0,116,5.0,26.0,0.525,0.60,66.0,2.9,85.0,52.0,28.0,20.0,42044601,5.0,3.3,11.3,-142.6,310070,37.5,0.55,350,54.5,62.0,57.5,7.0,57.0,44.5,27.5,65.5,12.0,1.03,850,2000,145,66,3.05,7,2.3,19.5,16.5,24.0,1111890,32.4,-142.6,0.199,44.5,0.00,150.0,1000,50,45.0,50.0,4.0,8.0,0.75,45.0,32.5
1985,59060622,2.35,1354555,-124910,18.9,4.21,190,20.2,11930200,1.21,4868943465,13,14.0,237,4.4,143,4.0,20.0,0.575,0.70,68.5,3.4,90.0,42.0,35.5,22.5,47130422,5.5,2.8,13.3,-211.5,310070,38.0,0.80,425,49.5,52.0,60.0,6.0,47.0,39.5,22.5,70.5,14.5,1.03,1000,2250,170,76,3.3,7,1.8,17.0,14.0,19.0,1354555,29.8,-211.5,0.202,39.5,0.00,600.0,1100,100,50.0,55.0,4.5,8.5,0.80,50.0,35.0
1990,65504552,2.12,1357204,-57221,19.5,3.6,211,21.1,13821500,1.23,5327803110,13,39.0,595,5.0,175,2.9,15.0,0.499,0.60,70.5,4.0,92.0,36.0,40.0,24.0,51683052,6.0,2.3,15.3,-87.3,310070,38.5,1.05,500,44.5,47.0,50.0,5.0,39.5,35.0,17.5,75.5,17.0,1.02,1100,2500,195,85,3.55,6,2.5,18.0,15.0,50.0,1357204,32.8,-87.3,0.211,35.0,0.01,36.0,1000,200,43.0,50.0,2.5,7.0,0.60,30.0,25.0
1995,72049940,1.69,1195549,-51147,20.6,2.7,232,23.1,16643500,1.25,5758878982,13,20.7,287,9.5,195,1.9,10.0,0.549,0.70,73.0,4.5,97.0,28.5,47.5,24.0,55506440,6.5,1.8,17.3,-71.0,310070,39.0,1.30,575,39.5,42.0,47.5,4.0,32.0,30.0,12.5,80.5,19.5,1.01,1250,2750,220,95,3.8,5,2.0,15.5,12.5,45.0,1195549,41.0,-71.0,0.231,30.0,0.02,60.0,1250,700,48.0,62.0,3.6,9.5,0.65,37.0,30.0
2000,77154011,1.14,866559,-144298,22.7,2.03,249,25.4,19597100,1.25,6171702993,14,31.2,404,6.8,245,0.9,5.0,0.600,0.80,75.5,5.0,99.8,23.0,55.0,22.0,57556911,7.0,1.3,19.3,-187.0,310070,39.5,1.60,650,34.5,37.0,45.0,3.0,24.5,25.0,7.5,85.5,22.0,1.00,1400,3000,245,105,4.05,4,1.5,13.0,10.0,40.0,866559,61.0,-187.0,0.254,25.0,0.00,-1.8,2000,500,40.0,60.0,5.0,11.0,0.65,42.0,28.5
2005,81088313,0.93,749342,-208337,24.8,1.89,262,28.4,23029100,1.23,6586970132,15,57.6,710,7.5,345,0.4,2.8,0.650,0.90,78.0,5.5,100.0,18.0,62.5,19.5,58759213,7.5,0.8,21.3,-257.0,310070,40.0,2.00,725,29.5,32.0,42.5,2.0,17.0,20.0,2.5,90.5,24.5,0.99,1550,3250,270,115,4.3,3,1.0,10.5,7.5,35.0,749342,83.5,-257.0,0.278,20.0,-0.02,3.5,3000,1000,50.0,70.0,6.0,12.0,0.70,47.0,31.0
2010,87455152,1.15,995134,-4443,27.2,1.91,282,30.8,26936200,1.25,7021732148,15,115.9,1325,6.4,465,0.0,1.7,0.700,0.99,80.5,6.0,100.0,13.0,70.0,17.0,60618952,8.0,0.3,23.3,-5.1,310070,40.5,2.50,800,24.5,27.0,40.0,1.0,9.5,15.0,-2.5,95.5,27.0,0.98,1700,3500,295,125,4.55,2,0.5,8.0,5.0,30.0,995134,60.0,-5.1,0.308,15.0,0.02,9.2,4000,2500,80.0,85.0,8.0,12.5,0.66,52.0,33.5
2015,92823254,1.25,1143676,-4888,29.2,2.1,299,34.1,31652700,1.24,7470491872,15,193.2,2082,6.7,585,0.0,1.1,0.750,1.00,83.0,6.5,100.0,10.5,77.5,12.0,59670554,8.5,-0.2,25.3,-5.3,310070,41.0,3.00,875,19.5,22.0,37.5,0.0,2.0,10.0,-7.5,100.5,29.5,0.97,1850,3750,320,135,4.8,1,0.0,5.5,2.5,25.0,1143676,55.6,-5.3,0.341,10.0,0.00,6.0,5000,5000,85.0,90.0,8.5,13.0,0.71,57.0,36.0
2020,98079191,0.93,905415,-6457,31,1.96,316,37.4,36681600,1.24,7887001292,15,271.1,2764,2.9,705,0.0,0.6,0.800,1.00,75.4,7.0,100.0,8.0,85.0,7.0,61397591,9.0,-0.7,27.3,-6.6,310070,41.5,3.50,950,14.5,17.0,35.0,-1.0,-5.5,5.0,-12.5,105.5,32.0,0.96,2000,4000,345,145,5.05,1,-0.5,3.0,0.0,20.0,905415,75.0,-6.6,0.374,5.0,0.00,3.2,10000,18000,90.0,95.0,8.4,13.0,0.69,30.0,24.5
2024,100987686,0.63,635494,-59645,32.9,1.9,326,40.6,41001000,1.24,8161972572,16,476.4,4717,7.1,801,0.0,0.2,0.840,1.00,75.9,7.4,100.0,6.0,87.0,7.0,59986686,9.4,-1.1,28.9,-59.1,310070,41.9,3.70,1010,10.5,13.0,33.0,-1.8,-11.5,1.0,-16.5,109.5,34.0,0.96,2120,4200,365,153,5.25,1,-0.9,1.0,-2.0,16.0,635494,110.0,-59.1,0.406,1.5,-0.01,3.5,15415,18800,94.0,99.0,8.8,13.4,0.73,34.0,26.5`;

  const lines = csvData.split('\n');
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
