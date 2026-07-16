<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class FinancasMeta extends Model
{
    protected $table = 'financas_metas';

    protected $fillable = [
        'user_id',
        'titulo',
        'icone',
        'categoria',
        'valor_alvo_centavos',
        'valor_atual_centavos',
    ];

    protected function casts(): array
    {
        return [
            'valor_alvo_centavos' => 'integer',
            'valor_atual_centavos' => 'integer',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
