'use client';

import { useEffect, useState } from 'react';
import { useParams } from 'next/navigation';
import Link from 'next/link';
import axios from 'axios';
import { Model } from '@/types';
import { ModelViewer } from '@/components/3d/ModelViewer';
import { CommentSection } from '@/components/comments/CommentSection';
import { MarketplaceLinks } from '@/components/models/MarketplaceLinks';

export default function ModelDetailPage() {
  const params = useParams();
  const slug = params?.slug as string;
  const [model, setModel] = useState<Model & { averageRating?: number } | null>(null);
  const [loading, setLoading] = useState(true);

  const fetchModel = async () => {
    try {
      const response = await axios.get(`/api/models/${slug}`);
      setModel(response.data);
    } catch (error) {
      console.error('Error fetching model:', error);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (slug) {
      fetchModel();
    }
  }, [slug]);

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto"></div>
          <p className="mt-4 text-gray-600">Loading model...</p>
        </div>
      </div>
    );
  }

  if (!model) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-center">
          <h1 className="text-2xl font-bold text-gray-800 mb-4">Model Not Found</h1>
          <Link
            href="/"
            className="px-6 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700"
          >
            Back to Home
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
          <Link
            href="/"
            className="inline-flex items-center text-blue-600 hover:text-blue-800"
          >
            ← Back to Showcase
          </Link>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Model Title and Info */}
        <div className="bg-white rounded-lg shadow-md p-6 mb-6">
          <div className="flex items-start justify-between mb-4">
            <div>
              <h1 className="text-3xl font-bold text-gray-900 mb-2">
                {model.title}
              </h1>
              <div className="flex items-center gap-4 text-sm text-gray-600">
                <span className="inline-block bg-blue-100 text-blue-800 px-3 py-1 rounded">
                  {model.category?.name}
                </span>
                {model.averageRating && model.averageRating > 0 ? (
                  <div className="flex items-center gap-1">
                    <span className="text-yellow-500">★</span>
                    <span className="font-medium">{model.averageRating.toFixed(1)}</span>
                  </div>
                ) : null}
                <span>👁️ {model.views} views</span>
              </div>
            </div>
            {model.featured && (
              <div className="bg-yellow-400 text-yellow-900 px-4 py-2 rounded-lg font-bold">
                ⭐ Featured
              </div>
            )}
          </div>

          <p className="text-gray-700 leading-relaxed mb-4">{model.description}</p>

          {/* Tags */}
          {model.tags && model.tags.length > 0 && (
            <div className="flex flex-wrap gap-2">
              {model.tags.map((tag, index) => (
                <span
                  key={index}
                  className="inline-block bg-gray-100 text-gray-700 text-sm px-3 py-1 rounded-full"
                >
                  {tag}
                </span>
              ))}
            </div>
          )}
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* 3D Viewer */}
          <div className="lg:col-span-2">
            <div className="bg-white rounded-lg shadow-md overflow-hidden">
              <ModelViewer modelUrl={model.modelUrl} className="h-[600px]" />
            </div>
          </div>

          {/* Sidebar with Purchase Links */}
          <div className="lg:col-span-1">
            <MarketplaceLinks
              unrealMarketUrl={model.unrealMarketUrl}
              unityMarketUrl={model.unityMarketUrl}
              price={model.price}
            />
          </div>
        </div>

        {/* Comments Section */}
        <div className="mt-8">
          <CommentSection
            modelId={model.id}
            comments={model.comments || []}
            onCommentAdded={fetchModel}
          />
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

