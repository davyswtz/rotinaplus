<?php

namespace App\Support;

final class EsporteCatalog
{
    /**
     * @return list<array{
     *   chave: string,
     *   nome: string,
     *   icone: string,
     *   descricao: string,
     *   minutos_padrao: int,
     *   usa_distancia: bool
     * }>
     */
    public static function all(): array
    {
        return [
            [
                'chave' => 'corrida',
                'nome' => 'Corrida',
                'icone' => '🏃',
                'descricao' => 'Corrida ao ar livre ou esteira',
                'minutos_padrao' => 30,
                'usa_distancia' => true,
            ],
            [
                'chave' => 'natacao',
                'nome' => 'Natação',
                'icone' => '🏊',
                'descricao' => 'Piscina ou águas abertas',
                'minutos_padrao' => 40,
                'usa_distancia' => true,
            ],
            [
                'chave' => 'volei',
                'nome' => 'Vôlei',
                'icone' => '🏐',
                'descricao' => 'Quadra ou praia',
                'minutos_padrao' => 60,
                'usa_distancia' => false,
            ],
            [
                'chave' => 'futebol',
                'nome' => 'Futebol',
                'icone' => '⚽',
                'descricao' => 'Campo, society ou futsal',
                'minutos_padrao' => 60,
                'usa_distancia' => false,
            ],
            [
                'chave' => 'basquete',
                'nome' => 'Basquete',
                'icone' => '🏀',
                'descricao' => 'Quadra ou streetball',
                'minutos_padrao' => 45,
                'usa_distancia' => false,
            ],
            [
                'chave' => 'ciclismo',
                'nome' => 'Ciclismo',
                'icone' => '🚴',
                'descricao' => 'Bike de rua ou indoor',
                'minutos_padrao' => 45,
                'usa_distancia' => true,
            ],
            [
                'chave' => 'tenis',
                'nome' => 'Tênis',
                'icone' => '🎾',
                'descricao' => 'Simples ou duplas',
                'minutos_padrao' => 60,
                'usa_distancia' => false,
            ],
            [
                'chave' => 'caminhada',
                'nome' => 'Caminhada',
                'icone' => '🚶',
                'descricao' => 'Passeio ativo',
                'minutos_padrao' => 30,
                'usa_distancia' => true,
            ],
            [
                'chave' => 'yoga',
                'nome' => 'Yoga',
                'icone' => '🧘',
                'descricao' => 'Mobilidade e respiração',
                'minutos_padrao' => 30,
                'usa_distancia' => false,
            ],
            [
                'chave' => 'artes_marciais',
                'nome' => 'Artes marciais',
                'icone' => '🥋',
                'descricao' => 'Jiu-jitsu, judô, boxe…',
                'minutos_padrao' => 60,
                'usa_distancia' => false,
            ],
            [
                'chave' => 'crossfit',
                'nome' => 'CrossFit',
                'icone' => '💥',
                'descricao' => 'WOD e condicionamento',
                'minutos_padrao' => 45,
                'usa_distancia' => false,
            ],
            [
                'chave' => 'surf',
                'nome' => 'Surf',
                'icone' => '🏄',
                'descricao' => 'Mar ou piscina de ondas',
                'minutos_padrao' => 90,
                'usa_distancia' => false,
            ],
        ];
    }

    public static function find(string $chave): ?array
    {
        foreach (self::all() as $esporte) {
            if ($esporte['chave'] === $chave) {
                return $esporte;
            }
        }

        return null;
    }
}
