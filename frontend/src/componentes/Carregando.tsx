import { Loader2 } from 'lucide-react';

/** Indicador de carregamento padrão, usado enquanto os dados de uma tela são buscados. */
export function Carregando() {
  return (
    <div className="flex flex-col items-center justify-center gap-2 py-10 text-tinta-fraca">
      <Loader2 size={22} className="animate-spin" />
      <span className="text-sm">Carregando...</span>
    </div>
  );
}
