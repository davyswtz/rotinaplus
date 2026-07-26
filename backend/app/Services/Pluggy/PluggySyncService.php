<?php

namespace App\Services\Pluggy;

use App\Models\FinancasConexao;
use App\Models\FinancasTransacao;
use App\Models\User;
use App\Support\FinancasCatalog;
use Carbon\Carbon;
use Illuminate\Support\Str;
use RuntimeException;

class PluggySyncService
{
    public function __construct(
        private readonly PluggyClient $client,
    ) {}

    public function status(User $user): array
    {
        $conexoes = FinancasConexao::query()
            ->where('user_id', $user->id)
            ->orderByDesc('id')
            ->get()
            ->map(fn (FinancasConexao $c) => [
                'id' => $c->id,
                'provider' => $c->provider,
                'item_id' => $c->item_id,
                'connector_name' => $c->connector_name,
                'status' => $c->status,
                'last_sync_at' => $c->last_sync_at?->toIso8601String(),
            ])
            ->values()
            ->all();

        return [
            'configured' => $this->client->isConfigured(),
            'local_sandbox' => false,
            'conexoes' => $conexoes,
        ];
    }

    public function createConnectToken(User $user): array
    {
        if (! $this->client->isConfigured()) {
            throw new RuntimeException(
                'Pluggy não configurado. Crie conta em https://dashboard.pluggy.ai e defina PLUGGY_CLIENT_ID / PLUGGY_CLIENT_SECRET.'
            );
        }

        $token = $this->client->createConnectToken('rotina-user-'.$user->id);

        return [
            'mode' => 'pluggy',
            'access_token' => $token,
            'include_sandbox' => false,
        ];
    }

    /**
     * @return array{conexao: FinancasConexao, importadas: int, atualizadas: int}
     */
    public function vincularESincronizar(User $user, string $itemId): array
    {
        if ($itemId === 'local-sandbox' || str_starts_with($itemId, 'local-')) {
            throw new RuntimeException('Sandbox local foi removido.');
        }

        if (! $this->client->isConfigured()) {
            throw new RuntimeException('Pluggy não configurado.');
        }

        $item = $this->client->getItem($itemId);
        $connector = $item['connector'] ?? [];

        $conexao = FinancasConexao::query()->updateOrCreate(
            [
                'user_id' => $user->id,
                'provider' => 'pluggy',
                'item_id' => $itemId,
            ],
            [
                'connector_id' => $connector['id'] ?? null,
                'connector_name' => $connector['name'] ?? 'Banco',
                'status' => $item['status'] ?? 'UPDATED',
            ],
        );

        return $this->sincronizarConexao($user, $conexao);
    }

    /**
     * @return array{conexao: FinancasConexao, importadas: int, atualizadas: int}
     */
    public function sincronizar(User $user, ?int $conexaoId = null): array
    {
        $query = FinancasConexao::query()->where('user_id', $user->id);
        if ($conexaoId) {
            $query->where('id', $conexaoId);
        }

        $conexao = $query->orderByDesc('id')->first();
        if (! $conexao) {
            throw new RuntimeException('Nenhuma conexão bancária encontrada.');
        }

        if ($conexao->item_id === 'local-sandbox' || str_starts_with((string) $conexao->item_id, 'local-')) {
            throw new RuntimeException('Sandbox local foi removido. Remova a conexão antiga e use a Pluggy real.');
        }

        return $this->sincronizarConexao($user, $conexao);
    }

    /**
     * @return array{conexao: FinancasConexao, importadas: int, atualizadas: int}
     */
    private function sincronizarConexao(User $user, FinancasConexao $conexao): array
    {
        $from = now('America/Sao_Paulo')->subMonths(3)->toDateString();
        $to = now('America/Sao_Paulo')->toDateString();
        $txs = $this->client->listTransactions((string) $conexao->item_id, $from, $to);

        $importadas = 0;
        $atualizadas = 0;

        foreach ($txs as $tx) {
            $mapped = $this->mapearTransacao($tx);
            if (! $mapped) {
                continue;
            }

            $externalId = (string) ($tx['id'] ?? '');
            if ($externalId === '') {
                continue;
            }

            $existing = FinancasTransacao::query()
                ->where('user_id', $user->id)
                ->where('origem', 'pluggy')
                ->where('external_id', $externalId)
                ->first();

            $payload = [
                ...$mapped,
                'origem' => 'pluggy',
                'external_id' => $externalId,
                'conexao_id' => $conexao->id,
            ];

            if ($existing) {
                $existing->update($payload);
                $atualizadas++;
            } else {
                FinancasTransacao::query()->create([
                    'user_id' => $user->id,
                    ...$payload,
                ]);
                $importadas++;
            }
        }

        $conexao->update([
            'last_sync_at' => now(),
            'status' => 'UPDATED',
        ]);

        return compact('conexao', 'importadas', 'atualizadas');
    }

    /**
     * @param  array<string, mixed>  $tx
     * @return array{tipo: string, categoria: string, titulo: string, icone: string, valor_centavos: int, data: string}|null
     */
    private function mapearTransacao(array $tx): ?array
    {
        $amount = (float) ($tx['amount'] ?? 0);
        if ($amount == 0.0) {
            return null;
        }

        $tipo = $amount > 0 ? 'receita' : 'despesa';
        $valorCentavos = (int) round(abs($amount) * 100);
        $titulo = trim((string) ($tx['description'] ?? $tx['descriptionRaw'] ?? 'Transação'));
        if ($titulo === '') {
            $titulo = 'Transação bancária';
        }

        $categoriaPluggy = strtolower((string) (
            $tx['category']
            ?? $tx['categoryId']
            ?? ''
        ));

        $categoria = $tipo === 'receita'
            ? 'receita'
            : $this->mapearCategoriaDespesa($categoriaPluggy, $titulo);

        $catalogo = $tipo === 'receita'
            ? FinancasCatalog::categoriaReceita()
            : (FinancasCatalog::categoriasDespesa()[$categoria] ?? FinancasCatalog::categoriasDespesa()['outros']);

        $data = $tx['date'] ?? $tx['postedDate'] ?? null;
        if (! $data) {
            return null;
        }

        $dataStr = Carbon::parse($data, 'America/Sao_Paulo')->toDateString();

        return [
            'tipo' => $tipo,
            'categoria' => $categoria,
            'titulo' => Str::limit($titulo, 80, ''),
            'icone' => $catalogo['icone'],
            'valor_centavos' => $valorCentavos,
            'data' => $dataStr,
        ];
    }

    private function mapearCategoriaDespesa(string $categoriaPluggy, string $titulo): string
    {
        $hay = $categoriaPluggy.' '.mb_strtolower($titulo);

        $mapa = [
            'moradia' => ['rent', 'aluguel', 'housing', 'condominio', 'energia', 'água', 'agua'],
            'alimentacao' => ['food', 'mercado', 'restaurant', 'supermercado', 'ifood', 'alimentação', 'alimentacao'],
            'transporte' => ['transport', 'uber', '99', 'combustivel', 'gasolina', 'parking'],
            'lazer' => ['leisure', 'entertainment', 'streaming', 'netflix', 'spotify', 'lazer'],
            'saude' => ['health', 'farmacia', 'farmácia', 'medico', 'saúde', 'saude'],
            'educacao' => ['education', 'curso', 'escola', 'faculdade', 'educação', 'educacao'],
        ];

        foreach ($mapa as $chave => $termos) {
            foreach ($termos as $termo) {
                if (str_contains($hay, $termo)) {
                    return $chave;
                }
            }
        }

        return 'outros';
    }
}
