<?php

namespace App\Http\Controllers\Api;

use App\DTOs\RotinaDTO;
use App\Http\Controllers\Controller;
use App\Http\Requests\StoreRotinaRequest;
use App\Http\Requests\UpdateRotinaRequest;
use App\Http\Resources\RotinaResource;
use App\Services\RotinaService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class RotinaController extends Controller
{
    public function __construct(
        private readonly RotinaService $rotinaService,
    ) {}

    public function index(): AnonymousResourceCollection
    {
        $rotinas = $this->rotinaService->list();

        return RotinaResource::collection($rotinas)
            ->additional(['success' => true]);
    }

    public function store(StoreRotinaRequest $request): JsonResponse
    {
        $dto = RotinaDTO::fromArray($request->validated());
        $rotina = $this->rotinaService->create($dto);

        return (new RotinaResource($rotina))
            ->additional(['success' => true, 'message' => 'Rotina criada com sucesso.'])
            ->response()
            ->setStatusCode(201);
    }

    public function show(int $id): RotinaResource
    {
        $rotina = $this->rotinaService->find($id);

        return (new RotinaResource($rotina))
            ->additional(['success' => true]);
    }

    public function update(UpdateRotinaRequest $request, int $id): RotinaResource
    {
        $dto = RotinaDTO::fromArray($request->validated());
        $rotina = $this->rotinaService->update($id, $dto);

        return (new RotinaResource($rotina))
            ->additional(['success' => true, 'message' => 'Rotina atualizada com sucesso.']);
    }

    public function destroy(int $id): JsonResponse
    {
        $this->rotinaService->delete($id);

        return response()->json([
            'success' => true,
            'message' => 'Rotina removida com sucesso.',
            'errors' => (object) [],
        ]);
    }
}
