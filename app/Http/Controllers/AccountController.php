<?php

namespace App\Http\Controllers;

use App\Models\Account;
use App\Models\Cycle;
use App\Models\Performance;
use App\Services\MetricCalculator;
use App\Services\SummaryProviderResolver;
use App\Models\Employee;
use App\Models\FormulaWeight;
use App\Models\LabelBucket;
use App\Models\ScoreBucket;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response as HttpResponse;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Collection;
use Illuminate\Support\Str;
use Inertia\Inertia;
use Inertia\Response;

class AccountController extends Controller
{
    public function index(Request $request, MetricCalculator $calculator): Response
    {
        $search = $request->string('search')->trim()->toString() ?: null;
        $pmId = $request->integer('project_manager_id') ?: null;
        $sortKey = $request->string('sort')->toString() ?: 'name';
        $direction = $request->string('direction')->toString() === 'desc' ? 'desc' : 'asc';

        $accounts = $sortKey === 'health'
            ? $this->paginateSortedByHealth($request, $search, $pmId, $direction, $calculator)
            : $this->paginateSortedBySqlColumn($request, $search, $pmId, $sortKey, $direction);

        // KPIs computed over ALL accounts (not just this page), same convention as the
        // Dashboard's header row — a paginated table shouldn't make the summary numbers
        // page-dependent.
        $allAccountIds = Account::pluck('id');
        $allHealth = $this->latestCycleHealthByAccount($allAccountIds, $calculator);

        return Inertia::render('Accounts/Index', [
            'accounts' => $accounts,
            'summary' => [
                'total' => $allAccountIds->count(),
                'instagram_connected' => Account::whereNotNull('ig_business_id')->count(),
                'at_risk' => $allHealth->filter(fn ($label) => in_array($label, ['KURANG', 'PARAH'], true))->count(),
            ],
            'filters' => [
                'search' => $search,
                'project_manager_id' => $pmId,
                'sort' => $sortKey,
                'direction' => $direction,
            ],
            'accountDepartmentEmployees' => Employee::whereHas(
                'department',
                fn ($query) => $query->where('name', 'Account')
            )->orderBy('name')->get(['id', 'name']),
            'defaultAiProvider' => config('services.ai_summary.provider', 'groq'),
        ]);
    }

    /**
     * Sort by name/PM/cycle-count — all real SQL columns, so this stays a normal
     * paginated query. Health/platform data is layered on afterward per-page,
     * same as the health-sort path below.
     */
    private function paginateSortedBySqlColumn(Request $request, ?string $search, ?int $pmId, string $sortKey, string $direction): LengthAwarePaginator
    {
        $sortColumns = [
            'name' => 'accounts.name',
            'pm' => 'employees.name',
            'cycles' => 'cycles_count',
        ];
        $sortColumn = $sortColumns[$sortKey] ?? 'accounts.name';

        $accounts = Account::with('projectManager:id,name')
            ->leftJoin('employees', 'employees.id', '=', 'accounts.project_manager_id')
            ->withCount('cycles')
            ->when($search, fn ($query, $search) => $query->where('accounts.name', 'like', "%{$search}%"))
            ->when($pmId, fn ($query, $pmId) => $query->where('accounts.project_manager_id', $pmId))
            ->orderBy($sortColumn, $direction)
            ->orderBy('accounts.name')
            ->paginate(15)
            ->withQueryString();

        $this->decorateWithHealthAndPlatforms($accounts, app(MetricCalculator::class));

        return $accounts;
    }

