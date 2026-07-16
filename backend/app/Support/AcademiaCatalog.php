<?php

namespace App\Support;

final class AcademiaCatalog
{
    /**
     * Template da semana (Seg–Dom). Sem progresso fictício.
     *
     * @return list<array{dia_chave: string, label: string, foco: string, is_rest: bool, ordem: int}>
     */
    public static function diasSemana(): array
    {
        return [
            ['dia_chave' => 'seg', 'label' => 'Seg', 'foco' => 'Peito', 'is_rest' => false, 'ordem' => 1],
            ['dia_chave' => 'ter', 'label' => 'Ter', 'foco' => 'Costas', 'is_rest' => false, 'ordem' => 2],
            ['dia_chave' => 'qua', 'label' => 'Qua', 'foco' => 'Ombros', 'is_rest' => false, 'ordem' => 3],
            ['dia_chave' => 'qui', 'label' => 'Qui', 'foco' => 'Braços', 'is_rest' => false, 'ordem' => 4],
            ['dia_chave' => 'sex', 'label' => 'Sex', 'foco' => 'Pernas', 'is_rest' => false, 'ordem' => 5],
            ['dia_chave' => 'sab', 'label' => 'Sáb', 'foco' => 'Cardio', 'is_rest' => false, 'ordem' => 6],
            ['dia_chave' => 'dom', 'label' => 'Dom', 'foco' => 'Rest', 'is_rest' => true, 'ordem' => 7],
        ];
    }

    /**
     * @return array{dia_chave: string, label: string, foco: string, is_rest: bool, ordem: int}|null
     */
    public static function diaPorChave(string $chave): ?array
    {
        foreach (self::diasSemana() as $dia) {
            if ($dia['dia_chave'] === $chave) {
                return $dia;
            }
        }

        return null;
    }

    /** Chave do dia (seg…dom) a partir de Carbon dayOfWeekIso (1=seg … 7=dom). */
    public static function chaveDoDiaIso(int $dayOfWeekIso): string
    {
        $map = [1 => 'seg', 2 => 'ter', 3 => 'qua', 4 => 'qui', 5 => 'sex', 6 => 'sab', 7 => 'dom'];

        return $map[$dayOfWeekIso] ?? 'seg';
    }
}
