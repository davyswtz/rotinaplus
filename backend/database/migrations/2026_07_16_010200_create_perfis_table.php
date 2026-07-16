<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('perfis', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete()->unique();
            $table->string('nome_heroi')->nullable();
            $table->string('avatar_key')->default('guara_serio');
            $table->string('classe')->default('Sábio');
            $table->string('emoji_classe', 16)->default('🔮');
            $table->unsignedInteger('nivel')->default(1);
            $table->unsignedInteger('xp_atual')->default(0);
            $table->unsignedInteger('xp_proximo_nivel')->default(500);
            $table->unsignedInteger('moedas')->default(0);
            $table->unsignedInteger('streak_dias')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('perfis');
    }
};
