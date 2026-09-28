import { CalendarDays, ListChecks, NotebookPen, Target, Wallet } from 'lucide-react';
import { NavLink } from 'react-router-dom';

/**
 * Itens exibidos na barra de navegação inferior (padrão mobile-first).
 * Cada seção tem uma cor de destaque própria (dentro do mesmo espectro
 * pastel do app), o que ajuda o usuário a identificar onde está.
 */
const ITENS_NAVEGACAO = [
  { caminho: '/', rotulo: 'Semana', Icone: CalendarDays, corAtiva: 'text-destaque-azul-escuro', corFundo: 'bg-destaque-azul-claro' },
  { caminho: '/habitos', rotulo: 'Hábitos', Icone: ListChecks, corAtiva: 'text-destaque-verde-escuro', corFundo: 'bg-destaque-verde-claro' },
  { caminho: '/metas', rotulo: 'Metas', Icone: Target, corAtiva: 'text-destaque-rosa-escuro', corFundo: 'bg-destaque-rosa-claro' },
  { caminho: '/financeiro', rotulo: 'Financeiro', Icone: Wallet, corAtiva: 'text-destaque-roxo-escuro', corFundo: 'bg-destaque-roxo-claro' },
  { caminho: '/diario', rotulo: 'Diário', Icone: NotebookPen, corAtiva: 'text-destaque-areia-escuro', corFundo: 'bg-destaque-areia-claro' },
];

/**
 * Navegação principal do app: barra fixa na parte inferior no mobile/tablet
 * (padrão comum em apps mobile) e, a partir do breakpoint lg (desktop),
 * vira uma barra lateral fixa à esquerda — padrão mais natural em telas largas.
 */
export function NavegacaoInferior() {
  return (
    <nav className="fixed inset-x-0 bottom-0 z-10 border-t border-papel-escuro bg-papel-claro/95 pb-[env(safe-area-inset-bottom)] backdrop-blur lg:inset-x-auto lg:inset-y-0 lg:left-0 lg:w-60 lg:border-t-0 lg:border-r lg:pb-0 lg:pt-8">
      <p className="hidden px-5 pb-6 font-titulo text-2xl text-tinta lg:block">Rotina Plus</p>

      <ul className="mx-auto flex max-w-md justify-around px-1 py-1.5 sm:max-w-xl sm:py-2 md:max-w-2xl lg:mx-0 lg:max-w-none lg:flex-col lg:items-stretch lg:justify-start lg:gap-1 lg:px-3 lg:py-0">
        {ITENS_NAVEGACAO.map(({ caminho, rotulo, Icone, corAtiva, corFundo }) => (
          <li key={caminho} className="flex flex-1 justify-center lg:flex-none lg:justify-stretch">
            <NavLink
              to={caminho}
              end={caminho === '/'}
              className={({ isActive }) =>
                `flex min-h-[44px] flex-col items-center justify-center gap-0.5 rounded-xl px-2 py-1.5 text-[10px] font-semibold transition-colors sm:min-h-[48px] sm:text-xs sm:hover:bg-papel-escuro/60 lg:w-full lg:flex-row lg:justify-start lg:gap-3 lg:px-3 lg:py-2.5 lg:text-sm ${
                  isActive ? `${corAtiva} ${corFundo}` : 'text-tinta-fraca'
                }`
              }
            >
              {({ isActive }) => (
                <>
                  <Icone size={19} strokeWidth={isActive ? 2.5 : 2} className="sm:h-5 sm:w-5" />
                  {rotulo}
                </>
              )}
            </NavLink>
          </li>
        ))}
      </ul>
    </nav>
  );
}
