<?php

namespace App\DTOs;

readonly class RotinaDTO
{
    public function __construct(
        public string $titulo,
        public ?string $descricao = null,
        public bool $concluida = false,
    ) {}

    public static function fromArray(array $data): self
    {
        return new self(
            titulo: $data['titulo'],
            descricao: $data['descricao'] ?? null,
            concluida: (bool) ($data['concluida'] ?? false),
        );
    }

    public function toArray(): array
    {
        return [
            'titulo' => $this->titulo,
            'descricao' => $this->descricao,
            'concluida' => $this->concluida,
        ];
    }
}
