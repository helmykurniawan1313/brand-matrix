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
        Schema::create('performance_ig_snapshots', function (Blueprint $table) {
            $table->id();
            $table->foreignId('performance_id')->constrained()->cascadeOnDelete();

            // Feed/carousel metrics
            $table->unsignedBigInteger('reach')->nullable();
            $table->unsignedBigInteger('likes')->nullable();
            $table->unsignedBigInteger('comments')->nullable();
            $table->unsignedBigInteger('shares')->nullable();
            $table->unsignedBigInteger('saved')->nullable();
            $table->unsignedBigInteger('total_interactions')->nullable();

            // Reels-only metrics
            $table->unsignedBigInteger('views')->nullable();
            $table->unsignedBigInteger('ig_reels_avg_watch_time')->nullable();
            $table->unsignedBigInteger('ig_reels_video_view_total_time')->nullable();

            $table->timestamp('fetched_at');
            $table->timestamps();

            $table->index(['performance_id', 'fetched_at']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('performance_ig_snapshots');
    }
};
