import axios, { AxiosError } from 'axios';
import { API_BASE_URL } from '../config/api';
import type { ApiErrorResponse } from '../types';
import { getToken } from './tokenStorage';

export const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
    Accept: 'application/json',
  },
  timeout: 15000,
});

api.interceptors.request.use((config) => {
  const token = getToken();
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

interface LaravelErrorBody {
  message?: string;
  errors?: Record<string, string[]>;
}

function parseApiErrorMessage(data: LaravelErrorBody | ApiErrorResponse | undefined): string {
  if (!data) {
    return 'Erro na requisição.';
  }

  const fieldError = data.errors
    ? Object.values(data.errors).flat()[0]
    : undefined;

  if (fieldError) {
    return fieldError;
  }

  if ('message' in data && data.message) {
    return data.message;
  }

  return 'Erro na requisição.';
}

api.interceptors.response.use(
  (response) => response,
  (error: AxiosError<LaravelErrorBody | ApiErrorResponse>) => {
    const message = parseApiErrorMessage(error.response?.data);
    return Promise.reject(new Error(message));
  },
);

export function setAuthToken(token: string | null): void {
  if (token) {
    api.defaults.headers.common.Authorization = `Bearer ${token}`;
  } else {
    delete api.defaults.headers.common.Authorization;
  }
}
