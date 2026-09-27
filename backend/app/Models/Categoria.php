<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

/**
 * Categoria usada para organizar e colorir tarefas.
 */
class Categoria extends Model
{
    protected $fillable = [
        'usuario_id',
        'nome',
        'cor',
    ];

    /** Usuário dono da categoria. */
    public function usuario(): BelongsTo
    {
        return $this->belongsTo(Usuario::class, 'usuario_id');
    }

    /** Tarefas que pertencem a esta categoria. */
    public function tarefas(): HasMany
    {
        return $this->hasMany(Tarefa::class, 'categoria_id');
    }
}
