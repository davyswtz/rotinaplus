<?php

namespace App\Services;

use App\DTOs\RotinaDTO;
use App\Models\Rotina;
use App\Repositories\RotinaRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Collection;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class RotinaService
{
    public function __construct(
        private readonly RotinaRepositoryInterface $rotinaRepository,
    ) {}

    public function list(): Collection
    {
        return $this->rotinaRepository->all();
    }

    public function paginate(int $perPage = 15): LengthAwarePaginator
    {
        return $this->rotinaRepository->paginate($perPage);
    }

    public function find(int $id): Rotina
    {
        $rotina = $this->rotinaRepository->find($id);

        if (! $rotina) {
            throw new NotFoundHttpException('Rotina não encontrada.');
        }

        return $rotina;
    }

    public function create(RotinaDTO $dto): Rotina
    {
        return $this->rotinaRepository->create($dto->toArray());
    }

    public function update(int $id, RotinaDTO $dto): Rotina
    {
        $rotina = $this->find($id);

        return $this->rotinaRepository->update($rotina, $dto->toArray());
    }

    public function delete(int $id): void
    {
        $rotina = $this->find($id);
        $this->rotinaRepository->delete($rotina);
    }
}
