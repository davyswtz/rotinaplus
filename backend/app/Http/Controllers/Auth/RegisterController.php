<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\RegisterRequest;
use App\Models\User;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class RegisterController extends Controller
{
    public function register(RegisterRequest $request)
    {
        $validated = $request->validated();

        $email = Str::lower(trim($validated['email']));
        $password = $validated['password'];

        $user = User::query()->create([
            'name' => trim($validated['name']),
            'email' => $email,
            // Cast `hashed` no model garante o bcrypt.
            'password' => $password,
        ]);

        // Confirma persistência verificável da senha.
        $user->refresh();
        if (
            empty($user->getRawOriginal('password'))
            || ! Hash::check($password, $user->getAuthPassword())
        ) {
            $user->forceFill([
                'password' => Hash::make($password),
            ])->save();
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
        ], 201);
    }
}
