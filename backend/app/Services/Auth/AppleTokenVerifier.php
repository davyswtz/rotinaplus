<?php

namespace App\Services\Auth;

use Firebase\JWT\JWT;
use Firebase\JWT\JWK;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Cache;
use Exception;

class AppleTokenVerifier
{
    public function verify(string $identityToken): array
    {
        $keys = Cache::remember('apple_public_keys', now()->addHours(6), function () {
            return Http::get('https://appleid.apple.com/auth/keys')->json();
        });

        $parsedKeys = JWK::parseKeySet($keys);

        $decoded = JWT::decode($identityToken, $parsedKeys);

        if ($decoded->iss !== 'https://appleid.apple.com') {
            throw new Exception('Issuer inválido no token da Apple.');
        }

        if ($decoded->aud !== config('services.apple.client_id')) {
            throw new Exception('Audience inválido no token da Apple.');
        }

        return [
            'provider_id' => $decoded->sub,
            'email' => $decoded->email ?? null,
        ];
    }
}