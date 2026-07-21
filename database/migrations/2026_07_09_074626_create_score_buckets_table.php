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
        Schema::create('score_buckets', function (Blueprint $table) {
            $table->id();
            $table->string('metric');
            $table->decimal('min_rate', 8, 2)->nullable();
            $table->decimal('score', 5, 2);
            $table->timestamps();

            $table->index(['metric', 'min_rate']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('score_buckets');
    }
};
