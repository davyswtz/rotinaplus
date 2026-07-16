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

export interface Perfil {
  nome_heroi: string | null;
  avatar_key: string;
  classe: string;
  emoji_classe: string;
  nivel: number;
  xp_atual: number;
  xp_proximo_nivel: number;
  moedas: number;
  streak_dias: number;
}

export interface Missao {
  id: number;
  icone: string;
  titulo: string;
  detalhe: string | null;
  xp: number;
  concluida: boolean;
  data?: string;
  ordem?: number;
}

export interface AcademiaResumo {
  meta_semana: number;
  feitos: number;
  sequencia_treinos: number;
}

export interface DashboardData {
  perfil: Perfil;
  missoes: Missao[];
  missoes_concluidas: number;
  missoes_total: number;
  xp_hoje: number;
  notificacoes_nao_lidas: number;
  academia_resumo: AcademiaResumo;
}

export interface Notificacao {
  id: number;
  icone: string;
  titulo: string;
  mensagem: string;
  lida: boolean;
  quando: string;
  created_at?: string;
}

export interface AcademiaDia {
  id: number;
  dia_chave: string;
  label: string;
  foco: string;
  is_rest: boolean;
  concluido: boolean;
  ordem?: number;
}

export interface AcademiaVolume {
  id: number;
  dia_chave: string;
  label: string;
  kg: number;
}

export interface AcademiaTreino {
  id: number;
  foco: string;
  titulo: string;
  exercicios: number;
  minutos: number;
  xp: number;
  dia_chave?: string | null;
}

export interface AcademiaData {
  meta_semana: number;
  feitos: number;
  sequencia_treinos: number;
  semana_inicio: string;
  dias: AcademiaDia[];
  volumes: AcademiaVolume[];
  treino_hoje: AcademiaTreino | null;
}

export function avatarAssetKey(key: string): string {
  const trimmed = (key || '').trim();
  if (!trimmed) return 'guara_serio';
  return trimmed.replace(/^avatar_/, '');
}
