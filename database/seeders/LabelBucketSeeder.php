<?php

namespace Database\Seeders;

use App\Models\LabelBucket;
use Illuminate\Database\Seeder;

class LabelBucketSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        if (LabelBucket::query()->exists()) {
            return;
        }

        $this->seedMetric(LabelBucket::METRIC_GROWTH, [
            [10.0, 'SIP'],
            [7.0, 'BAGUS'],
            [3.0, 'CUKUP'],
            [1.0, 'KURANG'],
            [null, 'PARAH'],
        ]);

        $this->seedMetric(LabelBucket::METRIC_VISIBILITY, [
            [100.0, 'SIP'],
            [75.0, 'BAGUS'],
            [50.0, 'CUKUP'],
            [25.0, 'KURANG'],
            [null, 'PARAH'],
        ]);

        $this->seedMetric(LabelBucket::METRIC_ENGAGEMENT, [
            [100.0, 'SIP'],
            [75.0, 'BAGUS'],
            [50.0, 'CUKUP'],
            [25.0, 'KURANG'],
            [null, 'PARAH'],
        ]);

        $this->seedMetric(LabelBucket::METRIC_HEALTH, [
            [85.0, 'SIP'],
            [60.0, 'BAGUS'],
            [40.0, 'CUKUP'],
            [10.0, 'KURANG'],
            [null, 'PARAH'],
        ]);
    }

    private function seedMetric(string $metric, array $tiers): void
    {
        foreach ($tiers as [$min, $label]) {
            LabelBucket::create([
                'metric' => $metric,
                'min_score' => $min,
                'label' => $label,
            ]);
        }
    }
}
