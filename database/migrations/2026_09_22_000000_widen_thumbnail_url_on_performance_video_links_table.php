<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * thumbnail_url was varchar(255), but TikTok's oEmbed thumbnail_url is a
 * signed CDN URL (x-signature/x-expires/... query params) that routinely
 * exceeds 255 characters. Under STRICT_TRANS_TABLES (the default here),
 * MySQL rejects the insert outright instead of truncating — every video
 * link whose resolved thumbnail happened to be long enough 500'd with an
 * uncaught QueryException in syncVideoLinks(). Widening to TEXT matches
 * embed_html, which already had to be widened for the same reason.
 */
return new class extends Migration
{
    public function up(): void
    {
        Schema::table('performance_video_links', function (Blueprint $table) {
            $table->text('thumbnail_url')->nullable()->change();
        });
    }

    public function down(): void
    {
        Schema::table('performance_video_links', function (Blueprint $table) {
            $table->string('thumbnail_url')->nullable()->change();
        });
    }
};
