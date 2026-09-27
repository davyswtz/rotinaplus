<?php

namespace App\Services;

use App\Models\Reflexao;
use App\Models\Usuario;

/**
 * Serviço responsável pelas regras de negócio das reflexões semanais.
 */
class ReflexaoService
{
    /**
     * Busca a reflexão do usuário para a semana informada (ou null se não existir).
     */
    public function buscarPorSemana(Usuario $usuario, string $semanaInicio): ?Reflexao
    {
        return $usuario->reflexoes()
            ->where('semana_inicio', $semanaInicio)
            ->first();
    }

    /**
     * Cria ou atualiza o texto de reflexão de uma semana.
     */
    public function salvar(Usuario $usuario, string $semanaInicio, string $texto): Reflexao
    {
        return Reflexao::updateOrCreate(
            ['usuario_id' => $usuario->id, 'semana_inicio' => $semanaInicio],
            ['texto' => $texto],
        );
    }
}
