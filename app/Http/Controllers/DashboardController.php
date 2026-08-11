<?php

namespace App\Http\Controllers;

use App\Models\Account;
use App\Models\Cycle;
use App\Models\Employee;
use App\Models\FormulaWeight;
use App\Models\LabelBucket;
use App\Models\Performance;
use App\Models\ScoreBucket;
use App\Services\MetricCalculator;
use App\Services\ScoreBucketResolver;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Inertia\Inertia;
use Inertia\Response;

class DashboardController extends Controller
{
    public function index(Request $request, MetricCalculator $calculator, ScoreBucketResolver $resolver): Response
    {
        $platform = in_array($request->query('platform'), ['instagram', 'tiktok'], true)
            ? $request->query('platform')
            : 'all';

        // range = 'all' (all-time) or 'Y-m' (a specific month), applied against the record's own date field.
        $range = $request->query('range', 'all');

        $platformCounts = [
            'instagram' => Cycle::where('platform', 'instagram')->count(),
            'tiktok' => Cycle::where('platform', 'tiktok')->count(),
        ];

        return Inertia::render('Dashboard/Index', [
            'filters' => [
                'platform' => $platform,
                'range' => $range,
            ],
            'platformCounts' => $platformCounts,
            'employeesCount' => Employee::count(),
            'cycleData' => fn () => $this->buildCycleData($platform, $range, $calculator),
            'performanceData' => fn () => $this->buildPerformanceData($platform, $range, $resolver),
        ]);
    }

    private function buildCycleData(string $platform, string $range, MetricCalculator $calculator): array
    {
        $scoreBuckets = ScoreBucket::all();
        $labelBuckets = LabelBucket::all();
        $formulaWeights = FormulaWeight::all();

        $cycleQuery = Cycle::query()->orderBy('cycle_start_date');
        if ($platform !== 'all') {
            $cycleQuery->where('platform', $platform);
        }

        $allCyclesForPlatform = $cycleQuery->get();

        $availableMonths = $allCyclesForPlatform
            ->map(fn (Cycle $cycle) => $cycle->cycle_start_date->format('Y-m'))
            ->unique()
            ->sortDesc()
            ->values();

        $cycles = $range === 'all'
            ? $allCyclesForPlatform
            : $allCyclesForPlatform->filter(fn (Cycle $cycle) => $cycle->cycle_start_date->format('Y-m') === $range)->values();

        $scoredCycles = $cycles->map(fn (Cycle $cycle) => [
            'cycle' => $cycle,
            'scores' => $calculator->calculate($cycle, $scoreBuckets, $labelBuckets, $formulaWeights),
        ]);

        $healthLabelOrder = ['PARAH', 'KURANG', 'CUKUP', 'BAGUS', 'SIP'];

        $healthDistribution = collect($healthLabelOrder)->mapWithKeys(fn ($label) => [
            $label => $scoredCycles->where('scores.health_label', $label)->count(),
        ]);

        // Monthly cycle-count trend for the last 6 months, always all-time regardless of range filter.
        $monthlyTrend = $this->buildMonthlyTrend($allCyclesForPlatform, fn (Cycle $cycle) => $cycle->cycle_start_date);

        $topProjectManagers = $this->buildTopProjectManagers($scoredCycles);

        $accountsCount = $platform === 'all'
            ? Account::count()
            : $allCyclesForPlatform->pluck('account_id')->unique()->count();

        return [
            'availableMonths' => $availableMonths,
            'summary' => [
                'accounts_count' => $accountsCount,
                'cycles_count' => $cycles->count(),
                'avg_health_rate' => $scoredCycles->isEmpty() ? null : round($scoredCycles->avg('scores.health_rate'), 2),
                'healthy_cycles_count' => $scoredCycles->where('scores.health_label', 'SIP')->count(),
                'at_risk_cycles_count' => $scoredCycles->whereIn('scores.health_label', ['KURANG', 'PARAH'])->count(),
            ],
            'healthDistribution' => [
                'tiers' => $healthLabelOrder,
                'counts' => $healthDistribution,
            ],
            'monthlyTrend' => $monthlyTrend,
            'topProjectManagers' => $topProjectManagers,
        ];
    }

