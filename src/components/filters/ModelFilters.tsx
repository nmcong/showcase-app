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
    <div id="model-filters" className="model-filters bg-slate-900/50 backdrop-blur-sm rounded-2xl shadow-2xl border border-white/10 p-6 space-y-6 sticky top-28">
      <div className="filters-header flex items-center justify-between mb-2">
        <h3 className="text-xl font-bold text-white flex items-center gap-3">
          <span className="w-10 h-10 bg-gradient-to-br from-indigo-600 to-purple-600 rounded-xl flex items-center justify-center shadow-lg shadow-indigo-500/30">
            <svg className="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 4a1 1 0 011-1h16a1 1 0 011 1v2.586a1 1 0 01-.293.707l-6.414 6.414a1 1 0 00-.293.707V17l-4 4v-6.586a1 1 0 00-.293-.707L3.293 7.293A1 1 0 013 6.586V4z" />
            </svg>
          </span>
          <span className="bg-gradient-to-r from-indigo-400 to-purple-400 bg-clip-text text-transparent">Filters</span>
        </h3>
        <button
          onClick={reset}
          className="text-sm text-slate-300 hover:text-white font-semibold px-4 py-2 bg-slate-800/50 rounded-xl hover:bg-slate-800 transition-all duration-200 border border-white/10 hover:border-indigo-500/50 hover:shadow-lg hover:shadow-indigo-500/20"
        >
          Reset
        </button>
      </div>

      {/* Search */}
      <div id="filter-search" className="filter-search">
        <label htmlFor="search-input" className="search-label block text-sm font-bold text-slate-300 mb-3 flex items-center gap-2">
          <svg className="w-4 h-4 text-indigo-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
          </svg>
          Search Models
        </label>
        <div className="search-input-wrapper relative">
          <input
            id="search-input"
            type="text"
            value={localSearch}
            onChange={(e) => setLocalSearch(e.target.value)}
            placeholder="Type to search..."
            aria-label="Search models"
            className="search-input w-full px-4 py-3 pl-11 bg-slate-800/50 border border-white/10 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500/50 focus:bg-slate-800 transition-all duration-200 font-medium placeholder-slate-500 text-slate-200"
          />
          <div className="absolute left-3 top-1/2 transform -translate-y-1/2 text-slate-500">
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
            </svg>
          </div>
        </div>
      </div>

      {/* Featured */}
      <div id="filter-featured" className="filter-featured">
        <label htmlFor="featured-checkbox" className="featured-label flex items-center gap-3 cursor-pointer p-4 bg-gradient-to-r from-amber-600/10 to-orange-600/10 rounded-xl border border-amber-500/30 hover:border-amber-500/50 hover:bg-gradient-to-r hover:from-amber-600/20 hover:to-orange-600/20 transition-all duration-200 group">
          <input
            id="featured-checkbox"
            type="checkbox"
            checked={featured || false}
            onChange={(e) => setFeatured(e.target.checked ? true : undefined)}
            aria-label="Show featured models only"
            className="featured-checkbox w-5 h-5 text-amber-500 bg-slate-800 rounded-lg focus:ring-2 focus:ring-amber-500 border-amber-500/50 cursor-pointer"
          />
          <span className="text-sm font-bold text-amber-400 group-hover:text-amber-300 transition-colors">
            Featured Only
          </span>
        </label>
      </div>

      {/* Categories */}
      <div id="filter-category" className="filter-category">
        <label className="category-label block text-sm font-bold text-slate-300 mb-3 flex items-center gap-2">
          <svg className="w-4 h-4 text-indigo-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z" />
          </svg>
          Category
        </label>
        <div className="category-options space-y-2">
          <button
            onClick={() => setCategory(undefined)}
            className={`w-full px-4 py-3 rounded-xl font-semibold text-sm transition-all duration-200 border text-left ${
              !category
                ? 'bg-gradient-to-r from-indigo-600 to-purple-600 text-white shadow-lg shadow-indigo-500/30 border-indigo-500/50'
                : 'bg-slate-800/50 text-slate-300 border-white/10 hover:bg-slate-800 hover:border-indigo-500/30 hover:text-white'
            }`}
        >
            All Categories
          </button>
          {categories.map((cat) => (
            <button
              key={cat.id}
              onClick={() => setCategory(cat.slug)}
              className={`w-full px-4 py-3 rounded-xl font-semibold text-sm transition-all duration-200 border text-left ${
                category === cat.slug
                  ? 'bg-gradient-to-r from-indigo-600 to-purple-600 text-white shadow-lg shadow-indigo-500/30 border-indigo-500/50'
                  : 'bg-slate-800/50 text-slate-300 border-white/10 hover:bg-slate-800 hover:border-indigo-500/30 hover:text-white'
              }`}
            >
              {cat.name}
            </button>
          ))}
        </div>
      </div>

      {/* Tags */}
      {availableTags.length > 0 && (
        <div id="filter-tags" className="filter-tags">
          <label className="tags-label block text-sm font-bold text-slate-300 mb-3 flex items-center gap-2">
            <svg className="w-4 h-4 text-indigo-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 7h.01M7 3h5c.512 0 1.024.195 1.414.586l7 7a2 2 0 010 2.828l-7 7a2 2 0 01-2.828 0l-7-7A1.994 1.994 0 013 12V7a4 4 0 014-4z" />
            </svg>
            Tags
          </label>
          <div className="tags-buttons flex flex-wrap gap-2">
            {availableTags.map((tag) => (
              <button
                key={tag}
                onClick={() => handleTagToggle(tag)}
                className={`px-4 py-2 text-sm font-semibold rounded-xl transition-all duration-200 transform hover:-translate-y-0.5 border ${
                  tags?.includes(tag)
                    ? 'bg-gradient-to-r from-indigo-600 to-purple-600 text-white shadow-lg shadow-indigo-500/30 border-indigo-500/50 scale-105'
                    : 'bg-slate-800/50 text-slate-300 border-white/10 hover:bg-slate-800 hover:border-indigo-500/30 hover:text-white hover:shadow-lg'
                }`}
              >
                #{tag}
              </button>
            ))}
          </div>
        </div>
      )}

      {/* Active Filters Count */}
      {(category || (tags && tags.length > 0) || featured || search) && (
        <div className="active-filters-count mt-4 p-4 bg-indigo-600/10 border border-indigo-500/30 rounded-xl">
          <p className="text-sm text-indigo-400 font-semibold text-center">
            🎯 {
              [
                category ? 1 : 0,
                tags?.length || 0,
                featured ? 1 : 0,
                search ? 1 : 0
              ].reduce((a, b) => a + b, 0)
            } filter(s) active
          </p>
        </div>
      )}
    </div>
  );
}

