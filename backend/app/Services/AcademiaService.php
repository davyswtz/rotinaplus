<?php

namespace App\Services;

use App\Models\AcademiaDia;
use App\Models\AcademiaEsporteSessao;
use App\Models\AcademiaTreino;
use App\Models\AcademiaTreinoExercicio;
use App\Models\AcademiaVolume;
use App\Models\Perfil;
use App\Models\User;
use App\Support\AcademiaCatalog;
use App\Support\EsporteCatalog;
use App\Support\ExercicioCatalog;
use App\Support\MissaoXpCalculator;
use App\Support\SemanaHelper;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class AcademiaService
{
    public function show(User $user): array
    {
        $this->ensureSemanaAtual($user);
        $data = app(DashboardService::class)->academia($user);
        $data['esportes'] = EsporteCatalog::all();
        $data['esporte_sessoes'] = $this->sessoesRecentes($user);
        $data['esporte_resumo'] = $this->resumoEsportes($user);
        $data['focos'] = ExercicioCatalog::focos();

        if ($data['treino_hoje']) {
            $data['treino_hoje']->load('itens');
            // Treinos legados (seed sem exercícios reais) não contam como treino do dia.
            if ($data['treino_hoje']->itens->isEmpty()) {
                $data['treino_hoje']->update(['ativo' => false]);
                $data['treino_hoje'] = null;
            }
        }

        return $data;
    }

    /**
     * Garante estrutura da semana atual (dias + volumes zerados).
     * Não cria treino fictício — o usuário monta em Novo treino.
     */
    public function ensureSemanaAtual(User $user): void
    {
        $user->ensureDefaults();
        $semana = SemanaHelper::inicioAtual()->toDateString();

        $temDias = AcademiaDia::query()
            ->where('user_id', $user->id)
            ->whereDate('semana_inicio', $semana)
            ->exists();

        if (! $temDias) {
            foreach (AcademiaCatalog::diasSemana() as $dia) {
                AcademiaDia::query()->create([
                    'user_id' => $user->id,
                    'semana_inicio' => $semana,
                    'dia_chave' => $dia['dia_chave'],
                    'label' => $dia['label'],
                    'foco' => $dia['foco'],
                    'is_rest' => $dia['is_rest'],
                    'concluido' => false,
                    'ordem' => $dia['ordem'],
                ]);
            }
        }

        $temVolumes = AcademiaVolume::query()
            ->where('user_id', $user->id)
            ->whereDate('semana_inicio', $semana)
            ->exists();

        if (! $temVolumes) {
            foreach (AcademiaCatalog::diasSemana() as $dia) {
                AcademiaVolume::query()->create([
                    'user_id' => $user->id,
                    'semana_inicio' => $semana,
                    'dia_chave' => $dia['dia_chave'],
                    'label' => $dia['label'],
                    'kg' => 0,
                ]);
            }
        }
    }

    public function catalogoExercicios(?string $grupo = null): array
    {
        return [
            'focos' => ExercicioCatalog::focos(),
            'exercicios' => ExercicioCatalog::porGrupo($grupo),
        ];
    }

    /**
     * @param  array{
     *   foco: string,
     *   titulo?: string|null,
     *   minutos?: int|null,
     *   exercicios: list<array{exercicio_chave?: string, nome?: string, series?: int, reps?: int, carga_kg?: int}>
     * }  $dados
     */
    public function criarTreino(User $user, array $dados): AcademiaTreino
    {
        $user->ensureDefaults();
        /** @var Perfil $perfil */
        $perfil = $user->perfil()->firstOrFail();

        $itens = $dados['exercicios'] ?? [];
        if (count($itens) < 1) {
            throw ValidationException::withMessages([
                'exercicios' => ['Adicione pelo menos 1 exercício.'],
            ]);
        }

        $foco = trim((string) ($dados['foco'] ?? 'Full body'));
        if (! in_array($foco, ExercicioCatalog::focos(), true)) {
            $foco = 'Full body';
        }

        $minutos = max(10, min(180, (int) ($dados['minutos'] ?? max(20, count($itens) * 6))));
        $titulo = trim((string) ($dados['titulo'] ?? ''));
        if ($titulo === '') {
            $titulo = 'Treino de '.$foco;
        }

        $peso = count($itens) >= 6 || $minutos >= 50 ? 3 : (count($itens) >= 3 || $minutos >= 30 ? 2 : 1);
        $xp = MissaoXpCalculator::calcularXp((int) $perfil->xp_proximo_nivel, $peso, false);

        $chaveHoje = AcademiaCatalog::chaveDoDiaIso(
            (int) now('America/Sao_Paulo')->dayOfWeekIso
        );

        return DB::transaction(function () use ($user, $foco, $titulo, $minutos, $xp, $chaveHoje, $itens) {
            AcademiaTreino::query()
                ->where('user_id', $user->id)
                ->where('ativo', true)
                ->whereNull('concluido_em')
                ->update(['ativo' => false]);

            $treino = AcademiaTreino::query()->create([
                'user_id' => $user->id,
                'foco' => $foco,
                'titulo' => $titulo,
                'exercicios' => count($itens),
                'minutos' => $minutos,
                'xp' => $xp,
                'dia_chave' => $chaveHoje,
                'ativo' => true,
                'concluido_em' => null,
                'volume_kg' => 0,
            ]);

            $this->sincronizarItens($treino, $itens);

            return $treino->fresh('itens');
        });
    }

    /**
     * @param  array{
     *   foco?: string,
     *   titulo?: string|null,
     *   minutos?: int|null,
     *   exercicios?: list<array{exercicio_chave?: string, nome?: string, series?: int, reps?: int, carga_kg?: int}>
     * }  $dados
     */
    public function atualizarTreino(User $user, int $id, array $dados): AcademiaTreino
    {
        $treino = $this->buscarTreino($user, $id);
        if ($treino->concluido_em) {
            throw ValidationException::withMessages([
                'treino' => ['Treino já concluído não pode ser editado.'],
            ]);
        }

        /** @var Perfil $perfil */
        $perfil = $user->perfil()->firstOrFail();

        return DB::transaction(function () use ($treino, $dados, $perfil) {
            if (isset($dados['foco'])) {
                $foco = trim((string) $dados['foco']);
                if (in_array($foco, ExercicioCatalog::focos(), true)) {
                    $treino->foco = $foco;
                }
            }
            if (array_key_exists('titulo', $dados) && trim((string) $dados['titulo']) !== '') {
                $treino->titulo = trim((string) $dados['titulo']);
            }
            if (isset($dados['minutos'])) {
                $treino->minutos = max(10, min(180, (int) $dados['minutos']));
            }

            if (isset($dados['exercicios'])) {
                $itens = $dados['exercicios'];
                if (count($itens) < 1) {
                    throw ValidationException::withMessages([
                        'exercicios' => ['Adicione pelo menos 1 exercício.'],
                    ]);
                }
                $this->sincronizarItens($treino, $itens);
                $treino->exercicios = count($itens);
            }

            $peso = $treino->exercicios >= 6 || $treino->minutos >= 50 ? 3
                : ($treino->exercicios >= 3 || $treino->minutos >= 30 ? 2 : 1);
            $treino->xp = MissaoXpCalculator::calcularXp((int) $perfil->xp_proximo_nivel, $peso, false);
            $treino->ativo = true;
            $treino->save();

            AcademiaTreino::query()
                ->where('user_id', $treino->user_id)
                ->where('id', '!=', $treino->id)
                ->where('ativo', true)
                ->whereNull('concluido_em')
                ->update(['ativo' => false]);

            return $treino->fresh('itens');
        });
    }

    public function detalheTreino(User $user, int $id): AcademiaTreino
    {
        return $this->buscarTreino($user, $id)->load('itens');
    }

    public function historico(User $user): array
    {
        return AcademiaTreino::query()
            ->where('user_id', $user->id)
            ->with('itens')
            ->orderByDesc('id')
            ->limit(30)
            ->get()
            ->all();
    }

    public function toggleExercicio(User $user, int $treinoId, int $exercicioId, ?bool $concluido = null): AcademiaTreinoExercicio
    {
        $treino = $this->buscarTreino($user, $treinoId);
        if ($treino->concluido_em) {
            throw ValidationException::withMessages([
                'treino' => ['Treino já concluído.'],
            ]);
        }

        $item = AcademiaTreinoExercicio::query()
            ->where('treino_id', $treino->id)
            ->find($exercicioId);

        if (! $item) {
            throw new NotFoundHttpException('Exercício não encontrado.');
        }

        $novo = $concluido ?? ! $item->concluido;
        if ((bool) $item->concluido === $novo) {
            return $item;
        }

        $item->concluido = $novo;
        $item->save();

        return $item->fresh();
    }

    public function concluirTreino(User $user, int $id): AcademiaTreino
    {
        $treino = $this->buscarTreino($user, $id);
        if ($treino->concluido_em) {
            return $treino->load('itens');
        }

        /** @var Perfil $perfil */
        $perfil = $user->perfil()->firstOrFail();

        return DB::transaction(function () use ($user, $treino, $perfil) {
            $treino->load('itens');
            AcademiaTreinoExercicio::query()
                ->where('treino_id', $treino->id)
                ->update(['concluido' => true]);

            $volume = (int) $treino->itens->sum(fn ($i) => ((int) $i->series) * ((int) $i->carga_kg));
            $treino->volume_kg = $volume;
            $treino->concluido_em = now('America/Sao_Paulo');
            $treino->ativo = false;
            $treino->save();

            $this->ajustarXp($perfil, (int) $treino->xp);
            $this->marcarDiaHoje($user);
            $this->somarVolumeHoje($user, $volume);

            $config = $user->academiaConfig()->first();
            if ($config) {
                $config->sequencia_treinos = (int) $config->sequencia_treinos + 1;
                $config->save();
            }

            return $treino->fresh('itens');
        });
    }

    public function excluirTreino(User $user, int $id): void
    {
        $treino = $this->buscarTreino($user, $id);
        if ($treino->concluido_em) {
            throw ValidationException::withMessages([
                'treino' => ['Treino concluído não pode ser excluído.'],
            ]);
        }
        $treino->delete();
    }

    public function toggleDia(User $user, int $id, ?bool $concluido = null): AcademiaDia
    {
        $this->ensureSemanaAtual($user);

        $dia = AcademiaDia::query()
            ->where('user_id', $user->id)
            ->find($id);

        if (! $dia) {
            throw new NotFoundHttpException('Dia de treino não encontrado.');
        }

        $novo = $concluido ?? ! $dia->concluido;

        if ((bool) $dia->concluido === $novo) {
            return $dia;
        }

        $dia->update(['concluido' => $novo]);

        $config = $user->academiaConfig()->first();
        if ($config) {
            $config->sequencia_treinos = max(
                0,
                $config->sequencia_treinos + ($novo ? 1 : -1),
            );
            $config->save();
        }

        return $dia->fresh();
    }

    /**
     * @param  array{esporte_chave: string, minutos?: int, distancia_metros?: int|null, data?: string|null, nota?: string|null}  $dados
     */
    public function registrarEsporte(User $user, array $dados): AcademiaEsporteSessao
    {
        $user->ensureDefaults();
        $catalogo = EsporteCatalog::find($dados['esporte_chave'] ?? '');
        if (! $catalogo) {
            throw new NotFoundHttpException('Esporte não encontrado.');
        }

        /** @var Perfil $perfil */
        $perfil = $user->perfil()->firstOrFail();
        $tz = 'America/Sao_Paulo';
        $dia = ! empty($dados['data'])
            ? Carbon::parse($dados['data'], $tz)->toDateString()
            : now($tz)->toDateString();

        $minutos = max(5, min(300, (int) ($dados['minutos'] ?? $catalogo['minutos_padrao'])));
        $distancia = $catalogo['usa_distancia']
            ? (isset($dados['distancia_metros']) ? max(0, (int) $dados['distancia_metros']) : null)
            : null;

        $peso = $minutos >= 60 ? 3 : ($minutos >= 30 ? 2 : 1);
        $xp = MissaoXpCalculator::calcularXp((int) $perfil->xp_proximo_nivel, $peso, false);

        $sessao = AcademiaEsporteSessao::query()->create([
            'user_id' => $user->id,
            'esporte_chave' => $catalogo['chave'],
            'icone' => $catalogo['icone'],
            'nome' => $catalogo['nome'],
            'minutos' => $minutos,
            'distancia_metros' => $distancia,
            'xp' => $xp,
            'data' => $dia,
            'nota' => $dados['nota'] ?? null,
        ]);

        $this->ajustarXp($perfil, $xp);

        $config = $user->academiaConfig()->first();
        if ($config) {
            $config->sequencia_treinos = (int) $config->sequencia_treinos + 1;
            $config->save();
        }

        return $sessao;
    }

    public function excluirEsporte(User $user, int $id): void
    {
        $sessao = AcademiaEsporteSessao::query()
            ->where('user_id', $user->id)
            ->find($id);

        if (! $sessao) {
            throw new NotFoundHttpException('Sessão não encontrada.');
        }

        /** @var Perfil|null $perfil */
        $perfil = $user->perfil()->first();
        if ($perfil) {
            $this->ajustarXp($perfil, -(int) $sessao->xp);
        }

        $config = $user->academiaConfig()->first();
        if ($config) {
            $config->sequencia_treinos = max(0, (int) $config->sequencia_treinos - 1);
            $config->save();
        }

        $sessao->delete();
    }

    public function updatePerfil(User $user, array $data): Perfil
    {
        $user->ensureDefaults();
        $perfil = $user->perfil;
        $perfil->update(array_filter(
            $data,
            fn ($v) => $v !== null,
        ));

        return $perfil->fresh();
    }

    /** @param  list<array{exercicio_chave?: string, nome?: string, series?: int, reps?: int, carga_kg?: int}>  $itens */
    private function sincronizarItens(AcademiaTreino $treino, array $itens): void
    {
        AcademiaTreinoExercicio::query()->where('treino_id', $treino->id)->delete();

        foreach (array_values($itens) as $i => $raw) {
            $chave = (string) ($raw['exercicio_chave'] ?? '');
            $catalogo = $chave !== '' ? ExercicioCatalog::find($chave) : null;
            $nome = trim((string) ($raw['nome'] ?? ($catalogo['nome'] ?? '')));
            if ($nome === '') {
                continue;
            }

            AcademiaTreinoExercicio::query()->create([
                'treino_id' => $treino->id,
                'exercicio_chave' => $catalogo['chave'] ?? ($chave !== '' ? $chave : 'custom_'.$i),
                'nome' => $nome,
                'icone' => $catalogo['icone'] ?? '💪',
                'grupo' => $catalogo['grupo'] ?? $treino->foco,
                'series' => max(1, min(10, (int) ($raw['series'] ?? ($catalogo['series_padrao'] ?? 3)))),
                'reps' => max(1, min(100, (int) ($raw['reps'] ?? ($catalogo['reps_padrao'] ?? 10)))),
                'carga_kg' => max(0, min(500, (int) ($raw['carga_kg'] ?? ($catalogo['carga_padrao'] ?? 0)))),
                'ordem' => $i + 1,
                'concluido' => false,
            ]);
        }

        $count = AcademiaTreinoExercicio::query()->where('treino_id', $treino->id)->count();
        if ($count < 1) {
            throw ValidationException::withMessages([
                'exercicios' => ['Nenhum exercício válido informado.'],
            ]);
        }
    }

    private function buscarTreino(User $user, int $id): AcademiaTreino
    {
        $treino = AcademiaTreino::query()
            ->where('user_id', $user->id)
            ->find($id);

        if (! $treino) {
            throw new NotFoundHttpException('Treino não encontrado.');
        }

        return $treino;
    }

    private function marcarDiaHoje(User $user): void
    {
        $this->ensureSemanaAtual($user);
        $semana = SemanaHelper::inicioAtual()->toDateString();
        $chave = AcademiaCatalog::chaveDoDiaIso((int) now('America/Sao_Paulo')->dayOfWeekIso);

        AcademiaDia::query()
            ->where('user_id', $user->id)
            ->whereDate('semana_inicio', $semana)
            ->where('dia_chave', $chave)
            ->update(['concluido' => true]);
    }

    private function somarVolumeHoje(User $user, int $kg): void
    {
        if ($kg <= 0) {
            return;
        }
        $semana = SemanaHelper::inicioAtual()->toDateString();
        $chave = AcademiaCatalog::chaveDoDiaIso((int) now('America/Sao_Paulo')->dayOfWeekIso);

        $volume = AcademiaVolume::query()
            ->where('user_id', $user->id)
            ->whereDate('semana_inicio', $semana)
            ->where('dia_chave', $chave)
            ->first();

        if ($volume) {
            $volume->kg = (int) $volume->kg + $kg;
            $volume->save();
        }
    }

    /** @return list<AcademiaEsporteSessao> */
    private function sessoesRecentes(User $user): array
    {
        return AcademiaEsporteSessao::query()
            ->where('user_id', $user->id)
            ->orderByDesc('data')
            ->orderByDesc('id')
            ->limit(12)
            ->get()
            ->all();
    }

    /** @return array{total_semana: int, minutos_semana: int, xp_semana: int} */
    private function resumoEsportes(User $user): array
    {
        $inicio = now('America/Sao_Paulo')->startOfWeek(Carbon::MONDAY)->toDateString();
        $sessoes = AcademiaEsporteSessao::query()
            ->where('user_id', $user->id)
            ->whereDate('data', '>=', $inicio)
            ->get();

        return [
            'total_semana' => $sessoes->count(),
            'minutos_semana' => (int) $sessoes->sum('minutos'),
            'xp_semana' => (int) $sessoes->sum('xp'),
        ];
    }

    private function ajustarXp(Perfil $perfil, int $delta): void
    {
        $xp = max(0, $perfil->xp_atual + $delta);

        while ($xp >= $perfil->xp_proximo_nivel) {
            $xp -= $perfil->xp_proximo_nivel;
            $perfil->nivel += 1;
            $perfil->xp_proximo_nivel = (int) round($perfil->xp_proximo_nivel * 1.25);
        }

        $perfil->xp_atual = $xp;
        $perfil->save();
    }
}
