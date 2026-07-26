<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('academia_treinos', function (Blueprint $table) {
            $table->timestamp('concluido_em')->nullable()->after('ativo');
            $table->unsignedInteger('volume_kg')->default(0)->after('concluido_em');
        });

        Schema::create('academia_treino_exercicios', function (Blueprint $table) {
            $table->id();
            $table->foreignId('treino_id')->constrained('academia_treinos')->cascadeOnDelete();
            $table->string('exercicio_chave', 64);
            $table->string('nome');
            $table->string('icone', 16)->default('💪');
            $table->string('grupo', 40);
            $table->unsignedTinyInteger('series')->default(3);
            $table->unsignedSmallInteger('reps')->default(10);
            $table->unsignedSmallInteger('carga_kg')->default(0);
            $table->unsignedTinyInteger('ordem')->default(0);
            $table->boolean('concluido')->default(false);
            $table->timestamps();

            $table->index(['treino_id', 'ordem']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('academia_treino_exercicios');

        Schema::table('academia_treinos', function (Blueprint $table) {
            $table->dropColumn(['concluido_em', 'volume_kg']);
        });
    }
};
