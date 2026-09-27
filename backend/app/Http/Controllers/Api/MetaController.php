<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Meta;
use App\Services\MetaService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Controller responsável pelos endpoints de metas.
 */
class MetaController extends Controller
{
    public function __construct(
        private readonly MetaService $metaService,
    ) {}

    /**
     * Lista as metas do usuário autenticado.
     */
    public function index(Request $request): JsonResponse
    {
        return response()->json($this->metaService->listar($request->user()));
    }

    /**
     * Cria uma nova meta.
     */
    public function store(Request $request): JsonResponse
    {
        $dados = $request->validate([
            'titulo' => ['required', 'string', 'max:255'],
            'ordem' => ['nullable', 'integer', 'min:0'],
        ]);

        $meta = $this->metaService->criar($request->user(), $dados);

        return response()->json($meta, 201);
    }

    /**
     * Atualiza uma meta existente.
     */
    public function update(Request $request, Meta $meta): JsonResponse
    {
        $this->garantirQueMetaPertenceAoUsuario($request, $meta);

        $dados = $request->validate([
            'titulo' => ['sometimes', 'required', 'string', 'max:255'],
            'ordem' => ['sometimes', 'integer', 'min:0'],
            'concluida' => ['sometimes', 'boolean'],
        ]);

        $meta = $this->metaService->atualizar($meta, $dados);

        return response()->json($meta);
    }

    /**
     * Alterna o status de conclusão da meta.
     */
    public function alternarConclusao(Request $request, Meta $meta): JsonResponse
    {
        $this->garantirQueMetaPertenceAoUsuario($request, $meta);

        $meta = $this->metaService->alternarConclusao($meta);

        return response()->json($meta);
    }

    /**
     * Remove uma meta.
     */
    public function destroy(Request $request, Meta $meta): JsonResponse
    {
        $this->garantirQueMetaPertenceAoUsuario($request, $meta);

        $this->metaService->remover($meta);

        return response()->json(['mensagem' => 'Meta removida com sucesso.']);
    }

    /**
     * Impede que um usuário edite/remova metas de outra pessoa.
     */
    private function garantirQueMetaPertenceAoUsuario(Request $request, Meta $meta): void
    {
        abort_if($meta->usuario_id !== $request->user()->id, 403, 'Acesso não autorizado a esta meta.');
    }
}
