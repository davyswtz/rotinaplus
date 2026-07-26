<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AcademiaEsporteSessao extends Model
{
    protected $table = 'academia_esporte_sessoes';

    protected $fillable = [
        'user_id',
        'esporte_chave',
        'icone',
        'nome',
        'minutos',
        'distancia_metros',
        'xp',
        'data',
        'nota',
    ];

    protected function casts(): array
    {
        return [
            'minutos' => 'integer',
            'distancia_metros' => 'integer',
            'xp' => 'integer',
            'data' => 'date',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
