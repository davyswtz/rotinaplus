<?php

namespace App\Http\Resources;

use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class NotificacaoResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'icone' => $this->icone,
            'titulo' => $this->titulo,
            'mensagem' => $this->mensagem,
            'lida' => $this->lida,
            'quando' => $this->formatQuando($this->created_at),
            'created_at' => $this->created_at?->toISOString(),
        ];
    }

    private function formatQuando(?Carbon $at): string
    {
        if (! $at) {
            return '';
        }

        $diff = $at->diffInMinutes(now());
        if ($diff < 5) {
            return 'Agora';
        }
        if ($diff < 60) {
            return $diff.'min atrás';
        }
        if ($diff < 1440) {
            return (int) floor($diff / 60).'h atrás';
        }

        return 'Ontem';
    }
}
