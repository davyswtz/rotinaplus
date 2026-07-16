<?php

namespace App\Support;

use Carbon\Carbon;

final class SemanaHelper
{
    /** Segunda-feira da semana atual (timezone app). */
    public static function inicioAtual(?Carbon $ref = null): Carbon
    {
        $ref ??= now('America/Sao_Paulo');

        return $ref->copy()->startOfWeek(Carbon::MONDAY)->startOfDay();
    }
}
