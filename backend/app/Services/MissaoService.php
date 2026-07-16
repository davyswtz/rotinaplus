<?php

namespace App\Services;

use App\Models\Missao;
use App\Models\Perfil;
use App\Models\User;
use App\Support\MissaoXpCalculator;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class MissaoService
{
    public function listHoje(User $user): \Illuminate\Database\Eloquent\Collection
    {
        $this->ensureMissoesPadraoHoje($user);

        $hoje = now('America/Sao_Paulo')->toDateString();

        return Missao::query()
            ->where('user_id', $user->id)
            ->whereDate('data', $hoje)
            ->orderBy('ordem')
            ->get();
    }

    /**
     * Garante 5 missões padrão aleatórias no dia (se ainda não houver nenhuma).
     */
    public function ensureMissoesPadraoHoje(User $user): void
    {
        $user->ensureDefaults();
        $hoje = now('America/Sao_Paulo')->toDateString();

        $existem = Missao::query()
            ->where('user_id', $user->id)
            ->whereDate('data', $hoje)
            ->exists();

        if ($existem) {
            return;
        }

        /** @var Perfil $perfil */
        $perfil = $user->perfil()->firstOrFail();
        $sorteadas = MissaoXpCalculator::sortearPadrao();

        foreach ($sorteadas as $indice => $item) {
            Missao::query()->create([
                'user_id' => $user->id,
                'data' => $hoje,
                'icone' => $item['icone'],
                'titulo' => $item['titulo'],
                'detalhe' => $item['detalhe'],
                'xp' => MissaoXpCalculator::calcularXp(
                    (int) $perfil->xp_proximo_nivel,
                    $item['peso'],
                    true,
                ),
                'concluida' => false,
                'concluida_em' => null,
                'ordem' => $indice + 1,
            ]);
        }
    }

    public function toggle(User $user, int $id): Missao
    {
        $missao = Missao::query()
            ->where('user_id', $user->id)
            ->find($id);

        if (! $missao) {
            throw new NotFoundHttpException('Missão não encontrada.');
        }

        $nova = ! $missao->concluida;

        $missao->update([
            'concluida' => $nova,
            'concluida_em' => $nova ? now() : null,
        ]);

        $this->ajustarXpPerfil($user, $missao, $nova);

        return $missao->fresh();
    }

    /**
     * Cria missão extra do dia. XP é calculado no servidor (cliente não envia).
     *
     * @param  array{icone?: string, titulo: string, detalhe?: string|null}  $dados
     */
    public function criarHoje(User $user, array $dados): Missao
    {
        $this->ensureMissoesPadraoHoje($user);
        $user->ensureDefaults();

        /** @var Perfil $perfil */
        $perfil = $user->perfil()->firstOrFail();
        $hoje = now('America/Sao_Paulo')->toDateString();

        $ordem = (int) Missao::query()
            ->where('user_id', $user->id)
            ->whereDate('data', $hoje)
            ->max('ordem');

        $peso = MissaoXpCalculator::estimarPeso(
            $dados['titulo'] ?? null,
            $dados['detalhe'] ?? null,
        );

        return Missao::query()->create([
            'user_id' => $user->id,
            'data' => $hoje,
            'icone' => $dados['icone'] ?? '🎯',
            'titulo' => $dados['titulo'],
            'detalhe' => $dados['detalhe'] ?? null,
            'xp' => MissaoXpCalculator::calcularXp(
                (int) $perfil->xp_proximo_nivel,
                $peso,
                false,
            ),
            'concluida' => false,
            'concluida_em' => null,
            'ordem' => $ordem + 1,
        ]);
    }

    private function ajustarXpPerfil(User $user, Missao $missao, bool $concluiu): void
    {
        /** @var Perfil|null $perfil */
        $perfil = $user->perfil()->first();
        if (! $perfil) {
            return;
        }

        $delta = $concluiu ? $missao->xp : -$missao->xp;
        $xp = max(0, $perfil->xp_atual + $delta);

        while ($xp >= $perfil->xp_proximo_nivel) {
            $xp -= $perfil->xp_proximo_nivel;
            $perfil->nivel += 1;
            $perfil->xp_proximo_nivel = (int) round($perfil->xp_proximo_nivel * 1.25);
        }

        $perfil->xp_atual = $xp;
        $perfil->save();
    }
}
