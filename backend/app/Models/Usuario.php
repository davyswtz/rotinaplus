<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

/**
 * Representa um usuário do sistema Rotina Plus.
 */
class Usuario extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * Nome da tabela associada ao model (fora do padrão em inglês do Laravel).
     */
    protected $table = 'usuarios';

    /**
     * Atributos que podem ser preenchidos em massa.
     */
    protected $fillable = [
        'nome',
        'email',
        'senha',
    ];

    /**
     * Atributos que devem ser ocultados ao serializar o model (ex: em respostas JSON).
     */
    protected $hidden = [
        'senha',
        'remember_token',
    ];

    /**
     * Conversão de tipos dos atributos.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verificado_em' => 'datetime',
            'senha' => 'hashed',
        ];
    }

    /**
     * Informa ao Laravel qual coluna representa a senha do usuário,
     * já que aqui usamos "senha" em vez de "password".
     */
    public function getAuthPassword(): string
    {
        return $this->senha;
    }

    // ---- Relacionamentos ----

    /** Categorias criadas pelo usuário. */
    public function categorias(): HasMany
    {
        return $this->hasMany(Categoria::class, 'usuario_id');
    }

    /** Tarefas de rotina do usuário. */
    public function tarefas(): HasMany
    {
        return $this->hasMany(Tarefa::class, 'usuario_id');
    }

    /** Hábitos cadastrados pelo usuário. */
    public function habitos(): HasMany
    {
        return $this->hasMany(Habito::class, 'usuario_id');
    }

    /** Metas cadastradas pelo usuário. */
    public function metas(): HasMany
    {
        return $this->hasMany(Meta::class, 'usuario_id');
    }

    /** Registros de humor do usuário. */
    public function registrosHumor(): HasMany
    {
        return $this->hasMany(RegistroHumor::class, 'usuario_id');
    }

    /** Registros de consumo de água do usuário. */
    public function registrosAgua(): HasMany
    {
        return $this->hasMany(RegistroAgua::class, 'usuario_id');
    }

    /** Transações financeiras (receitas e despesas) do usuário. */
    public function transacoes(): HasMany
    {
        return $this->hasMany(Transacao::class, 'usuario_id');
    }

    /** Reflexões semanais do usuário. */
    public function reflexoes(): HasMany
    {
        return $this->hasMany(Reflexao::class, 'usuario_id');
    }
}
