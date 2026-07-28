<?php

namespace App\Services;

use App\Models\Habito;
use App\Models\HabitoCheckin;
use App\Models\Perfil;
use App\Models\User;
use App\Support\HabitoCatalog;
use App\Support\MissaoXpCalculator;
use Carbon\Carbon;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class HabitoService
{
    public function journal(User $user, ?string $data = null): array
    {
        $user->ensureDefaults();
        $tz = 'America/Sao_Paulo';
        $dia = $data
            ? Carbon::parse($data, $tz)->toDateString()
            : now($tz)->toDateString();

        $isoDia = (int) Carbon::parse($dia, $tz)->dayOfWeekIso; // 1=seg … 7=dom

        $habitos = Habito::query()
            ->where('user_id', $user->id)
            ->where('ativo', true)
            ->orderBy('ordem')
            ->orderBy('id')
            ->get()
            ->filter(fn (Habito $h) => $this->valeParaDia($h, $isoDia))
            ->values();

        $checkins = HabitoCheckin::query()
            ->where('user_id', $user->id)
            ->whereDate('data', $dia)
            ->get()
            ->keyBy('habito_id');

        $itens = $habitos->map(function (Habito $h) use ($checkins) {
            /** @var HabitoCheckin|null $c */
            $c = $checkins->get($h->id);

            return [
                'habito' => $h,
                'checkin' => $c,
                'concluida' => (bool) ($c?->concluida),
                'streak' => $this->streakHabito($h),
            ];
        });

        $concluidos = $itens->where('concluida', true)->count();
        $total = $itens->count();

        return [
            'data' => $dia,
            'hoje' => now($tz)->toDateString(),
            'resumo' => [
                'concluidos' => $concluidos,
                'total' => $total,
                'percentual' => $total > 0 ? (int) round(($concluidos / $total) * 100) : 0,
                'streak_geral' => $this->streakGeral($user),
                'xp_hoje' => $itens
                    ->filter(fn ($i) => $i['concluida'])
                    ->sum(fn ($i) => (int) $i['habito']->xp),
            ],
            'semana' => $this->semanaHeatmap($user, $dia),
            'itens' => $itens->values()->all(),
            'sugestoes' => HabitoCatalog::sugestoes(),
            'areas' => HabitoCatalog::areas(),
        ];
    }

    public function resumoHoje(User $user): array
    {
        $data = $this->journal($user);

        return [
            'concluidos' => $data['resumo']['concluidos'],
            'total' => $data['resumo']['total'],
            'streak_geral' => $data['resumo']['streak_geral'],
            'percentual' => $data['resumo']['percentual'],
        ];
    }

    /**
     * @param  array{titulo: string, detalhe?: string|null, icone?: string|null, area?: string|null, frequencia?: string|null, dias_semana?: array|null}  $dados
     */
    public function criar(User $user, array $dados): Habito
    {
        $user->ensureDefaults();
        /** @var Perfil $perfil */
        $perfil = $user->perfil()->firstOrFail();

        $ordem = (int) Habito::query()->where('user_id', $user->id)->max('ordem');

        $area = $dados['area'] ?? 'geral';
        if (! in_array($area, HabitoCatalog::areas(), true)) {
            $area = 'geral';
        }

        $xp = MissaoXpCalculator::calcularXp(
            (int) $perfil->xp_proximo_nivel,
            MissaoXpCalculator::estimarPeso($dados['titulo'] ?? null, $dados['detalhe'] ?? null),
            false,
        );

        $clientUuid = $dados['client_uuid'] ?? null;
        if (is_string($clientUuid) && $clientUuid !== '') {
            $existente = Habito::query()
                ->where('user_id', $user->id)
                ->where('client_uuid', $clientUuid)
                ->first();
            if ($existente) {
                return $existente;
            }
        }

        return Habito::query()->create([
            'user_id' => $user->id,
            'icone' => $dados['icone'] ?? '✨',
            'titulo' => $dados['titulo'],
            'detalhe' => $dados['detalhe'] ?? null,
            'area' => $area,
            'frequencia' => ($dados['frequencia'] ?? 'diario') === 'semanal' ? 'semanal' : 'diario',
            'dias_semana' => $dados['dias_semana'] ?? null,
            'xp' => $xp,
            'ativo' => true,
            'ordem' => $ordem + 1,
            'client_uuid' => $clientUuid,
        ]);
    }

    public function atualizar(User $user, int $id, array $dados): Habito
    {
        $habito = $this->buscar($user, $id);

        $payload = array_filter([
            'icone' => $dados['icone'] ?? null,
            'titulo' => $dados['titulo'] ?? null,
            'detalhe' => array_key_exists('detalhe', $dados) ? $dados['detalhe'] : null,
            'area' => isset($dados['area']) && in_array($dados['area'], HabitoCatalog::areas(), true)
                ? $dados['area']
                : null,
            'frequencia' => isset($dados['frequencia'])
                ? (($dados['frequencia'] === 'semanal') ? 'semanal' : 'diario')
                : null,
            'dias_semana' => array_key_exists('dias_semana', $dados) ? $dados['dias_semana'] : null,
            'ativo' => array_key_exists('ativo', $dados) ? (bool) $dados['ativo'] : null,
        ], fn ($v) => $v !== null);

        if (array_key_exists('detalhe', $dados) && $dados['detalhe'] === null) {
            $payload['detalhe'] = null;
        }

        $habito->update($payload);

        return $habito->fresh();
    }

    public function excluir(User $user, int $id): void
    {
        $habito = $this->buscar($user, $id);
        $habito->update(['ativo' => false]);
    }

    /**
     * @param  array{data?: string|null, humor?: int|null, nota?: string|null}  $dados
     */
    public function toggleCheckin(User $user, int $habitoId, array $dados = []): array
    {
        $user->ensureDefaults();
        $habito = $this->buscar($user, $habitoId);
        $tz = 'America/Sao_Paulo';
        $dia = ! empty($dados['data'])
            ? Carbon::parse($dados['data'], $tz)->toDateString()
            : now($tz)->toDateString();

        $checkin = HabitoCheckin::query()->firstOrNew([
            'user_id' => $user->id,
            'habito_id' => $habito->id,
            'data' => $dia,
        ]);

        $eraConcluida = (bool) $checkin->concluida;
        $nova = array_key_exists('concluida', $dados) && $dados['concluida'] !== null
            ? (bool) $dados['concluida']
            : ! $eraConcluida;

        // Idempotente para sync offline.
        if ($eraConcluida === $nova && $checkin->exists) {
            if (array_key_exists('humor', $dados) && $dados['humor'] !== null) {
                $checkin->humor = max(1, min(5, (int) $dados['humor']));
            }
            if (array_key_exists('nota', $dados)) {
                $checkin->nota = $dados['nota'];
            }
            if ($checkin->isDirty()) {
                $checkin->save();
            }

            return [
                'habito' => $habito->fresh(),
                'checkin' => $checkin->fresh(),
                'concluida' => $nova,
                'streak' => $this->streakHabito($habito->fresh()),
                'bonus_dia' => 0,
            ];
        }

        $checkin->concluida = $nova;
        $checkin->concluida_em = $nova ? now() : null;

        if (array_key_exists('humor', $dados) && $dados['humor'] !== null) {
            $checkin->humor = max(1, min(5, (int) $dados['humor']));
        }
        if (array_key_exists('nota', $dados)) {
            $checkin->nota = $dados['nota'];
        }

        $checkin->save();

        $this->ajustarXp($user, (int) $habito->xp, $nova);
        $bonus = $this->avaliarDiaCompleto($user, $dia, $nova);

        return [
            'habito' => $habito->fresh(),
            'checkin' => $checkin->fresh(),
            'concluida' => $nova,
            'streak' => $this->streakHabito($habito->fresh()),
            'bonus_dia' => $bonus,
        ];
    }

    public function atualizarNota(User $user, int $habitoId, array $dados): HabitoCheckin
    {
        $habito = $this->buscar($user, $habitoId);
        $tz = 'America/Sao_Paulo';
        $dia = ! empty($dados['data'])
            ? Carbon::parse($dados['data'], $tz)->toDateString()
            : now($tz)->toDateString();

        $checkin = HabitoCheckin::query()->firstOrCreate(
            [
                'user_id' => $user->id,
                'habito_id' => $habito->id,
                'data' => $dia,
            ],
            [
                'concluida' => false,
                'concluida_em' => null,
            ],
        );

        if (array_key_exists('nota', $dados)) {
            $checkin->nota = $dados['nota'];
        }
        if (array_key_exists('humor', $dados) && $dados['humor'] !== null) {
            $checkin->humor = max(1, min(5, (int) $dados['humor']));
        }
        $checkin->save();

        return $checkin->fresh();
    }

    private function buscar(User $user, int $id): Habito
    {
        $habito = Habito::query()
            ->where('user_id', $user->id)
            ->where('ativo', true)
            ->find($id);

        if (! $habito) {
            throw new NotFoundHttpException('Hábito não encontrado.');
        }

        return $habito;
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

    private function streakHabito(Habito $habito): int
    {
        $tz = 'America/Sao_Paulo';
        $cursor = now($tz)->startOfDay();
        $streak = 0;

        for ($i = 0; $i < 365; $i++) {
            $iso = (int) $cursor->dayOfWeekIso;
            if (! $this->valeParaDia($habito, $iso)) {
                $cursor->subDay();
                continue;
            }

            $ok = HabitoCheckin::query()
                ->where('habito_id', $habito->id)
                ->whereDate('data', $cursor->toDateString())
                ->where('concluida', true)
                ->exists();

            if (! $ok) {
                break;
            }

            $streak++;
            $cursor->subDay();
        }

        return $streak;
    }

    private function streakGeral(User $user): int
    {
        $tz = 'America/Sao_Paulo';
        $cursor = now($tz)->startOfDay();
        $streak = 0;

        for ($i = 0; $i < 365; $i++) {
            $dia = $cursor->toDateString();
            $iso = (int) $cursor->dayOfWeekIso;

            $habitos = Habito::query()
                ->where('user_id', $user->id)
                ->where('ativo', true)
                ->get()
                ->filter(fn (Habito $h) => $this->valeParaDia($h, $iso));

            if ($habitos->isEmpty()) {
                break;
            }

            $ids = $habitos->pluck('id');
            $feitos = HabitoCheckin::query()
                ->where('user_id', $user->id)
                ->whereDate('data', $dia)
                ->where('concluida', true)
                ->whereIn('habito_id', $ids)
                ->count();

            if ($feitos < $habitos->count()) {
                // Se ainda é hoje e incompleto, não quebra streak passado — só para dias anteriores.
                if ($dia === now($tz)->toDateString()) {
                    $cursor->subDay();
                    continue;
                }
                break;
            }

            $streak++;
            $cursor->subDay();
        }

        return $streak;
    }

    /**
     * @return list<array{data: string, label: string, concluidos: int, total: int, percentual: int}>
     */
    private function semanaHeatmap(User $user, string $centro): array
    {
        $tz = 'America/Sao_Paulo';
        $base = Carbon::parse($centro, $tz)->startOfDay();
        $inicio = $base->copy()->subDays(6);
        $out = [];

        for ($i = 0; $i < 7; $i++) {
            $d = $inicio->copy()->addDays($i);
            $dia = $d->toDateString();
            $iso = (int) $d->dayOfWeekIso;

            $habitos = Habito::query()
                ->where('user_id', $user->id)
                ->where('ativo', true)
                ->get()
                ->filter(fn (Habito $h) => $this->valeParaDia($h, $iso));

            $total = $habitos->count();
            $concluidos = 0;
            if ($total > 0) {
                $concluidos = HabitoCheckin::query()
                    ->where('user_id', $user->id)
                    ->whereDate('data', $dia)
                    ->where('concluida', true)
                    ->whereIn('habito_id', $habitos->pluck('id'))
                    ->count();
            }

            $out[] = [
                'data' => $dia,
                'label' => $d->locale('pt_BR')->isoFormat('ddd'),
                'concluidos' => $concluidos,
                'total' => $total,
                'percentual' => $total > 0 ? (int) round(($concluidos / $total) * 100) : 0,
            ];
        }

        return $out;
    }

    private function ajustarXp(User $user, int $xpHabito, bool $concluiu): void
    {
        /** @var Perfil|null $perfil */
        $perfil = $user->perfil()->first();
        if (! $perfil) {
            return;
        }

        $delta = $concluiu ? $xpHabito : -$xpHabito;
        $xp = max(0, $perfil->xp_atual + $delta);

        while ($xp >= $perfil->xp_proximo_nivel) {
            $xp -= $perfil->xp_proximo_nivel;
            $perfil->nivel += 1;
            $perfil->xp_proximo_nivel = (int) round($perfil->xp_proximo_nivel * 1.25);
        }

        $perfil->xp_atual = $xp;
        $perfil->save();
    }

    /**
     * Bônus quando o dia fica 100% completo: +moedas e atualiza streak_dias.
     *
     * @return array{completo: bool, moedas: int, streak_dias: int}|null
     */
    private function avaliarDiaCompleto(User $user, string $dia, bool $acabouDeConcluir): ?array
    {
        $journal = $this->journal($user, $dia);
        $total = $journal['resumo']['total'];
        $concluidos = $journal['resumo']['concluidos'];

        if ($total === 0 || $concluidos < $total) {
            return null;
        }

        /** @var Perfil|null $perfil */
        $perfil = $user->perfil()->first();
        if (! $perfil) {
            return null;
        }

        $moedas = 0;
        if ($acabouDeConcluir) {
            $moedas = 10 + ($total * 2);
            $perfil->moedas += $moedas;
        }

        $streak = $this->streakGeral($user);
        $perfil->streak_dias = max((int) $perfil->streak_dias, $streak);
        $perfil->save();

        return [
            'completo' => true,
            'moedas' => $moedas,
            'streak_dias' => (int) $perfil->streak_dias,
        ];
    }
}
