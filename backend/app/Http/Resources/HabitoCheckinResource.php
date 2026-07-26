<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class HabitoCheckinResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'habito_id' => $this->habito_id,
            'data' => $this->data?->toDateString(),
            'concluida' => $this->concluida,
            'concluida_em' => $this->concluida_em?->toIso8601String(),
            'humor' => $this->humor,
            'nota' => $this->nota,
        ];
    }
}
