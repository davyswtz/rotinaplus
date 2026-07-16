<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PerfilResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'nome_heroi' => $this->nome_heroi,
            'avatar_key' => $this->avatar_key,
            'classe' => $this->classe,
            'emoji_classe' => $this->emoji_classe,
            'nivel' => $this->nivel,
            'xp_atual' => $this->xp_atual,
            'xp_proximo_nivel' => $this->xp_proximo_nivel,
            'moedas' => $this->moedas,
            'streak_dias' => $this->streak_dias,
        ];
    }
}
