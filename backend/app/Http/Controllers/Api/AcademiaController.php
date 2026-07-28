<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\AcademiaResource;
use App\Services\AcademiaService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AcademiaController extends Controller
{
    public function __construct(
        private readonly AcademiaService $academiaService,
    ) {}

    public function show(Request $request): JsonResponse
    {
        $data = $this->academiaService->show($request->user());

        return response()->json([
            'success' => true,
            'data' => new AcademiaResource($data),
        ]);
    }

    public function catalogoExercicios(Request $request): JsonResponse
    {
        $grupo = $request->query('grupo');
        $data = $this->academiaService->catalogoExercicios(
            is_string($grupo) ? $grupo : null
        );

        return response()->json([
            'success' => true,
            'data' => $data,
        ]);
    }

    public function storeTreino(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'foco' => ['required', 'string', 'max:64'],
            'titulo' => ['nullable', 'string', 'max:120'],
            'minutos' => ['nullable', 'integer', 'min:10', 'max:180'],
            'exercicios' => ['required', 'array', 'min:1'],
            'exercicios.*.exercicio_chave' => ['nullable', 'string', 'max:64'],
            'exercicios.*.nome' => ['nullable', 'string', 'max:120'],
            'exercicios.*.series' => ['nullable', 'integer', 'min:1', 'max:10'],
            'exercicios.*.reps' => ['nullable', 'integer', 'min:1', 'max:100'],
            'exercicios.*.carga_kg' => ['nullable', 'integer', 'min:0', 'max:500'],
        ]);

        $treino = $this->academiaService->criarTreino($request->user(), $validated);

        return response()->json([
            'success' => true,
            'message' => 'Treino criado.',
            'data' => AcademiaResource::treinoPayload($treino),
        ], 201);
    }

    public function updateTreino(Request $request, int $id): JsonResponse
    {
        $validated = $request->validate([
            'foco' => ['sometimes', 'string', 'max:64'],
            'titulo' => ['nullable', 'string', 'max:120'],
            'minutos' => ['nullable', 'integer', 'min:10', 'max:180'],
            'exercicios' => ['sometimes', 'array', 'min:1'],
            'exercicios.*.exercicio_chave' => ['nullable', 'string', 'max:64'],
            'exercicios.*.nome' => ['nullable', 'string', 'max:120'],
            'exercicios.*.series' => ['nullable', 'integer', 'min:1', 'max:10'],
            'exercicios.*.reps' => ['nullable', 'integer', 'min:1', 'max:100'],
            'exercicios.*.carga_kg' => ['nullable', 'integer', 'min:0', 'max:500'],
        ]);

        $treino = $this->academiaService->atualizarTreino($request->user(), $id, $validated);

        return response()->json([
            'success' => true,
            'message' => 'Treino atualizado.',
            'data' => AcademiaResource::treinoPayload($treino),
        ]);
    }

    public function showTreino(Request $request, int $id): JsonResponse
    {
        $treino = $this->academiaService->detalheTreino($request->user(), $id);

        return response()->json([
            'success' => true,
            'data' => AcademiaResource::treinoPayload($treino),
        ]);
    }

    public function historico(Request $request): JsonResponse
    {
        $lista = $this->academiaService->historico($request->user());

        return response()->json([
            'success' => true,
            'data' => collect($lista)->map(fn ($t) => AcademiaResource::treinoPayload($t))->values(),
        ]);
    }

    public function toggleExercicio(Request $request, int $id, int $exercicioId): JsonResponse
    {
        $validated = $request->validate([
            'concluido' => ['sometimes', 'boolean'],
        ]);

        $item = $this->academiaService->toggleExercicio(
            $request->user(),
            $id,
            $exercicioId,
            array_key_exists('concluido', $validated) ? (bool) $validated['concluido'] : null,
        );

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $item->id,
                'concluido' => $item->concluido,
            ],
        ]);
    }

    public function concluirTreino(Request $request, int $id): JsonResponse
    {
        $treino = $this->academiaService->concluirTreino($request->user(), $id);

        return response()->json([
            'success' => true,
            'message' => 'Treino concluído! +'.$treino->xp.' XP',
            'data' => AcademiaResource::treinoPayload($treino),
        ]);
    }

    public function destroyTreino(Request $request, int $id): JsonResponse
    {
        $this->academiaService->excluirTreino($request->user(), $id);

        return response()->json([
            'success' => true,
            'message' => 'Treino removido.',
        ]);
    }

    public function toggleDia(Request $request, int $id): JsonResponse
    {
        $validated = $request->validate([
            'concluido' => ['sometimes', 'boolean'],
        ]);

        $dia = $this->academiaService->toggleDia(
            $request->user(),
            $id,
            array_key_exists('concluido', $validated) ? (bool) $validated['concluido'] : null,
        );

        return response()->json([
            'success' => true,
            'message' => $dia->concluido ? 'Treino marcado como feito.' : 'Treino desmarcado.',
            'data' => [
                'id' => $dia->id,
                'dia_chave' => $dia->dia_chave,
                'label' => $dia->label,
                'foco' => $dia->foco,
                'is_rest' => $dia->is_rest,
                'concluido' => $dia->concluido,
            ],
        ]);
    }

    public function storeEsporte(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'esporte_chave' => ['required', 'string', 'max:40'],
            'minutos' => ['nullable', 'integer', 'min:5', 'max:300'],
            'distancia_metros' => ['nullable', 'integer', 'min:0', 'max:200000'],
            'data' => ['nullable', 'date'],
            'nota' => ['nullable', 'string', 'max:160'],
        ]);

        $sessao = $this->academiaService->registrarEsporte($request->user(), $validated);

        return response()->json([
            'success' => true,
            'message' => 'Sessão de esporte registrada.',
            'data' => [
                'id' => $sessao->id,
                'esporte_chave' => $sessao->esporte_chave,
                'icone' => $sessao->icone,
                'nome' => $sessao->nome,
                'minutos' => $sessao->minutos,
                'distancia_metros' => $sessao->distancia_metros,
                'xp' => $sessao->xp,
                'data' => $sessao->data?->toDateString(),
                'nota' => $sessao->nota,
            ],
        ], 201);
    }

    public function destroyEsporte(Request $request, int $id): JsonResponse
    {
        $this->academiaService->excluirEsporte($request->user(), $id);

        return response()->json([
            'success' => true,
            'message' => 'Sessão removida.',
        ]);
    }
}
