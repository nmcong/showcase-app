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
      name: 'Weapons',
      slug: 'weapons',
      description: '3D weapon models',
      createdAt: new Date(),
      updatedAt: new Date(),
    },
  ]);

  const [availableTags] = useState<string[]>([
    // Category-based tags
    'Characters',
    'Weapons',
    // Weapon types
    'Katana',
    'Samurai',
    'Sword',
    'Weapon',
    'Modular',
    'Tachi',
    'Wakizashi',
    // Style/Theme tags
    'Japanese',
    'Medieval',
    // Character/Animal tags
    'Animal',
    'Character',
    'Cute',
    'Mammal',
    'Wildlife',
    'Capybara',
    // Material/Design tags
    'Bamboo',
    'Kitsune',
    'Peony',
  ]);

  return (
    <div id="home-page" className="home-page min-h-screen bg-gradient-to-br from-slate-950 via-slate-900 to-slate-950">
      {/* JSON-LD for Organization */}
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify({
            "@context": "https://schema.org",
            "@type": "Organization",
            "name": "3D Models Showcase",
            "description": "Professional 3D assets marketplace",
            "url": "https://3dmodels-showcase.com",
            "logo": "https://3dmodels-showcase.com/logo.png",
            "sameAs": [
              "https://twitter.com/3dmodelsshowcase",
              "https://facebook.com/3dmodelsshowcase"
            ]
          })
        }}
      />
      
      {/* Header */}
      <header id="site-header" className="site-header glass-dark border-b border-white/10 sticky top-0 z-50">
        <div className="header-container max-w-[1612px] mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="header-inner flex items-center justify-between">
            <div className="header-brand flex items-center space-x-4">
              <div className="brand-logo w-10 h-10 bg-gradient-to-br from-indigo-600 to-purple-600 rounded-xl flex items-center justify-center shadow-lg shadow-indigo-500/50">
                <span className="text-white font-bold text-lg">3D</span>
              </div>
              <div className="brand-content">
                <h1 className="brand-title text-4xl font-bold bg-gradient-to-r from-indigo-400 via-purple-400 to-blue-400 bg-clip-text text-transparent" itemProp="name">
                  3D Models Showcase
                </h1>
                <p className="brand-tagline text-slate-400 mt-1 text-lg font-medium" itemProp="description">
                  Professional 3D assets for your creative projects
                </p>
              </div>
            </div>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <section id="hero-section" className="hero-section max-w-[1612px] mx-auto px-4 sm:px-6 lg:px-8 py-6">
        <div className="hero-content text-center mb-6">
          <h2 className="hero-title text-xl md:text-2xl font-bold text-white mb-2">
            Discover Amazing 3D Assets
          </h2>
          <p className="hero-description text-base text-slate-400 max-w-2xl mx-auto">
            Browse our curated collection of high-quality 3D models for Unity, Unreal Engine, and more
          </p>
        </div>
      </section>

      {/* Main Content */}
      <main id="main-content" className="main-content max-w-[1612px] mx-auto px-4 sm:px-6 lg:px-8 pb-12">
        <div className="content-layout grid grid-cols-1 lg:grid-cols-4 gap-8">
          {/* Filters Sidebar */}
          <aside id="filters-sidebar" className="filters-sidebar lg:col-span-1">
            <ModelFilters categories={categories} availableTags={availableTags} />
          </aside>

          {/* Models Grid */}
          <div id="models-section" className="models-section lg:col-span-3">
            <ModelGrid />
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer id="site-footer" className="site-footer glass-dark border-t border-white/10 mt-16">
        <div className="footer-container max-w-[1612px] mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="footer-content flex flex-col md:flex-row justify-between items-center gap-6">
            <div className="footer-brand flex items-center space-x-4">
              <div className="footer-logo w-8 h-8 bg-gradient-to-br from-indigo-600 to-purple-600 rounded-lg flex items-center justify-center shadow-lg shadow-indigo-500/30">
                <span className="text-white font-bold">3D</span>
              </div>
              <span className="footer-brand-name text-slate-300 font-medium">3D Models Showcase</span>
            </div>
            <p className="footer-copyright text-slate-500 text-center">
              © 2025 3D Models Showcase. All rights reserved.
            </p>
            <div className="footer-features flex gap-4 text-sm text-slate-500">
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
