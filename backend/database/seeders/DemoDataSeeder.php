<?php

namespace Database\Seeders;

use App\Models\AcademiaDia;
use App\Models\AcademiaTreino;
use App\Models\AcademiaVolume;
use App\Models\Missao;
use App\Models\Notificacao;
use App\Models\User;
use App\Support\SemanaHelper;
use Illuminate\Database\Seeder;

class DemoDataSeeder extends Seeder
{
    public function run(): void
    {
        $user = User::query()->where('email', 'davy@teste.com')->first();

        if (! $user) {
            return;
        }

        $user->ensureDefaults();

        $user->perfil()->update([
            'nome_heroi' => 'ssss',
            'avatar_key' => 'guara_sorriso',
            'classe' => 'Sábio',
            'emoji_classe' => '🔮',
            'nivel' => 1,
            'xp_atual' => 240,
            'xp_proximo_nivel' => 500,
            'moedas' => 480,
            'streak_dias' => 3,
        ]);

        $user->academiaConfig()->update([
            'meta_semana' => 5,
            'sequencia_treinos' => 12,
        ]);

        $this->seedMissoes($user);
        $this->seedNotificacoes($user);
        $this->seedAcademia($user);
    }

    private function seedMissoes(User $user): void
    {
        $hoje = now('America/Sao_Paulo')->toDateString();

        Missao::query()->where('user_id', $user->id)->whereDate('data', $hoje)->delete();

        $missoes = [
            ['icone' => '💧', 'titulo' => 'Beber água', 'detalhe' => '2L ao longo do dia', 'xp' => 15, 'concluida' => true, 'ordem' => 1],
            ['icone' => '🏃', 'titulo' => 'Treinar', 'detalhe' => '30 min de movimento', 'xp' => 25, 'concluida' => true, 'ordem' => 2],
            ['icone' => '📚', 'titulo' => 'Estudar', 'detalhe' => '1 Pomodoro focado', 'xp' => 20, 'concluida' => false, 'ordem' => 3],
            ['icone' => '🧘', 'titulo' => 'Meditar', 'detalhe' => '10 min de respiração', 'xp' => 15, 'concluida' => false, 'ordem' => 4],
            ['icone' => '💰', 'titulo' => 'Registrar gastos', 'detalhe' => 'Anotar o dia no app', 'xp' => 10, 'concluida' => false, 'ordem' => 5],
        ];

        foreach ($missoes as $m) {
            Missao::query()->create([
                'user_id' => $user->id,
                'data' => $hoje,
                'icone' => $m['icone'],
                'titulo' => $m['titulo'],
                'detalhe' => $m['detalhe'],
                'xp' => $m['xp'],
                'concluida' => $m['concluida'],
                'concluida_em' => $m['concluida'] ? now() : null,
                'ordem' => $m['ordem'],
            ]);
        }
    }

    private function seedNotificacoes(User $user): void
    {
        if (Notificacao::query()->where('user_id', $user->id)->exists()) {
            return;
        }

        $itens = [
            ['icone' => '🔥', 'titulo' => 'Streak em risco!', 'mensagem' => 'Complete pelo menos 1 hábito hoje para manter sua sequência de 3 dias.', 'lida' => false, 'hours' => 0],
            ['icone' => '⚡', 'titulo' => 'XP desbloqueado', 'mensagem' => 'Você ganhou 35 XP pela missão diária de hidratação. Continue assim!', 'lida' => false, 'hours' => 2],
            ['icone' => '🏆', 'titulo' => 'Conquista próxima', 'mensagem' => 'Faltam 2 treinos para desbloquear a medalha Guerreiro Consistente.', 'lida' => true, 'hours' => 4],
            ['icone' => '🦊', 'titulo' => 'Fox diz: Boa noite!', 'mensagem' => 'Lembre de registrar seus hábitos antes de dormir. Seu eu de amanhã agradece.', 'lida' => true, 'hours' => 20],
            ['icone' => '💰', 'titulo' => 'Meta de poupança', 'mensagem' => 'Você está a R$ 40 da meta semanal. Um café a menos e você chega lá.', 'lida' => true, 'hours' => 28],
            ['icone' => '📚', 'titulo' => 'Hora de estudar', 'mensagem' => 'Seu bloco de foco de Estudos começa em 15 minutos. Prepare o material!', 'lida' => true, 'hours' => 30],
        ];

        foreach ($itens as $item) {
            Notificacao::query()->create([
                'user_id' => $user->id,
                'icone' => $item['icone'],
                'titulo' => $item['titulo'],
                'mensagem' => $item['mensagem'],
                'lida' => $item['lida'],
                'lida_em' => $item['lida'] ? now()->subHours($item['hours']) : null,
                'created_at' => now()->subHours($item['hours']),
                'updated_at' => now()->subHours($item['hours']),
            ]);
        }
    }

