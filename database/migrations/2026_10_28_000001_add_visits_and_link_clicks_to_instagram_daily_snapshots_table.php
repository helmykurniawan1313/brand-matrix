<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('instagram_daily_snapshots', function (Blueprint $table) {
            $table->unsignedBigInteger('profile_visits')->nullable()->after('views');
            $table->unsignedBigInteger('link_clicks')->nullable()->after('profile_visits');
        });
    }

    public function down(): void
    {
        Schema::table('instagram_daily_snapshots', function (Blueprint $table) {
            $table->dropColumn(['profile_visits', 'link_clicks']);
        });
    }
};
