import { createContext, useContext, useEffect, useState, type ReactNode } from 'react';
import { CHAVE_TOKEN, clienteApi } from '../api/cliente';
import type { Usuario } from '../tipos';

/** Formato dos dados e funções disponibilizados pelo contexto de autenticação. */
interface AutenticacaoContextoTipo {
  usuario: Usuario | null;
  carregando: boolean;
  entrar: (email: string, senha: string) => Promise<void>;
  registrar: (nome: string, email: string, senha: string, confirmacaoSenha: string) => Promise<void>;
  sair: () => Promise<void>;
}

const AutenticacaoContexto = createContext<AutenticacaoContextoTipo | undefined>(undefined);

/**
 * Provedor que gerencia o estado de autenticação do usuário
 * (login, registro, logout) e disponibiliza esses dados para toda a aplicação.
 */
export function AutenticacaoProvedor({ children }: { children: ReactNode }) {
  const [usuario, setUsuario] = useState<Usuario | null>(null);
  const [carregando, setCarregando] = useState(true);

  // Ao carregar a aplicação, tenta recuperar o usuário logado usando o token salvo.
  useEffect(() => {
    async function carregarUsuarioAutenticado() {
      const token = localStorage.getItem(CHAVE_TOKEN);

      if (!token) {
        setCarregando(false);
        return;
      }

      try {
        const resposta = await clienteApi.get<Usuario>('/usuario');
        setUsuario(resposta.data);
      } catch {
        localStorage.removeItem(CHAVE_TOKEN);
      } finally {
        setCarregando(false);
      }
    }

    carregarUsuarioAutenticado();
  }, []);

  /** Autentica o usuário com e-mail e senha, salvando o token retornado. */
  async function entrar(email: string, senha: string) {
    const resposta = await clienteApi.post('/login', { email, senha });

    localStorage.setItem(CHAVE_TOKEN, resposta.data.token);
    setUsuario(resposta.data.usuario);
  }

  /** Cadastra um novo usuário e já efetua o login. */
  async function registrar(nome: string, email: string, senha: string, confirmacaoSenha: string) {
    const resposta = await clienteApi.post('/registro', {
      nome,
      email,
      senha,
      senha_confirmation: confirmacaoSenha,
    });

    localStorage.setItem(CHAVE_TOKEN, resposta.data.token);
    setUsuario(resposta.data.usuario);
  }

  /** Efetua o logout, revogando o token no servidor e limpando o estado local. */
  async function sair() {
    try {
      await clienteApi.post('/logout');
    } finally {
      localStorage.removeItem(CHAVE_TOKEN);
      setUsuario(null);
    }
  }

  return (
    <AutenticacaoContexto.Provider value={{ usuario, carregando, entrar, registrar, sair }}>
      {children}
    </AutenticacaoContexto.Provider>
  );
}

/** Hook de acesso rápido ao contexto de autenticação. */
export function useAutenticacao(): AutenticacaoContextoTipo {
  const contexto = useContext(AutenticacaoContexto);

  if (!contexto) {
    throw new Error('useAutenticacao deve ser usado dentro de um AutenticacaoProvedor.');
  }

  return contexto;
}
