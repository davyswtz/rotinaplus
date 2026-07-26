<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class HabitoCheckin extends Model
{
    protected $table = 'habito_checkins';

    protected $fillable = [
        'user_id',
        'habito_id',
        'data',
        'concluida',
        'concluida_em',
        'humor',
        'nota',
    ];

    protected function casts(): array
    {
        return [
            'data' => 'date',
            'concluida' => 'boolean',
            'concluida_em' => 'datetime',
            'humor' => 'integer',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function habito(): BelongsTo
    {
        return $this->belongsTo(Habito::class);
    }
}
