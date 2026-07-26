<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/** Cartão público de amigo (sem e-mail). */
class AmigoResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $perfil = $this->perfil;

        return [
            'id' => $this->id,
            'codigo_amigo' => $perfil?->codigo_amigo,
            'nome_heroi' => $perfil?->nome_heroi,
            'avatar_key' => $perfil?->avatar_key ?? 'guara_serio',
            'classe' => $perfil?->classe ?? 'Sábio',
            'emoji_classe' => $perfil?->emoji_classe ?? '🔮',
            'nivel' => (int) ($perfil?->nivel ?? 1),
        ];
    }
}
