import { api } from './api';
import type {
  AcademiaData,
  ApiResponse,
  DashboardData,
  Missao,
  Notificacao,
  Perfil,
} from '../types';

export async function fetchDashboard(): Promise<DashboardData> {
  const { data } = await api.get<ApiResponse<DashboardData>>('/api/v1/dashboard');
  if (!data.data) throw new Error('Dashboard vazio.');
  return data.data;
}

export async function toggleMissao(id: number): Promise<Missao> {
  const { data } = await api.patch<ApiResponse<Missao>>(
    `/api/v1/missoes/${id}/toggle`,
  );
  if (!data.data) throw new Error('Falha ao atualizar missão.');
  return data.data;
}

export async function fetchNotificacoes(): Promise<Notificacao[]> {
  const { data } = await api.get<ApiResponse<Notificacao[]>>(
    '/api/v1/notificacoes',
  );
  return data.data ?? [];
}

export async function marcarNotificacaoLida(id: number): Promise<void> {
  await api.patch(`/api/v1/notificacoes/${id}/lida`);
}

export async function lerTodasNotificacoes(): Promise<void> {
  await api.post('/api/v1/notificacoes/ler-todas');
}

export async function fetchAcademia(): Promise<AcademiaData> {
  const { data } = await api.get<ApiResponse<AcademiaData>>('/api/v1/academia');
  if (!data.data) throw new Error('Academia vazia.');
  return data.data;
}

export async function toggleAcademiaDia(id: number): Promise<void> {
  await api.patch(`/api/v1/academia/dias/${id}/toggle`);
}

export async function updatePerfil(
  payload: Partial<Pick<Perfil, 'nome_heroi' | 'avatar_key' | 'classe' | 'emoji_classe'>>,
): Promise<Perfil> {
  const { data } = await api.put<ApiResponse<Perfil>>('/api/v1/perfil', payload);
  if (!data.data) throw new Error('Falha ao atualizar perfil.');
  return data.data;
}
