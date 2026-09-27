<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * Texto de reflexão livre escrito pelo usuário sobre a semana.
 */
class Reflexao extends Model
{
    // Definido explicitamente pois a pluralização automática do Eloquent
    // (baseada em regras do inglês) não corresponde ao nome em português.
    protected $table = 'reflexoes';

    protected $fillable = [
        'usuario_id',
        'semana_inicio',
        'texto',
    ];

    protected function casts(): array
    {
        return [
            // Formato explícito "Y-m-d": evita salvar como datetime completo,
            // que quebraria o updateOrCreate usado para salvar a reflexão da semana.
            'semana_inicio' => 'date:Y-m-d',
        ];
    }

    /** Usuário dono da reflexão. */
    public function usuario(): BelongsTo
    {
        return $this->belongsTo(Usuario::class, 'usuario_id');
    }
}
