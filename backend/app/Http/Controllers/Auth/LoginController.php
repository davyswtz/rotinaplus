<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class LoginController extends Controller
{
    public function login(LoginRequest $request)
    {
        $validated = $request->validated();
        $email = Str::lower(trim($validated['email']));
        $password = $validated['password'];

        $user = User::query()->where('email', $email)->first();

        if (
            ! $user
            || empty($user->getRawOriginal('password'))
            || ! Hash::check($password, $user->getAuthPassword())
        ) {
            throw ValidationException::withMessages([
                'email' => ['As credenciais fornecidas são inválidas.'],
            ]);
        }

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
