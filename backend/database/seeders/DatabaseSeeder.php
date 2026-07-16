<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

/**
 * Prepara o banco local/dev com usuário de teste e defaults estruturais.
 * Não insere dados financeiros, notificações ou progresso fictícios —
 * missões do dia e semana de academia são criados sob demanda pelos services.
 */
class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    public function run(): void
    {
        $this->call([
            TestUserSeeder::class,
        ]);
    }
}
