<?php

namespace Database\Factories;

use App\Models\Rotina;
use Illuminate\Database\Eloquent\Factories\Factory;

class RotinaFactory extends Factory
{
    protected $model = Rotina::class;

    public function definition(): array
    {
        return [
            'titulo' => fake()->sentence(3),
            'descricao' => fake()->optional()->paragraph(),
            'concluida' => fake()->boolean(20),
        ];
    }
}
