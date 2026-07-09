<?php

namespace App\Repositories;

use App\Models\Rotina;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Collection;

class RotinaRepository implements RotinaRepositoryInterface
{
    public function __construct(
        private readonly Rotina $model,
    ) {}

    public function all(): Collection
    {
        return $this->model->newQuery()->latest()->get();
    }

    public function paginate(int $perPage = 15): LengthAwarePaginator
    {
        return $this->model->newQuery()->latest()->paginate($perPage);
    }

    public function find(int $id): ?Rotina
    {
        return $this->model->newQuery()->find($id);
    }

    public function create(array $data): Rotina
    {
        return $this->model->newQuery()->create($data);
    }

    public function update(Rotina $rotina, array $data): Rotina
    {
        $rotina->update($data);

        return $rotina->fresh();
    }

    public function delete(Rotina $rotina): bool
    {
        return (bool) $rotina->delete();
    }
}
