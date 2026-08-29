<?php

namespace App\Http\Controllers;

use App\Exports\ViewsTrendExport;
use App\Models\Account;
use App\Models\Cycle;
use App\Models\Performance;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response as HttpResponse;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Collection;
use Inertia\Inertia;
use Inertia\Response;
use Maatwebsite\Excel\Facades\Excel;

class ViewsTrendController extends Controller
{
    /**
     * A drop of 15%+ in avg views vs the previous cycle.
     */
    private const SETBACK_THRESHOLD = -0.15;

    /**
     * A rise of 15%+ in avg views vs the previous cycle.
     */
    private const GROWTH_THRESHOLD = 0.15;

    /**
     * Cycle-to-cycle swing within this band counts as "flat" for stagnation purposes.
     */
    private const STAGNANT_BAND = 0.10;

    /**
     * How many trailing flat cycles in a row before we call it stagnant.
     */
    private const STAGNANT_STREAK = 3;

    public function index(Request $request): Response
    {
        ['rows' => $sorted, 'counts' => $counts, 'filters' => $filters] = $this->filteredSortedRows($request);

        $page = $request->integer('page', 1);
        $perPage = 15;

        $paginator = new LengthAwarePaginator(
            $sorted->forPage($page, $perPage)->values(),
            $sorted->count(),
            $perPage,
            $page,
            ['path' => $request->url(), 'query' => $request->query()],
        );

        // The chart is scoped by filters only, never by the table's sort/page —
        // it always shows every filtered account (worst-first), so sorting or
        // paging the table below it doesn't reshuffle or truncate the chart.
        $chartRequest = Request::create($request->url(), 'GET', array_merge($request->query(), ['sort' => null, 'direction' => null]));
        ['rows' => $chartRows] = $this->filteredSortedRows($chartRequest);

        return Inertia::render('ViewsTrend/Index', [
            'filters' => $filters,
            'rows' => $paginator,
            'chartRows' => $chartRows->values(),
            'counts' => $counts,
        ]);
    }

    public function pdf(Request $request): HttpResponse
    {
        ['rows' => $rows, 'filters' => $filters] = $this->filteredSortedRows($request);

        $pdf = Pdf::loadView('pdf.views-trend-list', [
            'rows' => $rows->values(),
            'generatedAt' => now()->format('M j, Y g:i A'),
            'filterSummary' => $this->filterSummary($filters),
        ])->setPaper('a4', 'landscape');

        return $pdf->download('views-trend-'.now()->format('Y-m-d').'.pdf');
    }

    public function exportExcel(Request $request): \Symfony\Component\HttpFoundation\BinaryFileResponse
    {
        ['rows' => $rows] = $this->filteredSortedRows($request);

        return Excel::download(
            new ViewsTrendExport($rows->values()),
            'views-trend-'.now()->format('Y-m-d').'.xlsx',
        );
    }

