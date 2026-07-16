<?php

namespace App\Support;

/**
 * Pool de missões padrão do dia + cálculo de XP alinhado ao crescimento do perfil.
 *
 * Crescimento: nível sobe quando xp_atual >= xp_proximo_nivel; próximo nível *= 1.25.
 * Meta: completar as 5 missões padrão do dia ≈ 35% do XP necessário para o próximo nível.
 */
final class MissaoXpCalculator
{
    /** Fração do XP do nível coberta pelas 5 missões padrão (se todas forem concluídas). */
    public const ORCAMENTO_DIA_FRACAO = 0.35;

    /** Quantidade de missões geradas automaticamente por dia. */
    public const MISSOES_PADRAO_DIA = 5;

    /**
     * Catálogo (peso 1=leve, 2=média, 3=desafio).
     *
     * @return list<array{icone: string, titulo: string, detalhe: string, peso: int}>
     */
    public static function catalogo(): array
    {
        return [
            ['icone' => '💧', 'titulo' => 'Beber água', 'detalhe' => '2L ao longo do dia', 'peso' => 1],
            ['icone' => '🏃', 'titulo' => 'Treinar', 'detalhe' => '30 min de movimento', 'peso' => 3],
            ['icone' => '📚', 'titulo' => 'Estudar', 'detalhe' => '1 Pomodoro focado', 'peso' => 2],
            ['icone' => '🧘', 'titulo' => 'Meditar', 'detalhe' => '10 min de respiração', 'peso' => 2],
            ['icone' => '💰', 'titulo' => 'Registrar gastos', 'detalhe' => 'Anotar o dia no app', 'peso' => 1],
            ['icone' => '😴', 'titulo' => 'Dormir cedo', 'detalhe' => 'Deitar até 23h', 'peso' => 2],
            ['icone' => '🥗', 'titulo' => 'Comer bem', 'detalhe' => 'Uma refeição equilibrada', 'peso' => 2],
            ['icone' => '🚶', 'titulo' => 'Caminhar', 'detalhe' => '5.000 passos no dia', 'peso' => 2],
            ['icone' => '✍️', 'titulo' => 'Escrever diário', 'detalhe' => '5 minutos de reflexão', 'peso' => 1],
            ['icone' => '📵', 'titulo' => 'Detox digital', 'detalhe' => '1h sem redes sociais', 'peso' => 2],
            ['icone' => '🧹', 'titulo' => 'Organizar espaço', 'detalhe' => 'Arrumar mesa ou quarto', 'peso' => 1],
            ['icone' => '🦷', 'titulo' => 'Cuidados pessoais', 'detalhe' => 'Rotina completa de higiene', 'peso' => 1],
            ['icone' => '📞', 'titulo' => 'Conexão social', 'detalhe' => 'Falar com alguém querido', 'peso' => 1],
            ['icone' => '🎯', 'titulo' => 'Foco profundo', 'detalhe' => '45 min sem distrações', 'peso' => 3],
            ['icone' => '📖', 'titulo' => 'Ler', 'detalhe' => '20 páginas ou 15 min', 'peso' => 2],
            ['icone' => '🧊', 'titulo' => 'Alongar', 'detalhe' => '10 min de mobilidade', 'peso' => 1],
            ['icone' => '🧠', 'titulo' => 'Aprender algo novo', 'detalhe' => 'Uma aula ou tutorial curto', 'peso' => 2],
            ['icone' => '💳', 'titulo' => 'Revisar finanças', 'detalhe' => 'Checar saldo e metas', 'peso' => 2],
            ['icone' => '🛏️', 'titulo' => 'Fazer a cama', 'detalhe' => 'Começar o dia organizado', 'peso' => 1],
            ['icone' => '🎵', 'titulo' => 'Momento criativo', 'detalhe' => 'Música, desenho ou escrita', 'peso' => 2],
        ];
    }

    /**
     * Sorteia N missões distintas do catálogo.
     *
     * @return list<array{icone: string, titulo: string, detalhe: string, peso: int}>
     */
    public static function sortearPadrao(int $quantidade = self::MISSOES_PADRAO_DIA): array
    {
        $pool = self::catalogo();
        shuffle($pool);

        return array_slice($pool, 0, min($quantidade, count($pool)));
    }

    /**
     * XP justo para uma missão, com base no XP necessário para o próximo nível e no peso.
     *
     * Missões padrão do dia: o conjunto de 5 (pesos médios) soma ≈ 35% do nível.
     * Missão custom (extra): usa o mesmo fator unitário de uma missão de peso médio.
     */
    public static function calcularXp(int $xpProximoNivel, int $peso = 2, bool $ehPadraoDoDia = false): int
    {
        $peso = max(1, min(3, $peso));
        $xpProximoNivel = max(100, $xpProximoNivel);

        $orcamentoDia = (int) round($xpProximoNivel * self::ORCAMENTO_DIA_FRACAO);
        // Referência: 5 missões com peso médio 2 → soma de pesos = 10
        $xpPorPontoDePeso = $orcamentoDia / (self::MISSOES_PADRAO_DIA * 2);

        $xp = (int) round($xpPorPontoDePeso * $peso);

        // Missões extras (criadas pelo usuário) não devem farmar mais que uma missão média padrão.
        if (! $ehPadraoDoDia) {
            $teto = (int) round($xpPorPontoDePeso * 2);
            $xp = min($xp, $teto);
        }

        return max(8, $xp);
    }

    /** Estima peso de missão custom pela “carga” descrita no detalhe/título. */
    public static function estimarPeso(?string $titulo, ?string $detalhe): int
    {
        $texto = mb_strtolower(trim(($titulo ?? '').' '.($detalhe ?? '')));
        $len = mb_strlen($texto);

        if ($len >= 40 || preg_match('/\b(30|45|60)\s*min|pomodoro|treino|desafio|profunda?\b/u', $texto)) {
            return 3;
        }

        if ($len <= 18 || preg_match('/\b(5|10)\s*min|r[aá]pido|simples|leve\b/u', $texto)) {
            return 1;
        }

        return 2;
    }
}
