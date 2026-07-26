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
            'focos' => $data['focos'] ?? [],
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
            'treino_hoje' => $data['treino_hoje']
                ? self::treinoPayload($data['treino_hoje'])
                : null,
            'esportes' => $data['esportes'] ?? [],
            'esporte_resumo' => $data['esporte_resumo'] ?? [
                'total_semana' => 0,
                'minutos_semana' => 0,
                'xp_semana' => 0,
            ],
            'esporte_sessoes' => collect($data['esporte_sessoes'] ?? [])->map(fn ($s) => [
                'id' => $s->id,
                'esporte_chave' => $s->esporte_chave,
                'icone' => $s->icone,
                'nome' => $s->nome,
                'minutos' => $s->minutos,
                'distancia_metros' => $s->distancia_metros,
                'xp' => $s->xp,
                'data' => $s->data?->toDateString(),
                'nota' => $s->nota,
            ])->values(),
        ];
    }

    public static function treinoPayload(mixed $treino): array
    {
        $itens = $treino->relationLoaded('itens')
            ? $treino->itens
            : $treino->itens()->orderBy('ordem')->get();

        return [
            'id' => $treino->id,
            'foco' => $treino->foco,
            'titulo' => $treino->titulo,
            'exercicios' => $treino->exercicios,
            'minutos' => $treino->minutos,
            'xp' => $treino->xp,
            'dia_chave' => $treino->dia_chave,
            'ativo' => (bool) $treino->ativo,
            'concluido_em' => $treino->concluido_em?->toIso8601String(),
            'volume_kg' => (int) ($treino->volume_kg ?? 0),
            'itens' => collect($itens)->map(fn ($i) => [
                'id' => $i->id,
                'exercicio_chave' => $i->exercicio_chave,
                'nome' => $i->nome,
                'icone' => $i->icone,
                'grupo' => $i->grupo,
                'series' => $i->series,
                'reps' => $i->reps,
                'carga_kg' => $i->carga_kg,
                'ordem' => $i->ordem,
                'concluido' => (bool) $i->concluido,
            ])->values(),
        ];
    }
}