    /**
     * The filtered, sorted (but not yet paginated) row set shared by the page,
     * the PDF export, and the Excel export — one place for search/platform/trend
     * filtering and sort logic so all three stay in sync.
     */
    private function filteredSortedRows(Request $request): array
    {
        $search = $request->string('search')->trim()->toString() ?: null;

        $platform = $request->string('platform')->toString();
        $platform = in_array($platform, ['instagram', 'tiktok'], true) ? $platform : 'all';

        $trendFilter = $request->string('trend')->toString();
        $trendFilter = in_array($trendFilter, ['setback', 'stagnant', 'growing', 'stable', 'insufficient_data'], true)
            ? $trendFilter
            : null;

        $sortKey = $request->string('sort')->toString();
        $sortKey = in_array($sortKey, ['account', 'last_avg_views', 'prior_avg_views', 'last_total_views', 'prior_total_views', 'delta_pct'], true) ? $sortKey : 'trend';
        $direction = $request->string('direction')->toString() === 'desc' ? 'desc' : 'asc';

        $accounts = Account::orderBy('name')
            ->when($search, fn ($query, $search) => $query->where('name', 'like', "%{$search}%"))
            ->get(['id', 'name']);

        // Keyed by "{account_id}:{platform}", never merged across platforms — an
        // account's Instagram and TikTok view counts are different audiences and
        // averaging/interleaving them into one series would misrepresent both.
        $cyclesByAccountPlatform = Cycle::orderBy('cycle_start_date')
            ->when($platform !== 'all', fn ($query) => $query->where('platform', $platform))
            ->get(['id', 'account_id', 'platform', 'cycle_start_date'])
            ->groupBy(fn (Cycle $cycle) => "{$cycle->account_id}:{$cycle->platform}");

        $viewsByCycle = $this->avgViewsByCycle();
        $totalViewsByCycle = $this->totalViewsByCycle();
        // Both derive from the same per-cycle performance scan (viewsByCyclePerformances(),
        // memoized below) — this used to independently re-run that full-table query, once
        // per method call. Since index() calls filteredSortedRows() twice (table + chart)
        // and pdf()/exportExcel() add a third, that meant up to 4 full scans of Performance
        // per page load. Memoizing the underlying scan collapses that back to 1.

        $rows = $accounts
            ->flatMap(function (Account $account) use ($cyclesByAccountPlatform, $viewsByCycle, $totalViewsByCycle, $platform) {
                $platforms = $platform === 'all' ? ['instagram', 'tiktok'] : [$platform];

                return collect($platforms)->map(function (string $accountPlatform) use ($account, $cyclesByAccountPlatform, $viewsByCycle, $totalViewsByCycle) {
                    $cycles = $cyclesByAccountPlatform->get("{$account->id}:{$accountPlatform}", collect());

                    $series = $cycles->map(fn (Cycle $cycle) => [
                        'cycle_id' => $cycle->id,
                        'label' => $cycle->cycle_start_date->format('M Y'),
                        'avg_views' => $viewsByCycle->get($cycle->id),
                        'total_views' => $totalViewsByCycle->get($cycle->id),
                    ])->filter(fn ($point) => $point['avg_views'] !== null)->values();

                    return $this->buildRow($account, $accountPlatform, $series);
                });
            })
            ->filter(fn ($row) => $row !== null)
            ->values();

        $counts = [
            'setback' => $rows->where('trend', 'setback')->count(),
            'stagnant' => $rows->where('trend', 'stagnant')->count(),
            'growing' => $rows->where('trend', 'growing')->count(),
            'stable' => $rows->where('trend', 'stable')->count(),
            'insufficient_data' => $rows->where('trend', 'insufficient_data')->count(),
        ];

        // Worst-first is the default: setback -> stagnant -> stable -> growing -> insufficient,
        // since that's what a boss scanning this page cares about seeing at the top.
        // Any other column can be sorted explicitly via the table header.
        $trendRank = ['setback' => 0, 'stagnant' => 1, 'stable' => 2, 'growing' => 3, 'insufficient_data' => 4];

        $comparator = match ($sortKey) {
            'account' => fn ($a, $b) => $a['account_name'] <=> $b['account_name'],
            // nulls (insufficient data) always sort last, regardless of direction.
            'last_avg_views' => fn ($a, $b) => ($a['last_avg_views'] ?? -1) <=> ($b['last_avg_views'] ?? -1),
            'prior_avg_views' => fn ($a, $b) => ($a['prior_avg_views'] ?? -1) <=> ($b['prior_avg_views'] ?? -1),
            'last_total_views' => fn ($a, $b) => ($a['last_total_views'] ?? -1) <=> ($b['last_total_views'] ?? -1),
            'prior_total_views' => fn ($a, $b) => ($a['prior_total_views'] ?? -1) <=> ($b['prior_total_views'] ?? -1),
            'delta_pct' => fn ($a, $b) => ($a['delta_pct'] ?? -INF) <=> ($b['delta_pct'] ?? -INF),
            default => fn ($a, $b) => $trendRank[$a['trend']] <=> $trendRank[$b['trend']],
        };

        $sorted = $rows
            ->when($trendFilter, fn (Collection $rows) => $rows->where('trend', $trendFilter))
            ->sort(function ($a, $b) use ($comparator, $sortKey, $direction) {
                $result = $comparator($a, $b);

                if ($sortKey !== 'trend' && $direction === 'desc') {
                    $result = -$result;
                }

                return $result
                    ?: $a['account_name'] <=> $b['account_name']
                    ?: $a['platform'] <=> $b['platform'];
            })
            ->values();

        return [
            'rows' => $sorted,
            'counts' => $counts,
            'filters' => ['search' => $search, 'platform' => $platform, 'trend' => $trendFilter, 'sort' => $sortKey, 'direction' => $direction],
        ];
    }

