<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class LoginApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_login_returns_user_and_token_with_valid_credentials(): void
    {
        $user = User::factory()->create([
            'email' => 'user@rotinaplus.test',
            'password' => Hash::make('secret123'),
        ]);

        $response = $this->postJson('/api/v1/auth/login', [
            'email' => 'user@rotinaplus.test',
            'password' => 'secret123',
        ]);

        $response
            ->assertOk()
            ->assertJsonStructure([
                'user' => ['id', 'name', 'email'],
                'token',
            ])
            ->assertJsonPath('user.id', $user->id);

        $this->assertNotEmpty($response->json('token'));
    }

    public function test_login_returns_validation_error_with_invalid_credentials(): void
    {
        User::factory()->create([
            'email' => 'user@rotinaplus.test',
            'password' => Hash::make('secret123'),
        ]);

        $response = $this->postJson('/api/v1/auth/login', [
            'email' => 'user@rotinaplus.test',
            'password' => 'wrong-password',
        ]);

        $response
            ->assertUnprocessable()
            ->assertJsonPath('success', false);
    }
}
