import { useEffect, useRef, useMemo } from 'react';
import { vietnamData } from '@/data/vietnamData';
import { ScatterChart, Scatter, BarChart, Bar, RadarChart, Radar, PolarGrid, PolarAngleAxis, PolarRadiusAxis, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { CustomTooltip } from '@/components/ui/custom-tooltip';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';
import { FileText, TrendingUp, Target, Award } from 'lucide-react';

gsap.registerPlugin(ScrollTrigger);

export const SlidePolicyResearch = () => {
  const containerRef = useRef<HTMLDivElement>(null);

  // Policy periods data
  const policyPeriods = useMemo(() => {
    return vietnamData.map(d => {
      let period = 'Trước Đổi Mới';
      if (d.year >= 1986 && d.year < 2007) period = 'Đổi Mới (1986-2006)';
      else if (d.year >= 2007 && d.year < 2020) period = 'WTO & Hội Nhập (2007-2019)';
      else if (d.year >= 2020) period = 'COVID-19 & Phục Hồi (2020+)';

      return {
        year: d.year,
        period,
        gdpGrowth: d.gdpGrowth,
        povertyRate: d.povertyRate || 0,
        exportGrowth: d.exportGrowth || 0,
        fdi: d.fdiBillion || 0
      };
    }).filter(d => d.gdpGrowth > 0);
  }, []);

  // Correlation analysis
  const correlationData = useMemo(() => {
    const validData = vietnamData.filter(d =>
      d.gdpGrowth > 0 && d.povertyRate > 0 && d.exportGrowth !== undefined
    );

    return validData.map(d => ({
      year: d.year,
      gdpGrowth: d.gdpGrowth,
      povertyReduction: 100 - (d.povertyRate || 0),
      exportGrowth: d.exportGrowth,
      education: d.primaryCompletionRate || 0
    }));
  }, []);

  // Policy impact scores
  const policyImpactData = useMemo(() => [
    {
      policy: 'Đổi Mới 1986',
      economic: 9.2,
      social: 8.5,
      institutional: 9.8,
      sustainability: 7.9
    },
    {
      policy: 'WTO 2007',
      economic: 8.7,
      social: 7.3,
      institutional: 8.9,
      sustainability: 8.1
    },
    {
      policy: 'COVID-19 Response',
      economic: 6.8,
      social: 9.1,
      institutional: 7.2,
      sustainability: 8.5
    }
  ], []);

  // Policy recommendations
  const recommendations = [
    {
      area: 'Kinh Tế',
      recommendation: 'Tăng cường đầu tư vào công nghệ số và chuyển đổi xanh',
      impact: 'Cao'
    },
    {
      area: 'Xã Hội',
      recommendation: 'Đẩy mạnh bình đẳng giới và phát triển nguồn nhân lực chất lượng cao',
      impact: 'Cao'
    },
    {
      area: 'Môi Trường',
      recommendation: 'Chuyển đổi sang nền kinh tế carbon thấp và bảo vệ đa dạng sinh học',
      impact: 'Trung Bình'
    },
    {
      area: 'Thể Chế',
      recommendation: 'Cải thiện hiệu quả quản trị và chống tham nhũng',
      impact: 'Cao'
    }
  ];

  useEffect(() => {
    if (!containerRef.current) return;

    const ctx = gsap.context(() => {
      gsap.from('.policy-title', {
        opacity: 0,
        y: 50,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        duration: 1,
        ease: 'power3.out'
      });

      gsap.from('.policy-section', {
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

      gsap.from('.policy-chart', {
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
    <div ref={containerRef} className="min-h-screen bg-gradient-to-br from-purple-50 to-indigo-50 p-8">
      <div className="max-w-7xl mx-auto">
        {/* Title */}
        <div className="text-center mb-12">
          <h1 className="policy-title text-4xl font-bold text-gray-800 mb-4">
            Nghiên Cứu Chính Sách Phát Triển Việt Nam
          </h1>
          <p className="policy-title text-lg text-gray-600">
            Phân tích tác động của các chính sách kinh tế - xã hội qua các thời kỳ
          </p>
        </div>

        {/* Policy Periods Analysis */}
        <div className="policy-section bg-white rounded-xl shadow-lg p-8 mb-8">
          <div className="flex items-center mb-6">
            <FileText className="w-8 h-8 text-purple-600 mr-3" />
            <h2 className="text-2xl font-semibold text-gray-800">Phân Tích Theo Thời Kỳ Chính Sách</h2>
          </div>
          <div className="policy-chart h-96">
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={policyPeriods}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="year" />
                <YAxis />
                <Tooltip content={<CustomTooltip />} />
                <Legend />
                <Bar dataKey="gdpGrowth" fill="#16a34a" name="Tăng trưởng GDP (%)" />
                <Bar dataKey="exportGrowth" fill="#2563eb" name="Tăng trưởng Xuất khẩu (%)" />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Correlation Analysis */}
        <div className="policy-section bg-white rounded-xl shadow-lg p-8 mb-8">
          <div className="flex items-center mb-6">
            <TrendingUp className="w-8 h-8 text-blue-600 mr-3" />
            <h2 className="text-2xl font-semibold text-gray-800">Phân Tích Tương Quan</h2>
          </div>
          <div className="policy-chart h-96">
            <ResponsiveContainer width="100%" height="100%">
              <ScatterChart data={correlationData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="gdpGrowth" name="Tăng trưởng GDP (%)" />
                <YAxis dataKey="povertyReduction" name="Giảm nghèo (%)" />
                <Tooltip content={<CustomTooltip />} />
                <Scatter dataKey="povertyReduction" fill="#dc2626" />
              </ScatterChart>
            </ResponsiveContainer>
          </div>
          <p className="mt-4 text-gray-600 text-center">
            Mối tương quan giữa tăng trưởng GDP và giảm nghèo qua các năm
          </p>
        </div>

        {/* Policy Impact Radar */}
        <div className="policy-section bg-white rounded-xl shadow-lg p-8 mb-8">
          <div className="flex items-center mb-6">
            <Target className="w-8 h-8 text-green-600 mr-3" />
            <h2 className="text-2xl font-semibold text-gray-800">Đánh Giá Tác Động Chính Sách</h2>
          </div>
          <div className="policy-chart h-96">
            <ResponsiveContainer width="100%" height="100%">
              <RadarChart data={policyImpactData}>
                <PolarGrid />
                <PolarAngleAxis dataKey="policy" />
                <PolarRadiusAxis angle={90} domain={[0, 10]} />
                <Radar name="Kinh Tế" dataKey="economic" stroke="#16a34a" fill="#16a34a" fillOpacity={0.3} />
                <Radar name="Xã Hội" dataKey="social" stroke="#dc2626" fill="#dc2626" fillOpacity={0.3} />
                <Radar name="Thể Chế" dataKey="institutional" stroke="#2563eb" fill="#2563eb" fillOpacity={0.3} />
                <Radar name="Bền Vững" dataKey="sustainability" stroke="#f59e0b" fill="#f59e0b" fillOpacity={0.3} />
                <Legend />
              </RadarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Policy Recommendations */}
        <div className="policy-section bg-white rounded-xl shadow-lg p-8">
          <div className="flex items-center mb-6">
            <Award className="w-8 h-8 text-yellow-600 mr-3" />
            <h2 className="text-2xl font-semibold text-gray-800">Khuyến Nghị Chính Sách</h2>
          </div>
          <div className="grid md:grid-cols-2 gap-6">
            {recommendations.map((rec, index) => (
              <div key={index} className="bg-gray-50 p-6 rounded-lg border-l-4 border-blue-500">
                <div className="flex justify-between items-start mb-2">
                  <h3 className="font-semibold text-gray-800">{rec.area}</h3>
                  <span className={`px-2 py-1 rounded text-xs font-medium ${
                    rec.impact === 'Cao' ? 'bg-green-100 text-green-800' : 'bg-yellow-100 text-yellow-800'
                  }`}>
                    {rec.impact}
                  </span>
                </div>
                <p className="text-gray-700">{rec.recommendation}</p>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};