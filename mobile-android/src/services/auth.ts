import { api, setAuthToken } from './api';
import type { ApiResponse } from '../types';

interface LoginPayload {
  email: string;
  password: string;
}

interface LoginData {
  token: string;
}

let currentToken: string | null = null;

export async function login(email: string, password: string): Promise<void> {
  const { data } = await api.post<ApiResponse<LoginData>>(
    '/api/v1/auth/login',
    { email, password } satisfies LoginPayload,
  );

  if (!data.success || !data.data?.token) {
    throw new Error(data.message ?? 'Falha no login.');
  }

  currentToken = data.data.token;
  setAuthToken(currentToken);
}

export function logout(): void {
  currentToken = null;
  setAuthToken(null);
}

export function getToken(): string | null {
  return currentToken;
}

export function isAuthenticated(): boolean {
  return currentToken !== null;
}
