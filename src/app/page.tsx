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
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-3xl font-bold text-gray-900">
                3D Models Showcase
              </h1>
              <p className="text-gray-600 mt-1">
                Professional 3D assets for your projects
              </p>
            </div>
            
            <div className="flex items-center gap-4">
              {authenticated ? (
                <>
                  <span className="text-sm text-gray-700">
                    Hello, {user?.name || 'User'}
                  </span>
                  {user?.roles?.includes('admin') && (
                    <Link
                      href="/admin"
                      className="px-4 py-2 bg-gray-800 text-white rounded-md hover:bg-gray-700"
                    >
                      Admin Panel
                    </Link>
                  )}
                  <button
                    onClick={logout}
                    className="px-4 py-2 border border-gray-300 rounded-md hover:bg-gray-50"
                  >
                    Logout
                  </button>
                </>
              ) : (
                <button
                  onClick={login}
                  className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
                >
                  Login
                </button>
              )}
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
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
      <footer className="bg-white border-t mt-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <p className="text-center text-gray-600">
            © 2025 3D Models Showcase. All rights reserved.
          </p>
        </div>
      </footer>
    </div>
  );
}
