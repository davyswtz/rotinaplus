import { BrowserRouter, Route, Routes } from 'react-router-dom';
import { LayoutPrincipal } from './componentes/LayoutPrincipal';
import { RotaProtegida } from './componentes/RotaProtegida';
import { AutenticacaoProvedor } from './contextos/AutenticacaoContexto';
import { Diario } from './paginas/Diario';
import { Financeiro } from './paginas/Financeiro';
import { Habitos } from './paginas/Habitos';
import { Login } from './paginas/Login';
import { Metas } from './paginas/Metas';
import { Registro } from './paginas/Registro';
import { Semana } from './paginas/Semana';

/** Componente raiz: define o provedor de autenticação e as rotas da aplicação. */
function App() {
  return (
    <AutenticacaoProvedor>
      <BrowserRouter>
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route path="/registro" element={<Registro />} />

          <Route element={<RotaProtegida />}>
            <Route element={<LayoutPrincipal />}>
              <Route path="/" element={<Semana />} />
              <Route path="/habitos" element={<Habitos />} />
              <Route path="/metas" element={<Metas />} />
              <Route path="/financeiro" element={<Financeiro />} />
              <Route path="/diario" element={<Diario />} />
            </Route>
          </Route>
        </Routes>
      </BrowserRouter>
    </AutenticacaoProvedor>
  );
}

export default App;
