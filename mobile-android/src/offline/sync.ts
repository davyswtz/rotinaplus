import { api } from '../services/api';
import type { ApiResponse, Missao } from '../types';
import {
  loadOutbox,
  removeMutation,
  registerFlushHandler,
  type OfflineMutation,
} from './store';

async function replay(mutation: OfflineMutation): Promise<void> {
  const p = mutation.payload;
  switch (mutation.kind) {
    case 'toggleMissao':
      await api.patch(`/api/v1/missoes/${p.id}/toggle`, {
        concluida: p.concluida,
      });
      break;
    case 'criarMissao':
      await api.post('/api/v1/missoes', {
        titulo: p.titulo,
        detalhe: p.detalhe,
        icone: p.icone,
        client_uuid: p.client_uuid,
      });
      break;
    case 'toggleHabitoCheckin':
      await api.patch(`/api/v1/habitos/${p.id}/checkin`, {
        data: p.data,
        humor: p.humor,
        nota: p.nota,
        concluida: p.concluida,
      });
      break;
    case 'criarHabito':
      await api.post('/api/v1/habitos', {
        titulo: p.titulo,
        detalhe: p.detalhe,
        icone: p.icone,
        area: p.area,
        client_uuid: p.client_uuid,
      });
      break;
    case 'atualizarHabitoNota':
      await api.patch(`/api/v1/habitos/${p.id}/nota`, {
        data: p.data,
        nota: p.nota,
        humor: p.humor,
      });
      break;
    case 'toggleAcademiaDia':
      await api.patch(`/api/v1/academia/dias/${p.id}/toggle`, {
        concluido: p.concluido,
      });
      break;
    case 'registrarEsporte':
      await api.post('/api/v1/academia/esportes/sessoes', {
        esporte_chave: p.esporte_chave,
        minutos: p.minutos,
        distancia_metros: p.distancia_metros,
        nota: p.nota,
        client_uuid: p.client_uuid,
      });
      break;
    case 'excluirEsporteSessao':
      await api.delete(`/api/v1/academia/esportes/sessoes/${p.id}`);
      break;
    case 'criarTreino':
      await api.post('/api/v1/academia/treinos', {
        ...p,
      });
      break;
    case 'toggleTreinoExercicio':
      await api.patch(
        `/api/v1/academia/treinos/${p.treinoId}/exercicios/${p.exercicioId}/toggle`,
        { concluido: p.concluido },
      );
      break;
    case 'concluirTreino':
      await api.post(`/api/v1/academia/treinos/${p.id}/concluir`);
      break;
    case 'criarTransacao':
      await api.post('/api/v1/financas/transacoes', p);
      break;
    case 'excluirTransacao':
      await api.delete(`/api/v1/financas/transacoes/${p.id}`);
      break;
    case 'criarMeta':
      await api.post('/api/v1/financas/metas', p);
      break;
    case 'atualizarMeta':
      await api.patch(`/api/v1/financas/metas/${p.id}`, {
        valor_atual_centavos: p.valor_atual_centavos,
        titulo: p.titulo,
      });
      break;
    case 'atualizarPerfil':
      await api.put('/api/v1/perfil', p);
      break;
    default:
      break;
  }
}

export async function flushPendingMutations(): Promise<void> {
  const pending = await loadOutbox();
  for (const mutation of pending) {
    try {
      await replay(mutation);
      await removeMutation(mutation.id);
    } catch {
      break;
    }
  }
}

export function installOfflineSync(): void {
  registerFlushHandler(flushPendingMutations);
}

/** Tipagem auxiliar usada no sync de missões. */
export type { Missao, ApiResponse };
