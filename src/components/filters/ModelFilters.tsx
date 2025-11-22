'use client';

import { useEffect, useState } from 'react';
import { useFilterStore } from '@/store/useFilterStore';
import { Category } from '@/types';

interface ModelFiltersProps {
  categories: Category[];
  availableTags: string[];
}

export function ModelFilters({ categories, availableTags }: ModelFiltersProps) {
  const {
    category,
    tags,
    minPrice,
    maxPrice,
    search,
    featured,
    setCategory,
    setTags,
    setPriceRange,
    setSearch,
    setFeatured,
    reset,
  } = useFilterStore();

  const [localSearch, setLocalSearch] = useState(search || '');

  useEffect(() => {
    const timer = setTimeout(() => {
      setSearch(localSearch);
    }, 500);
    return () => clearTimeout(timer);
  }, [localSearch, setSearch]);

  const handleTagToggle = (tag: string) => {
    const newTags = tags?.includes(tag)
      ? tags.filter((t) => t !== tag)
      : [...(tags || []), tag];
    setTags(newTags);
  };

  return (
    <div id="model-filters" className="model-filters bg-white/80 backdrop-blur-sm rounded-2xl shadow-lg border border-white/20 p-6 space-y-6 sticky top-28">
      <div className="filters-header flex items-center justify-between">
        <h3 className="text-xl font-bold text-slate-800 flex items-center gap-2">
          <span className="w-2 h-2 bg-gradient-primary rounded-full"></span>
          Filters
        </h3>
        <button
          onClick={reset}
          className="text-sm text-indigo-600 hover:text-indigo-800 font-semibold px-3 py-1.5 bg-indigo-50 rounded-full hover:bg-indigo-100 transition-colors"
        >
          Reset All
        </button>
      </div>

      {/* Search */}
      <div id="filter-search" className="filter-search">
        <label htmlFor="search-input" className="search-label block text-sm font-semibold text-slate-700 mb-3">
          🔍 Search
        </label>
        <div className="search-input-wrapper relative">
          <input
            id="search-input"
            type="text"
            value={localSearch}
            onChange={(e) => setLocalSearch(e.target.value)}
            placeholder="Search models..."
            aria-label="Search models"
            className="search-input w-full px-4 py-3 bg-white/60 border border-white/30 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-transparent backdrop-blur-sm transition-all duration-200 font-medium placeholder-slate-400"
          />
          <div className="absolute right-3 top-1/2 transform -translate-y-1/2 text-slate-400">
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
          </div>
        </div>
      </div>

      {/* Featured */}
      <div id="filter-featured" className="filter-featured">
        <label htmlFor="featured-checkbox" className="featured-label flex items-center gap-3 cursor-pointer p-3 bg-amber-50/80 rounded-xl border border-amber-100 hover:bg-amber-50 transition-colors">
          <input
            id="featured-checkbox"
            type="checkbox"
            checked={featured || false}
            onChange={(e) => setFeatured(e.target.checked ? true : undefined)}
            aria-label="Show featured models only"
            className="featured-checkbox w-5 h-5 text-amber-600 rounded-lg focus:ring-2 focus:ring-amber-500 border-amber-300"
          />
          <span className="text-sm font-semibold text-amber-800 flex items-center gap-1">
            ⭐ Featured Models Only
          </span>
        </label>
      </div>

      {/* Categories */}
      <div id="filter-category" className="filter-category">
        <label htmlFor="category-select" className="category-label block text-sm font-semibold text-slate-700 mb-3">
          📁 Category
        </label>
        <select
          id="category-select"
          value={category || ''}
          onChange={(e) => setCategory(e.target.value || undefined)}
          aria-label="Filter by category"
          className="category-select w-full px-4 py-3 bg-white/60 border border-white/30 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-transparent backdrop-blur-sm font-medium text-slate-700 appearance-none cursor-pointer"
          style={{
            backgroundImage: `url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 20 20'%3e%3cpath stroke='%236b7280' stroke-linecap='round' stroke-linejoin='round' stroke-width='1.5' d='m6 8 4 4 4-4'/%3e%3c/svg%3e")`,
            backgroundPosition: 'right 0.75rem center',
            backgroundRepeat: 'no-repeat',
            backgroundSize: '1.25rem'
          }}
        >
          <option value="">All Categories</option>
          {categories.map((cat) => (
            <option key={cat.id} value={cat.slug}>
              {cat.name}
            </option>
          ))}
        </select>
      </div>

      {/* Price Range */}
      <div id="filter-price" className="filter-price">
        <label className="price-label block text-sm font-semibold text-slate-700 mb-3">
          💰 Price Range
        </label>
        <div className="price-inputs grid grid-cols-2 gap-3">
          <input
            type="number"
            value={minPrice || ''}
            onChange={(e) => setPriceRange(parseFloat(e.target.value) || undefined, maxPrice)}
            placeholder="Min $"
            className="px-4 py-3 bg-white/60 border border-white/30 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-transparent backdrop-blur-sm font-medium placeholder-slate-400"
          />
          <input
            type="number"
            value={maxPrice || ''}
            onChange={(e) => setPriceRange(minPrice, parseFloat(e.target.value) || undefined)}
            placeholder="Max $"
            className="px-4 py-3 bg-white/60 border border-white/30 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-transparent backdrop-blur-sm font-medium placeholder-slate-400"
          />
        </div>
      </div>

      {/* Tags */}
      {availableTags.length > 0 && (
        <div id="filter-tags" className="filter-tags">
          <label className="tags-label block text-sm font-semibold text-slate-700 mb-3">
            🏷️ Tags
          </label>
          <div className="tags-buttons flex flex-wrap gap-2">
            {availableTags.map((tag) => (
              <button
                key={tag}
                onClick={() => handleTagToggle(tag)}
                className={`px-3 py-2 text-sm font-medium rounded-full transition-all duration-200 transform hover:-translate-y-0.5 ${
                  tags?.includes(tag)
                    ? 'bg-gradient-primary text-white shadow-lg'
                    : 'bg-white/60 text-slate-600 border border-white/30 hover:bg-white hover:shadow-md backdrop-blur-sm'
                }`}
              >
                {tag}
              </button>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}

