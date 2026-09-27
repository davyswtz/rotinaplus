<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transacao;
use App\Services\TransacaoService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Controller responsável pelos endpoints de controle financeiro
 * (receitas, despesas e o resumo do período).
 */
class TransacaoController extends Controller
{
    /** Tipos de transação aceitos pelo sistema. */
    private const TIPOS = ['receita', 'despesa'];

    public function __construct(
        private readonly TransacaoService $transacaoService,
    ) {}

    /**
     * Lista as transações do usuário em um período, já com o resumo
     * financeiro (receitas, despesas e saldo) calculado.
     */
    public function index(Request $request): JsonResponse
    {
        $filtros = $request->validate([
            'data_inicio' => ['required', 'date'],
            'data_fim' => ['required', 'date', 'after_or_equal:data_inicio'],
        ]);

        $transacoes = $this->transacaoService->listarPorPeriodo(
            $request->user(),
            $filtros['data_inicio'],
            $filtros['data_fim'],
        );

        $resumo = $this->transacaoService->calcularResumo(
            $request->user(),
            $filtros['data_inicio'],
            $filtros['data_fim'],
        );

        return response()->json([
            'transacoes' => $transacoes,
            'resumo' => $resumo,
        ]);
    }

    /**
     * Cria uma nova transação (receita ou despesa).
     */
    public function store(Request $request): JsonResponse
    {
        $dados = $request->validate([
            'tipo' => ['required', 'string', 'in:'.implode(',', self::TIPOS)],
            'categoria' => ['required', 'string', 'max:255'],
            'descricao' => ['nullable', 'string', 'max:255'],
            'valor' => ['required', 'numeric', 'min:0.01'],
            'data' => ['required', 'date'],
        ]);

        $transacao = $this->transacaoService->criar($request->user(), $dados);

        return response()->json($transacao, 201);
    }

    /**
     * Atualiza uma transação existente.
     */
    public function update(Request $request, Transacao $transacao): JsonResponse
    {
        $this->garantirQueTransacaoPertenceAoUsuario($request, $transacao);

        $dados = $request->validate([
            'tipo' => ['sometimes', 'required', 'string', 'in:'.implode(',', self::TIPOS)],
            'categoria' => ['sometimes', 'required', 'string', 'max:255'],
            'descricao' => ['sometimes', 'nullable', 'string', 'max:255'],
            'valor' => ['sometimes', 'required', 'numeric', 'min:0.01'],
            'data' => ['sometimes', 'required', 'date'],
        ]);

        $transacao = $this->transacaoService->atualizar($transacao, $dados);

        return response()->json($transacao);
    }

    /**
     * Remove uma transação.
     */
    public function destroy(Request $request, Transacao $transacao): JsonResponse
    {
        $this->garantirQueTransacaoPertenceAoUsuario($request, $transacao);

        $this->transacaoService->remover($transacao);

        return response()->json(['mensagem' => 'Transação removida com sucesso.']);
    }

    /**
     * Impede que um usuário edite/remova transações de outra pessoa.
     */
    private function garantirQueTransacaoPertenceAoUsuario(Request $request, Transacao $transacao): void
    {
        abort_if($transacao->usuario_id !== $request->user()->id, 403, 'Acesso não autorizado a esta transação.');
    }
}
