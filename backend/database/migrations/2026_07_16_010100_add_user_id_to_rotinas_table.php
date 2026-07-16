<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('rotinas', function (Blueprint $table) {
            if (! Schema::hasColumn('rotinas', 'user_id')) {
                $table->foreignId('user_id')
                    ->nullable()
                    ->after('id')
                    ->constrained()
                    ->cascadeOnDelete();
            }
        });
    }

    public function down(): void
    {
        Schema::table('rotinas', function (Blueprint $table) {
            if (Schema::hasColumn('rotinas', 'user_id')) {
                $table->dropConstrainedForeignId('user_id');
            }
        });
    }
};
