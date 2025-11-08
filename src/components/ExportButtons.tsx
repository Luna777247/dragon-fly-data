import { Download, FileImage, FileText } from 'lucide-react';
import { Button } from '@/components/ui/button';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { useChartExport } from '@/hooks/useChartExport';

interface ExportButtonsProps {
  elementId: string;
  filename: string;
  data?: any[];
  orientation?: 'portrait' | 'landscape';
  variant?: 'default' | 'ghost' | 'outline';
}

export const ExportButtons = ({ 
  elementId, 
  filename, 
  data,
  orientation = 'landscape',
  variant = 'outline'
}: ExportButtonsProps) => {
  const { exportToPNG, exportToPDF, exportDataToCSV } = useChartExport();

  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button 
          variant={variant}
          size="sm"
          className="gap-2 bg-primary/10 hover:bg-primary/20 border-primary/30"
        >
          <Download className="w-4 h-4" />
          Xuất dữ liệu
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="w-48">
        <DropdownMenuItem 
          onClick={() => exportToPNG(elementId, filename)}
          className="gap-2 cursor-pointer"
        >
          <FileImage className="w-4 h-4" />
          Xuất PNG
        </DropdownMenuItem>
        <DropdownMenuItem 
          onClick={() => exportToPDF(elementId, filename, orientation)}
          className="gap-2 cursor-pointer"
        >
          <FileText className="w-4 h-4" />
          Xuất PDF
        </DropdownMenuItem>
        {data && data.length > 0 && (
          <DropdownMenuItem 
            onClick={() => exportDataToCSV(data, filename)}
            className="gap-2 cursor-pointer"
          >
            <FileText className="w-4 h-4" />
            Xuất CSV
          </DropdownMenuItem>
        )}
      </DropdownMenuContent>
    </DropdownMenu>
  );
};
