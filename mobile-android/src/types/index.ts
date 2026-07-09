export interface User {
  id: number;
  name: string;
  email: string;
}

export interface Rotina {
  id: number;
  titulo: string;
  descricao: string | null;
  concluida: boolean;
  created_at: string;
  updated_at: string;
}

export interface ApiResponse<T> {
  success: boolean;
  message?: string;
  data?: T;
  errors?: Record<string, string[]>;
}

export interface ApiErrorResponse {
  success: false;
  message: string;
  errors: Record<string, string[]>;
}