    /**
     * Human-readable filter description for the PDF export header, matching the
     * pattern used by the Cycles/Performance list exports.
     */
    private function filterSummary(array $filters): string
    {
        $parts = [];

        if ($filters['search']) {
            $parts[] = "search: \"{$filters['search']}\"";
        }
        if ($filters['platform'] !== 'all') {
            $parts[] = 'platform: '.($filters['platform'] === 'tiktok' ? 'TikTok' : 'Instagram');
        }
        if ($filters['trend']) {
            $parts[] = 'trend: '.$filters['trend'];
        }

        $sortLabels = [
            'account' => 'Account',
            'last_avg_views' => 'Last Cycle Avg Views',
            'prior_avg_views' => 'Prior Cycle Avg Views',
            'last_total_views' => 'Total Views (Last)',
            'prior_total_views' => 'Total Views (Prior)',
            'delta_pct' => 'Delta %',
            'trend' => 'Trend (default)',
        ];
        $parts[] = 'sorted by: '.($sortLabels[$filters['sort']] ?? $filters['sort']).' ('.strtoupper($filters['direction']).')';

        return implode(', ', $parts);
    }

    /**
     * Full per-cycle views series for one account+platform — the data behind
     * the detail modal. Views-only (no followers/health/reach): this endpoint
     * exists specifically so the modal can stay focused on what this page is
     * about, unlike the general-purpose AccountGrowthModal.
     */
    public function detail(Account $account, Request $request): JsonResponse
    {
        $platform = $request->string('platform')->toString();
        $platform = in_array($platform, ['instagram', 'tiktok'], true) ? $platform : 'instagram';

        // Scoped to this account+platform only — unlike the page/export queries above,
        // which need every account's data at once, this endpoint only ever needs one
        // account's rows, so there's no reason to scan the whole Performance table.
        $performances = Performance::where('account_id', $account->id)
            ->where('platform', $platform)
            ->whereNotNull('cycle_id')
            ->with(['igSnapshots' => fn ($query) => $query->limit(1)])
            ->get()
            ->groupBy('cycle_id');

        $viewsByCycle = $performances->map(function (Collection $cyclePerformances) {
            $views = $cyclePerformances
                ->map(function (Performance $performance) {
                    $snapshot = $performance->igSnapshots->first();

                    return $snapshot ? ($snapshot->views ?? $snapshot->total_interactions) : $performance->total_views_h7;
                })
                ->filter(fn ($views) => $views !== null);

            return $views->isEmpty() ? null : (float) $views->avg();
        });

        $postCountsByCycle = $performances->map(fn (Collection $cyclePerformances) => $cyclePerformances->count());

        $cycles = Cycle::where('account_id', $account->id)
            ->where('platform', $platform)
            ->orderBy('cycle_start_date')
            ->get();

        $series = $cycles->map(function (Cycle $cycle) use ($viewsByCycle, $postCountsByCycle) {
            $avgViews = $viewsByCycle->get($cycle->id);

            return [
                'cycle_id' => $cycle->id,
                'label' => $cycle->cycle_start_date->format('M Y'),
                'cycle_start_date' => $cycle->cycle_start_date->toDateString(),
                'cycle_end_date' => $cycle->cycle_end_date->toDateString(),
                'avg_views' => $avgViews === null ? null : (int) round($avgViews),
                'post_count' => $postCountsByCycle->get($cycle->id, 0),
            ];
        })->values();

        // Delta vs the immediately preceding cycle, per point — drives the sparkline
        // of ups/downs in the table without repeating the page's aggregate classification.
        $seriesWithDelta = $series->values()->map(function ($point, $index) use ($series) {
            if ($index === 0 || $point['avg_views'] === null) {
                return [...$point, 'delta_pct' => null];
            }

            $previous = $series[$index - 1];
            if ($previous['avg_views'] === null || $previous['avg_views'] <= 0) {
                return [...$point, 'delta_pct' => null];
            }

            return [...$point, 'delta_pct' => round((($point['avg_views'] - $previous['avg_views']) / $previous['avg_views']) * 100, 1)];
        });

        return response()->json([
            'account' => ['id' => $account->id, 'name' => $account->name],
            'platform' => $platform,
            'series' => $seriesWithDelta,
        ]);
    }

    /**
     * Average Views H+7 per cycle, across all accounts/platforms, keyed by cycle_id.
     * Same view-source precedence as AccountController::viewsFor() (Instagram
     * snapshot overrides the manually-typed column when a post is linked).
     */
    private function avgViewsByCycle(): Collection
    {
        return $this->viewsByCyclePerformances()
            ->map(fn (Collection $views) => $views->isEmpty() ? null : (float) $views->avg())
            ->filter(fn ($avg) => $avg !== null);
    }

