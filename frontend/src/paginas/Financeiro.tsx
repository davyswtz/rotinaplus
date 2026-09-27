import { ChevronLeft, ChevronRight, Plus, Trash2, TrendingDown, TrendingUp, Wallet } from 'lucide-react';
import { type FormEvent, useEffect, useState } from 'react';
import { clienteApi } from '../api/cliente';
import { Carregando } from '../componentes/Carregando';
import type { ResumoFinanceiro, TipoTransacao, Transacao } from '../tipos';
import { adicionarMeses, formatarDataISO, formatarMesAno, obterFimDoMes, obterInicioDoMes } from '../utilitarios/data';
import { formatarMoeda } from '../utilitarios/moeda';

/** Categorias sugeridas para cada tipo de transação (agilizam o lançamento). */
const CATEGORIAS_POR_TIPO: Record<TipoTransacao, string[]> = {
  receita: ['Salário', 'Freelance', 'Investimentos', 'Presente', 'Outros'],
  despesa: ['Alimentação', 'Transporte', 'Moradia', 'Lazer', 'Saúde', 'Educação', 'Compras', 'Outros'],
};

/** Tela de controle financeiro: receitas, despesas e saldo do mês. */
export function Financeiro() {
  const [mesSelecionado, setMesSelecionado] = useState(() => obterInicioDoMes(new Date()));
  const [transacoes, setTransacoes] = useState<Transacao[]>([]);
  const [resumo, setResumo] = useState<ResumoFinanceiro>({ total_receitas: 0, total_despesas: 0, saldo: 0 });
  const [carregando, setCarregando] = useState(true);
  const [formularioAberto, setFormularioAberto] = useState(false);

  const [tipo, setTipo] = useState<TipoTransacao>('despesa');
  const [categoria, setCategoria] = useState(CATEGORIAS_POR_TIPO.despesa[0]);
  const [descricao, setDescricao] = useState('');
  const [valor, setValor] = useState('');
  const [dataLancamento, setDataLancamento] = useState(formatarDataISO(new Date()));

  const dataInicio = formatarDataISO(obterInicioDoMes(mesSelecionado));
  const dataFim = formatarDataISO(obterFimDoMes(mesSelecionado));

  // Busca as transações e o resumo do mês selecionado.
  useEffect(() => {
    async function buscarTransacoesDoMes() {
      setCarregando(true);

      const resposta = await clienteApi.get('/transacoes', {
        params: { data_inicio: dataInicio, data_fim: dataFim },
      });

      setTransacoes(resposta.data.transacoes);
      setResumo(resposta.data.resumo);
      setCarregando(false);
    }

    buscarTransacoesDoMes();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [mesSelecionado]);

  /** Troca o tipo da transação no formulário, ajustando a categoria sugerida. */
  function selecionarTipo(novoTipo: TipoTransacao) {
    setTipo(novoTipo);
    setCategoria(CATEGORIAS_POR_TIPO[novoTipo][0]);
  }

  /** Cria uma nova transação (receita ou despesa). */
  async function criarTransacao(evento: FormEvent) {
    evento.preventDefault();

    const valorNumerico = Number(valor.replace(',', '.'));
    if (!valorNumerico || valorNumerico <= 0) return;

    const resposta = await clienteApi.post<Transacao>('/transacoes', {
      tipo,
      categoria,
      descricao: descricao.trim() || null,
      valor: valorNumerico,
      data: dataLancamento,
    });

    // Só insere na lista local se a transação pertencer ao mês em exibição.
    if (resposta.data.data.slice(0, 7) === dataInicio.slice(0, 7)) {
      setTransacoes((atual) => [resposta.data, ...atual]);
      atualizarResumoLocal(resposta.data, 1);
    }

    setDescricao('');
    setValor('');
    setFormularioAberto(false);
  }

  /** Remove uma transação. */
  async function removerTransacao(transacao: Transacao) {
    setTransacoes((atual) => atual.filter((item) => item.id !== transacao.id));
    atualizarResumoLocal(transacao, -1);
    await clienteApi.delete(`/transacoes/${transacao.id}`);
  }

  /** Ajusta o resumo financeiro localmente sem esperar nova busca na API. */
  function atualizarResumoLocal(transacao: Transacao, sinal: 1 | -1) {
    const valorTransacao = Number(transacao.valor) * sinal;

    setResumo((atual) => {
      const receitas = atual.total_receitas + (transacao.tipo === 'receita' ? valorTransacao : 0);
      const despesas = atual.total_despesas + (transacao.tipo === 'despesa' ? valorTransacao : 0);

      return { total_receitas: receitas, total_despesas: despesas, saldo: receitas - despesas };
    });
  }

  return (
    <div className="flex flex-col gap-4">
      {/* Cabeçalho com navegação entre meses */}
      <header className="flex items-center justify-between">
        <button onClick={() => setMesSelecionado((atual) => adicionarMeses(atual, -1))} className="botao-circular">
          <ChevronLeft size={20} />
        </button>
        <div className="text-center">
          <h1 className="flex items-center justify-center gap-1.5 font-titulo text-3xl leading-none text-tinta sm:text-4xl">
            <Wallet size={22} className="text-destaque-roxo-escuro" /> Financeiro
          </h1>
          <p className="text-sm text-tinta-suave">{formatarMesAno(mesSelecionado)}</p>
        </div>
        <button onClick={() => setMesSelecionado((atual) => adicionarMeses(atual, 1))} className="botao-circular">
          <ChevronRight size={20} />
        </button>
      </header>

      {/* Resumo financeiro do mês: empilha o saldo embaixo no mobile,
          e vira 3 colunas lado a lado a partir de telas sm. */}
      <div className="grid grid-cols-2 gap-3 sm:grid-cols-3">
        <div className="cartao !p-3">
          <div className="flex items-center gap-1 text-xs font-semibold text-destaque-verde-escuro">
            <TrendingUp size={14} /> Receitas
          </div>
          <p className="mt-1 text-base font-bold text-tinta sm:text-lg">{formatarMoeda(resumo.total_receitas)}</p>
        </div>
        <div className="cartao !p-3">
          <div className="flex items-center gap-1 text-xs font-semibold text-destaque-rosa-escuro">
            <TrendingDown size={14} /> Despesas
          </div>
          <p className="mt-1 text-base font-bold text-tinta sm:text-lg">{formatarMoeda(resumo.total_despesas)}</p>
        </div>
        <div className="cartao col-span-2 !p-3 border-l-4 border-l-destaque-roxo-escuro sm:col-span-1">
          <div className="flex items-center gap-1 text-xs font-semibold text-destaque-roxo-escuro">Saldo do mês</div>
          <p className={`mt-1 text-base font-bold sm:text-lg ${resumo.saldo < 0 ? 'text-destaque-rosa-escuro' : 'text-tinta'}`}>
            {formatarMoeda(resumo.saldo)}
          </p>
        </div>
      </div>

      {/* Formulário de nova transação */}
      {formularioAberto ? (
        <form onSubmit={criarTransacao} className="cartao flex flex-col gap-3 border-l-4 border-l-destaque-roxo-escuro">
          <div className="flex gap-2">
            <button
              type="button"
              onClick={() => selecionarTipo('despesa')}
              className={`min-h-[44px] flex-1 rounded-xl text-sm font-semibold transition-colors ${
                tipo === 'despesa' ? 'bg-destaque-rosa-escuro text-papel-claro' : 'bg-papel-escuro text-tinta-suave'
              }`}
            >
              Despesa
            </button>
            <button
              type="button"
              onClick={() => selecionarTipo('receita')}
              className={`min-h-[44px] flex-1 rounded-xl text-sm font-semibold transition-colors ${
                tipo === 'receita' ? 'bg-destaque-verde-escuro text-papel-claro' : 'bg-papel-escuro text-tinta-suave'
              }`}
            >
              Receita
            </button>
          </div>

          <select value={categoria} onChange={(evento) => setCategoria(evento.target.value)} className="campo-texto">
            {CATEGORIAS_POR_TIPO[tipo].map((opcao) => (
              <option key={opcao} value={opcao}>
                {opcao}
              </option>
            ))}
          </select>

          <input
            type="text"
            value={descricao}
            onChange={(evento) => setDescricao(evento.target.value)}
            placeholder="Descrição (opcional)"
            className="campo-texto"
          />

          {/* Empilhados no mobile: o input de data tem um tamanho mínimo interno
              (ícone do calendário) que não cabe lado a lado em telas estreitas. */}
          <div className="grid grid-cols-1 gap-2 sm:grid-cols-2">
            <input
              type="number"
              step="0.01"
              min="0.01"
              value={valor}
              onChange={(evento) => setValor(evento.target.value)}
              placeholder="Valor (R$)"
              required
              autoFocus
              className="campo-texto min-w-0"
            />
            <input
              type="date"
              value={dataLancamento}
              onChange={(evento) => setDataLancamento(evento.target.value)}
              required
              className="campo-texto min-w-0"
            />
          </div>

          <div className="flex gap-2">
            <button
              type="button"
              onClick={() => setFormularioAberto(false)}
              className="min-h-[44px] flex-1 rounded-xl bg-papel-escuro text-sm font-semibold text-tinta-suave sm:min-h-[46px]"
            >
              Cancelar
            </button>
            <button type="submit" className="botao-primario flex-1">
              Lançar
            </button>
          </div>
        </form>
      ) : (
        <button
          onClick={() => setFormularioAberto(true)}
          className="flex min-h-[44px] items-center justify-center gap-1.5 rounded-xl border-2 border-dashed border-destaque-roxo text-sm font-semibold text-destaque-roxo-escuro"
        >
          <Plus size={16} /> Nova transação
        </button>
      )}

      {/* Lista de transações do mês */}
      {carregando ? (
        <Carregando />
      ) : (
        <ul className="flex flex-col gap-2">
          {transacoes.map((transacao) => (
            <li key={transacao.id} className="group flex items-center gap-3 rounded-xl border border-papel-escuro bg-papel-claro px-3 py-2.5 shadow-papel">
              <div
                className={`flex h-9 w-9 shrink-0 items-center justify-center rounded-full ${
                  transacao.tipo === 'receita'
                    ? 'bg-destaque-verde-claro text-destaque-verde-escuro'
                    : 'bg-destaque-rosa-claro text-destaque-rosa-escuro'
                }`}
              >
                {transacao.tipo === 'receita' ? <TrendingUp size={16} /> : <TrendingDown size={16} />}
              </div>

              <div className="min-w-0 flex-1">
                <p className="truncate text-sm font-semibold text-tinta">{transacao.descricao || transacao.categoria}</p>
                <p className="text-xs text-tinta-fraca">
                  {transacao.categoria} · {transacao.data.split('-').reverse().join('/')}
                </p>
              </div>

              <span
                className={`shrink-0 text-sm font-bold ${
                  transacao.tipo === 'receita' ? 'text-destaque-verde-escuro' : 'text-destaque-rosa-escuro'
                }`}
              >
                {transacao.tipo === 'receita' ? '+' : '-'} {formatarMoeda(Number(transacao.valor))}
              </span>

              <button
                onClick={() => removerTransacao(transacao)}
                className="flex h-8 w-8 shrink-0 items-center justify-center text-tinta-fraca opacity-60 transition-opacity sm:opacity-0 sm:group-hover:opacity-100"
                aria-label="Remover transação"
              >
                <Trash2 size={15} />
              </button>
            </li>
          ))}

          {transacoes.length === 0 && (
            <p className="text-center text-xs italic text-tinta-fraca">Nenhuma transação lançada neste mês.</p>
          )}
        </ul>
      )}
    </div>
  );
}
