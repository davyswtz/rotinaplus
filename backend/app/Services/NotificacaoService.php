<?php

namespace App\Services;

use App\Models\Notificacao;
use App\Models\User;
use Illuminate\Database\Eloquent\Collection;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class NotificacaoService
{
    public function list(User $user): Collection
    {
        return Notificacao::query()
            ->where('user_id', $user->id)
            ->latest()
            ->get();
    }

    public function marcarLida(User $user, int $id): Notificacao
    {
        $item = Notificacao::query()
            ->where('user_id', $user->id)
            ->find($id);

        if (! $item) {
            throw new NotFoundHttpException('Notificação não encontrada.');
        }

        if (! $item->lida) {
            $item->update([
                'lida' => true,
                'lida_em' => now(),
            ]);
        }

        return $item->fresh();
    }

    public function lerTodas(User $user): int
    {
        return Notificacao::query()
            ->where('user_id', $user->id)
            ->where('lida', false)
            ->update([
                'lida' => true,
                'lida_em' => now(),
            ]);
    }
}