    private function seedAcademia(User $user): void
    {
        $semana = SemanaHelper::inicioAtual()->toDateString();

        AcademiaDia::query()
            ->where('user_id', $user->id)
            ->whereDate('semana_inicio', $semana)
            ->delete();

        AcademiaVolume::query()
            ->where('user_id', $user->id)
            ->whereDate('semana_inicio', $semana)
            ->delete();

        AcademiaTreino::query()->where('user_id', $user->id)->delete();

        $dias = [
            ['dia_chave' => 'seg', 'label' => 'Seg', 'foco' => 'Peito', 'is_rest' => false, 'concluido' => true, 'ordem' => 1],
            ['dia_chave' => 'ter', 'label' => 'Ter', 'foco' => 'Costas', 'is_rest' => false, 'concluido' => true, 'ordem' => 2],
            ['dia_chave' => 'qua', 'label' => 'Qua', 'foco' => 'Ombros', 'is_rest' => false, 'concluido' => false, 'ordem' => 3],
            ['dia_chave' => 'qui', 'label' => 'Qui', 'foco' => 'Braços', 'is_rest' => false, 'concluido' => false, 'ordem' => 4],
            ['dia_chave' => 'sex', 'label' => 'Sex', 'foco' => 'Pernas', 'is_rest' => false, 'concluido' => false, 'ordem' => 5],
            ['dia_chave' => 'sab', 'label' => 'Sáb', 'foco' => 'Cardio', 'is_rest' => false, 'concluido' => false, 'ordem' => 6],
            ['dia_chave' => 'dom', 'label' => 'Dom', 'foco' => 'Rest', 'is_rest' => true, 'concluido' => false, 'ordem' => 7],
        ];

        foreach ($dias as $dia) {
            AcademiaDia::query()->create([
                'user_id' => $user->id,
                'semana_inicio' => $semana,
                ...$dia,
            ]);
        }

        $volumes = [
            ['dia_chave' => 'seg', 'label' => 'Seg', 'kg' => 4200],
            ['dia_chave' => 'ter', 'label' => 'Ter', 'kg' => 3100],
            ['dia_chave' => 'qua', 'label' => 'Qua', 'kg' => 0],
            ['dia_chave' => 'qui', 'label' => 'Qui', 'kg' => 0],
            ['dia_chave' => 'sex', 'label' => 'Sex', 'kg' => 0],
            ['dia_chave' => 'sab', 'label' => 'Sáb', 'kg' => 0],
            ['dia_chave' => 'dom', 'label' => 'Dom', 'kg' => 0],
        ];

        foreach ($volumes as $vol) {
            AcademiaVolume::query()->create([
                'user_id' => $user->id,
                'semana_inicio' => $semana,
                ...$vol,
            ]);
        }

        AcademiaTreino::query()->create([
            'user_id' => $user->id,
            'foco' => 'Ombros',
            'titulo' => 'Iniciar treino de Ombros',
            'exercicios' => 8,
            'minutos' => 45,
            'xp' => 140,
            'dia_chave' => 'qua',
            'ativo' => true,
        ]);
    }
}