    /**
     * Sort by Health — not a real column (it's computed per-account from that
     * account's latest cycle via MetricCalculator, and bucket thresholds are
     * user-configurable so it can't be precomputed in SQL). Loads every account
     * matching the filters, computes health for all of them, sorts by severity
     * order, then paginates the already-sorted PHP collection manually — same
     * pattern CycleController uses for its own score-based sorting.
     */
    private function paginateSortedByHealth(Request $request, ?string $search, ?int $pmId, string $direction, MetricCalculator $calculator): LengthAwarePaginator
    {
        $matching = Account::with('projectManager:id,name')
            ->withCount('cycles')
            ->when($search, fn ($query, $search) => $query->where('name', 'like', "%{$search}%"))
            ->when($pmId, fn ($query, $pmId) => $query->where('project_manager_id', $pmId))
            ->orderBy('name')
            ->get();

        $healthByAccount = $this->latestCycleHealthByAccount($matching->pluck('id'), $calculator);
        $platformsByAccount = $this->platformsByAccount($matching->pluck('id'));

        // Severity order worst-to-best; accounts with no cycles (no health label at
        // all) sort last regardless of direction — "no data" isn't better or worse
        // than a real score, it just doesn't belong ranked among scored accounts.
        $severityRank = ['PARAH' => 0, 'KURANG' => 1, 'CUKUP' => 2, 'BAGUS' => 3, 'SIP' => 4];

        $sorted = $matching
            ->map(fn (Account $account) => [
                'account' => $account,
                'health_label' => $healthByAccount->get($account->id),
                'platforms' => $platformsByAccount->get($account->id, []),
            ])
            ->sort(function ($a, $b) use ($severityRank, $direction) {
                $rankA = $severityRank[$a['health_label']] ?? PHP_INT_MAX;
                $rankB = $severityRank[$b['health_label']] ?? PHP_INT_MAX;

                if ($rankA === PHP_INT_MAX && $rankB === PHP_INT_MAX) {
                    return 0;
                }
                if ($rankA === PHP_INT_MAX || $rankB === PHP_INT_MAX) {
                    return $rankA <=> $rankB;
                }

                return $direction === 'desc' ? $rankB <=> $rankA : $rankA <=> $rankB;
            })
            ->values();

        $page = $request->integer('page', 1);
        $perPage = 15;

        $paginator = new LengthAwarePaginator(
            $sorted->forPage($page, $perPage)->values(),
            $sorted->count(),
            $perPage,
            $page,
            ['path' => $request->url(), 'query' => $request->query()],
        );

        $paginator->through(fn ($row) => $this->presentAccount($row['account'], $row['health_label'], $row['platforms']));

        return $paginator;
    }

    /**
     * Layers health_label/platforms onto an already-paginated (SQL-sorted) page
     * of accounts — shared by the SQL-sort path so it doesn't duplicate the
     * present-a-row shape used by the health-sort path.
     */
    private function decorateWithHealthAndPlatforms(LengthAwarePaginator $accounts, MetricCalculator $calculator): void
    {
        $healthByAccount = $this->latestCycleHealthByAccount($accounts->pluck('id'), $calculator);
        $platformsByAccount = $this->platformsByAccount($accounts->pluck('id'));

        $accounts->through(fn (Account $account) => $this->presentAccount(
            $account,
            $healthByAccount->get($account->id),
            $platformsByAccount->get($account->id, []),
        ));
    }

    private function presentAccount(Account $account, ?string $healthLabel, array $platforms): array
    {
        return [
            'id' => $account->id,
            'name' => $account->name,
            'project_manager_id' => $account->project_manager_id,
            'project_manager' => $account->projectManager,
            'cycles_count' => $account->cycles_count,
            'ig_business_id' => $account->ig_business_id,
            'ig_username' => $account->ig_username,
            'ig_connected_at' => $account->ig_connected_at?->toIso8601String(),
            'health_label' => $healthLabel,
            'platforms' => $platforms,
        ];
    }

    /**
     * Health label of each account's most recently-started cycle, keyed by
     * account_id — the same "latest cycle" convention used by the Account
     * Growth modal's headline stat. Accounts with no cycles simply have no
     * entry (row shows "No data" instead of a status badge).
     */
    private function latestCycleHealthByAccount(Collection $accountIds, MetricCalculator $calculator): Collection
    {
        if ($accountIds->isEmpty()) {
            return collect();
        }

        $scoreBuckets = ScoreBucket::all();
        $labelBuckets = LabelBucket::all();
        $formulaWeights = FormulaWeight::all();

        return Cycle::whereIn('account_id', $accountIds)
            ->orderBy('cycle_start_date')
            ->get()
            ->groupBy('account_id')
            ->map(function (Collection $cycles) use ($calculator, $scoreBuckets, $labelBuckets, $formulaWeights) {
                $latest = $cycles->last();

                return $calculator->calculate($latest, $scoreBuckets, $labelBuckets, $formulaWeights)['health_label'];
            });
    }

    /**
     * Which platforms (instagram/tiktok) each account has at least one cycle
     * on, keyed by account_id — drives the platform icons on the accounts list.
     */
    private function platformsByAccount(Collection $accountIds): Collection
    {
        if ($accountIds->isEmpty()) {
            return collect();
        }

        return Cycle::whereIn('account_id', $accountIds)
            ->get(['account_id', 'platform'])
            ->groupBy('account_id')
            ->map(fn (Collection $cycles) => $cycles->pluck('platform')->unique()->values()->all());
    }

