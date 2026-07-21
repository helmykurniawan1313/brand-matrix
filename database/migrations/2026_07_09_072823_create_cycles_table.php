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
        Schema::create('cycles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('account_id')->constrained()->cascadeOnDelete();
            $table->date('cycle_start_date');
            $table->date('cycle_end_date');
            $table->unsignedBigInteger('start_follower');
            $table->unsignedBigInteger('end_follower');
            $table->unsignedBigInteger('reach');
            $table->unsignedBigInteger('views');
            $table->unsignedBigInteger('engagement');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('cycles');
    }
};
