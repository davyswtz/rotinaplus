<?php

namespace App\Services;

use App\Models\Tarefa;
use App\Models\Usuario;
use Illuminate\Database\Eloquent\Collection;

/**
 * Serviço responsável pelas regras de negócio das tarefas de rotina.
 */
class TarefaService
{
    /**
     * Lista as tarefas do usuário dentro de um intervalo de datas (ex: uma semana).
     */
    public function listarPorPeriodo(Usuario $usuario, string $dataInicio, string $dataFim): Collection
    {
        return $usuario->tarefas()
            ->whereBetween('data', [$dataInicio, $dataFim])
            ->orderBy('data')
            ->orderBy('id')
            ->get();
    }

    /**
     * Cria uma nova tarefa para o usuário.
     */
    public function criar(Usuario $usuario, array $dados): Tarefa
    {
        return $usuario->tarefas()->create($dados);
    }

    /**
     * Atualiza os dados de uma tarefa existente.
     */
    public function atualizar(Tarefa $tarefa, array $dados): Tarefa
    {
        $tarefa->update($dados);

        return $tarefa;
    }

    /**
     * Alterna o status de conclusão da tarefa (concluída/pendente).
     */
    public function alternarConclusao(Tarefa $tarefa): Tarefa
    {
        $tarefa->update(['concluida' => ! $tarefa->concluida]);

        return $tarefa;
    }

    /**
     * Remove uma tarefa.
     */
    public function remover(Tarefa $tarefa): void
    {
        $tarefa->delete();
    }

    /**
     * Calcula o percentual de tarefas concluídas dentro de um período
     * (usado na barra de progresso da semana).
     */
    public function calcularPercentualConcluido(Usuario $usuario, string $dataInicio, string $dataFim): float
    {
        $tarefas = $this->listarPorPeriodo($usuario, $dataInicio, $dataFim);

        if ($tarefas->isEmpty()) {
            return 0;
        }

        $totalConcluidas = $tarefas->where('concluida', true)->count();

        return round(($totalConcluidas / $tarefas->count()) * 100);
    }
}
