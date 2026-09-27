// Funções utilitárias para formatação de valores monetários em Real (BRL).

const formatadorMoeda = new Intl.NumberFormat('pt-BR', {
  style: 'currency',
  currency: 'BRL',
});

/** Formata um número como moeda brasileira (ex: 1500.5 -> "R$ 1.500,50"). */
export function formatarMoeda(valor: number): string {
  return formatadorMoeda.format(valor);
}
