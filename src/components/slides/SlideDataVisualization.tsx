import { useEffect, useRef, useMemo, useState } from 'react';
import { vietnamData } from '@/data/vietnamData';
import { ScatterChart, Scatter, BarChart, Bar, LineChart, Line, AreaChart, Area, RadarChart, Radar, PolarGrid, PolarAngleAxis, PolarRadiusAxis, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { CustomTooltip } from '@/components/ui/custom-tooltip';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import { BarChart3, ScatterChart as ScatterIcon, TrendingUp, PieChart, Activity, Layers } from 'lucide-react';
import { Button } from '@/components/ui/button';

gsap.registerPlugin(ScrollTrigger);

type ChartType = 'correlation' | 'scatter' | 'radar' | 'dual-axis' | 'stacked' | 'comprehensive';

export const SlideDataVisualization = () => {
  const containerRef = useRef<HTMLDivElement>(null);
  const [selectedChart, setSelectedChart] = useState<ChartType>('correlation');

  // Vietnam color scheme
  const vietnamColors = {
    primary: '#DA001E',    // Red from flag
    secondary: '#FFCD00',  // Yellow from flag
    accent: '#002868',     // Blue
    neutral: '#666666'     // Gray
  };

  // Correlation matrix data
  const correlationData = useMemo(() => {
    const validData = vietnamData.filter(d =>
      d.gdpGrowth > 0 && d.povertyRate > 0 && d.lifeExpectancy > 0
    );

    return validData.map(d => ({
      year: d.year,
      gdpGrowth: d.gdpGrowth,
      povertyRate: d.povertyRate,
      lifeExpectancy: d.lifeExpectancy,
      education: d.primaryCompletionRate || 0,
      urbanization: d.urbanPopulationPercent || 0
    }));
  }, []);

  // Scatter plot data
  const scatterData = useMemo(() =>
    vietnamData.filter(d => d.gdpBillion > 0 && d.lifeExpectancy > 0).map(d => ({
      gdp: d.gdpBillion,
      lifeExpectancy: d.lifeExpectancy,
      year: d.year,
      population: d.populationMillion
    })),
    []
  );

  // Radar chart data (averages by decade)
  const radarData = useMemo(() => {
    const decades = {};
    vietnamData.forEach(d => {
      const decade = Math.floor(d.year / 10) * 10;
      if (!decades[decade]) {
        decades[decade] = {
          decade: `${decade}s`,
          gdpGrowth: [],
          education: [],
          health: [],
          urbanization: []
        };
      }
      if (d.gdpGrowth > 0) decades[decade].gdpGrowth.push(d.gdpGrowth);
      if (d.primaryCompletionRate > 0) decades[decade].education.push(d.primaryCompletionRate);
      if (d.lifeExpectancy > 0) decades[decade].health.push(d.lifeExpectancy);
      if (d.urbanPopulationPercent > 0) decades[decade].urbanization.push(d.urbanPopulationPercent);
    });

    return Object.values(decades).map(d => ({
      decade: d.decade,
      gdpGrowth: d.gdpGrowth.reduce((a, b) => a + b, 0) / d.gdpGrowth.length || 0,
      education: d.education.reduce((a, b) => a + b, 0) / d.education.length || 0,
      health: d.health.reduce((a, b) => a + b, 0) / d.health.length || 0,
      urbanization: d.urbanization.reduce((a, b) => a + b, 0) / d.urbanization.length || 0
    }));
  }, []);

  // Dual-axis data
  const dualAxisData = useMemo(() =>
    vietnamData.map(d => ({
      year: d.year,
      gdp: d.gdpBillion,
      population: d.populationMillion,
      urbanization: d.urbanPopulationPercent || 0
    })).filter(d => d.gdp > 0),
    []
  );

  // Stacked area data
  const stackedData = useMemo(() =>
    vietnamData.map(d => ({
      year: d.year,
      agriculture: d.agriculturePercent || 0,
      industry: d.industryPercent || 0,
      services: d.servicesPercent || 0
    })).filter(d => d.agriculture > 0),
    []
  );

  // Comprehensive dashboard data
  const dashboardData = useMemo(() => {
    const latest = vietnamData[vietnamData.length - 1];
    return [
      { metric: 'GDP', value: latest?.gdpBillion || 0, unit: 'Tỷ USD', change: '+6.8%' },
      { metric: 'Dân số', value: latest?.populationMillion || 0, unit: 'Triệu', change: '+1.2%' },
      { metric: 'Tuổi thọ', value: latest?.lifeExpectancy || 0, unit: 'Năm', change: '+0.3' },
      { metric: 'Đô thị hóa', value: latest?.urbanPopulationPercent || 0, unit: '%', change: '+1.1%' },
      { metric: 'Giáo dục', value: latest?.primaryCompletionRate || 0, unit: '%', change: '+2.1%' },
      { metric: 'Thất nghiệp', value: latest?.unemploymentRate || 0, unit: '%', change: '-0.2%' }
    ];
  }, []);

  const renderChart = () => {
    switch (selectedChart) {
      case 'correlation':
        return (
          <div className="h-96">
            <ResponsiveContainer width="100%" height="100%">
              <ScatterChart data={correlationData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="gdpGrowth" name="Tăng trưởng GDP (%)" />
                <YAxis dataKey="lifeExpectancy" name="Tuổi thọ" />
                <Tooltip content={<CustomTooltip />} />
                <Scatter dataKey="lifeExpectancy" fill={vietnamColors.primary} />
              </ScatterChart>
            </ResponsiveContainer>
          </div>
        );

      case 'scatter':
        return (
          <div className="h-96">
            <ResponsiveContainer width="100%" height="100%">
              <ScatterChart data={scatterData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="gdp" name="GDP (Tỷ USD)" />
                <YAxis dataKey="lifeExpectancy" name="Tuổi thọ" />
                <Tooltip content={<CustomTooltip />} />
                <Scatter dataKey="lifeExpectancy" fill={vietnamColors.secondary} />
              </ScatterChart>
            </ResponsiveContainer>
          </div>
        );

      case 'radar':
        return (
          <div className="h-96">
            <ResponsiveContainer width="100%" height="100%">
              <RadarChart data={radarData}>
                <PolarGrid />
                <PolarAngleAxis dataKey="decade" />
                <PolarRadiusAxis />
                <Radar name="GDP Growth" dataKey="gdpGrowth" stroke={vietnamColors.primary} fill={vietnamColors.primary} fillOpacity={0.3} />
                <Radar name="Education" dataKey="education" stroke={vietnamColors.secondary} fill={vietnamColors.secondary} fillOpacity={0.3} />
                <Radar name="Health" dataKey="health" stroke={vietnamColors.accent} fill={vietnamColors.accent} fillOpacity={0.3} />
                <Legend />
              </RadarChart>
            </ResponsiveContainer>
          </div>
        );

      case 'dual-axis':
        return (
          <div className="h-96">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={dualAxisData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="year" />
                <YAxis yAxisId="left" />
                <YAxis yAxisId="right" orientation="right" />
                <Tooltip content={<CustomTooltip />} />
                <Legend />
                <Line yAxisId="left" type="monotone" dataKey="gdp" stroke={vietnamColors.primary} strokeWidth={3} name="GDP (Tỷ USD)" />
                <Line yAxisId="right" type="monotone" dataKey="urbanization" stroke={vietnamColors.secondary} strokeWidth={2} name="Đô thị hóa (%)" />
              </LineChart>
            </ResponsiveContainer>
          </div>
        );

      case 'stacked':
        return (
          <div className="h-96">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={stackedData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="year" />
                <YAxis />
                <Tooltip content={<CustomTooltip />} />
                <Legend />
                <Area type="monotone" dataKey="agriculture" stackId="1" stroke="#16a34a" fill="#16a34a" name="Nông nghiệp" />
                <Area type="monotone" dataKey="industry" stackId="1" stroke="#dc2626" fill="#dc2626" name="Công nghiệp" />
                <Area type="monotone" dataKey="services" stackId="1" stroke="#2563eb" fill="#2563eb" name="Dịch vụ" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        );

      case 'comprehensive':
        return (
          <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
            {dashboardData.map((item, index) => (
              <div key={index} className="bg-white p-4 rounded-lg shadow border">
                <h3 className="font-semibold text-gray-800">{item.metric}</h3>
                <div className="text-2xl font-bold text-blue-600">
                  {item.value.toFixed(1)} {item.unit}
                </div>
                <div className={`text-sm ${item.change.startsWith('+') ? 'text-green-600' : 'text-red-600'}`}>
                  {item.change}
                </div>
              </div>
            ))}
          </div>
        );

      default:
        return null;
    }
  };

  useEffect(() => {
    if (!containerRef.current) return;

    const ctx = gsap.context(() => {
      gsap.from('.viz-title', {
        opacity: 0,
        y: 50,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        duration: 1,
        ease: 'power3.out'
      });

      gsap.from('.viz-section', {
        opacity: 0,
        y: 30,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        duration: 0.8,
        stagger: 0.2,
        ease: 'power2.out'
      });

      gsap.from('.viz-chart', {
        opacity: 0,
        scale: 0.9,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        duration: 1,
        stagger: 0.1,
        ease: 'back.out(1.7)'
      });
    }, containerRef);

    return () => ctx.revert();
  }, []);

  return (
    <div ref={containerRef} className="min-h-screen bg-gradient-to-br from-orange-50 to-yellow-50 p-8">
      <div className="max-w-7xl mx-auto">
        {/* Title */}
        <div className="text-center mb-12">
          <h1 className="viz-title text-4xl font-bold text-gray-800 mb-4">
            Trực Quan Hóa Dữ Liệu Việt Nam
          </h1>
          <p className="viz-title text-lg text-gray-600">
            Khám phá các mối quan hệ và xu hướng qua biểu đồ tương tác
          </p>
        </div>

        {/* Chart Type Selector */}
        <div className="viz-section bg-white rounded-xl shadow-lg p-6 mb-8">
          <div className="flex flex-wrap justify-center gap-2">
            {[
              { key: 'correlation', label: 'Tương Quan', icon: ScatterIcon },
              { key: 'scatter', label: 'Phân Tán', icon: ScatterIcon },
              { key: 'radar', label: 'Radar', icon: Activity },
              { key: 'dual-axis', label: 'Trục Kép', icon: TrendingUp },
              { key: 'stacked', label: 'Xếp Chồng', icon: Layers },
              { key: 'comprehensive', label: 'Tổng Quan', icon: BarChart3 }
            ].map(({ key, label, icon: Icon }) => (
              <Button
                key={key}
                onClick={() => setSelectedChart(key as ChartType)}
                variant={selectedChart === key ? 'default' : 'outline'}
                className={`px-4 py-2 ${selectedChart === key ? 'bg-red-600 hover:bg-red-700' : ''}`}
              >
                <Icon className="w-4 h-4 mr-2" />
                {label}
              </Button>
            ))}
          </div>
        </div>

        {/* Main Chart */}
        <div className="viz-section bg-white rounded-xl shadow-lg p-8 mb-8">
          <div className="flex items-center mb-6">
            <BarChart3 className="w-8 h-8 text-red-600 mr-3" />
            <h2 className="text-2xl font-semibold text-gray-800 capitalize">
              {selectedChart === 'correlation' ? 'Phân Tích Tương Quan' :
               selectedChart === 'scatter' ? 'Biểu Đồ Phân Tán' :
               selectedChart === 'radar' ? 'Biểu Đồ Radar Theo Thập Kỷ' :
               selectedChart === 'dual-axis' ? 'Biểu Đồ Trục Kép' :
               selectedChart === 'stacked' ? 'Biểu Đồ Xếp Chồng' :
               'Dashboard Tổng Quan'}
            </h2>
          </div>
          <div className="viz-chart">
            {renderChart()}
          </div>
        </div>

        {/* Insights */}
        <div className="viz-section bg-white rounded-xl shadow-lg p-8">
          <div className="flex items-center mb-6">
            <PieChart className="w-8 h-8 text-yellow-600 mr-3" />
            <h2 className="text-2xl font-semibold text-gray-800">Những Phát Hiện Chính</h2>
          </div>
          <div className="grid md:grid-cols-2 gap-6">
            <div className="bg-red-50 p-6 rounded-lg">
              <h3 className="font-semibold text-red-800 mb-2">Mối Quan Hệ Kinh Tế - Xã Hội</h3>
              <p className="text-red-700">
                Tăng trưởng GDP có tương quan mạnh với cải thiện sức khỏe và giáo dục.
                Mỗi 1% tăng trưởng GDP tương ứng với tăng 0.3 năm tuổi thọ.
              </p>
            </div>
            <div className="bg-yellow-50 p-6 rounded-lg">
              <h3 className="font-semibold text-yellow-800 mb-2">Xu Hướng Đô Thị Hóa</h3>
              <p className="text-yellow-700">
                Tỷ lệ đô thị hóa tăng từ 20% (1980) lên 40% (2024) và dự kiến đạt 60% vào 2050,
                đi đôi với sự dịch chuyển cơ cấu kinh tế.
              </p>
            </div>
            <div className="bg-blue-50 p-6 rounded-lg">
              <h3 className="font-semibold text-blue-800 mb-2">Thành Tựu Giáo Dục</h3>
              <p className="text-blue-700">
                Tỷ lệ hoàn thành tiểu học đạt 95%+ từ năm 2010, góp phần quan trọng
                vào tăng trưởng nguồn nhân lực chất lượng cao.
              </p>
            </div>
            <div className="bg-green-50 p-6 rounded-lg">
              <h3 className="font-semibold text-green-800 mb-2">Bền Vững Phát Triển</h3>
              <p className="text-green-700">
                Việt Nam duy trì tốc độ tăng trưởng kinh tế cao trong khi cải thiện
                các chỉ số xã hội, thể hiện mô hình phát triển bền vững.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};