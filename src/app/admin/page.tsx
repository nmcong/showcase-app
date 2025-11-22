'use client';

import { ProtectedRoute } from '@/components/auth/ProtectedRoute';
import { useState } from 'react';
import Link from 'next/link';
import { useAuthStore } from '@/store/useAuthStore';
import { logout } from '@/lib/keycloak';

function AdminDashboard() {
  const { user } = useAuthStore();
  const [activeTab, setActiveTab] = useState<'overview' | 'models' | 'comments'>('overview');

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <h1 className="text-2xl font-bold text-gray-900">Admin Dashboard</h1>
              <Link
                href="/"
                className="text-blue-600 hover:text-blue-800 text-sm"
              >
                ← View Showcase
              </Link>
            </div>
            
            <div className="flex items-center gap-4">
              <span className="text-sm text-gray-700">
                {user?.name || 'Admin'}
              </span>
              <button
                onClick={logout}
                className="px-4 py-2 border border-gray-300 rounded-md hover:bg-gray-50"
              >
                Logout
              </button>
            </div>
          </div>
        </div>
      </header>

      {/* Navigation Tabs */}
      <div className="bg-white border-b">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <nav className="flex gap-8">
            <button
              onClick={() => setActiveTab('overview')}
              className={`py-4 px-2 border-b-2 font-medium text-sm ${
                activeTab === 'overview'
                  ? 'border-blue-600 text-blue-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700'
              }`}
            >
              Overview
            </button>
            <button
              onClick={() => setActiveTab('models')}
              className={`py-4 px-2 border-b-2 font-medium text-sm ${
                activeTab === 'models'
                  ? 'border-blue-600 text-blue-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700'
              }`}
            >
              Models
            </button>
            <button
              onClick={() => setActiveTab('comments')}
              className={`py-4 px-2 border-b-2 font-medium text-sm ${
                activeTab === 'comments'
                  ? 'border-blue-600 text-blue-600'
                  : 'border-transparent text-gray-500 hover:text-gray-700'
              }`}
            >
              Comments
            </button>
          </nav>
        </div>
      </div>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {activeTab === 'overview' && (
          <div>
            <h2 className="text-2xl font-bold text-gray-900 mb-6">Dashboard Overview</h2>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              <div className="bg-white rounded-lg shadow-md p-6">
                <h3 className="text-lg font-semibold text-gray-700 mb-2">Total Models</h3>
                <p className="text-3xl font-bold text-blue-600">-</p>
                <p className="text-sm text-gray-500 mt-2">Active listings</p>
              </div>
              
              <div className="bg-white rounded-lg shadow-md p-6">
                <h3 className="text-lg font-semibold text-gray-700 mb-2">Total Comments</h3>
                <p className="text-3xl font-bold text-green-600">-</p>
                <p className="text-sm text-gray-500 mt-2">User reviews</p>
              </div>
              
              <div className="bg-white rounded-lg shadow-md p-6">
                <h3 className="text-lg font-semibold text-gray-700 mb-2">Pending Approval</h3>
                <p className="text-3xl font-bold text-orange-600">-</p>
                <p className="text-sm text-gray-500 mt-2">Awaiting review</p>
              </div>
            </div>

            <div className="mt-8 bg-white rounded-lg shadow-md p-6">
              <h3 className="text-xl font-bold text-gray-900 mb-4">Quick Actions</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <Link
                  href="/admin/models/new"
                  className="flex items-center justify-center gap-2 px-6 py-4 bg-blue-600 text-white rounded-md hover:bg-blue-700"
                >
                  <span>➕</span>
                  <span>Add New Model</span>
                </Link>
                
                <button
                  onClick={() => setActiveTab('comments')}
                  className="flex items-center justify-center gap-2 px-6 py-4 bg-green-600 text-white rounded-md hover:bg-green-700"
                >
                  <span>✓</span>
                  <span>Review Comments</span>
                </button>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'models' && (
          <div>
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-2xl font-bold text-gray-900">Manage Models</h2>
              <Link
                href="/admin/models/new"
                className="px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
              >
                Add New Model
              </Link>
            </div>
            
            <div className="bg-white rounded-lg shadow-md p-6">
              <p className="text-gray-600">
                Model management interface. Use the API routes to manage models programmatically,
                or integrate with a headless CMS for better content management.
              </p>
            </div>
          </div>
        )}

        {activeTab === 'comments' && (
          <div>
            <h2 className="text-2xl font-bold text-gray-900 mb-6">Manage Comments</h2>
            
            <div className="bg-white rounded-lg shadow-md p-6">
              <p className="text-gray-600">
                Comment moderation interface. Review and approve user comments before they appear on the site.
              </p>
            </div>
          </div>
        )}
      </main>
    </div>
  );
}

export default function AdminPage() {
  return (
    <ProtectedRoute requiredRole="admin">
      <AdminDashboard />
    </ProtectedRoute>
  );
}

