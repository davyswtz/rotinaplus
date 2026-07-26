<?php

namespace App\Services;

use App\Models\Amizade;
use App\Models\Perfil;
use App\Models\User;
use App\Support\NickHelper;
use Illuminate\Support\Collection;
use Illuminate\Validation\ValidationException;

class AmigoService
{
    /** @return Collection<int, User> */
    public function listar(User $user): Collection
    {
        $user->ensureDefaults();

        $ids = Amizade::query()
            ->where(function ($q) use ($user) {
                $q->where('user_id', $user->id)
                    ->orWhere('amigo_id', $user->id);
            })
            ->get(['user_id', 'amigo_id'])
            ->map(fn (Amizade $a) => $a->user_id === $user->id ? $a->amigo_id : $a->user_id)
            ->unique()
            ->values();

        if ($ids->isEmpty()) {
            return collect();
        }

        return User::query()
            ->with('perfil')
            ->whereIn('id', $ids)
            ->orderBy('id')
            ->get()
            ->each(fn (User $u) => $u->ensureDefaults());
    }

    public function adicionarPorNick(User $user, string $nickRaw): User
    {
        $user->ensureDefaults();
        $nick = NickHelper::normalizar($nickRaw);

        if (! NickHelper::validarFormato($nick)) {
            throw ValidationException::withMessages([
                'nick' => ['Informe um nick válido (3–32 caracteres: letras, números ou _).'],
            ]);
        }

        $perfil = Perfil::query()->where('nick', $nick)->first();
        if (! $perfil) {
            throw ValidationException::withMessages([
                'nick' => ['Nenhum herói encontrado com esse nick.'],
            ]);
        }

        $amigo = $perfil->user;
        if (! $amigo) {
            throw ValidationException::withMessages([
                'nick' => ['Nenhum herói encontrado com esse nick.'],
            ]);
        }

        if ($amigo->id === $user->id) {
            throw ValidationException::withMessages([
                'nick' => ['Você não pode adicionar a si mesmo.'],
            ]);
        }

        if ($this->jaSaoAmigos($user->id, $amigo->id)) {
            throw ValidationException::withMessages([
                'nick' => ['Vocês já são amigos.'],
            ]);
        }

        Amizade::query()->create([
            'user_id' => $user->id,
            'amigo_id' => $amigo->id,
        ]);

        $amigo->ensureDefaults();
        $amigo->load('perfil');

        return $amigo;
    }

    public function remover(User $user, int $amigoId): void
    {
        $deleted = Amizade::query()
            ->where(function ($q) use ($user, $amigoId) {
                $q->where(function ($q2) use ($user, $amigoId) {
                    $q2->where('user_id', $user->id)->where('amigo_id', $amigoId);
                })->orWhere(function ($q2) use ($user, $amigoId) {
                    $q2->where('user_id', $amigoId)->where('amigo_id', $user->id);
                });
            })
            ->delete();

        if ($deleted === 0) {
            throw ValidationException::withMessages([
                'amigo' => ['Amizade não encontrada.'],
            ]);
        }
    }

    private function jaSaoAmigos(int $a, int $b): bool
    {
        return Amizade::query()
            ->where(function ($q) use ($a, $b) {
                $q->where('user_id', $a)->where('amigo_id', $b);
            })
            ->orWhere(function ($q) use ($a, $b) {
                $q->where('user_id', $b)->where('amigo_id', $a);
            })
            ->exists();
    }
}
