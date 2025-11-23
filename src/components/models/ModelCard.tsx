'use client';

import Link from 'next/link';
import Image from 'next/image';
import { Model } from '@/types';
import { Star } from 'lucide-react';

interface ModelCardProps {
  model: Model & { averageRating?: number; commentsCount?: number };
  isFeaturedLarge?: boolean;
}

export function ModelCard({ model, isFeaturedLarge = false }: ModelCardProps) {
  return (
    <Link href={`/models/${model.slug}`} className="model-card-link group h-full flex" data-model-id={model.id} data-model-slug={model.slug}>
      <article id={`model-card-${model.id}`} className={`model-card h-full w-full flex flex-col bg-slate-900/50 backdrop-blur-sm rounded-2xl shadow-xl border border-white/10 overflow-hidden hover:shadow-2xl hover:shadow-indigo-500/20 hover:bg-slate-900/70 transition-all duration-500 transform hover:-translate-y-2 hover:border-indigo-500/30 ${isFeaturedLarge ? 'featured-large' : ''}`}>
        {/* Thumbnail */}
        <div className={`card-thumbnail relative ${isFeaturedLarge ? 'h-72' : 'h-56'} bg-gradient-to-br from-slate-900 to-slate-800 overflow-hidden flex-shrink-0`}>
          <Image
            src={model.thumbnailUrl}
            alt={model.title}
            fill
            className="object-cover group-hover:scale-110 transition-transform duration-700 ease-out"
          />
          <div className="absolute inset-0 bg-gradient-to-t from-black/30 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
          
          {model.featured && (
            <div className="absolute top-3 right-3 flex items-center gap-1.5 bg-gradient-to-r from-amber-400 to-orange-500 text-white text-xs font-bold px-3 py-1.5 rounded-full shadow-lg animate-pulse">
              <Star className="w-3.5 h-3.5 fill-yellow-300 text-yellow-300" />
              <span>Featured</span>
            </div>
          )}
          
          {/* Hover overlay */}
          <div className="absolute inset-0 bg-gradient-to-t from-indigo-600/20 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
        </div>

        {/* Content */}
        <div className="card-content p-6 flex-1 flex flex-col">
          <h3 className="card-title text-xl font-bold text-white mb-3 group-hover:text-indigo-400 transition-colors duration-300 line-clamp-2">
            {model.title}
          </h3>
          
          <p className="card-description text-sm text-slate-400 mb-4 line-clamp-2 leading-relaxed flex-1">
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
            <div className="card-tags flex flex-wrap gap-2">
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
        </div>
      </article>
    </Link>
  );
}
