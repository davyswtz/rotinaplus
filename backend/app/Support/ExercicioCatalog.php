<?php

namespace App\Support;

final class ExercicioCatalog
{
    /**
     * @return list<string>
     */
    public static function focos(): array
    {
        return ['Peito', 'Costas', 'Ombros', 'Braços', 'Pernas', 'Cardio', 'Full body'];
    }

    /**
     * @return list<array{
     *   chave: string,
     *   nome: string,
     *   icone: string,
     *   grupo: string,
     *   series_padrao: int,
     *   reps_padrao: int,
     *   carga_padrao: int
     * }>
     */
    public static function all(): array
    {
        return [
            ['chave' => 'supino_reto', 'nome' => 'Supino reto', 'icone' => '🏋️', 'grupo' => 'Peito', 'series_padrao' => 4, 'reps_padrao' => 10, 'carga_padrao' => 40],
            ['chave' => 'supino_inclinado', 'nome' => 'Supino inclinado', 'icone' => '🏋️', 'grupo' => 'Peito', 'series_padrao' => 3, 'reps_padrao' => 10, 'carga_padrao' => 30],
            ['chave' => 'crucifixo', 'nome' => 'Crucifixo', 'icone' => '💪', 'grupo' => 'Peito', 'series_padrao' => 3, 'reps_padrao' => 12, 'carga_padrao' => 12],
            ['chave' => 'flexao', 'nome' => 'Flexão', 'icone' => '🫸', 'grupo' => 'Peito', 'series_padrao' => 3, 'reps_padrao' => 15, 'carga_padrao' => 0],
            ['chave' => 'peck_deck', 'nome' => 'Peck deck', 'icone' => '💪', 'grupo' => 'Peito', 'series_padrao' => 3, 'reps_padrao' => 12, 'carga_padrao' => 35],

            ['chave' => 'puxada_frente', 'nome' => 'Puxada frente', 'icone' => '🏋️', 'grupo' => 'Costas', 'series_padrao' => 4, 'reps_padrao' => 10, 'carga_padrao' => 45],
            ['chave' => 'remada_curvada', 'nome' => 'Remada curvada', 'icone' => '🏋️', 'grupo' => 'Costas', 'series_padrao' => 4, 'reps_padrao' => 10, 'carga_padrao' => 40],
            ['chave' => 'remada_unilateral', 'nome' => 'Remada unilateral', 'icone' => '💪', 'grupo' => 'Costas', 'series_padrao' => 3, 'reps_padrao' => 12, 'carga_padrao' => 18],
            ['chave' => 'pulldown', 'nome' => 'Pulldown', 'icone' => '🏋️', 'grupo' => 'Costas', 'series_padrao' => 3, 'reps_padrao' => 12, 'carga_padrao' => 40],
            ['chave' => 'barra_fix', 'nome' => 'Barra fixa', 'icone' => '🆙', 'grupo' => 'Costas', 'series_padrao' => 3, 'reps_padrao' => 8, 'carga_padrao' => 0],

            ['chave' => 'desenvolvimento', 'nome' => 'Desenvolvimento', 'icone' => '🏋️', 'grupo' => 'Ombros', 'series_padrao' => 4, 'reps_padrao' => 10, 'carga_padrao' => 25],
            ['chave' => 'elevacao_lateral', 'nome' => 'Elevação lateral', 'icone' => '💪', 'grupo' => 'Ombros', 'series_padrao' => 3, 'reps_padrao' => 12, 'carga_padrao' => 8],
            ['chave' => 'elevacao_frontal', 'nome' => 'Elevação frontal', 'icone' => '💪', 'grupo' => 'Ombros', 'series_padrao' => 3, 'reps_padrao' => 12, 'carga_padrao' => 8],
            ['chave' => 'remada_alta', 'nome' => 'Remada alta', 'icone' => '🏋️', 'grupo' => 'Ombros', 'series_padrao' => 3, 'reps_padrao' => 12, 'carga_padrao' => 20],
            ['chave' => 'arnold_press', 'nome' => 'Arnold press', 'icone' => '💪', 'grupo' => 'Ombros', 'series_padrao' => 3, 'reps_padrao' => 10, 'carga_padrao' => 14],

            ['chave' => 'rosca_direta', 'nome' => 'Rosca direta', 'icone' => '💪', 'grupo' => 'Braços', 'series_padrao' => 3, 'reps_padrao' => 12, 'carga_padrao' => 14],
            ['chave' => 'rosca_martelo', 'nome' => 'Rosca martelo', 'icone' => '💪', 'grupo' => 'Braços', 'series_padrao' => 3, 'reps_padrao' => 12, 'carga_padrao' => 12],
            ['chave' => 'triceps_corda', 'nome' => 'Tríceps corda', 'icone' => '🏋️', 'grupo' => 'Braços', 'series_padrao' => 3, 'reps_padrao' => 12, 'carga_padrao' => 25],
            ['chave' => 'triceps_testa', 'nome' => 'Tríceps testa', 'icone' => '💪', 'grupo' => 'Braços', 'series_padrao' => 3, 'reps_padrao' => 12, 'carga_padrao' => 20],
            ['chave' => 'rosca_concentrada', 'nome' => 'Rosca concentrada', 'icone' => '💪', 'grupo' => 'Braços', 'series_padrao' => 3, 'reps_padrao' => 12, 'carga_padrao' => 10],

            ['chave' => 'agachamento', 'nome' => 'Agachamento', 'icone' => '🏋️', 'grupo' => 'Pernas', 'series_padrao' => 4, 'reps_padrao' => 10, 'carga_padrao' => 60],
            ['chave' => 'leg_press', 'nome' => 'Leg press', 'icone' => '🏋️', 'grupo' => 'Pernas', 'series_padrao' => 4, 'reps_padrao' => 12, 'carga_padrao' => 120],
            ['chave' => 'stiff', 'nome' => 'Stiff', 'icone' => '💪', 'grupo' => 'Pernas', 'series_padrao' => 3, 'reps_padrao' => 10, 'carga_padrao' => 40],
            ['chave' => 'cadeira_extensora', 'nome' => 'Cadeira extensora', 'icone' => '🏋️', 'grupo' => 'Pernas', 'series_padrao' => 3, 'reps_padrao' => 12, 'carga_padrao' => 40],
            ['chave' => 'mesa_flexora', 'nome' => 'Mesa flexora', 'icone' => '🏋️', 'grupo' => 'Pernas', 'series_padrao' => 3, 'reps_padrao' => 12, 'carga_padrao' => 35],
            ['chave' => 'panturrilha', 'nome' => 'Panturrilha', 'icone' => '🦵', 'grupo' => 'Pernas', 'series_padrao' => 4, 'reps_padrao' => 15, 'carga_padrao' => 40],

            ['chave' => 'esteira', 'nome' => 'Esteira', 'icone' => '🏃', 'grupo' => 'Cardio', 'series_padrao' => 1, 'reps_padrao' => 20, 'carga_padrao' => 0],
            ['chave' => 'bike', 'nome' => 'Bike', 'icone' => '🚴', 'grupo' => 'Cardio', 'series_padrao' => 1, 'reps_padrao' => 20, 'carga_padrao' => 0],
            ['chave' => 'eliptico', 'nome' => 'Elíptico', 'icone' => '🏃', 'grupo' => 'Cardio', 'series_padrao' => 1, 'reps_padrao' => 20, 'carga_padrao' => 0],
            ['chave' => 'burpee', 'nome' => 'Burpee', 'icone' => '🔥', 'grupo' => 'Cardio', 'series_padrao' => 3, 'reps_padrao' => 12, 'carga_padrao' => 0],
            ['chave' => 'corda', 'nome' => 'Corda', 'icone' => '🪢', 'grupo' => 'Cardio', 'series_padrao' => 3, 'reps_padrao' => 60, 'carga_padrao' => 0],

            ['chave' => 'prancha', 'nome' => 'Prancha', 'icone' => '🧘', 'grupo' => 'Full body', 'series_padrao' => 3, 'reps_padrao' => 45, 'carga_padrao' => 0],
            ['chave' => 'farmers_walk', 'nome' => "Farmer's walk", 'icone' => '🏋️', 'grupo' => 'Full body', 'series_padrao' => 3, 'reps_padrao' => 40, 'carga_padrao' => 20],
            ['chave' => 'kettlebell_swing', 'nome' => 'Kettlebell swing', 'icone' => '💥', 'grupo' => 'Full body', 'series_padrao' => 3, 'reps_padrao' => 15, 'carga_padrao' => 16],
            ['chave' => 'thruster', 'nome' => 'Thruster', 'icone' => '🏋️', 'grupo' => 'Full body', 'series_padrao' => 3, 'reps_padrao' => 10, 'carga_padrao' => 20],
        ];
    }

    public static function find(string $chave): ?array
    {
        foreach (self::all() as $item) {
            if ($item['chave'] === $chave) {
                return $item;
            }
        }

        return null;
    }

    /**
     * @return list<array{
     *   chave: string,
     *   nome: string,
     *   icone: string,
     *   grupo: string,
     *   series_padrao: int,
     *   reps_padrao: int,
     *   carga_padrao: int
     * }>
     */
    public static function porGrupo(?string $grupo): array
    {
        if ($grupo === null || $grupo === '' || strcasecmp($grupo, 'Full body') === 0) {
            return self::all();
        }

        return array_values(array_filter(
            self::all(),
            fn (array $e) => strcasecmp($e['grupo'], $grupo) === 0
                || strcasecmp($grupo, 'Full body') === 0,
        ));
    }
}
