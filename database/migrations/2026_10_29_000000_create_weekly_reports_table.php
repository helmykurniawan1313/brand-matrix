<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('weekly_reports', function (Blueprint $table) {
            $table->id();
            $table->foreignId('account_id')->constrained()->cascadeOnDelete();
            $table->string('platform');
            $table->date('week_start_date');
            $table->date('week_end_date');
            $table->unsignedBigInteger('follower_count')->nullable();
            $table->unsignedBigInteger('reach')->nullable();
            $table->unsignedBigInteger('views')->nullable();
            $table->unsignedBigInteger('profile_visits')->nullable();
            $table->unsignedBigInteger('link_clicks')->nullable();
            $table->bigInteger('engagement')->nullable();
            $table->timestamps();

            $table->unique(['account_id', 'platform', 'week_start_date']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('weekly_reports');
    }
};
