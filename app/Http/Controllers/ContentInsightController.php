<?php

namespace App\Http\Controllers;

use App\Exports\ContentInsightExport;
use App\Models\Account;
use App\Models\ContentInsight;
use App\Models\Cycle;
use App\Models\Employee;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response as HttpResponse;
use Illuminate\Support\Collection;
use Illuminate\Validation\Rule;
use Inertia\Inertia;
use Inertia\Response;
use Maatwebsite\Excel\Facades\Excel;

class ContentInsightController extends Controller
{
    public function index(Request $request): Response
    {
        $all = $this->allInsights();

        return Inertia::render('ContentInsights/Index', [
            'allInsights' => $all->values(),
            'months' => $all->pluck('month')->filter()->unique()->sort()->values(),
            'accounts' => Account::orderBy('name')->get(['id', 'name']),
            'projectManagers' => Employee::whereIn('id', Account::query()->whereNotNull('project_manager_id')->distinct()->pluck('project_manager_id'))
                ->orderBy('name')
                ->get(['id', 'name']),
        ]);
    }

    public function pdf(Request $request): HttpResponse
    {
        ['rows' => $rows, 'filters' => $filters] = $this->filteredSortedRows($request);

        $pdf = Pdf::loadView('pdf.content-insights-list', [
            'rows' => $rows->values(),
            'generatedAt' => now()->format('M j, Y g:i A'),
            'filterSummary' => $this->filterSummary($filters),
        ])->setPaper('a4', 'landscape');

        return $pdf->download('content-insights-'.now()->format('Y-m-d').'.pdf');
    }

    public function exportExcel(Request $request): \Symfony\Component\HttpFoundation\BinaryFileResponse
    {
        ['rows' => $rows] = $this->filteredSortedRows($request);

        return Excel::download(
            new ContentInsightExport($rows->values()),
            'content-insights-'.now()->format('Y-m-d').'.xlsx',
        );
    }

    /**
     * The flat, ungrouped insight rows — same shape the page's client-side
     * computeds are built from (one row per account+cycle, not yet grouped
     * into "one row per account").
     */
    private function allInsights(): Collection
    {
        return ContentInsight::with([
            'account:id,name,project_manager_id',
            'account.projectManager:id,name',
            'cycle:id,account_id,cycle_start_date,cycle_end_date,platform,end_follower',
        ])
            ->join('cycles', 'cycles.id', '=', 'content_insights.cycle_id')
            ->orderByDesc('cycles.cycle_start_date')
            ->select('content_insights.*')
            ->get()
            ->map(fn (ContentInsight $insight) => [
                'id' => $insight->id,
                'account_id' => $insight->account_id,
                'cycle_id' => $insight->cycle_id,
                'account_name' => $insight->account?->name,
                'project_manager_id' => $insight->account?->project_manager_id,
                'project_manager_name' => $insight->account?->projectManager?->name,
                'platform' => $insight->cycle?->platform,
                'month' => $insight->cycle?->cycle_start_date?->format('Y-m'),
                'cycle_start_date' => $insight->cycle?->cycle_start_date?->toDateString(),
                'cycle_end_date' => $insight->cycle?->cycle_end_date?->toDateString(),
                'end_follower' => $insight->cycle?->end_follower,
                'viewers_posts' => $insight->viewers_posts,
                'viewers_reels' => $insight->viewers_reels,
                'viewers_story' => $insight->viewers_story,
                'interactions_posts' => $insight->interactions_posts,
                'interactions_reels' => $insight->interactions_reels,
                'interactions_story' => $insight->interactions_story,
            ]);
    }

    // --- Weighted Content Score — ports the page's client-side computeds
    // (weightedScoresFor / accountRows / filteredRows / sortedRows in
    // ContentInsights/Index.vue) so the PDF/Excel exports show exactly what
    // the table shows, for the same search/platform/month-range/sort params. ---

    private const SCORE_WEIGHTS = [
        'posts' => [['source' => 'views', 'weight' => 0.5], ['source' => 'interactions', 'weight' => 0.2], ['source' => 'growth', 'weight' => 0.3]],
        'reels' => [['source' => 'views', 'weight' => 0.5], ['source' => 'interactions', 'weight' => 0.2], ['source' => 'growth', 'weight' => 0.3]],
        'story' => [['source' => 'views', 'weight' => 0.8], ['source' => 'interactions', 'weight' => 0.2]],
    ];

    private const CONTENT_TYPE_LABELS = ['posts' => 'Posts', 'reels' => 'Reels', 'story' => 'Story'];

    private function pct(?float $from, ?float $to): ?float
    {
        if ($from === null || $to === null || $from == 0) {
            return null;
        }

        return (($to - $from) / $from) * 100;
    }

