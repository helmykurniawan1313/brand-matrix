<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('content_insights', function (Blueprint $table) {
            $table->id();
            $table->foreignId('account_id')->constrained()->cascadeOnDelete();
            $table->foreignId('cycle_id')->constrained()->cascadeOnDelete();

            // Viewers, split by content type (from Instagram "Views by content type")
            $table->unsignedBigInteger('viewers_posts')->default(0);
            $table->unsignedBigInteger('viewers_reels')->default(0);
            $table->unsignedBigInteger('viewers_story')->default(0);

            // Interactions, split by content type (from "Interactions by content type")
            $table->unsignedBigInteger('interactions_posts')->default(0);
            $table->unsignedBigInteger('interactions_reels')->default(0);
            $table->unsignedBigInteger('interactions_story')->default(0);

            $table->timestamps();

            $table->unique(['account_id', 'cycle_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('content_insights');
    }
};
