<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Amizade extends Model
{
    protected $table = 'amizades';

    protected $fillable = [
        'user_id',
        'amigo_id',
        'status',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function amigo(): BelongsTo
    {
        return $this->belongsTo(User::class, 'amigo_id');
    }
}