    public function growth(Account $account, MetricCalculator $calculator): JsonResponse
    {
        $scoreBuckets = ScoreBucket::all();
        $labelBuckets = LabelBucket::all();
        $formulaWeights = FormulaWeight::all();

        $postCountsByCycle = $this->postCountsByCycle($account);

        $cycles = $account->cycles()
            ->orderBy('cycle_start_date')
            ->get()
            ->map(function ($cycle) use ($calculator, $scoreBuckets, $labelBuckets, $formulaWeights, $postCountsByCycle) {
                $scores = $calculator->calculate($cycle, $scoreBuckets, $labelBuckets, $formulaWeights);
                $postCounts = $postCountsByCycle->get($cycle->id, ['post_count' => 0, 'view_count' => 0]);

                return [
                    'label' => $cycle->cycle_start_date->format('M Y'),
                    'cycle_start_date' => $cycle->cycle_start_date->toDateString(),
                    'platform' => $cycle->platform,
                    'growth_rate' => round($scores['growth_rate'], 2),
                    'end_follower' => $cycle->end_follower,
                    'reach' => $cycle->reach,
                    'views' => $cycle->views,
                    'engagement' => $cycle->engagement,
                    'story_performance' => $cycle->story_performance,
                    'visibility_rate' => round($scores['visibility_rate'], 2),
                    'engagement_score' => round($scores['engagement_score'], 2),
                    'health_rate' => round($scores['health_rate'], 2),
                    'health_label' => $scores['health_label'],
                    'er_reach_rate' => round($scores['er_reach_rate'], 2),
                    'er_follower_rate' => round($scores['er_follower_rate'], 2),
                    'post_count' => $postCounts['post_count'],
                    'view_count' => $postCounts['view_count'],
                ];
            });

        return response()->json([
            'account' => ['id' => $account->id, 'name' => $account->name],
            'cycles' => $cycles,
            'postSummary' => $this->postSummaryByPlatform($account),
            'ai_summary' => $account->ai_summary,
            'ai_summary_generated_at' => $account->ai_summary_generated_at?->toIso8601String(),
        ]);
    }

    /**
     * Views H+7 for a post, overlaid from its latest Instagram snapshot when
     * linked — same source used everywhere else this metric is shown, since
     * the manually-typed total_views_h7 column goes stale once a post is
     * linked to Instagram.
     */
    private function viewsFor(Performance $performance): ?int
    {
        $snapshot = $performance->igSnapshots->first();

        return $snapshot ? ($snapshot->views ?? $snapshot->total_interactions) : $performance->total_views_h7;
    }

    /**
     * Total post count, total Views H+7, and average Views H+7 for this
     * account, split by platform (matching the modal's Instagram/TikTok
     * tabs) — plus a with-cycle / without-cycle breakdown of posts and views,
     * since a post's cycle_id is auto-assigned only when a cycle's date range
     * actually covers its post_date (see PerformanceCycleAssigner) and some
     * posts legitimately have none yet.
     */
    private function postSummaryByPlatform(Account $account): array
    {
        $performances = Performance::where('account_id', $account->id)
            ->with(['igSnapshots' => fn ($query) => $query->limit(1)])
            ->get();

        $countAndViews = function (Collection $group) {
            $viewsWithValue = $group->map(fn (Performance $performance) => $this->viewsFor($performance))
                ->filter(fn ($views) => $views !== null);

            return [
                'total_posts' => $group->count(),
                'total_views' => (int) $viewsWithValue->sum(),
            ];
        };

        $summaryFor = function (string $platform) use ($performances, $countAndViews) {
            $platformPerformances = $performances->filter(fn (Performance $performance) => ($performance->platform ?? 'instagram') === $platform);
            $viewsWithValue = $platformPerformances->map(fn (Performance $performance) => $this->viewsFor($performance))
                ->filter(fn ($views) => $views !== null);

            return [
                'total_posts' => $platformPerformances->count(),
                'total_views' => (int) $viewsWithValue->sum(),
                // Averaged over posts with a recorded view count, not every post — a post with
                // no data yet shouldn't drag the average toward zero (matches avg_views elsewhere).
                'avg_views' => $viewsWithValue->isEmpty() ? null : (int) round($viewsWithValue->avg()),
                'with_cycle' => $countAndViews($platformPerformances->filter(fn (Performance $performance) => $performance->cycle_id !== null)),
                'without_cycle' => $countAndViews($platformPerformances->filter(fn (Performance $performance) => $performance->cycle_id === null)),
            ];
        };

        return [
            'instagram' => $summaryFor('instagram'),
            'tiktok' => $summaryFor('tiktok'),
        ];
    }

