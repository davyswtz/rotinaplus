<?php

namespace App\Services;

use App\Models\AcademiaDia;
use App\Models\AcademiaTreino;
use App\Models\AcademiaVolume;
use App\Models\Perfil;
use App\Models\User;
use App\Support\AcademiaCatalog;
use App\Support\SemanaHelper;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class AcademiaService
{
    public function show(User $user): array
    {
        return app(DashboardService::class)->academia($user);
    }

    /**
     * Garante estrutura da semana atual (dias + volumes zerados + treino do dia).
     * Não inventa progresso — tudo começa vazio/não concluído.
     */
    public function ensureSemanaAtual(User $user): void
    {
        $user->ensureDefaults();
        $semana = SemanaHelper::inicioAtual()->toDateString();

        $temDias = AcademiaDia::query()
            ->where('user_id', $user->id)
            ->whereDate('semana_inicio', $semana)
            ->exists();

        if (! $temDias) {
            foreach (AcademiaCatalog::diasSemana() as $dia) {
                AcademiaDia::query()->create([
                    'user_id' => $user->id,
                    'semana_inicio' => $semana,
                    'dia_chave' => $dia['dia_chave'],
                    'label' => $dia['label'],
                    'foco' => $dia['foco'],
                    'is_rest' => $dia['is_rest'],
                    'concluido' => false,
                    'ordem' => $dia['ordem'],
                ]);
            }
        }

        $temVolumes = AcademiaVolume::query()
            ->where('user_id', $user->id)
            ->whereDate('semana_inicio', $semana)
            ->exists();

        if (! $temVolumes) {
            foreach (AcademiaCatalog::diasSemana() as $dia) {
                AcademiaVolume::query()->create([
                    'user_id' => $user->id,
                    'semana_inicio' => $semana,
                    'dia_chave' => $dia['dia_chave'],
                    'label' => $dia['label'],
                    'kg' => 0,
                ]);
            }
        }

        $temTreinoAtivo = AcademiaTreino::query()
            ->where('user_id', $user->id)
            ->where('ativo', true)
            ->exists();

        if (! $temTreinoAtivo) {
            $chaveHoje = AcademiaCatalog::chaveDoDiaIso(
                (int) now('America/Sao_Paulo')->dayOfWeekIso
            );
            $meta = AcademiaCatalog::diaPorChave($chaveHoje) ?? AcademiaCatalog::diasSemana()[0];

            AcademiaTreino::query()
                ->where('user_id', $user->id)
                ->update(['ativo' => false]);

            AcademiaTreino::query()->create([
                'user_id' => $user->id,
                'foco' => $meta['foco'],
                'titulo' => $meta['is_rest']
                    ? 'Dia de descanso'
                    : 'Iniciar treino de '.$meta['foco'],
                'exercicios' => $meta['is_rest'] ? 0 : 8,
                'minutos' => $meta['is_rest'] ? 0 : 45,
                'xp' => $meta['is_rest'] ? 0 : 140,
                'dia_chave' => $meta['dia_chave'],
                'ativo' => true,
            ]);
        }
    }

    public function toggleDia(User $user, int $id): AcademiaDia
    {
        $this->ensureSemanaAtual($user);

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
