<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Cria a tabela de registros de consumo de água por dia.
     */
    public function up(): void
    {
        Schema::create('registros_agua', function (Blueprint $table) {
            $table->id();
            $table->foreignId('usuario_id')->constrained('usuarios')->cascadeOnDelete();
            $table->date('data');
            $table->unsignedInteger('quantidade_ml')->default(0);
            $table->timestamps();

            $table->unique(['usuario_id', 'data']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('registros_agua');
    }
};
