import { Circle, Eraser, Hand, LayoutGrid, Lock, Minus, Palette, PenTool, Plus, Redo2, Square, Trash2, Type, Undo2, Unlock, X } from 'lucide-react';
import { type MouseEvent as EventoMouseReact, useEffect, useLayoutEffect, useRef, useState } from 'react';

type TipoForma = 'linha' | 'linha-pontilhada' | 'retangulo' | 'circulo' | 'texto';
type Ferramenta = 'nenhuma' | TipoForma | 'apagar' | 'mover';

/** Coordenadas guardadas em % da área (0–100), para sobreviver a redimensionamentos da janela. */
interface Forma {
  id: string;
  tipo: TipoForma;
  x1: number;
  y1: number;
  x2: number;
  y2: number;
  cor: string; // nome da variável CSS de cor, ex: "--tinta"
  texto?: string;
  tamanhoFonte?: number; // só usado quando tipo === 'texto'
  larguraTexto?: number; // px — largura da caixa de texto; o texto quebra a linha dentro dela
}

interface EstadoDesenho {
  formas: Forma[];
  historico: Forma[][];
  futuro: Forma[][];
}

const CHAVE_ARMAZENAMENTO = 'rotina-plus-formas-decorativas';
const CHAVE_CORES_PERSONALIZADAS = 'rotina-plus-cores-personalizadas';
const LIMITE_HISTORICO = 50;
const LIMITE_CORES_PERSONALIZADAS = 10;

/** Paleta de cores prontas: os tons de destaque do app (adaptam ao tema) + um leque fixo bem mais amplo. */
const PALETA: { nome: string; varCss: string }[] = [
  { nome: 'Tinta', varCss: '--tinta' },
  { nome: 'Azul', varCss: '--destaque-azul-escuro' },
  { nome: 'Verde', varCss: '--destaque-verde-escuro' },
  { nome: 'Rosa', varCss: '--destaque-rosa-escuro' },
  { nome: 'Roxo', varCss: '--destaque-roxo-escuro' },
  { nome: 'Areia', varCss: '--destaque-areia-escuro' },
];

/** Cores fixas adicionais (não mudam com o tema — são a cor "literal" escolhida mesmo). */
const CORES_FIXAS: { nome: string; hex: string }[] = [
  { nome: 'Preto', hex: '#1a1a1a' },
  { nome: 'Branco', hex: '#f5f2eb' },
  { nome: 'Cinza', hex: '#8a8a8a' },
  { nome: 'Vermelho', hex: '#d64545' },
  { nome: 'Laranja', hex: '#e08a3c' },
  { nome: 'Amarelo', hex: '#e0c23c' },
  { nome: 'Lima', hex: '#8bc34a' },
  { nome: 'Verde-água', hex: '#3cb8a8' },
  { nome: 'Ciano', hex: '#3ca9d6' },
  { nome: 'Azul royal', hex: '#3c5fd6' },
  { nome: 'Índigo', hex: '#6a3cd6' },
  { nome: 'Magenta', hex: '#c23cd6' },
  { nome: 'Pink', hex: '#e0559a' },
  { nome: 'Marrom', hex: '#8a5a3c' },
];

function carregarCoresPersonalizadas(): string[] {
  try {
    const bruto = localStorage.getItem(CHAVE_CORES_PERSONALIZADAS);
    return bruto ? JSON.parse(bruto) : [];
  } catch {
    return [];
  }
}

/** Converte o valor guardado numa cor CSS: nomes começando com "--" são tokens do tema, o resto é literal (hex). */
function corComoCss(cor: string): string {
  return cor.startsWith('--') ? `rgb(var(${cor}))` : cor;
}

/** Tamanhos de fonte disponíveis para o texto, com um tamanho de exibição menor (só pra caber no botão). */
const TAMANHOS_FONTE: { valor: number; exibicao: number }[] = [
  { valor: 16, exibicao: 11 },
  { valor: 20, exibicao: 13 },
  { valor: 26, exibicao: 16 },
  { valor: 34, exibicao: 19 },
];

const LARGURA_TEXTO_PADRAO = 220;
const LARGURA_TEXTO_MINIMA = 60;
const ALTURA_LINHA = 1.25; // multiplicador do tamanho da fonte

/** Canvas escondido só pra medir largura de texto (decide onde quebrar a linha). */
let canvasDeMedida: HTMLCanvasElement | null = null;

function medirLarguraTexto(texto: string, tamanhoFonte: number): number {
  if (!canvasDeMedida) canvasDeMedida = document.createElement('canvas');
  const contexto = canvasDeMedida.getContext('2d');
  if (!contexto) return texto.length * tamanhoFonte * 0.52;

  contexto.font = `${tamanhoFonte}px "Kalam", cursive`;
  return contexto.measureText(texto).width;
}

