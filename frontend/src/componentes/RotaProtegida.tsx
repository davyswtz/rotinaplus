import { Navigate, Outlet } from 'react-router-dom';
import { useAutenticacao } from '../contextos/AutenticacaoContexto';
import { Carregando } from './Carregando';

/**
 * Só permite acesso às rotas filhas se houver um usuário autenticado.
 * Caso contrário, redireciona para a tela de login.
 */
export function RotaProtegida() {
  const { usuario, carregando } = useAutenticacao();

  if (carregando) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-papel">
        <Carregando />
      </div>
    );
  }

  if (!usuario) {
    return <Navigate to="/login" replace />;
  }

  return <Outlet />;
}
