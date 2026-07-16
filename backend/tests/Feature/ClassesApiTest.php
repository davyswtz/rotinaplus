<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ClassesApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_classes_catalog_returns_four_classes(): void
    {
        $response = $this->getJson('/api/v1/classes');

        $response
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonCount(4, 'data')
            ->assertJsonStructure([
                'data' => [
                    ['key', 'nome', 'emoji', 'descricao', 'bonus', 'tema'],
                ],
            ]);

        $nomes = collect($response->json('data'))->pluck('nome')->all();
        $this->assertSame(['Guerreiro', 'Estudioso', 'Investidor', 'Sábio'], $nomes);
    }
}
