<?php

namespace App\Services;

use App\Models\Transacao;
use App\Models\Usuario;
use Illuminate\Database\Eloquent\Collection;

/**
 * Serviço responsável pelas regras de negócio das transações financeiras
 * (receitas e despesas) e pelo cálculo do resumo financeiro do período.
 */
class TransacaoService
{
    /**
     * Lista as transações do usuário dentro de um intervalo de datas (ex: um mês).
     */
    public function listarPorPeriodo(Usuario $usuario, string $dataInicio, string $dataFim): Collection
    {
        return $usuario->transacoes()
            ->whereBetween('data', [$dataInicio, $dataFim])
            ->orderByDesc('data')
            ->orderByDesc('id')
            ->get();
    }

    /**
     * Cria uma nova transação para o usuário.
     */
    public function criar(Usuario $usuario, array $dados): Transacao
    {
        return $usuario->transacoes()->create($dados);
    }

    /**
     * Atualiza os dados de uma transação existente.
     */
    public function atualizar(Transacao $transacao, array $dados): Transacao
    {
        $transacao->update($dados);

        return $transacao;
    }

    /**
     * Remove uma transação.
     */
    public function remover(Transacao $transacao): void
    {
        $transacao->delete();
    }

    /**
     * Calcula o resumo financeiro do período: total de receitas, total de
     * despesas e o saldo (receitas - despesas). Usado nos cartões do topo
     * da tela de Financeiro.
     *
     * @return array{total_receitas: float, total_despesas: float, saldo: float}
     */
    public function calcularResumo(Usuario $usuario, string $dataInicio, string $dataFim): array
    {
        $transacoes = $this->listarPorPeriodo($usuario, $dataInicio, $dataFim);

        $totalReceitas = (float) $transacoes->where('tipo', 'receita')->sum('valor');
        $totalDespesas = (float) $transacoes->where('tipo', 'despesa')->sum('valor');

        return [
            'total_receitas' => $totalReceitas,
            'total_despesas' => $totalDespesas,
            'saldo' => $totalReceitas - $totalDespesas,
        ];
    }
}
