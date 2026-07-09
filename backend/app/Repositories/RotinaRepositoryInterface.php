<?php

namespace App\Repositories;

use App\Models\Rotina;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Collection;

interface RotinaRepositoryInterface
{
    public function all(): Collection;

    public function paginate(int $perPage = 15): LengthAwarePaginator;

    public function find(int $id): ?Rotina;

    public function create(array $data): Rotina;

    public function update(Rotina $rotina, array $data): Rotina;

    public function delete(Rotina $rotina): bool;
}
