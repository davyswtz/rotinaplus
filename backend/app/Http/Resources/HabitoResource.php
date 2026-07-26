<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class HabitoResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'icone' => $this->icone,
            'titulo' => $this->titulo,
            'detalhe' => $this->detalhe,
            'area' => $this->area,
            'frequencia' => $this->frequencia,
            'dias_semana' => $this->dias_semana,
            'xp' => $this->xp,
            'ativo' => $this->ativo,
            'ordem' => $this->ordem,
        ];
    }
}
