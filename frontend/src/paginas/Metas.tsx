import { Check, Plus, Target, X } from 'lucide-react';
import { type FormEvent, useEffect, useState } from 'react';
import { clienteApi } from '../api/cliente';
import { Carregando } from '../componentes/Carregando';
import type { Meta } from '../tipos';

/** Tela de lista de metas/objetivos do usuário. */
export function Metas() {
  const [metas, setMetas] = useState<Meta[]>([]);
  const [carregando, setCarregando] = useState(true);
  const [novoTitulo, setNovoTitulo] = useState('');

  // Busca as metas do usuário ao abrir a tela.
  useEffect(() => {
    async function buscarMetas() {
      const resposta = await clienteApi.get<Meta[]>('/metas');
      setMetas(resposta.data);
      setCarregando(false);
    }

    buscarMetas();
  }, []);

  /** Cria uma nova meta. */
  async function criarMeta(evento: FormEvent) {
    evento.preventDefault();

    if (!novoTitulo.trim()) return;

    const resposta = await clienteApi.post<Meta>('/metas', { titulo: novoTitulo });

    setMetas((atual) => [...atual, resposta.data]);
    setNovoTitulo('');
  }

  /** Alterna o status de conclusão de uma meta. */
  async function alternarConclusao(meta: Meta) {
    setMetas((atual) =>
      atual.map((item) => (item.id === meta.id ? { ...item, concluida: !item.concluida } : item)),
    );

    await clienteApi.patch(`/metas/${meta.id}/concluir`);
  }

  /** Remove uma meta. */
  async function removerMeta(meta: Meta) {
    setMetas((atual) => atual.filter((item) => item.id !== meta.id));
    await clienteApi.delete(`/metas/${meta.id}`);
  }

  return (
    <div className="flex flex-col gap-4">
      <header className="text-center">
        <h1 className="flex items-center justify-center gap-2 font-titulo text-3xl text-tinta sm:text-4xl">
          <Target size={24} className="text-destaque-rosa-escuro" /> Metas
        </h1>
        <p className="text-sm text-tinta-suave">Seus objetivos e planos</p>
      </header>

      <form onSubmit={criarMeta} className="flex gap-2">
        <input
          type="text"
          value={novoTitulo}
          onChange={(evento) => setNovoTitulo(evento.target.value)}
          placeholder="Nova meta..."
          className="campo-texto min-w-0 flex-1"
        />
        <button
          type="submit"
          className="flex items-center justify-center rounded-xl bg-tinta px-4 text-papel-claro shadow-papel"
          aria-label="Adicionar meta"
        >
          <Plus size={18} />
        </button>
      </form>

      {carregando ? (
        <Carregando />
      ) : (
        <ul className="flex flex-col gap-2">
          {metas.map((meta) => (
            <li key={meta.id} className="group flex items-center gap-2.5 rounded-xl border border-papel-escuro bg-papel-claro px-3 py-2.5 shadow-papel">
              <button
                onClick={() => alternarConclusao(meta)}
                aria-label={meta.concluida ? 'Marcar como pendente' : 'Marcar como concluída'}
                className={`flex h-8 w-8 shrink-0 items-center justify-center rounded-full border-2 transition-colors ${
                  meta.concluida
                    ? 'border-destaque-rosa-escuro bg-destaque-rosa-escuro text-papel-claro'
                    : 'border-papel-escuro text-transparent'
                }`}
              >
                <Check size={14} strokeWidth={3} />
              </button>
              <span className={`flex-1 text-sm ${meta.concluida ? 'text-tinta-fraca line-through' : 'text-tinta'}`}>
                {meta.titulo}
              </span>
              <button
                onClick={() => removerMeta(meta)}
                className="flex h-8 w-8 shrink-0 items-center justify-center text-tinta-fraca opacity-60 transition-opacity sm:opacity-0 sm:group-hover:opacity-100"
                aria-label="Remover meta"
              >
                <X size={16} />
              </button>
            </li>
          ))}

          {metas.length === 0 && (
            <p className="text-center text-xs italic text-tinta-fraca">Nenhuma meta cadastrada ainda.</p>
          )}
        </ul>
      )}
    </div>
  );
}
