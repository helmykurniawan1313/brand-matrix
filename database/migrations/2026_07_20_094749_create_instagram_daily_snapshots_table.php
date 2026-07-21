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
        Schema::create('instagram_daily_snapshots', function (Blueprint $table) {
            $table->id();
            $table->foreignId('client_id')->constrained()->cascadeOnDelete();
            $table->date('captured_date');
            $table->unsignedBigInteger('followers_count')->nullable();
            $table->unsignedBigInteger('media_count')->nullable();
            $table->unsignedBigInteger('reach')->nullable();
            $table->unsignedBigInteger('accounts_engaged')->nullable();
            $table->unsignedBigInteger('total_interactions')->nullable();
            $table->timestamp('captured_at');
            $table->timestamps();

            $table->unique(['client_id', 'captured_date']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('instagram_daily_snapshots');
    }
};
