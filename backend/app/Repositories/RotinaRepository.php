<?php

namespace App\Repositories;

use App\Models\Rotina;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\Auth;

class RotinaRepository implements RotinaRepositoryInterface
{
    public function __construct(
        private readonly Rotina $model,
    ) {}

    public function all(): Collection
    {
        return $this->query()->latest()->get();
    }

    public function paginate(int $perPage = 15): LengthAwarePaginator
    {
        return $this->query()->latest()->paginate($perPage);
    }

    public function find(int $id): ?Rotina
    {
        return $this->query()->find($id);
    }

    public function create(array $data): Rotina
    {
        $data['user_id'] = Auth::id();

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

    private function query()
    {
        return $this->model->newQuery()->where('user_id', Auth::id());
    }
}
