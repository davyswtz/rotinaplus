<?php

namespace App\Services\Auth;

use Illuminate\Support\Facades\Http;
use Exception;

class GoogleTokenVerifier
{
    public function verify(string $idToken): array
    {
        $response = Http::get('https://oauth2.googleapis.com/tokeninfo', [
            'id_token' => $idToken,
        ]);

        if (! $response->successful()) {
            throw new Exception('Token do Google inválido.');
        }

        $payload = $response->json();

        if ($payload['aud'] !== config('services.google.client_id')) {
            throw new Exception('Audience inválido no token do Google.');
        }

        return [
            'provider_id' => $payload['sub'],
            'email' => $payload['email'] ?? null,
        ];
    }
}