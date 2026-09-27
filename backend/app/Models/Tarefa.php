<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * Tarefa de rotina vinculada a um dia específico (exibida na visão semanal).
 */
class Tarefa extends Model
{
    protected $fillable = [
        'usuario_id',
        'categoria_id',
        'titulo',
        'descricao',
        'data',
        'concluida',
    ];

    protected function casts(): array
    {
        return [
            // Formato explícito "Y-m-d": evita salvar como datetime completo
            // ("2026-09-28 00:00:00"), o que quebraria comparações com
            // strings de data cruas usadas nos filtros de período.
            'data' => 'date:Y-m-d',
            'concluida' => 'boolean',
        ];
    }

    /** Usuário dono da tarefa. */
    public function usuario(): BelongsTo
    {
        return $this->belongsTo(Usuario::class, 'usuario_id');
    }

    /** Categoria associada à tarefa (opcional). */
    public function categoria(): BelongsTo
    {
        return $this->belongsTo(Categoria::class, 'categoria_id');
    }
}
