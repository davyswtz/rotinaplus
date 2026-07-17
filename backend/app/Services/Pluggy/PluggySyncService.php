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
            'local_sandbox' => (bool) config('services.pluggy.local_sandbox'),
            'conexoes' => $conexoes,
        ];
    }

    public function createConnectToken(User $user): array
    {
        if (! $this->client->isConfigured()) {
            if (config('services.pluggy.local_sandbox')) {
                return [
                    'mode' => 'local',
                    'access_token' => 'local-sandbox',
                    'include_sandbox' => true,
                ];
            }

            throw new RuntimeException(
                'Pluggy não configurado. Crie conta em https://dashboard.pluggy.ai e defina PLUGGY_CLIENT_ID / PLUGGY_CLIENT_SECRET.'
            );
        }

        $token = $this->client->createConnectToken('rotina-user-'.$user->id);

        return [
            'mode' => 'pluggy',
            'access_token' => $token,
            'include_sandbox' => true,
        ];
    }

    /**
     * @return array{conexao: FinancasConexao, importadas: int, atualizadas: int}
     */
    public function vincularESincronizar(User $user, string $itemId): array
    {
        if ($itemId === 'local-sandbox' || str_starts_with($itemId, 'local-')) {
            return $this->sincronizarLocal($user);
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
            throw new RuntimeException('Nenhuma conexão bancária encontrada. Conecte o sandbox primeiro.');
        }

        if ($conexao->item_id === 'local-sandbox' || str_starts_with((string) $conexao->item_id, 'local-')) {
            return $this->sincronizarLocal($user, $conexao);
        }

        return $this->sincronizarConexao($user, $conexao);
    }

    /**
     * Sandbox local: gera transações de exemplo sem chave Pluggy (só APP_ENV local).
     *
     * @return array{conexao: FinancasConexao, importadas: int, atualizadas: int}
     */
    public function sincronizarLocal(User $user, ?FinancasConexao $conexao = null): array
    {
        if (! config('services.pluggy.local_sandbox')) {
            throw new RuntimeException('Sandbox local desabilitado. Configure as chaves Pluggy.');
        }

        $conexao ??= FinancasConexao::query()->updateOrCreate(
            [
                'user_id' => $user->id,
                'provider' => 'pluggy',
                'item_id' => 'local-sandbox',
            ],
            [
                'connector_id' => 0,
                'connector_name' => 'Sandbox Local (Pluggy-like)',
                'status' => 'UPDATED',
            ],
        );

        $hoje = now('America/Sao_Paulo');
        $samples = [
            ['tipo' => 'receita', 'categoria' => 'receita', 'titulo' => 'Salário Sandbox', 'icone' => '💼', 'valor' => 540000, 'dias' => 12],
            ['tipo' => 'receita', 'categoria' => 'receita', 'titulo' => 'PIX recebido', 'icone' => '💸', 'valor' => 15000, 'dias' => 5],
            ['tipo' => 'despesa', 'categoria' => 'moradia', 'titulo' => 'Aluguel', 'icone' => '🏠', 'valor' => 120000, 'dias' => 10],
            ['tipo' => 'despesa', 'categoria' => 'alimentacao', 'titulo' => 'Mercado', 'icone' => '🛒', 'valor' => 32750, 'dias' => 3],
            ['tipo' => 'despesa', 'categoria' => 'transporte', 'titulo' => 'Uber', 'icone' => '🚌', 'valor' => 2890, 'dias' => 2],
            ['tipo' => 'despesa', 'categoria' => 'lazer', 'titulo' => 'Streaming', 'icone' => '🎮', 'valor' => 5590, 'dias' => 8],
            ['tipo' => 'despesa', 'categoria' => 'saude', 'titulo' => 'Farmácia', 'icone' => '💊', 'valor' => 6740, 'dias' => 1],
        ];

        $importadas = 0;
        $atualizadas = 0;

        foreach ($samples as $i => $sample) {
            $externalId = 'local-sandbox-'.$i;
            $data = $hoje->copy()->subDays($sample['dias'])->toDateString();
            $existing = FinancasTransacao::query()
                ->where('user_id', $user->id)
                ->where('origem', 'pluggy')
                ->where('external_id', $externalId)
                ->first();

            $payload = [
                'tipo' => $sample['tipo'],
                'categoria' => $sample['categoria'],
                'titulo' => $sample['titulo'],
                'icone' => $sample['icone'],
                'valor_centavos' => $sample['valor'],
                'data' => $data,
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

        $conexao->update(['last_sync_at' => now(), 'status' => 'UPDATED']);

        return compact('conexao', 'importadas', 'atualizadas');
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
