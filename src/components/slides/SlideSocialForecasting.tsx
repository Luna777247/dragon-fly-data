import { useEffect, useRef, useMemo } from 'react';
import { vietnamData } from '@/data/vietnamData';
import { LineChart, Line, AreaChart, Area, BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { CustomTooltip } from '@/components/ui/custom-tooltip';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import { Users, Heart, GraduationCap, Briefcase, Home, TrendingUp } from 'lucide-react';

gsap.registerPlugin(ScrollTrigger);

export const SlideSocialForecasting = () => {
  const containerRef = useRef<HTMLDivElement>(null);

  // Historical data for forecasting
  const historicalData = useMemo(() =>
    vietnamData.filter(d => d.year >= 2000).map(d => ({
      year: d.year,
      population: d.populationMillion,
      urbanPop: d.urbanPopulationPercent,
      lifeExpectancy: d.lifeExpectancy,
      primaryCompletion: d.primaryCompletionRate,
      unemployment: d.unemploymentRate,
      fertility: d.fertilityRate
    })),
    []
  );

  // Social forecasting (2025-2050)
  const socialForecast = useMemo(() => {
    const lastData = historicalData[historicalData.length - 1];
    if (!lastData) return [];

    const forecasts = [];
    let currentYear = lastData.year;
    let currentPop = lastData.population;
    let currentUrban = lastData.urbanPop;
    let currentLifeExp = lastData.lifeExpectancy;
    let currentEducation = lastData.primaryCompletion;
    let currentUnemp = lastData.unemployment;
    let currentFertility = lastData.fertility;

    for (let i = 1; i <= 26; i++) {
      currentYear += 1;

      // Population growth (slowing down)
      const popGrowthRate = Math.max(0.005, 0.01 - (i * 0.0002)); // From 1% to 0.5%
      currentPop *= (1 + popGrowthRate);

      // Urbanization (continuing trend)
      currentUrban = Math.min(80, currentUrban + 0.8); // Approach 80%

      // Life expectancy (gradual increase)
      currentLifeExp = Math.min(78, currentLifeExp + 0.15); // Approach 78

      // Education (high completion rates)
      currentEducation = Math.min(98, currentEducation + 0.3); // Approach 98%

      // Unemployment (stable around 2-3%)
      currentUnemp = 2.5 + (Math.sin(i / 5) * 0.5); // Slight oscillation

      // Fertility (stabilizing)
      currentFertility = Math.max(1.8, currentFertility - 0.02); // Approach 1.8

      forecasts.push({
        year: currentYear,
        population: Math.round(currentPop * 100) / 100,
        urbanPop: Math.round(currentUrban * 100) / 100,
        lifeExpectancy: Math.round(currentLifeExp * 100) / 100,
        primaryCompletion: Math.round(currentEducation * 100) / 100,
        unemployment: Math.round(currentUnemp * 100) / 100,
        fertility: Math.round(currentFertility * 100) / 100
      });
    }

    return forecasts;
  }, [historicalData]);

  // Combined historical + forecast
  const combinedData = useMemo(() =>
    [...historicalData, ...socialForecast],
    [historicalData, socialForecast]
  );

  // Key social indicators summary
  const socialSummary = useMemo(() => {
    const current = historicalData[historicalData.length - 1];
    const future = socialForecast[socialForecast.length - 1];

    return [
      {
        indicator: 'Dân số',
        current: current?.population || 0,
        future: future?.population || 0,
        change: ((future?.population || 0) / (current?.population || 1) - 1) * 100,
        icon: Users
      },
      {
        indicator: 'Đô thị hóa',
        current: current?.urbanPop || 0,
        future: future?.urbanPop || 0,
        change: (future?.urbanPop || 0) - (current?.urbanPop || 0),
        icon: Home
      },
      {
        indicator: 'Tuổi thọ',
        current: current?.lifeExpectancy || 0,
        future: future?.lifeExp || 0,
        change: (future?.lifeExpectancy || 0) - (current?.lifeExpectancy || 0),
        icon: Heart
      },
      {
        indicator: 'Giáo dục',
        current: current?.primaryCompletion || 0,
        future: future?.primaryCompletion || 0,
        change: (future?.primaryCompletion || 0) - (current?.primaryCompletion || 0),
        icon: GraduationCap
      },
      {
        indicator: 'Thất nghiệp',
        current: current?.unemployment || 0,
        future: future?.unemployment || 0,
        change: (future?.unemployment || 0) - (current?.unemployment || 0),
        icon: Briefcase
      },
      {
        indicator: 'Tỷ suất sinh',
        current: current?.fertility || 0,
        future: future?.fertility || 0,
        change: (future?.fertility || 0) - (current?.fertility || 0),
        icon: TrendingUp
      }
    ];
  }, [historicalData, socialForecast]);

  useEffect(() => {
    if (!containerRef.current) return;

    const ctx = gsap.context(() => {
      gsap.from('.social-title', {
        opacity: 0,
        y: 50,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        duration: 1,
        ease: 'power3.out'
      });

      gsap.from('.social-section', {
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

      gsap.from('.social-chart', {
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
    <div ref={containerRef} className="min-h-screen bg-gradient-to-br from-pink-50 to-rose-50 p-8">
      <div className="max-w-7xl mx-auto">
        {/* Title */}
        <div className="text-center mb-12">
          <h1 className="social-title text-4xl font-bold text-gray-800 mb-4">
            Dự Báo Xã Hội Việt Nam (2025-2050)
          </h1>
          <p className="social-title text-lg text-gray-600">
            Dự báo các chỉ số xã hội quan trọng cho tương lai
          </p>
        </div>

        {/* Population Forecast */}
        <div className="social-section bg-white rounded-xl shadow-lg p-8 mb-8">
          <div className="flex items-center mb-6">
            <Users className="w-8 h-8 text-blue-600 mr-3" />
            <h2 className="text-2xl font-semibold text-gray-800">Dự Báo Dân Số</h2>
          </div>
          <div className="social-chart h-96">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={combinedData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="year" />
                <YAxis />
                <Tooltip content={<CustomTooltip />} />
                <Legend />
                <Area
                  type="monotone"
                  dataKey="population"
                  stroke="#2563eb"
                  fill="#2563eb"
                  fillOpacity={0.3}
                  name="Dân số (Triệu)"
                />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Urbanization and Education */}
        <div className="social-section bg-white rounded-xl shadow-lg p-8 mb-8">
          <div className="flex items-center mb-6">
            <Home className="w-8 h-8 text-green-600 mr-3" />
            <h2 className="text-2xl font-semibold text-gray-800">Đô Thị Hóa và Giáo Dục</h2>
          </div>
          <div className="social-chart h-96">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={combinedData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="year" />
                <YAxis yAxisId="left" />
                <YAxis yAxisId="right" orientation="right" />
                <Tooltip content={<CustomTooltip />} />
                <Legend />
                <Line
                  yAxisId="left"
                  type="monotone"
                  dataKey="urbanPop"
                  stroke="#16a34a"
                  strokeWidth={3}
                  name="Đô thị hóa (%)"
                />
                <Line
                  yAxisId="right"
                  type="monotone"
                  dataKey="primaryCompletion"
                  stroke="#8b5cf6"
                  strokeWidth={2}
                  name="Hoàn thành tiểu học (%)"
                />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Health and Employment */}
        <div className="social-section bg-white rounded-xl shadow-lg p-8 mb-8">
          <div className="flex items-center mb-6">
            <Heart className="w-8 h-8 text-red-600 mr-3" />
            <h2 className="text-2xl font-semibold text-gray-800">Sức Khỏe và Việc Làm</h2>
          </div>
          <div className="social-chart h-96">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={combinedData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="year" />
                <YAxis yAxisId="left" />
                <YAxis yAxisId="right" orientation="right" />
                <Tooltip content={<CustomTooltip />} />
                <Legend />
                <Line
                  yAxisId="left"
                  type="monotone"
                  dataKey="lifeExpectancy"
                  stroke="#dc2626"
                  strokeWidth={3}
                  name="Tuổi thọ (Năm)"
                />
                <Line
                  yAxisId="right"
                  type="monotone"
                  dataKey="unemployment"
                  stroke="#f59e0b"
                  strokeWidth={2}
                  name="Thất nghiệp (%)"
                />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Social Indicators Summary */}
        <div className="social-section bg-white rounded-xl shadow-lg p-8">
          <div className="flex items-center mb-6">
            <TrendingUp className="w-8 h-8 text-purple-600 mr-3" />
            <h2 className="text-2xl font-semibold text-gray-800">Tóm Tắt Các Chỉ Số Xã Hội</h2>
          </div>
          <div className="grid md:grid-cols-3 gap-6">
            {socialSummary.map((item, index) => {
              const Icon = item.icon;
              return (
                <div key={index} className="bg-gray-50 p-6 rounded-lg">
                  <div className="flex items-center mb-3">
                    <Icon className="w-6 h-6 text-blue-600 mr-2" />
                    <h3 className="font-semibold text-gray-800">{item.indicator}</h3>
                  </div>
                  <div className="space-y-2">
                    <div className="flex justify-between">
                      <span className="text-gray-600">Hiện tại:</span>
                      <span className="font-medium">{item.current.toFixed(1)}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-600">2050:</span>
                      <span className="font-medium">{item.future.toFixed(1)}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-gray-600">Thay đổi:</span>
                      <span className={`font-medium ${item.change > 0 ? 'text-green-600' : 'text-red-600'}`}>
                        {item.change > 0 ? '+' : ''}{item.change.toFixed(1)}
                        {item.indicator === 'Dân số' ? '%' : item.indicator === 'Tuổi thọ' ? ' năm' : '%'}
                      </span>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </div>
    </div>
  );
};