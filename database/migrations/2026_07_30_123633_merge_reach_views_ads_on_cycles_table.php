<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Add-then-copy-then-drop instead of Schema::renameColumn() (needs
        // doctrine/dbal, not installed) or raw ALTER ... CHANGE (MySQL-only,
        // breaks the SQLite test suite). No existing cycle has reach_ads_used
        // or views_ads_used set (confirmed before writing this migration), so
        // there's no data to actually carry over, but this stays portable
        // regardless.
        Schema::table('cycles', function (Blueprint $table) {
            $table->boolean('reach_views_ads_used')->default(false)->after('ads_currency');
            $table->decimal('reach_views_ads_spend', 15, 2)->nullable()->after('reach_views_ads_used');
        });

        DB::table('cycles')->update([
            'reach_views_ads_used' => DB::raw('reach_ads_used'),
            'reach_views_ads_spend' => DB::raw('reach_ads_spend'),
        ]);

        Schema::table('cycles', function (Blueprint $table) {
            $table->dropColumn(['reach_ads_used', 'reach_ads_spend', 'views_ads_used', 'views_ads_spend']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('cycles', function (Blueprint $table) {
            $table->boolean('reach_ads_used')->default(false)->after('ads_currency');
            $table->decimal('reach_ads_spend', 15, 2)->nullable()->after('reach_ads_used');
            $table->boolean('views_ads_used')->default(false)->after('reach_ads_spend');
            $table->decimal('views_ads_spend', 15, 2)->nullable()->after('views_ads_used');
        });

        DB::table('cycles')->update([
            'reach_ads_used' => DB::raw('reach_views_ads_used'),
            'reach_ads_spend' => DB::raw('reach_views_ads_spend'),
        ]);

        Schema::table('cycles', function (Blueprint $table) {
            $table->dropColumn(['reach_views_ads_used', 'reach_views_ads_spend']);
        });
    }
};
