// Tipos TypeScript que espelham os models retornados pela API Laravel.

/** Usuário autenticado no sistema. */
export interface Usuario {
  id: number;
  nome: string;
  email: string;
}

/** Categoria usada para organizar e colorir tarefas. */
export interface Categoria {
  id: number;
  usuario_id: number;
  nome: string;
  cor: string;
}

/** Tarefa de rotina vinculada a um dia específico. */
export interface Tarefa {
  id: number;
  usuario_id: number;
  categoria_id: number | null;
  titulo: string;
  descricao: string | null;
  data: string; // formato ISO (YYYY-MM-DD)
  concluida: boolean;
}

/** Registro de conclusão de um hábito em um dia específico. */
export interface RegistroHabito {
  id: number;
  habito_id: number;
  data: string;
  concluido: boolean;
}

/** Hábito acompanhado no quadro semanal. */
export interface Habito {
  id: number;
  usuario_id: number;
  nome: string;
  ordem: number;
  ativo: boolean;
  registros?: RegistroHabito[];
}

/** Meta/objetivo da lista de marcadores da semana. */
export interface Meta {
  id: number;
  usuario_id: number;
  titulo: string;
  concluida: boolean;
  ordem: number;
}

/** Opções possíveis de humor diário. */
export type OpcaoHumor = 'muito_feliz' | 'feliz' | 'neutro' | 'triste' | 'muito_triste';

/** Registro do humor escolhido em um dia específico. */
export interface RegistroHumor {
  id: number;
  usuario_id: number;
  data: string;
  humor: OpcaoHumor;
}

/** Registro da quantidade de água consumida em um dia específico. */
export interface RegistroAgua {
  id: number;
  usuario_id: number;
  data: string;
  quantidade_ml: number;
}

/** Texto de reflexão livre sobre a semana. */
export interface Reflexao {
  id: number;
  usuario_id: number;
  semana_inicio: string;
  texto: string;
}

/** Tipo de uma transação financeira: entrada ou saída de dinheiro. */
export type TipoTransacao = 'receita' | 'despesa';

/** Transação financeira (receita ou despesa) lançada pelo usuário. */
export interface Transacao {
  id: number;
  usuario_id: number;
  tipo: TipoTransacao;
  categoria: string;
  descricao: string | null;
  valor: string; // vem da API como string decimal (ex: "150.50")
  data: string;
}

/** Resumo financeiro de um período: total de receitas, despesas e saldo. */
export interface ResumoFinanceiro {
  total_receitas: number;
  total_despesas: number;
  saldo: number;
}
