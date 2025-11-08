import html2canvas from 'html2canvas';
import jsPDF from 'jspdf';
import { useToast } from '@/hooks/use-toast';

export const useChartExport = () => {
  const { toast } = useToast();

  const exportToPNG = async (elementId: string, filename: string = 'chart') => {
    try {
      const element = document.getElementById(elementId);
      if (!element) {
        toast({
          title: "Lỗi",
          description: "Không tìm thấy biểu đồ để export",
          variant: "destructive",
        });
        return;
      }

      const canvas = await html2canvas(element, {
        backgroundColor: null,
        scale: 2,
        logging: false,
      });

      const link = document.createElement('a');
      link.download = `${filename}.png`;
      link.href = canvas.toDataURL('image/png');
      link.click();

      toast({
        title: "Thành công",
        description: "Đã xuất biểu đồ sang PNG",
      });
    } catch (error) {
      toast({
        title: "Lỗi",
        description: "Không thể xuất biểu đồ",
        variant: "destructive",
      });
    }
  };

  const exportToPDF = async (elementId: string, filename: string = 'chart', orientation: 'portrait' | 'landscape' = 'landscape') => {
    try {
      const element = document.getElementById(elementId);
      if (!element) {
        toast({
          title: "Lỗi",
          description: "Không tìm thấy biểu đồ để export",
          variant: "destructive",
        });
        return;
      }

      const canvas = await html2canvas(element, {
        backgroundColor: '#ffffff',
        scale: 2,
        logging: false,
      });

      const imgData = canvas.toDataURL('image/png');
      const pdf = new jsPDF({
        orientation: orientation,
        unit: 'mm',
        format: 'a4',
      });

      const pdfWidth = pdf.internal.pageSize.getWidth();
      const pdfHeight = pdf.internal.pageSize.getHeight();
      const imgWidth = canvas.width;
      const imgHeight = canvas.height;
      const ratio = Math.min(pdfWidth / imgWidth, pdfHeight / imgHeight);
      const imgX = (pdfWidth - imgWidth * ratio) / 2;
      const imgY = 10;

      pdf.addImage(imgData, 'PNG', imgX, imgY, imgWidth * ratio, imgHeight * ratio);
      pdf.save(`${filename}.pdf`);

      toast({
        title: "Thành công",
        description: "Đã xuất biểu đồ sang PDF",
      });
    } catch (error) {
      toast({
        title: "Lỗi",
        description: "Không thể xuất biểu đồ",
        variant: "destructive",
      });
    }
  };

  const exportDataToCSV = (data: any[], filename: string = 'data') => {
    try {
      if (!data || data.length === 0) {
        toast({
          title: "Lỗi",
          description: "Không có dữ liệu để xuất",
          variant: "destructive",
        });
        return;
      }

      const headers = Object.keys(data[0]);
      const csvContent = [
        headers.join(','),
        ...data.map(row => 
          headers.map(header => {
            const value = row[header];
            return typeof value === 'string' && value.includes(',') 
              ? `"${value}"` 
              : value;
          }).join(',')
        )
      ].join('\n');

      const blob = new Blob(['\ufeff' + csvContent], { type: 'text/csv;charset=utf-8;' });
      const link = document.createElement('a');
      link.href = URL.createObjectURL(blob);
      link.download = `${filename}.csv`;
      link.click();

      toast({
        title: "Thành công",
        description: "Đã xuất dữ liệu sang CSV",
      });
    } catch (error) {
      toast({
        title: "Lỗi",
        description: "Không thể xuất dữ liệu",
        variant: "destructive",
      });
    }
  };

  return {
    exportToPNG,
    exportToPDF,
    exportDataToCSV,
  };
};
