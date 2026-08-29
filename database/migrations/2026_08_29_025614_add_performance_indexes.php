<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Indexes for columns that every controller filters/sorts on heavily
     * (cycle_start_date, platform, post_date), but that only had an implicit
     * index via their foreign key (account_id/cycle_id already indexed by
     * ->constrained()). No behavior change — purely speeds up the WHERE/ORDER BY
     * clauses already used throughout CycleController/PerformanceController/
     * ViewsTrendController/DashboardController as these tables grow.
     */
    public function up(): void
    {
        Schema::table('cycles', function (Blueprint $table) {
            $table->index('cycle_start_date');
            $table->index(['account_id', 'platform']);
        });

        Schema::table('performances', function (Blueprint $table) {
            $table->index('post_date');
            $table->index(['account_id', 'platform']);
        });
    }

    public function down(): void
    {
        Schema::table('cycles', function (Blueprint $table) {
            $table->dropIndex('cycles_cycle_start_date_index');
            $table->dropIndex('cycles_account_id_platform_index');
        });

        Schema::table('performances', function (Blueprint $table) {
            $table->dropIndex('performances_post_date_index');
            $table->dropIndex('performances_account_id_platform_index');
        });
    }
};
