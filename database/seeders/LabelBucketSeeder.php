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
        if (! LabelBucket::query()->where('metric', LabelBucket::METRIC_GROWTH)->exists()) {
            $this->seedMetric(LabelBucket::METRIC_GROWTH, [
                [10.0, 'SIP'],
                [7.0, 'BAGUS'],
                [3.0, 'CUKUP'],
                [1.0, 'KURANG'],
                [null, 'PARAH'],
            ]);
        }

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

        if (! LabelBucket::query()->where('metric', LabelBucket::METRIC_ACCOUNT_GROWTH)->exists()) {
            // Same wording as the Views/Reach/Engagement change buckets below
            // (Sip/Bagus/Cukup/Perlu Perhatian) — kept consistent so the Accounts
            // table's four status columns read as one system, not two.
            $this->seedMetric(LabelBucket::METRIC_ACCOUNT_GROWTH, [
                [15.0, 'Sip'],
                [5.0, 'Bagus'],
                [0.0, 'Cukup'],
                [null, 'Perlu Perhatian'],
            ]);
        }

        // Period-over-period % change labels for the Growth Analysis panel —
        // same thresholds/wording as Account Growth Rate, per explicit request:
        // >15% Sip, >5% Bagus, >0% Cukup, <0% Perlu Perhatian. Applied to Views,
        // Reach, and Engagement change between two picked months.
        foreach ([LabelBucket::METRIC_VIEWS_CHANGE, LabelBucket::METRIC_REACH_CHANGE, LabelBucket::METRIC_ENGAGEMENT_CHANGE] as $metric) {
            if (! LabelBucket::query()->where('metric', $metric)->exists()) {
                $this->seedMetric($metric, [
                    [15.0, 'Sip'],
                    [5.0, 'Bagus'],
                    [0.0, 'Cukup'],
                    [null, 'Perlu Perhatian'],
                ]);
            }
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
