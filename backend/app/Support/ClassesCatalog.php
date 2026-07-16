<?php

namespace App\Support;

final class ClassesCatalog
{
    /**
     * Catálogo de classes do onboarding (fonte única para API e validação).
     *
     * @return list<array{
     *   key: string,
     *   nome: string,
     *   emoji: string,
     *   descricao: string,
     *   bonus: list<string>,
     *   tema: string
     * }>
     */
    public static function all(): array
    {
        return [
            [
                'key' => 'guerreiro',
                'nome' => 'Guerreiro',
                'emoji' => '⚔️',
                'descricao' => 'Foco em treinos e disciplina física',
                'bonus' => [
                    '+20% XP na academia',
                    'Streak bônus x2',
                    'Resistência lendária',
                ],
                'tema' => 'laranja',
            ],
            [
                'key' => 'estudioso',
                'nome' => 'Estudioso',
                'emoji' => '📚',
                'descricao' => 'Domina conhecimento e aprendizado',
                'bonus' => [
                    '+20% XP nos estudos',
                    'Memória aprimorada',
                    'Foco sobrenatural',
                ],
                'tema' => 'ciano',
            ],
            [
                'key' => 'investidor',
                'nome' => 'Investidor',
                'emoji' => '💰',
                'descricao' => 'Mestre das finanças e crescimento',
                'bonus' => [
                    '+20% XP em finanças',
                    'Renda passiva bônus',
                    'Visão de mercado',
                ],
                'tema' => 'verde',
            ],
            [
                'key' => 'sabio',
                'nome' => 'Sábio',
                'emoji' => '🔮',
                'descricao' => 'Equilibra todas as áreas da vida',
                'bonus' => [
                    '+10% XP em tudo',
                    'Bônus de equilíbrio',
                    'Sabedoria ancestral',
                ],
                'tema' => 'roxo',
            ],
        ];
    }

    /**
     * @return list<string>
     */
    public static function nomes(): array
    {
        return array_column(self::all(), 'nome');
    }

    public static function findByNome(string $nome): ?array
    {
        foreach (self::all() as $classe) {
            if (strcasecmp($classe['nome'], $nome) === 0) {
                return $classe;
            }
        }

        return null;
    }

    public static function findByKey(string $key): ?array
    {
        foreach (self::all() as $classe) {
            if ($classe['key'] === $key) {
                return $classe;
            }
        }

        return null;
    }
}
