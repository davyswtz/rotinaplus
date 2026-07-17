<?php

namespace App\Services\Pluggy;

use Illuminate\Http\Client\PendingRequest;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use RuntimeException;

class PluggyClient
{
    private const BASE = 'https://api.pluggy.ai';

    public function isConfigured(): bool
    {
        return filled(config('services.pluggy.client_id'))
            && filled(config('services.pluggy.client_secret'));
    }

    public function createConnectToken(string $clientUserId): string
    {
        $response = $this->httpWithApiKey()->post('/connect_token', [
            'options' => [
                'clientUserId' => $clientUserId,
                'avoidDuplicates' => true,
            ],
        ]);

        if (! $response->successful()) {
            throw new RuntimeException('Falha ao criar connect token Pluggy: '.$response->body());
        }

        $token = $response->json('accessToken');
        if (! is_string($token) || $token === '') {
            throw new RuntimeException('Connect token Pluggy vazio.');
        }

        return $token;
    }

    public function getItem(string $itemId): array
    {
        $response = $this->httpWithApiKey()->get('/items/'.$itemId);

        if (! $response->successful()) {
            throw new RuntimeException('Falha ao buscar item Pluggy: '.$response->body());
        }

        return $response->json();
    }

    /**
     * @return list<array<string, mixed>>
     */
    public function listTransactions(string $itemId, ?string $from = null, ?string $to = null): array
    {
        $page = 1;
        $all = [];

        do {
            $query = [
                'itemId' => $itemId,
                'page' => $page,
                'pageSize' => 100,
            ];
            if ($from) {
                $query['from'] = $from;
            }
            if ($to) {
                $query['to'] = $to;
            }

            $response = $this->httpWithApiKey()->get('/transactions', $query);
            if (! $response->successful()) {
                throw new RuntimeException('Falha ao listar transações Pluggy: '.$response->body());
            }

            $results = $response->json('results') ?? [];
            $all = array_merge($all, $results);
            $totalPages = (int) ($response->json('totalPages') ?? 1);
            $page++;
        } while ($page <= $totalPages && $page <= 20);

        return $all;
    }

    private function httpWithApiKey(): PendingRequest
    {
        return Http::baseUrl(self::BASE)
            ->acceptJson()
            ->withHeaders([
                'X-API-KEY' => $this->apiKey(),
                'Content-Type' => 'application/json',
            ])
            ->timeout(30);
    }

    private function apiKey(): string
    {
        if (! $this->isConfigured()) {
            throw new RuntimeException('Pluggy não configurado. Defina PLUGGY_CLIENT_ID e PLUGGY_CLIENT_SECRET.');
        }

        return Cache::remember('pluggy_api_key', 90 * 60, function () {
            $response = Http::baseUrl(self::BASE)
                ->acceptJson()
                ->post('/auth', [
                    'clientId' => config('services.pluggy.client_id'),
                    'clientSecret' => config('services.pluggy.client_secret'),
                ]);

            if (! $response->successful()) {
                throw new RuntimeException('Falha ao autenticar na Pluggy: '.$response->body());
            }

            $key = $response->json('apiKey');
            if (! is_string($key) || $key === '') {
                throw new RuntimeException('API key Pluggy vazia.');
            }

            return $key;
        });
    }
}
