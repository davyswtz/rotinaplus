<?php

namespace Tests\Unit;

use App\DTOs\RotinaDTO;
use App\Models\Rotina;
use App\Repositories\RotinaRepository;
use App\Services\RotinaService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class RotinaServiceTest extends TestCase
{
    use RefreshDatabase;

    private RotinaService $service;

    protected function setUp(): void
    {
        parent::setUp();

        $this->service = new RotinaService(
            new RotinaRepository(new Rotina),
        );
    }

    public function test_create_rotina_via_service(): void
    {
        $dto = new RotinaDTO(
            titulo: 'Meditar',
            descricao: '10 minutos',
            concluida: false,
        );

        $rotina = $this->service->create($dto);

        $this->assertInstanceOf(Rotina::class, $rotina);
        $this->assertSame('Meditar', $rotina->titulo);
    }

    public function test_find_throws_when_rotina_not_found(): void
    {
        $this->expectException(\Symfony\Component\HttpKernel\Exception\NotFoundHttpException::class);

        $this->service->find(999);
    }
}
