import { CadernoDesktop } from './CadernoDesktop';
import { Semana } from './Semana';

/**
 * Tela inicial ("/"): no mobile/tablet mostra a visão de Semana em coluna
 * única (como o resto do app); a partir do breakpoint lg (desktop) mostra
 * o caderno de duas folhas, que já reúne semana, hábitos, água, humor,
 * metas e reflexão em uma página só.
 */
export function PaginaInicial() {
  return (
    <>
      <div className="lg:hidden">
        <Semana />
      </div>
      <div className="hidden lg:block">
        <CadernoDesktop />
      </div>
    </>
  );
}
