<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Categoria;
use App\Services\CategoriaService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Controller responsável pelos endpoints de categorias.
 */
class CategoriaController extends Controller
{
    public function __construct(
        private readonly CategoriaService $categoriaService,
    ) {}

    /**
     * Lista as categorias do usuário autenticado.
     */
    public function index(Request $request): JsonResponse
    {
        return response()->json(
            $this->categoriaService->listar($request->user())
        );
    }

    /**
     * Cria uma nova categoria.
     */
    public function store(Request $request): JsonResponse
    {
        $dados = $request->validate([
            'nome' => ['required', 'string', 'max:255'],
            'cor' => ['nullable', 'string', 'max:7'],
        ]);

        $categoria = $this->categoriaService->criar($request->user(), $dados);

        return response()->json($categoria, 201);
    }

    /**
     * Atualiza uma categoria existente.
     */
    public function update(Request $request, Categoria $categoria): JsonResponse
    {
        $this->garantirQueCategoriaPertenceAoUsuario($request, $categoria);

        $dados = $request->validate([
            'nome' => ['sometimes', 'required', 'string', 'max:255'],
            'cor' => ['sometimes', 'nullable', 'string', 'max:7'],
        ]);

        $categoria = $this->categoriaService->atualizar($categoria, $dados);

        return response()->json($categoria);
    }

    /**
     * Remove uma categoria.
     */
    public function destroy(Request $request, Categoria $categoria): JsonResponse
    {
        $this->garantirQueCategoriaPertenceAoUsuario($request, $categoria);

        $this->categoriaService->remover($categoria);

        return response()->json(['mensagem' => 'Categoria removida com sucesso.']);
    }

    /**
     * Impede que um usuário edite/remova categorias de outra pessoa.
     */
    private function garantirQueCategoriaPertenceAoUsuario(Request $request, Categoria $categoria): void
    {
        abort_if($categoria->usuario_id !== $request->user()->id, 403, 'Acesso não autorizado a esta categoria.');
    }
}
