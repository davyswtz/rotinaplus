<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\HabitoCheckinResource;
use App\Http\Resources\HabitoResource;
use App\Services\HabitoService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class HabitoController extends Controller
{
    public function __construct(
        private readonly HabitoService $habitoService,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'data' => ['nullable', 'date'],
        ]);

        $journal = $this->habitoService->journal(
            $request->user(),
            $validated['data'] ?? null,
        );

        $itens = collect($journal['itens'])->map(fn (array $item) => [
            'habito' => (new HabitoResource($item['habito']))->resolve(),
            'checkin' => $item['checkin']
                ? (new HabitoCheckinResource($item['checkin']))->resolve()
                : null,
            'concluida' => $item['concluida'],
            'streak' => $item['streak'],
        ])->values();

        return response()->json([
            'success' => true,
            'data' => [
                'data' => $journal['data'],
                'hoje' => $journal['hoje'],
                'resumo' => $journal['resumo'],
                'semana' => $journal['semana'],
                'itens' => $itens,
                'sugestoes' => $journal['sugestoes'],
                'areas' => $journal['areas'],
            ],
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'titulo' => ['required', 'string', 'min:2', 'max:80'],
            'detalhe' => ['nullable', 'string', 'max:160'],
            'icone' => ['nullable', 'string', 'max:16'],
            'area' => ['nullable', 'string', 'max:32'],
            'frequencia' => ['nullable', 'in:diario,semanal'],
            'dias_semana' => ['nullable', 'array'],
            'dias_semana.*' => ['integer', 'min:1', 'max:7'],
        ]);

        $habito = $this->habitoService->criar($request->user(), $validated);

        return response()->json([
            'success' => true,
            'message' => 'Hábito criado.',
            'data' => new HabitoResource($habito),
        ], 201);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $validated = $request->validate([
            'titulo' => ['sometimes', 'string', 'min:2', 'max:80'],
            'detalhe' => ['nullable', 'string', 'max:160'],
            'icone' => ['nullable', 'string', 'max:16'],
            'area' => ['nullable', 'string', 'max:32'],
            'frequencia' => ['nullable', 'in:diario,semanal'],
            'dias_semana' => ['nullable', 'array'],
            'dias_semana.*' => ['integer', 'min:1', 'max:7'],
            'ativo' => ['sometimes', 'boolean'],
        ]);

        $habito = $this->habitoService->atualizar($request->user(), $id, $validated);

        return response()->json([
            'success' => true,
            'message' => 'Hábito atualizado.',
            'data' => new HabitoResource($habito),
        ]);
    }

    public function destroy(Request $request, int $id): JsonResponse
    {
        $this->habitoService->excluir($request->user(), $id);

        return response()->json([
            'success' => true,
            'message' => 'Hábito arquivado.',
        ]);
    }

    public function toggleCheckin(Request $request, int $id): JsonResponse
    {
        $validated = $request->validate([
            'data' => ['nullable', 'date'],
            'humor' => ['nullable', 'integer', 'min:1', 'max:5'],
            'nota' => ['nullable', 'string', 'max:1000'],
        ]);

        $result = $this->habitoService->toggleCheckin($request->user(), $id, $validated);

        return response()->json([
            'success' => true,
            'message' => $result['concluida'] ? 'Hábito marcado.' : 'Hábito desmarcado.',
            'data' => [
                'habito' => (new HabitoResource($result['habito']))->resolve(),
                'checkin' => (new HabitoCheckinResource($result['checkin']))->resolve(),
                'concluida' => $result['concluida'],
                'streak' => $result['streak'],
                'bonus_dia' => $result['bonus_dia'],
            ],
        ]);
    }

    public function atualizarNota(Request $request, int $id): JsonResponse
    {
        $validated = $request->validate([
            'data' => ['nullable', 'date'],
            'nota' => ['nullable', 'string', 'max:1000'],
            'humor' => ['nullable', 'integer', 'min:1', 'max:5'],
        ]);

        $checkin = $this->habitoService->atualizarNota($request->user(), $id, $validated);

        return response()->json([
            'success' => true,
            'message' => 'Diário atualizado.',
            'data' => new HabitoCheckinResource($checkin),
        ]);
    }
}
