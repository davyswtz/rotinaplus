<?php

namespace App\Services;

use App\Models\Meta;
use App\Models\Usuario;
use Illuminate\Database\Eloquent\Collection;

/**
 * Serviço responsável pelas regras de negócio das metas (lista de objetivos).
 */
class MetaService
{
    /**
     * Lista as metas do usuário, ordenadas pela ordem definida.
     */
    public function listar(Usuario $usuario): Collection
    {
        return $usuario->metas()->orderBy('ordem')->orderBy('id')->get();
    }

    /**
     * Cria uma nova meta para o usuário.
     */
    public function criar(Usuario $usuario, array $dados): Meta
    {
        return $usuario->metas()->create($dados);
    }

    /**
     * Atualiza os dados de uma meta existente.
     */
    public function atualizar(Meta $meta, array $dados): Meta
    {
        $meta->update($dados);

        return $meta;
    }

    /**
     * Alterna o status de conclusão da meta.
     */
    public function alternarConclusao(Meta $meta): Meta
    {
        $meta->update(['concluida' => ! $meta->concluida]);

        return $meta;
    }

    /**
     * Remove uma meta.
     */
    public function remover(Meta $meta): void
    {
        $meta->delete();
    }
}
