'use client';

import Link from 'next/link';
import Image from 'next/image';
import { Model } from '@/types';

interface ModelCardProps {
  model: Model & { averageRating?: number; commentsCount?: number };
}

export function ModelCard({ model }: ModelCardProps) {
  return (
    <Link href={`/models/${model.slug}`} className="group">
      <div className="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-xl transition-shadow duration-300">
        {/* Thumbnail */}
        <div className="relative h-48 bg-gray-200">
          <Image
            src={model.thumbnailUrl}
            alt={model.title}
            fill
            className="object-cover group-hover:scale-105 transition-transform duration-300"
          />
          {model.featured && (
            <div className="absolute top-2 right-2 bg-yellow-400 text-yellow-900 text-xs font-bold px-2 py-1 rounded">
              ⭐ Featured
            </div>
          )}
        </div>

        {/* Content */}
        <div className="p-4">
          <h3 className="text-lg font-semibold text-gray-800 mb-2 group-hover:text-blue-600 transition-colors">
            {model.title}
          </h3>
          
          <p className="text-sm text-gray-600 mb-3 line-clamp-2">
            {model.description}
          </p>

          {/* Category */}
          <div className="flex items-center gap-2 mb-3">
            <span className="inline-block bg-blue-100 text-blue-800 text-xs px-2 py-1 rounded">
              {model.category?.name}
            </span>
          </div>

          {/* Tags */}
          {model.tags && model.tags.length > 0 && (
            <div className="flex flex-wrap gap-1 mb-3">
              {model.tags.slice(0, 3).map((tag, index) => (
                <span
                  key={index}
                  className="inline-block bg-gray-100 text-gray-700 text-xs px-2 py-1 rounded"
                >
                  {tag}
                </span>
              ))}
              {model.tags.length > 3 && (
                <span className="inline-block text-gray-500 text-xs px-2 py-1">
                  +{model.tags.length - 3} more
                </span>
              )}
            </div>
          )}

          {/* Rating and Stats */}
          <div className="flex items-center justify-between text-sm">
            <div className="flex items-center gap-1">
              {model.averageRating ? (
                <>
                  <span className="text-yellow-500">★</span>
                  <span className="font-medium">{model.averageRating.toFixed(1)}</span>
                  <span className="text-gray-500">({model.commentsCount})</span>
                </>
              ) : (
                <span className="text-gray-400">No reviews yet</span>
              )}
            </div>
            
            {model.price && (
              <span className="font-bold text-green-600">
                ${model.price.toFixed(2)}
              </span>
            )}
          </div>

          {/* Marketplace Icons */}
          <div className="flex gap-2 mt-3 pt-3 border-t">
            {model.unrealMarketUrl && (
              <div className="text-xs text-gray-600">🎮 Unreal</div>
            )}
            {model.unityMarketUrl && (
              <div className="text-xs text-gray-600">🎯 Unity</div>
            )}
          </div>
        </div>
      </div>
    </Link>
  );
}

