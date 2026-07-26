<?php

namespace App\Services;

use App\Models\Amizade;
use App\Models\Notificacao;
use App\Models\Perfil;
use App\Models\User;
use App\Support\CodigoAmigoHelper;
use Illuminate\Support\Collection;
use Illuminate\Validation\ValidationException;

class AmigoService
{
    public const STATUS_PENDENTE = 'pendente';

    public const STATUS_ACEITO = 'aceito';

    public const STATUS_RECUSADO = 'recusado';

    /** @return Collection<int, User> */
    public function listar(User $user): Collection
    {
        $user->ensureDefaults();

        $ids = Amizade::query()
            ->where('status', self::STATUS_ACEITO)
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

    /**
     * Envia solicitação de amizade pelo código.
     *
     * @return array{amizade: Amizade, notificacao: Notificacao}
     */
    public function convidarPorCodigo(User $user, string $codigoRaw): array
    {
        $user->ensureDefaults();
        $codigo = CodigoAmigoHelper::normalizar($codigoRaw);

        if (! CodigoAmigoHelper::validarFormato($codigo)) {
            throw ValidationException::withMessages([
                'codigo' => ['Informe um código válido (6 caracteres).'],
            ]);
        }

        $perfil = Perfil::query()->where('codigo_amigo', $codigo)->first();
        if (! $perfil?->user) {
            throw ValidationException::withMessages([
                'codigo' => ['Nenhum herói encontrado com esse código.'],
            ]);
        }

        $destino = $perfil->user;
        if ($destino->id === $user->id) {
            throw ValidationException::withMessages([
                'codigo' => ['Você não pode adicionar a si mesmo.'],
            ]);
        }

        if ($this->temAmizadeAceita($user->id, $destino->id)) {
            throw ValidationException::withMessages([
                'codigo' => ['Vocês já são amigos.'],
            ]);
        }

        $pendente = $this->buscarPendente($user->id, $destino->id);
        if ($pendente) {
            throw ValidationException::withMessages([
                'codigo' => ['Já existe uma solicitação pendente.'],
            ]);
        }

        $amizade = Amizade::query()->create([
            'user_id' => $user->id,
            'amigo_id' => $destino->id,
            'status' => self::STATUS_PENDENTE,
        ]);

        $nome = $user->perfil?->nome_heroi ?: $user->name;
        $notificacao = Notificacao::query()->create([
            'user_id' => $destino->id,
            'icone' => '🤝',
            'titulo' => 'Pedido de amizade',
            'mensagem' => "{$nome} quer ser seu amigo.",
            'tipo' => 'convite_amigo',
            'referencia_id' => $amizade->id,
            'payload' => [
                'amizade_id' => $amizade->id,
                'de_user_id' => $user->id,
                'de_nome' => $nome,
                'de_codigo' => $user->perfil?->codigo_amigo,
            ],
            'lida' => false,
        ]);

        return [
            'amizade' => $amizade,
            'notificacao' => $notificacao,
        ];
    }

    public function aceitar(User $user, int $amizadeId): Amizade
    {
        $amizade = $this->amizadeParaDestino($user, $amizadeId);

        if ($amizade->status === self::STATUS_ACEITO) {
            return $amizade;
        }

        if ($amizade->status !== self::STATUS_PENDENTE) {
            throw ValidationException::withMessages([
                'amizade' => ['Esta solicitação não pode ser aceita.'],
            ]);
        }

        $amizade->update(['status' => self::STATUS_ACEITO]);
        $this->marcarNotificacoesDaAmizade($amizade->id, $user->id);

        $solicitante = User::query()->find($amizade->user_id);
        if ($solicitante) {
            $nome = $user->perfil?->nome_heroi ?: $user->name;
            Notificacao::query()->create([
                'user_id' => $solicitante->id,
                'icone' => '🎉',
                'titulo' => 'Amizade aceita',
                'mensagem' => "{$nome} aceitou seu pedido de amizade.",
                'tipo' => 'amigo_aceito',
                'referencia_id' => $amizade->id,
                'payload' => [
                    'amizade_id' => $amizade->id,
                    'amigo_user_id' => $user->id,
                ],
                'lida' => false,
            ]);
        }

        return $amizade->fresh();
    }

    public function recusar(User $user, int $amizadeId): void
    {
        $amizade = $this->amizadeParaDestino($user, $amizadeId);

        if ($amizade->status === self::STATUS_RECUSADO) {
            $this->marcarNotificacoesDaAmizade($amizade->id, $user->id);

            return;
        }

        if ($amizade->status !== self::STATUS_PENDENTE) {
            throw ValidationException::withMessages([
                'amizade' => ['Esta solicitação não pode ser recusada.'],
            ]);
        }

        $amizade->update(['status' => self::STATUS_RECUSADO]);
        $this->marcarNotificacoesDaAmizade($amizade->id, $user->id);
    }

    public function remover(User $user, int $amigoId): void
    {
        $deleted = Amizade::query()
            ->where('status', self::STATUS_ACEITO)
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

    private function amizadeParaDestino(User $user, int $amizadeId): Amizade
    {
        $amizade = Amizade::query()->find($amizadeId);
        if (! $amizade || (int) $amizade->amigo_id !== (int) $user->id) {
            throw ValidationException::withMessages([
                'amizade' => ['Solicitação não encontrada.'],
            ]);
        }

        return $amizade;
    }

    private function marcarNotificacoesDaAmizade(int $amizadeId, int $userId): void
    {
        Notificacao::query()
            ->where('user_id', $userId)
            ->where('tipo', 'convite_amigo')
            ->where('referencia_id', $amizadeId)
            ->where('lida', false)
            ->update([
                'lida' => true,
                'lida_em' => now(),
            ]);
    }

    private function temAmizadeAceita(int $a, int $b): bool
    {
        return Amizade::query()
            ->where('status', self::STATUS_ACEITO)
            ->where(function ($q) use ($a, $b) {
                $q->where(function ($q2) use ($a, $b) {
                    $q2->where('user_id', $a)->where('amigo_id', $b);
                })->orWhere(function ($q2) use ($a, $b) {
                    $q2->where('user_id', $b)->where('amigo_id', $a);
                });
            })
            ->exists();
    }

    private function buscarPendente(int $a, int $b): ?Amizade
    {
        return Amizade::query()
            ->where('status', self::STATUS_PENDENTE)
            ->where(function ($q) use ($a, $b) {
                $q->where(function ($q2) use ($a, $b) {
                    $q2->where('user_id', $a)->where('amigo_id', $b);
                })->orWhere(function ($q2) use ($a, $b) {
                    $q2->where('user_id', $b)->where('amigo_id', $a);
                });
            })
            ->first();
    }
}
