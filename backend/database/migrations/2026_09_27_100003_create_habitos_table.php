<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Cria a tabela de hábitos (linhas do quadro de hábitos, ex: academia, alongamento).
     */
    public function up(): void
    {
        Schema::create('habitos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('usuario_id')->constrained('usuarios')->cascadeOnDelete();
            $table->string('nome');
            $table->unsignedInteger('ordem')->default(0); // ordem de exibição no quadro
            $table->boolean('ativo')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('habitos');
    }
};
