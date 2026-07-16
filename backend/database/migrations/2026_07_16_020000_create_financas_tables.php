<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('financas_transacoes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('tipo', 16); // receita | despesa
            $table->string('categoria', 32);
            $table->string('titulo');
            $table->string('icone', 16)->default('💳');
            $table->unsignedInteger('valor_centavos');
            $table->date('data');
            $table->timestamps();

            $table->index(['user_id', 'data']);
            $table->index(['user_id', 'tipo']);
        });

        Schema::create('financas_metas', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('titulo');
            $table->string('icone', 16)->default('🎯');
            $table->string('categoria', 32)->nullable();
            $table->unsignedInteger('valor_alvo_centavos');
            $table->unsignedInteger('valor_atual_centavos')->default(0);
            $table->timestamps();

            $table->index('user_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('financas_metas');
        Schema::dropIfExists('financas_transacoes');
    }
};
