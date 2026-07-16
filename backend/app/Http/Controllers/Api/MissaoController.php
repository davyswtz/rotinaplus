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

    public function toggle(Request $request, int $id): JsonResponse
    {
        $missao = $this->missaoService->toggle($request->user(), $id);

        return response()->json([
            'success' => true,
            'message' => $missao->concluida ? 'Missão concluída.' : 'Missão reaberta.',
            'data' => new MissaoResource($missao),
        ]);
    }
}
