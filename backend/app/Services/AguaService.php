<?php

namespace App\Services;

use App\Models\RegistroAgua;
use App\Models\Usuario;
use Illuminate\Database\Eloquent\Collection;

/**
 * Serviço responsável pelas regras de negócio do tracker de consumo de água.
 */
class AguaService
{
    /** Quantidade adicionada a cada "gota" marcada, em mililitros. */
    private const ML_POR_GOTA = 250;

    /**
     * Lista os registros de água do usuário em um período.
     */
    public function listarPorPeriodo(Usuario $usuario, string $dataInicio, string $dataFim): Collection
    {
        return $usuario->registrosAgua()
            ->whereBetween('data', [$dataInicio, $dataFim])
            ->get();
    }

    /**
     * Adiciona uma "gota" de água ao registro do dia (cria o registro se não existir).
     */
    public function adicionarGota(Usuario $usuario, string $data): RegistroAgua
    {
        $registro = RegistroAgua::firstOrCreate(
            ['usuario_id' => $usuario->id, 'data' => $data],
            ['quantidade_ml' => 0],
        );

        $registro->increment('quantidade_ml', self::ML_POR_GOTA);

        return $registro;
    }

    /**
     * Remove uma "gota" de água do registro do dia (sem deixar o total ser negativo).
     */
    public function removerGota(Usuario $usuario, string $data): RegistroAgua
    {
        $registro = RegistroAgua::firstOrCreate(
            ['usuario_id' => $usuario->id, 'data' => $data],
            ['quantidade_ml' => 0],
        );

        $novaQuantidade = max(0, $registro->quantidade_ml - self::ML_POR_GOTA);
        $registro->update(['quantidade_ml' => $novaQuantidade]);

        return $registro;
    }
}
