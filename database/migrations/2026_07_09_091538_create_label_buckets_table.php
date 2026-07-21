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
        Schema::create('label_buckets', function (Blueprint $table) {
            $table->id();
            $table->string('metric');
            $table->decimal('min_score', 6, 2)->nullable();
            $table->string('label');
            $table->timestamps();

            $table->index(['metric', 'min_score']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('label_buckets');
    }
};
