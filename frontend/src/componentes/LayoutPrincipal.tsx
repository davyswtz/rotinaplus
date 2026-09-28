import { Outlet } from 'react-router-dom';
import { AlternarTema } from './AlternarTema';
import { NavegacaoInferior } from './NavegacaoInferior';

/**
 * Layout usado nas telas internas do app: mobile-first (largura de celular
 * por padrão), ganha respiro em tablet e, a partir do breakpoint lg
 * (desktop), abre espaço para a navegação lateral e usa uma coluna bem
 * mais larga em vez de continuar limitado à largura de um celular.
 */
export function LayoutPrincipal() {
  return (
    <div className="min-h-screen bg-papel">
      <main className="mx-auto min-h-screen max-w-md bg-papel px-4 pb-28 pt-6 sm:max-w-xl sm:px-6 sm:pt-8 md:max-w-2xl lg:ml-60 lg:max-w-5xl lg:px-10 lg:pb-10 lg:pt-10">
        <Outlet />
      </main>
      <AlternarTema />
      <NavegacaoInferior />
    </div>
  );
}
