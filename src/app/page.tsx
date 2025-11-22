'use client';

import { useEffect, useState } from 'react';
import { ModelGrid } from '@/components/models/ModelGrid';
import { ModelFilters } from '@/components/filters/ModelFilters';
import { Category } from '@/types';
import axios from 'axios';
import Link from 'next/link';
import { useAuthStore } from '@/store/useAuthStore';
import { login, logout } from '@/lib/keycloak';

export default function HomePage() {
  const [categories, setCategories] = useState<Category[]>([]);
  const [availableTags, setAvailableTags] = useState<string[]>([]);
  const { authenticated, user } = useAuthStore();

  useEffect(() => {
    const fetchCategories = async () => {
      try {
        const response = await axios.get('/api/categories');
        setCategories(response.data);
      } catch (error) {
        console.error('Error fetching categories:', error);
      }
    };

    // Fetch available tags (you can implement a dedicated API for this)
    const fetchTags = async () => {
      // For now, using hardcoded tags. In production, fetch from API
      setAvailableTags([
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
    };

    fetchCategories();
    fetchTags();
  }, []);

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-50 via-blue-50 to-indigo-50">
      {/* Header */}
      <header className="glass border-b border-white/20 sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <div className="w-10 h-10 bg-gradient-primary rounded-xl flex items-center justify-center animate-float">
                <span className="text-white font-bold text-lg">3D</span>
              </div>
              <div>
                <h1 className="text-4xl font-bold bg-gradient-to-r from-indigo-600 via-purple-600 to-blue-600 bg-clip-text text-transparent">
                  3D Models Showcase
                </h1>
                <p className="text-slate-600 mt-1 text-lg font-medium">
                  Professional 3D assets for your creative projects
                </p>
              </div>
            </div>
            
            <div className="flex items-center gap-4">
              {authenticated ? (
                <>
                  <div className="hidden md:flex items-center gap-3 px-4 py-2 bg-white/60 rounded-full border border-white/30">
                    <div className="w-8 h-8 bg-gradient-to-r from-green-400 to-blue-500 rounded-full flex items-center justify-center">
                      <span className="text-white text-sm font-semibold">
                        {(user?.name || 'User').charAt(0).toUpperCase()}
                      </span>
                    </div>
                    <span className="text-sm font-medium text-slate-700">
                      {user?.name || 'User'}
                    </span>
                  </div>
                  {user?.roles?.includes('admin') && (
                    <Link
                      href="/admin"
                      className="px-6 py-2.5 bg-gradient-to-r from-slate-800 to-slate-700 text-white rounded-xl hover:from-slate-700 hover:to-slate-600 transition-all duration-200 font-medium shadow-lg hover:shadow-xl transform hover:-translate-y-0.5"
                    >
                      Admin Panel
                    </Link>
                  )}
                  <button
                    onClick={logout}
                    className="px-6 py-2.5 bg-white/80 border border-slate-200 text-slate-700 rounded-xl hover:bg-white hover:shadow-lg transition-all duration-200 font-medium"
                  >
                    Logout
                  </button>
                </>
              ) : (
                <button
                  onClick={login}
                  className="px-8 py-3 bg-gradient-primary text-white rounded-xl hover:shadow-lg transition-all duration-200 font-semibold transform hover:-translate-y-0.5"
                >
                  Login
                </button>
              )}
            </div>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="text-center mb-12">
          <h2 className="text-2xl md:text-3xl font-bold text-slate-800 mb-4">
            Discover Amazing 3D Assets
          </h2>
          <p className="text-lg text-slate-600 max-w-2xl mx-auto">
            Browse our curated collection of high-quality 3D models for Unity, Unreal Engine, and more
          </p>
        </div>
      </section>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-12">
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
      <footer className="glass border-t border-white/20 mt-16">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="flex flex-col md:flex-row justify-between items-center gap-6">
            <div className="flex items-center space-x-4">
              <div className="w-8 h-8 bg-gradient-primary rounded-lg flex items-center justify-center">
                <span className="text-white font-bold">3D</span>
              </div>
              <span className="text-slate-700 font-medium">3D Models Showcase</span>
            </div>
            <p className="text-slate-600 text-center">
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