/** Quebra o texto em linhas que cabem em `larguraMaxima`, palavra por palavra — como num editor de texto. */
function quebrarTexto(texto: string, larguraMaxima: number, tamanhoFonte: number): string[] {
  const linhas: string[] = [];

  for (const paragrafo of texto.split('\n')) {
    const palavras = paragrafo.split(' ');
    let linhaAtual = '';

    for (const palavra of palavras) {
      const tentativa = linhaAtual ? `${linhaAtual} ${palavra}` : palavra;
      if (linhaAtual && medirLarguraTexto(tentativa, tamanhoFonte) > larguraMaxima) {
        linhas.push(linhaAtual);
        linhaAtual = palavra;
      } else {
        linhaAtual = tentativa;
      }
    }

    linhas.push(linhaAtual);
  }

  return linhas;
}

function carregarFormasSalvas(): Forma[] {
  try {
    const bruto = localStorage.getItem(CHAVE_ARMAZENAMENTO);
    const formas = bruto ? JSON.parse(bruto) : [];
    // Compatibilidade com desenhos salvos antes de existir cor/tamanho/largura por forma.
    return formas.map((forma: Forma) => ({
      ...forma,
      cor: forma.cor ?? '--tinta',
      tamanhoFonte: forma.tamanhoFonte ?? 22,
      larguraTexto: forma.larguraTexto ?? LARGURA_TEXTO_PADRAO,
    }));
  } catch {
    return [];
  }
}

/**
 * Camada de desenho sobreposta à página: permite ao usuário traçar linhas,
 * linhas pontilhadas, retângulos, círculos e texto para separar/organizar as
 * seções como quiser, em cores diferentes. Só captura o mouse quando uma
 * ferramenta está ativa — no resto do tempo os cliques passam direto para a
 * página. As formas ficam salvas no navegador, e Ctrl+Z / Ctrl+Shift+Z
 * desfazem e refazem as últimas alterações do desenho.
 *
 * Com `travado`, a ferramenta de desenho fica escondida e inativa (os
 * desenhos já feitos continuam visíveis, só não dá para editar).
 */
interface WidgetDisponivel {
  id: string;
  titulo: string;
}

