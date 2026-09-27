<?php

namespace Database\Seeders;

use App\Models\Usuario;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Cria um usuário de teste para facilitar o desenvolvimento local.
     */
    public function run(): void
    {
        Usuario::factory()->create([
            'nome' => 'Usuário de Teste',
            'email' => 'teste@rotinaplus.com',
            'senha' => Hash::make('senha123'),
        ]);
    }
}
