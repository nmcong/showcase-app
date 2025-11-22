'use client';

import { useState } from 'react';
import { ModelGrid } from '@/components/models/ModelGrid';
import { ModelFilters } from '@/components/filters/ModelFilters';
import { Category } from '@/types';

export default function HomePage() {
  const [categories] = useState<Category[]>([
    {
      id: '1',
      name: 'Characters',
      slug: 'characters',
      description: '3D character models',
      createdAt: new Date(),
      updatedAt: new Date(),
    },
    {
      id: '2',
      name: 'Props',
      slug: 'props',
      description: '3D prop models',
      createdAt: new Date(),
      updatedAt: new Date(),
    },
    {
      id: '3',
      name: 'Environments',
      slug: 'environments',
      description: '3D environment models',
      createdAt: new Date(),
      updatedAt: new Date(),
    },
  ]);

  const [availableTags] = useState<string[]>([
    'Characters',
    'Props',
    'Weapons',
    'Vehicles',
    'Environment',
    'Buildings',
    'Nature',
    'Sci-Fi',
    'Fantasy',
    'Modern',
  ]);

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-950 via-slate-900 to-slate-950">
      {/* Header */}
      <header className="glass-dark border-b border-white/10 sticky top-0 z-50">
        <div className="max-w-[1612px] mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <div className="w-10 h-10 bg-gradient-to-br from-indigo-600 to-purple-600 rounded-xl flex items-center justify-center shadow-lg shadow-indigo-500/50">
                <span className="text-white font-bold text-lg">3D</span>
              </div>
              <div>
                <h1 className="text-4xl font-bold bg-gradient-to-r from-indigo-400 via-purple-400 to-blue-400 bg-clip-text text-transparent">
                  3D Models Showcase
                </h1>
                <p className="text-slate-400 mt-1 text-lg font-medium">
                  Professional 3D assets for your creative projects
                </p>
              </div>
            </div>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <section className="max-w-[1612px] mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="text-center mb-12">
          <h2 className="text-2xl md:text-3xl font-bold text-white mb-4">
            Discover Amazing 3D Assets
          </h2>
          <p className="text-lg text-slate-400 max-w-2xl mx-auto">
            Browse our curated collection of high-quality 3D models for Unity, Unreal Engine, and more
          </p>
        </div>
      </section>

      {/* Main Content */}
      <main className="max-w-[1612px] mx-auto px-4 sm:px-6 lg:px-8 pb-12">
        <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
          {/* Filters Sidebar */}
          <aside className="lg:col-span-1">
            <ModelFilters categories={categories} availableTags={availableTags} />
          </aside>

          {/* Models Grid */}
          <div className="lg:col-span-3">
            <ModelGrid />
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="glass-dark border-t border-white/10 mt-16">
        <div className="max-w-[1612px] mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="flex flex-col md:flex-row justify-between items-center gap-6">
            <div className="flex items-center space-x-4">
              <div className="w-8 h-8 bg-gradient-to-br from-indigo-600 to-purple-600 rounded-lg flex items-center justify-center shadow-lg shadow-indigo-500/30">
                <span className="text-white font-bold">3D</span>
              </div>
              <span className="text-slate-300 font-medium">3D Models Showcase</span>
            </div>
            <p className="text-slate-500 text-center">
              © 2025 3D Models Showcase. All rights reserved.
            </p>
            <div className="flex gap-4 text-sm text-slate-500">
              <span>Quality Assets</span>
              <span>•</span>
              <span>Professional Support</span>
              <span>•</span>
              <span>Fast Delivery</span>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
