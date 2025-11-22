export interface Model {
  id: string;
  title: string;
  slug: string;
  description: string;
  thumbnailUrl: string;
  modelUrl: string;
  price?: number;
  unrealMarketUrl?: string;
  unityMarketUrl?: string;
  tags: string[];
  views: number;
  featured: boolean;
  published: boolean;
  categoryId: string;
  category?: Category;
  comments?: Comment[];
  createdAt: Date;
  updatedAt: Date;
}

export interface Category {
  id: string;
  name: string;
  slug: string;
  description?: string;
  createdAt: Date;
  updatedAt: Date;
  models?: Model[];
}

export interface Comment {
  id: string;
  authorName: string;
  authorEmail: string;
  content: string;
  rating: number;
  approved: boolean;
  modelId: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface User {
  id: string;
  keycloakId: string;
  email: string;
  name?: string;
  role: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface FilterOptions {
  category?: string;
  tags?: string[];
  minPrice?: number;
  maxPrice?: number;
  search?: string;
  featured?: boolean;
}

