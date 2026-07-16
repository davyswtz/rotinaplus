<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\MissaoResource;
use App\Http\Resources\PerfilResource;
use App\Services\DashboardService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function __construct(
        private readonly DashboardService $dashboardService,
    ) {}

    public function show(Request $request): JsonResponse
    {
        $data = $this->dashboardService->forUser($request->user());

        return response()->json([
            'success' => true,
            'data' => [
                'perfil' => new PerfilResource($data['perfil']),
                'missoes' => MissaoResource::collection($data['missoes']),
                'missoes_concluidas' => $data['missoes_concluidas'],
                'missoes_total' => $data['missoes_total'],
                'xp_hoje' => $data['xp_hoje'],
                'notificacoes_nao_lidas' => $data['notificacoes_nao_lidas'],
                'academia_resumo' => $data['academia_resumo'],
            ],
        ]);
    }
}
