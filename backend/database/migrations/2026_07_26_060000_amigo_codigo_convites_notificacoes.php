<?php

use App\Support\CodigoAmigoHelper;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasColumn('perfis', 'codigo_amigo')) {
            Schema::table('perfis', function (Blueprint $table) {
                $table->string('codigo_amigo', 12)->nullable()->after('nome_heroi');
            });
        }

        if (Schema::hasColumn('perfis', 'nick')) {
            foreach (DB::table('perfis')->select('id', 'nick')->get() as $perfil) {
                DB::table('perfis')->where('id', $perfil->id)->update([
                    'codigo_amigo' => $perfil->nick,
                ]);
            }

            Schema::table('perfis', function (Blueprint $table) {
                $table->dropUnique(['nick']);
                $table->dropColumn('nick');
            });
        }

        $usados = [];
        foreach (DB::table('perfis')->select('id', 'codigo_amigo')->get() as $perfil) {
            $codigo = CodigoAmigoHelper::normalizar((string) ($perfil->codigo_amigo ?? ''));
            if (! CodigoAmigoHelper::validarFormato($codigo) || isset($usados[$codigo])) {
                $codigo = CodigoAmigoHelper::gerarUnico($usados);
            } else {
                $usados[$codigo] = true;
            }
            DB::table('perfis')->where('id', $perfil->id)->update(['codigo_amigo' => $codigo]);
        }

        $this->ensureUniqueIndex('perfis', 'codigo_amigo');

        if (! Schema::hasColumn('amizades', 'status')) {
            Schema::table('amizades', function (Blueprint $table) {
                $table->string('status', 16)->default('aceito')->after('amigo_id');
            });
            DB::table('amizades')->update(['status' => 'aceito']);
        }

        Schema::table('notificacoes', function (Blueprint $table) {
            if (! Schema::hasColumn('notificacoes', 'tipo')) {
                $table->string('tipo', 40)->nullable()->after('mensagem');
            }
            if (! Schema::hasColumn('notificacoes', 'referencia_id')) {
                $table->unsignedBigInteger('referencia_id')->nullable()->after('tipo');
            }
            if (! Schema::hasColumn('notificacoes', 'payload')) {
                $table->json('payload')->nullable()->after('referencia_id');
            }
        });
    }

    public function down(): void
    {
        Schema::table('notificacoes', function (Blueprint $table) {
            foreach (['payload', 'referencia_id', 'tipo'] as $col) {
                if (Schema::hasColumn('notificacoes', $col)) {
                    $table->dropColumn($col);
                }
            }
        });

        if (Schema::hasColumn('amizades', 'status')) {
            Schema::table('amizades', function (Blueprint $table) {
                $table->dropColumn('status');
            });
        }

        if (Schema::hasColumn('perfis', 'codigo_amigo') && ! Schema::hasColumn('perfis', 'nick')) {
            Schema::table('perfis', function (Blueprint $table) {
                $table->string('nick', 32)->nullable()->after('nome_heroi');
            });
            foreach (DB::table('perfis')->select('id', 'codigo_amigo')->get() as $perfil) {
                DB::table('perfis')->where('id', $perfil->id)->update([
                    'nick' => strtolower((string) $perfil->codigo_amigo),
                ]);
            }
            Schema::table('perfis', function (Blueprint $table) {
                $table->dropUnique(['codigo_amigo']);
                $table->dropColumn('codigo_amigo');
                $table->unique('nick');
            });
        }
    }

    private function ensureUniqueIndex(string $table, string $column): void
    {
        foreach (Schema::getIndexes($table) as $index) {
            if (($index['unique'] ?? false) && in_array($column, $index['columns'] ?? [], true)) {
                return;
            }
        }

        Schema::table($table, function (Blueprint $blueprint) use ($column) {
            $blueprint->unique($column);
        });
    }
};
