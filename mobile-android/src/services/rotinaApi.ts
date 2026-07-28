import { api } from './api';
import type {
  AcademiaData,
  AcademiaTreino,
  ApiResponse,
  DashboardData,
  EsporteSessao,
  ExercicioCatalogoData,
  FinancasData,
  FinancasMeta,
  FinancasTransacao,
  Missao,
  Notificacao,
  Perfil,
} from '../types';
import {
  CacheKeys,
  cachedFetch,
  isNetworkError,
  loadCache,
  mutateOfflineFirst,
  newClientUUID,
  saveCache,
  setOnline,
} from '../offline/store';

export async function fetchDashboard(): Promise<DashboardData> {
  return cachedFetch(CacheKeys.dashboard, async () => {
    const { data } = await api.get<ApiResponse<DashboardData>>('/api/v1/dashboard');
    if (!data.data) throw new Error('Dashboard vazio.');
    return data.data;
  });
}

export async function toggleMissao(
  id: number,
  concluida: boolean,
): Promise<Missao> {
  return mutateOfflineFirst({
    kind: 'toggleMissao',
    payload: { id, concluida },
    offlineValue: {
      id,
      icone: '🎯',
      titulo: '',
      detalhe: null,
      xp: 0,
      concluida,
    } as Missao,
    remote: async () => {
      const { data } = await api.patch<ApiResponse<Missao>>(
        `/api/v1/missoes/${id}/toggle`,
        { concluida },
      );
      if (!data.data) throw new Error('Falha ao atualizar missão.');
      return data.data;
    },
  });
}

export async function criarMissao(payload: {
  titulo: string;
  detalhe?: string;
  icone?: string;
}): Promise<Missao> {
  const client_uuid = newClientUUID();
  const offline = {
    id: -Date.now(),
    icone: payload.icone ?? '🎯',
    titulo: payload.titulo,
    detalhe: payload.detalhe ?? null,
    xp: 35,
    concluida: false,
  } as Missao;
  return mutateOfflineFirst({
    kind: 'criarMissao',
    payload: { ...payload, client_uuid },
    offlineValue: offline,
    remote: async () => {
      const { data } = await api.post<ApiResponse<Missao>>('/api/v1/missoes', {
        ...payload,
        client_uuid,
      });
      if (!data.data) throw new Error('Falha ao criar missão.');
      return data.data;
    },
  });
}

export async function fetchNotificacoes(): Promise<Notificacao[]> {
  return cachedFetch(CacheKeys.notificacoes, async () => {
    const { data } = await api.get<ApiResponse<Notificacao[]>>(
      '/api/v1/notificacoes',
    );
    return data.data ?? [];
  });
}

export async function marcarNotificacaoLida(id: number): Promise<void> {
  const cached = await loadCache<Notificacao[]>(CacheKeys.notificacoes);
  if (cached) {
    await saveCache(
      CacheKeys.notificacoes,
      cached.map((n) => (n.id === id ? { ...n, lida: true } : n)),
    );
  }
  try {
    await api.patch(`/api/v1/notificacoes/${id}/lida`);
  } catch (e) {
    if (!isNetworkError(e)) throw e;
    setOnline(false);
  }
}

export async function lerTodasNotificacoes(): Promise<void> {
  const cached = await loadCache<Notificacao[]>(CacheKeys.notificacoes);
  if (cached) {
    await saveCache(
      CacheKeys.notificacoes,
      cached.map((n) => ({ ...n, lida: true })),
    );
  }
  try {
    await api.post('/api/v1/notificacoes/ler-todas');
  } catch (e) {
    if (!isNetworkError(e)) throw e;
    setOnline(false);
  }
}

export async function fetchAcademia(): Promise<AcademiaData> {
  return cachedFetch(CacheKeys.academia, async () => {
    const { data } = await api.get<ApiResponse<AcademiaData>>('/api/v1/academia');
    if (!data.data) throw new Error('Academia vazia.');
    return data.data;
  });
}

export async function toggleAcademiaDia(
  id: number,
  concluido: boolean,
): Promise<void> {
  await mutateOfflineFirst({
    kind: 'toggleAcademiaDia',
    payload: { id, concluido },
    offlineValue: undefined as void,
    remote: async () => {
      await api.patch(`/api/v1/academia/dias/${id}/toggle`, { concluido });
    },
  });
}

