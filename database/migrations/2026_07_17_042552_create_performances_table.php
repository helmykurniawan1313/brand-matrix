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
        Schema::create('performances', function (Blueprint $table) {
            $table->id();
            $table->foreignId('client_id')->constrained('accounts')->cascadeOnDelete();
            $table->date('post_date');
            $table->date('preview_date')->nullable();
            $table->boolean('ads')->default(false);
            $table->foreignId('project_manager_id')->nullable()->constrained('employees')->nullOnDelete();
            $table->foreignId('conceptor_id')->nullable()->constrained('employees')->nullOnDelete();
            $table->foreignId('editor_id')->nullable()->constrained('employees')->nullOnDelete();
            $table->unsignedInteger('followers')->nullable();
            $table->unsignedInteger('total_views_h7')->nullable();
            $table->string('proof_path')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('performances');
    }
};
