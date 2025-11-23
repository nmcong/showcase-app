'use client';

import { useEffect, useState, useRef } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { ModelViewer } from '@/components/3d/ModelViewer';
import Link from 'next/link';
import Image from 'next/image';
import { ShoppingCart, Box, Star } from 'lucide-react';

interface ModelDetail {
  id: string;
  title: string;
  slug: string;
  description: string;
  category: string;
  tags: string[];
  thumbnail: string;
  modelPath: string;
  images?: string[];
  fabUrl?: string;
  unrealMarketUrl?: string;
  unityMarketUrl?: string;
  featured: boolean;
  stats?: {
    polygons: string;
    textures: string;
    fileSize: string;
  };
  features?: string[];
  technicalDetails?: {
    textureResolution?: string;
    textureFormats?: string[];
    uvMapping?: string;
    collisionMesh?: string;
  };
}

export default function ModelDetailPage() {
  const params = useParams();
  const router = useRouter();
  const [model, setModel] = useState<ModelDetail | null>(null);
  const [viewMode, setViewMode] = useState<'3d' | 'image'>('3d');
  const [selectedImageIndex, setSelectedImageIndex] = useState(0);
  const [canScrollLeft, setCanScrollLeft] = useState(false);
  const [canScrollRight, setCanScrollRight] = useState(false);
  const scrollContainerRef = useRef<HTMLDivElement>(null);
  const isDragging = useRef(false);
  const startX = useRef(0);
  const scrollLeftPos = useRef(0);

  useEffect(() => {
    const fetchModel = async () => {
      try {
        const response = await fetch('/models/config.json');
        const config = await response.json();
        const foundModel = config.models.find((m: any) => m.slug === params.slug);
        
        if (foundModel) {
          setModel(foundModel);
        } else {
          router.push('/');
        }
      } catch (error) {
        console.error('Error fetching model:', error);
        router.push('/');
      }
    };

    fetchModel();
  }, [params.slug, router]);

  // Check scroll position for arrow buttons
  const checkScrollPosition = () => {
    if (scrollContainerRef.current) {
      const { scrollLeft, scrollWidth, clientWidth } = scrollContainerRef.current;
      setCanScrollLeft(scrollLeft > 0);
      setCanScrollRight(scrollLeft < scrollWidth - clientWidth - 1);
    }
  };

  // Arrow button handlers
  const scrollToLeft = () => {
    if (scrollContainerRef.current) {
      scrollContainerRef.current.scrollBy({ left: -300, behavior: 'smooth' });
    }
  };

  const scrollToRight = () => {
    if (scrollContainerRef.current) {
      scrollContainerRef.current.scrollBy({ left: 300, behavior: 'smooth' });
    }
  };

  // Drag to scroll handlers
  const handleMouseDown = (e: React.MouseEvent<HTMLDivElement>) => {
    if (!scrollContainerRef.current) return;
    isDragging.current = true;
    startX.current = e.pageX - scrollContainerRef.current.offsetLeft;
    scrollLeftPos.current = scrollContainerRef.current.scrollLeft;
    scrollContainerRef.current.style.cursor = 'grabbing';
    scrollContainerRef.current.style.userSelect = 'none';
  };

  const handleMouseMove = (e: React.MouseEvent<HTMLDivElement>) => {
    if (!isDragging.current || !scrollContainerRef.current) return;
    e.preventDefault();
    const x = e.pageX - scrollContainerRef.current.offsetLeft;
    const walk = (x - startX.current) * 2; // Scroll speed multiplier
    scrollContainerRef.current.scrollLeft = scrollLeftPos.current - walk;
  };

  const handleMouseUp = () => {
    if (!scrollContainerRef.current) return;
    isDragging.current = false;
    scrollContainerRef.current.style.cursor = 'grab';
    scrollContainerRef.current.style.userSelect = 'auto';
  };

  const handleMouseLeave = () => {
    if (!scrollContainerRef.current) return;
    isDragging.current = false;
    scrollContainerRef.current.style.cursor = 'grab';
    scrollContainerRef.current.style.userSelect = 'auto';
  };

  // Set initial view mode based on available content
  useEffect(() => {
    if (model) {
      if (model.modelPath) {
        setViewMode('3d');
      } else if (model.images && model.images.length > 0) {
        setViewMode('image');
        setSelectedImageIndex(0);
      }
    }
  }, [model]);

  // Listen to scroll events to update arrow button states
  useEffect(() => {
    const container = scrollContainerRef.current;
    if (container) {
      checkScrollPosition();
      container.addEventListener('scroll', checkScrollPosition);
      window.addEventListener('resize', checkScrollPosition);
      
      return () => {
        container.removeEventListener('scroll', checkScrollPosition);
        window.removeEventListener('resize', checkScrollPosition);
      };
    }
  }, [model]);

  if (!model) {
    return null;
  }

  const allMedia = [
    ...(model.modelPath ? [{ type: '3d' as const, url: model.modelPath, label: '3D Model' }] : []),
    ...(model.images || []).map((img, idx) => ({ 
      type: 'image' as const, 
      url: img, 
      label: `View ${idx + 1}` 
    }))
  ];

  return (
    <div id="model-detail-page" className="model-detail-page min-h-screen lg:h-screen flex flex-col bg-gradient-to-br from-slate-950 via-slate-900 to-slate-950 overflow-auto lg:overflow-hidden">
      {/* JSON-LD Structured Data for Product */}
      {model && (
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{
            __html: JSON.stringify({
              "@context": "https://schema.org",
              "@type": "Product",
              "name": model.title,
              "description": model.description,
              "image": `https://3dmodels-showcase.com${model.thumbnail}`,
              "category": model.category,
              "brand": {
                "@type": "Brand",
                "name": "3D Models Showcase"
              },
              "offers": {
                "@type": "Offer",
                "url": model.fabUrl || `https://3dmodels-showcase.com/models/${model.slug}`,
                "priceCurrency": "USD",
                "availability": "https://schema.org/InStock",
                "seller": {
                  "@type": "Organization",
                  "name": "Fab.com"
                }
              },
              "aggregateRating": model.featured ? {
                "@type": "AggregateRating",
                "ratingValue": "5",
                "reviewCount": "1"
              } : undefined
            })
          }}
        />
      )}
      
      {/* Header - Fixed */}
      <header id="detail-header" className="detail-header glass-dark border-b border-white/10 flex-shrink-0">
        <div className="detail-header-container w-full max-w-[1612px] mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="detail-header-content flex items-center justify-between">
            <Link href="/" className="back-to-gallery-link flex items-center space-x-3 hover:opacity-80 transition-opacity">
              <div className="back-logo w-10 h-10 bg-gradient-to-br from-indigo-600 to-purple-600 rounded-xl flex items-center justify-center shadow-lg shadow-indigo-500/50">
                <span className="text-white font-bold text-lg">3D</span>
              </div>
              <span className="back-text text-xl font-bold text-white">← Back to Gallery</span>
            </Link>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main id="detail-main" className="detail-main flex-1 overflow-hidden lg:overflow-auto">
        <div className="detail-container w-full max-w-[1612px] mx-auto px-4 sm:px-6 lg:px-8 lg:h-full">
          <div className="detail-layout grid grid-cols-1 xl:grid-cols-3 gap-6 lg:h-full py-6">
            {/* Left: Preview Area */}
            <div id="preview-area" className="preview-area xl:col-span-2 flex flex-col gap-4 h-[600px] lg:h-auto xl:h-full">
              {/* Main Viewer - Takes remaining space */}
              <div id="model-viewer-container" className="model-viewer-container flex-1 bg-slate-900/50 backdrop-blur-sm rounded-2xl shadow-2xl border border-white/10 overflow-hidden">
                <div 
                  className="viewer-content relative w-full h-full"
                  onContextMenu={(e) => e.preventDefault()}
                  style={{ userSelect: 'none' }}
                >
                  {viewMode === '3d' && model.modelPath ? (
                    <ModelViewer 
                      modelUrl={model.modelPath} 
                      texturesPath="/models/KatanaBamboo"
                      enableTextureToggle={true}
                    />
                  ) : (
                    <div className="relative w-full h-full bg-gradient-to-br from-slate-900 to-slate-800 flex items-center justify-center p-4">
                      <Image
                        src={allMedia[selectedImageIndex].url}
                        alt={`${model.title} - ${allMedia[selectedImageIndex].label}`}
                        fill
                        className="object-contain"
                      />
                    </div>
                  )}
                </div>
              </div>

              {/* Gallery Thumbnails - Arrows + Drag to scroll */}
              <div id="gallery-thumbnails" className="gallery-thumbnails group flex-shrink-0 bg-slate-900/50 backdrop-blur-sm rounded-2xl shadow-xl border border-white/10 p-4 relative">
                {/* Left Arrow Button */}
                {canScrollLeft && (
                  <button
                    onClick={scrollToLeft}
                    className="gallery-arrow gallery-arrow-left absolute left-2 top-1/2 -translate-y-1/2 z-20 w-10 h-10 rounded-full bg-slate-800/90 backdrop-blur-sm border border-white/20 flex items-center justify-center transition-all duration-300 hover:bg-slate-700 hover:scale-110 hover:shadow-lg hover:shadow-indigo-500/30 opacity-70 hover:opacity-100 cursor-pointer"
                    aria-label="Scroll gallery left"
                  >
                    <svg className="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M15 19l-7-7 7-7" />
                    </svg>
                  </button>
                )}

                {/* Right Arrow Button */}
                {canScrollRight && (
                  <button
                    onClick={scrollToRight}
                    className="gallery-arrow gallery-arrow-right absolute right-2 top-1/2 -translate-y-1/2 z-20 w-10 h-10 rounded-full bg-slate-800/90 backdrop-blur-sm border border-white/20 flex items-center justify-center transition-all duration-300 hover:bg-slate-700 hover:scale-110 hover:shadow-lg hover:shadow-indigo-500/30 opacity-70 hover:opacity-100 cursor-pointer"
                    aria-label="Scroll gallery right"
                  >
                    <svg className="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M9 5l7 7-7 7" />
                    </svg>
                  </button>
                )}

                <div 
                  ref={scrollContainerRef}
                  onMouseDown={handleMouseDown}
                  onMouseMove={handleMouseMove}
                  onMouseUp={handleMouseUp}
                  onMouseLeave={handleMouseLeave}
                  className="thumbnails-scroll-container flex gap-4 overflow-x-auto pb-2 snap-x snap-mandatory cursor-grab active:cursor-grabbing" 
                  style={{ scrollbarWidth: 'thin', scrollbarColor: '#6366f1 transparent' }}
                >
                  {allMedia.map((media, idx) => (
                    <button
                      key={idx}
                      data-media-type={media.type}
                      data-media-index={idx}
                      onClick={() => {
                        if (!isDragging.current) {
                          setSelectedImageIndex(idx);
                          setViewMode(media.type === '3d' ? '3d' : 'image');
                        }
                      }}
                      className={`thumbnail-button flex-shrink-0 relative w-28 h-28 rounded-xl overflow-hidden transition-all duration-300 snap-start ${
                        selectedImageIndex === idx 
                          ? 'thumbnail-active' 
                          : 'thumbnail-inactive'
                      }`}
                      style={{ boxSizing: 'content-box' }}
                    >
                      {media.type === '3d' ? (
                        <div className="w-full h-full bg-gradient-to-br from-slate-800 to-slate-900 flex items-center justify-center">
                          <div className="text-center">
                            <Box className="w-8 h-8 text-white mx-auto" strokeWidth={2} />
                            <p className="text-white text-xs font-bold mt-1">3D Model</p>
                          </div>
                        </div>
                      ) : (
                        <Image
                          src={media.url}
                          alt={media.label}
                          fill
                          className="object-cover"
                        />
                      )}
                    </button>
                  ))}
                </div>
              </div>
            </div>

            {/* Right: Scrollable Details Sidebar */}
            <div id="details-sidebar" className="details-sidebar xl:col-span-1 overflow-visible xl:overflow-hidden">
              <div 
                className="sidebar-scroll-container xl:h-full overflow-visible xl:overflow-y-auto pr-2 space-y-4"
                style={{
                  scrollbarWidth: 'thin',
                  scrollbarColor: '#6366f1 transparent'
                }}
              >
                {/* Title */}
                <div id="model-title-section" className="model-title-section bg-slate-900/50 backdrop-blur-sm rounded-2xl shadow-xl border border-white/10 p-5">
                  {model.featured && (
                    <div className="inline-flex items-center gap-2 bg-gradient-to-r from-amber-400 to-orange-500 text-white text-sm font-bold px-4 py-2 rounded-full shadow-lg mb-3">
                      <Star className="w-4 h-4 fill-yellow-300 text-yellow-300" />
                      <span>Featured</span>
                    </div>
                  )}
                  <h1 className="text-2xl font-bold text-white mb-3">{model.title}</h1>
                  <div className="flex items-center gap-2">
                    <span className="inline-block bg-gradient-to-r from-indigo-600/20 to-purple-600/20 text-indigo-400 text-sm font-semibold px-4 py-2 rounded-full border border-indigo-500/30">
                      {model.category}
                    </span>
                  </div>
                </div>

                {/* Description */}
                <div id="model-description-section" className="model-description-section bg-slate-900/50 backdrop-blur-sm rounded-2xl shadow-xl border border-white/10 p-5">
                  <h2 className="section-title text-lg font-bold text-white mb-2">Description</h2>
                  <p className="section-content text-slate-300 leading-relaxed text-sm">{model.description}</p>
                </div>

                {/* Tags */}
                {model.tags && model.tags.length > 0 && (
                  <div id="model-tags-section" className="model-tags-section bg-slate-900/50 backdrop-blur-sm rounded-2xl shadow-xl border border-white/10 p-5">
                    <h2 className="section-title text-lg font-bold text-white mb-2">Tags</h2>
                    <div className="tags-container flex flex-wrap gap-2">
                      {model.tags.map((tag, index) => (
                        <span
                          key={index}
                          className="inline-block bg-slate-800 text-slate-300 text-xs font-medium px-3 py-1.5 rounded-full hover:bg-slate-700 transition-colors border border-white/5"
                        >
                          #{tag}
                        </span>
                      ))}
                    </div>
                  </div>
                )}

                {/* Stats */}
                {model.stats && (
                  <div id="model-stats-section" className="model-stats-section bg-slate-900/50 backdrop-blur-sm rounded-2xl shadow-xl border border-white/10 p-5">
                    <h2 className="section-title text-lg font-bold text-white mb-3">Statistics</h2>
                    <div className="stats-list space-y-2">
                      <div className="flex justify-between items-center p-3 bg-gradient-to-br from-blue-600/20 to-indigo-600/20 rounded-xl border border-blue-500/30">
                        <span className="text-sm text-slate-300 font-medium">Polygons</span>
                        <span className="text-base font-bold text-blue-400">{model.stats.polygons}</span>
                      </div>
                      <div className="flex justify-between items-center p-3 bg-gradient-to-br from-purple-600/20 to-pink-600/20 rounded-xl border border-purple-500/30">
                        <span className="text-sm text-slate-300 font-medium">Textures</span>
                        <span className="text-base font-bold text-purple-400">{model.stats.textures}</span>
                      </div>
                      <div className="flex justify-between items-center p-3 bg-gradient-to-br from-emerald-600/20 to-green-600/20 rounded-xl border border-emerald-500/30">
                        <span className="text-sm text-slate-300 font-medium">File Size</span>
                        <span className="text-base font-bold text-emerald-400">{model.stats.fileSize}</span>
                      </div>
                    </div>
                  </div>
                )}

                {/* Features */}
                {model.features && model.features.length > 0 && (
                  <div id="model-features-section" className="model-features-section bg-slate-900/50 backdrop-blur-sm rounded-2xl shadow-xl border border-white/10 p-5">
                    <h2 className="section-title text-lg font-bold text-white mb-3">Key Features</h2>
                    <ul className="features-list space-y-2">
                      {model.features.map((feature, index) => (
                        <li key={index} className="flex items-start gap-2">
                          <span className="text-green-400 text-lg mt-0.5 flex-shrink-0">✓</span>
                          <span className="text-slate-300 text-sm">{feature}</span>
                        </li>
                      ))}
                    </ul>
                  </div>
                )}

                {/* Technical Details */}
                {model.technicalDetails && (
                  <div id="model-technical-section" className="model-technical-section bg-slate-900/50 backdrop-blur-sm rounded-2xl shadow-xl border border-white/10 p-5">
                    <h2 className="section-title text-lg font-bold text-white mb-3">Technical Details</h2>
                    <div className="technical-details-list space-y-2 text-sm">
                      {model.technicalDetails.textureResolution && (
                        <div className="flex justify-between py-2 border-b border-white/5">
                          <span className="text-slate-400 font-medium">Texture Resolution:</span>
                          <span className="text-slate-200 font-semibold">{model.technicalDetails.textureResolution}</span>
                        </div>
                      )}
                      {model.technicalDetails.textureFormats && (
                        <div className="py-2 border-b border-white/5">
                          <span className="text-slate-400 font-medium block mb-2">Texture Formats:</span>
                          <div className="flex flex-wrap gap-2">
                            {model.technicalDetails.textureFormats.map((format, i) => (
                              <span key={i} className="bg-slate-800 text-slate-300 px-2 py-1 rounded text-xs border border-white/5">
                                {format}
                              </span>
                            ))}
                          </div>
                        </div>
                      )}
                      {model.technicalDetails.uvMapping && (
                        <div className="flex justify-between py-2 border-b border-white/5">
                          <span className="text-slate-400 font-medium">UV Mapping:</span>
                          <span className="text-slate-200 font-semibold">{model.technicalDetails.uvMapping}</span>
                        </div>
                      )}
                      {model.technicalDetails.collisionMesh && (
                        <div className="flex justify-between py-2">
                          <span className="text-slate-400 font-medium">Collision Mesh:</span>
                          <span className="text-slate-200 font-semibold">{model.technicalDetails.collisionMesh}</span>
                        </div>
                      )}
                    </div>
                  </div>
                )}

                {/* Purchase CTA - Sticky at bottom of sidebar scroll */}
                <div id="purchase-cta-section" className="purchase-cta-section xl:sticky xl:bottom-0 bg-gradient-to-t from-slate-950 via-slate-950 to-transparent pt-4 pb-2">
                  {model.fabUrl && (
                    <a
                      href={model.fabUrl}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="purchase-button block w-full bg-gradient-to-r from-indigo-600 to-purple-600 text-white text-center py-4 px-6 rounded-xl font-bold text-lg hover:shadow-2xl hover:shadow-indigo-500/50 transition-all duration-300 transform hover:-translate-y-1"
                    >
                      <div className="flex items-center justify-center gap-3">
                        <ShoppingCart className="w-6 h-6" />
                        <span>Get on Fab.com</span>
                      </div>
                      <div className="text-xs opacity-90 mt-1">View pricing & purchase</div>
                    </a>
                  )}
                </div>
              </div>
            </div>
          </div>
        </div>
      </main>

      {/* Custom scrollbar styles */}
      <style jsx global>{`
        /* Thumbnail styles */
        .thumbnail-button {
          border: 2px solid rgba(255, 255, 255, 0.1);
        }

        .thumbnail-button.thumbnail-active {
          border-color: #6366f1;
        }

        .thumbnail-button.thumbnail-inactive:hover {
          border-color: rgba(99, 102, 241, 0.5);
        }

        /* Horizontal scrollbar for gallery */
        .thumbnails-scroll-container::-webkit-scrollbar {
          height: 10px;
        }
        .thumbnails-scroll-container::-webkit-scrollbar-track {
          background: rgba(30, 41, 59, 0.5);
          border-radius: 5px;
        }
        .thumbnails-scroll-container::-webkit-scrollbar-thumb {
          background: linear-gradient(90deg, #6366f1, #8b5cf6);
          border-radius: 5px;
          border: 2px solid rgba(30, 41, 59, 0.5);
        }
        .thumbnails-scroll-container::-webkit-scrollbar-thumb:hover {
          background: linear-gradient(90deg, #4f46e5, #7c3aed);
        }

        /* Smooth scrolling for gallery */
        .thumbnails-scroll-container {
          scroll-behavior: smooth;
        }

        /* Vertical scrollbar for sidebar */
        .overflow-y-auto::-webkit-scrollbar {
          width: 8px;
        }
        .overflow-y-auto::-webkit-scrollbar-track {
          background: transparent;
        }
        .overflow-y-auto::-webkit-scrollbar-thumb {
          background: #6366f1;
          border-radius: 4px;
        }
        .overflow-y-auto::-webkit-scrollbar-thumb:hover {
          background: #4f46e5;
        }
      `}</style>
    </div>
  );
}
