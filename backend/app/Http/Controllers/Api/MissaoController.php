<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\MissaoResource;
use App\Services\MissaoService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MissaoController extends Controller
{
    public function __construct(
        private readonly MissaoService $missaoService,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $missoes = $this->missaoService->listHoje($request->user());

        return response()->json([
            'success' => true,
            'data' => MissaoResource::collection($missoes),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'titulo' => ['required', 'string', 'min:2', 'max:80'],
            'detalhe' => ['nullable', 'string', 'max:160'],
            'icone' => ['nullable', 'string', 'max:16'],
            'client_uuid' => ['nullable', 'uuid'],
        ]);

        $missao = $this->missaoService->criarHoje($request->user(), $validated);

        return response()->json([
            'success' => true,
            'message' => 'Missão criada.',
            'data' => new MissaoResource($missao),
        ], 201);
    }

    public function toggle(Request $request, int $id): JsonResponse
    {
        $validated = $request->validate([
            'concluida' => ['sometimes', 'boolean'],
        ]);

        $missao = $this->missaoService->toggle(
            $request->user(),
            $id,
            array_key_exists('concluida', $validated) ? (bool) $validated['concluida'] : null,
        );

        return response()->json([
            'success' => true,
            'message' => $missao->concluida ? 'Missão concluída.' : 'Missão reaberta.',
            'data' => new MissaoResource($missao),
        ]);
    }
}
