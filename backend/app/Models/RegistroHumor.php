<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * Registro do humor (emoji) escolhido pelo usuário em um dia específico.
 */
class RegistroHumor extends Model
{
    // Definido explicitamente pois a pluralização automática do Eloquent
    // (baseada em regras do inglês) não corresponde ao nome em português.
    protected $table = 'registros_humor';

    protected $fillable = [
        'usuario_id',
        'data',
        'humor',
    ];

    protected function casts(): array
    {
        return [
            // Formato explícito "Y-m-d": evita salvar como datetime completo,
            // que quebraria o updateOrCreate usado para definir o humor do dia.
            'data' => 'date:Y-m-d',
        ];
    }

    /** Usuário dono do registro. */
    public function usuario(): BelongsTo
    {
        return $this->belongsTo(Usuario::class, 'usuario_id');
    }
}
