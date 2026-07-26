<?php

namespace Tests\Feature;

use App\Models\Notificacao;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AmigoApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_convite_por_codigo_notifica_e_aceite_vira_amigo(): void
    {
        $eu = User::factory()->create(['name' => 'Davy']);
        $amigo = User::factory()->create(['name' => 'Ana']);
        $eu->ensureDefaults();
        $amigo->ensureDefaults();

        $codigo = $amigo->perfil->codigo_amigo;
        $this->assertNotEmpty($codigo);

        Sanctum::actingAs($eu);
        $convite = $this->postJson('/api/v1/amigos', ['codigo' => $codigo]);
        $convite->assertCreated();
        $amizadeId = (int) $convite->json('data.amizade_id');
        $this->assertSame('pendente', $convite->json('data.status'));

        // Ainda não são amigos
        $this->assertSame(0, $this->getJson('/api/v1/amigos')->json('data.total'));

        // Destino recebe notificação
        Sanctum::actingAs($amigo);
        $notifs = $this->getJson('/api/v1/notificacoes');
        $notifs->assertOk();
        $this->assertSame('convite_amigo', $notifs->json('data.0.tipo'));
        $this->assertSame($amizadeId, (int) $notifs->json('data.0.referencia_id'));

        $aceitar = $this->postJson("/api/v1/amigos/{$amizadeId}/aceitar");
        $aceitar->assertOk();
        $this->assertSame($eu->perfil->codigo_amigo, $aceitar->json('data.codigo_amigo'));

        $this->assertSame(1, $this->getJson('/api/v1/amigos')->json('data.total'));

        Sanctum::actingAs($eu);
        $this->assertSame(1, $this->getJson('/api/v1/amigos')->json('data.total'));
        $this->assertTrue(
            Notificacao::query()->where('user_id', $eu->id)->where('tipo', 'amigo_aceito')->exists()
        );
    }

    public function test_recusar_convite_nao_vira_amigo(): void
    {
        $eu = User::factory()->create();
        $amigo = User::factory()->create();
        $eu->ensureDefaults();
        $amigo->ensureDefaults();

        Sanctum::actingAs($eu);
        $amizadeId = (int) $this->postJson('/api/v1/amigos', [
            'codigo' => $amigo->perfil->codigo_amigo,
        ])->json('data.amizade_id');

        Sanctum::actingAs($amigo);
        $this->postJson("/api/v1/amigos/{$amizadeId}/recusar")->assertOk();
        $this->assertSame(0, $this->getJson('/api/v1/amigos')->json('data.total'));
    }

    public function test_nao_convida_codigo_inexistente_nem_a_si_mesmo(): void
    {
        $eu = User::factory()->create();
        $eu->ensureDefaults();
        Sanctum::actingAs($eu);

        $this->postJson('/api/v1/amigos', ['codigo' => 'ZZZZZZ'])
            ->assertStatus(422);

        $this->postJson('/api/v1/amigos', ['codigo' => $eu->perfil->codigo_amigo])
            ->assertStatus(422);
    }

    public function test_stats_do_amigo_aceito(): void
    {
        $eu = User::factory()->create();
        $amigo = User::factory()->create();
        $eu->ensureDefaults();
        $amigo->ensureDefaults();

        Sanctum::actingAs($eu);
        $amizadeId = (int) $this->postJson('/api/v1/amigos', [
            'codigo' => $amigo->perfil->codigo_amigo,
        ])->json('data.amizade_id');

        Sanctum::actingAs($amigo);
        $this->postJson("/api/v1/amigos/{$amizadeId}/aceitar")->assertOk();

        Sanctum::actingAs($eu);
        $stats = $this->getJson('/api/v1/amigos/'.$amigo->id.'/stats?periodo=semana');
        $stats->assertOk();
        $this->assertSame($amigo->id, (int) $stats->json('data.amigo.id'));
        $this->assertArrayHasKey('totais', $stats->json('data'));
        $this->assertArrayHasKey('nivel', $stats->json('data'));
    }

    public function test_stats_bloqueia_nao_amigo(): void
    {
        $eu = User::factory()->create();
        $outro = User::factory()->create();
        $eu->ensureDefaults();
        $outro->ensureDefaults();

        Sanctum::actingAs($eu);
        $this->getJson('/api/v1/amigos/'.$outro->id.'/stats')->assertStatus(422);
    }

    public function test_perfil_expoe_codigo_amigo(): void
    {
        $eu = User::factory()->create();
        $eu->ensureDefaults();
        Sanctum::actingAs($eu);

        $stats = $this->getJson('/api/v1/perfil/stats');
        $stats->assertOk();
        $this->assertNotEmpty($stats->json('data.perfil.codigo_amigo'));
    }
}
