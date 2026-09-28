import { Check, ChevronLeft, ChevronRight, Droplet, Plus, X } from 'lucide-react';
import { type FormEvent, useEffect, useRef, useState } from 'react';
import { clienteApi } from '../api/cliente';
import { CamadaDesenho } from '../componentes/CamadaDesenho';
import { Carregando } from '../componentes/Carregando';
import { type PosicaoWidget, type TamanhoWidget, WidgetArrastavel } from '../componentes/WidgetArrastavel';
import type { Habito, Meta, OpcaoHumor, RegistroAgua, RegistroHumor, Tarefa } from '../tipos';
import {
  adicionarSemanas,
  formatarCabecalhoMesDaSemana,
  formatarDataISO,
  formatarIntervaloDaSemana,
  NOMES_DIAS_SEMANA,
  obterDiasDaSemana,
  obterInicioDaSemana,
  obterNumeroDaSemana,
} from '../utilitarios/data';

/** Emojis usados para representar cada opção de humor (mesmo mapeamento da tela de Hábitos). */
const EMOJI_POR_HUMOR: Record<OpcaoHumor, string> = {
  muito_feliz: '😄',
  feliz: '🙂',
  neutro: '😐',
  triste: '🙁',
  muito_triste: '😢',
};

const ORDEM_HUMORES: OpcaoHumor[] = ['muito_feliz', 'feliz', 'neutro', 'triste', 'muito_triste'];

const QUANTIDADE_MAX_GOTAS = 7;
const ML_POR_GOTA = 250;

const CHAVE_LAYOUT = 'rotina-plus-layout-pagina-direita-v2';
const CHAVE_TRAVADO = 'rotina-plus-caderno-travado';
const CHAVE_NOTAS_DIA = 'rotina-plus-notas-do-dia';

function carregarNotasDoDia(): Record<string, string> {
  try {
    const bruto = localStorage.getItem(CHAVE_NOTAS_DIA);
    return bruto ? JSON.parse(bruto) : {};
  } catch {
    return {};
  }
}

/**
 * Posição inicial de cada bloco na folha direita, usada apenas na primeira vez
 * (antes do usuário arrastar algo). Evita os dois cantos de cima: o esquerdo é
 * reservado para a barra de ferramentas de desenho e o direito para o botão
 * de tema claro/escuro, que fica fixo por cima de tudo.
 */
const LAYOUT_PADRAO: Record<string, PosicaoWidget> = {
  habitos: { x: 3, y: 18 },
  agua: { x: 68, y: 18 },
  humor: { x: 68, y: 40 },
  progresso: { x: 3, y: 56 },
  metas: { x: 3, y: 66 },
  reflexao: { x: 3, y: 83 },
};

function carregarLayoutSalvo(): Record<string, PosicaoWidget> {
  try {
    const bruto = localStorage.getItem(CHAVE_LAYOUT);
    return bruto ? { ...LAYOUT_PADRAO, ...JSON.parse(bruto) } : LAYOUT_PADRAO;
  } catch {
    return LAYOUT_PADRAO;
  }
}

const CHAVE_TAMANHOS = 'rotina-plus-tamanhos-pagina-direita';

/** Largura inicial de cada bloco (a altura começa automática, só vira fixa quando o usuário redimensiona). */
const TAMANHOS_PADRAO: Record<string, TamanhoWidget> = {
  habitos: { largura: 420, altura: null },
  agua: { largura: 190, altura: null },
  humor: { largura: 190, altura: null },
  progresso: { largura: 320, altura: null },
  metas: { largura: 320, altura: null },
  reflexao: { largura: 340, altura: null },
};

function carregarTamanhosSalvos(): Record<string, TamanhoWidget> {
  try {
    const bruto = localStorage.getItem(CHAVE_TAMANHOS);
    return bruto ? { ...TAMANHOS_PADRAO, ...JSON.parse(bruto) } : TAMANHOS_PADRAO;
  } catch {
    return TAMANHOS_PADRAO;
  }
}

const CHAVE_WIDGETS_ATIVOS = 'rotina-plus-widgets-ativos';

/** Todos os blocos que existem pra colocar na folha direita — a lista que aparece no quadradinho de "adicionar". */
const WIDGETS_DISPONIVEIS: { id: string; titulo: string }[] = [
  { id: 'habitos', titulo: 'Hábitos' },
  { id: 'agua', titulo: 'Água' },
  { id: 'humor', titulo: 'Humor' },
  { id: 'progresso', titulo: 'Progresso da semana' },
  { id: 'metas', titulo: 'Metas da semana' },
  { id: 'reflexao', titulo: 'Reflexão da semana' },
];

