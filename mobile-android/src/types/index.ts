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
  codigo_amigo: string | null;
  avatar_key: string;
  classe: string;
  emoji_classe: string;
  nivel: number;
  xp_atual: number;
  xp_proximo_nivel: number;
  moedas: number;
  streak_dias: number;
}

export interface Amigo {
  id: number;
  codigo_amigo: string | null;
  nome_heroi: string | null;
  avatar_key: string;
  classe: string;
  emoji_classe: string;
  nivel: number;
}

export interface AmigosLista {
  amigos: Amigo[];
  total: number;
}

export interface ConviteAmigoResposta {
  amizade_id: number;
  status: string;
}

export interface PerfilSerieDia {
  data: string;
  label: string;
  acertos: number;
  falhas: number;
  taxa: number;
  xp: number;
}

export interface PerfilAreaStats {
  acertos?: number;
  falhas?: number;
  taxa?: number;
  sessoes?: number;
  minutos?: number;
  xp?: number;
}

export interface PerfilStats {
  periodo: string;
  inicio: string;
  fim: string;
  perfil: Perfil;
  totais: {
    acertos: number;
    falhas: number;
    taxa_sucesso: number;
    xp_ganho: number;
    dias_completos: number;
    streak_atual: number;
    sequencia_treinos: number;
  };
  serie: PerfilSerieDia[];
  por_area: {
    missoes: PerfilAreaStats;
    habitos: PerfilAreaStats;
    academia: PerfilAreaStats;
    esportes: PerfilAreaStats;
  };
  nivel: {
    atual: number;
    xp_atual: number;
    xp_proximo: number;
    progresso: number;
    moedas: number;
  };
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

export interface HabitosResumo {
  concluidos: number;
  total: number;
  streak_geral: number;
  percentual: number;
}

export interface DashboardData {
  perfil: Perfil;
  missoes: Missao[];
  missoes_concluidas: number;
  missoes_total: number;
  xp_hoje: number;
  notificacoes_nao_lidas: number;
  academia_resumo: AcademiaResumo;
  habitos_resumo?: HabitosResumo;
}

export interface Habito {
  id: number;
  icone: string;
  titulo: string;
  detalhe: string | null;
  area: string;
  frequencia: string;
  dias_semana?: number[] | null;
  xp: number;
  ativo?: boolean;
  ordem?: number;
}

export interface HabitoCheckin {
  id: number;
  habito_id: number;
  data?: string;
  concluida: boolean;
  concluida_em?: string | null;
  humor?: number | null;
  nota?: string | null;
}

export interface HabitoSemanaDia {
  data: string;
  label: string;
  concluidos: number;
  total: number;
  percentual: number;
}

export interface HabitoSugestao {
  icone: string;
  titulo: string;
  detalhe: string;
  area: string;
}

export interface HabitoItemJournal {
  habito: Habito;
  checkin: HabitoCheckin | null;
  concluida: boolean;
  streak: number;
}

export interface HabitoJournal {
  data: string;
  hoje: string;
  resumo: {
    concluidos: number;
    total: number;
    percentual: number;
    streak_geral: number;
    xp_hoje: number;
  };
  semana: HabitoSemanaDia[];
  itens: HabitoItemJournal[];
  sugestoes: HabitoSugestao[];
  areas: string[];
}

export interface HabitoToggleResult {
  habito: Habito;
  checkin: HabitoCheckin;
  concluida: boolean;
  streak: number;
  bonus_dia?: {
    completo: boolean;
    moedas: number;
    streak_dias: number;
  } | null;
}

export interface Notificacao {
  id: number;
  icone: string;
  titulo: string;
  mensagem: string;
  tipo?: string | null;
  referencia_id?: number | null;
  payload?: Record<string, unknown> | null;
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

export interface AcademiaTreinoExercicio {
  id?: number;
  exercicio_chave: string;
  nome: string;
  icone: string;
  grupo: string;
  series: number;
  reps: number;
  carga_kg: number;
  ordem?: number;
  concluido?: boolean;
}

export interface AcademiaTreino {
  id: number;
  foco: string;
  titulo: string;
  exercicios: number;
  minutos: number;
  xp: number;
  dia_chave?: string | null;
  ativo?: boolean;
  concluido_em?: string | null;
  volume_kg?: number;
  itens?: AcademiaTreinoExercicio[];
}

export interface ExercicioCatalogo {
  chave: string;
  nome: string;
  icone: string;
  grupo: string;
  series_padrao: number;
  reps_padrao: number;
  carga_padrao: number;
}

export interface ExercicioCatalogoData {
  focos: string[];
  exercicios: ExercicioCatalogo[];
}

export interface EsporteCatalogo {
  chave: string;
  nome: string;
  icone: string;
  descricao: string;
  minutos_padrao: number;
  usa_distancia: boolean;
}

export interface EsporteResumo {
  total_semana: number;
  minutos_semana: number;
  xp_semana: number;
}

export interface EsporteSessao {
  id: number;
  esporte_chave: string;
  icone: string;
  nome: string;
  minutos: number;
  distancia_metros: number | null;
  xp: number;
  data: string | null;
  nota: string | null;
}

export interface AcademiaData {
  meta_semana: number;
  feitos: number;
  sequencia_treinos: number;
  semana_inicio: string;
  dias: AcademiaDia[];
  volumes: AcademiaVolume[];
  treino_hoje: AcademiaTreino | null;
  esportes?: EsporteCatalogo[];
  esporte_resumo?: EsporteResumo;
  esporte_sessoes?: EsporteSessao[];
}

export interface FinancasMes {
  ano_mes: string;
  label: string;
  curto: string;
}

export interface FinancasSerie {
  ano_mes: string;
  curto: string;
  receita_centavos: number;
  gastos_centavos: number;
  saldo_centavos: number;
}

export interface FinancasDistribuicao {
  categoria: string;
  nome: string;
  cor: string;
  valor_centavos: number;
  percentual: number;
}

export interface FinancasTransacao {
  id: number;
  tipo: 'receita' | 'despesa' | string;
  categoria: string;
  categoria_nome: string;
  categoria_cor: string;
  titulo: string;
  icone: string;
  valor_centavos: number;
  data: string;
}

export interface FinancasMeta {
  id: number;
  titulo: string;
  icone: string;
  categoria: string | null;
  valor_alvo_centavos: number;
  valor_atual_centavos: number;
  percentual: number;
}

export interface FinancasCategoria {
  chave: string;
  nome: string;
  cor: string;
  icone: string;
}

export interface FinancasCategorias {
  despesas: FinancasCategoria[];
  receita: FinancasCategoria;
}

export interface FinancasConexao {
  id: number;
  provider: string;
  item_id: string | null;
  connector_name: string | null;
  status: string;
  last_sync_at: string | null;
}

export interface FinancasPluggy {
  configured: boolean;
  local_sandbox: boolean;
  conexoes: FinancasConexao[];
}

export interface FinancasData {
  ano_mes: string;
  mes_label: string;
  meses: FinancasMes[];
  saldo_centavos: number;
  receita_centavos: number;
  gastos_centavos: number;
  serie_mensal: FinancasSerie[];
  distribuicao: FinancasDistribuicao[];
  recentes: FinancasTransacao[];
  transacoes: FinancasTransacao[];
  metas: FinancasMeta[];
  categorias: FinancasCategorias;
  pluggy?: FinancasPluggy;
}

export interface PluggyConnectToken {
  mode: string;
  access_token: string;
  include_sandbox?: boolean;
}

export interface PluggySyncResult {
  importadas: number;
  atualizadas: number;
}

export function avatarAssetKey(key: string): string {
  const trimmed = (key || '').trim();
  if (!trimmed) return 'guara_serio';
  return trimmed.replace(/^avatar_/, '');
}
