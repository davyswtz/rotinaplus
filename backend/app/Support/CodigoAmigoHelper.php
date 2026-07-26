<?php

namespace App\Support;

final class CodigoAmigoHelper
{
    public const TAMANHO = 6;

    /** Gera código único de 6 caracteres A-Z0-9. */
    public static function gerarUnico(array &$usadosEmMemoria = []): string
    {
        do {
            $codigo = self::aleatorio();
        } while (
            isset($usadosEmMemoria[$codigo])
            || self::existe($codigo)
        );

        $usadosEmMemoria[$codigo] = true;

        return $codigo;
    }

    public static function normalizar(string $codigo): string
    {
        $codigo = strtoupper(trim($codigo));
        $codigo = ltrim($codigo, '#');

        return preg_replace('/[^A-Z0-9]/', '', $codigo) ?? '';
    }

    public static function validarFormato(string $codigo): bool
    {
        return (bool) preg_match('/^[A-Z0-9]{6,12}$/', $codigo);
    }

    public static function existe(string $codigo): bool
    {
        if (! \Illuminate\Support\Facades\Schema::hasTable('perfis')) {
            return false;
        }

        if (! \Illuminate\Support\Facades\Schema::hasColumn('perfis', 'codigo_amigo')) {
            return false;
        }

        return \App\Models\Perfil::query()->where('codigo_amigo', $codigo)->exists();
    }

    private static function aleatorio(): string
    {
        $chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // sem I/O/0/1
        $out = '';
        for ($i = 0; $i < self::TAMANHO; $i++) {
            $out .= $chars[random_int(0, strlen($chars) - 1)];
        }

        return $out;
    }
}
