<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\PerfilResource;
use App\Services\AcademiaService;
use App\Services\PerfilStatsService;
use App\Support\ClassesCatalog;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class PerfilController extends Controller
{
    public function __construct(
        private readonly AcademiaService $academiaService,
        private readonly PerfilStatsService $perfilStatsService,
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

    public function stats(Request $request): JsonResponse
    {
        $periodo = $request->query('periodo', 'semana');
        if (! in_array($periodo, ['semana', 'mes'], true)) {
            $periodo = 'semana';
        }

        $data = $this->perfilStatsService->forUser($request->user(), $periodo);

        return response()->json([
            'success' => true,
            'data' => [
                'periodo' => $data['periodo'],
                'inicio' => $data['inicio'],
                'fim' => $data['fim'],
                'perfil' => new PerfilResource($data['perfil']),
                'totais' => $data['totais'],
                'serie' => $data['serie'],
                'por_area' => $data['por_area'],
                'nivel' => $data['nivel'],
            ],
        ]);
    }

    public function update(Request $request): JsonResponse
    {
        $user = $request->user();
        $user->ensureDefaults();

        $validated = $request->validate([
            'nome_heroi' => ['sometimes', 'string', 'max:40'],
            'avatar_key' => ['sometimes', 'string', 'max:64'],
            'classe' => ['sometimes', 'string', 'max:40', Rule::in(ClassesCatalog::nomes())],
            'emoji_classe' => ['sometimes', 'string', 'max:16'],
        ]);

        if (isset($validated['classe']) && ! isset($validated['emoji_classe'])) {
            $catalogo = ClassesCatalog::findByNome($validated['classe']);
            if ($catalogo) {
                $validated['emoji_classe'] = $catalogo['emoji'];
            }
        }

        $perfil = $this->academiaService->updatePerfil($user, $validated);

        return response()->json([
            'success' => true,
            'message' => 'Perfil atualizado.',
            'data' => new PerfilResource($perfil),
        ]);
    }
}
