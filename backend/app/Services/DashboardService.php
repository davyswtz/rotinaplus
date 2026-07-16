<?php

namespace App\Services;

use App\Models\AcademiaDia;
use App\Models\AcademiaTreino;
use App\Models\AcademiaVolume;
use App\Models\Missao;
use App\Models\Notificacao;
use App\Models\User;
use App\Support\SemanaHelper;

class DashboardService
{
    public function forUser(User $user): array
    {
        $user->ensureDefaults();
        $user->loadMissing('perfil', 'academiaConfig');

        $hoje = now('America/Sao_Paulo')->toDateString();
        $semana = SemanaHelper::inicioAtual()->toDateString();

        $missoes = Missao::query()
            ->where('user_id', $user->id)
            ->whereDate('data', $hoje)
            ->orderBy('ordem')
            ->get();

        $notificacoesNaoLidas = Notificacao::query()
            ->where('user_id', $user->id)
            ->where('lida', false)
            ->count();

        return [
            'perfil' => $user->perfil,
            'missoes' => $missoes,
            'missoes_concluidas' => $missoes->where('concluida', true)->count(),
            'missoes_total' => $missoes->count(),
            'xp_hoje' => $missoes->where('concluida', true)->sum('xp'),
            'notificacoes_nao_lidas' => $notificacoesNaoLidas,
            'academia_resumo' => $this->academiaResumo($user, $semana),
        ];
    }

    public function academia(User $user): array
    {
        $user->ensureDefaults();
        $semana = SemanaHelper::inicioAtual()->toDateString();

        $config = $user->academiaConfig;
        $dias = AcademiaDia::query()
            ->where('user_id', $user->id)
            ->whereDate('semana_inicio', $semana)
            ->orderBy('ordem')
            ->get();

        $volumes = AcademiaVolume::query()
            ->where('user_id', $user->id)
            ->whereDate('semana_inicio', $semana)
            ->orderBy('id')
            ->get();

        $treinoHoje = AcademiaTreino::query()
            ->where('user_id', $user->id)
            ->where('ativo', true)
            ->first();

        $feitos = $dias->where('concluido', true)->count();

        return [
            'meta_semana' => $config?->meta_semana ?? 5,
            'feitos' => $feitos,
            'sequencia_treinos' => $config?->sequencia_treinos ?? 0,
            'dias' => $dias,
            'volumes' => $volumes,
            'treino_hoje' => $treinoHoje,
            'semana_inicio' => $semana,
        ];
    }

    private function academiaResumo(User $user, string $semana): array
    {
        $config = $user->academiaConfig;
        $feitos = AcademiaDia::query()
            ->where('user_id', $user->id)
            ->whereDate('semana_inicio', $semana)
            ->where('concluido', true)
            ->count();

        return [
            'meta_semana' => $config?->meta_semana ?? 5,
            'feitos' => $feitos,
            'sequencia_treinos' => $config?->sequencia_treinos ?? 0,
        ];
    }
}