    /**
     * Post count and total Views H+7 per cycle, keyed by cycle_id — used to
     * plot "posts/views per cycle" trend lines alongside the existing
     * follower/rate charts. Posts with no matching cycle (Performance's
     * auto-assigned cycle_id is null) are simply excluded, since this report
     * is indexed by cycle.
     */
    private function postCountsByCycle(Account $account): Collection
    {
        return Performance::where('account_id', $account->id)
            ->whereNotNull('cycle_id')
            ->with(['igSnapshots' => fn ($query) => $query->limit(1)])
            ->get()
            ->groupBy('cycle_id')
            ->map(fn (Collection $performances) => [
                'post_count' => $performances->count(),
                'view_count' => (int) $performances->sum(fn (Performance $performance) => $this->viewsFor($performance) ?? 0),
            ]);
    }

    public function summarize(Request $request, Account $account, MetricCalculator $calculator, SummaryProviderResolver $resolver): JsonResponse
    {
        $data = $request->validate([
            'prompt' => ['nullable', 'string', 'max:500'],
            'provider' => ['nullable', 'string', 'in:'.implode(',', SummaryProviderResolver::PROVIDERS)],
        ]);

        $scoreBuckets = ScoreBucket::all();
        $labelBuckets = LabelBucket::all();
        $formulaWeights = FormulaWeight::all();

        $cycles = $account->cycles()
            ->orderBy('cycle_start_date')
            ->get()
            ->map(fn ($cycle) => [
                'cycle' => $cycle->setRelation('account', $account),
                'scores' => $calculator->calculate($cycle, $scoreBuckets, $labelBuckets, $formulaWeights),
            ]);

        if ($cycles->isEmpty()) {
            return response()->json(['message' => 'No cycles recorded for this account yet.'], 422);
        }

        $filterDescription = ['summary' => "account: {$account->name}"];

        try {
            $summary = $resolver->resolve($data['provider'] ?? null)
                ->summarizeFiltered($cycles, $filterDescription, $data['prompt'] ?? null);
        } catch (\Throwable $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        $account->forceFill([
            'ai_summary' => $summary,
            'ai_summary_generated_at' => now(),
        ])->save();

        return response()->json([
            'summary' => $summary,
            'cycle_count' => $cycles->count(),
            'generated_at' => $account->ai_summary_generated_at->toIso8601String(),
        ]);
    }

    public function pdf(Request $request, Account $account): HttpResponse
    {
        $data = $request->validate([
            'charts' => ['required', 'array', 'min:1'],
            'charts.*.label' => ['required', 'string'],
            'charts.*.image' => ['required', 'string'],
            'ai_summary' => ['nullable', 'string'],
            'summary' => ['nullable', 'array'],
            'summary.platform' => ['nullable', 'string'],
            'summary.followers' => ['nullable', 'numeric'],
            'summary.followers_delta' => ['nullable', 'numeric'],
            'summary.health_label' => ['nullable', 'string'],
            'summary.health_rate' => ['nullable', 'numeric'],
            'summary.growth_rate' => ['nullable', 'numeric'],
            'summary.avg_views' => ['nullable', 'numeric'],
            'summary.total_posts' => ['nullable', 'numeric'],
            'summary.latest_cycle_label' => ['nullable', 'string'],
            'summary.volume' => ['nullable', 'array'],
            'summary.volume.*.label' => ['required_with:summary.volume', 'string'],
            'summary.volume.*.value' => ['nullable', 'numeric'],
            'summary.volume.*.delta' => ['nullable', 'numeric'],
        ]);

        $pdf = Pdf::loadView('pdf.account-growth', [
            'account' => $account,
            'charts' => $data['charts'],
            'aiSummary' => $data['ai_summary'] ?? null,
            'summary' => $data['summary'] ?? null,
            'generatedAt' => now()->format('M j, Y g:i A'),
        ])->setPaper('a4', 'portrait');

        $filename = sprintf('%s-growth-%s.pdf', Str::slug($account->name), now()->format('Y-m-d'));

        return $pdf->download($filename);
    }

    public function store(Request $request): RedirectResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'project_manager_id' => ['nullable', 'exists:employees,id'],
        ]);

        Account::create($data);

        return back();
    }

    public function update(Request $request, Account $account): RedirectResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'project_manager_id' => ['nullable', 'exists:employees,id'],
        ]);

        $account->update($data);

        return back();
    }

    public function destroy(Account $account): RedirectResponse
    {
        $account->delete();

        return back();
    }
}
