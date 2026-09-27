<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * Transação financeira (receita ou despesa) lançada pelo usuário.
 */
class Transacao extends Model
{
    // Definido explicitamente pois a pluralização automática do Eloquent
    // (baseada em regras do inglês) não corresponde ao nome em português.
    protected $table = 'transacoes';

    protected $fillable = [
        'usuario_id',
        'tipo',
        'categoria',
        'descricao',
        'valor',
        'data',
    ];

    protected function casts(): array
    {
        return [
            // Formato explícito "Y-m-d": evita salvar como datetime completo
            // (mesmo cuidado tomado nos outros models com campo de data).
            'data' => 'date:Y-m-d',
            'valor' => 'decimal:2',
        ];
    }

    /** Usuário dono da transação. */
    public function usuario(): BelongsTo
    {
        return $this->belongsTo(Usuario::class, 'usuario_id');
    }
}
