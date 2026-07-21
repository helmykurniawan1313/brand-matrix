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
        if (! LabelBucket::query()->where('metric', LabelBucket::METRIC_VISIBILITY)->exists()) {
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

        if (! LabelBucket::query()->where('metric', LabelBucket::METRIC_VIEWS)->exists()) {
            $this->seedMetric(LabelBucket::METRIC_VIEWS, [
                [100000.0, 'Sip'],
                [10000.0, 'Bagus'],
                [4000.0, 'Cukup'],
                [1000.0, 'Kurang Ringan'],
                [null, 'Parah'],
            ]);
        }

        if (! LabelBucket::query()->where('metric', LabelBucket::METRIC_FOLLOWERS)->exists()) {
            $this->seedMetric(LabelBucket::METRIC_FOLLOWERS, [
                [1000000.0, 'Mega'],
                [100000.0, 'Macro'],
                [10000.0, 'Micro'],
                [1000.0, 'Nano'],
            ]);
        }
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
