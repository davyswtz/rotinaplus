<?php

namespace App\Services;

use App\Models\AcademiaDia;
use App\Models\AcademiaEsporteSessao;
use App\Models\AcademiaTreino;
use App\Models\Habito;
use App\Models\HabitoCheckin;
use App\Models\Missao;
use App\Models\User;
use App\Support\AcademiaCatalog;
use App\Support\SemanaHelper;
use Carbon\Carbon;
use Carbon\CarbonPeriod;

class PerfilStatsService
{
    /**
     * @return array<string, mixed>
     */
    public function forUser(User $user, string $periodo = 'semana'): array
    {
        $user->ensureDefaults();
        $user->loadMissing('perfil', 'academiaConfig');

        $tz = 'America/Sao_Paulo';
        $hoje = now($tz)->startOfDay();
        $dias = $periodo === 'mes' ? 30 : 7;
        $inicio = $hoje->copy()->subDays($dias - 1);
        $fim = $hoje->copy();

        $serie = [];
        $totaisAcertos = 0;
        $totaisFalhas = 0;
        $totaisXp = 0;
        $diasCompletos = 0;

        $area = [
            'missoes' => ['acertos' => 0, 'falhas' => 0],
            'habitos' => ['acertos' => 0, 'falhas' => 0],
            'academia' => ['acertos' => 0, 'falhas' => 0],
            'esportes' => ['sessoes' => 0, 'minutos' => 0, 'xp' => 0],
        ];

        $missoes = Missao::query()
            ->where('user_id', $user->id)
            ->whereDate('data', '>=', $inicio->toDateString())
            ->whereDate('data', '<=', $fim->toDateString())
            ->get()
            ->groupBy(fn ($m) => Carbon::parse($m->data)->toDateString());

        $habitos = Habito::query()
            ->where('user_id', $user->id)
            ->where('ativo', true)
            ->get();

        $checkins = HabitoCheckin::query()
            ->where('user_id', $user->id)
            ->whereDate('data', '>=', $inicio->toDateString())
            ->whereDate('data', '<=', $fim->toDateString())
            ->get()
            ->groupBy(fn ($c) => Carbon::parse($c->data)->toDateString());

        $semanaInicioMin = SemanaHelper::inicioAtual()
            ->copy()
            ->subWeeks(5)
            ->toDateString();

        $diasAcademia = AcademiaDia::query()
            ->where('user_id', $user->id)
            ->whereDate('semana_inicio', '>=', $semanaInicioMin)
            ->get();

        $esportes = AcademiaEsporteSessao::query()
            ->where('user_id', $user->id)
            ->whereDate('data', '>=', $inicio->toDateString())
            ->whereDate('data', '<=', $fim->toDateString())
            ->get()
            ->groupBy(fn ($s) => Carbon::parse($s->data)->toDateString());

        $treinos = AcademiaTreino::query()
            ->where('user_id', $user->id)
            ->whereNotNull('concluido_em')
            ->where('concluido_em', '>=', $inicio->copy()->startOfDay())
            ->where('concluido_em', '<=', $fim->copy()->endOfDay())
            ->get()
            ->groupBy(fn ($t) => Carbon::parse($t->concluido_em)->timezone($tz)->toDateString());

        foreach (CarbonPeriod::create($inicio, $fim) as $carbon) {
            /** @var Carbon $carbon */
            $data = $carbon->toDateString();
            $iso = (int) $carbon->dayOfWeekIso;
            $ehPassadoOuHoje = $carbon->lte($hoje);

            $mDia = $missoes->get($data, collect());
            $mAcertos = $mDia->where('concluida', true)->count();
            $mFalhas = $ehPassadoOuHoje ? $mDia->where('concluida', false)->count() : 0;
            $mXp = (int) $mDia->where('concluida', true)->sum('xp');

            $hEsperados = $habitos->filter(fn (Habito $h) => $this->valeParaDia($h, $iso));
            $cDia = $checkins->get($data, collect())->keyBy('habito_id');
            $hAcertos = 0;
            $hFalhas = 0;
            $hXp = 0;
            foreach ($hEsperados as $h) {
                $feito = (bool) ($cDia->get($h->id)?->concluida);
                if ($feito) {
                    $hAcertos++;
                    $hXp += (int) $h->xp;
                } elseif ($ehPassadoOuHoje) {
                    $hFalhas++;
                }
            }

            $chave = AcademiaCatalog::chaveDoDiaIso($iso);
            $semanaDoDia = $carbon->copy()->startOfWeek(Carbon::MONDAY)->toDateString();
            $aDia = $diasAcademia->first(fn ($d) => $d->dia_chave === $chave
                && Carbon::parse($d->semana_inicio)->toDateString() === $semanaDoDia);
            $aAcertos = 0;
            $aFalhas = 0;
            if ($aDia && ! $aDia->is_rest) {
                if ($aDia->concluido) {
                    $aAcertos = 1;
                } elseif ($ehPassadoOuHoje && $carbon->lt($hoje)) {
                    $aFalhas = 1;
                }
            }

            $eDia = $esportes->get($data, collect());
            $eSessoes = $eDia->count();
            $eMinutos = (int) $eDia->sum('minutos');
            $eXp = (int) $eDia->sum('xp');

            $tXp = (int) $treinos->get($data, collect())->sum('xp');

            $acertos = $mAcertos + $hAcertos + $aAcertos;
            $falhas = $mFalhas + $hFalhas + $aFalhas;
            $xp = $mXp + $hXp + $eXp + $tXp;
            $total = $acertos + $falhas;
            $taxa = $total > 0 ? (int) round(($acertos / $total) * 100) : 0;

            if ($total > 0 && $falhas === 0 && $acertos > 0) {
                $diasCompletos++;
            }

            $totaisAcertos += $acertos;
            $totaisFalhas += $falhas;
            $totaisXp += $xp;

            $area['missoes']['acertos'] += $mAcertos;
            $area['missoes']['falhas'] += $mFalhas;
            $area['habitos']['acertos'] += $hAcertos;
            $area['habitos']['falhas'] += $hFalhas;
            $area['academia']['acertos'] += $aAcertos;
            $area['academia']['falhas'] += $aFalhas;
            $area['esportes']['sessoes'] += $eSessoes;
            $area['esportes']['minutos'] += $eMinutos;
            $area['esportes']['xp'] += $eXp;

            $labels = [1 => 'seg', 2 => 'ter', 3 => 'qua', 4 => 'qui', 5 => 'sex', 6 => 'sáb', 7 => 'dom'];

            $serie[] = [
                'data' => $data,
                'label' => $labels[$iso] ?? $carbon->format('d/m'),
                'acertos' => $acertos,
                'falhas' => $falhas,
                'taxa' => $taxa,
                'xp' => $xp,
                'por_area' => [
                    'missoes' => ['acertos' => $mAcertos, 'falhas' => $mFalhas],
                    'habitos' => ['acertos' => $hAcertos, 'falhas' => $hFalhas],
                    'academia' => ['acertos' => $aAcertos, 'falhas' => $aFalhas],
                    'esportes' => ['sessoes' => $eSessoes, 'minutos' => $eMinutos],
                ],
            ];
        }

        $totalGeral = $totaisAcertos + $totaisFalhas;

        foreach (['missoes', 'habitos', 'academia'] as $k) {
            $t = $area[$k]['acertos'] + $area[$k]['falhas'];
            $area[$k]['taxa'] = $t > 0
                ? (int) round(($area[$k]['acertos'] / $t) * 100)
                : 0;
        }

        $config = $user->academiaConfig;

        return [
            'periodo' => $periodo === 'mes' ? 'mes' : 'semana',
            'inicio' => $inicio->toDateString(),
            'fim' => $fim->toDateString(),
            'perfil' => $user->perfil,
            'totais' => [
                'acertos' => $totaisAcertos,
                'falhas' => $totaisFalhas,
                'taxa_sucesso' => $totalGeral > 0
                    ? (int) round(($totaisAcertos / $totalGeral) * 100)
                    : 0,
                'xp_ganho' => $totaisXp,
                'dias_completos' => $diasCompletos,
                'streak_atual' => (int) ($user->perfil->streak_dias ?? 0),
                'sequencia_treinos' => (int) ($config?->sequencia_treinos ?? 0),
            ],
            'serie' => $serie,
            'por_area' => $area,
            'nivel' => [
                'atual' => (int) $user->perfil->nivel,
                'xp_atual' => (int) $user->perfil->xp_atual,
                'xp_proximo' => (int) $user->perfil->xp_proximo_nivel,
                'progresso' => $user->perfil->xp_proximo_nivel > 0
                    ? min(1, round($user->perfil->xp_atual / $user->perfil->xp_proximo_nivel, 4))
                    : 0,
                'moedas' => (int) $user->perfil->moedas,
            ],
        ];
    }

    private function valeParaDia(Habito $habito, int $isoDia): bool
    {
        if ($habito->frequencia !== 'semanal') {
            return true;
        }

        $dias = $habito->dias_semana ?? [];
        if (! is_array($dias) || $dias === []) {
            return true;
        }

        return in_array($isoDia, array_map('intval', $dias), true);
    }
}
