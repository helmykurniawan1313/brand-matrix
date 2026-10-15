<?php

use App\Models\LabelBucket;
use App\Models\ScoreBucket;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    // Same best-to-worst rotation the frontend's old hardcoded `tierTones` used
    // (resources/js/Pages/Settings/Buckets.vue) — assigning these by rank here
    // keeps every existing tier visually identical immediately after migrating;
    // only becomes user-editable from this point on.
    private const RANK_TONES = ['sip', 'bagus', 'cukup', 'kurang', 'parah'];

    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('score_buckets', function (Blueprint $table) {
            // Token key into the app's existing --status-{token}-bg/-ink design
            // tokens, or 'custom' to use custom_color_bg/custom_color_ink instead.
            $table->string('color')->nullable()->after('score');
            $table->string('custom_color_bg')->nullable()->after('color');
            $table->string('custom_color_ink')->nullable()->after('custom_color_bg');
        });

        Schema::table('label_buckets', function (Blueprint $table) {
            $table->string('color')->nullable()->after('label');
            $table->string('custom_color_bg')->nullable()->after('color');
            $table->string('custom_color_ink')->nullable()->after('custom_color_bg');
        });

        $this->backfillByRank('score_buckets', ScoreBucket::METRICS, 'min_rate');
        $this->backfillByRank('label_buckets', LabelBucket::METRICS, 'min_score');
    }

    /**
     * Assigns each metric's tiers a color by best-to-worst rank (highest min
     * first), mirroring the old frontend tierTones array, so nothing visually
     * changes right after this migration runs.
     */
    private function backfillByRank(string $table, array $metrics, string $minKey): void
    {
        foreach ($metrics as $metric) {
            $rows = DB::table($table)
                ->where('metric', $metric)
                ->orderByDesc($minKey)
                ->get(['id']);

            foreach ($rows as $rank => $row) {
                $tone = self::RANK_TONES[min($rank, count(self::RANK_TONES) - 1)];
                DB::table($table)->where('id', $row->id)->update(['color' => $tone]);
            }
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('score_buckets', function (Blueprint $table) {
            $table->dropColumn(['color', 'custom_color_bg', 'custom_color_ink']);
        });

        Schema::table('label_buckets', function (Blueprint $table) {
            $table->dropColumn(['color', 'custom_color_bg', 'custom_color_ink']);
        });
    }
};
