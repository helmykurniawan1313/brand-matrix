<?php

namespace App\Http\Controllers;

use App\Models\Account;
use App\Models\Cycle;
use App\Models\Employee;
use App\Models\FormulaWeight;
use App\Models\LabelBucket;
use App\Models\ScoreBucket;
use App\Services\MetricCalculator;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Collection;
use Inertia\Inertia;
use Inertia\Response;

/**
 * Account Performance — same Growth/Visibility/Engagement/Health breakdown
 * as the Cycles table, but collapsed to one row per account+platform (its
 * MOST RECENT cycle only), instead of listing every cycle ever recorded.
 * Clicking a row opens a month-over-month trend across that account's full
 * cycle history for the same platform.
 */
class AccountPerformanceController extends Controller
{
    public function index(Request $request, MetricCalculator $calculator): Response
    {
        $search = $request->string('search')->trim()->toString() ?: null;
        $pmId = $request->integer('project_manager_id') ?: null;
        $healthFilter = array_values(array_filter(explode(',', $request->string('health_label')->trim()->toString())));
        $page = $request->integer('page', 1);
        $perPage = 15;

        $accountIds = Account::query()
            ->when($search, fn ($query, $search) => $query->where('name', 'like', "%{$search}%"))
            ->when($pmId, fn ($query, $pmId) => $query->where('project_manager_id', $pmId))
            ->pluck('id');

        $rows = $this->latestCyclePerAccountPlatform($accountIds, $calculator)
            ->when($healthFilter, fn ($rows) => $rows->filter(fn ($row) => in_array($row['health_label'], $healthFilter, true)))
            ->values();

        $paginator = new LengthAwarePaginator(
            $rows->forPage($page, $perPage)->values(),
            $rows->count(),
            $perPage,
            $page,
            ['path' => $request->url(), 'query' => $request->query()],
        );

        return Inertia::render('AccountPerformance/Index', [
            'rows' => $paginator,
            'summary' => [
                'total' => $rows->count(),
            ],
            'filters' => [
                'search' => $search,
                'project_manager_id' => $pmId,
                'health_label' => $healthFilter,
            ],
            'accountDepartmentEmployees' => Employee::whereHas(
                'department',
                fn ($query) => $query->where('name', 'Account')
            )->orderBy('name')->get(['id', 'name']),
            'healthLabels' => LabelBucket::where('metric', LabelBucket::METRIC_HEALTH)
                ->orderByDesc('min_score')
                ->pluck('label'),
        ]);
    }

    /**
     * Month-over-month trend for one account+platform — every cycle's full
     * score breakdown (Growth/Visibility/Engagement/Health), oldest first, so
     * the detail chart can plot each metric's line across the account's
     * entire history on that platform.
     */
    public function trend(Request $request, Account $account, MetricCalculator $calculator): JsonResponse
    {
        $platform = $request->string('platform')->trim()->toString() ?: 'instagram';

        $scoreBuckets = ScoreBucket::all();
        $labelBuckets = LabelBucket::all();
        $formulaWeights = FormulaWeight::all();

        $cycles = $account->cycles()
            ->where(fn ($query) => $query->where('platform', $platform)->orWhere(fn ($q) => $platform === 'instagram' && $q->whereNull('platform')))
            ->orderBy('cycle_start_date')
            ->get();

        $series = $cycles->map(function (Cycle $cycle) use ($calculator, $scoreBuckets, $labelBuckets, $formulaWeights) {
            $scores = $calculator->calculate($cycle, $scoreBuckets, $labelBuckets, $formulaWeights);

            return [
                'month' => $cycle->cycle_start_date->format('M Y'),
                'cycle_start_date' => $cycle->cycle_start_date->toDateString(),
                'cycle_end_date' => $cycle->cycle_end_date->toDateString(),
                'growth_rate' => round($scores['growth_rate'], 2),
                'visibility_rate' => round($scores['visibility_rate'], 2),
                'engagement_score' => round($scores['engagement_score'], 2),
                'health_rate' => round($scores['health_rate'], 2),
                'health_label' => $scores['health_label'],
            ];
        })->values();

        return response()->json([
            'account' => ['id' => $account->id, 'name' => $account->name],
            'platform' => $platform,
            'series' => $series,
        ]);
    }

    /**
     * One row per account+platform combination, carrying only that
     * combination's MOST RECENT cycle's full score breakdown — same
     * per-platform grouping as Account Health/Account Growth, so an account
     * with both Instagram and TikTok cycles shows two separate rows.
     */
    private function latestCyclePerAccountPlatform(Collection $accountIds, MetricCalculator $calculator): Collection
    {
        if ($accountIds->isEmpty()) {
            return collect();
        }

        $accountsById = Account::with('projectManager:id,name')
            ->whereIn('id', $accountIds)
            ->get()
            ->keyBy('id');

        $scoreBuckets = ScoreBucket::all();
        $labelBuckets = LabelBucket::all();
        $formulaWeights = FormulaWeight::all();

        return Cycle::whereIn('account_id', $accountIds)
            ->orderBy('cycle_start_date')
            ->get()
            ->groupBy('account_id')
            ->flatMap(function (Collection $accountCycles, int $accountId) use ($accountsById, $calculator, $scoreBuckets, $labelBuckets, $formulaWeights) {
                $account = $accountsById->get($accountId);
                if (! $account) {
                    return [];
                }

                return $accountCycles
                    ->groupBy(fn (Cycle $cycle) => $cycle->platform ?? 'instagram')
                    ->map(function (Collection $cycles, string $platform) use ($account, $calculator, $scoreBuckets, $labelBuckets, $formulaWeights) {
                        $latest = $cycles->last();
                        $scores = $calculator->calculate($latest, $scoreBuckets, $labelBuckets, $formulaWeights);

                        return [
                            'account_id' => $account->id,
                            'account_name' => $account->name,
                            'project_manager' => $account->projectManager,
                            'platform' => $platform,
                            'cycle_id' => $latest->id,
                            'latest_cycle_label' => $latest->cycle_start_date->format('M Y'),
                            'cycle_start_date' => $latest->cycle_start_date->toDateString(),
                            'cycle_end_date' => $latest->cycle_end_date->toDateString(),
                            'cycles_count' => $cycles->count(),
                            'growth_rate' => round($scores['growth_rate'], 2),
                            'visibility_rate' => round($scores['visibility_rate'], 2),
                            'engagement_score' => round($scores['engagement_score'], 2),
                            'health_rate' => round($scores['health_rate'], 2),
                            'health_label' => $scores['health_label'],
                        ];
                    })
                    ->values();
            })
            ->sortBy('account_name')
            ->values();
    }
}
