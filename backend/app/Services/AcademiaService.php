<?php

namespace App\Services;

use App\Models\AcademiaDia;
use App\Models\Perfil;
use App\Models\User;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class AcademiaService
{
    public function __construct(
        private readonly DashboardService $dashboardService,
    ) {}

    public function show(User $user): array
    {
        return $this->dashboardService->academia($user);
    }

    public function toggleDia(User $user, int $id): AcademiaDia
    {
        $dia = AcademiaDia::query()
            ->where('user_id', $user->id)
            ->find($id);

        if (! $dia) {
            throw new NotFoundHttpException('Dia de treino não encontrado.');
        }

        $novo = ! $dia->concluido;
        $dia->update(['concluido' => $novo]);

        $config = $user->academiaConfig()->first();
        if ($config) {
            $config->sequencia_treinos = max(
                0,
                $config->sequencia_treinos + ($novo ? 1 : -1),
            );
            $config->save();
        }

        return $dia->fresh();
    }

    public function updatePerfil(User $user, array $data): Perfil
    {
        $user->ensureDefaults();
        $perfil = $user->perfil;
        $perfil->update(array_filter(
            $data,
            fn ($v) => $v !== null,
        ));

        return $perfil->fresh();
    }
}
