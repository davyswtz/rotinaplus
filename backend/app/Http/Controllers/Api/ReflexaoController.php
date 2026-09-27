<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\ReflexaoService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Controller responsável pelos endpoints de reflexão semanal.
 */
class ReflexaoController extends Controller
{
    public function __construct(
        private readonly ReflexaoService $reflexaoService,
    ) {}

    /**
     * Retorna a reflexão da semana informada (parâmetro de query "semana_inicio").
     */
    public function mostrar(Request $request): JsonResponse
    {
        $filtros = $request->validate([
            'semana_inicio' => ['required', 'date'],
        ]);

        $reflexao = $this->reflexaoService->buscarPorSemana($request->user(), $filtros['semana_inicio']);

        return response()->json($reflexao);
    }

    /**
     * Salva (cria ou atualiza) o texto de reflexão de uma semana.
     */
    public function salvar(Request $request): JsonResponse
    {
        $dados = $request->validate([
            'semana_inicio' => ['required', 'date'],
            'texto' => ['nullable', 'string'],
        ]);

        $reflexao = $this->reflexaoService->salvar(
            $request->user(),
            $dados['semana_inicio'],
            $dados['texto'] ?? '',
        );

        return response()->json($reflexao);
    }
}
