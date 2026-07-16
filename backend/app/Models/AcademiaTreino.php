<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

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
    ];

    protected function casts(): array
    {
        return [
            'exercicios' => 'integer',
            'minutos' => 'integer',
            'xp' => 'integer',
            'ativo' => 'boolean',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
