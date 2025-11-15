import { useEffect, useRef, useMemo } from 'react';
import { vietnamData } from '@/data/vietnamData';
import { LineChart, Line, BarChart, Bar, AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { CustomTooltip } from '@/components/ui/custom-tooltip';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import { TrendingUp, Users, Heart, GraduationCap, Briefcase, Building } from 'lucide-react';

gsap.registerPlugin(ScrollTrigger);

export const SlideHistoricalTrends = () => {
  const containerRef = useRef<HTMLDivElement>(null);

  const gdpData = useMemo(() =>
    vietnamData.map(d => ({
      year: d.year,
      gdp: d.gdpBillion,
      gdpGrowth: d.gdpGrowth
    })).filter(d => d.gdp > 0),
    []
  );

  const populationData = useMemo(() =>
    vietnamData.map(d => ({
      year: d.year,
      population: d.populationMillion,
      urbanPop: d.urbanPopulationPercent,
      fertility: d.fertilityRate
    })).filter(d => d.population > 0),
    []
  );

  const healthData = useMemo(() =>
    vietnamData.map(d => ({
      year: d.year,
      lifeExpectancy: d.lifeExpectancy,
      infantMortality: d.infantMortality,
      co2Emissions: d.co2EmissionsPerCapita
    })).filter(d => d.lifeExpectancy > 0),
    []
  );

  const educationData = useMemo(() =>
    vietnamData.map(d => ({
      year: d.year,
      primaryCompletion: d.primaryCompletionRate,
      literacyRate: d.literacyRate
    })).filter(d => d.primaryCompletion > 0),
    []
  );

  const employmentData = useMemo(() =>
    vietnamData.map(d => ({
      year: d.year,
      unemployment: d.unemploymentRate,
      laborForce: d.laborForceParticipation
    })).filter(d => d.unemployment > 0),
    []
  );

  useEffect(() => {
    if (!containerRef.current) return;

    const ctx = gsap.context(() => {
      gsap.from('.hist-title', {
        opacity: 0,
        y: 50,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        duration: 1,
        ease: 'power3.out'
      });

      gsap.from('.hist-section', {
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

      gsap.from('.hist-chart', {
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
    <div ref={containerRef} className="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50 p-8">
      <div className="max-w-7xl mx-auto">
        {/* Title */}
        <div className="text-center mb-12">
          <h1 className="hist-title text-4xl font-bold text-gray-800 mb-4">
            Phân Tích Xu Hướng Lịch Sử Việt Nam (1960-2024)
          </h1>
          <p className="hist-title text-lg text-gray-600">
            Khám phá 65 năm phát triển kinh tế - xã hội của Việt Nam
          </p>
        </div>

        {/* GDP Growth Section */}
        <div className="hist-section bg-white rounded-xl shadow-lg p-8 mb-8">
          <div className="flex items-center mb-6">
            <TrendingUp className="w-8 h-8 text-green-600 mr-3" />
            <h2 className="text-2xl font-semibold text-gray-800">Tăng Trưởng GDP</h2>
          </div>
          <div className="hist-chart h-96">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={gdpData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="year" />
                <YAxis yAxisId="left" />
                <YAxis yAxisId="right" orientation="right" />
                <Tooltip content={<CustomTooltip />} />
                <Legend />
                <Line
                  yAxisId="left"
                  type="monotone"
                  dataKey="gdp"
                  stroke="#16a34a"
                  strokeWidth={3}
                  name="GDP (Tỷ USD)"
                />
                <Line
                  yAxisId="right"
                  type="monotone"
                  dataKey="gdpGrowth"
                  stroke="#dc2626"
                  strokeWidth={2}
                  name="Tăng trưởng GDP (%)"
                />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Population Demographics */}
        <div className="hist-section bg-white rounded-xl shadow-lg p-8 mb-8">
          <div className="flex items-center mb-6">
            <Users className="w-8 h-8 text-blue-600 mr-3" />
            <h2 className="text-2xl font-semibold text-gray-800">Biến Động Dân Số</h2>
          </div>
          <div className="hist-chart h-96">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={populationData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="year" />
                <YAxis yAxisId="left" />
                <YAxis yAxisId="right" orientation="right" />
                <Tooltip content={<CustomTooltip />} />
                <Legend />
                <Area
                  yAxisId="left"
                  type="monotone"
                  dataKey="population"
                  stackId="1"
                  stroke="#2563eb"
                  fill="#2563eb"
                  fillOpacity={0.6}
                  name="Dân số (Triệu)"
                />
                <Line
                  yAxisId="right"
                  type="monotone"
                  dataKey="urbanPop"
                  stroke="#f59e0b"
                  strokeWidth={3}
                  name="Đô thị hóa (%)"
                />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Health Improvements */}
        <div className="hist-section bg-white rounded-xl shadow-lg p-8 mb-8">
          <div className="flex items-center mb-6">
            <Heart className="w-8 h-8 text-red-600 mr-3" />
            <h2 className="text-2xl font-semibold text-gray-800">Cải Thiện Sức Khỏe</h2>
          </div>
          <div className="hist-chart h-96">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={healthData}>
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
                  stroke="#16a34a"
                  strokeWidth={3}
                  name="Tuổi thọ (Năm)"
                />
                <Line
                  yAxisId="right"
                  type="monotone"
                  dataKey="infantMortality"
                  stroke="#dc2626"
                  strokeWidth={2}
                  name="Tử vong trẻ sơ sinh (/1000)"
                />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Education Development */}
        <div className="hist-section bg-white rounded-xl shadow-lg p-8 mb-8">
          <div className="flex items-center mb-6">
            <GraduationCap className="w-8 h-8 text-purple-600 mr-3" />
            <h2 className="text-2xl font-semibold text-gray-800">Phát Triển Giáo Dục</h2>
          </div>
          <div className="hist-chart h-96">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={educationData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="year" />
                <YAxis />
                <Tooltip content={<CustomTooltip />} />
                <Legend />
                <Bar
                  dataKey="primaryCompletion"
                  fill="#8b5cf6"
                  name="Hoàn thành tiểu học (%)"
                />
                <Bar
                  dataKey="literacyRate"
                  fill="#06b6d4"
                  name="Tỷ lệ biết chữ (%)"
                />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Employment Trends */}
        <div className="hist-section bg-white rounded-xl shadow-lg p-8">
          <div className="flex items-center mb-6">
            <Briefcase className="w-8 h-8 text-orange-600 mr-3" />
            <h2 className="text-2xl font-semibold text-gray-800">Xu Hướng Việc Làm</h2>
          </div>
          <div className="hist-chart h-96">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={employmentData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="year" />
                <YAxis />
                <Tooltip content={<CustomTooltip />} />
                <Legend />
                <Line
                  type="monotone"
                  dataKey="unemployment"
                  stroke="#dc2626"
                  strokeWidth={3}
                  name="Thất nghiệp (%)"
                />
                <Line
                  type="monotone"
                  dataKey="laborForce"
                  stroke="#16a34a"
                  strokeWidth={2}
                  name="Tham gia lực lượng lao động (%)"
                />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>
    </div>
  );
};