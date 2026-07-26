<?php

namespace App\Support;

final class HabitoCatalog
{
    /** @return list<string> */
    public static function areas(): array
    {
        return ['geral', 'academia', 'financas', 'estudos', 'bemestar'];
    }

    /**
     * Sugestões iniciais (não auto-criadas — o usuário escolhe).
     *
     * @return list<array{icone: string, titulo: string, detalhe: string, area: string}>
     */
    public static function sugestoes(): array
    {
        return [
            ['icone' => '💧', 'titulo' => 'Beber água', 'detalhe' => '2L ao longo do dia', 'area' => 'bemestar'],
            ['icone' => '🏃', 'titulo' => 'Mover o corpo', 'detalhe' => '30 min de movimento', 'area' => 'academia'],
            ['icone' => '📚', 'titulo' => 'Estudar / ler', 'detalhe' => '25 min focados', 'area' => 'estudos'],
            ['icone' => '💰', 'titulo' => 'Registrar gastos', 'detalhe' => 'Anotar o dia', 'area' => 'financas'],
            ['icone' => '🧘', 'titulo' => 'Respirar / meditar', 'detalhe' => '5–10 minutos', 'area' => 'bemestar'],
            ['icone' => '✍️', 'titulo' => 'Escrever no diário', 'detalhe' => 'Uma reflexão curta', 'area' => 'geral'],
            ['icone' => '😴', 'titulo' => 'Dormir cedo', 'detalhe' => 'Deitar até 23h', 'area' => 'bemestar'],
            ['icone' => '📵', 'titulo' => 'Detox digital', 'detalhe' => '1h sem redes', 'area' => 'geral'],
        ];
    }
}
