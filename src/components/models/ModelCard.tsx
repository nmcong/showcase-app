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
      <div className="bg-white/80 backdrop-blur-sm rounded-2xl shadow-lg border border-white/20 overflow-hidden hover:shadow-2xl hover:bg-white/90 transition-all duration-500 transform hover:-translate-y-2 hover:scale-105">
        {/* Thumbnail */}
        <div className="relative h-56 bg-gradient-to-br from-slate-100 to-slate-200 overflow-hidden">
          <Image
            src={model.thumbnailUrl}
            alt={model.title}
            fill
            className="object-cover group-hover:scale-110 transition-transform duration-700 ease-out"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-black/10 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
          
          {model.featured && (
            <div className="absolute top-3 right-3 bg-gradient-to-r from-amber-400 to-orange-500 text-white text-xs font-bold px-3 py-1.5 rounded-full shadow-lg animate-pulse">
              ⭐ Featured
            </div>
          )}
          
          {/* Hover overlay */}
          <div className="absolute inset-0 bg-gradient-to-t from-blue-600/20 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
        </div>

        {/* Content */}
        <div className="p-6">
          <h3 className="text-xl font-bold text-slate-800 mb-3 group-hover:text-indigo-600 transition-colors duration-300 line-clamp-2">
            {model.title}
          </h3>
          
          <p className="text-sm text-slate-600 mb-4 line-clamp-2 leading-relaxed">
            {model.description}
          </p>

          {/* Category */}
          <div className="flex items-center gap-2 mb-4">
            <span className="inline-block bg-gradient-to-r from-indigo-100 to-purple-100 text-indigo-700 text-xs font-semibold px-3 py-1.5 rounded-full border border-indigo-200">
              {model.category?.name}
            </span>
          </div>

          {/* Tags */}
          {model.tags && model.tags.length > 0 && (
            <div className="flex flex-wrap gap-2 mb-4">
              {model.tags.slice(0, 3).map((tag, index) => (
                <span
                  key={index}
                  className="inline-block bg-slate-100 text-slate-600 text-xs font-medium px-2.5 py-1 rounded-full hover:bg-slate-200 transition-colors"
                >
                  {tag}
                </span>
              ))}
              {model.tags.length > 3 && (
                <span className="inline-block text-slate-400 text-xs px-2 py-1 font-medium">
                  +{model.tags.length - 3} more
                </span>
              )}
            </div>
          )}

          {/* Rating and Stats */}
          <div className="flex items-center justify-between text-sm mb-4">
            <div className="flex items-center gap-1.5">
              {model.averageRating ? (
                <>
                  <div className="flex items-center gap-1 bg-amber-50 px-2 py-1 rounded-full">
                    <span className="text-amber-500 text-base">★</span>
                    <span className="font-semibold text-slate-700">{model.averageRating.toFixed(1)}</span>
                    <span className="text-slate-500 text-xs">({model.commentsCount})</span>
                  </div>
                </>
              ) : (
                <span className="text-slate-400 text-xs font-medium">No reviews yet</span>
              )}
            </div>
            
            {model.price && (
              <span className="font-bold text-emerald-600 text-lg bg-emerald-50 px-3 py-1 rounded-full">
                ${model.price.toFixed(2)}
              </span>
            )}
          </div>

          {/* Marketplace Icons */}
          <div className="flex gap-3 pt-4 border-t border-slate-100">
            {model.unrealMarketUrl && (
              <div className="flex items-center gap-1.5 text-xs text-slate-600 bg-blue-50 px-3 py-1.5 rounded-full">
                <span className="text-blue-600 font-bold">UE</span>
                <span className="font-medium">Unreal</span>
              </div>
            )}
            {model.unityMarketUrl && (
              <div className="flex items-center gap-1.5 text-xs text-slate-600 bg-purple-50 px-3 py-1.5 rounded-full">
                <span className="text-purple-600 font-bold">U3D</span>
                <span className="font-medium">Unity</span>
              </div>
            )}
          </div>
        </div>
      </div>
    </Link>
  );
}