export async function registrarEsporte(payload: {
  esporte_chave: string;
  minutos: number;
  distancia_metros?: number | null;
  nota?: string | null;
}): Promise<EsporteSessao> {
  const client_uuid = newClientUUID();
  const offline = {
    id: -Date.now(),
    esporte_chave: payload.esporte_chave,
    icone: '🏅',
    nome: payload.esporte_chave,
    minutos: payload.minutos,
    distancia_metros: payload.distancia_metros ?? null,
    xp: 0,
    nota: payload.nota ?? null,
  } as EsporteSessao;
  return mutateOfflineFirst({
    kind: 'registrarEsporte',
    payload: { ...payload, client_uuid },
    offlineValue: offline,
    remote: async () => {
      const { data } = await api.post<ApiResponse<EsporteSessao>>(
        '/api/v1/academia/esportes/sessoes',
        { ...payload, client_uuid },
      );
      if (!data.data) throw new Error('Falha ao registrar esporte.');
      return data.data;
    },
  });
}

export async function excluirEsporteSessao(id: number): Promise<void> {
  await mutateOfflineFirst({
    kind: 'excluirEsporteSessao',
    payload: { id },
    offlineValue: undefined as void,
    remote: async () => {
      await api.delete(`/api/v1/academia/esportes/sessoes/${id}`);
    },
  });
}

export async function fetchCatalogoExercicios(
  grupo?: string,
): Promise<ExercicioCatalogoData> {
  return cachedFetch(CacheKeys.catalogo(grupo), async () => {
    const { data } = await api.get<ApiResponse<ExercicioCatalogoData>>(
      '/api/v1/academia/exercicios',
      { params: grupo ? { grupo } : undefined },
    );
    if (!data.data) throw new Error('Catálogo vazio.');
    return data.data;
  });
}

export async function criarTreino(payload: {
  foco: string;
  titulo?: string;
  minutos?: number;
  exercicios: Array<{
    exercicio_chave: string;
    series?: number;
    reps?: number;
    carga_kg?: number;
  }>;
}): Promise<AcademiaTreino> {
  const client_uuid = newClientUUID();
  return mutateOfflineFirst({
    kind: 'criarTreino',
    payload: { ...payload, client_uuid },
    offlineValue: {
      id: -Date.now(),
      foco: payload.foco,
      titulo: payload.titulo ?? null,
      minutos: payload.minutos ?? 45,
      ativo: true,
      xp: 0,
      itens: [],
    } as unknown as AcademiaTreino,
    remote: async () => {
      const { data } = await api.post<ApiResponse<AcademiaTreino>>(
        '/api/v1/academia/treinos',
        { ...payload, client_uuid },
      );
      if (!data.data) throw new Error('Falha ao criar treino.');
      return data.data;
    },
  });
}

export async function fetchHistoricoTreinos(): Promise<AcademiaTreino[]> {
  return cachedFetch(CacheKeys.historicoTreinos, async () => {
    const { data } = await api.get<ApiResponse<AcademiaTreino[]>>(
      '/api/v1/academia/treinos/historico',
    );
    return data.data ?? [];
  });
}

export async function fetchTreino(id: number): Promise<AcademiaTreino> {
  return cachedFetch(CacheKeys.treino(id), async () => {
    const { data } = await api.get<ApiResponse<AcademiaTreino>>(
      `/api/v1/academia/treinos/${id}`,
    );
    if (!data.data) throw new Error('Treino não encontrado.');
    return data.data;
  });
}

export async function toggleTreinoExercicio(
  treinoId: number,
  exercicioId: number,
  concluido: boolean,
): Promise<void> {
  await mutateOfflineFirst({
    kind: 'toggleTreinoExercicio',
    payload: { treinoId, exercicioId, concluido },
    offlineValue: undefined as void,
    remote: async () => {
      await api.patch(
        `/api/v1/academia/treinos/${treinoId}/exercicios/${exercicioId}/toggle`,
        { concluido },
      );
    },
  });
}

export async function concluirTreino(id: number): Promise<AcademiaTreino> {
  return mutateOfflineFirst({
    kind: 'concluirTreino',
    payload: { id },
    offlineValue: { id, ativo: false } as AcademiaTreino,
    remote: async () => {
      const { data } = await api.post<ApiResponse<AcademiaTreino>>(
        `/api/v1/academia/treinos/${id}/concluir`,
      );
      if (!data.data) throw new Error('Falha ao concluir treino.');
      return data.data;
    },
  });
}

export async function fetchHabitos(data?: string): Promise<
  import('../types').HabitoJournal
