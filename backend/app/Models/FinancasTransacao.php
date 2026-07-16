<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class FinancasTransacao extends Model
{
    protected $table = 'financas_transacoes';

    protected $fillable = [
        'user_id',
        'tipo',
        'categoria',
        'titulo',
        'icone',
        'valor_centavos',
        'data',
    ];

    protected function casts(): array
    {
        return [
            'valor_centavos' => 'integer',
            'data' => 'date',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
