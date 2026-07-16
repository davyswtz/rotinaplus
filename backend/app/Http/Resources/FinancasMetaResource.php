<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class FinancasMetaResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $alvo = max(1, (int) $this->valor_alvo_centavos);
        $atual = (int) $this->valor_atual_centavos;

        return [
            'id' => $this->id,
            'titulo' => $this->titulo,
            'icone' => $this->icone,
            'categoria' => $this->categoria,
            'valor_alvo_centavos' => $alvo,
            'valor_atual_centavos' => $atual,
            'percentual' => min(100, round(($atual / $alvo) * 100, 1)),
        ];
    }
}
