<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * Factory usada para gerar usuários de teste.
 *
 * @extends Factory<\App\Models\Usuario>
 */
class UsuarioFactory extends Factory
{
    /**
     * Define os valores padrão do model.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'nome' => fake()->name(),
            'email' => fake()->unique()->safeEmail(),
            'email_verificado_em' => now(),
            'senha' => Hash::make('senha123'),
            'remember_token' => Str::random(10),
        ];
    }
}
