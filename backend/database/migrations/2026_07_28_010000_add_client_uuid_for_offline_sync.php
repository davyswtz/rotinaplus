<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('missoes', function (Blueprint $table) {
            $table->uuid('client_uuid')->nullable()->after('ordem');
            $table->unique(['user_id', 'client_uuid']);
        });

        Schema::table('habitos', function (Blueprint $table) {
            $table->uuid('client_uuid')->nullable()->after('ativo');
            $table->unique(['user_id', 'client_uuid']);
        });

        Schema::table('financas_transacoes', function (Blueprint $table) {
            $table->uuid('client_uuid')->nullable();
            $table->unique(['user_id', 'client_uuid']);
        });

        Schema::table('financas_metas', function (Blueprint $table) {
            $table->uuid('client_uuid')->nullable();
            $table->unique(['user_id', 'client_uuid']);
        });

        Schema::table('academia_esporte_sessoes', function (Blueprint $table) {
            $table->uuid('client_uuid')->nullable();
            $table->unique(['user_id', 'client_uuid']);
        });

        Schema::table('academia_treinos', function (Blueprint $table) {
            $table->uuid('client_uuid')->nullable();
            $table->unique(['user_id', 'client_uuid']);
        });
    }

    public function down(): void
    {
        foreach ([
            'missoes',
            'habitos',
            'financas_transacoes',
            'financas_metas',
            'academia_esporte_sessoes',
            'academia_treinos',
        ] as $tableName) {
            Schema::table($tableName, function (Blueprint $table) {
                $table->dropUnique(['user_id', 'client_uuid']);
                $table->dropColumn('client_uuid');
            });
        }
    }
};
