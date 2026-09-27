<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\HumorService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Controller responsável pelos endpoints do tracker de humor diário.
 */
class HumorController extends Controller
{
    /** Valores de humor aceitos pelo sistema. */
    private const OPCOES_HUMOR = ['muito_feliz', 'feliz', 'neutro', 'triste', 'muito_triste'];

    public function __construct(
        private readonly HumorService $humorService,
    ) {}

    /**
     * Lista os registros de humor do usuário em um período.
     */
    public function index(Request $request): JsonResponse
    {
        $filtros = $request->validate([
            'data_inicio' => ['required', 'date'],
            'data_fim' => ['required', 'date', 'after_or_equal:data_inicio'],
        ]);

        $registros = $this->humorService->listarPorPeriodo(
            $request->user(),
            $filtros['data_inicio'],
            $filtros['data_fim'],
        );

        return response()->json($registros);
    }

    /**
     * Define o humor do usuário em um dia específico.
     */
    public function definir(Request $request): JsonResponse
    {
        $dados = $request->validate([
            'data' => ['required', 'date'],
            'humor' => ['required', 'string', 'in:'.implode(',', self::OPCOES_HUMOR)],
        ]);

        $registro = $this->humorService->definirHumorDoDia(
            $request->user(),
            $dados['data'],
            $dados['humor'],
        );

        return response()->json($registro);
    }
}
