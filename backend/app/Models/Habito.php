<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Habito extends Model
{
    protected $table = 'habitos';

    protected $fillable = [
        'user_id',
        'icone',
        'titulo',
        'detalhe',
        'area',
        'frequencia',
        'dias_semana',
        'xp',
        'ativo',
        'ordem',
    ];

    protected function casts(): array
    {
        return [
            'dias_semana' => 'array',
            'xp' => 'integer',
            'ativo' => 'boolean',
            'ordem' => 'integer',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function checkins(): HasMany
    {
        return $this->hasMany(HabitoCheckin::class);
    }
}
