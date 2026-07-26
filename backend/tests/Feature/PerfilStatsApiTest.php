<?php

namespace Tests\Feature;

use App\Models\Missao;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class PerfilStatsApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_retorna_stats_da_semana(): void
    {
        $user = User::factory()->create();
        $user->ensureDefaults();
        Sanctum::actingAs($user);

        Missao::query()->create([
            'user_id' => $user->id,
            'icone' => '💧',
            'titulo' => 'Beber água',
            'detalhe' => null,
            'xp' => 20,
            'concluida' => true,
            'data' => now('America/Sao_Paulo')->toDateString(),
            'ordem' => 1,
        ]);

        Missao::query()->create([
            'user_id' => $user->id,
            'icone' => '📚',
            'titulo' => 'Estudar',
            'detalhe' => null,
            'xp' => 30,
            'concluida' => false,
            'data' => now('America/Sao_Paulo')->toDateString(),
            'ordem' => 2,
        ]);

        $res = $this->getJson('/api/v1/perfil/stats?periodo=semana')
            ->assertOk()
            ->json('data');

        $this->assertSame('semana', $res['periodo']);
        $this->assertCount(7, $res['serie']);
        $this->assertGreaterThanOrEqual(1, $res['totais']['acertos']);
        $this->assertGreaterThanOrEqual(1, $res['totais']['falhas']);
        $this->assertArrayHasKey('nivel', $res);
        $this->assertArrayHasKey('por_area', $res);
    }
}
