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
        Schema::create('filter_summaries', function (Blueprint $table) {
            $table->id();
            $table->json('filters')->nullable();
            $table->string('provider');
            $table->text('custom_prompt')->nullable();
            $table->longText('summary');
            $table->unsignedInteger('cycle_count');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('filter_summaries');
    }
};
