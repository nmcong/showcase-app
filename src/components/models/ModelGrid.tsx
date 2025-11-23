'use client';

import { useEffect, useState, useRef } from 'react';
import { ModelCard } from './ModelCard';
import { Model } from '@/types';
import { useFilterStore } from '@/store/useFilterStore';

export function ModelGrid() {
  const [models, setModels] = useState<Model[]>([]);
  const [allModels, setAllModels] = useState<Model[]>([]);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [shouldAnimate, setShouldAnimate] = useState(true);
  const [isInitialized, setIsInitialized] = useState(false);
  const filters = useFilterStore();

  // Load all models once on mount
  useEffect(() => {
    const loadModels = async () => {
      try {
        const response = await fetch('/models/config.json');
        const config = await response.json();
        
        // Map to Model type
        const mappedModels: Model[] = (config.models || []).map((m: any) => ({
          id: m.id,
          title: m.title,
          slug: m.slug,
          description: m.description,
          thumbnailUrl: m.thumbnail || '/placeholder-model.jpg',
          modelUrl: m.modelPath,
          tags: m.tags || [],
          views: 0,
          featured: m.featured || false,
          published: true,
          categoryId: m.category,
          category: {
            id: m.category,
            name: m.category,
            slug: m.category.toLowerCase(),
            createdAt: new Date(),
            updatedAt: new Date(),
          },
          unrealMarketUrl: m.unrealMarketUrl,
          unityMarketUrl: m.unityMarketUrl,
          createdAt: new Date(),
          updatedAt: new Date(),
        }));

        setAllModels(mappedModels);
        setIsInitialized(true);
      } catch (error) {
        console.error('Error loading models:', error);
        setAllModels([]);
        setIsInitialized(true);
      }
    };

    loadModels();
  }, []);

  // Filter and paginate models
  useEffect(() => {
    if (!isInitialized) return;

    const filterModels = () => {
      try {
        let filteredModels = [...allModels];

        // Apply filters
        if (filters.category) {
          filteredModels = filteredModels.filter((m: any) => 
            m.category?.toLowerCase() === filters.category?.toLowerCase()
          );
        }

        if (filters.tags && filters.tags.length > 0) {
          filteredModels = filteredModels.filter((m: any) =>
            filters.tags?.some(tag => m.tags?.includes(tag))
          );
        }

        if (filters.search) {
          const searchLower = filters.search.toLowerCase();
          filteredModels = filteredModels.filter((m) =>
            m.title?.toLowerCase().includes(searchLower) ||
            m.description?.toLowerCase().includes(searchLower) ||
            m.tags?.some((tag: string) => tag.toLowerCase().includes(searchLower))
          );
        }

        if (filters.featured) {
          filteredModels = filteredModels.filter((m) => m.featured === true);
        }

        // Pagination
        const itemsPerPage = 9;
        const startIndex = (page - 1) * itemsPerPage;
        const endIndex = startIndex + itemsPerPage;
        const paginatedModels = filteredModels.slice(startIndex, endIndex);

        setModels(paginatedModels);
        setTotalPages(Math.ceil(filteredModels.length / itemsPerPage));
      } catch (error) {
        console.error('Error filtering models:', error);
        setModels([]);
      }
    };

    filterModels();
  }, [filters, page, allModels, isInitialized]);

  // Disable animation after first load to prevent re-triggering
  useEffect(() => {
    if (shouldAnimate && models.length > 0) {
      // Wait for animation to complete (longest delay + animation duration)
      const maxDelay = (models.length - 1) * 0.1;
      const animationDuration = 0.6;
      const totalTime = (maxDelay + animationDuration) * 1000;
      
      const timer = setTimeout(() => {
        setShouldAnimate(false);
      }, totalTime);

      return () => clearTimeout(timer);
    }
  }, [shouldAnimate, models.length]);

  // Don't show "no models" until initialized
  if (!isInitialized) {
    return null;
  }

  if (models.length === 0) {
    return (
      <div id="grid-empty" className="grid-empty text-center py-20">
        <div className="empty-state-card bg-slate-900/50 backdrop-blur-sm rounded-2xl p-12 border border-white/10 shadow-2xl max-w-md mx-auto">
          <div className="w-20 h-20 bg-gradient-to-r from-slate-800 to-slate-700 rounded-full flex items-center justify-center mx-auto mb-6">
            <span className="text-slate-400 text-3xl">🔍</span>
          </div>
          <h3 className="text-xl font-bold text-white mb-3">No models found</h3>
          <p className="text-slate-400 mb-6">We couldn&apos;t find any models matching your current filters.</p>
          <button
            onClick={() => useFilterStore.getState().reset()}
            className="px-8 py-3 bg-gradient-to-r from-indigo-600 to-purple-600 text-white rounded-xl hover:shadow-lg hover:shadow-indigo-500/50 transition-all duration-200 font-semibold transform hover:-translate-y-0.5"
          >
            Clear All Filters
          </button>
        </div>
      </div>
    );
  }

  return (
    <div id="models-grid-wrapper" className="models-grid-wrapper">
      <div id="models-grid" className="models-grid grid grid-cols-1 lg:grid-cols-2 gap-6 lg:gap-8" style={{ gridAutoRows: '1fr' }}>
        {models.map((model, index) => {
          // Only the first featured model gets large layout (full width on desktop)
          const isFeaturedLarge = model.featured && index === models.findIndex(m => m.featured);
          
          return (
          <div
            key={model.id}
              className={`grid-item h-full ${isFeaturedLarge ? 'lg:col-span-2' : ''} ${shouldAnimate ? 'animate-fadeInUp' : ''}`}
              data-model-index={index}
              data-featured={isFeaturedLarge}
            style={{
                animationDelay: shouldAnimate ? `${index * 0.1}s` : undefined,
                opacity: !shouldAnimate ? 1 : undefined,
                transform: !shouldAnimate ? 'translateY(0)' : undefined
            }}
          >
              <ModelCard model={model} isFeaturedLarge={isFeaturedLarge} />
          </div>
          );
        })}
      </div>

      {/* Pagination */}
      {totalPages > 1 && (
        <nav id="pagination" className="pagination flex justify-center items-center gap-3 mt-12" aria-label="Models pagination">
          <button
            onClick={() => setPage((p) => Math.max(1, p - 1))}
            disabled={page === 1}
            className="px-6 py-3 bg-slate-900/50 backdrop-blur-sm border border-white/10 rounded-xl disabled:opacity-50 disabled:cursor-not-allowed hover:bg-slate-900/70 hover:shadow-lg transition-all duration-200 font-medium text-slate-300 transform hover:-translate-y-0.5"
          >
            ← Previous
          </button>
          
          <div className="pagination-numbers flex items-center gap-2">
            {Array.from({ length: Math.min(5, totalPages) }, (_, i) => {
              const pageNum = i + 1;
              return (
                <button
                  key={pageNum}
                  onClick={() => setPage(pageNum)}
                  aria-label={`Page ${pageNum}`}
                  aria-current={page === pageNum ? 'page' : undefined}
                  className={`page-button px-4 py-3 rounded-xl font-medium transition-all duration-200 transform hover:-translate-y-0.5 ${
                    page === pageNum
                      ? 'bg-gradient-to-r from-indigo-600 to-purple-600 text-white shadow-lg shadow-indigo-500/50'
                      : 'bg-slate-900/50 backdrop-blur-sm border border-white/10 text-slate-300 hover:bg-slate-900/70 hover:shadow-lg'
                  }`}
                >
                  {pageNum}
                </button>
              );
            })}
          </div>

          <button
            onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
            disabled={page === totalPages}
            className="px-6 py-3 bg-slate-900/50 backdrop-blur-sm border border-white/10 rounded-xl disabled:opacity-50 disabled:cursor-not-allowed hover:bg-slate-900/70 hover:shadow-lg transition-all duration-200 font-medium text-slate-300 transform hover:-translate-y-0.5"
          >
            Next →
          </button>
        </nav>
      )}
    </div>
  );
}
