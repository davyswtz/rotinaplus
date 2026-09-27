<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Cria a tabela de reflexões semanais (texto livre sobre a semana).
     */
    public function up(): void
    {
        Schema::create('reflexoes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('usuario_id')->constrained('usuarios')->cascadeOnDelete();
            $table->date('semana_inicio'); // segunda-feira da semana em questão
            $table->longText('texto')->nullable();
            $table->timestamps();

            $table->unique(['usuario_id', 'semana_inicio']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('reflexoes');
    }
};
