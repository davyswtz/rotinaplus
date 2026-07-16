<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\NotificacaoResource;
use App\Services\NotificacaoService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificacaoController extends Controller
{
    public function __construct(
        private readonly NotificacaoService $notificacaoService,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $itens = $this->notificacaoService->list($request->user());

        return response()->json([
            'success' => true,
            'data' => NotificacaoResource::collection($itens),
        ]);
    }

    public function marcarLida(Request $request, int $id): JsonResponse
    {
        $item = $this->notificacaoService->marcarLida($request->user(), $id);

        return response()->json([
            'success' => true,
            'data' => new NotificacaoResource($item),
        ]);
    }

    public function lerTodas(Request $request): JsonResponse
    {
        $qtd = $this->notificacaoService->lerTodas($request->user());

        return response()->json([
            'success' => true,
            'message' => 'Notificações marcadas como lidas.',
            'data' => ['atualizadas' => $qtd],
        ]);
    }
}
