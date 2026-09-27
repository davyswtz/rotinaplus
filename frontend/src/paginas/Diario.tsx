import { ChevronLeft, ChevronRight, LogOut } from 'lucide-react';
import { useEffect, useState } from 'react';
import { clienteApi } from '../api/cliente';
import { Carregando } from '../componentes/Carregando';
import { useAutenticacao } from '../contextos/AutenticacaoContexto';
import type { Reflexao } from '../tipos';
import { adicionarSemanas, formatarDataISO, formatarIntervaloDaSemana, obterInicioDaSemana } from '../utilitarios/data';

/** Tela de reflexão livre sobre a semana (diário). */
export function Diario() {
  const { usuario, sair } = useAutenticacao();

  const [inicioSemana, setInicioSemana] = useState(() => obterInicioDaSemana(new Date()));
  const [texto, setTexto] = useState('');
  const [carregando, setCarregando] = useState(true);
  const [salvando, setSalvando] = useState(false);

  const semanaInicioISO = formatarDataISO(inicioSemana);

  // Busca a reflexão já salva para a semana selecionada.
  useEffect(() => {
    async function buscarReflexao() {
      setCarregando(true);

      const resposta = await clienteApi.get<Reflexao | null>('/reflexao', {
        params: { semana_inicio: semanaInicioISO },
      });

      setTexto(resposta.data?.texto ?? '');
      setCarregando(false);
    }

    buscarReflexao();
  }, [semanaInicioISO]);

  /** Salva o texto de reflexão da semana atual. */
  async function salvarReflexao() {
    setSalvando(true);

    try {
      await clienteApi.post('/reflexao', { semana_inicio: semanaInicioISO, texto });
    } finally {
      setSalvando(false);
    }
  }

  return (
    <div className="flex flex-col gap-4">
      <header className="flex items-center justify-between">
        <button
          onClick={() => setInicioSemana((atual) => adicionarSemanas(atual, -1))}
          className="botao-circular"
        >
          <ChevronLeft size={20} />
        </button>
        <div className="text-center">
          <h1 className="font-titulo text-3xl leading-none text-tinta sm:text-4xl">Diário</h1>
          <p className="text-sm text-tinta-suave">{formatarIntervaloDaSemana(inicioSemana)}</p>
        </div>
        <button
          onClick={() => setInicioSemana((atual) => adicionarSemanas(atual, 1))}
          className="botao-circular"
        >
          <ChevronRight size={20} />
        </button>
      </header>

      {carregando ? (
        <Carregando />
      ) : (
        <>
          {/* "Folha de caderno": cartão levemente girado, com fita adesiva e furos de espiral */}
          <div className="relative -rotate-[0.6deg] rounded-md shadow-lg shadow-tinta/15">
            {/* Fita adesiva decorativa no topo da folha */}
            <div className="absolute -top-3 left-1/2 h-6 w-20 -translate-x-1/2 -rotate-2 rounded-sm bg-destaque-areia/70 shadow-sm" />

            {/* Furos de espiral na margem esquerda */}
            <div className="pointer-events-none absolute inset-y-0 left-3 z-10 flex flex-col justify-evenly py-6">
              {Array.from({ length: 8 }).map((_, indice) => (
                <span
                  key={indice}
                  className="h-2.5 w-2.5 rounded-full bg-papel shadow-[inset_0_1px_2px_rgba(0,0,0,0.25)]"
                />
              ))}
            </div>

            <textarea
              value={texto}
              onChange={(evento) => setTexto(evento.target.value)}
              placeholder="Como foi sua semana?"
              rows={14}
              className="folha-pautada font-manuscrito w-full resize-none rounded-md border border-papel-escuro text-lg text-tinta outline-none focus:border-tinta"
            />
          </div>

          <button onClick={salvarReflexao} disabled={salvando} className="botao-primario">
            {salvando ? 'Salvando...' : 'Salvar reflexão'}
          </button>
        </>
      )}

      <div className="mt-6 flex items-center justify-between border-t border-papel-escuro pt-4">
        <span className="text-xs text-tinta-suave">Logado como {usuario?.nome}</span>
        <button onClick={sair} className="-m-2 flex items-center gap-1 p-2 text-xs font-semibold text-tinta-fraca underline">
          <LogOut size={13} /> Sair
        </button>
      </div>
    </div>
  );
}
