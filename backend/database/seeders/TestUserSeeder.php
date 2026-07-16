<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class TestUserSeeder extends Seeder
{
    public function run(): void
    {
        $user = User::query()->updateOrCreate(
            ['email' => 'davy@teste.com'],
            [
                'name' => 'Davy Teste',
                'password' => 'senha123',
            ],
        );

        $user->ensureDefaults();
    }
}
