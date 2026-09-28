import { Moon, Sun } from 'lucide-react';
import { useTema } from '../contextos/TemaContexto';

/**
 * Botão fixo que alterna entre o tema claro e o escuro. Fica visível em
 * qualquer tela do app (mobile ou desktop), sempre acima do conteúdo.
 */
export function AlternarTema() {
  const { tema, alternarTema } = useTema();

  return (
    <button
      onClick={alternarTema}
      aria-label={tema === 'escuro' ? 'Ativar tema claro' : 'Ativar tema escuro'}
      className="fixed right-4 top-4 z-30 flex h-10 w-10 items-center justify-center rounded-full border border-papel-escuro bg-papel-claro text-tinta shadow-papel transition-transform active:scale-95 sm:hover:bg-papel-escuro"
    >
      {tema === 'escuro' ? <Sun size={17} /> : <Moon size={17} />}
    </button>
  );
}
