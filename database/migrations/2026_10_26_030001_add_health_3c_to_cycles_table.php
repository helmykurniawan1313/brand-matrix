<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('cycles', function (Blueprint $table) {
            $table->decimal('health_3c', 6, 2)->nullable()->after('formula_changed_at');
            $table->string('health_3c_label')->nullable()->after('health_3c');
        });
    }

    public function down(): void
    {
        Schema::table('cycles', function (Blueprint $table) {
            $table->dropColumn(['health_3c', 'health_3c_label']);
        });
    }
};
