<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Cria a tabela de transações financeiras (receitas e despesas).
     */
    public function up(): void
    {
        Schema::create('transacoes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('usuario_id')->constrained('usuarios')->cascadeOnDelete();
            $table->string('tipo'); // 'receita' ou 'despesa'
            $table->string('categoria'); // ex: Alimentação, Transporte, Salário...
            $table->string('descricao')->nullable();
            $table->decimal('valor', 10, 2);
            $table->date('data');
            $table->timestamps();

            $table->index(['usuario_id', 'data']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('transacoes');
    }
};
