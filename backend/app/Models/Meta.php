<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * Meta/objetivo da lista de marcadores (bullet list de metas da semana).
 */
class Meta extends Model
{
    protected $fillable = [
        'usuario_id',
        'titulo',
        'concluida',
        'ordem',
    ];

    protected function casts(): array
    {
        return [
            'concluida' => 'boolean',
        ];
    }

    /** Usuário dono da meta. */
    public function usuario(): BelongsTo
    {
        return $this->belongsTo(Usuario::class, 'usuario_id');
    }
}
