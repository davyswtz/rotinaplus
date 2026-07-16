<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\AcademiaResource;
use App\Services\AcademiaService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AcademiaController extends Controller
{
    public function __construct(
        private readonly AcademiaService $academiaService,
    ) {}

    public function show(Request $request): JsonResponse
    {
        $data = $this->academiaService->show($request->user());

        return response()->json([
            'success' => true,
            'data' => new AcademiaResource($data),
        ]);
    }

    public function toggleDia(Request $request, int $id): JsonResponse
    {
        $dia = $this->academiaService->toggleDia($request->user(), $id);

        return response()->json([
            'success' => true,
            'message' => $dia->concluido ? 'Treino marcado como feito.' : 'Treino desmarcado.',
            'data' => [
                'id' => $dia->id,
                'dia_chave' => $dia->dia_chave,
                'label' => $dia->label,
                'foco' => $dia->foco,
                'is_rest' => $dia->is_rest,
                'concluido' => $dia->concluido,
            ],
        ]);
    }
}
