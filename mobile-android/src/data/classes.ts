/** Helpers de tema das classes — dados vêm de GET /api/v1/classes. */

export type ClasseHeroi = {
  key: string;
  nome: string;
  emoji: string;
  descricao: string;
  bonus: string[];
  tema: string;
  cor: string;
};

const TEMA_COR: Record<string, string> = {
  laranja: '#FF7A47',
  ciano: '#59D9EB',
  verde: '#59DB85',
  ambar: '#E8B86A',
  roxo: '#E8B86A',
};

export function corDoTema(tema: string): string {
  return TEMA_COR[tema] ?? '#E87830';
}

export function mapClasseApi(item: {
  key: string;
  nome: string;
  emoji: string;
  descricao: string;
  bonus: string[];
  tema: string;
}): ClasseHeroi {
  return {
    ...item,
    cor: corDoTema(item.tema),
  };
}
