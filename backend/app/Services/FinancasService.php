<?php

namespace App\Services;

use App\Models\FinancasMeta;
use App\Models\FinancasTransacao;
use App\Models\User;
use App\Support\FinancasCatalog;
use Carbon\Carbon;
use Illuminate\Support\Collection;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class FinancasService
{
    public function resumo(User $user, ?string $anoMes = null): array
    {
        $ref = $this->resolverMes($anoMes);
        $inicio = $ref->copy()->startOfMonth();
        $fim = $ref->copy()->endOfMonth();

        $transacoesMes = FinancasTransacao::query()
            ->where('user_id', $user->id)
            ->whereBetween('data', [$inicio->toDateString(), $fim->toDateString()])
            ->orderByDesc('data')
            ->orderByDesc('id')
            ->get();

        $receita = (int) $transacoesMes->where('tipo', 'receita')->sum('valor_centavos');
        $gastos = (int) $transacoesMes->where('tipo', 'despesa')->sum('valor_centavos');

        return [
            'ano_mes' => $ref->format('Y-m'),
            'mes_label' => $this->labelMes($ref),
            'meses' => $this->mesesDisponiveis($user, $ref),
            'saldo_centavos' => $receita - $gastos,
            'receita_centavos' => $receita,
            'gastos_centavos' => $gastos,
            'serie_mensal' => $this->serieMensal($user, $ref),
            'distribuicao' => $this->distribuicao($transacoesMes),
            'recentes' => $transacoesMes->take(8)->values(),
            'transacoes' => $transacoesMes->values(),
            'metas' => FinancasMeta::query()
                ->where('user_id', $user->id)
                ->orderBy('id')
                ->get(),
            'categorias' => $this->categoriasPayload(),
        ];
    }

    /**
     * @param  array{tipo: string, categoria: string, titulo: string, icone?: string, valor_centavos: int, data: string}  $dados
     */
    public function criarTransacao(User $user, array $dados): FinancasTransacao
    {
        $tipo = $dados['tipo'];
        $categoria = $dados['categoria'];

        if ($tipo === 'receita') {
            $categoria = 'receita';
        } elseif (! in_array($categoria, FinancasCatalog::chavesDespesa(), true)) {
            throw ValidationException::withMessages([
                'categoria' => ['Categoria inválida.'],
            ]);
        }

        $catalogo = $tipo === 'receita'
            ? FinancasCatalog::categoriaReceita()
            : FinancasCatalog::categoriasDespesa()[$categoria];

        return FinancasTransacao::query()->create([
            'user_id' => $user->id,
            'tipo' => $tipo,
            'categoria' => $categoria,
            'titulo' => $dados['titulo'],
            'icone' => $dados['icone'] ?? $catalogo['icone'],
            'valor_centavos' => $dados['valor_centavos'],
            'data' => $dados['data'],
        ]);
    }

    public function excluirTransacao(User $user, int $id): void
    {
        $tx = FinancasTransacao::query()
            ->where('user_id', $user->id)
            ->find($id);

        if (! $tx) {
            throw new NotFoundHttpException('Transação não encontrada.');
        }

        $tx->delete();
    }

    /**
     * @param  array{titulo: string, icone?: string, categoria?: string|null, valor_alvo_centavos: int}  $dados
     */
    public function criarMeta(User $user, array $dados): FinancasMeta
    {
        return FinancasMeta::query()->create([
            'user_id' => $user->id,
            'titulo' => $dados['titulo'],
            'icone' => $dados['icone'] ?? '🎯',
            'categoria' => $dados['categoria'] ?? null,
            'valor_alvo_centavos' => $dados['valor_alvo_centavos'],
            'valor_atual_centavos' => 0,
        ]);
    }

    /**
     * @param  array{valor_atual_centavos?: int, titulo?: string}  $dados
     */
    public function atualizarMeta(User $user, int $id, array $dados): FinancasMeta
    {
        $meta = FinancasMeta::query()
            ->where('user_id', $user->id)
            ->find($id);

        if (! $meta) {
            throw new NotFoundHttpException('Meta não encontrada.');
        }

        $meta->update(array_filter([
            'titulo' => $dados['titulo'] ?? null,
            'valor_atual_centavos' => $dados['valor_atual_centavos'] ?? null,
        ], fn ($v) => $v !== null));

        return $meta->fresh();
    }

    private function resolverMes(?string $anoMes): Carbon
    {
        if ($anoMes && preg_match('/^\d{4}-\d{2}$/', $anoMes)) {
            return Carbon::createFromFormat('Y-m-d', $anoMes.'-01', 'America/Sao_Paulo')->startOfMonth();
        }

        return now('America/Sao_Paulo')->startOfMonth();
    }

    private function labelMes(Carbon $mes): string
    {
        $nomes = [
            1 => 'Janeiro', 2 => 'Fevereiro', 3 => 'Março', 4 => 'Abril',
            5 => 'Maio', 6 => 'Junho', 7 => 'Julho', 8 => 'Agosto',
            9 => 'Setembro', 10 => 'Outubro', 11 => 'Novembro', 12 => 'Dezembro',
        ];

        return ($nomes[(int) $mes->month] ?? $mes->format('F')).' '.$mes->year;
    }

    /**
     * @return list<array{ano_mes: string, label: string, curto: string}>
     */
    private function mesesDisponiveis(User $user, Carbon $selecionado): array
    {
        $meses = collect();
        for ($i = 4; $i >= 0; $i--) {
            $m = $selecionado->copy()->subMonths($i);
            $meses->push($m);
        }

        // Inclui meses com dados fora da janela
        $comDados = FinancasTransacao::query()
            ->where('user_id', $user->id)
            ->selectRaw("DATE_FORMAT(data, '%Y-%m') as ano_mes")
            ->groupBy('ano_mes')
            ->pluck('ano_mes');

        foreach ($comDados as $am) {
            $m = Carbon::createFromFormat('Y-m-d', $am.'-01', 'America/Sao_Paulo')->startOfMonth();
            if (! $meses->contains(fn (Carbon $c) => $c->format('Y-m') === $m->format('Y-m'))) {
                $meses->push($m);
            }
        }

        return $meses
            ->unique(fn (Carbon $c) => $c->format('Y-m'))
            ->sortBy(fn (Carbon $c) => $c->format('Y-m'))
            ->values()
            ->map(function (Carbon $m) {
                $curtos = [1 => 'Jan', 2 => 'Fev', 3 => 'Mar', 4 => 'Abr', 5 => 'Mai', 6 => 'Jun', 7 => 'Jul', 8 => 'Ago', 9 => 'Set', 10 => 'Out', 11 => 'Nov', 12 => 'Dez'];

                return [
                    'ano_mes' => $m->format('Y-m'),
                    'label' => $this->labelMes($m),
                    'curto' => $curtos[(int) $m->month] ?? $m->format('M'),
                ];
            })
            ->all();
    }

    /**
     * @return list<array{ano_mes: string, curto: string, receita_centavos: int, gastos_centavos: int, saldo_centavos: int}>
     */
    private function serieMensal(User $user, Carbon $selecionado): array
    {
        $serie = [];
        for ($i = 4; $i >= 0; $i--) {
            $m = $selecionado->copy()->subMonths($i);
            $inicio = $m->copy()->startOfMonth()->toDateString();
            $fim = $m->copy()->endOfMonth()->toDateString();

            $txs = FinancasTransacao::query()
                ->where('user_id', $user->id)
                ->whereBetween('data', [$inicio, $fim])
                ->get();

            $receita = (int) $txs->where('tipo', 'receita')->sum('valor_centavos');
            $gastos = (int) $txs->where('tipo', 'despesa')->sum('valor_centavos');
            $curtos = [1 => 'Jan', 2 => 'Fev', 3 => 'Mar', 4 => 'Abr', 5 => 'Mai', 6 => 'Jun', 7 => 'Jul', 8 => 'Ago', 9 => 'Set', 10 => 'Out', 11 => 'Nov', 12 => 'Dez'];

            $serie[] = [
                'ano_mes' => $m->format('Y-m'),
                'curto' => $curtos[(int) $m->month] ?? $m->format('M'),
                'receita_centavos' => $receita,
                'gastos_centavos' => $gastos,
                'saldo_centavos' => $receita - $gastos,
            ];
        }

        return $serie;
    }

    /**
     * @param  Collection<int, FinancasTransacao>  $transacoesMes
     * @return list<array{categoria: string, nome: string, cor: string, valor_centavos: int, percentual: float}>
     */
    private function distribuicao(Collection $transacoesMes): array
    {
        $despesas = $transacoesMes->where('tipo', 'despesa');
        $total = max(1, (int) $despesas->sum('valor_centavos'));
        $porCategoria = $despesas->groupBy('categoria');
        $catalogo = FinancasCatalog::categoriasDespesa();
        $itens = [];

        foreach ($catalogo as $chave => $meta) {
            $valor = (int) ($porCategoria->get($chave)?->sum('valor_centavos') ?? 0);
            if ($valor <= 0) {
                continue;
            }
            $itens[] = [
                'categoria' => $chave,
                'nome' => $meta['nome'],
                'cor' => $meta['cor'],
                'valor_centavos' => $valor,
                'percentual' => round(($valor / $total) * 100, 1),
            ];
        }

        usort($itens, fn ($a, $b) => $b['valor_centavos'] <=> $a['valor_centavos']);

        return $itens;
    }

    private function categoriasPayload(): array
    {
        $despesas = [];
        foreach (FinancasCatalog::categoriasDespesa() as $chave => $meta) {
            $despesas[] = [
                'chave' => $chave,
                'nome' => $meta['nome'],
                'cor' => $meta['cor'],
                'icone' => $meta['icone'],
            ];
        }

        $receita = FinancasCatalog::categoriaReceita();

        return [
            'despesas' => $despesas,
            'receita' => [
                'chave' => 'receita',
                'nome' => $receita['nome'],
                'cor' => $receita['cor'],
                'icone' => $receita['icone'],
            ],
        ];
    }
}