    private function buildPerformanceData(string $platform, string $range, ScoreBucketResolver $resolver): array
    {
        $viewsBuckets = LabelBucket::where('metric', LabelBucket::METRIC_VIEWS)->get();

        $performanceQuery = Performance::with(['igSnapshots' => fn ($query) => $query->limit(1)])
            ->orderBy('post_date');
        if ($platform !== 'all') {
            $performanceQuery->where('platform', $platform);
        }

        $allPerformancesForPlatform = $performanceQuery->get()->map(function (Performance $performance) use ($resolver, $viewsBuckets) {
            $snapshot = $performance->igSnapshots->first();
            if ($snapshot) {
                $performance->total_views_h7 = $snapshot->views ?? $snapshot->total_interactions;
            }

            $performance->views_status = $performance->total_views_h7 === null
                ? null
                : $resolver->resolve($viewsBuckets, (float) $performance->total_views_h7, 'min_score', 'label');

            return $performance;
        });

        $availableMonths = $allPerformancesForPlatform
            ->filter(fn (Performance $performance) => $performance->post_date !== null)
            ->map(fn (Performance $performance) => $performance->post_date->format('Y-m'))
            ->unique()
            ->sortDesc()
            ->values();

        $performances = $range === 'all'
            ? $allPerformancesForPlatform
            : $allPerformancesForPlatform->filter(
                fn (Performance $performance) => $performance->post_date !== null && $performance->post_date->format('Y-m') === $range
            )->values();

        $viewsLabelOrder = $viewsBuckets->sortByDesc('min_score')->pluck('label')->values();
        $topTierCount = (int) ceil($viewsLabelOrder->count() / 2);
        $topTierLabels = $viewsLabelOrder->take($topTierCount);
        $bottomTierLabels = $viewsLabelOrder->skip($topTierCount);

        $viewsWithValue = $performances->filter(fn ($performance) => $performance->total_views_h7 !== null);

        $viewsDistributionTiers = $viewsLabelOrder->reverse()->values();
        $viewsCounts = array_fill_keys($viewsDistributionTiers->all(), 0);
        foreach ($performances as $performance) {
            if ($performance->views_status !== null && array_key_exists($performance->views_status, $viewsCounts)) {
                $viewsCounts[$performance->views_status]++;
            }
        }

        $monthlyTrend = $this->buildMonthlyTrend($allPerformancesForPlatform, fn (Performance $performance) => $performance->post_date, fn (Performance $performance) => $performance->post_date !== null);

        $accountsCount = $platform === 'all'
            ? Account::count()
            : $allPerformancesForPlatform->pluck('account_id')->unique()->count();

        return [
            'availableMonths' => $availableMonths,
            'summary' => [
                'accounts_count' => $accountsCount,
                'performances_count' => $performances->count(),
                'avg_views' => $viewsWithValue->isEmpty() ? null : round($viewsWithValue->avg('total_views_h7')),
                'top_performing_count' => $performances->whereIn('views_status', $topTierLabels)->count(),
                'at_risk_count' => $performances->whereIn('views_status', $bottomTierLabels)->count(),
            ],
            'viewsDistribution' => [
                'tiers' => $viewsDistributionTiers,
                'counts' => $viewsCounts,
            ],
            'monthlyTrend' => $monthlyTrend,
            'platformCounts' => [
                'instagram' => $performances->where('platform', 'instagram')->count(),
                'tiktok' => $performances->where('platform', 'tiktok')->count(),
            ],
            'topProjectManagers' => $this->buildTopEmployeesByPostCount($performances, 'project_manager_id'),
            'topConceptors' => $this->buildTopEmployeesByPostCount($performances, 'conceptor_id'),
        ];
    }

    /**
     * Top 3 employees by number of performance posts assigned to them under
     * the given foreign key (editor_id or conceptor_id). Posts with no one
     * assigned are excluded rather than grouped under a fake "unassigned" entry.
     */
    private function buildTopEmployeesByPostCount(Collection $performances, string $foreignKey): array
    {
        $assigned = $performances->filter(fn (Performance $performance) => $performance->{$foreignKey} !== null);

        $byEmployee = $assigned->groupBy($foreignKey);

        $employeeNames = Employee::whereIn('id', $byEmployee->keys())->pluck('name', 'id');

        $ranked = $byEmployee->map(fn (Collection $rows, $employeeId) => [
            'employee_id' => (int) $employeeId,
            'employee_name' => $employeeNames->get($employeeId, 'Unknown'),
            'post_count' => $rows->count(),
        ])->sortByDesc('post_count')->take(3)->values();

        return $ranked->all();
    }

    /**
     * Record count per month for the 6 most recent months that actually have
     * data, oldest first — a simple activity trend for the dashboard. Shared
     * by Cycles (cycle_start_date) and Performance (post_date).
     */
    private function buildMonthlyTrend(Collection $records, \Closure $dateGetter, ?\Closure $filter = null): array
    {
        if ($filter) {
            $records = $records->filter($filter);
        }

        $byMonth = $records->groupBy(fn ($record) => $dateGetter($record)->format('Y-m'));

        $months = $byMonth->keys()->sort()->values()->take(-6);

        return $months->map(fn ($month) => [
            'label' => \Carbon\Carbon::createFromFormat('Y-m-d', "{$month}-01")->format('M Y'),
            'count' => $byMonth->get($month)->count(),
        ])->values()->all();
    }

    /**
     * Top 3 project managers by average Health Rate across the cycles
     * assigned to them (via cycle.project_manager_id — a cycle's PM can
     * differ from its account's default PM). Cycles with no PM set are
     * excluded rather than grouped under a fake "unassigned" entry.
     */
    private function buildTopProjectManagers(Collection $scoredCycles): array
    {
        $withPm = $scoredCycles->filter(fn ($row) => $row['cycle']->project_manager_id !== null);

        $byPm = $withPm->groupBy(fn ($row) => $row['cycle']->project_manager_id);

        $employeeNames = Employee::whereIn('id', $byPm->keys())->pluck('name', 'id');

        $ranked = $byPm->map(function (Collection $rows, $pmId) use ($employeeNames) {
            $avgHealthRate = $rows->avg('scores.health_rate');

            return [
                'employee_id' => (int) $pmId,
                'employee_name' => $employeeNames->get($pmId, 'Unknown'),
                'avg_health_rate' => round($avgHealthRate, 2),
                'cycle_count' => $rows->count(),
            ];
        })->sortByDesc('avg_health_rate')->take(3)->values();

        return $ranked->all();
    }
}
