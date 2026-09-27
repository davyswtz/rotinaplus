<?php

namespace App\Services;

use App\Models\Habito;
use App\Models\RegistroHabito;
use App\Models\Usuario;
use Illuminate\Database\Eloquent\Collection;

/**
 * Serviço responsável pelas regras de negócio de hábitos e seus registros diários.
 */
class HabitoService
{
    /**
     * Lista os hábitos ativos do usuário, já com os registros de um período
     * carregados (usado para montar o quadro de hábitos da semana).
     */
    public function listarComRegistros(Usuario $usuario, string $dataInicio, string $dataFim): Collection
    {
        return $usuario->habitos()
            ->where('ativo', true)
            ->orderBy('ordem')
            ->with(['registros' => function ($query) use ($dataInicio, $dataFim) {
                $query->whereBetween('data', [$dataInicio, $dataFim]);
            }])
            ->get();
    }

    /**
     * Cria um novo hábito para o usuário.
     */
    public function criar(Usuario $usuario, array $dados): Habito
    {
        return $usuario->habitos()->create($dados);
    }

    /**
     * Atualiza os dados de um hábito existente.
     */
    public function atualizar(Habito $habito, array $dados): Habito
    {
        $habito->update($dados);

        return $habito;
    }

    /**
     * Remove um hábito (e seus registros, via cascade no banco).
     */
    public function remover(Habito $habito): void
    {
        $habito->delete();
    }

    /**
     * Alterna a marcação de um hábito em um dia específico (cria, ativa
     * ou desativa o registro daquele dia).
     */
    public function alternarRegistroDoDia(Habito $habito, string $data): RegistroHabito
    {
        $registro = RegistroHabito::firstOrNew([
            'habito_id' => $habito->id,
            'data' => $data,
        ]);

        $registro->concluido = ! $registro->concluido;
        $registro->save();

        return $registro;
    }
}
