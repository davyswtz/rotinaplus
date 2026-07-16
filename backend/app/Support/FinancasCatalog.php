<?php

namespace App\Support;

final class FinancasCatalog
{
    /**
     * @return array<string, array{nome: string, cor: string, icone: string}>
     */
    public static function categoriasDespesa(): array
    {
        return [
            'moradia' => ['nome' => 'Moradia', 'cor' => '#7A42F5', 'icone' => '🏠'],
            'alimentacao' => ['nome' => 'Alimentação', 'cor' => '#4ADE80', 'icone' => '🛒'],
            'transporte' => ['nome' => 'Transporte', 'cor' => '#5BDEE8', 'icone' => '🚌'],
            'lazer' => ['nome' => 'Lazer', 'cor' => '#FF8C33', 'icone' => '🎮'],
            'saude' => ['nome' => 'Saúde', 'cor' => '#F5D76E', 'icone' => '💊'],
            'educacao' => ['nome' => 'Educação', 'cor' => '#C084FC', 'icone' => '📚'],
            'outros' => ['nome' => 'Outros', 'cor' => '#9CA3AF', 'icone' => '📦'],
        ];
    }

    public static function categoriaReceita(): array
    {
        return ['nome' => 'Receita', 'cor' => '#4ADE80', 'icone' => '💼'];
    }

    /**
     * @return list<string>
     */
    public static function chavesDespesa(): array
    {
        return array_keys(self::categoriasDespesa());
    }
}
