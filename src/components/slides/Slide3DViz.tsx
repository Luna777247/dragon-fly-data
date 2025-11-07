import { useEffect, useRef, useState } from 'react';
import { vietnamData } from '@/data/vietnamData';
import { Box, Layers, TrendingUp } from 'lucide-react';
import gsap from 'gsap';
import { ScrollTrigger } from 'gsap/ScrollTrigger';

gsap.registerPlugin(ScrollTrigger);

export const Slide3DViz = () => {
  const containerRef = useRef<HTMLDivElement>(null);
  const [hoveredBar, setHoveredBar] = useState<number | null>(null);
  const [rotation, setRotation] = useState({ x: 0, y: 0 });
  const [zoom, setZoom] = useState(1);
  const [isDragging, setIsDragging] = useState(false);
  const [lastPos, setLastPos] = useState({ x: 0, y: 0 });

  useEffect(() => {
    if (!containerRef.current) return;

    const ctx = gsap.context(() => {
      gsap.from('.viz3d-title', {
        opacity: 0,
        y: 50,
        rotationX: -90,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        duration: 1,
        ease: 'power3.out'
      });

      gsap.from('.viz3d-bar', {
        opacity: 0,
        scaleY: 0,
        rotationX: 90,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        duration: 1.5,
        stagger: 0.05,
        ease: 'elastic.out(1, 0.5)'
      });

      gsap.from('.viz3d-layer', {
        opacity: 0,
        z: -200,
        scrollTrigger: {
          trigger: containerRef.current,
          start: 'top center',
        },
        duration: 1.2,
        stagger: 0.1,
        ease: 'power2.out'
      });
    }, containerRef);

    return () => ctx.revert();
  }, []);

  // Select key years for 3D visualization
  const keyYears = [1955, 1965, 1975, 1985, 1995, 2005, 2015, 2024];
  const vizData = vietnamData.filter(d => keyYears.includes(d.year));
  
  const maxPop = Math.max(...vizData.map(d => d.population));
  const maxGDP = Math.max(...vizData.map(d => d.gdpBillion));

  // Mouse/Touch handlers for interactive 3D rotation
  const handleMouseDown = (e: React.MouseEvent) => {
    setIsDragging(true);
    setLastPos({ x: e.clientX, y: e.clientY });
  };

  const handleMouseMove = (e: React.MouseEvent) => {
    if (!isDragging) return;
    const deltaX = e.clientX - lastPos.x;
    const deltaY = e.clientY - lastPos.y;
    setRotation(prev => ({
      x: prev.x + deltaY * 0.5,
      y: prev.y + deltaX * 0.5
    }));
    setLastPos({ x: e.clientX, y: e.clientY });
  };

  const handleMouseUp = () => {
    setIsDragging(false);
  };

  const handleWheel = (e: React.WheelEvent) => {
    e.preventDefault();
    setZoom(prev => Math.max(0.5, Math.min(2, prev + (e.deltaY > 0 ? -0.1 : 0.1))));
  };

  const handleTouchStart = (e: React.TouchEvent) => {
    if (e.touches.length === 1) {
      setIsDragging(true);
      setLastPos({ x: e.touches[0].clientX, y: e.touches[0].clientY });
    }
  };

  const handleTouchMove = (e: React.TouchEvent) => {
    if (!isDragging || e.touches.length !== 1) return;
    const deltaX = e.touches[0].clientX - lastPos.x;
    const deltaY = e.touches[0].clientY - lastPos.y;
    setRotation(prev => ({
      x: prev.x + deltaY * 0.5,
      y: prev.y + deltaX * 0.5
    }));
    setLastPos({ x: e.touches[0].clientX, y: e.touches[0].clientY });
  };

  const handleTouchEnd = () => {
    setIsDragging(false);
  };

  return (
    <div ref={containerRef} className="min-h-screen py-20 px-6 relative overflow-hidden bg-gradient-to-br from-background via-primary/5 to-secondary/10">
      <div className="max-w-7xl mx-auto relative z-10">
        <div className="text-center mb-16">
          <Box className="viz3d-title w-16 h-16 text-primary mx-auto mb-6 animate-pulse" />
          <h2 className="viz3d-title font-display text-5xl md:text-6xl font-bold mb-4">
            Chiều Sâu <span className="text-primary dragon-glow">Phát Triển</span>
          </h2>
          <p className="viz3d-title text-xl text-muted-foreground">Trải nghiệm dữ liệu trong không gian 3D</p>
        </div>

        {/* 3D Bar Chart using CSS Transforms */}
        <div className="mb-16 perspective-1000">
          <div className="bg-card/30 backdrop-blur-sm p-12 rounded-2xl border border-border shadow-elegant transform-style-3d">
            <div className="flex items-center justify-between mb-4">
              <div className="text-xs text-muted-foreground bg-card/50 px-3 py-1 rounded-full">
                Kéo để xoay • Cuộn để zoom
              </div>
              <div className="text-xs text-muted-foreground bg-card/50 px-3 py-1 rounded-full">
                Zoom: {(zoom * 100).toFixed(0)}%
              </div>
            </div>
            <h3 className="text-2xl font-bold mb-8 text-center flex items-center justify-center gap-3">
              <TrendingUp className="w-6 h-6 text-primary" />
              Dân Số & GDP Qua Thời Gian (3D)
            </h3>
            
            <div 
              className="relative h-96 flex items-end justify-around gap-4 cursor-grab active:cursor-grabbing select-none" 
              style={{ 
                perspective: '1000px',
                transform: `scale(${zoom})`,
                transition: isDragging ? 'none' : 'transform 0.3s ease'
              }}
              onMouseDown={handleMouseDown}
              onMouseMove={handleMouseMove}
              onMouseUp={handleMouseUp}
              onMouseLeave={handleMouseUp}
              onWheel={handleWheel}
              onTouchStart={handleTouchStart}
              onTouchMove={handleTouchMove}
              onTouchEnd={handleTouchEnd}
            >
              <div style={{ 
                transform: `rotateX(${rotation.x}deg) rotateY(${rotation.y}deg)`,
                transformStyle: 'preserve-3d',
                width: '100%',
                height: '100%',
                display: 'flex',
                alignItems: 'flex-end',
                justifyContent: 'space-around',
                gap: '1rem',
                transition: isDragging ? 'none' : 'transform 0.3s ease'
              }}>
              {vizData.map((d, idx) => {
                const popHeight = (d.population / maxPop) * 100;
                const gdpHeight = (d.gdpBillion / maxGDP) * 100;
                const isHovered = hoveredBar === idx;
                
                return (
                  <div 
                    key={d.year}
                    className="viz3d-bar flex flex-col items-center gap-2 flex-1 max-w-24"
                    onMouseEnter={() => setHoveredBar(idx)}
                    onMouseLeave={() => setHoveredBar(null)}
                  >
                    {/* GDP Bar (Back) */}
                    <div 
                      className="w-full relative transition-all duration-500 cursor-pointer"
                      style={{ 
                        height: `${gdpHeight * 3}px`,
                        transform: isHovered ? 'translateZ(30px) scale(1.1)' : 'translateZ(-20px) rotateY(-15deg)',
                        transformStyle: 'preserve-3d',
                      }}
                    >
                      <div 
                        className="absolute inset-0 rounded-t-lg bg-gradient-to-t from-secondary/80 to-secondary border-2 border-secondary/50 shadow-lg"
                        style={{
                          boxShadow: isHovered ? '0 10px 40px rgba(147, 197, 253, 0.5)' : '0 5px 20px rgba(147, 197, 253, 0.3)'
                        }}
                      />
                      {/* Top face */}
                      <div 
                        className="absolute top-0 left-0 right-0 h-4 bg-secondary/90 rounded-t-lg"
                        style={{ transform: 'rotateX(90deg) translateZ(2px)', transformOrigin: 'top' }}
                      />
                    </div>

                    {/* Population Bar (Front) */}
                    <div 
                      className="w-full relative transition-all duration-500 cursor-pointer -mt-2"
                      style={{ 
                        height: `${popHeight * 3}px`,
                        transform: isHovered ? 'translateZ(50px) scale(1.15)' : 'translateZ(0px)',
                        transformStyle: 'preserve-3d',
                      }}
                    >
                      <div 
                        className="absolute inset-0 rounded-t-lg bg-gradient-to-t from-primary/80 to-primary border-2 border-primary/50 shadow-lg"
                        style={{
                          boxShadow: isHovered ? '0 10px 40px rgba(212, 175, 55, 0.5)' : '0 5px 20px rgba(212, 175, 55, 0.3)'
                        }}
                      />
                      {/* Top face */}
                      <div 
                        className="absolute top-0 left-0 right-0 h-4 bg-primary/90 rounded-t-lg"
                        style={{ transform: 'rotateX(90deg) translateZ(2px)', transformOrigin: 'top' }}
                      />
                    </div>

                    {/* Year Label */}
                    <div className={`text-center font-bold transition-all duration-300 ${isHovered ? 'text-primary scale-110' : 'text-muted-foreground'}`}>
                      {d.year}
                    </div>

                    {/* Tooltip on Hover */}
                    {isHovered && (
                      <div className="absolute -top-20 left-1/2 -translate-x-1/2 bg-card/95 backdrop-blur-md border border-primary/30 rounded-xl p-4 shadow-lg z-50 whitespace-nowrap animate-scale-in">
                        <div className="text-sm font-semibold mb-2 text-primary">Năm {d.year}</div>
                        <div className="text-xs text-muted-foreground space-y-1">
                          <div>Dân số: {(d.population / 1000000).toFixed(1)}M</div>
                          <div>GDP: ${d.gdpBillion}B</div>
                        </div>
                      </div>
                    )}
                  </div>
                );
              })}
              </div>
            </div>

            {/* Legend */}
            <div className="flex justify-center gap-8 mt-8">
              <div className="flex items-center gap-2">
                <div className="w-4 h-4 bg-primary rounded"></div>
                <span className="text-sm text-muted-foreground">Dân số</span>
              </div>
              <div className="flex items-center gap-2">
                <div className="w-4 h-4 bg-secondary rounded"></div>
                <span className="text-sm text-muted-foreground">GDP</span>
              </div>
            </div>
          </div>
        </div>

        {/* 3D Layered Stats */}
        <div className="perspective-1000">
          <h3 className="text-2xl font-bold mb-8 text-center flex items-center justify-center gap-3">
            <Layers className="w-6 h-6 text-secondary" />
            Tầng Lớp Phát Triển
          </h3>
          
          <div className="relative h-96" style={{ transformStyle: 'preserve-3d' }}>
            {/* Layer 1 - Economic */}
            <div 
              className="viz3d-layer absolute inset-0 bg-gradient-to-br from-primary/20 to-primary/5 backdrop-blur-sm p-8 rounded-2xl border border-primary/30 shadow-elegant"
              style={{ transform: 'translateZ(0px)' }}
            >
              <div className="text-xl font-bold text-primary mb-4">Tầng Kinh Tế</div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <div className="text-3xl font-bold text-primary">${vizData[vizData.length - 1].gdpBillion}B</div>
                  <div className="text-sm text-muted-foreground">GDP 2024</div>
                </div>
                <div>
                  <div className="text-3xl font-bold text-primary">{vizData[vizData.length - 1].gdpGrowthRate}%</div>
                  <div className="text-sm text-muted-foreground">Tăng trưởng</div>
                </div>
              </div>
            </div>

            {/* Layer 2 - Social */}
            <div 
              className="viz3d-layer absolute inset-0 bg-gradient-to-br from-secondary/20 to-secondary/5 backdrop-blur-sm p-8 rounded-2xl border border-secondary/30 shadow-elegant"
              style={{ transform: 'translateZ(-50px) translateY(20px)' }}
            >
              <div className="text-xl font-bold text-secondary mb-4">Tầng Xã Hội</div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <div className="text-3xl font-bold text-secondary">{vizData[vizData.length - 1].urbanPopPercent}%</div>
                  <div className="text-sm text-muted-foreground">Đô thị hóa</div>
                </div>
                <div>
                  <div className="text-3xl font-bold text-secondary">{vizData[vizData.length - 1].literacyRate}%</div>
                  <div className="text-sm text-muted-foreground">Biết chữ</div>
                </div>
              </div>
            </div>

            {/* Layer 3 - Demographic */}
            <div 
              className="viz3d-layer absolute inset-0 bg-gradient-to-br from-accent/20 to-accent/5 backdrop-blur-sm p-8 rounded-2xl border border-accent/30 shadow-elegant"
              style={{ transform: 'translateZ(-100px) translateY(40px)' }}
            >
              <div className="text-xl font-bold text-accent mb-4">Tầng Dân Số</div>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <div className="text-3xl font-bold text-accent">{(vizData[vizData.length - 1].population / 1000000).toFixed(1)}M</div>
                  <div className="text-sm text-muted-foreground">Dân số</div>
                </div>
                <div>
                  <div className="text-3xl font-bold text-accent">{vizData[vizData.length - 1].medianAge}</div>
                  <div className="text-sm text-muted-foreground">Tuổi trung vị</div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Insight */}
        <div className="mt-16 bg-gradient-to-r from-primary/10 via-secondary/10 to-accent/10 backdrop-blur-sm p-8 rounded-2xl border border-primary/30">
          <div className="flex items-start gap-4">
            <Box className="w-8 h-8 text-primary flex-shrink-0 mt-1" />
            <div>
              <h3 className="text-2xl font-bold mb-3 text-primary">Khám Phá Chiều Sâu Dữ Liệu</h3>
              <p className="text-lg text-muted-foreground leading-relaxed">
                Visualization 3D giúp chúng ta nhìn thấy sự phát triển từ nhiều góc độ khác nhau. Mỗi tầng lớp đại diện cho một khía cạnh: 
                kinh tế, xã hội, và dân số. Khi nhìn từ trên xuống, ta thấy sự tăng trưởng liên tục qua các thập kỷ. 
                Từ {(vizData[0].population / 1000000).toFixed(1)}M dân (1955) lên {(vizData[vizData.length - 1].population / 1000000).toFixed(1)}M (2024), 
                từ ${vizData[0].gdpBillion}B lên ${vizData[vizData.length - 1].gdpBillion}B GDP - một hành trình đầy ấn tượng.
              </p>
            </div>
          </div>
        </div>
      </div>

      <style>{`
        .perspective-1000 {
          perspective: 1000px;
        }
        .transform-style-3d {
          transform-style: preserve-3d;
        }
      `}</style>
    </div>
  );
};
