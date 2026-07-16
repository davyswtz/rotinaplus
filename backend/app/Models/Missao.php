<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Missao extends Model
{
    protected $table = 'missoes';

    protected $fillable = [
        'user_id',
        'data',
        'icone',
        'titulo',
        'detalhe',
        'xp',
        'concluida',
        'concluida_em',
        'ordem',
    ];

    protected function casts(): array
    {
        return [
            'data' => 'date',
            'xp' => 'integer',
            'concluida' => 'boolean',
            'concluida_em' => 'datetime',
            'ordem' => 'integer',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
