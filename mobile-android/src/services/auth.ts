import { api, setAuthToken } from './api';
import type { User } from '../types';
import * as tokenStorage from './tokenStorage';

interface LoginPayload {
  email: string;
  password: string;
}

interface LoginResponse {
  user: User;
  token: string;
}

export async function hydrate(): Promise<void> {
  const token = await tokenStorage.hydrateToken();
  setAuthToken(token);
}

export async function login(email: string, password: string): Promise<void> {
  const { data } = await api.post<LoginResponse>(
    '/api/v1/auth/login',
    { email, password } satisfies LoginPayload,
  );

  if (!data.token) {
    throw new Error('Falha no login.');
  }

  await tokenStorage.saveToken(data.token);
  setAuthToken(data.token);
}

export async function logout(): Promise<void> {
  await tokenStorage.clearToken();
  setAuthToken(null);
}

export function getToken(): string | null {
  return tokenStorage.getToken();
}

export function isAuthenticated(): boolean {
  return tokenStorage.getToken() !== null;
}
