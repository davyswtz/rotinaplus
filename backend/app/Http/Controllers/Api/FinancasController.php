<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\FinancasMetaResource;
use App\Http\Resources\FinancasTransacaoResource;
use App\Services\FinancasService;
use App\Support\FinancasCatalog;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class FinancasController extends Controller
{
    public function __construct(
        private readonly FinancasService $financasService,
    ) {}

    public function show(Request $request): JsonResponse
    {
        $data = $this->financasService->resumo(
            $request->user(),
            $request->query('mes'),
        );

        return response()->json([
            'success' => true,
            'data' => [
                'ano_mes' => $data['ano_mes'],
                'mes_label' => $data['mes_label'],
                'meses' => $data['meses'],
                'saldo_centavos' => $data['saldo_centavos'],
                'receita_centavos' => $data['receita_centavos'],
                'gastos_centavos' => $data['gastos_centavos'],
                'serie_mensal' => $data['serie_mensal'],
                'distribuicao' => $data['distribuicao'],
                'recentes' => FinancasTransacaoResource::collection($data['recentes']),
                'transacoes' => FinancasTransacaoResource::collection($data['transacoes']),
                'metas' => FinancasMetaResource::collection($data['metas']),
                'categorias' => $data['categorias'],
            ],
        ]);
    }

    public function storeTransacao(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'tipo' => ['required', Rule::in(['receita', 'despesa'])],
            'categoria' => ['required', 'string', 'max:32'],
            'titulo' => ['required', 'string', 'min:2', 'max:80'],
            'icone' => ['nullable', 'string', 'max:16'],
            'valor_centavos' => ['required', 'integer', 'min:1'],
            'data' => ['required', 'date'],
        ]);

        if ($validated['tipo'] === 'despesa') {
            $request->validate([
                'categoria' => [Rule::in(FinancasCatalog::chavesDespesa())],
            ]);
        }

        $tx = $this->financasService->criarTransacao($request->user(), $validated);

        return response()->json([
            'success' => true,
            'message' => 'Transação criada.',
            'data' => new FinancasTransacaoResource($tx),
        ], 201);
    }

    public function destroyTransacao(Request $request, int $id): JsonResponse
    {
        $this->financasService->excluirTransacao($request->user(), $id);

        return response()->json([
            'success' => true,
            'message' => 'Transação removida.',
        ]);
    }

    public function storeMeta(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'titulo' => ['required', 'string', 'min:2', 'max:80'],
            'icone' => ['nullable', 'string', 'max:16'],
            'categoria' => ['nullable', 'string', 'max:32'],
            'valor_alvo_centavos' => ['required', 'integer', 'min:100'],
        ]);

        $meta = $this->financasService->criarMeta($request->user(), $validated);

        return response()->json([
            'success' => true,
            'message' => 'Meta criada.',
            'data' => new FinancasMetaResource($meta),
        ], 201);
    }

    public function updateMeta(Request $request, int $id): JsonResponse
    {
        $validated = $request->validate([
            'titulo' => ['sometimes', 'string', 'min:2', 'max:80'],
            'valor_atual_centavos' => ['sometimes', 'integer', 'min:0'],
        ]);

        $meta = $this->financasService->atualizarMeta($request->user(), $id, $validated);

        return response()->json([
            'success' => true,
            'message' => 'Meta atualizada.',
            'data' => new FinancasMetaResource($meta),
        ]);
    }
}
