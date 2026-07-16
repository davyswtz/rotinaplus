<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AcademiaResource extends JsonResource
{
    /** @param  array<string, mixed>  $resource */
    public function toArray(Request $request): array
    {
        $data = $this->resource;

        return [
            'meta_semana' => $data['meta_semana'],
            'feitos' => $data['feitos'],
            'sequencia_treinos' => $data['sequencia_treinos'],
            'semana_inicio' => $data['semana_inicio'],
            'dias' => collect($data['dias'])->map(fn ($d) => [
                'id' => $d->id,
                'dia_chave' => $d->dia_chave,
                'label' => $d->label,
                'foco' => $d->foco,
                'is_rest' => $d->is_rest,
                'concluido' => $d->concluido,
                'ordem' => $d->ordem,
            ])->values(),
            'volumes' => collect($data['volumes'])->map(fn ($v) => [
                'id' => $v->id,
                'dia_chave' => $v->dia_chave,
                'label' => $v->label,
                'kg' => $v->kg,
            ])->values(),
            'treino_hoje' => $data['treino_hoje'] ? [
                'id' => $data['treino_hoje']->id,
                'foco' => $data['treino_hoje']->foco,
                'titulo' => $data['treino_hoje']->titulo,
                'exercicios' => $data['treino_hoje']->exercicios,
                'minutos' => $data['treino_hoje']->minutos,
                'xp' => $data['treino_hoje']->xp,
                'dia_chave' => $data['treino_hoje']->dia_chave,
            ] : null,
        ];
    }
}
