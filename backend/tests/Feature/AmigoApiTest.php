<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AmigoApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_adiciona_lista_e_remove_amigo_por_nick(): void
    {
        $eu = User::factory()->create(['name' => 'Davy']);
        $amigo = User::factory()->create(['name' => 'Ana']);
        $eu->ensureDefaults();
        $amigo->ensureDefaults();

        $nickAmigo = $amigo->perfil->nick;
        $this->assertNotEmpty($nickAmigo);

        Sanctum::actingAs($eu);

        $add = $this->postJson('/api/v1/amigos', ['nick' => $nickAmigo]);
        $add->assertCreated();
        $this->assertSame($amigo->id, (int) $add->json('data.id'));
        $this->assertSame($nickAmigo, $add->json('data.nick'));

        $lista = $this->getJson('/api/v1/amigos');
        $lista->assertOk();
        $this->assertSame(1, $lista->json('data.total'));
        $this->assertSame($nickAmigo, $lista->json('data.amigos.0.nick'));

        // Amigo também vê a amizade
        Sanctum::actingAs($amigo);
        $listaAmigo = $this->getJson('/api/v1/amigos');
        $listaAmigo->assertOk();
        $this->assertSame(1, $listaAmigo->json('data.total'));
        $this->assertSame($eu->perfil->nick, $listaAmigo->json('data.amigos.0.nick'));

        Sanctum::actingAs($eu);
        $this->deleteJson('/api/v1/amigos/'.$amigo->id)->assertOk();

        $lista2 = $this->getJson('/api/v1/amigos');
        $this->assertSame(0, $lista2->json('data.total'));
    }

    public function test_nao_adiciona_nick_inexistente_nem_a_si_mesmo(): void
    {
        $eu = User::factory()->create();
        $eu->ensureDefaults();
        Sanctum::actingAs($eu);

        $this->postJson('/api/v1/amigos', ['nick' => 'naoexiste123'])
            ->assertStatus(422);

        $this->postJson('/api/v1/amigos', ['nick' => $eu->perfil->nick])
            ->assertStatus(422);
    }

    public function test_atualiza_nick_no_perfil(): void
    {
        $eu = User::factory()->create();
        $eu->ensureDefaults();
        Sanctum::actingAs($eu);

        $res = $this->putJson('/api/v1/perfil', ['nick' => 'Guara_Dev']);
        $res->assertOk();
        $this->assertSame('guara_dev', $res->json('data.nick'));
    }
}
