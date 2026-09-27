<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Cria a tabela de registros de humor (emoji escolhido em cada dia).
     */
    public function up(): void
    {
        Schema::create('registros_humor', function (Blueprint $table) {
            $table->id();
            $table->foreignId('usuario_id')->constrained('usuarios')->cascadeOnDelete();
            $table->date('data');
            // humor do dia: muito_feliz, feliz, neutro, triste, muito_triste
            $table->string('humor');
            $table->timestamps();

            $table->unique(['usuario_id', 'data']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('registros_humor');
    }
};
