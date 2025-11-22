import { create } from 'zustand';
import Keycloak from 'keycloak-js';

interface AuthState {
  keycloak: Keycloak | null;
  authenticated: boolean;
  user: {
    name?: string;
    email?: string;
    roles?: string[];
  } | null;
  setKeycloak: (keycloak: Keycloak) => void;
  setAuthenticated: (authenticated: boolean) => void;
  setUser: (user: AuthState['user']) => void;
  logout: () => void;
}

export const useAuthStore = create<AuthState>((set, get) => ({
  keycloak: null,
  authenticated: false,
  user: null,
  setKeycloak: (keycloak) => set({ keycloak }),
  setAuthenticated: (authenticated) => set({ authenticated }),
  setUser: (user) => set({ user }),
  logout: () => {
    const { keycloak } = get();
    keycloak?.logout();
    set({ authenticated: false, user: null });
  },
}));

