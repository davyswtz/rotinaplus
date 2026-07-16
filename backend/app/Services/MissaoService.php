<?php

namespace App\Services;

use App\Models\Missao;
use App\Models\Perfil;
use App\Models\User;
use Carbon\Carbon;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class MissaoService
{
    public function listHoje(User $user): \Illuminate\Database\Eloquent\Collection
    {
        $hoje = now('America/Sao_Paulo')->toDateString();

        return Missao::query()
            ->where('user_id', $user->id)
            ->whereDate('data', $hoje)
            ->orderBy('ordem')
            ->get();
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
