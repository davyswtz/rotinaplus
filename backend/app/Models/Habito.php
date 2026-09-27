<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * Hábito acompanhado no quadro semanal (ex: academia, alongamento, estudo).
 */
class Habito extends Model
{
    protected $fillable = [
        'usuario_id',
        'nome',
        'ordem',
        'ativo',
    ];

    protected function casts(): array
    {
        return [
            'ativo' => 'boolean',
        ];
    }

    /** Usuário dono do hábito. */
    public function usuario(): BelongsTo
    {
        return $this->belongsTo(Usuario::class, 'usuario_id');
    }

    /** Registros diários de conclusão deste hábito. */
    public function registros(): HasMany
    {
        return $this->hasMany(RegistroHabito::class, 'habito_id');
    }
}
