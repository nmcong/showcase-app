'use client';

import { useEffect, useState } from 'react';
import { ModelCard } from './ModelCard';
import { Model } from '@/types';
import { useFilterStore } from '@/store/useFilterStore';
import axios from 'axios';

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
        const params = new URLSearchParams();
        if (filters.category) params.append('category', filters.category);
        if (filters.tags && filters.tags.length > 0)
          params.append('tags', filters.tags.join(','));
        if (filters.minPrice) params.append('minPrice', filters.minPrice.toString());
        if (filters.maxPrice) params.append('maxPrice', filters.maxPrice.toString());
        if (filters.search) params.append('search', filters.search);
        if (filters.featured) params.append('featured', 'true');
        params.append('page', page.toString());

        const response = await axios.get(`/api/models?${params.toString()}`);
        setModels(response.data.models);
        setTotalPages(response.data.pagination.totalPages);
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
            <div className="animate-spin rounded-full h-16 w-16 border-4 border-indigo-200 border-t-indigo-600 mx-auto"></div>
            <div className="animate-ping absolute inset-0 rounded-full h-16 w-16 border-4 border-indigo-400 opacity-20"></div>
          </div>
          <p className="mt-6 text-slate-600 text-lg font-medium">Loading amazing 3D models...</p>
          <p className="text-slate-400 text-sm">This won&apos;t take long</p>
        </div>
      </div>
    );
  }

  if (models.length === 0) {
    return (
      <div className="text-center py-20">
        <div className="bg-white/60 backdrop-blur-sm rounded-2xl p-12 border border-white/20 shadow-lg max-w-md mx-auto">
          <div className="w-20 h-20 bg-gradient-to-r from-slate-200 to-slate-300 rounded-full flex items-center justify-center mx-auto mb-6">
            <span className="text-slate-500 text-3xl">🔍</span>
          </div>
          <h3 className="text-xl font-bold text-slate-800 mb-3">No models found</h3>
          <p className="text-slate-600 mb-6">We couldn&apos;t find any models matching your current filters.</p>
          <button
            onClick={() => useFilterStore.getState().reset()}
            className="px-8 py-3 bg-gradient-primary text-white rounded-xl hover:shadow-lg transition-all duration-200 font-semibold transform hover:-translate-y-0.5"
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
            className="px-6 py-3 bg-white/80 backdrop-blur-sm border border-white/20 rounded-xl disabled:opacity-50 disabled:cursor-not-allowed hover:bg-white hover:shadow-lg transition-all duration-200 font-medium text-slate-700 transform hover:-translate-y-0.5"
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
                      ? 'bg-gradient-primary text-white shadow-lg'
                      : 'bg-white/80 backdrop-blur-sm border border-white/20 text-slate-700 hover:bg-white hover:shadow-lg'
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
            className="px-6 py-3 bg-white/80 backdrop-blur-sm border border-white/20 rounded-xl disabled:opacity-50 disabled:cursor-not-allowed hover:bg-white hover:shadow-lg transition-all duration-200 font-medium text-slate-700 transform hover:-translate-y-0.5"
          >
            Next →
          </button>
        </div>
      )}
    </div>
  );
}

