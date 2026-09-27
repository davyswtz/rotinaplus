<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Cria a tabela de tarefas (itens de rotina exibidos na visão semanal).
     */
    public function up(): void
    {
        Schema::create('tarefas', function (Blueprint $table) {
            $table->id();
            $table->foreignId('usuario_id')->constrained('usuarios')->cascadeOnDelete();
            $table->foreignId('categoria_id')->nullable()->constrained('categorias')->nullOnDelete();
            $table->string('titulo');
            $table->text('descricao')->nullable();
            $table->date('data'); // dia da semana ao qual a tarefa pertence
            $table->boolean('concluida')->default(false);
            $table->timestamps();

            $table->index(['usuario_id', 'data']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tarefas');
    }
};
