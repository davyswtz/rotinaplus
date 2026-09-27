<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * Registro da quantidade de água consumida pelo usuário em um dia específico.
 */
class RegistroAgua extends Model
{
    // Definido explicitamente pois a pluralização automática do Eloquent
    // (baseada em regras do inglês) não corresponde ao nome em português.
    protected $table = 'registros_agua';

    protected $fillable = [
        'usuario_id',
        'data',
        'quantidade_ml',
    ];

    protected function casts(): array
    {
        return [
            // Formato explícito "Y-m-d": sem isso, o Eloquent salva como
            // datetime completo (ex: "2026-09-28 00:00:00"), o que não bate
            // com a string de data crua usada nas buscas (firstOrCreate etc.)
            // e causa violação da constraint UNIQUE em chamadas repetidas.
            'data' => 'date:Y-m-d',
        ];
    }

    /** Usuário dono do registro. */
    public function usuario(): BelongsTo
    {
        return $this->belongsTo(Usuario::class, 'usuario_id');
    }
}
