<?php

namespace App\Http\Resources;

use App\Support\FinancasCatalog;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class FinancasTransacaoResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $meta = $this->tipo === 'receita'
            ? FinancasCatalog::categoriaReceita()
            : (FinancasCatalog::categoriasDespesa()[$this->categoria] ?? FinancasCatalog::categoriasDespesa()['outros']);

        return [
            'id' => $this->id,
            'tipo' => $this->tipo,
            'categoria' => $this->categoria,
            'categoria_nome' => $meta['nome'],
            'categoria_cor' => $meta['cor'],
            'titulo' => $this->titulo,
            'icone' => $this->icone,
            'valor_centavos' => $this->valor_centavos,
            'data' => $this->data?->toDateString(),
        ];
    }
}
