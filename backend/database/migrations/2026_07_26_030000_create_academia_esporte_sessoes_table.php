<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('academia_esporte_sessoes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('esporte_chave', 40);
            $table->string('icone', 16);
            $table->string('nome');
            $table->unsignedSmallInteger('minutos')->default(30);
            $table->unsignedInteger('distancia_metros')->nullable();
            $table->unsignedInteger('xp')->default(20);
            $table->date('data');
            $table->string('nota')->nullable();
            $table->timestamps();

            $table->index(['user_id', 'data']);
            $table->index(['user_id', 'esporte_chave']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('academia_esporte_sessoes');
    }
};
