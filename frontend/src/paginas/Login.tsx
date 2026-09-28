import { type FormEvent, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import logo from '../assets/logo.png';
import { AlternarTema } from '../componentes/AlternarTema';
import { useAutenticacao } from '../contextos/AutenticacaoContexto';

/** Tela de login do sistema. */
export function Login() {
  const { entrar } = useAutenticacao();
  const navegar = useNavigate();

  const [email, setEmail] = useState('');
  const [senha, setSenha] = useState('');
  const [erro, setErro] = useState<string | null>(null);
  const [enviando, setEnviando] = useState(false);

  /** Envia o formulário de login. */
  async function aoEnviarFormulario(evento: FormEvent) {
    evento.preventDefault();
    setErro(null);
    setEnviando(true);

    try {
      await entrar(email, senha);
      navegar('/');
    } catch {
      setErro('E-mail ou senha incorretos. Tente novamente.');
    } finally {
      setEnviando(false);
    }
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-papel px-4 py-8">
      <AlternarTema />
      <div className="w-full max-w-sm rounded-3xl border border-papel-escuro bg-papel-claro p-6 shadow-papel-lg sm:max-w-md sm:p-8">
        <img src={logo} alt="Rotina Plus" className="mb-1 h-16 w-16 rounded-2xl object-cover shadow-papel" />
        <h1 className="font-titulo text-4xl text-tinta sm:text-5xl">Rotina Plus</h1>
        <p className="mb-6 text-sm text-tinta-suave">Organize sua semana, hábitos e metas.</p>

        <form onSubmit={aoEnviarFormulario} className="flex flex-col gap-3">
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
            className="campo-texto"
          />

          {erro && <p className="text-sm text-destaque-rosa-escuro">{erro}</p>}

          <button type="submit" disabled={enviando} className="botao-primario mt-2">
            {enviando ? 'Entrando...' : 'Entrar'}
          </button>
        </form>

        <p className="mt-4 text-center text-sm text-tinta-suave">
          Ainda não tem conta?{' '}
          <Link to="/registro" className="font-semibold text-destaque-azul-escuro underline">
            Cadastre-se
          </Link>
        </p>
      </div>
    </div>
  );
}
