<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AcademiaTreinoApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_cria_inicia_e_conclui_treino(): void
    {
        $user = User::factory()->create();
        $user->ensureDefaults();
        Sanctum::actingAs($user);

        $catalogo = $this->getJson('/api/v1/academia/exercicios?grupo=Peito')
            ->assertOk()
            ->json('data.exercicios');

        $this->assertNotEmpty($catalogo);

        $payload = [
            'foco' => 'Peito',
            'titulo' => 'Peito pesado',
            'minutos' => 45,
            'exercicios' => [
                [
                    'exercicio_chave' => $catalogo[0]['chave'],
                    'series' => 4,
                    'reps' => 10,
                    'carga_kg' => 40,
                ],
                [
                    'exercicio_chave' => $catalogo[1]['chave'] ?? $catalogo[0]['chave'],
                    'series' => 3,
                    'reps' => 12,
                    'carga_kg' => 20,
                ],
            ],
        ];

        $criar = $this->postJson('/api/v1/academia/treinos', $payload)
            ->assertCreated()
            ->json('data');

        $this->assertSame('Peito', $criar['foco']);
        $this->assertCount(2, $criar['itens']);
        $this->assertTrue($criar['ativo']);

        $academia = $this->getJson('/api/v1/academia')->assertOk()->json('data');
        $this->assertNotNull($academia['treino_hoje']);
        $this->assertSame($criar['id'], $academia['treino_hoje']['id']);
        $this->assertCount(2, $academia['treino_hoje']['itens']);

        $itemId = $criar['itens'][0]['id'];
        $this->patchJson("/api/v1/academia/treinos/{$criar['id']}/exercicios/{$itemId}/toggle")
            ->assertOk()
            ->assertJsonPath('data.concluido', true);

        $concluir = $this->postJson("/api/v1/academia/treinos/{$criar['id']}/concluir")
            ->assertOk()
            ->json('data');

        $this->assertNotNull($concluir['concluido_em']);
        $this->assertFalse($concluir['ativo']);
        $this->assertGreaterThan(0, $concluir['volume_kg']);

        $historico = $this->getJson('/api/v1/academia/treinos/historico')
            ->assertOk()
            ->json('data');

        $this->assertNotEmpty($historico);
    }
}
