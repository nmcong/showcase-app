import { create } from 'zustand';
import { FilterOptions } from '@/types';

interface FilterState extends FilterOptions {
  setCategory: (category?: string) => void;
  setTags: (tags: string[]) => void;
  setPriceRange: (min?: number, max?: number) => void;
  setSearch: (search: string) => void;
  setFeatured: (featured?: boolean) => void;
  reset: () => void;
}

const initialState: FilterOptions = {
  category: undefined,
  tags: [],
  minPrice: undefined,
  maxPrice: undefined,
  search: '',
  featured: undefined,
};

export const useFilterStore = create<FilterState>((set) => ({
  ...initialState,
  setCategory: (category) => set({ category }),
  setTags: (tags) => set({ tags }),
  setPriceRange: (minPrice, maxPrice) => set({ minPrice, maxPrice }),
  setSearch: (search) => set({ search }),
  setFeatured: (featured) => set({ featured }),
  reset: () => set(initialState),
}));

