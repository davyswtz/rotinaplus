import { createContext, useContext, useEffect, useState, type ReactNode } from 'react';

export type Tema = 'claro' | 'escuro';

const CHAVE_TEMA = 'rotina-plus-tema';

/** Formato dos dados e funções disponibilizados pelo contexto de tema. */
interface TemaContextoTipo {
  tema: Tema;
  alternarTema: () => void;
}

const TemaContexto = createContext<TemaContextoTipo | undefined>(undefined);

/** Lê o tema salvo pelo usuário ou, na ausência dele, segue a preferência do sistema. */
function obterTemaInicial(): Tema {
  const salvo = localStorage.getItem(CHAVE_TEMA);
  if (salvo === 'claro' || salvo === 'escuro') return salvo;

  const prefereEscuro = window.matchMedia('(prefers-color-scheme: dark)').matches;
  return prefereEscuro ? 'escuro' : 'claro';
}

/**
 * Provedor do tema claro/escuro do app. Aplica a classe `dark` no <html>
 * (usada pelo Tailwind e pelas variáveis de cor em index.css) e salva a
 * escolha do usuário para as próximas visitas.
 */
export function TemaProvedor({ children }: { children: ReactNode }) {
  const [tema, setTema] = useState<Tema>(obterTemaInicial);

  useEffect(() => {
    document.documentElement.classList.toggle('dark', tema === 'escuro');
    localStorage.setItem(CHAVE_TEMA, tema);

    const metaThemeColor = document.querySelector('meta[name="theme-color"]');
    metaThemeColor?.setAttribute('content', tema === 'escuro' ? '#000000' : '#f2ead9');
  }, [tema]);

  function alternarTema() {
    setTema((atual) => (atual === 'claro' ? 'escuro' : 'claro'));
  }

  return <TemaContexto.Provider value={{ tema, alternarTema }}>{children}</TemaContexto.Provider>;
}

/** Hook de acesso rápido ao contexto de tema. */
export function useTema(): TemaContextoTipo {
  const contexto = useContext(TemaContexto);

  if (!contexto) {
    throw new Error('useTema deve ser usado dentro de um TemaProvedor.');
  }

  return contexto;
}
