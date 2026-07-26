<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class HabitoApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_cria_habito_e_faz_checkin_com_xp(): void
    {
        $user = User::factory()->create();
        $user->ensureDefaults();
        Sanctum::actingAs($user);

        $criar = $this->postJson('/api/v1/habitos', [
            'titulo' => 'Beber água',
            'detalhe' => '2L',
            'icone' => '💧',
            'area' => 'bemestar',
        ]);

        $criar->assertCreated();
        $id = (int) $criar->json('data.id');
        $xp = (int) $criar->json('data.xp');
        $this->assertGreaterThan(0, $xp);

        $journal = $this->getJson('/api/v1/habitos');
        $journal->assertOk();
        $this->assertCount(1, $journal->json('data.itens'));
        $this->assertSame(0, $journal->json('data.resumo.concluidos'));

        $toggle = $this->patchJson("/api/v1/habitos/{$id}/checkin", [
            'humor' => 4,
            'nota' => 'Dia leve',
        ]);
        $toggle->assertOk();
        $this->assertTrue($toggle->json('data.concluida'));
        $this->assertSame('Dia leve', $toggle->json('data.checkin.nota'));

        $user->refresh();
        $this->assertSame($xp, (int) $user->perfil->xp_atual);

        $journal2 = $this->getJson('/api/v1/habitos');
        $this->assertSame(1, $journal2->json('data.resumo.concluidos'));
        $this->assertNotNull($journal2->json('data.resumo.streak_geral'));
    }

    public function test_dashboard_inclui_habitos_resumo(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        $this->postJson('/api/v1/habitos', [
            'titulo' => 'Ler',
            'icone' => '📖',
            'area' => 'estudos',
        ])->assertCreated();

        $dash = $this->getJson('/api/v1/dashboard');
        $dash->assertOk();
        $this->assertSame(0, $dash->json('data.habitos_resumo.concluidos'));
        $this->assertSame(1, $dash->json('data.habitos_resumo.total'));
    }
}