    private function weightedScoresFor(array $from, array $to): array
    {
        $growthRate = $this->pct($from['end_follower'], $to['end_follower']);

        $result = [];
        foreach (self::SCORE_WEIGHTS as $type => $components) {
            $values = [
                'views' => $this->pct($from["viewers_{$type}"], $to["viewers_{$type}"]),
                'interactions' => $this->pct($from["interactions_{$type}"], $to["interactions_{$type}"]),
                'growth' => $growthRate,
            ];

            $available = array_filter($components, fn ($c) => $values[$c['source']] !== null);
            $weightSum = array_sum(array_column($available, 'weight'));

            $score = empty($available)
                ? null
                : array_sum(array_map(fn ($c) => ($values[$c['source']] * $c['weight']) / $weightSum, $available));

            $result[] = [
                'key' => $type,
                'label' => self::CONTENT_TYPE_LABELS[$type],
                'score' => $score,
            ];
        }

        return $result;
    }

    /**
     * One row per account — default: latest cycle vs. the one before it.
     * With month_from/month_to: that account's cycle in each picked month.
     * Then filtered by search/platform and sorted, matching the page exactly.
     */
    private function filteredSortedRows(Request $request): array
    {
        $all = $this->allInsights();

        $search = $request->string('search')->trim()->lower()->toString();
        $platform = $request->string('platform')->trim()->toString() ?: 'all';
        $pm = $request->string('pm')->trim()->toString() ?: 'all';
        $trend = $request->string('trend')->trim()->toString() ?: 'all';
        $monthFrom = $request->string('month_from')->trim()->toString() ?: null;
        $monthTo = $request->string('month_to')->trim()->toString() ?: null;
        $sortKey = $request->string('sort')->trim()->toString() ?: 'account';
        $direction = $request->string('direction')->trim()->toString() ?: 'asc';
        $hasRange = $monthFrom && $monthTo;

        if ($hasRange) {
            $byAccount = [];
            foreach ($all as $insight) {
                if ($insight['month'] !== $monthFrom && $insight['month'] !== $monthTo) {
                    continue;
                }
                $byAccount[$insight['account_id']][$insight['month']] = $insight;
            }

            $rows = collect();
            foreach ($byAccount as $pair) {
                $from = $pair[$monthFrom] ?? null;
                $to = $pair[$monthTo] ?? null;
                if (!$from || !$to) {
                    continue;
                }
                $rows->push(['current' => $to, 'previous' => $from, 'weightedScores' => $this->weightedScoresFor($from, $to)]);
            }
        } else {
            $latestByAccount = [];
            foreach ($all as $insight) {
                if (!$insight['cycle_start_date']) {
                    continue;
                }
                $existing = $latestByAccount[$insight['account_id']] ?? null;
                if (!$existing || $insight['cycle_start_date'] > $existing['cycle_start_date']) {
                    $latestByAccount[$insight['account_id']] = $insight;
                }
            }

            $rows = collect($latestByAccount)->map(function ($insight) use ($all) {
                $prev = collect($all)
                    ->filter(fn ($i) => $i['account_id'] === $insight['account_id']
                        && $i['cycle_start_date']
                        && $i['cycle_start_date'] < $insight['cycle_start_date'])
                    ->sortByDesc('cycle_start_date')
                    ->first();

                return [
                    'current' => $insight,
                    'previous' => $prev,
                    'weightedScores' => $prev ? $this->weightedScoresFor($prev, $insight) : null,
                ];
            })->values();
        }

        $scoreFor = fn ($row, $type) => collect($row['weightedScores'] ?? [])->firstWhere('key', $type)['score'] ?? null;

        // Overall trend — the average of whichever content-type scores are
        // available for the row, bucketed the same way Views Trend classifies
        // its own delta (>=+1% growing, <=-1% setback, else flat/stable).
        // A row with no weighted scores at all (no prior cycle) is 'no_data'.
        $overallTrend = function ($row) {
            $scores = collect($row['weightedScores'] ?? [])->pluck('score')->filter(fn ($s) => $s !== null);
            if ($scores->isEmpty()) {
                return 'no_data';
            }
            $avg = $scores->avg();

            return match (true) {
                $avg <= -1 => 'down',
                $avg >= 1 => 'up',
                default => 'flat',
            };
        };

        $rows = $rows->filter(function ($row) use ($search, $platform, $pm, $trend, $overallTrend) {
            $matchesSearch = !$search || str_contains(strtolower($row['current']['account_name'] ?? ''), $search);
            $matchesPlatform = $platform === 'all' || $row['current']['platform'] === $platform;
            $matchesPm = $pm === 'all' || (string) $row['current']['project_manager_id'] === $pm;
            $matchesTrend = $trend === 'all' || $overallTrend($row) === $trend;

            return $matchesSearch && $matchesPlatform && $matchesPm && $matchesTrend;
        })->values();

        if ($sortKey === 'account') {
            $rows = $rows->sortBy(fn ($row) => $row['current']['account_name'] ?? '', SORT_NATURAL | SORT_FLAG_CASE);
            if ($direction === 'desc') {
                $rows = $rows->reverse();
            }
        } else {
            $withValue = $rows->filter(fn ($row) => $scoreFor($row, $sortKey) !== null);
            $withoutValue = $rows->filter(fn ($row) => $scoreFor($row, $sortKey) === null);

            $withValue = $withValue->sortBy(fn ($row) => $scoreFor($row, $sortKey));
            if ($direction === 'desc') {
                $withValue = $withValue->reverse();
            }
            $rows = $withValue->values()->concat($withoutValue->values());
        }

        return [
            'rows' => $rows->values(),
            'filters' => [
                'search' => $search,
                'platform' => $platform,
                'pm' => $pm,
                'trend' => $trend,
                'month_from' => $monthFrom,
                'month_to' => $monthTo,
                'has_range' => $hasRange,
            ],
        ];
    }

