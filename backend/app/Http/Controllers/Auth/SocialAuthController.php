<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\OauthProvider;
use App\Services\Auth\AppleTokenVerifier;
use App\Services\Auth\GoogleTokenVerifier;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class SocialAuthController extends Controller
{
    public function login(Request $request, AppleTokenVerifier $apple, GoogleTokenVerifier $google)
    {
        $validated = $request->validate([
            'provider' => 'required|in:apple,google',
            'token' => 'required|string',
            'name' => 'nullable|string',
        ]);

        try {
            $result = match ($validated['provider']) {
                'apple' => $apple->verify($validated['token']),
                'google' => $google->verify($validated['token']),
            };
        } catch (\Exception $e) {
            throw ValidationException::withMessages([
                'token' => 'Token inválido ou expirado.',
            ]);
        }

        $user = DB::transaction(function () use ($validated, $result) {
            $oauthProvider = OauthProvider::where('provider', $validated['provider'])
                ->where('provider_id', $result['provider_id'])
                ->first();

            if ($oauthProvider) {
                return $oauthProvider->user;
            }

            $user = User::firstOrCreate(
                ['email' => $result['email']],
                [
                    'name' => $validated['name'] ?? explode('@', $result['email'])[0],
                    'password' => null,
                    'email_verified_at' => now(),
                ]
            );

            $user->oauthProviders()->create([
                'provider' => $validated['provider'],
                'provider_id' => $result['provider_id'],
            ]);

            return $user;
        });

        $user->update(['last_login_at' => now()]);
        $user->ensureDefaults();
        $user->load('perfil');

        $token = $user->createToken('mobile-app')->plainTextToken;

        return response()->json([
            'success' => true,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
            ],
            'perfil' => $user->perfil,
            'token' => $token,
        ]);
    }
}