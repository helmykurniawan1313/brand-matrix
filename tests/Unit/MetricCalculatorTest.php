<?php

namespace Tests\Unit;

use App\Models\Cycle;
use App\Models\FormulaWeight;
use App\Models\LabelBucket;
use App\Models\ScoreBucket;
use App\Services\MetricCalculator;
use Illuminate\Support\Collection;
use PHPUnit\Framework\Attributes\DataProvider;
use Tests\TestCase;

class MetricCalculatorTest extends TestCase
{
    private function cycle(array $overrides = []): Cycle
    {
        return new Cycle(array_merge([
            'cycle_start_date' => '2026-01-01',
            'cycle_end_date' => '2026-01-31',
            'start_follower' => 1000,
            'end_follower' => 1100,
            'reach' => 1200,
            'views' => 1800,
            'engagement' => 60,
        ], $overrides));
    }

    /**
     * @return Collection<int, ScoreBucket>
     */
    private function scoreBuckets(): Collection
    {
        $tier = fn (string $metric, ?float $min, float $score) => new ScoreBucket([
            'metric' => $metric,
            'min_rate' => $min,
            'score' => $score,
        ]);

        return collect([
            $tier(ScoreBucket::METRIC_GROWTH, 10.0, 100.0),
            $tier(ScoreBucket::METRIC_GROWTH, 7.0, 75.0),
            $tier(ScoreBucket::METRIC_GROWTH, 3.0, 50.0),
            $tier(ScoreBucket::METRIC_GROWTH, 1.0, 25.0),
            $tier(ScoreBucket::METRIC_GROWTH, null, 0.0),

            $tier(ScoreBucket::METRIC_REACH, 5000.0, 100.0),
            $tier(ScoreBucket::METRIC_REACH, 2000.0, 75.0),
            $tier(ScoreBucket::METRIC_REACH, 1000.0, 50.0),
            $tier(ScoreBucket::METRIC_REACH, 500.0, 25.0),
            $tier(ScoreBucket::METRIC_REACH, null, 0.0),

            $tier(ScoreBucket::METRIC_VIEW, 500.0, 100.0),
            $tier(ScoreBucket::METRIC_VIEW, 400.0, 75.0),
            $tier(ScoreBucket::METRIC_VIEW, 200.0, 50.0),
            $tier(ScoreBucket::METRIC_VIEW, 100.0, 25.0),
            $tier(ScoreBucket::METRIC_VIEW, null, 0.0),

            $tier(ScoreBucket::METRIC_ER_REACH, 5.0, 100.0),
            $tier(ScoreBucket::METRIC_ER_REACH, 3.5, 75.0),
            $tier(ScoreBucket::METRIC_ER_REACH, 1.5, 50.0),
            $tier(ScoreBucket::METRIC_ER_REACH, 0.5, 25.0),
            $tier(ScoreBucket::METRIC_ER_REACH, null, 0.0),

            $tier(ScoreBucket::METRIC_ER_FOLLOWER, 5.0, 100.0),
            $tier(ScoreBucket::METRIC_ER_FOLLOWER, 3.0, 75.0),
            $tier(ScoreBucket::METRIC_ER_FOLLOWER, 2.0, 50.0),
            $tier(ScoreBucket::METRIC_ER_FOLLOWER, 1.0, 25.0),
            $tier(ScoreBucket::METRIC_ER_FOLLOWER, null, 0.0),
        ]);
    }

    /**
     * @return Collection<int, LabelBucket>
     */
    private function labelBuckets(): Collection
    {
        $tier = fn (string $metric, ?float $min, string $label) => new LabelBucket([
            'metric' => $metric,
            'min_score' => $min,
            'label' => $label,
        ]);

        return collect([
            $tier(LabelBucket::METRIC_VISIBILITY, 100.0, 'SIP'),
            $tier(LabelBucket::METRIC_VISIBILITY, 75.0, 'BAGUS'),
            $tier(LabelBucket::METRIC_VISIBILITY, 50.0, 'CUKUP'),
            $tier(LabelBucket::METRIC_VISIBILITY, 25.0, 'KURANG'),
            $tier(LabelBucket::METRIC_VISIBILITY, null, 'PARAH'),

            $tier(LabelBucket::METRIC_ENGAGEMENT, 100.0, 'SIP'),
            $tier(LabelBucket::METRIC_ENGAGEMENT, 75.0, 'BAGUS'),
            $tier(LabelBucket::METRIC_ENGAGEMENT, 50.0, 'CUKUP'),
            $tier(LabelBucket::METRIC_ENGAGEMENT, 25.0, 'KURANG'),
            $tier(LabelBucket::METRIC_ENGAGEMENT, null, 'PARAH'),

            $tier(LabelBucket::METRIC_HEALTH, 85.0, 'SIP'),
            $tier(LabelBucket::METRIC_HEALTH, 60.0, 'BAGUS'),
            $tier(LabelBucket::METRIC_HEALTH, 40.0, 'CUKUP'),
            $tier(LabelBucket::METRIC_HEALTH, 10.0, 'KURANG'),
            $tier(LabelBucket::METRIC_HEALTH, null, 'PARAH'),
        ]);
    }

