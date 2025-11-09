import { useMemo } from 'react';
import { vietnamData } from '@/data/vietnamData';
import type { VietnamDataPoint, ChartDataPoint, TimelineData } from '@/lib/types';
import {
  getTimelineData,
  filterDataByYearRange,
  transformToChartData,
  getLatestDataPoint,
  findDataByYear,
} from '@/lib/dataUtils';

export interface UseVietnamDataOptions {
  startYear?: number;
  endYear?: number;
}

export function useVietnamData(options?: UseVietnamDataOptions) {
  const timelineData = useMemo<TimelineData>(() => {
    return getTimelineData(vietnamData);
  }, []);

  const filteredData = useMemo<VietnamDataPoint[]>(() => {
    if (!options?.startYear || !options?.endYear) {
      return vietnamData;
    }
    return filterDataByYearRange(vietnamData, options.startYear, options.endYear);
  }, [options?.startYear, options?.endYear]);

  const chartData = useMemo<ChartDataPoint[]>(() => {
    return transformToChartData(filteredData);
  }, [filteredData]);

  const latestData = useMemo<VietnamDataPoint | null>(() => {
    return getLatestDataPoint(filteredData);
  }, [filteredData]);

  const getDataByYear = useMemo(() => {
    return (year: number): VietnamDataPoint | null => {
      return findDataByYear(vietnamData, year);
    };
  }, []);

  return {
    data: vietnamData,
    filteredData,
    chartData,
    latestData,
    timelineData,
    getDataByYear,
  };
}

export function useVietnamDataPoint(year: number): VietnamDataPoint | null {
  return useMemo(() => {
    return findDataByYear(vietnamData, year);
  }, [year]);
}

export function useTimelineData(): TimelineData {
  return useMemo(() => {
    return getTimelineData(vietnamData);
  }, []);
}
