<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('financas_conexoes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('provider', 32)->default('pluggy');
            $table->string('item_id')->nullable();
            $table->unsignedInteger('connector_id')->nullable();
            $table->string('connector_name')->nullable();
            $table->string('status', 32)->default('updated');
            $table->timestamp('last_sync_at')->nullable();
            $table->json('meta')->nullable();
            $table->timestamps();

            $table->unique(['user_id', 'provider', 'item_id']);
            $table->index(['user_id', 'provider']);
        });

        Schema::table('financas_transacoes', function (Blueprint $table) {
            $table->string('origem', 16)->default('manual')->after('data');
            $table->string('external_id')->nullable()->after('origem');
            $table->foreignId('conexao_id')->nullable()->after('external_id')
                ->constrained('financas_conexoes')->nullOnDelete();

            $table->unique(['user_id', 'origem', 'external_id']);
        });
    }

    public function down(): void
    {
        Schema::table('financas_transacoes', function (Blueprint $table) {
            $table->dropUnique(['user_id', 'origem', 'external_id']);
            $table->dropConstrainedForeignId('conexao_id');
            $table->dropColumn(['origem', 'external_id', 'conexao_id']);
        });

        Schema::dropIfExists('financas_conexoes');
    }
};