    public function test_full_calculation_with_strong_performance(): void
    {
        // start=1000 end=1100 -> growth=100, growth_rate=10%
        // reach=1200, end=1100 -> reach_rate=109.09%
        // views=1800, end=1100 -> view_rate=163.64%
        // engagement=60, reach=1200 -> er_reach_rate=5%
        // engagement=60, end=1100 -> er_follower_rate=5.4545%
        $result = (new MetricCalculator())->calculate($this->cycle(), $this->scoreBuckets(), $this->labelBuckets(), collect());

        $this->assertSame(100, $result['growth']);
        $this->assertEqualsWithDelta(10.0, $result['growth_rate'], 0.0001);
        $this->assertEqualsWithDelta(109.0909, $result['reach_rate'], 0.001);
        $this->assertEqualsWithDelta(163.6364, $result['view_rate'], 0.001);
        $this->assertEqualsWithDelta(5.0, $result['er_reach_rate'], 0.0001);
        $this->assertEqualsWithDelta(5.4545, $result['er_follower_rate'], 0.001);

        $this->assertEqualsWithDelta(100.0, $result['growth_score'], 0.0001);
        $this->assertEqualsWithDelta(0.0, $result['reach_score'], 0.0001);
        $this->assertEqualsWithDelta(25.0, $result['view_score'], 0.0001);
        $this->assertEqualsWithDelta(100.0, $result['er_reach_score'], 0.0001);
        $this->assertEqualsWithDelta(100.0, $result['er_follower_score'], 0.0001);

        // visibility_rate = (0 + 25) / 2 = 12.5
        $this->assertEqualsWithDelta(12.5, $result['visibility_rate'], 0.0001);
        $this->assertSame('PARAH', $result['visibility_label']);

        // engagement_score = (100 + 100) / 2 = 100
        $this->assertEqualsWithDelta(100.0, $result['engagement_score'], 0.0001);
        $this->assertSame('SIP', $result['engagement_label']);

        // health_rate = (100 + 12.5 + 100) / 3 = 70.8333
        $this->assertEqualsWithDelta(70.8333, $result['health_rate'], 0.001);
        $this->assertSame('BAGUS', $result['health_label']);
    }

    public function test_zero_denominators_do_not_divide_by_zero(): void
    {
        $cycle = $this->cycle([
            'start_follower' => 0,
            'end_follower' => 0,
            'reach' => 0,
            'views' => 0,
            'engagement' => 0,
        ]);

        $result = (new MetricCalculator())->calculate($cycle, $this->scoreBuckets(), $this->labelBuckets(), collect());

        $this->assertSame(0, $result['growth']);
        $this->assertSame(0.0, $result['growth_rate']);
        $this->assertSame(0.0, $result['reach_rate']);
        $this->assertSame(0.0, $result['view_rate']);
        $this->assertSame(0.0, $result['er_reach_rate']);
        $this->assertSame(0.0, $result['er_follower_rate']);
        $this->assertSame('PARAH', $result['health_label']);
    }

    #[DataProvider('growthScoreBucketProvider')]
    public function test_growth_score_buckets(int $startFollower, int $endFollower, float $expectedScore): void
    {
        $cycle = $this->cycle([
            'start_follower' => $startFollower,
            'end_follower' => $endFollower,
        ]);

        $result = (new MetricCalculator())->calculate($cycle, $this->scoreBuckets(), $this->labelBuckets(), collect());

        $this->assertEqualsWithDelta($expectedScore, $result['growth_score'], 0.0001);
    }

