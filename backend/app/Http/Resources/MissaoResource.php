<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class MissaoResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'icone' => $this->icone,
            'titulo' => $this->titulo,
            'detalhe' => $this->detalhe,
            'xp' => $this->xp,
            'concluida' => $this->concluida,
            'data' => $this->data?->toDateString(),
            'ordem' => $this->ordem,
        ];
    }
}
