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
        // Add-then-copy-then-drop-then-rename instead of ->nullable()->change()
        // (needs doctrine/dbal, not installed) — stays portable across MySQL
        // and the SQLite test suite. ads becomes tri-state: true/false/null
        // ("-" — unknown/not recorded), replacing the previous always-Yes-or-No boolean.
        Schema::table('performances', function (Blueprint $table) {
            $table->boolean('ads_new')->nullable()->after('ads');
        });

        DB::table('performances')->update(['ads_new' => DB::raw('ads')]);

        Schema::table('performances', function (Blueprint $table) {
            $table->dropColumn('ads');
        });

        Schema::table('performances', function (Blueprint $table) {
            $table->renameColumn('ads_new', 'ads');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('performances', function (Blueprint $table) {
            $table->boolean('ads_old')->default(false)->after('ads');
        });

        DB::table('performances')->update(['ads_old' => DB::raw('COALESCE(ads, 0)')]);

        Schema::table('performances', function (Blueprint $table) {
            $table->dropColumn('ads');
        });

        Schema::table('performances', function (Blueprint $table) {
            $table->renameColumn('ads_old', 'ads');
        });
    }
};
