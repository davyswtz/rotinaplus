<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AcademiaVolume extends Model
{
    protected $fillable = [
        'user_id',
        'semana_inicio',
        'dia_chave',
        'label',
        'kg',
    ];

    protected function casts(): array
    {
        return [
            'semana_inicio' => 'date',
            'kg' => 'integer',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
