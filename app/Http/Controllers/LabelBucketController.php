<?php

namespace App\Http\Controllers;

use App\Models\LabelBucket;
use App\Models\ScoreBucket;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class LabelBucketController extends Controller
{
    public function store(Request $request): RedirectResponse
    {
        $data = $this->validated($request);

        LabelBucket::create($data);

        return back();
    }

    public function update(Request $request, LabelBucket $labelBucket): RedirectResponse
    {
        $data = $this->validated($request, requireMetric: false);

        // ScoreBucket.tier stores the account_tier label as a plain string
        // (not a foreign key), matched by exact equality in AccountTierResolver/
        // MetricCalculator's fallback lookup. Renaming a tier here would
        // otherwise silently orphan every score_buckets row still tagged with
        // the old name — they'd stop matching and fall through to the global
        // bucket set without any error or warning.
        $oldLabel = $labelBucket->label;
        $newLabel = $data['label'] ?? $oldLabel;
        $isAccountTierRename = $labelBucket->metric === LabelBucket::METRIC_ACCOUNT_TIER
            && $newLabel !== $oldLabel;

        $labelBucket->update($data);

        if ($isAccountTierRename) {
            ScoreBucket::where('tier', $oldLabel)->update(['tier' => $newLabel]);
        }

        return back();
    }

    public function destroy(LabelBucket $labelBucket): RedirectResponse
    {
        // Same orphaning risk as the rename case above, but for delete: a
        // tier with existing Score Tiers rows would leave them permanently
        // unreachable (their tier name no longer resolves to anything) —
        // blocked instead of silently deleting or orphaning that data.
        if ($labelBucket->metric === LabelBucket::METRIC_ACCOUNT_TIER) {
            $scoreBucketCount = ScoreBucket::where('tier', $labelBucket->label)->count();

            if ($scoreBucketCount > 0) {
                throw ValidationException::withMessages([
                    'label' => "Can't delete \"{$labelBucket->label}\" — it still has {$scoreBucketCount} Score Tiers threshold(s) set. Remove or reassign those first.",
                ]);
            }
        }

        $labelBucket->delete();

        return back();
    }

    private function validated(Request $request, bool $requireMetric = true): array
    {
        return $request->validate([
            'metric' => [$requireMetric ? 'required' : 'sometimes', 'string', 'in:'.implode(',', LabelBucket::METRICS)],
            'min_score' => ['nullable', 'numeric'],
            'label' => ['required', 'string', 'max:50'],
            'color' => ['nullable', 'string', 'max:20'],
            'custom_color_bg' => ['nullable', 'string', 'max:20'],
            'custom_color_ink' => ['nullable', 'string', 'max:20'],
        ]);
    }
}
