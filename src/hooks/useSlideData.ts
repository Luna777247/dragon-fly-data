import { useMemo } from 'react';
import { vietnamData } from '@/data/vietnamData';
import type { VietnamDataPoint } from '@/lib/types';

export const useSlideData = () => {
  const latestData = useMemo(() => vietnamData[vietnamData.length - 1], []);
  const earliestData = useMemo(() => vietnamData[0], []);

  const getMilestoneData = useMemo(
    () => (years: number[]) =>
      vietnamData.filter((d) => years.includes(d.year)),
    []
  );

  const getDataByYear = useMemo(
    () => (year: number) =>
      vietnamData.find((d) => d.year === year),
    []
  );

  const getDataRange = useMemo(
    () => (startYear: number, endYear: number) =>
      vietnamData.filter((d) => d.year >= startYear && d.year <= endYear),
    []
  );

  const getYearComparison = useMemo(
    () => (year1: number, year2: number) => {
      const data1 = vietnamData.find((d) => d.year === year1);
      const data2 = vietnamData.find((d) => d.year === year2);
      return { data1, data2 };
    },
    []
  );

  const calculateChange = useMemo(
    () => (startValue: number, endValue: number) => {
      const change = ((endValue - startValue) / startValue) * 100;
      return {
        value: change,
        isPositive: change > 0,
        formatted: `${change > 0 ? '+' : ''}${change.toFixed(1)}%`,
        multiplier: (endValue / startValue).toFixed(1),
      };
    },
    []
  );

  const getEmploymentStructure = useMemo(
    () => () =>
      vietnamData.map((d) => ({
        year: d.year,
        agriculture: d.employmentAgriculture || 0,
        industry: d.employmentIndustry || 0,
        services: d.employmentServices || 0,
      })),
    []
  );

  const getUrbanizationData = useMemo(
    () => () =>
      vietnamData.map((d) => {
        const urbanPop = (d.population * d.urbanPopPercent) / 100 / 1000000;
        const ruralPop = (d.population * (100 - d.urbanPopPercent)) / 100 / 1000000;
        return {
          year: d.year,
          urbanPopPercent: d.urbanPopPercent,
          ruralPop,
          urbanPop,
        };
      }),
    []
  );

  const getDemographicData = useMemo(
    () => () =>
      vietnamData.map((d) => ({
        year: d.year,
        medianAge: d.medianAge,
        fertility: d.fertilityRate,
      })),
    []
  );

  const getVitalStats = useMemo(
    () => () =>
      vietnamData.map((d) => ({
        year: d.year,
        birthRate: d.birthRate,
        deathRate: d.deathRate,
        fertilityRate: d.fertilityRate,
        dependencyRatio: d.dependencyRatio,
      })),
    []
  );

  return {
    allData: vietnamData,
    latestData,
    earliestData,
    getMilestoneData,
    getDataByYear,
    getDataRange,
    getYearComparison,
    calculateChange,
    getEmploymentStructure,
    getUrbanizationData,
    getDemographicData,
    getVitalStats,
  };
};
