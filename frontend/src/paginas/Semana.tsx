import { Check, ChevronLeft, ChevronRight, Plus, X } from 'lucide-react';
import { type FormEvent, useEffect, useState } from 'react';
import { clienteApi } from '../api/cliente';
import { Carregando } from '../componentes/Carregando';
import type { Tarefa } from '../tipos';
import {
  adicionarSemanas,
  formatarDataISO,
  formatarIntervaloDaSemana,
  NOMES_DIAS_SEMANA,
  obterDiasDaSemana,
  obterInicioDaSemana,
} from '../utilitarios/data';

/** Tela principal: visão semanal com as tarefas de rotina de cada dia. */
export function Semana() {
  const [inicioSemana, setInicioSemana] = useState(() => obterInicioDaSemana(new Date()));
  const [tarefas, setTarefas] = useState<Tarefa[]>([]);
  const [percentualConcluido, setPercentualConcluido] = useState(0);
  const [carregando, setCarregando] = useState(true);
  const [diaComFormularioAberto, setDiaComFormularioAberto] = useState<string | null>(null);
  const [novoTitulo, setNovoTitulo] = useState('');

  const diasDaSemana = obterDiasDaSemana(inicioSemana);
  const hojeISO = formatarDataISO(new Date());

  // Sempre que a semana selecionada mudar, busca as tarefas correspondentes na API.
  useEffect(() => {
    async function buscarTarefasDaSemana() {
      setCarregando(true);

      const dataInicio = formatarDataISO(diasDaSemana[0]);
      const dataFim = formatarDataISO(diasDaSemana[6]);

      const resposta = await clienteApi.get('/tarefas', {
        params: { data_inicio: dataInicio, data_fim: dataFim },
      });

      setTarefas(resposta.data.tarefas);
      setPercentualConcluido(resposta.data.percentual_concluido);
      setCarregando(false);
    }

    buscarTarefasDaSemana();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [inicioSemana]);

  /** Retorna as tarefas pertencentes a um dia específico. */
  function tarefasDoDia(data: Date): Tarefa[] {
    const dataISO = formatarDataISO(data);
    return tarefas.filter((tarefa) => tarefa.data.startsWith(dataISO));
  }

  /** Alterna o status de conclusão de uma tarefa (marca/desmarca o checkbox). */
  async function alternarConclusao(tarefa: Tarefa) {
    setTarefas((atual) =>
      atual.map((item) => (item.id === tarefa.id ? { ...item, concluida: !item.concluida } : item)),
    );

    await clienteApi.patch(`/tarefas/${tarefa.id}/concluir`);
  }

  /** Remove uma tarefa da lista. */
  async function removerTarefa(tarefa: Tarefa) {
    setTarefas((atual) => atual.filter((item) => item.id !== tarefa.id));
    await clienteApi.delete(`/tarefas/${tarefa.id}`);
  }

  /** Cria uma nova tarefa no dia informado. */
  async function criarTarefa(evento: FormEvent, data: Date) {
    evento.preventDefault();

    if (!novoTitulo.trim()) {
      return;
    }

    const resposta = await clienteApi.post<Tarefa>('/tarefas', {
      titulo: novoTitulo,
      data: formatarDataISO(data),
    });

    setTarefas((atual) => [...atual, resposta.data]);
    setNovoTitulo('');
    setDiaComFormularioAberto(null);
  }

  return (
    <div className="flex flex-col gap-4">
      {/* Cabeçalho com navegação entre semanas */}
      <header className="flex items-center justify-between">
        <button
          onClick={() => setInicioSemana((atual) => adicionarSemanas(atual, -1))}
          className="botao-circular"
          aria-label="Semana anterior"
        >
          <ChevronLeft size={20} />
        </button>

        <div className="text-center">
          <h1 className="font-titulo text-3xl leading-none text-tinta sm:text-4xl">Minha Semana</h1>
          <p className="text-sm text-tinta-suave">{formatarIntervaloDaSemana(inicioSemana)}</p>
        </div>

        <button
          onClick={() => setInicioSemana((atual) => adicionarSemanas(atual, 1))}
          className="botao-circular"
          aria-label="Próxima semana"
        >
          <ChevronRight size={20} />
        </button>
      </header>

      {/* Barra de progresso semanal */}
      <div className="cartao py-3">
        <div className="h-2.5 w-full overflow-hidden rounded-full bg-papel-escuro">
          <div
            className="h-full rounded-full bg-gradient-to-r from-destaque-azul-escuro to-destaque-azul transition-all"
            style={{ width: `${percentualConcluido}%` }}
          />
        </div>
        <p className="mt-1.5 text-right text-xs font-semibold text-destaque-azul-escuro">
          {percentualConcluido}% concluído
        </p>
      </div>

      {/* Lista de dias da semana, cada um com suas tarefas.
          Em telas maiores (tablet/desktop) vira um grid de 2-3 colunas. */}
      {carregando ? (
        <Carregando />
      ) : (
        <div className="grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-3">
          {diasDaSemana.map((dia, indice) => {
            const dataISO = formatarDataISO(dia);
            const tarefasDesteDia = tarefasDoDia(dia);
            const formularioAberto = diaComFormularioAberto === dataISO;
            const ehHoje = dataISO === hojeISO;

            return (
              <section
                key={dataISO}
                className={`cartao border-l-4 ${ehHoje ? 'border-l-destaque-azul-escuro' : 'border-l-papel-escuro'}`}
              >
                <div className="mb-2 flex items-center gap-2.5">
                  <span
                    className={`flex h-9 w-9 shrink-0 items-center justify-center rounded-full text-base font-bold ${
                      ehHoje ? 'bg-destaque-azul-escuro text-papel-claro' : 'bg-papel-escuro text-tinta'
                    }`}
                  >
                    {dia.getDate()}
                  </span>
                  <span className="text-sm font-semibold uppercase tracking-wide text-tinta-suave">
                    {NOMES_DIAS_SEMANA[indice]}
                  </span>
                </div>

                <ul className="flex flex-col gap-1.5">
                  {tarefasDesteDia.map((tarefa) => (
                    <li key={tarefa.id} className="group flex items-center gap-2">
                      <button
                        onClick={() => alternarConclusao(tarefa)}
                        aria-label={tarefa.concluida ? 'Marcar como pendente' : 'Marcar como concluída'}
                        className={`flex h-8 w-8 shrink-0 items-center justify-center rounded-md border-2 transition-colors ${
                          tarefa.concluida
                            ? 'border-destaque-azul-escuro bg-destaque-azul-escuro text-papel-claro'
                            : 'border-papel-escuro text-transparent'
                        }`}
                      >
                        <Check size={15} strokeWidth={3} />
                      </button>
                      <span
                        className={`flex-1 text-sm ${
                          tarefa.concluida ? 'text-tinta-fraca line-through' : 'text-tinta'
                        }`}
                      >
                        {tarefa.titulo}
                      </span>
                      <button
                        onClick={() => removerTarefa(tarefa)}
                        className="flex h-8 w-8 shrink-0 items-center justify-center text-tinta-fraca opacity-60 transition-opacity sm:opacity-0 sm:group-hover:opacity-100"
                        aria-label="Remover tarefa"
                      >
                        <X size={15} />
                      </button>
                    </li>
                  ))}

                  {tarefasDesteDia.length === 0 && !formularioAberto && (
                    <li className="text-xs italic text-tinta-fraca">Nenhuma tarefa neste dia.</li>
                  )}
                </ul>

                {formularioAberto ? (
                  <form onSubmit={(evento) => criarTarefa(evento, dia)} className="mt-2 flex gap-2">
                    <input
                      autoFocus
                      type="text"
                      value={novoTitulo}
                      onChange={(evento) => setNovoTitulo(evento.target.value)}
                      onBlur={() => !novoTitulo && setDiaComFormularioAberto(null)}
                      placeholder="Nova tarefa..."
                      className="campo-texto min-w-0 flex-1"
                    />
                    <button
                      type="submit"
                      className="flex items-center justify-center rounded-xl bg-tinta px-3 text-papel-claro"
                      aria-label="Confirmar nova tarefa"
                    >
                      <Check size={16} />
                    </button>
                  </form>
                ) : (
                  <button
                    onClick={() => setDiaComFormularioAberto(dataISO)}
                    className="mt-2 flex items-center gap-1 text-xs font-semibold text-destaque-azul-escuro"
                  >
                    <Plus size={14} /> adicionar tarefa
                  </button>
                )}
              </section>
            );
          })}
        </div>
      )}
    </div>
  );
}
