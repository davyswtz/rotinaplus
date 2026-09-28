import { GripVertical, X } from 'lucide-react';
import { type PointerEvent as EventoPonteiroReact, type ReactNode, type RefObject, useRef, useState } from 'react';

export interface PosicaoWidget {
  x: number; // % da largura do container
  y: number; // % da altura do container
}

export interface TamanhoWidget {
  largura: number; // px
  altura: number | null; // px, ou null = altura automática (ainda não foi redimensionado)
}

const LARGURA_MINIMA = 150;
const ALTURA_MINIMA = 70;

interface Props {
  id: string;
  titulo: string;
  posicao: PosicaoWidget;
  tamanho: TamanhoWidget;
  containerRef: RefObject<HTMLDivElement | null>;
  onArrastar: (id: string, posicao: PosicaoWidget) => void;
  onRedimensionar: (id: string, tamanho: TamanhoWidget) => void;
  onRemover?: () => void;
  travado?: boolean;
  children: ReactNode;
}

/**
 * Cartão flutuante que pode ser arrastado e redimensionado livremente pela página
 * (posição e tamanho em % / px do container, para se adaptar caso a janela mude de
 * tamanho). Usado para transformar cada bloco da folha direita do caderno (hábitos,
 * água, humor, metas, reflexão...) num componente que o usuário reorganiza e
 * redimensiona como quiser — o conteúdo interno é fluido e se adapta ao tamanho.
 * Com `travado`, tanto a alça de arrastar quanto a de redimensionar ficam desativadas.
 */
export function WidgetArrastavel({
  id,
  titulo,
  posicao,
  tamanho,
  containerRef,
  onArrastar,
  onRedimensionar,
  onRemover,
  travado,
  children,
}: Props) {
  const [arrastando, setArrastando] = useState(false);
  const [redimensionando, setRedimensionando] = useState(false);
  const deslocamentoRef = useRef({ x: 0, y: 0 });
  const redimensionamentoRef = useRef({ x: 0, y: 0, largura: 0, altura: 0 });
  const cardRef = useRef<HTMLDivElement>(null);

  function aoIniciarArraste(evento: EventoPonteiroReact<HTMLDivElement>) {
    if (travado) return;
    const containerRetangulo = containerRef.current?.getBoundingClientRect();
    if (!containerRetangulo) return;

    const cardX = containerRetangulo.left + (posicao.x / 100) * containerRetangulo.width;
    const cardY = containerRetangulo.top + (posicao.y / 100) * containerRetangulo.height;

    deslocamentoRef.current = { x: evento.clientX - cardX, y: evento.clientY - cardY };
    setArrastando(true);
    evento.currentTarget.setPointerCapture(evento.pointerId);
  }

  function aoMoverArraste(evento: EventoPonteiroReact<HTMLDivElement>) {
    if (!arrastando || travado) return;
    const containerRetangulo = containerRef.current?.getBoundingClientRect();
    if (!containerRetangulo) return;

    const novoX = evento.clientX - deslocamentoRef.current.x - containerRetangulo.left;
    const novoY = evento.clientY - deslocamentoRef.current.y - containerRetangulo.top;

    const percentX = Math.min(Math.max((novoX / containerRetangulo.width) * 100, 0), 92);
    const percentY = Math.min(Math.max((novoY / containerRetangulo.height) * 100, 0), 92);

    onArrastar(id, { x: percentX, y: percentY });
  }

  function aoSoltarArraste() {
    setArrastando(false);
  }

  function aoIniciarRedimensionar(evento: EventoPonteiroReact<HTMLDivElement>) {
    if (travado) return;
    evento.stopPropagation();
    const cardRetangulo = cardRef.current?.getBoundingClientRect();
    if (!cardRetangulo) return;

    redimensionamentoRef.current = { x: evento.clientX, y: evento.clientY, largura: cardRetangulo.width, altura: cardRetangulo.height };
    setRedimensionando(true);
    evento.currentTarget.setPointerCapture(evento.pointerId);
  }

  function aoMoverRedimensionar(evento: EventoPonteiroReact<HTMLDivElement>) {
    if (!redimensionando) return;
    const containerRetangulo = containerRef.current?.getBoundingClientRect();

    const deltaX = evento.clientX - redimensionamentoRef.current.x;
    const deltaY = evento.clientY - redimensionamentoRef.current.y;

    const larguraMaxima = containerRetangulo ? containerRetangulo.width - 16 : 1200;
    const alturaMaxima = containerRetangulo ? containerRetangulo.height - 16 : 1200;

    const novaLargura = Math.min(Math.max(redimensionamentoRef.current.largura + deltaX, LARGURA_MINIMA), larguraMaxima);
    const novaAltura = Math.min(Math.max(redimensionamentoRef.current.altura + deltaY, ALTURA_MINIMA), alturaMaxima);

    onRedimensionar(id, { largura: novaLargura, altura: novaAltura });
  }

  function aoSoltarRedimensionar() {
    setRedimensionando(false);
  }

  return (
    <div
      ref={cardRef}
      className={`absolute flex flex-col rounded-2xl border border-papel-escuro bg-papel-claro/95 shadow-papel backdrop-blur transition-shadow ${arrastando || redimensionando ? 'shadow-papel-lg' : ''}`}
      style={{
        left: `${posicao.x}%`,
        top: `${posicao.y}%`,
        width: tamanho.largura,
        height: tamanho.altura ?? undefined,
        zIndex: arrastando || redimensionando ? 30 : 5,
      }}
    >
      <div
        onPointerDown={aoIniciarArraste}
        onPointerMove={aoMoverArraste}
        onPointerUp={aoSoltarArraste}
        className={`flex shrink-0 touch-none items-center gap-1.5 rounded-t-2xl border-b border-papel-escuro px-3 py-1.5 text-[10px] font-bold uppercase tracking-wide text-tinta-fraca ${
          travado ? 'cursor-default' : 'cursor-grab active:cursor-grabbing'
        }`}
      >
        {!travado && <GripVertical size={12} />}
        <span className="flex-1 truncate">{titulo}</span>
        {!travado && onRemover && (
          <button
            onPointerDown={(evento) => evento.stopPropagation()}
            onClick={onRemover}
            aria-label={`Remover ${titulo}`}
            className="-m-1 shrink-0 rounded p-1 text-tinta-fraca hover:text-tinta"
          >
            <X size={12} />
          </button>
        )}
      </div>

      <div className={`sem-scrollbar min-w-0 flex-1 p-3 ${tamanho.altura ? 'overflow-auto' : 'overflow-visible'}`}>{children}</div>

      {/* Alça de redimensionar: arraste o canto pra aumentar/diminuir o cartão. */}
      {!travado && (
        <div
          onPointerDown={aoIniciarRedimensionar}
          onPointerMove={aoMoverRedimensionar}
          onPointerUp={aoSoltarRedimensionar}
          aria-label={`Redimensionar ${titulo}`}
          className="absolute bottom-0 right-0 flex h-4 w-4 touch-none items-end justify-end p-0.5 text-tinta-fraca/60 hover:text-tinta-fraca"
          style={{ cursor: 'nwse-resize' }}
        >
          <svg width="8" height="8" viewBox="0 0 8 8" fill="none">
            <path d="M7 1L1 7M7 4.5L4.5 7M7 7.5L7.5 7" stroke="currentColor" strokeWidth="1" strokeLinecap="round" />
          </svg>
        </div>
      )}
    </div>
  );
}
