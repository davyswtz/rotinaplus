import { Outlet } from 'react-router-dom';
import { NavegacaoInferior } from './NavegacaoInferior';

/**
 * Layout usado nas telas internas do app: mobile-first (largura de celular
 * por padrão), mas ganha um pouco mais de respiro em telas maiores
 * (tablet/desktop) sem deixar de ser a mesma experiência em coluna única.
 */
export function LayoutPrincipal() {
  return (
    <div className="min-h-screen bg-papel">
      <main className="mx-auto min-h-screen max-w-md bg-papel px-4 pb-28 pt-6 sm:max-w-xl sm:px-6 sm:pt-8 md:max-w-2xl">
        <Outlet />
      </main>
      <NavegacaoInferior />
    </div>
  );
}