export function CamadaDesenho({
  travado,
  aoAlternarTravado,
  widgetsParaAdicionar,
  aoAdicionarWidget,
}: {
  travado: boolean;
  aoAlternarTravado: () => void;
  widgetsParaAdicionar: WidgetDisponivel[];
  aoAdicionarWidget: (id: string) => void;
}) {
  const [estado, setEstado] = useState<EstadoDesenho>(() => ({
    formas: carregarFormasSalvas(),
    historico: [],
    futuro: [],
  }));
  const [ferramenta, setFerramenta] = useState<Ferramenta>('nenhuma');
  const [caixaAberta, setCaixaAberta] = useState(false);
  const [caixaWidgetsAberta, setCaixaWidgetsAberta] = useState(false);
  const [corAtual, setCorAtual] = useState('--tinta');
  const [coresPersonalizadas, setCoresPersonalizadas] = useState<string[]>(carregarCoresPersonalizadas);
  const [corPickerAtual, setCorPickerAtual] = useState('#2f2a24');
  const [tamanhoFonteAtual, setTamanhoFonteAtual] = useState(22);
  const [desenhoAtual, setDesenhoAtual] = useState<Forma | null>(null);
  const [textoEditando, setTextoEditando] = useState<{ x: number; y: number; valor: string; largura: number } | null>(null);
  const [tamanho, setTamanho] = useState({ largura: 0, altura: 0 });

  // Seleção/arraste/redimensionamento de texto (ferramenta "mover").
  const [formaSelecionadaId, setFormaSelecionadaId] = useState<string | null>(null);
  const [arrastandoTexto, setArrastandoTexto] = useState<{ id: string; offsetX: number; offsetY: number; x: number; y: number } | null>(null);
  const [redimensionandoTexto, setRedimensionandoTexto] = useState<{ id: string; xInicial: number; larguraInicial: number; largura: number } | null>(null);

  const svgRef = useRef<SVGSVGElement>(null);
  const wrapperRef = useRef<HTMLDivElement>(null);
  const textareaRef = useRef<HTMLTextAreaElement>(null);

  // O foco precisa ser aplicado logo após o campo aparecer (antes do navegador processar
  // o "mouseup" do mesmo clique, que senão rouba o foco de volta e a digitação não funciona).
  useLayoutEffect(() => {
    if (textoEditando) textareaRef.current?.focus();
  }, [textoEditando]);

  // Mede a área disponível em pixels reais, para desenhar sem distorcer (linhas retas e círculos redondos de verdade).
  useEffect(() => {
    const elemento = wrapperRef.current;
    if (!elemento) return;

    const medir = () => setTamanho({ largura: elemento.clientWidth, altura: elemento.clientHeight });
    medir();

    const observador = new ResizeObserver(medir);
    observador.observe(elemento);
    return () => observador.disconnect();
  }, []);

  useEffect(() => {
    localStorage.setItem(CHAVE_ARMAZENAMENTO, JSON.stringify(estado.formas));
  }, [estado.formas]);

  useEffect(() => {
    localStorage.setItem(CHAVE_CORES_PERSONALIZADAS, JSON.stringify(coresPersonalizadas));
  }, [coresPersonalizadas]);

  // Ao trancar, cancela qualquer ferramenta de forma ativa (a caixa continua aberta e o
  // texto continua funcionando — só linha/forma/apagar/limpar ficam desativados).
  useEffect(() => {
    if (!travado) return;
    setFerramenta((atual) => (atual === 'texto' ? atual : 'nenhuma'));
    setDesenhoAtual(null);
    setCaixaWidgetsAberta(false);
  }, [travado]);

  // Ao trocar de ferramenta, perde a seleção de texto (mover/redimensionar só faz sentido com "mover" ativo).
  useEffect(() => {
    if (ferramenta !== 'mover') {
      setFormaSelecionadaId(null);
      setArrastandoTexto(null);
      setRedimensionandoTexto(null);
    }
  }, [ferramenta]);

  /** Aplica uma nova lista de formas, guardando a anterior no histórico (para o Ctrl+Z). */
  function aplicarNovasFormas(novasFormas: Forma[]) {
    setEstado((atual) => ({
      formas: novasFormas,
      historico: [...atual.historico, atual.formas].slice(-LIMITE_HISTORICO),
      futuro: [],
    }));
  }

  function desfazer() {
    setEstado((atual) => {
      if (atual.historico.length === 0) return atual;
      const anterior = atual.historico[atual.historico.length - 1];
      return {
        formas: anterior,
        historico: atual.historico.slice(0, -1),
        futuro: [atual.formas, ...atual.futuro].slice(0, LIMITE_HISTORICO),
      };
    });
  }

  function refazer() {
    setEstado((atual) => {
      if (atual.futuro.length === 0) return atual;
      const proximo = atual.futuro[0];
      return {
        formas: proximo,
        historico: [...atual.historico, atual.formas].slice(-LIMITE_HISTORICO),
        futuro: atual.futuro.slice(1),
      };
    });
  }

  // Atalhos de teclado: Ctrl/Cmd+Z desfaz, Ctrl/Cmd+Shift+Z (ou +Y) refaz.
  // Ignora quando o foco está num campo de texto do resto do app (deixa o undo nativo do navegador agir ali).
  useEffect(() => {
    function aoPressionarTecla(evento: KeyboardEvent) {
      const alvo = evento.target as HTMLElement | null;
      if (alvo && (alvo.tagName === 'INPUT' || alvo.tagName === 'TEXTAREA')) return;

      const comCtrlOuCmd = evento.ctrlKey || evento.metaKey;
      if (!comCtrlOuCmd) return;

      const tecla = evento.key.toLowerCase();
      if (tecla === 'z' && evento.shiftKey) {
        evento.preventDefault();
        refazer();
      } else if (tecla === 'z') {
        evento.preventDefault();
        desfazer();
      } else if (tecla === 'y') {
        evento.preventDefault();
        refazer();
      }
    }

    window.addEventListener('keydown', aoPressionarTecla);
    return () => window.removeEventListener('keydown', aoPressionarTecla);
  }, []);

  function obterPontoRelativo(evento: EventoMouseReact): { x: number; y: number } {
    const retangulo = svgRef.current!.getBoundingClientRect();
    return {
      x: ((evento.clientX - retangulo.left) / retangulo.width) * 100,
      y: ((evento.clientY - retangulo.top) / retangulo.height) * 100,
    };
  }

  function iniciarDesenho(evento: EventoMouseReact) {
    if (ferramenta === 'nenhuma' || ferramenta === 'apagar') return;
    // Evita que o navegador tente devolver o foco para outro lugar depois do clique
    // (é isso que fazia o campo de texto perder o foco antes de o usuário digitar).
    evento.preventDefault();

    if (ferramenta === 'mover') {
      // Clique em área vazia (num texto, o próprio texto já parou a propagação): desmarca.
      setFormaSelecionadaId(null);
      return;
    }

    const ponto = obterPontoRelativo(evento);

    if (ferramenta === 'texto') {
      setTextoEditando({ x: ponto.x, y: ponto.y, valor: '', largura: LARGURA_TEXTO_PADRAO });
      return;
    }

    setDesenhoAtual({ id: crypto.randomUUID(), tipo: ferramenta, x1: ponto.x, y1: ponto.y, x2: ponto.x, y2: ponto.y, cor: corAtual });
  }

  function atualizarDesenho(evento: EventoMouseReact) {
    if (!desenhoAtual) return;
    const ponto = obterPontoRelativo(evento);
    setDesenhoAtual({ ...desenhoAtual, x2: ponto.x, y2: ponto.y });
  }

  function finalizarDesenho() {
    if (!desenhoAtual) return;

    const tamanhoTraço = Math.hypot(desenhoAtual.x2 - desenhoAtual.x1, desenhoAtual.y2 - desenhoAtual.y1);
    if (tamanhoTraço > 1.5) {
      aplicarNovasFormas([...estado.formas, desenhoAtual]);
    }
    setDesenhoAtual(null);
  }

  /** Começa a arrastar um texto (clique na própria forma, com a ferramenta "mover" ativa). */
  function iniciarArrasteTexto(evento: EventoMouseReact, forma: Forma) {
    evento.stopPropagation();
    evento.preventDefault();
    const ponto = obterPontoRelativo(evento);
    setFormaSelecionadaId(forma.id);
    setArrastandoTexto({ id: forma.id, offsetX: ponto.x - forma.x1, offsetY: ponto.y - forma.y1, x: forma.x1, y: forma.y1 });
  }

  /** Começa a redimensionar a largura da caixa de texto (arrasta a alcinha no canto da seleção) — o texto quebra linha conforme ela muda. */
  function iniciarRedimensionarTexto(evento: EventoMouseReact, forma: Forma) {
    evento.stopPropagation();
    evento.preventDefault();
    const ponto = obterPontoRelativo(evento);
    const larguraInicial = forma.larguraTexto ?? LARGURA_TEXTO_PADRAO;
    setRedimensionandoTexto({ id: forma.id, xInicial: ponto.x, larguraInicial, largura: larguraInicial });
  }

  /** Atualiza o arraste/redimensionamento de texto em andamento, junto com o desenho de formas. */
  function aoMoverMouseSvg(evento: EventoMouseReact) {
    atualizarDesenho(evento);

    if (arrastandoTexto) {
      const ponto = obterPontoRelativo(evento);
      setArrastandoTexto((atual) => atual && { ...atual, x: ponto.x - atual.offsetX, y: ponto.y - atual.offsetY });
    }

    if (redimensionandoTexto) {
      const ponto = obterPontoRelativo(evento);
      const deltaPx = ((ponto.x - redimensionandoTexto.xInicial) / 100) * tamanho.largura;
      const novaLargura = Math.max(LARGURA_TEXTO_MINIMA, redimensionandoTexto.larguraInicial + deltaPx);
      setRedimensionandoTexto((atual) => atual && { ...atual, largura: novaLargura });
    }
  }

  /** Confirma o arraste/redimensionamento de texto em andamento, junto com o fim do desenho de formas. */
  function aoSoltarMouseSvg() {
    finalizarDesenho();

    if (arrastandoTexto) {
      const { id, x, y } = arrastandoTexto;
      aplicarNovasFormas(estado.formas.map((forma) => (forma.id === id ? { ...forma, x1: x, y1: y, x2: x, y2: y } : forma)));
      setArrastandoTexto(null);
    }

    if (redimensionandoTexto) {
      const { id, largura: larguraFinal } = redimensionandoTexto;
      aplicarNovasFormas(estado.formas.map((forma) => (forma.id === id ? { ...forma, larguraTexto: larguraFinal } : forma)));
      setRedimensionandoTexto(null);
    }
  }

  function confirmarTexto() {
    if (textoEditando && textoEditando.valor.trim()) {
      aplicarNovasFormas([
        ...estado.formas,
        {
          id: crypto.randomUUID(),
          tipo: 'texto',
          x1: textoEditando.x,
          y1: textoEditando.y,
          x2: textoEditando.x,
          y2: textoEditando.y,
          cor: corAtual,
          texto: textoEditando.valor,
          tamanhoFonte: tamanhoFonteAtual,
          larguraTexto: textoEditando.largura,
        },
      ]);
    }
    setTextoEditando(null);
  }

  function apagarForma(id: string) {
    aplicarNovasFormas(estado.formas.filter((forma) => forma.id !== id));
  }

  /** Escolhe uma cor personalizada (do seletor nativo) e guarda no histórico de cores usadas. */
  function escolherCorPersonalizada(hex: string) {
    setCorPickerAtual(hex);
    setCorAtual(hex);
    setCoresPersonalizadas((atual) => [hex, ...atual.filter((cor) => cor !== hex)].slice(0, LIMITE_CORES_PERSONALIZADAS));
  }

  function alternarFerramenta(ferramentaClicada: Ferramenta) {
    setFerramenta((atual) => (atual === ferramentaClicada ? 'nenhuma' : ferramentaClicada));
  }

  const desenhando = ferramenta !== 'nenhuma' && ferramenta !== 'apagar' && ferramenta !== 'mover';
  const apagando = ferramenta === 'apagar';
  const movendo = ferramenta === 'mover';

  /** Converte as coordenadas em % guardadas na forma para pixels reais da área atual. */
  function paraPixel(forma: Pick<Forma, 'x1' | 'y1' | 'x2' | 'y2'>) {
    return {
      x1: (forma.x1 / 100) * tamanho.largura,
      y1: (forma.y1 / 100) * tamanho.altura,
      x2: (forma.x2 / 100) * tamanho.largura,
      y2: (forma.y2 / 100) * tamanho.altura,
    };
  }

  /** Aplica a posição/tamanho ao vivo (durante um arraste ou redimensionamento) por cima da forma salva. */
  function formaParaExibir(forma: Forma): Forma {
    let resultado = forma;
    if (arrastandoTexto && arrastandoTexto.id === forma.id) {
      resultado = { ...resultado, x1: arrastandoTexto.x, y1: arrastandoTexto.y, x2: arrastandoTexto.x, y2: arrastandoTexto.y };
    }
    if (redimensionandoTexto && redimensionandoTexto.id === forma.id) {
      resultado = { ...resultado, larguraTexto: redimensionandoTexto.largura };
    }
    return resultado;
  }

  return (
    <div ref={wrapperRef} className="pointer-events-none absolute inset-0 z-10">
      <svg
        ref={svgRef}
        width={tamanho.largura}
        height={tamanho.altura}
        viewBox={`0 0 ${tamanho.largura || 1} ${tamanho.altura || 1}`}
        className={`h-full w-full ${desenhando ? 'pointer-events-auto cursor-crosshair' : apagando || movendo ? 'pointer-events-auto' : 'pointer-events-none'}`}
        onMouseDown={iniciarDesenho}
        onMouseMove={aoMoverMouseSvg}
        onMouseUp={aoSoltarMouseSvg}
        onMouseLeave={aoSoltarMouseSvg}
      >
        {/* Área invisível que captura o clique em qualquer ponto vazio ao desenhar/mover. */}
        {(desenhando || movendo) && <rect x={0} y={0} width={tamanho.largura} height={tamanho.altura} fill="transparent" />}

        {estado.formas.map((forma) => {
          const exibida = formaParaExibir(forma);
          return (
            <FormaSvg
              key={forma.id}
              forma={exibida}
              pixels={paraPixel(exibida)}
              apagavel={apagando}
              onApagar={() => apagarForma(forma.id)}
              movivel={movendo && forma.tipo === 'texto'}
              onIniciarMover={(evento) => iniciarArrasteTexto(evento, forma)}
            />
          );
        })}
        {desenhoAtual && <FormaSvg forma={desenhoAtual} pixels={paraPixel(desenhoAtual)} apagavel={false} preview />}

        {/* Caixa de seleção + alça de redimensionar do texto selecionado (ferramenta "mover"). */}
        {movendo && formaSelecionadaId && (() => {
          const original = estado.formas.find((forma) => forma.id === formaSelecionadaId && forma.tipo === 'texto');
          if (!original) return null;

          const exibida = formaParaExibir(original);
          const pix = paraPixel(exibida);
          const tamanhoFonte = exibida.tamanhoFonte ?? 22;
          const largura = exibida.larguraTexto ?? LARGURA_TEXTO_PADRAO;
          const linhas = quebrarTexto(exibida.texto ?? '', largura, tamanhoFonte);
          const altura = linhas.length * tamanhoFonte * ALTURA_LINHA;

          return (
            <g>
              <rect
                x={pix.x1 - 4}
                y={pix.y1 - 4}
                width={largura + 8}
                height={altura + 8}
                fill="none"
                stroke="rgb(var(--destaque-azul-escuro))"
                strokeWidth={1.5}
                strokeDasharray="6 4"
                pointerEvents="none"
              />
              <circle
                cx={pix.x1 + largura}
                cy={pix.y1 + altura}
                r={7}
                fill="rgb(var(--destaque-azul-escuro))"
                stroke="rgb(var(--papel-claro))"
                strokeWidth={2}
                style={{ cursor: 'nwse-resize', pointerEvents: 'all' }}
                onMouseDown={(evento) => iniciarRedimensionarTexto(evento, original)}
              />
            </g>
          );
        })()}
      </svg>

      {/* Campo de texto flutuante enquanto o usuário digita uma anotação. */}
      {textoEditando && (
        <textarea
          ref={textareaRef}
          rows={1}
          value={textoEditando.valor}
          onChange={(evento) => {
            setTextoEditando({ ...textoEditando, valor: evento.target.value });
            // Cresce em altura conforme o texto quebra linha, como num editor de texto de verdade.
            evento.target.style.height = 'auto';
            evento.target.style.height = `${evento.target.scrollHeight}px`;
          }}
          onBlur={confirmarTexto}
          onKeyDown={(evento) => {
            if (evento.key === 'Escape') setTextoEditando(null);
            if (evento.key === 'Enter' && !evento.shiftKey) {
              evento.preventDefault();
              confirmarTexto();
            }
          }}
          placeholder="Escreva algo..."
          className="pointer-events-auto absolute resize-none overflow-hidden bg-transparent font-manuscrito leading-tight outline-none"
          style={{
            left: `${textoEditando.x}%`,
            top: `${textoEditando.y}%`,
            width: textoEditando.largura,
            color: corComoCss(corAtual),
            fontSize: `${tamanhoFonteAtual}px`,
          }}
        />
      )}

      {/* Coluna de quadradinhos: pincel (formas), texto e cadeado — continuam acessíveis mesmo
          trancado; só as ferramentas de forma ficam visíveis porém desativadas quando travado. */}
      <div className="pointer-events-auto fixed left-[280px] top-4 z-20 flex flex-col items-start gap-2">
        {/* Adicionar componentes: escolhe um bloco (hábitos, água, humor...) pra colocar
            na página — depois é só arrastar ele pra onde quiser com a mãozinha ou pela alça. */}
        <button
          onClick={() => setCaixaWidgetsAberta((atual) => !atual)}
          disabled={travado}
          aria-label={caixaWidgetsAberta ? 'Fechar lista de componentes' : 'Adicionar componente'}
          title="Adicionar componente"
          className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-xl border border-papel-escuro shadow-papel transition-colors disabled:opacity-30 ${
            caixaWidgetsAberta ? 'bg-tinta text-papel-claro' : 'bg-papel-claro text-tinta-suave hover:bg-papel-escuro'
          }`}
        >
          {caixaWidgetsAberta ? <X size={18} /> : <LayoutGrid size={16} />}
        </button>

        {caixaWidgetsAberta && (
          <div className="flex w-44 flex-col gap-0.5 rounded-xl border border-papel-escuro bg-papel-claro/95 p-1.5 shadow-papel backdrop-blur">
            {widgetsParaAdicionar.length === 0 ? (
              <p className="px-1.5 py-1 text-[11px] italic text-tinta-fraca">Tudo já foi adicionado.</p>
            ) : (
              widgetsParaAdicionar.map((widget) => (
                <button
                  key={widget.id}
                  onClick={() => {
                    aoAdicionarWidget(widget.id);
                    setCaixaWidgetsAberta(false);
                  }}
                  className="flex items-center gap-1.5 rounded-lg px-1.5 py-1.5 text-left text-[12.5px] text-tinta transition-colors hover:bg-papel-escuro"
                >
                  <Plus size={13} className="shrink-0 text-tinta-fraca" />
                  {widget.titulo}
                </button>
              ))
            )}
          </div>
        )}

        {/* Mãozinha: seleciona um texto já colocado para arrastar (corpo do texto) ou
            redimensionar (alça azul no canto da seleção). */}
        <button
          onClick={() => alternarFerramenta('mover')}
          disabled={travado}
          aria-label={movendo ? 'Sair do modo mover' : 'Mover e redimensionar texto'}
          title="Mover e redimensionar texto"
          className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-xl border border-papel-escuro shadow-papel transition-colors disabled:opacity-30 ${
            movendo ? 'bg-tinta text-papel-claro' : 'bg-papel-claro text-tinta-suave hover:bg-papel-escuro'
          }`}
        >
          <Hand size={16} />
        </button>

        <button
          onClick={() => setCaixaAberta((atual) => !atual)}
          aria-label={caixaAberta ? 'Fechar ferramentas de desenho' : 'Abrir ferramentas de desenho'}
          title={caixaAberta ? 'Fechar ferramentas' : 'Formas geométricas'}
          className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-xl border border-papel-escuro shadow-papel transition-colors ${
            caixaAberta || (ferramenta !== 'nenhuma' && ferramenta !== 'texto' && ferramenta !== 'mover') ? 'bg-tinta text-papel-claro' : 'bg-papel-claro text-tinta-suave hover:bg-papel-escuro'
          }`}
        >
          {caixaAberta ? <X size={18} /> : <PenTool size={16} />}
        </button>

        {caixaAberta && (
          <div className="flex flex-col gap-1 rounded-xl border border-papel-escuro bg-papel-claro/95 p-1 shadow-papel backdrop-blur">
            <div className="flex items-center gap-1">
              <BotaoFerramenta ativo={ferramenta === 'linha'} desabilitado={travado} onClick={() => alternarFerramenta('linha')} label="Linha">
                <Minus size={15} />
              </BotaoFerramenta>
              <BotaoFerramenta ativo={ferramenta === 'linha-pontilhada'} desabilitado={travado} onClick={() => alternarFerramenta('linha-pontilhada')} label="Linha pontilhada">
                <IconeLinhaPontilhada />
              </BotaoFerramenta>
              <BotaoFerramenta ativo={ferramenta === 'retangulo'} desabilitado={travado} onClick={() => alternarFerramenta('retangulo')} label="Retângulo">
                <Square size={14} />
              </BotaoFerramenta>
              <BotaoFerramenta ativo={ferramenta === 'circulo'} desabilitado={travado} onClick={() => alternarFerramenta('circulo')} label="Círculo">
                <Circle size={14} />
              </BotaoFerramenta>

              <span className="mx-0.5 h-5 w-px bg-papel-escuro" />

              <BotaoFerramenta ativo={apagando} desabilitado={travado} onClick={() => alternarFerramenta('apagar')} label="Apagar forma">
                <Eraser size={15} />
              </BotaoFerramenta>
              <BotaoFerramenta ativo={false} desabilitado={travado} onClick={() => aplicarNovasFormas([])} label="Limpar todos os desenhos">
                <Trash2 size={15} />
              </BotaoFerramenta>

              <span className="mx-0.5 h-5 w-px bg-papel-escuro" />

              <BotaoFerramenta ativo={false} desabilitado={travado || estado.historico.length === 0} onClick={desfazer} label="Desfazer (Ctrl+Z)">
                <Undo2 size={15} />
              </BotaoFerramenta>
              <BotaoFerramenta ativo={false} desabilitado={travado || estado.futuro.length === 0} onClick={refazer} label="Refazer (Ctrl+Shift+Z)">
                <Redo2 size={15} />
              </BotaoFerramenta>
            </div>

            <SeletorCor
              corAtual={corAtual}
              onEscolher={setCorAtual}
              corPicker={corPickerAtual}
              onEscolherPicker={escolherCorPersonalizada}
              coresPersonalizadas={coresPersonalizadas}
            />
          </div>
        )}

        {/* Texto: quadradinho próprio, com cor e tamanho da fonte — usa a mesma fonte manuscrita do Diário. */}
        <button
          onClick={() => alternarFerramenta('texto')}
          aria-label={ferramenta === 'texto' ? 'Fechar ferramenta de texto' : 'Escrever texto'}
          title="Texto"
          className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-xl border border-papel-escuro shadow-papel transition-colors ${
            ferramenta === 'texto' ? 'bg-tinta text-papel-claro' : 'bg-papel-claro text-tinta-suave hover:bg-papel-escuro'
          }`}
        >
          <Type size={16} />
        </button>

        {ferramenta === 'texto' && (
          <div className="flex flex-col gap-1 rounded-xl border border-papel-escuro bg-papel-claro/95 p-1 shadow-papel backdrop-blur">
            <SeletorCor
              corAtual={corAtual}
              onEscolher={setCorAtual}
              corPicker={corPickerAtual}
              onEscolherPicker={escolherCorPersonalizada}
              coresPersonalizadas={coresPersonalizadas}
            />
            <div className="flex items-center gap-1 border-t border-papel-escuro px-0.5 pb-0.5 pt-1.5">
              {TAMANHOS_FONTE.map((tamanho) => (
                <button
                  key={tamanho.valor}
                  onClick={() => setTamanhoFonteAtual(tamanho.valor)}
                  aria-label={`Tamanho da fonte ${tamanho.valor}px`}
                  title={`${tamanho.valor}px`}
                  className={`flex h-6 w-6 shrink-0 items-center justify-center rounded-md font-manuscrito transition-colors ${
                    tamanhoFonteAtual === tamanho.valor ? 'bg-tinta text-papel-claro' : 'text-tinta-suave hover:bg-papel-escuro'
                  }`}
                  style={{ fontSize: tamanho.exibicao }}
                >
                  A
                </button>
              ))}
            </div>
          </div>
        )}

        {/* Cadeado: destrancado dá para desenhar e arrastar os blocos da folha direita;
            trancado, as ferramentas de forma ficam visíveis mas inativas — só o texto continua funcionando. */}
        <button
          onClick={aoAlternarTravado}
          aria-label={travado ? 'Destrancar a folha direita' : 'Trancar a folha direita'}
          title={travado ? 'Destrancado: dá para desenhar e arrastar os blocos' : 'Trancado: só dá para marcar e escrever (e ainda usar o texto)'}
          className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-xl border border-papel-escuro shadow-papel transition-colors ${
            travado ? 'bg-tinta text-papel-claro' : 'bg-papel-claro text-tinta-suave hover:bg-papel-escuro'
          }`}
        >
          {travado ? <Lock size={16} /> : <Unlock size={16} />}
        </button>
      </div>

      {((caixaAberta && (desenhando || apagando)) || ferramenta === 'texto' || movendo) && (
        <p className="pointer-events-none fixed left-[280px] top-[336px] z-20 text-[10px] font-semibold text-white/50">
          {ferramenta === 'texto'
            ? 'clique na página para escrever'
            : movendo
              ? 'clique num texto pra arrastar ou puxe a alça pra mudar a largura (o texto quebra a linha)'
              : apagando
                ? 'clique numa forma para apagar'
                : 'clique e arraste para desenhar'}
        </p>
      )}
    </div>
  );
}

/**
 * Seletor de cor completo: paleta do tema, um leque fixo de cores, o histórico de
 * cores personalizadas já usadas, e um botão que abre o seletor nativo do sistema
 * (roda de cor + campo hex/RGB) para montar qualquer cor.
 */
function SeletorCor({
  corAtual,
  onEscolher,
  corPicker,
  onEscolherPicker,
  coresPersonalizadas,
}: {
  corAtual: string;
  onEscolher: (cor: string) => void;
  corPicker: string;
  onEscolherPicker: (hex: string) => void;
  coresPersonalizadas: string[];
}) {
  return (
    <div className="flex max-w-[184px] flex-wrap items-center gap-1 px-0.5 pb-0.5 pt-0.5">
      {PALETA.map((cor) => (
        <button
          key={cor.varCss}
          onClick={() => onEscolher(cor.varCss)}
          aria-label={`Cor ${cor.nome}`}
          title={cor.nome}
          className={`h-5 w-5 shrink-0 rounded-full transition-transform ${corAtual === cor.varCss ? 'scale-110 ring-2 ring-tinta ring-offset-1 ring-offset-papel-claro' : 'hover:scale-105'}`}
          style={{ backgroundColor: `rgb(var(${cor.varCss}))` }}
        />
      ))}

      {CORES_FIXAS.map((cor) => (
        <button
          key={cor.hex}
          onClick={() => onEscolher(cor.hex)}
          aria-label={`Cor ${cor.nome}`}
          title={cor.nome}
          className={`h-5 w-5 shrink-0 rounded-full border border-black/10 transition-transform ${corAtual === cor.hex ? 'scale-110 ring-2 ring-tinta ring-offset-1 ring-offset-papel-claro' : 'hover:scale-105'}`}
          style={{ backgroundColor: cor.hex }}
        />
      ))}

      {coresPersonalizadas.map((hex) => (
        <button
          key={hex}
          onClick={() => onEscolher(hex)}
          aria-label={`Cor personalizada ${hex}`}
          title={hex}
          className={`h-5 w-5 shrink-0 rounded-full border border-black/10 transition-transform ${corAtual === hex ? 'scale-110 ring-2 ring-tinta ring-offset-1 ring-offset-papel-claro' : 'hover:scale-105'}`}
          style={{ backgroundColor: hex }}
        />
      ))}

      {/* Roda um seletor de cor nativo (escolhe qualquer tom, com hex/RGB) por baixo do ícone. */}
      <label
        className="relative flex h-5 w-5 shrink-0 cursor-pointer items-center justify-center rounded-full border border-dashed border-tinta-fraca text-tinta-fraca transition-transform hover:scale-105"
        title="Montar outra cor"
      >
        <Palette size={11} />
        <input
          type="color"
          value={corPicker}
          onChange={(evento) => onEscolherPicker(evento.target.value)}
          aria-label="Montar uma cor personalizada"
          className="absolute inset-0 h-full w-full cursor-pointer opacity-0"
        />
      </label>
    </div>
  );
}

/** Um botão redondo/quadrado pequeno da barra de ferramentas de desenho. */
function BotaoFerramenta({
  ativo,
  desabilitado,
  onClick,
  label,
  children,
}: {
  ativo: boolean;
  desabilitado?: boolean;
  onClick: () => void;
  label: string;
  children: React.ReactNode;
}) {
  return (
    <button
      onClick={onClick}
      disabled={desabilitado}
      aria-label={label}
      title={label}
      className={`flex h-7 w-7 items-center justify-center rounded-lg transition-colors disabled:opacity-30 ${
        ativo ? 'bg-tinta text-papel-claro' : 'text-tinta-suave hover:bg-papel-escuro'
      }`}
    >
      {children}
    </button>
  );
}

/** Ícone de linha pontilhada (lucide não tem um pronto). */
function IconeLinhaPontilhada() {
  return (
    <svg width="15" height="15" viewBox="0 0 24 24" fill="none">
      <line x1="2" y1="12" x2="7" y2="12" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
      <line x1="10.5" y1="12" x2="14" y2="12" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
      <line x1="17.5" y1="12" x2="22" y2="12" stroke="currentColor" strokeWidth="2" strokeLinecap="round" />
    </svg>
  );
}

/** Renderiza uma forma (linha, linha pontilhada, retângulo, círculo ou texto) dentro do SVG, já em pixels reais. */
function FormaSvg({
  forma,
  pixels,
  apagavel,
  onApagar,
  movivel,
  onIniciarMover,
  preview,
}: {
  forma: Forma;
  pixels: { x1: number; y1: number; x2: number; y2: number };
  apagavel: boolean;
  onApagar?: () => void;
  movivel?: boolean;
  onIniciarMover?: (evento: EventoMouseReact) => void;
  preview?: boolean;
}) {
  const cor = corComoCss(forma.cor);

  const eventosClique = apagavel
    ? { onClick: onApagar, style: { cursor: 'pointer' as const, pointerEvents: 'all' as const } }
    : movivel
      ? { onMouseDown: onIniciarMover, style: { cursor: 'move' as const, pointerEvents: 'all' as const } }
      : { style: { pointerEvents: 'none' as const } };

  if (forma.tipo === 'texto') {
    const tamanhoFonte = forma.tamanhoFonte ?? 22;
    const largura = forma.larguraTexto ?? LARGURA_TEXTO_PADRAO;
    const linhas = quebrarTexto(forma.texto ?? '', largura, tamanhoFonte);

    return (
      <text
        x={pixels.x1}
        y={pixels.y1}
        dominantBaseline="hanging"
        fontSize={tamanhoFonte}
        fill={cor}
        opacity={preview ? 0.55 : 1}
        className="font-manuscrito"
        {...eventosClique}
      >
        {linhas.map((linha, indice) => (
          <tspan key={indice} x={pixels.x1} dy={indice === 0 ? 0 : tamanhoFonte * ALTURA_LINHA}>
            {linha}
          </tspan>
        ))}
      </text>
    );
  }

  const propriedadesComuns = {
    stroke: cor,
    strokeWidth: 2.5,
    fill: 'none',
    opacity: preview ? 0.55 : 1,
    strokeLinecap: 'round' as const,
    ...(apagavel
      ? { onClick: onApagar, style: { cursor: 'pointer' as const, pointerEvents: 'stroke' as const } }
      : { style: { pointerEvents: 'none' as const } }),
  };

  if (forma.tipo === 'linha' || forma.tipo === 'linha-pontilhada') {
    return (
      <line
        x1={pixels.x1}
        y1={pixels.y1}
        x2={pixels.x2}
        y2={pixels.y2}
        strokeDasharray={forma.tipo === 'linha-pontilhada' ? '12 8' : undefined}
        {...propriedadesComuns}
      />
    );
  }

  const x = Math.min(pixels.x1, pixels.x2);
  const y = Math.min(pixels.y1, pixels.y2);
  const largura = Math.abs(pixels.x2 - pixels.x1);
  const altura = Math.abs(pixels.y2 - pixels.y1);

  if (forma.tipo === 'retangulo') {
    return <rect x={x} y={y} width={largura} height={altura} rx={10} {...propriedadesComuns} />;
  }

  return <ellipse cx={x + largura / 2} cy={y + altura / 2} rx={largura / 2} ry={altura / 2} {...propriedadesComuns} />;
}
