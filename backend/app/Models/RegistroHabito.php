<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * Registra se um hábito foi concluído em um dia específico
 * (representa as "bolinhas marcadas" do quadro de hábitos).
 */
class RegistroHabito extends Model
{
    // Definido explicitamente pois a pluralização automática do Eloquent
    // (baseada em regras do inglês) não corresponde ao nome em português.
    protected $table = 'registros_habitos';

    protected $fillable = [
        'habito_id',
        'data',
        'concluido',
    ];

    protected function casts(): array
    {
        return [
            // Formato explícito "Y-m-d": evita salvar como datetime completo,
            // que quebraria o firstOrNew usado para alternar o registro do dia.
            'data' => 'date:Y-m-d',
            'concluido' => 'boolean',
        ];
    }

    /** Hábito ao qual este registro pertence. */
    public function habito(): BelongsTo
    {
        return $this->belongsTo(Habito::class, 'habito_id');
    }
}
