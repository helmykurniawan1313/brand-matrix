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
        Schema::create('activity_logs', function (Blueprint $table) {
            $table->id();
            // Polymorphic target (loggable_type/loggable_id) instead of a per-model
            // table — intended to cover many editable models over time (Performance
            // first, Cycle/WeeklyReport/Account next), not just one.
            $table->string('loggable_type');
            $table->unsignedBigInteger('loggable_id');
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->string('action'); // created | updated | deleted
            // { field => [old, new], ... } — only the fields that actually changed,
            // so 'updated' rows with no real diff (e.g. a resave with no changes)
            // are simply not logged at all rather than recorded as noise.
            $table->json('changes')->nullable();
            $table->timestamps();

            $table->index(['loggable_type', 'loggable_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('activity_logs');
    }
};
