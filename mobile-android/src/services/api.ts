import axios, { AxiosError } from 'axios';
import type { ApiErrorResponse } from '../types';

const BASE_URL = 'http://181.215.135.114';

export const api = axios.create({
  baseURL: BASE_URL,
  headers: {
    'Content-Type': 'application/json',
    Accept: 'application/json',
  },
  timeout: 15000,
});

api.interceptors.request.use((config) => {
  const token = getStoredToken();
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

api.interceptors.response.use(
  (response) => response,
  (error: AxiosError<ApiErrorResponse>) => {
    const message =
      error.response?.data?.message ?? 'Erro na requisição.';
    return Promise.reject(new Error(message));
  },
);

function getStoredToken(): string | null {
  // TODO: integrar com AsyncStorage
  return null;
}

export function setAuthToken(token: string | null): void {
  if (token) {
    api.defaults.headers.common.Authorization = `Bearer ${token}`;
  } else {
    delete api.defaults.headers.common.Authorization;
  }
}
