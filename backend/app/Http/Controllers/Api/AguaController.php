<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\AguaService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Controller responsável pelos endpoints do tracker de consumo de água.
 */
class AguaController extends Controller
{
    public function __construct(
        private readonly AguaService $aguaService,
    ) {}

    /**
     * Lista os registros de água do usuário em um período.
     */
    public function index(Request $request): JsonResponse
    {
        $filtros = $request->validate([
            'data_inicio' => ['required', 'date'],
            'data_fim' => ['required', 'date', 'after_or_equal:data_inicio'],
        ]);

        $registros = $this->aguaService->listarPorPeriodo(
            $request->user(),
            $filtros['data_inicio'],
            $filtros['data_fim'],
        );

        return response()->json($registros);
    }

    /**
     * Adiciona uma gota de água ao dia informado.
     */
    public function adicionar(Request $request): JsonResponse
    {
        $dados = $request->validate(['data' => ['required', 'date']]);

        $registro = $this->aguaService->adicionarGota($request->user(), $dados['data']);

        return response()->json($registro);
    }

    /**
     * Remove uma gota de água do dia informado.
     */
    public function remover(Request $request): JsonResponse
    {
        $dados = $request->validate(['data' => ['required', 'date']]);

        $registro = $this->aguaService->removerGota($request->user(), $dados['data']);

        return response()->json($registro);
    }
}
