<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\PerfilResource;
use App\Services\AcademiaService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PerfilController extends Controller
{
    public function __construct(
        private readonly AcademiaService $academiaService,
    ) {}

    public function show(Request $request): JsonResponse
    {
        $user = $request->user();
        $user->ensureDefaults();

        return response()->json([
            'success' => true,
            'data' => [
                'user' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                ],
                'perfil' => new PerfilResource($user->perfil),
            ],
        ]);
    }

    public function update(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'nome_heroi' => ['sometimes', 'string', 'max:40'],
            'avatar_key' => ['sometimes', 'string', 'max:64'],
            'classe' => ['sometimes', 'string', 'max:40'],
            'emoji_classe' => ['sometimes', 'string', 'max:16'],
        ]);

        $perfil = $this->academiaService->updatePerfil($request->user(), $validated);

        return response()->json([
            'success' => true,
            'message' => 'Perfil atualizado.',
            'data' => new PerfilResource($perfil),
        ]);
    }
}
