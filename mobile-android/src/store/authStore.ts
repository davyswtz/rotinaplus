import { create } from 'zustand';
import * as authService from '../services/auth';

interface AuthState {
  isAuthenticated: boolean;
  isHydrated: boolean;
  isLoading: boolean;
  error: string | null;
  hydrate: () => Promise<void>;
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
}

export const useAuthStore = create<AuthState>((set) => ({
  isAuthenticated: false,
  isHydrated: false,
  isLoading: false,
  error: null,

  hydrate: async () => {
    await authService.hydrate();
    set({
      isAuthenticated: authService.isAuthenticated(),
      isHydrated: true,
    });
  },

  login: async (email, password) => {
    set({ isLoading: true, error: null });
    try {
      await authService.login(email, password);
      set({ isAuthenticated: true, isLoading: false });
    } catch (error) {
      set({
        isAuthenticated: false,
        isLoading: false,
        error: error instanceof Error ? error.message : 'Erro desconhecido.',
      });
    }
  },

  logout: async () => {
    await authService.logout();
    set({ isAuthenticated: false, error: null });
  },
}));
