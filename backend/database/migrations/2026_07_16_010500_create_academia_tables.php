<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('academia_configs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete()->unique();
            $table->unsignedTinyInteger('meta_semana')->default(5);
            $table->unsignedInteger('sequencia_treinos')->default(0);
            $table->timestamps();
        });

        Schema::create('academia_dias', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->date('semana_inicio');
            $table->string('dia_chave', 8);
            $table->string('label', 8);
            $table->string('foco', 64);
            $table->boolean('is_rest')->default(false);
            $table->boolean('concluido')->default(false);
            $table->unsignedTinyInteger('ordem')->default(0);
            $table->timestamps();

            $table->unique(['user_id', 'semana_inicio', 'dia_chave']);
        });

        Schema::create('academia_volumes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->date('semana_inicio');
            $table->string('dia_chave', 8);
            $table->string('label', 8);
            $table->unsignedInteger('kg')->default(0);
            $table->timestamps();

            $table->unique(['user_id', 'semana_inicio', 'dia_chave']);
        });

        Schema::create('academia_treinos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('foco', 64);
            $table->string('titulo');
            $table->unsignedTinyInteger('exercicios')->default(0);
            $table->unsignedSmallInteger('minutos')->default(0);
            $table->unsignedInteger('xp')->default(0);
            $table->string('dia_chave', 8)->nullable();
            $table->boolean('ativo')->default(false);
            $table->timestamps();

            $table->index(['user_id', 'ativo']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('academia_treinos');
        Schema::dropIfExists('academia_volumes');
        Schema::dropIfExists('academia_dias');
        Schema::dropIfExists('academia_configs');
    }
};
