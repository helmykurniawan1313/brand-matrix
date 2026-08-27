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
        Schema::table('performances', function (Blueprint $table) {
            // Nullable: a post with no matching cycle (none covers its date yet, or
            // none exists at all for that account/platform) simply stays unassigned.
            $table->foreignId('cycle_id')->nullable()->after('platform')->constrained()->nullOnDelete();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('performances', function (Blueprint $table) {
            $table->dropConstrainedForeignId('cycle_id');
        });
    }
};