> {
  return cachedFetch(CacheKeys.habitos(data), async () => {
    const { data: res } = await api.get<
      ApiResponse<import('../types').HabitoJournal>
    >('/api/v1/habitos', { params: data ? { data } : undefined });
    if (!res.data) throw new Error('Diário vazio.');
    return res.data;
  });
}

export async function criarHabito(payload: {
  titulo: string;
  detalhe?: string;
  icone?: string;
  area?: string;
}): Promise<import('../types').Habito> {
  const client_uuid = newClientUUID();
  return mutateOfflineFirst({
    kind: 'criarHabito',
    payload: { ...payload, client_uuid },
    offlineValue: {
      id: -Date.now(),
      icone: payload.icone ?? '✨',
      titulo: payload.titulo,
      detalhe: payload.detalhe ?? null,
      area: payload.area ?? 'geral',
      frequencia: 'diario',
      xp: 20,
      ativo: true,
    } as import('../types').Habito,
    remote: async () => {
      const { data } = await api.post<ApiResponse<import('../types').Habito>>(
        '/api/v1/habitos',
        { ...payload, client_uuid },
      );
      if (!data.data) throw new Error('Falha ao criar hábito.');
      return data.data;
    },
  });
}

export async function toggleHabitoCheckin(
  id: number,
  payload?: {
    data?: string;
    humor?: number;
    nota?: string;
    concluida?: boolean;
  },
): Promise<import('../types').HabitoToggleResult> {
  const concluida = payload?.concluida ?? true;
  return mutateOfflineFirst({
    kind: 'toggleHabitoCheckin',
    payload: { id, ...payload, concluida },
    offlineValue: {
      habito: {
        id,
        icone: '✨',
        titulo: '',
        area: 'geral',
        frequencia: 'diario',
        xp: 0,
      },
      checkin: {
        id: 0,
        habito_id: id,
        concluida,
        humor: payload?.humor ?? null,
        nota: payload?.nota ?? null,
      },
      concluida,
      streak: 0,
    } as import('../types').HabitoToggleResult,
    remote: async () => {
      const { data } = await api.patch<
        ApiResponse<import('../types').HabitoToggleResult>
      >(`/api/v1/habitos/${id}/checkin`, { ...payload, concluida });
      if (!data.data) throw new Error('Falha no check-in.');
      return data.data;
    },
  });
}

export async function atualizarHabitoNota(
  id: number,
  payload: { data?: string; nota?: string | null; humor?: number },
): Promise<import('../types').HabitoCheckin> {
  const { data } = await api.patch<ApiResponse<import('../types').HabitoCheckin>>(
    `/api/v1/habitos/${id}/nota`,
    payload,
  );
  if (!data.data) throw new Error('Falha ao salvar nota.');
  return data.data;
}

export async function excluirHabito(id: number): Promise<void> {
  await api.delete(`/api/v1/habitos/${id}`);
}

export async function fetchFinancas(mes?: string): Promise<FinancasData> {
  return cachedFetch(CacheKeys.financasMes(mes), async () => {
    const { data } = await api.get<ApiResponse<FinancasData>>('/api/v1/financas', {
      params: mes ? { mes } : undefined,
    });
    if (!data.data) throw new Error('Finanças vazias.');
    return data.data;
  });
}

export async function criarTransacao(payload: {
  tipo: string;
  categoria: string;
  titulo: string;
  icone?: string;
  valor_centavos: number;
  data: string;
}): Promise<FinancasTransacao> {
  const client_uuid = newClientUUID();
  return mutateOfflineFirst({
    kind: 'criarTransacao',
    payload: { ...payload, client_uuid },
    offlineValue: {
      id: -Date.now(),
      ...payload,
      categoria_nome: payload.categoria,
      categoria_cor: '#E87830',
      icone: payload.icone ?? '💰',
    } as FinancasTransacao,
    remote: async () => {
      const { data } = await api.post<ApiResponse<FinancasTransacao>>(
        '/api/v1/financas/transacoes',
        { ...payload, client_uuid },
      );
      if (!data.data) throw new Error('Falha ao criar transação.');
      return data.data;
    },
  });
}

export async function excluirTransacao(id: number): Promise<void> {
  await mutateOfflineFirst({
    kind: 'excluirTransacao',
    payload: { id },
    offlineValue: undefined as void,
    remote: async () => {
      await api.delete(`/api/v1/financas/transacoes/${id}`);
    },
  });
}

