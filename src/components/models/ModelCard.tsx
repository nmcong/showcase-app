'use client';

import Link from 'next/link';
import Image from 'next/image';
import { Model } from '@/types';

interface ModelCardProps {
  model: Model & { averageRating?: number; commentsCount?: number };
  isFeaturedLarge?: boolean;
}

export function ModelCard({ model, isFeaturedLarge = false }: ModelCardProps) {
  return (
    <Link href={`/models/${model.slug}`} className="model-card-link group" data-model-id={model.id} data-model-slug={model.slug}>
      <article id={`model-card-${model.id}`} className={`model-card bg-slate-900/50 backdrop-blur-sm rounded-2xl shadow-xl border border-white/10 overflow-hidden hover:shadow-2xl hover:shadow-indigo-500/20 hover:bg-slate-900/70 transition-all duration-500 transform hover:-translate-y-2 hover:scale-105 hover:border-indigo-500/30 ${isFeaturedLarge ? 'featured-large' : ''}`}>
        {/* Thumbnail */}
        <div className={`card-thumbnail relative ${isFeaturedLarge ? 'h-64' : 'h-56'} bg-gradient-to-br from-slate-900 to-slate-800 overflow-hidden`}>
          <Image
            src={model.thumbnailUrl}
            alt={model.title}
            fill
            className="object-cover group-hover:scale-110 transition-transform duration-700 ease-out"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-black/30 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
          
          {model.featured && (
            <div className="absolute top-3 right-3 bg-gradient-to-r from-amber-400 to-orange-500 text-white text-xs font-bold px-3 py-1.5 rounded-full shadow-lg animate-pulse">
              ⭐ Featured
            </div>
          )}
          
          {/* Hover overlay */}
          <div className="absolute inset-0 bg-gradient-to-t from-indigo-600/20 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
        </div>

        {/* Content */}
        <div className={`card-content ${isFeaturedLarge ? 'p-7' : 'p-6'}`}>
          <h3 className={`card-title ${isFeaturedLarge ? 'text-2xl' : 'text-xl'} font-bold text-white mb-3 group-hover:text-indigo-400 transition-colors duration-300 line-clamp-2`}>
            {model.title}
          </h3>
          
          <p className={`card-description ${isFeaturedLarge ? 'text-base' : 'text-sm'} text-slate-400 mb-4 ${isFeaturedLarge ? 'line-clamp-3' : 'line-clamp-2'} leading-relaxed`}>
            {model.description}
          </p>

          {/* Category */}
          <div className="card-category flex items-center gap-2 mb-4">
            <span className="inline-block bg-gradient-to-r from-indigo-600/20 to-purple-600/20 text-indigo-400 text-xs font-semibold px-3 py-1.5 rounded-full border border-indigo-500/30">
              {model.category?.name}
            </span>
          </div>

          {/* Tags */}
          {model.tags && model.tags.length > 0 && (
            <div className="card-tags flex flex-wrap gap-2 mb-4">
              {model.tags.slice(0, 3).map((tag, index) => (
                <span
                  key={index}
                  className="inline-block bg-slate-800 text-slate-300 text-xs font-medium px-2.5 py-1 rounded-full hover:bg-slate-700 transition-colors border border-white/5"
                >
                  {tag}
                </span>
              ))}
              {model.tags.length > 3 && (
                <span className="inline-block text-slate-500 text-xs px-2 py-1 font-medium">
                  +{model.tags.length - 3} more
                </span>
              )}
            </div>
          )}

          {/* Marketplace Button */}
          <div className="card-marketplace-buttons flex gap-3 pt-4 border-t border-white/5">
            {model.unrealMarketUrl && (
              <div className="flex-1 flex items-center justify-center gap-2 text-sm text-white bg-gradient-to-r from-blue-600/80 to-blue-700/80 px-4 py-2.5 rounded-xl font-semibold group-hover:shadow-lg group-hover:shadow-blue-500/30 transition-all border border-blue-500/30">
                <span className="text-lg">🎮</span>
                <span>Unreal Engine</span>
              </div>
            )}
            {model.unityMarketUrl && (
              <div className="flex-1 flex items-center justify-center gap-2 text-sm text-white bg-gradient-to-r from-purple-600/80 to-purple-700/80 px-4 py-2.5 rounded-xl font-semibold group-hover:shadow-lg group-hover:shadow-purple-500/30 transition-all border border-purple-500/30">
                <span className="text-lg">🎯</span>
                <span>Unity</span>
              </div>
            )}
          </div>

          {/* View 3D Preview CTA */}
          <div className="card-cta mt-4 text-center">
            <span className="cta-text text-xs text-indigo-400 font-semibold group-hover:text-indigo-300 transition-colors">
              Click to view 3D preview →
            </span>
          </div>
        </div>
      </article>
    </Link>
  );
}
