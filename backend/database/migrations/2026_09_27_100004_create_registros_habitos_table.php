<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Cria a tabela de registros de hábitos: marca se um hábito foi
     * concluído em um determinado dia (as "bolinhas" do quadro semanal).
     */
    public function up(): void
    {
        Schema::create('registros_habitos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('habito_id')->constrained('habitos')->cascadeOnDelete();
            $table->date('data');
            $table->boolean('concluido')->default(false);
            $table->timestamps();

            $table->unique(['habito_id', 'data']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('registros_habitos');
    }
};
