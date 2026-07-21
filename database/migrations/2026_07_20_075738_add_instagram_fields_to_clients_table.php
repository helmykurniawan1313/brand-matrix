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
        Schema::table('clients', function (Blueprint $table) {
            $table->string('ig_business_id')->nullable()->unique();
            $table->string('ig_username')->nullable();
            $table->text('ig_access_token')->nullable();
            $table->timestamp('ig_token_expires_at')->nullable();
            $table->timestamp('ig_connected_at')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('clients', function (Blueprint $table) {
            $table->dropColumn([
                'ig_business_id',
                'ig_username',
                'ig_access_token',
                'ig_token_expires_at',
                'ig_connected_at',
            ]);
        });
    }
};