function carregarWidgetsAtivos(): string[] {
  try {
    const bruto = localStorage.getItem(CHAVE_WIDGETS_ATIVOS);
    return bruto ? JSON.parse(bruto) : [];
  } catch {
    return [];
  }
}

/**
 * Visão "caderno aberto" exibida apenas em telas desktop (lg+): reúne a semana,
 * o quadro de hábitos, água, humor, metas e a reflexão em uma única página de
 * duas folhas, no estilo de um planner físico (fundo escuro, papel creme,
 * linhas pontilhadas e fontes manuscritas nos títulos).
 */
export function CadernoDesktop() {
  const [inicioSemana, setInicioSemana] = useState(() => obterInicioDaSemana(new Date()));
  const [tarefas, setTarefas] = useState<Tarefa[]>([]);
  const [percentualConcluido, setPercentualConcluido] = useState(0);
  const [habitos, setHabitos] = useState<Habito[]>([]);
  const [registrosHumor, setRegistrosHumor] = useState<RegistroHumor[]>([]);
  const [registrosAgua, setRegistrosAgua] = useState<RegistroAgua[]>([]);
  const [metas, setMetas] = useState<Meta[]>([]);
  const [textoReflexao, setTextoReflexao] = useState('');
  const [carregando, setCarregando] = useState(true);
  const [salvandoReflexao, setSalvandoReflexao] = useState(false);

  const [diaComFormularioAberto, setDiaComFormularioAberto] = useState<string | null>(null);
  const [novoTituloTarefa, setNovoTituloTarefa] = useState('');
  const [novoTituloMeta, setNovoTituloMeta] = useState('');
  const [novoNomeHabito, setNovoNomeHabito] = useState('');
  const [formularioHabitoAberto, setFormularioHabitoAberto] = useState(false);

  const [layout, setLayout] = useState<Record<string, PosicaoWidget>>(carregarLayoutSalvo);
  const [travado, setTravado] = useState(() => localStorage.getItem(CHAVE_TRAVADO) === '1');
  const [notasDia, setNotasDia] = useState<Record<string, string>>(carregarNotasDoDia);
  const [widgetsAtivos, setWidgetsAtivos] = useState<string[]>(carregarWidgetsAtivos);
  const [tamanhos, setTamanhos] = useState<Record<string, TamanhoWidget>>(carregarTamanhosSalvos);
  const paginaDireitaRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    localStorage.setItem(CHAVE_LAYOUT, JSON.stringify(layout));
  }, [layout]);

  useEffect(() => {
    localStorage.setItem(CHAVE_TAMANHOS, JSON.stringify(tamanhos));
  }, [tamanhos]);

  useEffect(() => {
    localStorage.setItem(CHAVE_TRAVADO, travado ? '1' : '0');
  }, [travado]);

  useEffect(() => {
    localStorage.setItem(CHAVE_NOTAS_DIA, JSON.stringify(notasDia));
  }, [notasDia]);

  useEffect(() => {
    localStorage.setItem(CHAVE_WIDGETS_ATIVOS, JSON.stringify(widgetsAtivos));
  }, [widgetsAtivos]);

  /** Atualiza o texto livre escrito ao lado das tarefas de um dia (não é tarefa, é anotação solta). */
  function atualizarNotaDoDia(dataISO: string, texto: string) {
    setNotasDia((atual) => ({ ...atual, [dataISO]: texto }));
  }

  function moverWidget(id: string, posicao: PosicaoWidget) {
    setLayout((atual) => ({ ...atual, [id]: posicao }));
  }

  function redimensionarWidget(id: string, tamanho: TamanhoWidget) {
    setTamanhos((atual) => ({ ...atual, [id]: tamanho }));
  }

  /** Coloca um bloco na folha direita (escolhido no quadradinho de adicionar). */
  function adicionarWidget(id: string) {
    setWidgetsAtivos((atual) => (atual.includes(id) ? atual : [...atual, id]));
  }

  /** Tira um bloco da folha direita (botão de remover no cabeçalho do cartão). */
  function removerWidget(id: string) {
    setWidgetsAtivos((atual) => atual.filter((atualId) => atualId !== id));
  }

  const widgetsParaAdicionar = WIDGETS_DISPONIVEIS.filter((widget) => !widgetsAtivos.includes(widget.id));

  const diasDaSemana = obterDiasDaSemana(inicioSemana);
  const dataInicio = formatarDataISO(diasDaSemana[0]);
  const dataFim = formatarDataISO(diasDaSemana[6]);
  const hojeISO = formatarDataISO(new Date());

  // Busca todos os dados da semana (tarefas, hábitos, humor, água, reflexão) de uma vez.
  useEffect(() => {
    async function buscarDadosDaSemana() {
      setCarregando(true);

      const [respostaTarefas, respostaHabitos, respostaHumor, respostaAgua, respostaReflexao, respostaMetas] =
        await Promise.all([
          clienteApi.get('/tarefas', { params: { data_inicio: dataInicio, data_fim: dataFim } }),
          clienteApi.get<Habito[]>('/habitos', { params: { data_inicio: dataInicio, data_fim: dataFim } }),
          clienteApi.get<RegistroHumor[]>('/humor', { params: { data_inicio: dataInicio, data_fim: dataFim } }),
          clienteApi.get<RegistroAgua[]>('/agua', { params: { data_inicio: dataInicio, data_fim: dataFim } }),
          clienteApi.get<{ texto: string } | null>('/reflexao', { params: { semana_inicio: dataInicio } }),
          clienteApi.get<Meta[]>('/metas'),
        ]);

      setTarefas(respostaTarefas.data.tarefas);
      setPercentualConcluido(respostaTarefas.data.percentual_concluido);
      setHabitos(respostaHabitos.data);
      setRegistrosHumor(respostaHumor.data);
      setRegistrosAgua(respostaAgua.data);
      setTextoReflexao(respostaReflexao.data?.texto ?? '');
      setMetas(respostaMetas.data);
      setCarregando(false);
    }

    buscarDadosDaSemana();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [inicioSemana]);

  function tarefasDoDia(data: Date): Tarefa[] {
    const dataISO = formatarDataISO(data);
    return tarefas.filter((tarefa) => tarefa.data.startsWith(dataISO));
  }

  async function alternarConclusaoTarefa(tarefa: Tarefa) {
    setTarefas((atual) =>
      atual.map((item) => (item.id === tarefa.id ? { ...item, concluida: !item.concluida } : item)),
    );
    await clienteApi.patch(`/tarefas/${tarefa.id}/concluir`);
  }

  async function removerTarefa(tarefa: Tarefa) {
    setTarefas((atual) => atual.filter((item) => item.id !== tarefa.id));
    await clienteApi.delete(`/tarefas/${tarefa.id}`);
  }

  async function criarTarefa(evento: FormEvent, data: Date) {
    evento.preventDefault();
    if (!novoTituloTarefa.trim()) return;

    const resposta = await clienteApi.post<Tarefa>('/tarefas', {
      titulo: novoTituloTarefa,
      data: formatarDataISO(data),
    });

    setTarefas((atual) => [...atual, resposta.data]);
    setNovoTituloTarefa('');
    setDiaComFormularioAberto(null);
  }

  function habitoConcluidoNoDia(habito: Habito, dataISO: string): boolean {
    return Boolean(habito.registros?.find((registro) => registro.data.startsWith(dataISO))?.concluido);
  }

  async function alternarHabitoNoDia(habito: Habito, dataISO: string) {
    setHabitos((atual) =>
      atual.map((item) => {
        if (item.id !== habito.id) return item;

        const jaConcluido = habitoConcluidoNoDia(item, dataISO);
        const registrosSemEsteDia = (item.registros ?? []).filter((r) => !r.data.startsWith(dataISO));

        return {
          ...item,
          registros: [...registrosSemEsteDia, { id: 0, habito_id: item.id, data: dataISO, concluido: !jaConcluido }],
        };
      }),
    );

    await clienteApi.patch(`/habitos/${habito.id}/registrar-dia`, { data: dataISO });
  }

  async function criarHabito(evento: FormEvent) {
    evento.preventDefault();
    if (!novoNomeHabito.trim()) return;

    const resposta = await clienteApi.post<Habito>('/habitos', { nome: novoNomeHabito });
    setHabitos((atual) => [...atual, { ...resposta.data, registros: [] }]);
    setNovoNomeHabito('');
    setFormularioHabitoAberto(false);
  }

  async function removerHabito(habito: Habito) {
    setHabitos((atual) => atual.filter((item) => item.id !== habito.id));
    await clienteApi.delete(`/habitos/${habito.id}`);
  }

  function humorDoDia(dataISO: string): OpcaoHumor | null {
    return registrosHumor.find((registro) => registro.data.startsWith(dataISO))?.humor ?? null;
  }

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

  const aguaDeHoje = registrosAgua.find((registro) => registro.data.startsWith(hojeISO))?.quantidade_ml ?? 0;
  const gotasPreenchidas = Math.min(Math.round(aguaDeHoje / ML_POR_GOTA), QUANTIDADE_MAX_GOTAS);

  /** Clique numa gota: ajusta a água de hoje para o nível clicado (ou zera, se já estiver nele). */
  async function definirNivelDeAgua(nivel: number) {
    const novoNivel = gotasPreenchidas === nivel ? nivel - 1 : nivel;
    const diferencaDeGotas = novoNivel - gotasPreenchidas;
    if (diferencaDeGotas === 0) return;

    const rota = diferencaDeGotas > 0 ? '/agua/adicionar' : '/agua/remover';
    let resposta;
    for (let i = 0; i < Math.abs(diferencaDeGotas); i++) {
      resposta = await clienteApi.post<RegistroAgua>(rota, { data: hojeISO });
    }

    if (resposta) {
      setRegistrosAgua((atual) => [...atual.filter((registro) => !registro.data.startsWith(hojeISO)), resposta!.data]);
    }
  }

  async function criarMeta(evento: FormEvent) {
    evento.preventDefault();
    if (!novoTituloMeta.trim()) return;

    const resposta = await clienteApi.post<Meta>('/metas', { titulo: novoTituloMeta });
    setMetas((atual) => [...atual, resposta.data]);
    setNovoTituloMeta('');
  }

  async function alternarConclusaoMeta(meta: Meta) {
    setMetas((atual) => atual.map((item) => (item.id === meta.id ? { ...item, concluida: !item.concluida } : item)));
    await clienteApi.patch(`/metas/${meta.id}/concluir`);
  }

  async function removerMeta(meta: Meta) {
    setMetas((atual) => atual.filter((item) => item.id !== meta.id));
    await clienteApi.delete(`/metas/${meta.id}`);
  }

  async function salvarReflexao() {
    setSalvandoReflexao(true);
    try {
      await clienteApi.post('/reflexao', { semana_inicio: dataInicio, texto: textoReflexao });
    } finally {
      setSalvandoReflexao(false);
    }
  }

  // Grade compartilhada pelo cabeçalho e pelas linhas do quadro de hábitos, para tudo ficar alinhado.
  const GRADE_HABITOS = 'grid-cols-[minmax(0,1fr)_repeat(7,2rem)]';

  return (
    <div className="fixed inset-y-0 left-0 right-0 z-0 flex items-center justify-center bg-[rgb(var(--caderno-fundo))] p-10 lg:left-60">

      {/* O "livro": duas folhas lado a lado, com uma margem em volta em vez de ocupar a tela toda.
          A sombra em camadas simula a borracha/pilha de folhas por baixo da página de cima. */}
      <div
        className="relative grid h-full max-h-[880px] w-full max-w-[1480px] grid-cols-2 overflow-hidden rounded-[28px] bg-papel-claro"
        style={{
          boxShadow:
            '0 1px 0 1px rgb(var(--papel-escuro)), 0 3px 0 2px rgb(var(--papel-claro)), 0 5px 0 3px rgb(var(--papel-escuro)), 0 7px 0 4px rgb(var(--papel-claro)), 0 35px 60px -15px rgba(0, 0, 0, 0.55)',
        }}
      >
        {/* Lombada: sombra funda bem no meio (a "dobra") e um leve realce onde cada
            página começa a se curvar pra fora dela — o que dá a sensação de livro aberto. */}
        <div
          className="pointer-events-none absolute inset-y-0 left-1/2 z-10 w-24 -translate-x-1/2"
          style={{
            background:
              'linear-gradient(to right, transparent 0%, rgba(0,0,0,0.04) 30%, rgba(0,0,0,0.22) 50%, rgba(0,0,0,0.04) 70%, transparent 100%)',
          }}
        />

        <button
          onClick={() => setInicioSemana((atual) => adicionarSemanas(atual, -1))}
          aria-label="Semana anterior"
          className="absolute left-5 top-1/2 z-20 flex h-11 w-11 -translate-y-1/2 items-center justify-center rounded-full border border-tinta/15 bg-papel-claro text-tinta-suave shadow-papel transition-colors hover:bg-papel-escuro hover:text-tinta"
        >
          <ChevronLeft size={20} />
        </button>

        <button
          onClick={() => setInicioSemana((atual) => adicionarSemanas(atual, 1))}
          aria-label="Próxima semana"
          className="absolute right-5 top-1/2 z-20 flex h-11 w-11 -translate-y-1/2 items-center justify-center rounded-full border border-tinta/15 bg-papel-claro text-tinta-suave shadow-papel transition-colors hover:bg-papel-escuro hover:text-tinta"
        >
          <ChevronRight size={20} />
        </button>

          {/* Folha esquerda: semana */}
          <div
            className="sem-scrollbar flex flex-col overflow-y-auto p-[44px] xl:p-[66px]"
            style={{ boxShadow: 'inset -24px 0 24px -24px rgba(0,0,0,0.18)' }}
          >
            <header className="mb-[44px] flex items-baseline justify-between gap-4">
              <h1 className="font-titulo text-4xl leading-none text-tinta">{formatarCabecalhoMesDaSemana(inicioSemana)}</h1>
              <p className="whitespace-nowrap text-[11px] font-bold uppercase tracking-wider text-tinta-fraca">
                Semana {obterNumeroDaSemana(inicioSemana)} · {formatarIntervaloDaSemana(inicioSemana)}
              </p>
            </header>

            {carregando ? (
              <Carregando />
            ) : (
              <ul className="flex flex-1 flex-col divide-y divide-dashed divide-papel-escuro">
                {diasDaSemana.map((dia, indice) => {
                  const dataISO = formatarDataISO(dia);
                  const tarefasDesteDia = tarefasDoDia(dia);
                  const formularioAberto = diaComFormularioAberto === dataISO;
                  const ehHoje = dataISO === hojeISO;
                  const ehSabado = indice === 5;
                  const ehDomingo = indice === 6;

                  return (
                    <li key={dataISO} className="group flex py-[11px] first:pt-0 last:pb-0">
                      {/* Coluna esquerda: data + tarefas */}
                      <div className="flex flex-[1.15] gap-[22px] pr-[22px]">
                        <div className="w-12 shrink-0 text-center">
                          <span
                            className={`relative inline-block text-2xl font-extrabold leading-none ${
                              ehDomingo ? 'text-destaque-rosa-escuro' : ehSabado ? 'text-destaque-azul-escuro' : 'text-tinta'
                            }`}
                          >
                            {dia.getDate()}
                            {ehHoje && <span className="absolute -bottom-1.5 left-0 h-[3px] w-full rounded-full bg-current" />}
                          </span>
                          <span className="mt-1 block text-[10px] font-bold uppercase tracking-wider text-tinta-fraca">
                            {NOMES_DIAS_SEMANA[indice]}
                          </span>
                        </div>

                        <div className="min-w-0 flex-1">
                          <ul className="flex flex-col">
                            {tarefasDesteDia.map((tarefa) => (
                              <li key={tarefa.id} className="group/tarefa flex h-[22px] items-center gap-2.5">
                                <button
                                  onClick={() => alternarConclusaoTarefa(tarefa)}
                                  aria-label={tarefa.concluida ? 'Marcar como pendente' : 'Marcar como concluída'}
                                  className={`flex h-4 w-4 shrink-0 items-center justify-center rounded-[4px] border transition-colors ${
                                    tarefa.concluida
                                      ? 'border-tinta bg-tinta text-papel-claro'
                                      : 'border-tinta-fraca/70 text-transparent'
                                  }`}
                                >
                                  <Check size={10} strokeWidth={3} />
                                </button>
                                <span className={`flex-1 truncate font-manuscrito text-[17px] leading-none ${tarefa.concluida ? 'text-tinta-fraca line-through' : 'text-tinta'}`}>
                                  {tarefa.titulo}
                                </span>
                                <button
                                  onClick={() => removerTarefa(tarefa)}
                                  className="opacity-0 transition-opacity group-hover/tarefa:opacity-100"
                                  aria-label="Remover tarefa"
                                >
                                  <X size={12} className="text-tinta-fraca" />
                                </button>
                              </li>
                            ))}

                            {tarefasDesteDia.length === 0 && !formularioAberto && (
                              <li className="flex h-[22px] items-center font-manuscrito text-[15px] italic leading-none text-tinta-fraca/60">
                                Nenhuma tarefa
                              </li>
                            )}
                          </ul>

                          {formularioAberto ? (
                            <form onSubmit={(evento) => criarTarefa(evento, dia)} className="flex h-[22px] items-center gap-1.5">
                              <input
                                autoFocus
                                type="text"
                                value={novoTituloTarefa}
                                onChange={(evento) => setNovoTituloTarefa(evento.target.value)}
                                onBlur={() => !novoTituloTarefa && setDiaComFormularioAberto(null)}
                                placeholder="Nova tarefa..."
                                className="min-w-0 flex-1 bg-transparent font-manuscrito text-[17px] leading-none text-tinta outline-none"
                              />
                              <button type="submit" aria-label="Confirmar nova tarefa" className="text-tinta-fraca hover:text-tinta">
                                <Check size={14} />
                              </button>
                            </form>
                          ) : (
                            <button
                              onClick={() => setDiaComFormularioAberto(dataISO)}
                              className="flex h-[22px] items-center gap-1 text-[11px] font-semibold leading-none text-tinta-fraca opacity-0 transition-opacity hover:text-tinta group-hover:opacity-100"
                            >
                              <Plus size={11} /> adicionar tarefa
                            </button>
                          )}
                        </div>
                      </div>

                      {/* Coluna direita: espaço livre pra escrever qualquer coisa nesse dia (não é tarefa, é anotação solta). */}
                      <div className="flex-[0.85] border-l border-dashed border-papel-escuro pl-[22px]">
                        <textarea
                          value={notasDia[dataISO] ?? ''}
                          onChange={(evento) => atualizarNotaDoDia(dataISO, evento.target.value)}
                          placeholder="Escreva aqui..."
                          rows={3}
                          className="sem-scrollbar w-full resize-none overflow-y-auto bg-transparent font-manuscrito text-[15px] italic leading-[22px] text-tinta-suave outline-none placeholder:text-tinta-fraca/50"
                        />
                      </div>
                    </li>
                  );
                })}
              </ul>
            )}
          </div>

          {/* Folha direita: hábitos, água, humor, metas e reflexão — cada bloco é um
              widget que o usuário arrasta e solta onde quiser nesta folha. */}
          <div
            ref={paginaDireitaRef}
            className="papel-quadriculado-fino relative overflow-hidden"
            style={{ boxShadow: 'inset 24px 0 24px -24px rgba(0,0,0,0.18)' }}
          >
            <CamadaDesenho
              travado={travado}
              aoAlternarTravado={() => setTravado((atual) => !atual)}
              widgetsParaAdicionar={widgetsParaAdicionar}
              aoAdicionarWidget={adicionarWidget}
            />
            {carregando ? (
              <div className="flex h-full items-center justify-center">
                <Carregando />
              </div>
            ) : (
              <>
                {widgetsAtivos.includes("habitos") && (
                <WidgetArrastavel id="habitos" titulo="Hábitos" posicao={layout.habitos} containerRef={paginaDireitaRef} onArrastar={moverWidget} tamanho={tamanhos.habitos ?? TAMANHOS_PADRAO.habitos} onRedimensionar={redimensionarWidget} travado={travado} onRemover={() => removerWidget("habitos")}>
                  <div className={`grid h-6 ${GRADE_HABITOS} items-center gap-1 text-center text-[11px] font-bold uppercase leading-none text-tinta-fraca`}>
                    <span />
                    {NOMES_DIAS_SEMANA.map((nome, indice) => {
                      const ehHojeColuna = formatarDataISO(diasDaSemana[indice]) === hojeISO;
                      return (
                        <span key={nome} className="flex items-center justify-center">
                          <span className={`flex h-4 w-4 items-center justify-center rounded-full ${ehHojeColuna ? 'bg-tinta text-papel-claro' : ''}`}>
                            {nome[0]}
                          </span>
                        </span>
                      );
                    })}
                  </div>

                  <div className="flex flex-col">
                    {habitos.map((habito) => (
                      <div key={habito.id} className={`group/habito grid h-8 ${GRADE_HABITOS} items-center gap-1`}>
                        <div className="relative flex min-w-0 items-center pr-2">
                          <span className="truncate text-[14px] font-medium leading-none text-tinta" title={habito.nome}>
                            {habito.nome}
                          </span>
                          <button
                            onClick={() => removerHabito(habito)}
                            aria-label={`Remover hábito ${habito.nome}`}
                            className="absolute right-1 flex h-5 w-5 shrink-0 items-center justify-center rounded-full bg-papel-claro text-tinta-fraca opacity-0 shadow-papel transition-opacity hover:text-tinta group-hover/habito:opacity-100"
                          >
                            <X size={11} />
                          </button>
                        </div>
                        {diasDaSemana.map((dia) => {
                          const dataISO = formatarDataISO(dia);
                          const concluido = habitoConcluidoNoDia(habito, dataISO);

                          return (
                            <button
                              key={dataISO}
                              onClick={() => alternarHabitoNoDia(habito, dataISO)}
                              aria-label={`Marcar ${habito.nome} em ${dataISO}`}
                              className={`mx-auto flex h-[22px] w-[22px] items-center justify-center rounded-full border-2 transition-colors ${
                                concluido ? 'border-tinta bg-tinta' : 'border-papel-escuro hover:border-tinta-fraca'
                              }`}
                            >
                              {concluido && <Check size={13} strokeWidth={3} className="text-papel-claro" />}
                            </button>
                          );
                        })}
                      </div>
                    ))}

                    {habitos.length === 0 && !formularioHabitoAberto && (
                      <p className="flex h-8 items-center text-[13px] italic leading-none text-tinta-fraca">
                        Nenhum hábito cadastrado ainda.
                      </p>
                    )}
                  </div>

                  {formularioHabitoAberto ? (
                    <form onSubmit={criarHabito} className="mt-1.5 flex items-center gap-1.5 border-t border-papel-escuro pt-1.5">
                      <input
                        autoFocus
                        type="text"
                        value={novoNomeHabito}
                        onChange={(evento) => setNovoNomeHabito(evento.target.value)}
                        onBlur={() => !novoNomeHabito && setFormularioHabitoAberto(false)}
                        placeholder="Nome do hábito..."
                        className="min-w-0 flex-1 bg-transparent text-[13.5px] text-tinta outline-none placeholder:text-tinta-fraca"
                      />
                      <button type="submit" aria-label="Confirmar novo hábito" className="text-tinta-fraca hover:text-tinta">
                        <Check size={15} />
                      </button>
                    </form>
                  ) : (
                    <button
                      onClick={() => setFormularioHabitoAberto(true)}
                      className="mt-1.5 flex items-center gap-1 border-t border-papel-escuro pt-1.5 text-[12px] font-semibold text-tinta-fraca hover:text-tinta"
                    >
                      <Plus size={13} /> adicionar hábito
                    </button>
                  )}
                </WidgetArrastavel>
                )}

                {widgetsAtivos.includes("agua") && (
                <WidgetArrastavel id="agua" titulo="Água" posicao={layout.agua} containerRef={paginaDireitaRef} onArrastar={moverWidget} tamanho={tamanhos.agua ?? TAMANHOS_PADRAO.agua} onRedimensionar={redimensionarWidget} travado={travado} onRemover={() => removerWidget("agua")}>
                  <div className="grid h-[22px] grid-cols-7 items-center gap-1">
                    {Array.from({ length: QUANTIDADE_MAX_GOTAS }).map((_, indice) => (
                      <button
                        key={indice}
                        onClick={() => definirNivelDeAgua(indice + 1)}
                        aria-label={`Definir água em ${(indice + 1) * ML_POR_GOTA}ml`}
                        className="flex items-center justify-center"
                      >
                        <Droplet
                          size={16}
                          className={indice < gotasPreenchidas ? 'text-destaque-azul-escuro' : 'text-papel-escuro'}
                          fill={indice < gotasPreenchidas ? 'currentColor' : 'none'}
                        />
                      </button>
                    ))}
                  </div>
                  <p className="flex h-[22px] items-center text-[11px] font-semibold leading-none text-tinta-fraca">
                    {aguaDeHoje}ml hoje
                  </p>
                </WidgetArrastavel>
                )}

                {widgetsAtivos.includes("humor") && (
                <WidgetArrastavel id="humor" titulo="Humor" posicao={layout.humor} containerRef={paginaDireitaRef} onArrastar={moverWidget} tamanho={tamanhos.humor ?? TAMANHOS_PADRAO.humor} onRedimensionar={redimensionarWidget} travado={travado} onRemover={() => removerWidget("humor")}>
                  <div className="grid h-[22px] grid-cols-7 items-center gap-1 text-center text-[9px] font-bold uppercase leading-none text-tinta-fraca">
                    {NOMES_DIAS_SEMANA.map((nome) => (
                      <span key={nome}>{nome[0]}</span>
                    ))}
                  </div>
                  <div className="grid h-[22px] grid-cols-7 items-center gap-1 text-center">
                    {diasDaSemana.map((dia) => {
                      const dataISO = formatarDataISO(dia);
                      const humor = humorDoDia(dataISO);

                      return (
                        <button
                          key={dataISO}
                          onClick={() => alternarHumorDoDia(dataISO)}
                          className="flex items-center justify-center rounded-full text-base leading-none transition-transform hover:scale-110"
                        >
                          {humor ? EMOJI_POR_HUMOR[humor] : <span className="block h-3 w-3 rounded-full border border-papel-escuro" />}
                        </button>
                      );
                    })}
                  </div>
                </WidgetArrastavel>
                )}

                {widgetsAtivos.includes("progresso") && (
                <WidgetArrastavel id="progresso" titulo="Progresso da semana" posicao={layout.progresso} containerRef={paginaDireitaRef} onArrastar={moverWidget} tamanho={tamanhos.progresso ?? TAMANHOS_PADRAO.progresso} onRedimensionar={redimensionarWidget} travado={travado} onRemover={() => removerWidget("progresso")}>
                  <div className="flex h-[22px] items-center gap-3">
                    <div className="h-3 flex-1 overflow-hidden rounded-full bg-papel-escuro">
                      <div
                        className="h-full rounded-full transition-all"
                        style={{
                          width: `${percentualConcluido}%`,
                          backgroundImage:
                            'repeating-linear-gradient(45deg, rgb(var(--tinta)) 0px, rgb(var(--tinta)) 5px, rgb(var(--tinta-suave)) 5px, rgb(var(--tinta-suave)) 10px)',
                        }}
                      />
                    </div>
                    <span className="shrink-0 text-xs font-bold leading-none text-tinta-suave">{percentualConcluido}%</span>
                  </div>
                </WidgetArrastavel>
                )}

                {widgetsAtivos.includes("metas") && (
                <WidgetArrastavel id="metas" titulo="Metas da semana" posicao={layout.metas} containerRef={paginaDireitaRef} onArrastar={moverWidget} tamanho={tamanhos.metas ?? TAMANHOS_PADRAO.metas} onRedimensionar={redimensionarWidget} travado={travado} onRemover={() => removerWidget("metas")}>
                  <ul className="flex flex-col">
                    {metas.map((meta) => (
                      <li key={meta.id} className="group/meta flex h-[22px] items-center gap-3">
                        <span className="h-1 w-1 shrink-0 rounded-full bg-tinta-fraca" />
                        <button
                          onClick={() => alternarConclusaoMeta(meta)}
                          className={`flex-1 truncate text-left text-[13.5px] leading-none ${meta.concluida ? 'text-tinta-fraca line-through' : 'text-tinta'}`}
                        >
                          {meta.titulo}
                        </button>
                        <button
                          onClick={() => removerMeta(meta)}
                          className="opacity-0 transition-opacity group-hover/meta:opacity-100"
                          aria-label="Remover meta"
                        >
                          <X size={12} className="text-tinta-fraca" />
                        </button>
                      </li>
                    ))}

                    <li className="flex h-[22px] items-center gap-3">
                      <span className="h-1 w-1 shrink-0 rounded-full bg-tinta-fraca/60" />
                      <form onSubmit={criarMeta} className="min-w-0 flex-1">
                        <input
                          type="text"
                          value={novoTituloMeta}
                          onChange={(evento) => setNovoTituloMeta(evento.target.value)}
                          placeholder="adicionar à lista..."
                          className="w-full bg-transparent text-[13.5px] leading-none text-tinta placeholder:text-tinta-fraca outline-none"
                        />
                      </form>
                    </li>
                  </ul>
                </WidgetArrastavel>
                )}

                {widgetsAtivos.includes("reflexao") && (
                <WidgetArrastavel id="reflexao" titulo="Reflexão da semana" posicao={layout.reflexao} containerRef={paginaDireitaRef} onArrastar={moverWidget} tamanho={tamanhos.reflexao ?? TAMANHOS_PADRAO.reflexao} onRedimensionar={redimensionarWidget} travado={travado} onRemover={() => removerWidget("reflexao")}>
                  <textarea
                    value={textoReflexao}
                    onChange={(evento) => setTextoReflexao(evento.target.value)}
                    onBlur={salvarReflexao}
                    placeholder="Como foi sua semana?"
                    rows={5}
                    className="sem-scrollbar h-full w-full resize-none bg-transparent font-manuscrito text-lg leading-[22px] text-tinta outline-none placeholder:font-corpo placeholder:text-base placeholder:italic placeholder:leading-[22px] placeholder:text-tinta-fraca"
                  />
                  {salvandoReflexao && <span className="block text-right text-[11px] text-tinta-fraca">Salvando...</span>}
                </WidgetArrastavel>
                )}
              </>
            )}
          </div>
        </div>
      </div>
  );
}
