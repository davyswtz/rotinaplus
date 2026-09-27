<?php

namespace App\Services;

use App\Models\Categoria;
use App\Models\Usuario;
use Illuminate\Database\Eloquent\Collection;

/**
 * Serviço responsável pelas regras de negócio de categorias.
 */
class CategoriaService
{
    /**
     * Lista todas as categorias do usuário.
     */
    public function listar(Usuario $usuario): Collection
    {
        return $usuario->categorias()->orderBy('nome')->get();
    }

    /**
     * Cria uma nova categoria para o usuário.
     */
    public function criar(Usuario $usuario, array $dados): Categoria
    {
        return $usuario->categorias()->create($dados);
    }

    /**
     * Atualiza os dados de uma categoria existente.
     */
    public function atualizar(Categoria $categoria, array $dados): Categoria
    {
        $categoria->update($dados);

        return $categoria;
    }

    /**
     * Remove uma categoria.
     */
    public function remover(Categoria $categoria): void
    {
        $categoria->delete();
    }
}
