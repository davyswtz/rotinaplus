<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class RegisterApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_register_creates_user_and_returns_token(): void
    {
        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'Novo Herói',
            'email' => 'novo@rotinaplus.test',
            'password' => 'senha12345',
            'password_confirmation' => 'senha12345',
        ]);

        $response
            ->assertCreated()
            ->assertJsonStructure([
                'success',
                'user' => ['id', 'name', 'email'],
                'perfil',
                'token',
            ])
            ->assertJsonPath('user.email', 'novo@rotinaplus.test')
            ->assertJsonPath('user.name', 'Novo Herói');

        $this->assertDatabaseHas('users', [
            'email' => 'novo@rotinaplus.test',
            'name' => 'Novo Herói',
        ]);

        $this->assertNotEmpty($response->json('token'));
        $this->assertDatabaseHas('perfis', [
            'user_id' => $response->json('user.id'),
        ]);
    }

    public function test_register_rejects_duplicate_email(): void
    {
        User::factory()->create([
            'email' => 'existe@rotinaplus.test',
            'password' => Hash::make('senha12345'),
        ]);

        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'Outro',
            'email' => 'existe@rotinaplus.test',
            'password' => 'senha12345',
            'password_confirmation' => 'senha12345',
        ]);

        $response
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['email']);
    }

    public function test_register_rejects_password_mismatch(): void
    {
        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'Novo',
            'email' => 'novo@rotinaplus.test',
            'password' => 'senha12345',
            'password_confirmation' => 'outra-senha',
        ]);

        $response
            ->assertUnprocessable()
            ->assertJsonValidationErrors(['password']);
    }
}
