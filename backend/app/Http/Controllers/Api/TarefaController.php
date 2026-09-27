<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Tarefa;
use App\Services\TarefaService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Controller responsável pelos endpoints de tarefas de rotina.
 */
class TarefaController extends Controller
{
    public function __construct(
        private readonly TarefaService $tarefaService,
    ) {}

    /**
     * Lista as tarefas do usuário em um intervalo de datas.
     * Espera os parâmetros de query "data_inicio" e "data_fim".
     */
    public function index(Request $request): JsonResponse
    {
        $filtros = $request->validate([
            'data_inicio' => ['required', 'date'],
            'data_fim' => ['required', 'date', 'after_or_equal:data_inicio'],
        ]);

        $tarefas = $this->tarefaService->listarPorPeriodo(
            $request->user(),
            $filtros['data_inicio'],
            $filtros['data_fim'],
        );

        $percentualConcluido = $this->tarefaService->calcularPercentualConcluido(
            $request->user(),
            $filtros['data_inicio'],
            $filtros['data_fim'],
        );

        return response()->json([
            'tarefas' => $tarefas,
            'percentual_concluido' => $percentualConcluido,
        ]);
    }

    /**
     * Cria uma nova tarefa.
     */
    public function store(Request $request): JsonResponse
    {
        $dados = $request->validate([
            'categoria_id' => ['nullable', 'exists:categorias,id'],
            'titulo' => ['required', 'string', 'max:255'],
            'descricao' => ['nullable', 'string'],
            'data' => ['required', 'date'],
        ]);

        $tarefa = $this->tarefaService->criar($request->user(), $dados);

        return response()->json($tarefa, 201);
    }

    /**
     * Atualiza uma tarefa existente.
     */
    public function update(Request $request, Tarefa $tarefa): JsonResponse
    {
        $this->garantirQueTarefaPertenceAoUsuario($request, $tarefa);

        $dados = $request->validate([
            'categoria_id' => ['sometimes', 'nullable', 'exists:categorias,id'],
            'titulo' => ['sometimes', 'required', 'string', 'max:255'],
            'descricao' => ['sometimes', 'nullable', 'string'],
            'data' => ['sometimes', 'required', 'date'],
            'concluida' => ['sometimes', 'boolean'],
        ]);

        $tarefa = $this->tarefaService->atualizar($tarefa, $dados);

        return response()->json($tarefa);
    }

    /**
     * Alterna o status de conclusão da tarefa.
     */
    public function alternarConclusao(Request $request, Tarefa $tarefa): JsonResponse
    {
        $this->garantirQueTarefaPertenceAoUsuario($request, $tarefa);

        $tarefa = $this->tarefaService->alternarConclusao($tarefa);

        return response()->json($tarefa);
    }

    /**
     * Remove uma tarefa.
     */
    public function destroy(Request $request, Tarefa $tarefa): JsonResponse
    {
        $this->garantirQueTarefaPertenceAoUsuario($request, $tarefa);

        $this->tarefaService->remover($tarefa);

        return response()->json(['mensagem' => 'Tarefa removida com sucesso.']);
    }

    /**
     * Impede que um usuário edite/remova tarefas de outra pessoa.
     */
    private function garantirQueTarefaPertenceAoUsuario(Request $request, Tarefa $tarefa): void
    {
        abort_if($tarefa->usuario_id !== $request->user()->id, 403, 'Acesso não autorizado a esta tarefa.');
    }
}
