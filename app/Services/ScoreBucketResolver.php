<?php

namespace App\Services;

use Illuminate\Support\Collection;

class ScoreBucketResolver
{
    /**
     * Resolves a rate to the value of the tier with the highest min_rate that is <= rate.
     * A null min_rate is treated as -infinity (the floor tier), so it always matches
     * unless a higher tier also matches.
     *
     * @param  Collection  $buckets  Buckets for a single metric, each exposing $minKey and $valueKey.
     */
    public function resolve(Collection $buckets, float $rate, string $minKey = 'min_rate', string $valueKey = 'score'): mixed
    {
        $rate = round($rate, 4);

        $matches = $buckets->filter(function ($bucket) use ($rate, $minKey) {
            $min = $bucket->{$minKey};

            return $min === null || $rate >= round((float) $min, 4);
        });

        $winner = $matches->sortByDesc(fn ($bucket) => $bucket->{$minKey} === null ? -INF : round((float) $bucket->{$minKey}, 4))
            ->first();

        return $winner?->{$valueKey};
    }
}
