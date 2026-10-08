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
        Schema::table('users', function (Blueprint $table) {
            // null (the default) = unrestricted, sees every page — preserves
            // current behavior for every existing account. A JSON array of
            // page keys (see User::PAGES) restricts a user to just those,
            // opt-in only via the Users admin screen. Super Admins always
            // have full access regardless of this column (enforced in code,
            // not here, so promoting someone to Super Admin never needs a
            // data migration).
            $table->json('page_access')->nullable()->after('role');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('page_access');
        });
    }
};