export async function criarMeta(payload: {
  titulo: string;
  icone?: string;
  valor_alvo_centavos: number;
}): Promise<FinancasMeta> {
  const client_uuid = newClientUUID();
  return mutateOfflineFirst({
    kind: 'criarMeta',
    payload: { ...payload, client_uuid },
    offlineValue: {
      id: -Date.now(),
      titulo: payload.titulo,
      icone: payload.icone ?? '🎯',
      valor_alvo_centavos: payload.valor_alvo_centavos,
      valor_atual_centavos: 0,
    } as FinancasMeta,
    remote: async () => {
      const { data } = await api.post<ApiResponse<FinancasMeta>>(
        '/api/v1/financas/metas',
        { ...payload, client_uuid },
      );
      if (!data.data) throw new Error('Falha ao criar meta.');
      return data.data;
    },
  });
}

export async function atualizarMeta(
  id: number,
  payload: { valor_atual_centavos?: number; titulo?: string },
): Promise<FinancasMeta> {
  return mutateOfflineFirst({
    kind: 'atualizarMeta',
    payload: { id, ...payload },
    offlineValue: { id, ...payload } as FinancasMeta,
    remote: async () => {
      const { data } = await api.patch<ApiResponse<FinancasMeta>>(
        `/api/v1/financas/metas/${id}`,
        payload,
      );
      if (!data.data) throw new Error('Falha ao atualizar meta.');
      return data.data;
    },
  });
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
  payload: Partial<
    Pick<Perfil, 'nome_heroi' | 'avatar_key' | 'classe' | 'emoji_classe'>
  >,
): Promise<Perfil> {
  return mutateOfflineFirst({
    kind: 'atualizarPerfil',
    payload: payload as Record<string, unknown>,
    offlineValue: payload as Perfil,
    remote: async () => {
      const { data } = await api.put<ApiResponse<Perfil>>('/api/v1/perfil', payload);
      if (!data.data) throw new Error('Falha ao atualizar perfil.');
      return data.data;
    },
  });
}

export async function fetchAmigos(): Promise<import('../types').AmigosLista> {
  return cachedFetch(CacheKeys.amigos, async () => {
    const { data } = await api.get<ApiResponse<import('../types').AmigosLista>>(
      '/api/v1/amigos',
    );
    if (!data.data) throw new Error('Falha ao carregar amigos.');
    return data.data;
  });
}

export async function fetchAmigoStats(
  id: number,
  periodo: 'semana' | 'mes' = 'semana',
): Promise<import('../types').AmigoStats> {
  const { data } = await api.get<ApiResponse<import('../types').AmigoStats>>(
    `/api/v1/amigos/${id}/stats`,
    { params: { periodo } },
  );
  if (!data.data) throw new Error('Falha ao carregar stats do amigo.');
  return data.data;
}

export async function convidarAmigo(
  codigo: string,
): Promise<import('../types').ConviteAmigoResposta> {
  const { data } = await api.post<ApiResponse<import('../types').ConviteAmigoResposta>>(
    '/api/v1/amigos',
    { codigo },
  );
  if (!data.data) throw new Error(data.message || 'Falha ao enviar solicitação.');
  return data.data;
}

export async function aceitarAmigo(
  amizadeId: number,
): Promise<import('../types').Amigo> {
  const { data } = await api.post<ApiResponse<import('../types').Amigo>>(
    `/api/v1/amigos/${amizadeId}/aceitar`,
  );
  if (!data.data) throw new Error(data.message || 'Falha ao aceitar.');
  return data.data;
}

export async function recusarAmigo(amizadeId: number): Promise<void> {
  await api.post(`/api/v1/amigos/${amizadeId}/recusar`);
}

export async function removerAmigo(id: number): Promise<void> {
  await api.delete(`/api/v1/amigos/${id}`);
}

export async function fetchPerfilStats(
  periodo: 'semana' | 'mes' = 'semana',
): Promise<import('../types').PerfilStats> {
  return cachedFetch(CacheKeys.perfilStats(periodo), async () => {
    const { data } = await api.get<ApiResponse<import('../types').PerfilStats>>(
      '/api/v1/perfil/stats',
      { params: { periodo } },
    );
    if (!data.data) throw new Error('Stats vazias.');
    return data.data;
  });
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
  return cachedFetch(CacheKeys.classes, async () => {
    const { data } = await api.get<ApiResponse<ClasseCatalogItem[]>>('/api/v1/classes');
    return data.data ?? [];
  });
}