    public static function growthScoreBucketProvider(): array
    {
        return [
            'above 10% scores 100' => [1000, 1101, 100.0],
            'exactly 10% scores 100' => [1000, 1100, 100.0],
            'exactly 7% scores 75' => [1000, 1070, 75.0],
            'exactly 3% scores 50' => [1000, 1030, 50.0],
            'exactly 1% scores 25' => [1000, 1010, 25.0],
            'just below 1% scores 0' => [1000, 1009, 0.0],
            'negative growth scores 0' => [1000, 900, 0.0],
        ];
    }

    public function test_visibility_label_sip_requires_both_scores_at_100(): void
    {
        $cycle = $this->cycle([
            'start_follower' => 1000,
            'end_follower' => 1000,
            'reach' => 50000,
            'views' => 5000,
        ]);

        $result = (new MetricCalculator())->calculate($cycle, $this->scoreBuckets(), $this->labelBuckets(), collect());

        $this->assertEqualsWithDelta(100.0, $result['reach_score'], 0.0001);
        $this->assertEqualsWithDelta(100.0, $result['view_score'], 0.0001);
        $this->assertEqualsWithDelta(100.0, $result['visibility_rate'], 0.0001);
        $this->assertSame('SIP', $result['visibility_label']);
    }

    public function test_custom_user_defined_buckets_are_respected(): void
    {
        $customScoreBuckets = collect([
            new ScoreBucket(['metric' => ScoreBucket::METRIC_GROWTH, 'min_rate' => 0.0, 'score' => 42.0]),
            new ScoreBucket(['metric' => ScoreBucket::METRIC_GROWTH, 'min_rate' => null, 'score' => 1.0]),
        ]);

        $result = (new MetricCalculator())->calculate($this->cycle(), $customScoreBuckets, $this->labelBuckets(), collect());

        $this->assertEqualsWithDelta(42.0, $result['growth_score'], 0.0001);
    }

    public function test_rate_with_no_matching_bucket_scores_zero(): void
    {
        $result = (new MetricCalculator())->calculate($this->cycle(), collect(), collect(), collect());

        $this->assertSame(0.0, $result['growth_score']);
        $this->assertSame(0.0, $result['reach_score']);
        $this->assertSame(0.0, $result['view_score']);
        $this->assertNull($result['visibility_label']);
        $this->assertNull($result['health_label']);
    }

    public function test_custom_formula_weights_change_health_rate(): void
    {
        // growth_score=100 (rate 10%), visibility_rate=(0+25)/2=12.5, engagement_score=(100+100)/2=100
        $weights = collect([
            new FormulaWeight(['aggregate' => FormulaWeight::AGGREGATE_HEALTH, 'component' => 'growth_score', 'weight' => 0.8]),
            new FormulaWeight(['aggregate' => FormulaWeight::AGGREGATE_HEALTH, 'component' => 'visibility_rate', 'weight' => 0.1]),
            new FormulaWeight(['aggregate' => FormulaWeight::AGGREGATE_HEALTH, 'component' => 'engagement_score', 'weight' => 0.1]),
        ]);

        $result = (new MetricCalculator())->calculate($this->cycle(), $this->scoreBuckets(), $this->labelBuckets(), $weights);

        // (100*0.8 + 12.5*0.1 + 100*0.1) / 1.0 = 91.25
        $this->assertEqualsWithDelta(91.25, $result['health_rate'], 0.0001);
    }

    public function test_formula_weights_auto_normalize_when_not_summing_to_one(): void
    {
        // Weights of 2 and 2 (not normalized to 1.0) should behave identically to 0.5/0.5.
        $weights = collect([
            new FormulaWeight(['aggregate' => FormulaWeight::AGGREGATE_ENGAGEMENT, 'component' => 'er_reach_score', 'weight' => 2.0]),
            new FormulaWeight(['aggregate' => FormulaWeight::AGGREGATE_ENGAGEMENT, 'component' => 'er_follower_score', 'weight' => 2.0]),
        ]);

        $result = (new MetricCalculator())->calculate($this->cycle(), $this->scoreBuckets(), $this->labelBuckets(), $weights);

        $this->assertEqualsWithDelta(100.0, $result['engagement_score'], 0.0001);
    }
}
