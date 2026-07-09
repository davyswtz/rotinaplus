<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Rotina extends Model
{
    use HasFactory;

    protected $fillable = [
        'titulo',
        'descricao',
        'concluida',
    ];

    protected function casts(): array
    {
        return [
            'concluida' => 'boolean',
        ];
    }
}
