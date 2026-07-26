<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\AmigoResource;
use App\Http\Resources\PerfilResource;
use App\Services\AmigoService;
use App\Services\PerfilStatsService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AmigoController extends Controller
{
    public function __construct(
        private readonly AmigoService $amigoService,
        private readonly PerfilStatsService $perfilStatsService,
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

    public function stats(Request $request, int $id): JsonResponse
    {
        $periodo = $request->query('periodo', 'semana');
        if (! in_array($periodo, ['semana', 'mes'], true)) {
            $periodo = 'semana';
        }

        $amigo = $this->amigoService->obterAmigoAceito($request->user(), $id);
        $data = $this->perfilStatsService->forUser($amigo, $periodo);

        return response()->json([
            'success' => true,
            'data' => [
                'amigo' => new AmigoResource($amigo),
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

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'codigo' => ['required_without:codigo_amigo', 'string', 'min:6', 'max:12'],
            'codigo_amigo' => ['required_without:codigo', 'string', 'min:6', 'max:12'],
        ]);

        $codigo = $validated['codigo'] ?? $validated['codigo_amigo'];
        $resultado = $this->amigoService->convidarPorCodigo($request->user(), $codigo);

        return response()->json([
            'success' => true,
            'message' => 'Solicitação enviada.',
            'data' => [
                'amizade_id' => $resultado['amizade']->id,
                'status' => $resultado['amizade']->status,
            ],
        ], 201);
    }

    public function aceitar(Request $request, int $id): JsonResponse
    {
        $amizade = $this->amigoService->aceitar($request->user(), $id);
        $amigo = $amizade->user_id === $request->user()->id
            ? $amizade->amigo()->with('perfil')->first()
            : $amizade->user()->with('perfil')->first();

        return response()->json([
            'success' => true,
            'message' => 'Amizade aceita.',
            'data' => $amigo ? new AmigoResource($amigo) : null,
        ]);
    }

    public function recusar(Request $request, int $id): JsonResponse
    {
        $this->amigoService->recusar($request->user(), $id);

        return response()->json([
            'success' => true,
            'message' => 'Solicitação recusada.',
        ]);
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