    /**
     * Total (summed) Views H+7 per cycle — the volume number, alongside the
     * average shown elsewhere on this page. Same source/precedence as
     * avgViewsByCycle(), just summed instead of averaged.
     */
    private function totalViewsByCycle(): Collection
    {
        return $this->viewsByCyclePerformances()
            ->map(fn (Collection $views) => (int) $views->sum());
    }

    /**
     * Shared groundwork for avgViewsByCycle()/totalViewsByCycle(): every
     * performance's resolved view count, grouped by cycle_id. Memoized per
     * request — this scans the whole Performance table, and both callers
     * (plus multiple call sites within a single index()/pdf()/exportExcel()
     * request) would otherwise each trigger their own independent full scan.
     */
    private ?Collection $viewsByCyclePerformancesCache = null;

    private function viewsByCyclePerformances(): Collection
    {
        return $this->viewsByCyclePerformancesCache ??= Performance::whereNotNull('cycle_id')
            ->with(['igSnapshots' => fn ($query) => $query->limit(1)])
            ->get()
            ->groupBy('cycle_id')
            ->map(function (Collection $performances) {
                return $performances
                    ->map(function (Performance $performance) {
                        $snapshot = $performance->igSnapshots->first();

                        return $snapshot ? ($snapshot->views ?? $snapshot->total_interactions) : $performance->total_views_h7;
                    })
                    ->filter(fn ($views) => $views !== null);
            });
    }

    /**
     * Classify one account+platform's cycle-ordered avg-views series into a
     * trend row. Returns null when there's no cycle data at all for this
     * account on this platform (nothing to show), as opposed to exactly one
     * cycle's worth (shown as 'insufficient_data' so the account is still visible).
     */
    private function buildRow(Account $account, string $platform, Collection $series): ?array
    {
        $rowId = "{$account->id}:{$platform}";

        if ($series->count() < 2) {
            return $series->isEmpty() ? null : [
                'row_id' => $rowId,
                'account_id' => $account->id,
                'account_name' => $account->name,
                'platform' => $platform,
                'last_avg_views' => (int) round($series->last()['avg_views']),
                'prior_avg_views' => null,
                'last_total_views' => (int) ($series->last()['total_views'] ?? 0),
                'prior_total_views' => null,
                'delta_pct' => null,
                'trend' => 'insufficient_data',
                'stagnant_streak' => 0,
                'last_cycle_label' => $series->last()['label'],
            ];
        }

        $last = $series->last();
        $prior = $series->slice(-2, 1)->first();

        $deltaPct = $prior['avg_views'] > 0
            ? ($last['avg_views'] - $prior['avg_views']) / $prior['avg_views']
            : null;

        $stagnantStreak = $this->trailingFlatStreak($series);

        $trend = match (true) {
            $deltaPct === null => 'insufficient_data',
            $deltaPct <= self::SETBACK_THRESHOLD => 'setback',
            $stagnantStreak >= self::STAGNANT_STREAK => 'stagnant',
            $deltaPct >= self::GROWTH_THRESHOLD => 'growing',
            default => 'stable',
        };

        return [
            'row_id' => $rowId,
            'account_id' => $account->id,
            'account_name' => $account->name,
            'platform' => $platform,
            'last_avg_views' => (int) round($last['avg_views']),
            'prior_avg_views' => (int) round($prior['avg_views']),
            'last_total_views' => (int) ($last['total_views'] ?? 0),
            'prior_total_views' => (int) ($prior['total_views'] ?? 0),
            'delta_pct' => $deltaPct === null ? null : round($deltaPct * 100, 1),
            'trend' => $trend,
            'stagnant_streak' => $stagnantStreak,
            'last_cycle_label' => $last['label'],
        ];
    }

    /**
     * How many consecutive cycles, counting back from the most recent, stayed
     * within +/-STAGNANT_BAND of the cycle immediately before them. E.g. cycles
     * [100, 105, 98, 102] (latest last) -> compares 105->98 (flat), 98->102
     * (flat), so streak = 2 flat transitions = 3 flat cycles.
     */
    private function trailingFlatStreak(Collection $series): int
    {
        $values = $series->pluck('avg_views')->values();
        $streak = 1; // the latest cycle itself always counts as 1

        for ($i = $values->count() - 1; $i > 0; $i--) {
            $current = $values[$i];
            $previous = $values[$i - 1];

            if ($previous <= 0) {
                break;
            }

            $swing = abs($current - $previous) / $previous;

            if ($swing > self::STAGNANT_BAND) {
                break;
            }

            $streak++;
        }

        return $streak;
    }
}
