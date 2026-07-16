<?php

namespace Tests\Feature;

use App\Models\Missao;
use App\Models\User;
use App\Support\MissaoXpCalculator;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class MissaoApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_dashboard_gera_cinco_missoes_padrao_aleatorias(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        $response = $this->getJson('/api/v1/dashboard');

        $response->assertOk();
        $this->assertCount(5, $response->json('data.missoes'));
        $this->assertDatabaseCount('missoes', 5);
    }

    public function test_store_calcula_xp_e_ignora_xp_do_cliente(): void
    {
        $user = User::factory()->create();
        $user->ensureDefaults();
        Sanctum::actingAs($user);

        // Garante as 5 padrão primeiro
        $this->getJson('/api/v1/dashboard')->assertOk();

        $response = $this->postJson('/api/v1/missoes', [
            'titulo' => 'Ler 20 páginas',
            'detalhe' => 'Livro da semana',
            'icone' => '📖',
            'xp' => 999,
        ]);

        $response
            ->assertCreated()
            ->assertJsonPath('data.titulo', 'Ler 20 páginas');

        $xp = (int) $response->json('data.xp');
        $esperado = MissaoXpCalculator::calcularXp(500, 2, false);
        $this->assertSame($esperado, $xp);
        $this->assertNotSame(999, $xp);
    }

    public function test_nao_duplica_padrao_no_mesmo_dia(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        $this->getJson('/api/v1/dashboard')->assertOk();
        $this->getJson('/api/v1/dashboard')->assertOk();

        $this->assertSame(
            5,
            Missao::query()->where('user_id', $user->id)->count()
        );
    }
}
