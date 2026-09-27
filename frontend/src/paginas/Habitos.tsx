import { Check, ChevronLeft, ChevronRight, Droplet, ListChecks, Minus, Plus, Smile, Trash2 } from 'lucide-react';
import { type FormEvent, useEffect, useState } from 'react';
import { clienteApi } from '../api/cliente';
import { Carregando } from '../componentes/Carregando';
import type { Habito, OpcaoHumor, RegistroAgua, RegistroHumor } from '../tipos';
import {
  adicionarSemanas,
  formatarDataISO,
  formatarIntervaloDaSemana,
  NOMES_DIAS_SEMANA,
  obterDiasDaSemana,
  obterInicioDaSemana,
} from '../utilitarios/data';

/** Emojis usados para representar cada opção de humor. */
const EMOJI_POR_HUMOR: Record<OpcaoHumor, string> = {
  muito_feliz: '😄',
  feliz: '🙂',
  neutro: '😐',
  triste: '🙁',
  muito_triste: '😢',
};

/** Ordem de rotação usada ao clicar no emoji de humor de um dia. */
const ORDEM_HUMORES: OpcaoHumor[] = ['muito_feliz', 'feliz', 'neutro', 'triste', 'muito_triste'];

/** Tela de acompanhamento de hábitos, humor e consumo de água da semana. */
export function Habitos() {
  const [inicioSemana, setInicioSemana] = useState(() => obterInicioDaSemana(new Date()));
  const [habitos, setHabitos] = useState<Habito[]>([]);
  const [registrosHumor, setRegistrosHumor] = useState<RegistroHumor[]>([]);
  const [registrosAgua, setRegistrosAgua] = useState<RegistroAgua[]>([]);
  const [carregando, setCarregando] = useState(true);
  const [novoNomeHabito, setNovoNomeHabito] = useState('');
  const [formularioHabitoAberto, setFormularioHabitoAberto] = useState(false);

  const diasDaSemana = obterDiasDaSemana(inicioSemana);
  const dataInicio = formatarDataISO(diasDaSemana[0]);
  const dataFim = formatarDataISO(diasDaSemana[6]);
  const hojeISO = formatarDataISO(new Date());

  // Busca hábitos, humor e água sempre que a semana selecionada mudar.
  useEffect(() => {
    async function buscarDadosDaSemana() {
      setCarregando(true);

      const [respostaHabitos, respostaHumor, respostaAgua] = await Promise.all([
        clienteApi.get<Habito[]>('/habitos', { params: { data_inicio: dataInicio, data_fim: dataFim } }),
        clienteApi.get<RegistroHumor[]>('/humor', { params: { data_inicio: dataInicio, data_fim: dataFim } }),
        clienteApi.get<RegistroAgua[]>('/agua', { params: { data_inicio: dataInicio, data_fim: dataFim } }),
      ]);

      setHabitos(respostaHabitos.data);
      setRegistrosHumor(respostaHumor.data);
      setRegistrosAgua(respostaAgua.data);
      setCarregando(false);
    }

    buscarDadosDaSemana();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [inicioSemana]);

  /** Verifica se um hábito está marcado como concluído em determinado dia. */
  function habitoConcluidoNoDia(habito: Habito, dataISO: string): boolean {
    return Boolean(habito.registros?.find((registro) => registro.data.startsWith(dataISO))?.concluido);
  }

  /** Alterna a marcação de um hábito em um dia da semana. */
  async function alternarHabitoNoDia(habito: Habito, dataISO: string) {
    setHabitos((atual) =>
      atual.map((item) => {
        if (item.id !== habito.id) return item;

        const jaConcluido = habitoConcluidoNoDia(item, dataISO);
        const registrosSemEsteDia = (item.registros ?? []).filter((r) => !r.data.startsWith(dataISO));

        return {
          ...item,
          registros: [
            ...registrosSemEsteDia,
            { id: 0, habito_id: item.id, data: dataISO, concluido: !jaConcluido },
          ],
        };
      }),
    );

    await clienteApi.patch(`/habitos/${habito.id}/registrar-dia`, { data: dataISO });
  }

  /** Cria um novo hábito. */
  async function criarHabito(evento: FormEvent) {
    evento.preventDefault();

    if (!novoNomeHabito.trim()) return;

    const resposta = await clienteApi.post<Habito>('/habitos', { nome: novoNomeHabito });

    setHabitos((atual) => [...atual, { ...resposta.data, registros: [] }]);
    setNovoNomeHabito('');
    setFormularioHabitoAberto(false);
  }

  /** Remove um hábito. */
  async function removerHabito(habito: Habito) {
    setHabitos((atual) => atual.filter((item) => item.id !== habito.id));
    await clienteApi.delete(`/habitos/${habito.id}`);
  }

  /** Retorna o humor registrado em um dia (ou null se não houver). */
  function humorDoDia(dataISO: string): OpcaoHumor | null {
    return registrosHumor.find((registro) => registro.data.startsWith(dataISO))?.humor ?? null;
  }

  /** Avança para o próximo humor da lista ao clicar no emoji de um dia. */
  async function alternarHumorDoDia(dataISO: string) {
    const humorAtual = humorDoDia(dataISO);
    const indiceAtual = humorAtual ? ORDEM_HUMORES.indexOf(humorAtual) : -1;
    const proximoHumor = ORDEM_HUMORES[(indiceAtual + 1) % ORDEM_HUMORES.length];

    setRegistrosHumor((atual) => [
      ...atual.filter((registro) => !registro.data.startsWith(dataISO)),
      { id: 0, usuario_id: 0, data: dataISO, humor: proximoHumor },
    ]);

    await clienteApi.post('/humor', { data: dataISO, humor: proximoHumor });
  }

  /** Quantidade de água (em ml) consumida hoje. */
  const aguaDeHoje = registrosAgua.find((registro) => registro.data.startsWith(hojeISO))?.quantidade_ml ?? 0;

  /** Adiciona uma gota de água ao dia de hoje. */
  async function adicionarGotaDeAgua() {
    const resposta = await clienteApi.post<RegistroAgua>('/agua/adicionar', { data: hojeISO });
    atualizarRegistroAgua(resposta.data);
  }

  /** Remove uma gota de água do dia de hoje. */
  async function removerGotaDeAgua() {
    const resposta = await clienteApi.post<RegistroAgua>('/agua/remover', { data: hojeISO });
    atualizarRegistroAgua(resposta.data);
  }

  /** Atualiza a lista local de registros de água com o valor mais recente. */
  function atualizarRegistroAgua(registroAtualizado: RegistroAgua) {
    setRegistrosAgua((atual) => [
      ...atual.filter((registro) => !registro.data.startsWith(hojeISO)),
      registroAtualizado,
    ]);
  }

  return (
    <div className="flex flex-col gap-6">
      {/* Cabeçalho com navegação entre semanas */}
      <header className="flex items-center justify-between">
        <button
          onClick={() => setInicioSemana((atual) => adicionarSemanas(atual, -1))}
          className="botao-circular"
        >
          <ChevronLeft size={20} />
        </button>
        <div className="text-center">
          <h1 className="font-titulo text-3xl leading-none text-tinta sm:text-4xl">Hábitos</h1>
          <p className="text-sm text-tinta-suave">{formatarIntervaloDaSemana(inicioSemana)}</p>
        </div>
        <button
          onClick={() => setInicioSemana((atual) => adicionarSemanas(atual, 1))}
          className="botao-circular"
        >
          <ChevronRight size={20} />
        </button>
      </header>

      {carregando ? (
        <Carregando />
      ) : (
        <>
          {/* Quadro de hábitos */}
          <section className="cartao border-l-4 border-l-destaque-verde-escuro">
            <h2 className="titulo-secao">
              <ListChecks size={20} className="text-destaque-verde-escuro" /> Quadro de hábitos
            </h2>
            <div className="mb-2 grid grid-cols-[minmax(0,1fr)_repeat(7,1.75rem)] items-center gap-1 text-center text-[11px] font-bold uppercase text-tinta-fraca sm:grid-cols-[minmax(0,1fr)_repeat(7,2rem)]">
              <span />
              {NOMES_DIAS_SEMANA.map((nome, indice) => (
                <span key={nome} className={formatarDataISO(diasDaSemana[indice]) === hojeISO ? 'text-destaque-verde-escuro' : ''}>
                  {nome[0]}
                </span>
              ))}
            </div>

            <div className="flex flex-col gap-1">
              {habitos.map((habito) => (
                <div
                  key={habito.id}
                  className="grid grid-cols-[minmax(0,1fr)_repeat(7,1.75rem)] items-center gap-1 sm:grid-cols-[minmax(0,1fr)_repeat(7,2rem)]"
                >
                  <span className="truncate pr-1 text-sm text-tinta">{habito.nome}</span>
                  {diasDaSemana.map((dia) => {
                    const dataISO = formatarDataISO(dia);
                    const concluido = habitoConcluidoNoDia(habito, dataISO);

                    return (
                      <button
                        key={dataISO}
                        onClick={() => alternarHabitoNoDia(habito, dataISO)}
                        className="mx-auto flex h-9 w-9 items-center justify-center"
                        aria-label={`Marcar ${habito.nome} em ${dataISO}`}
                      >
                        <span
                          className={`flex h-6 w-6 items-center justify-center rounded-full border-2 transition-colors ${
                            concluido
                              ? 'border-destaque-verde-escuro bg-destaque-verde-escuro'
                              : 'border-papel-escuro bg-transparent'
                          }`}
                        >
                          {concluido && <Check size={13} strokeWidth={3} className="text-papel-claro" />}
                        </span>
                      </button>
                    );
                  })}
                </div>
              ))}

              {habitos.length === 0 && (
                <p className="text-xs italic text-tinta-fraca">Nenhum hábito cadastrado ainda.</p>
              )}
            </div>

            {formularioHabitoAberto ? (
              <form onSubmit={criarHabito} className="mt-3 flex gap-2">
                <input
                  autoFocus
                  type="text"
                  value={novoNomeHabito}
                  onChange={(evento) => setNovoNomeHabito(evento.target.value)}
                  placeholder="Nome do hábito..."
                  className="campo-texto min-w-0 flex-1"
                />
                <button
                  type="submit"
                  className="flex items-center justify-center rounded-xl bg-tinta px-3 text-papel-claro"
                  aria-label="Confirmar novo hábito"
                >
                  <Check size={16} />
                </button>
              </form>
            ) : (
              <button
                onClick={() => setFormularioHabitoAberto(true)}
                className="mt-3 flex items-center gap-1 text-xs font-semibold text-destaque-verde-escuro"
              >
                <Plus size={14} /> adicionar hábito
              </button>
            )}

            {habitos.length > 0 && (
              <ul className="mt-3 flex flex-wrap gap-3 border-t border-papel-escuro pt-3">
                {habitos.map((habito) => (
                  <li key={habito.id}>
                    <button
                      onClick={() => removerHabito(habito)}
                      className="flex items-center gap-1 text-[11px] text-tinta-fraca"
                      aria-label={`Remover hábito ${habito.nome}`}
                    >
                      <Trash2 size={12} /> {habito.nome}
                    </button>
                  </li>
                ))}
              </ul>
            )}
          </section>

          {/* Água e humor lado a lado em telas maiores */}
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
            {/* Consumo de água (dia de hoje) */}
            <section className="cartao border-l-4 border-l-destaque-azul-escuro">
              <h2 className="titulo-secao">
                <Droplet size={20} className="text-destaque-azul-escuro" fill="currentColor" /> Água de hoje
              </h2>
              <div className="flex items-center justify-between">
                <span className="text-sm font-semibold text-tinta-suave">{aguaDeHoje} ml</span>
                <div className="flex items-center gap-2">
                  <button
                    onClick={removerGotaDeAgua}
                    className="flex h-10 w-10 items-center justify-center rounded-full bg-papel-escuro text-tinta transition-transform active:scale-95"
                    aria-label="Remover copo de água"
                  >
                    <Minus size={16} />
                  </button>
                  <button
                    onClick={adicionarGotaDeAgua}
                    className="flex h-10 w-10 items-center justify-center rounded-full bg-destaque-azul-escuro text-papel-claro transition-transform active:scale-95"
                    aria-label="Adicionar copo de água"
                  >
                    <Plus size={16} />
                  </button>
                </div>
              </div>
            </section>

            {/* Humor da semana */}
            <section className="cartao border-l-4 border-l-destaque-rosa-escuro">
              <h2 className="titulo-secao">
                <Smile size={20} className="text-destaque-rosa-escuro" /> Humor da semana
              </h2>
              <div className="grid grid-cols-7 gap-0.5 text-center">
                {diasDaSemana.map((dia, indice) => {
                  const dataISO = formatarDataISO(dia);
                  const humor = humorDoDia(dataISO);

                  return (
                    <button
                      key={dataISO}
                      onClick={() => alternarHumorDoDia(dataISO)}
                      className="flex flex-col items-center gap-0.5 rounded-lg py-1 transition-colors hover:bg-destaque-rosa-claro"
                    >
                      <span className="text-xl">{humor ? EMOJI_POR_HUMOR[humor] : '⭘'}</span>
                      <span className="text-[10px] font-semibold text-tinta-fraca">{NOMES_DIAS_SEMANA[indice][0]}</span>
                    </button>
                  );
                })}
              </div>
            </section>
          </div>
        </>
      )}
    </div>
  );
}