    private function filterSummary(array $filters): string
    {
        $parts = [];

        if (!empty($filters['search'])) {
            $parts[] = 'search: "'.$filters['search'].'"';
        }
        if (!empty($filters['platform']) && $filters['platform'] !== 'all') {
            $parts[] = 'platform: '.ucfirst($filters['platform']);
        }
        if (!empty($filters['pm']) && $filters['pm'] !== 'all') {
            $pmName = Employee::find($filters['pm'])?->name;
            if ($pmName) {
                $parts[] = 'PM: '.$pmName;
            }
        }
        if (!empty($filters['trend']) && $filters['trend'] !== 'all') {
            $parts[] = 'trend: '.ucfirst(str_replace('_', ' ', $filters['trend']));
        }
        if (!empty($filters['has_range'])) {
            $parts[] = 'compared: '.$filters['month_from'].' vs '.$filters['month_to'];
        } else {
            $parts[] = "scored against each account's previous cycle";
        }

        return $parts ? implode(' · ', $parts) : 'none';
    }

    /**
     * Cycles for a given account, for the dependent "cycle" select box.
     */
    public function cycles(Account $account): JsonResponse
    {
        // Existing insights for this account, keyed by cycle_id — so the
        // create/edit form can auto-fill Viewers/Interactions the moment a
        // cycle with recorded data is picked, without a second request.
        $insightsByCycle = ContentInsight::where('account_id', $account->id)
            ->get()
            ->keyBy('cycle_id');

        return response()->json(
            $account->cycles()
                ->orderByDesc('cycle_start_date')
                ->get(['id', 'cycle_start_date', 'cycle_end_date', 'platform'])
                ->map(function (Cycle $cycle) use ($insightsByCycle) {
                    $insight = $insightsByCycle->get($cycle->id);

                    return [
                        'id' => $cycle->id,
                        'platform' => $cycle->platform,
                        'cycle_start_date' => $cycle->cycle_start_date->toDateString(),
                        'cycle_end_date' => $cycle->cycle_end_date->toDateString(),
                        'label' => $this->cycleLabel($cycle),
                        'insight' => $insight ? [
                            'id' => $insight->id,
                            'viewers_posts' => $insight->viewers_posts,
                            'viewers_reels' => $insight->viewers_reels,
                            'viewers_story' => $insight->viewers_story,
                            'interactions_posts' => $insight->interactions_posts,
                            'interactions_reels' => $insight->interactions_reels,
                            'interactions_story' => $insight->interactions_story,
                        ] : null,
                    ];
                })
        );
    }

    public function store(Request $request): RedirectResponse
    {
        $data = $this->validated($request);

        // One row per account + cycle — updating the same pair overwrites.
        ContentInsight::updateOrCreate(
            ['account_id' => $data['account_id'], 'cycle_id' => $data['cycle_id']],
            $data,
        );

        return back();
    }

    public function update(Request $request, ContentInsight $contentInsight): RedirectResponse
    {
        $contentInsight->update($this->validated($request));

        return back();
    }

    public function destroy(ContentInsight $contentInsight): RedirectResponse
    {
        $contentInsight->delete();

        return back();
    }

    private function validated(Request $request): array
    {
        return $request->validate([
            'account_id' => ['required', 'exists:accounts,id'],
            'cycle_id' => [
                'required',
                Rule::exists('cycles', 'id')->where(
                    fn ($query) => $query->where('account_id', $request->input('account_id'))
                ),
            ],
            'viewers_posts' => ['required', 'integer', 'min:0'],
            'viewers_reels' => ['required', 'integer', 'min:0'],
            'viewers_story' => ['required', 'integer', 'min:0'],
            'interactions_posts' => ['required', 'integer', 'min:0'],
            'interactions_reels' => ['required', 'integer', 'min:0'],
            'interactions_story' => ['required', 'integer', 'min:0'],
        ]);
    }

    private function cycleLabel(Cycle $cycle): string
    {
        $range = $cycle->cycle_start_date->format('d M Y').' – '.$cycle->cycle_end_date->format('d M Y');

        return ucfirst($cycle->platform).' · '.$range;
    }
}
