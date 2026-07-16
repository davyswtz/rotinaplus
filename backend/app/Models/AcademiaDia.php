<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AcademiaDia extends Model
{
    protected $fillable = [
        'user_id',
        'semana_inicio',
        'dia_chave',
        'label',
        'foco',
        'is_rest',
        'concluido',
        'ordem',
    ];

    protected function casts(): array
    {
        return [
            'semana_inicio' => 'date',
            'is_rest' => 'boolean',
            'concluido' => 'boolean',
            'ordem' => 'integer',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
