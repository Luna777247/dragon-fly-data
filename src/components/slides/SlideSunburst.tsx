import { useEffect, useRef, useState } from 'react';
import { vietnamData } from '@/data/vietnamData';
import { CircleDot, Maximize2 } from 'lucide-react';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

interface SunburstNode {
  name: string;
  value?: number;
  children?: SunburstNode[];
  color: string;
  depth: number;
}

export const SlideSunburst = () => {
  const containerRef = useRef<HTMLDivElement>(null);
  const svgRef = useRef<SVGSVGElement>(null);
  const [hoveredNode, setHoveredNode] = useState<SunburstNode | null>(null);
  const [selectedYear, setSelectedYear] = useState(2024);

  useEffect(() => {
    if (!containerRef.current) return;

    const ctx = gsap.context(() => {
      gsap.from('.sunburst-title', {
        opacity: 0,
        y: 50,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        duration: 1,
        ease: 'power3.out'
      });

      gsap.from('.sunburst-viz', {
        opacity: 0,
        scale: 0.5,
        rotation: -180,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        duration: 1.5,
        ease: 'back.out(1.2)'
      });
    }, containerRef);

    return () => ctx.revert();
  }, []);

  const data = vietnamData.find(d => d.year === selectedYear);
  if (!data) return null;

  // Create hierarchical sunburst data
  const sunburstData: SunburstNode = {
    name: 'Việt Nam',
    depth: 0,
    color: 'hsl(var(--primary))',
    children: [
      {
        name: 'Dân Số',
        depth: 1,
        color: 'hsl(var(--primary))',
        children: [
          {
            name: 'ĐBSH',
            value: data.densityDBSH,
            depth: 2,
            color: 'hsl(var(--primary) / 0.8)',
          },
          {
            name: 'ĐBSCL',
            value: data.densityDBSCL,
            depth: 2,
            color: 'hsl(var(--primary) / 0.6)',
          },
          {
            name: 'Miền Trung',
            value: data.densityMienTrung,
            depth: 2,
            color: 'hsl(var(--primary) / 0.4)',
          },
          {
            name: 'Miền Núi',
            value: data.densityMienNui,
            depth: 2,
            color: 'hsl(var(--primary) / 0.2)',
          },
        ]
      },
      {
        name: 'Kinh Tế',
        depth: 1,
        color: 'hsl(var(--secondary))',
        children: [
          {
            name: 'Nông nghiệp',
            value: data.employmentAgriculture,
            depth: 2,
            color: 'hsl(var(--secondary) / 0.8)',
          },
          {
            name: 'Công nghiệp',
            value: data.employmentIndustry,
            depth: 2,
            color: 'hsl(var(--secondary) / 0.6)',
          },
          {
            name: 'Dịch vụ',
            value: data.employmentServices,
            depth: 2,
            color: 'hsl(var(--secondary) / 0.4)',
          },
        ]
      },
      {
        name: 'Xã Hội',
        depth: 1,
        color: 'hsl(var(--accent))',
        children: [
          {
            name: '0-14 tuổi',
            value: data.popAged0to14,
            depth: 2,
            color: 'hsl(var(--accent) / 0.8)',
          },
          {
            name: '15-64 tuổi',
            value: data.popAged15to64,
            depth: 2,
            color: 'hsl(var(--accent) / 0.6)',
          },
          {
            name: '65+ tuổi',
            value: data.popAged65Plus,
            depth: 2,
            color: 'hsl(var(--accent) / 0.4)',
          },
        ]
      },
    ]
  };

  // Calculate sunburst arcs
  const width = 600;
  const height = 600;
  const radius = Math.min(width, height) / 2;
  const centerX = width / 2;
  const centerY = height / 2;

  const renderSunburst = (node: SunburstNode, startAngle: number, endAngle: number, innerRadius: number, outerRadius: number): JSX.Element[] => {
    const elements: JSX.Element[] = [];
    
    if (node.value !== undefined) {
      const angle = (startAngle + endAngle) / 2;
      const x1 = centerX + Math.cos(startAngle) * innerRadius;
      const y1 = centerY + Math.sin(startAngle) * innerRadius;
      const x2 = centerX + Math.cos(endAngle) * innerRadius;
      const y2 = centerY + Math.sin(endAngle) * innerRadius;
      const x3 = centerX + Math.cos(endAngle) * outerRadius;
      const y3 = centerY + Math.sin(endAngle) * outerRadius;
      const x4 = centerX + Math.cos(startAngle) * outerRadius;
      const y4 = centerY + Math.sin(startAngle) * outerRadius;

      const largeArc = endAngle - startAngle > Math.PI ? 1 : 0;

      const path = `
        M ${x1} ${y1}
        A ${innerRadius} ${innerRadius} 0 ${largeArc} 1 ${x2} ${y2}
        L ${x3} ${y3}
        A ${outerRadius} ${outerRadius} 0 ${largeArc} 0 ${x4} ${y4}
        Z
      `;

      elements.push(
        <path
          key={`${node.name}-${startAngle}`}
          d={path}
          fill={node.color}
          stroke="hsl(var(--background))"
          strokeWidth={2}
          className="transition-all duration-300 cursor-pointer hover:opacity-80"
          onMouseEnter={() => setHoveredNode(node)}
          onMouseLeave={() => setHoveredNode(null)}
        />
      );

      // Add label
      const labelX = centerX + Math.cos(angle) * ((innerRadius + outerRadius) / 2);
      const labelY = centerY + Math.sin(angle) * ((innerRadius + outerRadius) / 2);
      
      elements.push(
        <text
          key={`label-${node.name}-${startAngle}`}
          x={labelX}
          y={labelY}
          textAnchor="middle"
          dominantBaseline="middle"
          fill="hsl(var(--foreground))"
          className="text-xs font-bold pointer-events-none"
        >
          {node.name}
        </text>
      );
    }

    if (node.children) {
      const totalValue = node.children.reduce((sum, child) => sum + (child.value || child.children?.reduce((s, c) => s + (c.value || 0), 0) || 0), 0);
      let currentAngle = startAngle;

      node.children.forEach(child => {
        const childValue = child.value || child.children?.reduce((s, c) => s + (c.value || 0), 0) || 0;
        const childAngle = ((endAngle - startAngle) * childValue) / totalValue;
        const childEndAngle = currentAngle + childAngle;

        elements.push(...renderSunburst(child, currentAngle, childEndAngle, outerRadius, outerRadius + 80));
        currentAngle = childEndAngle;
      });
    }

    return elements;
  };

  return (
    <div ref={containerRef} className="min-h-screen py-20 px-6 relative overflow-hidden bg-gradient-to-br from-background via-primary/5 to-accent/10">
      <div className="max-w-7xl mx-auto relative z-10">
        {/* Header */}
        <div className="text-center mb-12">
          <CircleDot className="sunburst-title w-16 h-16 text-primary mx-auto mb-6 animate-pulse" />
          <h2 className="sunburst-title font-display text-5xl md:text-6xl font-bold mb-4">
            Sunburst <span className="text-primary dragon-glow">Phân Cấp</span>
          </h2>
          <p className="sunburst-title text-xl text-muted-foreground">Cấu trúc dữ liệu theo vùng miền và lĩnh vực</p>
        </div>

        {/* Year Selector */}
        <div className="mb-8 text-center">
          <select
            value={selectedYear}
            onChange={(e) => setSelectedYear(parseInt(e.target.value))}
            className="bg-card/50 text-foreground border-2 border-primary rounded-xl px-6 py-3 text-xl font-bold cursor-pointer focus:outline-none focus:ring-2 focus:ring-primary"
          >
            {vietnamData.map(d => (
              <option key={d.year} value={d.year}>{d.year}</option>
            ))}
          </select>
        </div>

        {/* Sunburst Visualization */}
        <div className="flex justify-center items-center mb-12">
          <div className="sunburst-viz relative">
            <svg ref={svgRef} width={width} height={height} className="drop-shadow-2xl">
              {/* Center circle */}
              <circle
                cx={centerX}
                cy={centerY}
                r={80}
                fill="hsl(var(--card))"
                stroke="hsl(var(--primary))"
                strokeWidth={3}
              />
              <text
                x={centerX}
                y={centerY - 10}
                textAnchor="middle"
                className="text-2xl font-bold fill-primary"
              >
                {selectedYear}
              </text>
              <text
                x={centerX}
                y={centerY + 15}
                textAnchor="middle"
                className="text-sm fill-muted-foreground"
              >
                Việt Nam
              </text>

              {/* Render sunburst */}
              {renderSunburst(sunburstData, 0, Math.PI * 2, 100, 180)}
            </svg>

            {/* Hover tooltip */}
            {hoveredNode && hoveredNode.value !== undefined && (
              <div className="absolute top-4 right-4 bg-card/95 backdrop-blur-md border border-primary/30 rounded-xl p-4 shadow-lg animate-scale-in">
                <div className="text-sm font-semibold text-primary mb-1">{hoveredNode.name}</div>
                <div className="text-2xl font-bold">{hoveredNode.value.toFixed(1)}</div>
                <div className="text-xs text-muted-foreground">
                  {hoveredNode.depth === 2 && hoveredNode.name.includes('tuổi') ? '% dân số' : 
                   hoveredNode.depth === 2 && (hoveredNode.name === 'Nông nghiệp' || hoveredNode.name === 'Công nghiệp' || hoveredNode.name === 'Dịch vụ') ? '% việc làm' :
                   'Mật độ (người/km²)'}
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Legend */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="bg-gradient-to-br from-primary/20 to-primary/5 p-6 rounded-xl border border-primary/30">
            <h3 className="text-xl font-bold text-primary mb-3">Dân Số Vùng</h3>
            <div className="space-y-2 text-sm text-muted-foreground">
              <div>• ĐBSH: Đồng bằng sông Hồng</div>
              <div>• ĐBSCL: Đồng bằng sông Cửu Long</div>
              <div>• Miền Trung & Miền Núi</div>
            </div>
          </div>

          <div className="bg-gradient-to-br from-secondary/20 to-secondary/5 p-6 rounded-xl border border-secondary/30">
            <h3 className="text-xl font-bold text-secondary mb-3">Cơ Cấu Kinh Tế</h3>
            <div className="space-y-2 text-sm text-muted-foreground">
              <div>• Nông nghiệp: {data.employmentAgriculture}%</div>
              <div>• Công nghiệp: {data.employmentIndustry}%</div>
              <div>• Dịch vụ: {data.employmentServices}%</div>
            </div>
          </div>

          <div className="bg-gradient-to-br from-accent/20 to-accent/5 p-6 rounded-xl border border-accent/30">
            <h3 className="text-xl font-bold text-accent mb-3">Cơ Cấu Tuổi</h3>
            <div className="space-y-2 text-sm text-muted-foreground">
              <div>• 0-14 tuổi: {data.popAged0to14}%</div>
              <div>• 15-64 tuổi: {data.popAged15to64}%</div>
              <div>• 65+ tuổi: {data.popAged65Plus}%</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
