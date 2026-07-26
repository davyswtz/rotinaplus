<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class AcademiaTreino extends Model
{
    protected $fillable = [
        'user_id',
        'foco',
        'titulo',
        'exercicios',
        'minutos',
        'xp',
        'dia_chave',
        'ativo',
        'concluido_em',
        'volume_kg',
    ];

    protected function casts(): array
    {
        return [
            'exercicios' => 'integer',
            'minutos' => 'integer',
            'xp' => 'integer',
            'ativo' => 'boolean',
            'concluido_em' => 'datetime',
            'volume_kg' => 'integer',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function itens(): HasMany
    {
        return $this->hasMany(AcademiaTreinoExercicio::class, 'treino_id')->orderBy('ordem');
    }
}
