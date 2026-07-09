<?php

namespace Tests\Feature;

use App\Models\Rotina;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class RotinaApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_can_list_rotinas(): void
    {
        Rotina::factory()->count(3)->create();

        $response = $this->getJson('/api/v1/rotinas');

        $response
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonCount(3, 'data');
    }

    public function test_can_create_rotina(): void
    {
        $payload = [
            'titulo' => 'Academia',
            'descricao' => 'Treino de pernas',
            'concluida' => false,
        ];

        $response = $this->postJson('/api/v1/rotinas', $payload);

        $response
            ->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.titulo', 'Academia');

        $this->assertDatabaseHas('rotinas', ['titulo' => 'Academia']);
    }

    public function test_validation_error_returns_standard_format(): void
    {
        $response = $this->postJson('/api/v1/rotinas', []);

        $response
            ->assertUnprocessable()
            ->assertJsonPath('success', false)
            ->assertJsonStructure([
                'success',
                'message',
                'errors' => ['titulo'],
            ]);
    }

    public function test_can_show_rotina(): void
    {
        $rotina = Rotina::factory()->create();

        $response = $this->getJson("/api/v1/rotinas/{$rotina->id}");

        $response
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.id', $rotina->id);
    }

    public function test_can_update_rotina(): void
    {
        $rotina = Rotina::factory()->create(['titulo' => 'Antiga']);

        $response = $this->putJson("/api/v1/rotinas/{$rotina->id}", [
            'titulo' => 'Atualizada',
        ]);

        $response
            ->assertOk()
            ->assertJsonPath('data.titulo', 'Atualizada');
    }

    public function test_can_delete_rotina(): void
    {
        $rotina = Rotina::factory()->create();

        $response = $this->deleteJson("/api/v1/rotinas/{$rotina->id}");

        $response
            ->assertOk()
            ->assertJsonPath('success', true);

        $this->assertDatabaseMissing('rotinas', ['id' => $rotina->id]);
    }

    public function test_not_found_returns_standard_format(): void
    {
        $response = $this->getJson('/api/v1/rotinas/999');

        $response
            ->assertNotFound()
            ->assertJsonPath('success', false);
    }
}
