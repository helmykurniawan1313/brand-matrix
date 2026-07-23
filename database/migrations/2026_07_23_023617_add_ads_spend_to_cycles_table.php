<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('cycles', function (Blueprint $table) {
            $table->string('ads_currency', 3)->nullable()->after('story_performance');

            $table->boolean('reach_ads_used')->default(false)->after('ads_currency');
            $table->decimal('reach_ads_spend', 15, 2)->nullable()->after('reach_ads_used');

            $table->boolean('views_ads_used')->default(false)->after('reach_ads_spend');
            $table->decimal('views_ads_spend', 15, 2)->nullable()->after('views_ads_used');

            $table->boolean('engagement_ads_used')->default(false)->after('views_ads_spend');
            $table->decimal('engagement_ads_spend', 15, 2)->nullable()->after('engagement_ads_used');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('cycles', function (Blueprint $table) {
            $table->dropColumn([
                'ads_currency',
                'reach_ads_used',
                'reach_ads_spend',
                'views_ads_used',
                'views_ads_spend',
                'engagement_ads_used',
                'engagement_ads_spend',
            ]);
        });
    }
};
