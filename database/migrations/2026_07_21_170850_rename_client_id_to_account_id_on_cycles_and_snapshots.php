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
            $table->renameColumn('client_id', 'account_id');
        });

        Schema::table('instagram_daily_snapshots', function (Blueprint $table) {
            $table->renameColumn('client_id', 'account_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('cycles', function (Blueprint $table) {
            $table->renameColumn('account_id', 'client_id');
        });

        Schema::table('instagram_daily_snapshots', function (Blueprint $table) {
            $table->renameColumn('account_id', 'client_id');
        });
    }
};
