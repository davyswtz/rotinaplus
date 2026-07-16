<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AcademiaConfig extends Model
{
    protected $fillable = [
        'user_id',
        'meta_semana',
        'sequencia_treinos',
    ];

    protected function casts(): array
    {
        return [
            'meta_semana' => 'integer',
            'sequencia_treinos' => 'integer',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
