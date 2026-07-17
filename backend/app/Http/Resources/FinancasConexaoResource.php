<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class FinancasConexaoResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'provider' => $this->provider,
            'item_id' => $this->item_id,
            'connector_name' => $this->connector_name,
            'status' => $this->status,
            'last_sync_at' => $this->last_sync_at?->toIso8601String(),
        ];
    }
}
