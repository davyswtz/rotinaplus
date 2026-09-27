<?php

namespace App\Services;

use App\Models\RegistroHumor;
use App\Models\Usuario;
use Illuminate\Database\Eloquent\Collection;

/**
 * Serviço responsável pelas regras de negócio do tracker de humor diário.
 */
class HumorService
{
    /**
     * Lista os registros de humor do usuário em um período.
     */
    public function listarPorPeriodo(Usuario $usuario, string $dataInicio, string $dataFim): Collection
    {
        return $usuario->registrosHumor()
            ->whereBetween('data', [$dataInicio, $dataFim])
            ->get();
    }

    /**
     * Define (cria ou atualiza) o humor do usuário em um dia específico.
     */
    public function definirHumorDoDia(Usuario $usuario, string $data, string $humor): RegistroHumor
    {
        return RegistroHumor::updateOrCreate(
            ['usuario_id' => $usuario->id, 'data' => $data],
            ['humor' => $humor],
        );
    }
}
