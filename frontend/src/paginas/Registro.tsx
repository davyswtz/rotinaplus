import { type FormEvent, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import logo from '../assets/logo.png';
import { useAutenticacao } from '../contextos/AutenticacaoContexto';

/** Tela de cadastro de um novo usuário. */
export function Registro() {
  const { registrar } = useAutenticacao();
  const navegar = useNavigate();

  const [nome, setNome] = useState('');
  const [email, setEmail] = useState('');
  const [senha, setSenha] = useState('');
  const [confirmacaoSenha, setConfirmacaoSenha] = useState('');
  const [erro, setErro] = useState<string | null>(null);
  const [enviando, setEnviando] = useState(false);

  /** Envia o formulário de cadastro. */
  async function aoEnviarFormulario(evento: FormEvent) {
    evento.preventDefault();
    setErro(null);

    if (senha !== confirmacaoSenha) {
      setErro('As senhas não coincidem.');
      return;
    }

    setEnviando(true);

    try {
      await registrar(nome, email, senha, confirmacaoSenha);
      navegar('/');
    } catch {
      setErro('Não foi possível concluir o cadastro. Verifique os dados informados.');
    } finally {
      setEnviando(false);
    }
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-papel px-4 py-8">
      <div className="w-full max-w-sm rounded-3xl border border-papel-escuro bg-papel-claro p-6 shadow-papel-lg sm:max-w-md sm:p-8">
        <img src={logo} alt="Rotina Plus" className="mb-1 h-16 w-16 rounded-2xl object-cover shadow-papel" />
        <h1 className="font-titulo text-4xl text-tinta sm:text-5xl">Criar conta</h1>
        <p className="mb-6 text-sm text-tinta-suave">Comece a organizar sua rotina.</p>

        <form onSubmit={aoEnviarFormulario} className="flex flex-col gap-3">
          <input
            type="text"
            placeholder="Nome"
            value={nome}
            onChange={(evento) => setNome(evento.target.value)}
            required
            className="campo-texto"
          />
          <input
            type="email"
            placeholder="E-mail"
            value={email}
            onChange={(evento) => setEmail(evento.target.value)}
            required
            className="campo-texto"
          />
          <input
            type="password"
            placeholder="Senha"
            value={senha}
            onChange={(evento) => setSenha(evento.target.value)}
            required
            minLength={6}
            className="campo-texto"
          />
          <input
            type="password"
            placeholder="Confirmar senha"
            value={confirmacaoSenha}
            onChange={(evento) => setConfirmacaoSenha(evento.target.value)}
            required
            minLength={6}
            className="campo-texto"
          />

          {erro && <p className="text-sm text-destaque-rosa-escuro">{erro}</p>}

          <button type="submit" disabled={enviando} className="botao-primario mt-2">
            {enviando ? 'Criando conta...' : 'Criar conta'}
          </button>
        </form>

        <p className="mt-4 text-center text-sm text-tinta-suave">
          Já tem conta?{' '}
          <Link to="/login" className="font-semibold text-destaque-verde-escuro underline">
            Entrar
          </Link>
        </p>
      </div>
    </div>
  );
}
