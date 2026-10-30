<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Meta's daily export CSVs report net daily changes for "Follows" and
     * "Interactions" (e.g. unlikes/deleted comments outnumbering new ones on
     * a given day), which can be negative — the unsigned columns rejected
     * those rows with "Out of range value" when bulk-imported.
     */
    public function up(): void
    {
        Schema::table('instagram_daily_snapshots', function (Blueprint $table) {
            $table->bigInteger('followers_count')->nullable()->change();
            $table->bigInteger('total_interactions')->nullable()->change();
        });
    }

    public function down(): void
    {
        Schema::table('instagram_daily_snapshots', function (Blueprint $table) {
            $table->unsignedBigInteger('followers_count')->nullable()->change();
            $table->unsignedBigInteger('total_interactions')->nullable()->change();
        });
    }
};
