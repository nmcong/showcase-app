'use client';

import { useEffect, useState } from 'react';
import { ModelCard } from './ModelCard';
import { Model } from '@/types';
import { useFilterStore } from '@/store/useFilterStore';

export function ModelGrid() {
  const [models, setModels] = useState<Model[]>([]);
  const [loading, setLoading] = useState(true);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const filters = useFilterStore();

  useEffect(() => {
    const fetchModels = async () => {
      setLoading(true);
      try {
        // Fetch models from config.json
        const response = await fetch('/models/config.json');
        const config = await response.json();
        let filteredModels = config.models || [];

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
          filteredModels = filteredModels.filter((m: any) =>
            m.title?.toLowerCase().includes(searchLower) ||
            m.description?.toLowerCase().includes(searchLower) ||
            m.tags?.some((tag: string) => tag.toLowerCase().includes(searchLower))
          );
        }

        if (filters.featured) {
          filteredModels = filteredModels.filter((m: any) => m.featured === true);
        }

        // Convert to Model type
        const mappedModels: Model[] = filteredModels.map((m: any) => ({
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

        // Pagination
        const itemsPerPage = 9;
        const startIndex = (page - 1) * itemsPerPage;
        const endIndex = startIndex + itemsPerPage;
        const paginatedModels = mappedModels.slice(startIndex, endIndex);

        setModels(paginatedModels);
        setTotalPages(Math.ceil(mappedModels.length / itemsPerPage));
      } catch (error) {
        console.error('Error fetching models:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchModels();
  }, [filters, page]);

  if (loading) {
    return (
      <div className="flex items-center justify-center py-20">
        <div className="text-center">
          <div className="relative">
            <div className="animate-spin rounded-full h-16 w-16 border-4 border-indigo-500/30 border-t-indigo-500 mx-auto"></div>
            <div className="animate-ping absolute inset-0 rounded-full h-16 w-16 border-4 border-indigo-500 opacity-20"></div>
          </div>
          <p className="mt-6 text-slate-300 text-lg font-medium">Loading amazing 3D models...</p>
          <p className="text-slate-500 text-sm">This won&apos;t take long</p>
        </div>
      </div>
    );
  }

  if (models.length === 0) {
    return (
      <div className="text-center py-20">
        <div className="bg-slate-900/50 backdrop-blur-sm rounded-2xl p-12 border border-white/10 shadow-2xl max-w-md mx-auto">
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
    <div>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        {models.map((model, index) => (
          <div
            key={model.id}
            className="animate-fadeInUp"
            style={{
              animationDelay: `${index * 0.1}s`,
              animationFillMode: 'both'
            }}
          >
            <ModelCard model={model} />
          </div>
        ))}
      </div>

      {/* Pagination */}
      {totalPages > 1 && (
        <div className="flex justify-center items-center gap-3 mt-12">
          <button
            onClick={() => setPage((p) => Math.max(1, p - 1))}
            disabled={page === 1}
            className="px-6 py-3 bg-slate-900/50 backdrop-blur-sm border border-white/10 rounded-xl disabled:opacity-50 disabled:cursor-not-allowed hover:bg-slate-900/70 hover:shadow-lg transition-all duration-200 font-medium text-slate-300 transform hover:-translate-y-0.5"
          >
            ← Previous
          </button>
          
          <div className="flex items-center gap-2">
            {Array.from({ length: Math.min(5, totalPages) }, (_, i) => {
              const pageNum = i + 1;
              return (
                <button
                  key={pageNum}
                  onClick={() => setPage(pageNum)}
                  className={`px-4 py-3 rounded-xl font-medium transition-all duration-200 transform hover:-translate-y-0.5 ${
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
        </div>
      )}
    </div>
  );
}
