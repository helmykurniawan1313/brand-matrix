<?php

namespace Database\Seeders;

use App\Models\ScoreBucket;
use Illuminate\Database\Seeder;

class ScoreBucketSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        if (ScoreBucket::query()->exists()) {
            return;
        }

        $this->seedMetric(ScoreBucket::METRIC_GROWTH, [
            [10.0, 100.0],
            [7.0, 75.0],
            [3.0, 50.0],
            [1.0, 25.0],
            [null, 0.0],
        ]);

        $this->seedMetric(ScoreBucket::METRIC_REACH, [
            [5000.0, 100.0],
            [2000.0, 75.0],
            [1000.0, 50.0],
            [500.0, 25.0],
            [null, 0.0],
        ]);

        $this->seedMetric(ScoreBucket::METRIC_VIEW, [
            [500.0, 100.0],
            [400.0, 75.0],
            [200.0, 50.0],
            [100.0, 25.0],
            [null, 0.0],
        ]);
        // Note: View Rate is defined as (views / end_follower) x 100, expressed as a percentage
        // to stay consistent with the other rate metrics. Thresholds approximate the ">5x/4x/2x/1x
        // of followers" wording as percentages (500%/400%/200%/100%) — confirm/adjust via the
        // Settings > Buckets UI if a different scale was intended.

        $this->seedMetric(ScoreBucket::METRIC_ER_REACH, [
            [5.0, 100.0],
            [3.5, 75.0],
            [1.5, 50.0],
            [0.5, 25.0],
            [null, 0.0],
        ]);

        $this->seedMetric(ScoreBucket::METRIC_ER_FOLLOWER, [
            [5.0, 100.0],
            [3.0, 75.0],
            [2.0, 50.0],
            [1.0, 25.0],
            [null, 0.0],
        ]);
    }

    private function seedMetric(string $metric, array $tiers): void
    {
        foreach ($tiers as [$min, $score]) {
            ScoreBucket::create([
                'metric' => $metric,
                'min_rate' => $min,
                'score' => $score,
            ]);
        }
    }
}
