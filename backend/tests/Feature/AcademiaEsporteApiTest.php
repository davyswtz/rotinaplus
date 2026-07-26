<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AcademiaEsporteApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_lista_esportes_e_registra_sessao(): void
    {
        $user = User::factory()->create();
        $user->ensureDefaults();
        Sanctum::actingAs($user);

        $show = $this->getJson('/api/v1/academia');
        $show->assertOk();
        $this->assertNotEmpty($show->json('data.esportes'));
        $this->assertSame(0, $show->json('data.esporte_resumo.total_semana'));

        $criar = $this->postJson('/api/v1/academia/esportes/sessoes', [
            'esporte_chave' => 'corrida',
            'minutos' => 35,
            'distancia_metros' => 5000,
        ]);
        $criar->assertCreated();
        $this->assertSame('Corrida', $criar->json('data.nome'));
        $this->assertGreaterThan(0, $criar->json('data.xp'));

        $show2 = $this->getJson('/api/v1/academia');
        $this->assertSame(1, $show2->json('data.esporte_resumo.total_semana'));
        $this->assertCount(1, $show2->json('data.esporte_sessoes'));
    }
}
