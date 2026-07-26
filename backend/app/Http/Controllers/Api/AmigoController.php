<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\AmigoResource;
use App\Services\AmigoService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AmigoController extends Controller
{
    public function __construct(
        private readonly AmigoService $amigoService,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $amigos = $this->amigoService->listar($request->user());

        return response()->json([
            'success' => true,
            'data' => [
                'amigos' => AmigoResource::collection($amigos)->resolve(),
                'total' => $amigos->count(),
            ],
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'nick' => ['required', 'string', 'min:3', 'max:32'],
        ]);

        $amigo = $this->amigoService->adicionarPorNick($request->user(), $validated['nick']);

        return response()->json([
            'success' => true,
            'message' => 'Amigo adicionado.',
            'data' => new AmigoResource($amigo),
        ], 201);
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $this->amigoService->remover($request->user(), $id);

        return response()->json([
            'success' => true,
            'message' => 'Amigo removido.',
        ]);
    }
}
