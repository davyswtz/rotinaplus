<?php

namespace App\Models;

use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

#[Fillable(['name', 'email', 'password', 'last_login_at', 'avatar_url', 'is_active'])]
#[Hidden(['password', 'remember_token'])]
class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, Notifiable, SoftDeletes;

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'last_login_at' => 'datetime',
            'is_active' => 'boolean',
        ];
    }

    public function perfil(): HasOne
    {
        return $this->hasOne(Perfil::class);
    }

    public function oauthProviders(): HasMany
    {
        return $this->hasMany(OauthProvider::class);
    }

    public function missoes(): HasMany
    {
        return $this->hasMany(Missao::class);
    }

    public function notificacoes(): HasMany
    {
        return $this->hasMany(Notificacao::class);
    }

    public function rotinas(): HasMany
    {
        return $this->hasMany(Rotina::class);
    }

    public function academiaConfig(): HasOne
    {
        return $this->hasOne(AcademiaConfig::class);
    }

    public function academiaDias(): HasMany
    {
        return $this->hasMany(AcademiaDia::class);
    }

    public function academiaVolumes(): HasMany
    {
        return $this->hasMany(AcademiaVolume::class);
    }

    public function academiaTreinos(): HasMany
    {
        return $this->hasMany(AcademiaTreino::class);
    }

    /** Garante perfil + config academia mínimos. */
    public function ensureDefaults(): void
    {
        $this->perfil()->firstOrCreate(
            ['user_id' => $this->id],
            [
                'nome_heroi' => $this->name,
                'avatar_key' => 'guara_serio',
                'classe' => 'Sábio',
                'emoji_classe' => '🔮',
                'nivel' => 1,
                'xp_atual' => 0,
                'xp_proximo_nivel' => 500,
                'moedas' => 0,
                'streak_dias' => 0,
            ],
        );

        $this->academiaConfig()->firstOrCreate(
            ['user_id' => $this->id],
            [
                'meta_semana' => 5,
                'sequencia_treinos' => 0,
            ],
        );
    }
}
