<?php

namespace App\Support;

use App\Models\Perfil;
use Illuminate\Support\Str;

final class NickHelper
{
    public static function normalizar(string $nick): string
    {
        $nick = Str::lower(trim($nick));
        $nick = ltrim($nick, '@');
        $nick = preg_replace('/[^a-z0-9_]/', '', $nick) ?? '';

        return $nick;
    }

    public static function validarFormato(string $nick): bool
    {
        return (bool) preg_match('/^[a-z0-9_]{3,32}$/', $nick);
    }

    /** Gera nick único a partir de um nome. */
    public static function gerarUnico(string $base, ?int $ignorarPerfilId = null): string
    {
        $slug = self::normalizar(Str::ascii($base));
        if ($slug === '' || strlen($slug) < 3) {
            $slug = 'heroi'.substr(md5($base.microtime(true)), 0, 4);
        }
        $slug = substr($slug, 0, 28);

        $candidato = $slug;
        $n = 1;
        while (self::existe($candidato, $ignorarPerfilId)) {
            $n++;
            $candidato = substr($slug, 0, 28).$n;
        }

        return $candidato;
    }

    public static function existe(string $nick, ?int $ignorarPerfilId = null): bool
    {
        $q = Perfil::query()->where('nick', $nick);
        if ($ignorarPerfilId !== null) {
            $q->where('id', '!=', $ignorarPerfilId);
        }

        return $q->exists();
    }
}
