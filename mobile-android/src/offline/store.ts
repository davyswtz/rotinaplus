import AsyncStorage from '@react-native-async-storage/async-storage';
import { AppState, type AppStateStatus } from 'react-native';

const CACHE_PREFIX = 'offline_cache_';
const OUTBOX_KEY = 'offline_outbox_v1';

export type OfflineMutationKind =
  | 'toggleMissao'
  | 'criarMissao'
  | 'toggleHabitoCheckin'
  | 'criarHabito'
  | 'atualizarHabitoNota'
  | 'excluirHabito'
  | 'toggleAcademiaDia'
  | 'registrarEsporte'
  | 'excluirEsporteSessao'
  | 'criarTreino'
  | 'toggleTreinoExercicio'
  | 'concluirTreino'
  | 'criarTransacao'
  | 'excluirTransacao'
  | 'criarMeta'
  | 'atualizarMeta'
  | 'atualizarPerfil';

export type OfflineMutation = {
  id: string;
  kind: OfflineMutationKind;
  payload: Record<string, unknown>;
  createdAt: string;
};

export const CacheKeys = {
  dashboard: 'dashboard',
  academia: 'academia',
  financas: 'financas',
  amigos: 'amigos',
  notificacoes: 'notificacoes',
  historicoTreinos: 'historico_treinos',
  classes: 'classes',
  habitos: (data?: string | null) =>
    data ? `habitos_${data}` : 'habitos_hoje',
  financasMes: (mes?: string | null) =>
    mes ? `financas_${mes}` : 'financas',
  catalogo: (grupo?: string | null) => `catalogo_${grupo ?? 'all'}`,
  treino: (id: number) => `treino_${id}`,
  perfilStats: (periodo: string) => `perfil_stats_${periodo}`,
};

let isOnline = true;
let flushing = false;
let flushHandler: (() => Promise<void>) | null = null;

export function setOnline(value: boolean) {
  const wasOffline = !isOnline;
  isOnline = value;
  if (value && wasOffline) {
    void flushOutbox();
  }
}

export function getIsOnline() {
  return isOnline;
}

export function registerFlushHandler(handler: () => Promise<void>) {
  flushHandler = handler;
}

export async function saveCache<T>(key: string, value: T): Promise<void> {
  await AsyncStorage.setItem(CACHE_PREFIX + key, JSON.stringify(value));
}

export async function loadCache<T>(key: string): Promise<T | null> {
  const raw = await AsyncStorage.getItem(CACHE_PREFIX + key);
  if (!raw) return null;
  try {
    return JSON.parse(raw) as T;
  } catch {
    return null;
  }
}

export async function enqueueMutation(
  kind: OfflineMutationKind,
  payload: Record<string, unknown>,
): Promise<void> {
  const list = await loadOutbox();
  list.push({
    id: `${Date.now()}-${Math.random().toString(36).slice(2, 9)}`,
    kind,
    payload,
    createdAt: new Date().toISOString(),
  });
  await AsyncStorage.setItem(OUTBOX_KEY, JSON.stringify(list));
  void flushOutbox();
}

export async function loadOutbox(): Promise<OfflineMutation[]> {
  const raw = await AsyncStorage.getItem(OUTBOX_KEY);
  if (!raw) return [];
  try {
    return JSON.parse(raw) as OfflineMutation[];
  } catch {
    return [];
  }
}

export async function removeMutation(id: string): Promise<void> {
  const list = await loadOutbox();
  await AsyncStorage.setItem(
    OUTBOX_KEY,
    JSON.stringify(list.filter((m) => m.id !== id)),
  );
}

export async function clearOfflineData(): Promise<void> {
  const keys = await AsyncStorage.getAllKeys();
  const toRemove = keys.filter(
    (k) => k.startsWith(CACHE_PREFIX) || k === OUTBOX_KEY,
  );
  if (toRemove.length) await AsyncStorage.multiRemove(toRemove);
}

export async function flushOutbox(): Promise<void> {
  if (flushing || !isOnline || !flushHandler) return;
  flushing = true;
  try {
    await flushHandler();
  } finally {
    flushing = false;
  }
}

/** Detecta falha de rede do Axios/fetch. */
export function isNetworkError(error: unknown): boolean {
  if (!error || typeof error !== 'object') return false;
  const e = error as {
    message?: string;
    code?: string;
    response?: { status?: number };
  };
  if (e.code === 'ERR_NETWORK' || e.code === 'ECONNABORTED') return true;
  if (!e.response && typeof e.message === 'string') {
    return /network|timeout|internet/i.test(e.message);
  }
  return false;
}

function isAuthError(error: unknown): boolean {
  if (!error || typeof error !== 'object') return false;
  const status = (error as { response?: { status?: number } }).response?.status;
  return status === 401 || status === 403;
}

function isValidationError(error: unknown): boolean {
  if (!error || typeof error !== 'object') return false;
  const status = (error as { response?: { status?: number } }).response?.status;
  return status === 400 || status === 422;
}

export async function cachedFetch<T>(
  key: string,
  remote: () => Promise<T>,
): Promise<T> {
  try {
    const value = await remote();
    await saveCache(key, value);
    setOnline(true);
    return value;
  } catch (error) {
    const cached = await loadCache<T>(key);
    if (cached) {
      if (isNetworkError(error) || (!isAuthError(error) && !isValidationError(error))) {
        setOnline(false);
      }
      return cached;
    }
    throw error;
  }
}

export async function mutateOfflineFirst<T>(opts: {
  kind: OfflineMutationKind;
  payload: Record<string, unknown>;
  offlineValue: T;
  remote: () => Promise<T>;
}): Promise<T> {
  if (!getIsOnline()) {
    await enqueueMutation(opts.kind, opts.payload);
    return opts.offlineValue;
  }
  try {
    const value = await opts.remote();
    setOnline(true);
    return value;
  } catch (error) {
    if (isAuthError(error) || isValidationError(error)) {
      throw error;
    }
    // Rede, timeout, 5xx, host down, etc.: fila local e segue.
    setOnline(false);
    await enqueueMutation(opts.kind, opts.payload);
    return opts.offlineValue;
  }
}

/** Ping leve + reflush ao voltar ao foreground. */
export function startOfflineRuntime() {
  const onAppState = (state: AppStateStatus) => {
    if (state === 'active') {
      setOnline(true);
      void flushOutbox();
    }
  };
  const sub = AppState.addEventListener('change', onAppState);
  void flushOutbox();
  return () => sub.remove();
}

export function newClientUUID(): string {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
    const r = (Math.random() * 16) | 0;
    const v = c === 'x' ? r : (r & 0x3) | 0x8;
    return v.toString(16);
  });
}
