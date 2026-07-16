import AsyncStorage from '@react-native-async-storage/async-storage';
import { api, setAuthToken } from './api';
import type { User } from '../types';
import * as tokenStorage from './tokenStorage';

interface LoginPayload {
  email: string;
  password: string;
}

interface RegisterPayload {
  name: string;
  email: string;
  password: string;
  password_confirmation: string;
}

interface AuthResponse {
  user: User;
  token: string;
}

const ONBOARDING_KEYS = ['nome_heroi', 'avatar_selecionado'] as const;

async function clearOnboardingLocalState(): Promise<void> {
  await AsyncStorage.multiRemove([...ONBOARDING_KEYS]);
}

export async function hydrate(): Promise<void> {
  const token = await tokenStorage.hydrateToken();
  setAuthToken(token);
}

export async function login(email: string, password: string): Promise<void> {
  const { data } = await api.post<AuthResponse>(
    '/api/v1/auth/login',
    { email, password } satisfies LoginPayload,
  );

  if (!data.token) {
    throw new Error('Falha no login.');
  }

  await tokenStorage.saveToken(data.token);
  setAuthToken(data.token);
}

export async function register(
  name: string,
  email: string,
  password: string,
  passwordConfirmation: string,
): Promise<void> {
  const { data } = await api.post<AuthResponse>(
    '/api/v1/auth/register',
    {
      name,
      email,
      password,
      password_confirmation: passwordConfirmation,
    } satisfies RegisterPayload,
  );

  if (!data.token) {
    throw new Error('Falha ao criar conta.');
  }

  // Conta nova: limpa onboarding local → Welcome → avatar → nome → Home.
  await clearOnboardingLocalState();
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
