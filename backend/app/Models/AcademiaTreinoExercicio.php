<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AcademiaTreinoExercicio extends Model
{
    protected $table = 'academia_treino_exercicios';

    protected $fillable = [
        'treino_id',
        'exercicio_chave',
        'nome',
        'icone',
        'grupo',
        'series',
        'reps',
        'carga_kg',
        'ordem',
        'concluido',
    ];

    protected function casts(): array
    {
        return [
            'series' => 'integer',
            'reps' => 'integer',
            'carga_kg' => 'integer',
            'ordem' => 'integer',
            'concluido' => 'boolean',
        ];
    }

    public function treino(): BelongsTo
    {
        return $this->belongsTo(AcademiaTreino::class, 'treino_id');
    }
}
