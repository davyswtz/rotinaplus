<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class FinancasConexao extends Model
{
    protected $table = 'financas_conexoes';

    protected $fillable = [
        'user_id',
        'provider',
        'item_id',
        'connector_id',
        'connector_name',
        'status',
        'last_sync_at',
        'meta',
    ];

    protected function casts(): array
    {
        return [
            'connector_id' => 'integer',
            'last_sync_at' => 'datetime',
            'meta' => 'array',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function transacoes(): HasMany
    {
        return $this->hasMany(FinancasTransacao::class, 'conexao_id');
    }
}
