<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Perfil extends Model
{
    protected $table = 'perfis';

    protected $fillable = [
        'user_id',
        'nome_heroi',
        'avatar_key',
        'classe',
        'emoji_classe',
        'nivel',
        'xp_atual',
        'xp_proximo_nivel',
        'moedas',
        'streak_dias',
    ];

    protected function casts(): array
    {
        return [
            'nivel' => 'integer',
            'xp_atual' => 'integer',
            'xp_proximo_nivel' => 'integer',
            'moedas' => 'integer',
            'streak_dias' => 'integer',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
