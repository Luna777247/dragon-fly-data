import type { VietnamDataPoint } from '@/lib/types';
import { parseCSVToData, setCachedData } from '@/lib/dataUtils';
import csvRawData from './vietnam_advance.csv?raw';

export const parseVietnamData = (): VietnamDataPoint[] => {
  return parseCSVToData(csvRawData);
};

export const vietnamData = parseVietnamData();

setCachedData(vietnamData);

export type { VietnamDataPoint } from '@/lib/types';
