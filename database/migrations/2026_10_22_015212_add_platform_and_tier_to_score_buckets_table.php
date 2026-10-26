<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('score_buckets', function (Blueprint $table) {
            $table->string('platform')->nullable()->after('metric');
            $table->string('tier')->nullable()->after('platform');

            $table->index(['platform', 'tier', 'metric', 'min_rate']);
        });
    }

    public function down(): void
    {
        Schema::table('score_buckets', function (Blueprint $table) {
            $table->dropIndex(['platform', 'tier', 'metric', 'min_rate']);
            $table->dropColumn(['platform', 'tier']);
        });
    }
};
