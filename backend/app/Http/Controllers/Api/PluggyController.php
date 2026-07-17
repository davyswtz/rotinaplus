<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\FinancasConexaoResource;
use App\Services\Pluggy\PluggySyncService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use RuntimeException;

class PluggyController extends Controller
{
    public function __construct(
        private readonly PluggySyncService $pluggySync,
    ) {}

    public function status(Request $request): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => $this->pluggySync->status($request->user()),
        ]);
    }

    public function connectToken(Request $request): JsonResponse
    {
        try {
            $data = $this->pluggySync->createConnectToken($request->user());
        } catch (RuntimeException $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 422);
        }

        return response()->json([
            'success' => true,
            'data' => $data,
        ]);
    }

    public function vincular(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'item_id' => ['required', 'string', 'max:120'],
        ]);

        try {
            $result = $this->pluggySync->vincularESincronizar(
                $request->user(),
                $validated['item_id'],
            );
        } catch (RuntimeException $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 422);
        }

        return response()->json([
            'success' => true,
            'message' => sprintf(
                'Sincronizado: %d novas, %d atualizadas.',
                $result['importadas'],
                $result['atualizadas'],
            ),
            'data' => [
                'conexao' => new FinancasConexaoResource($result['conexao']),
                'importadas' => $result['importadas'],
                'atualizadas' => $result['atualizadas'],
            ],
        ]);
    }

    public function sincronizar(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'conexao_id' => ['nullable', 'integer'],
        ]);

        try {
            $result = $this->pluggySync->sincronizar(
                $request->user(),
                $validated['conexao_id'] ?? null,
            );
        } catch (RuntimeException $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
            ], 422);
        }

        return response()->json([
            'success' => true,
            'message' => sprintf(
                'Sincronizado: %d novas, %d atualizadas.',
                $result['importadas'],
                $result['atualizadas'],
            ),
            'data' => [
                'conexao' => new FinancasConexaoResource($result['conexao']),
                'importadas' => $result['importadas'],
                'atualizadas' => $result['atualizadas'],
            ],
        ]);
    }
}
