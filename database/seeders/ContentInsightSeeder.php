<?php

namespace Database\Seeders;

use App\Models\ContentInsight;
use App\Models\Cycle;
use Illuminate\Database\Seeder;

/**
 * Fills a ContentInsight row for every cycle with plausible random numbers.
 *
 * Numbers are loosely anchored to the cycle's own `views` / `engagement` so a
 * cycle with big reach also shows big content-insight numbers. Each metric is
 * split Posts / Reels / Story with weights that mirror a typical IG account
 * (Reels carry most views, Stories carry a fair share of interactions).
 *
 * Uses updateOrCreate keyed on (account_id, cycle_id) — safe to re-run, and it
 * leaves any row you entered by hand in place only if you pass --class and skip
 * it; by default it overwrites. Nothing else in the app touches this table.
 */
class ContentInsightSeeder extends Seeder
{
    public function run(): void
    {
        $split = function (int $total, array $weights): array {
            // jitter each weight ±25%, then normalise and hand out whole units
            $jittered = array_map(fn ($w) => max(0.01, $w * mt_rand(75, 125) / 100), $weights);
            $sum = array_sum($jittered);

            $posts = (int) round($total * $jittered[0] / $sum);
            $reels = (int) round($total * $jittered[1] / $sum);
            $story = max(0, $total - $posts - $reels);

            return [$posts, $reels, $story];
        };

        Cycle::query()->chunkById(200, function ($cycles) use ($split) {
            foreach ($cycles as $cycle) {
                // Viewers total ~ a slice of the cycle's recorded views (fallback random)
                $viewsBase = (int) ($cycle->views ?: mt_rand(2_000, 60_000));
                $viewersTotal = (int) round($viewsBase * mt_rand(40, 90) / 100);
                $viewersTotal = max($viewersTotal, mt_rand(300, 1_500));

                // Interactions total ~ a slice of engagement (fallback random)
                $engBase = (int) ($cycle->engagement ?: mt_rand(200, 8_000));
                $interactionsTotal = (int) round($engBase * mt_rand(50, 110) / 100);
                $interactionsTotal = max($interactionsTotal, mt_rand(50, 400));

                // Reels dominate views; Posts lead interactions, Stories meaningful on both
                [$vp, $vr, $vs] = $split($viewersTotal, [0.30, 0.55, 0.15]);
                [$ip, $ir, $is] = $split($interactionsTotal, [0.45, 0.40, 0.15]);

                ContentInsight::updateOrCreate(
                    ['account_id' => $cycle->account_id, 'cycle_id' => $cycle->id],
                    [
                        'viewers_posts' => $vp,
                        'viewers_reels' => $vr,
                        'viewers_story' => $vs,
                        'interactions_posts' => $ip,
                        'interactions_reels' => $ir,
                        'interactions_story' => $is,
                    ],
                );
            }
        });

        $this->command?->info('Seeded content insights for '.ContentInsight::count().' cycles.');
    }
}
