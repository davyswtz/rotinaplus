<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('habitos', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('icone', 16)->default('✨');
            $table->string('titulo');
            $table->string('detalhe')->nullable();
            $table->string('area', 32)->default('geral'); // geral|academia|financas|estudos|bemestar
            $table->string('frequencia', 16)->default('diario'); // diario|semanal
            $table->json('dias_semana')->nullable(); // [1..7] ISO quando semanal
            $table->unsignedInteger('xp')->default(15);
            $table->boolean('ativo')->default(true);
            $table->unsignedSmallInteger('ordem')->default(0);
            $table->timestamps();

            $table->index(['user_id', 'ativo']);
        });

        Schema::create('habito_checkins', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('habito_id')->constrained('habitos')->cascadeOnDelete();
            $table->date('data');
            $table->boolean('concluida')->default(false);
            $table->timestamp('concluida_em')->nullable();
            $table->unsignedTinyInteger('humor')->nullable(); // 1–5
            $table->text('nota')->nullable();
            $table->timestamps();

            $table->unique(['habito_id', 'data']);
            $table->index(['user_id', 'data']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('habito_checkins');
        Schema::dropIfExists('habitos');
    }
};
