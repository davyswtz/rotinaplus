// Funções utilitárias para trabalhar com datas e semanas (segunda a domingo).

/** Nomes abreviados dos dias da semana, começando na segunda-feira. */
export const NOMES_DIAS_SEMANA = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

/** Nomes dos meses em português. */
export const NOMES_MESES = [
  'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
  'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
];

/** Converte uma data para o formato ISO usado pela API (YYYY-MM-DD). */
export function formatarDataISO(data: Date): string {
  const ano = data.getFullYear();
  const mes = String(data.getMonth() + 1).padStart(2, '0');
  const dia = String(data.getDate()).padStart(2, '0');

  return `${ano}-${mes}-${dia}`;
}

/** Retorna a segunda-feira da semana à qual a data pertence. */
export function obterInicioDaSemana(data: Date): Date {
  const copia = new Date(data);
  const diaDaSemana = copia.getDay(); // 0 = domingo, 1 = segunda, ...
  const deslocamento = diaDaSemana === 0 ? -6 : 1 - diaDaSemana;

  copia.setDate(copia.getDate() + deslocamento);
  copia.setHours(0, 0, 0, 0);

  return copia;
}

/** Retorna um array com as 7 datas (segunda a domingo) de uma semana, a partir do seu início. */
export function obterDiasDaSemana(inicioDaSemana: Date): Date[] {
  return Array.from({ length: 7 }, (_, indice) => {
    const dia = new Date(inicioDaSemana);
    dia.setDate(dia.getDate() + indice);

    return dia;
  });
}

/** Soma (ou subtrai) semanas a partir de uma data. */
export function adicionarSemanas(data: Date, quantidade: number): Date {
  const copia = new Date(data);
  copia.setDate(copia.getDate() + quantidade * 7);

  return copia;
}

/** Monta um texto amigável do intervalo da semana (ex: "28 Set - 4 Out"). */
export function formatarIntervaloDaSemana(inicioDaSemana: Date): string {
  const dias = obterDiasDaSemana(inicioDaSemana);
  const primeiro = dias[0];
  const ultimo = dias[6];

  const mesPrimeiro = NOMES_MESES[primeiro.getMonth()].slice(0, 3);
  const mesUltimo = NOMES_MESES[ultimo.getMonth()].slice(0, 3);

  return `${primeiro.getDate()} ${mesPrimeiro} - ${ultimo.getDate()} ${mesUltimo}`;
}

/** Retorna o primeiro dia (dia 1) do mês de uma data. */
export function obterInicioDoMes(data: Date): Date {
  return new Date(data.getFullYear(), data.getMonth(), 1);
}

/** Retorna o último dia do mês de uma data. */
export function obterFimDoMes(data: Date): Date {
  return new Date(data.getFullYear(), data.getMonth() + 1, 0);
}

/** Soma (ou subtrai) meses a partir de uma data, mantendo o dia 1. */
export function adicionarMeses(data: Date, quantidade: number): Date {
  return new Date(data.getFullYear(), data.getMonth() + quantidade, 1);
}

/** Formata o nome do mês e o ano (ex: "Setembro 2026"). */
export function formatarMesAno(data: Date): string {
  return `${NOMES_MESES[data.getMonth()]} ${data.getFullYear()}`;
}
