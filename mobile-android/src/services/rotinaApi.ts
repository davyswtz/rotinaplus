import { api } from './api';
import type {
  AcademiaData,
  ApiResponse,
  DashboardData,
  FinancasData,
  FinancasMeta,
  FinancasTransacao,
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

export async function criarMissao(payload: {
  titulo: string;
  detalhe?: string;
  icone?: string;
}): Promise<Missao> {
  const { data } = await api.post<ApiResponse<Missao>>('/api/v1/missoes', payload);
  if (!data.data) throw new Error('Falha ao criar missão.');
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

export async function fetchFinancas(mes?: string): Promise<FinancasData> {
  const { data } = await api.get<ApiResponse<FinancasData>>('/api/v1/financas', {
    params: mes ? { mes } : undefined,
  });
  if (!data.data) throw new Error('Finanças vazias.');
  return data.data;
}

export async function criarTransacao(payload: {
  tipo: string;
  categoria: string;
  titulo: string;
  icone?: string;
  valor_centavos: number;
  data: string;
}): Promise<FinancasTransacao> {
  const { data } = await api.post<ApiResponse<FinancasTransacao>>(
    '/api/v1/financas/transacoes',
    payload,
  );
  if (!data.data) throw new Error('Falha ao criar transação.');
  return data.data;
}

export async function excluirTransacao(id: number): Promise<void> {
  await api.delete(`/api/v1/financas/transacoes/${id}`);
}

export async function criarMeta(payload: {
  titulo: string;
  icone?: string;
  valor_alvo_centavos: number;
}): Promise<FinancasMeta> {
  const { data } = await api.post<ApiResponse<FinancasMeta>>(
    '/api/v1/financas/metas',
    payload,
  );
  if (!data.data) throw new Error('Falha ao criar meta.');
  return data.data;
}

export async function atualizarMeta(
  id: number,
  payload: { valor_atual_centavos?: number; titulo?: string },
): Promise<FinancasMeta> {
  const { data } = await api.patch<ApiResponse<FinancasMeta>>(
    `/api/v1/financas/metas/${id}`,
    payload,
  );
  if (!data.data) throw new Error('Falha ao atualizar meta.');
  return data.data;
}

export async function pluggyConnectToken(): Promise<
  import('../types').PluggyConnectToken
> {
  const { data } = await api.post<ApiResponse<import('../types').PluggyConnectToken>>(
    '/api/v1/financas/pluggy/connect-token',
  );
  if (!data.data) throw new Error(data.message || 'Falha no connect token.');
  return data.data;
}

export async function pluggyVincular(
  itemId: string,
): Promise<import('../types').PluggySyncResult> {
  const { data } = await api.post<ApiResponse<import('../types').PluggySyncResult>>(
    '/api/v1/financas/pluggy/vincular',
    { item_id: itemId },
  );
  if (!data.data) throw new Error(data.message || 'Falha ao vincular banco.');
  return data.data;
}

export async function pluggySincronizar(): Promise<
  import('../types').PluggySyncResult
> {
  const { data } = await api.post<ApiResponse<import('../types').PluggySyncResult>>(
    '/api/v1/financas/pluggy/sincronizar',
  );
  if (!data.data) throw new Error(data.message || 'Falha ao sincronizar.');
  return data.data;
}

export async function updatePerfil(
  payload: Partial<Pick<Perfil, 'nome_heroi' | 'avatar_key' | 'classe' | 'emoji_classe'>>,
): Promise<Perfil> {
  const { data } = await api.put<ApiResponse<Perfil>>('/api/v1/perfil', payload);
  if (!data.data) throw new Error('Falha ao atualizar perfil.');
  return data.data;
}

export type ClasseCatalogItem = {
  key: string;
  nome: string;
  emoji: string;
  descricao: string;
  bonus: string[];
  tema: string;
};

export async function fetchClasses(): Promise<ClasseCatalogItem[]> {
  const { data } = await api.get<ApiResponse<ClasseCatalogItem[]>>('/api/v1/classes');
  return data.data ?? [];
}
