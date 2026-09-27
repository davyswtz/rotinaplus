<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Habito;
use App\Services\HabitoService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Controller responsável pelos endpoints de hábitos e do quadro de acompanhamento.
 */
class HabitoController extends Controller
{
    public function __construct(
        private readonly HabitoService $habitoService,
    ) {}

    /**
     * Lista os hábitos do usuário com os registros de um período
     * (parâmetros de query "data_inicio" e "data_fim").
     */
    public function index(Request $request): JsonResponse
    {
        $filtros = $request->validate([
            'data_inicio' => ['required', 'date'],
            'data_fim' => ['required', 'date', 'after_or_equal:data_inicio'],
        ]);

        $habitos = $this->habitoService->listarComRegistros(
            $request->user(),
            $filtros['data_inicio'],
            $filtros['data_fim'],
        );

        return response()->json($habitos);
    }

    /**
     * Cria um novo hábito.
     */
    public function store(Request $request): JsonResponse
    {
        $dados = $request->validate([
            'nome' => ['required', 'string', 'max:255'],
            'ordem' => ['nullable', 'integer', 'min:0'],
        ]);

        $habito = $this->habitoService->criar($request->user(), $dados);

        return response()->json($habito, 201);
    }

    /**
     * Atualiza um hábito existente.
     */
    public function update(Request $request, Habito $habito): JsonResponse
    {
        $this->garantirQueHabitoPertenceAoUsuario($request, $habito);

        $dados = $request->validate([
            'nome' => ['sometimes', 'required', 'string', 'max:255'],
            'ordem' => ['sometimes', 'integer', 'min:0'],
            'ativo' => ['sometimes', 'boolean'],
        ]);

        $habito = $this->habitoService->atualizar($habito, $dados);

        return response()->json($habito);
    }

    /**
     * Remove um hábito.
     */
    public function destroy(Request $request, Habito $habito): JsonResponse
    {
        $this->garantirQueHabitoPertenceAoUsuario($request, $habito);

        $this->habitoService->remover($habito);

        return response()->json(['mensagem' => 'Hábito removido com sucesso.']);
    }

    /**
     * Alterna a marcação do hábito em um dia específico.
     */
    public function alternarRegistroDoDia(Request $request, Habito $habito): JsonResponse
    {
        $this->garantirQueHabitoPertenceAoUsuario($request, $habito);

        $dados = $request->validate([
            'data' => ['required', 'date'],
        ]);

        $registro = $this->habitoService->alternarRegistroDoDia($habito, $dados['data']);

        return response()->json($registro);
    }

    /**
     * Impede que um usuário edite/remova hábitos de outra pessoa.
     */
    private function garantirQueHabitoPertenceAoUsuario(Request $request, Habito $habito): void
    {
        abort_if($habito->usuario_id !== $request->user()->id, 403, 'Acesso não autorizado a este hábito.');
    }
}
