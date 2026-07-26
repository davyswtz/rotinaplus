<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('perfis', function (Blueprint $table) {
            $table->string('nick', 32)->nullable()->after('nome_heroi');
        });

        // Backfill nicks únicos a partir do nome_heroi / user name.
        $perfis = DB::table('perfis')
            ->leftJoin('users', 'users.id', '=', 'perfis.user_id')
            ->select('perfis.id', 'perfis.nome_heroi', 'users.name')
            ->get();

        $usados = [];
        foreach ($perfis as $perfil) {
            $base = $this->slugificar((string) ($perfil->nome_heroi ?: $perfil->name ?: 'heroi'));
            $nick = $base;
            $n = 1;
            while (isset($usados[$nick]) || DB::table('perfis')->where('nick', $nick)->exists()) {
                $n++;
                $nick = $base.$n;
                if (strlen($nick) > 32) {
                    $nick = substr($base, 0, 28).$n;
                }
            }
            $usados[$nick] = true;
            DB::table('perfis')->where('id', $perfil->id)->update(['nick' => $nick]);
        }

        Schema::table('perfis', function (Blueprint $table) {
            $table->unique('nick');
        });

        Schema::create('amizades', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('amigo_id')->constrained('users')->cascadeOnDelete();
            $table->timestamps();

            $table->unique(['user_id', 'amigo_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('amizades');
        Schema::table('perfis', function (Blueprint $table) {
            $table->dropUnique(['nick']);
            $table->dropColumn('nick');
        });
    }

    private function slugificar(string $valor): string
    {
        $slug = Str::lower(Str::ascii($valor));
        $slug = preg_replace('/[^a-z0-9_]+/', '', str_replace(' ', '_', $slug)) ?? '';
        $slug = trim($slug, '_');
        if ($slug === '' || strlen($slug) < 3) {
            $slug = 'heroi'.substr(md5($valor.microtime()), 0, 4);
        }

        return substr($slug, 0, 32);
    }
};
