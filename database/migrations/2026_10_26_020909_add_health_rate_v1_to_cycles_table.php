<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('cycles', function (Blueprint $table) {
            $table->decimal('health_rate_v1', 6, 2)->nullable()->after('needs_check');
            $table->string('health_label_v1')->nullable()->after('health_rate_v1');
            $table->timestamp('formula_changed_at')->nullable()->after('health_label_v1');
        });
    }

    public function down(): void
    {
        Schema::table('cycles', function (Blueprint $table) {
            $table->dropColumn(['health_rate_v1', 'health_label_v1', 'formula_changed_at']);
        });
    }
};
