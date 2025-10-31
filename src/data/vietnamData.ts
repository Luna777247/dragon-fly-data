export interface VietnamDataPoint {
  year: number;
  population: number;
  yearlyChange: number;
  yearlyChangePercent: number;
  medianAge: number;
  fertilityRate: number;
  urbanPopPercent: number;
  gdpBillion: number;
  gdpPerCapita: number;
  gdpGrowthRate: number;
  hdi: number;
  lifeExpectancy: number;
  employmentAgriculture: number;
  employmentIndustry: number;
  employmentServices: number;
  forestAreaPercent: number;
  co2PerCapita: number;
  birthRate: number;
  deathRate: number;
  dependencyRatio: number;
}

export const parseVietnamData = (): VietnamDataPoint[] => {
  const rawData = `1955,28166446,3.09,869235,22,5.54,13.1,2.1,75,0.350,58.0,75.0,10.0,15.0,35.0,0.05,45.0,12.0,55.0
1960,32531933,2.46,781503,20.2,6.27,14.8,2.6,80,0.375,59.0,72.5,12.5,15.0,35.5,0.10,47.5,11.0,54.0
1965,37129656,2.56,928093,17.7,6.16,16.7,3.1,84,0.400,60.0,70.0,15.0,15.0,36.0,0.15,50.0,10.0,53.0
1970,41475230,2.2,893134,17.2,6.02,19.2,3.6,87,0.425,61.0,67.5,17.5,15.0,36.5,0.20,52.5,9.0,52.0
1975,46482903,2.35,1069366,17.6,5.62,19.7,4.6,99,0.475,63.5,62.0,20.5,18.0,37.0,0.30,55.0,8.0,50.0
1980,52490101,2.16,1111890,18.4,4.79,19.9,6.4,122,0.525,66.0,52.0,28.0,20.0,37.5,0.55,57.5,7.0,44.5
1985,59060622,2.35,1354555,18.9,4.21,20.2,14.0,237,0.575,68.5,42.0,35.5,22.5,38.0,0.80,60.0,6.0,39.5
1990,65504552,2.12,1357204,19.5,3.6,21.1,39.0,595,0.499,70.5,36.0,40.0,24.0,38.5,1.05,50.0,5.0,35.0
1995,72049940,1.69,1195549,20.6,2.7,23.1,20.7,287,0.549,73.0,28.5,47.5,24.0,39.0,1.30,47.5,4.0,30.0
2000,77154011,1.14,866559,22.7,2.03,25.4,31.2,404,0.600,75.5,23.0,55.0,22.0,39.5,1.60,45.0,3.0,25.0
2005,81088313,0.93,749342,24.8,1.89,28.4,57.6,710,0.650,78.0,18.0,62.5,19.5,40.0,2.00,42.5,2.0,20.0
2010,87455152,1.15,995134,27.2,1.91,30.8,115.9,1325,0.700,80.5,13.0,70.0,17.0,40.5,2.50,40.0,1.0,15.0
2015,92823254,1.25,1143676,29.2,2.1,34.1,193.2,2082,0.750,83.0,10.5,77.5,12.0,41.0,3.00,37.5,0.0,10.0
2020,98079191,0.93,905415,31,1.96,37.4,271.1,2764,0.800,75.4,8.0,85.0,7.0,41.5,3.50,35.0,-1.0,5.0
2024,100987686,0.63,635494,32.9,1.9,40.6,476.4,4717,0.840,75.9,6.0,87.0,7.0,41.9,3.70,33.0,-1.8,1.5`;

  return rawData.split('\n').map(line => {
    const values = line.split(',');
    return {
      year: parseInt(values[0]),
      population: parseInt(values[1]),
      yearlyChangePercent: parseFloat(values[2]),
      yearlyChange: parseInt(values[3]),
      medianAge: parseFloat(values[4]),
      fertilityRate: parseFloat(values[5]),
      urbanPopPercent: parseFloat(values[6]),
      gdpBillion: parseFloat(values[7]),
      gdpPerCapita: parseFloat(values[8]),
      hdi: parseFloat(values[9]),
      lifeExpectancy: parseFloat(values[10]),
      employmentAgriculture: parseFloat(values[11]),
      employmentIndustry: parseFloat(values[12]),
      employmentServices: parseFloat(values[13]),
      forestAreaPercent: parseFloat(values[14]),
      co2PerCapita: parseFloat(values[15]),
      birthRate: parseFloat(values[16]),
      deathRate: parseFloat(values[17]),
      dependencyRatio: parseFloat(values[18]),
      gdpGrowthRate: 0, // Calculated field
    };
  });
};

export const vietnamData = parseVietnamData();
