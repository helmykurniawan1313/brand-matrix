<?php

namespace App\Http\Controllers;

use App\Models\Account;
use App\Models\Cycle;
use App\Models\FilterSummary;
use App\Models\FormulaWeight;
use App\Models\LabelBucket;
use App\Models\ScoreBucket;
use App\Services\MetricCalculator;
use App\Services\SummaryProviderResolver;
use Barryvdh\DomPDF\Facade\Pdf;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response as HttpResponse;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Collection;
use Illuminate\Support\Str;
use Inertia\Inertia;
use Inertia\Response;

class CycleController extends Controller
{
    public function index(Request $request, MetricCalculator $calculator): Response
    {
        $scoreBuckets = ScoreBucket::all();
        $labelBuckets = LabelBucket::all();
        $formulaWeights = FormulaWeight::all();

        $healthLabel = $request->string('health_label')->trim()->toString() ?: null;
        $monthFrom = $request->string('month_from')->trim()->toString() ?: null;
        $monthTo = $request->string('month_to')->trim()->toString() ?: null;

        $filtered = Cycle::with('account')
            ->when($request->integer('account_id'), fn ($query, $accountId) => $query->where('account_id', $accountId))
            ->when($request->string('search')->trim()->toString(), function ($query, $search) {
                $query->whereHas('account', fn ($accountQuery) => $accountQuery->where('name', 'like', "%{$search}%"));
            })
            ->when($monthFrom, fn ($query, $monthFrom) => $this->applyMonthRangeFilter($query, $monthFrom, $monthTo))
            ->orderByDesc('cycle_start_date');

        $matching = $filtered->get()->map(fn (Cycle $cycle) => [
            ...$cycle->toArray(),
            'scores' => $calculator->calculate($cycle, $scoreBuckets, $labelBuckets, $formulaWeights),
        ]);

        if ($healthLabel) {
            $matching = $matching->filter(fn ($cycle) => $cycle['scores']['health_label'] === $healthLabel)->values();
        }

        $page = $request->integer('page', 1);
        $perPage = 15;

        $paginator = new LengthAwarePaginator(
            $matching->forPage($page, $perPage)->values(),
            $matching->count(),
            $perPage,
            $page,
            ['path' => $request->url(), 'query' => $request->query()],
        );

        $availableYears = Cycle::pluck('cycle_start_date')
            ->map(fn ($date) => (int) $date->format('Y'))
            ->unique()
            ->sortDesc()
            ->values();

        return Inertia::render('Cycles/Index', [
            'cycles' => $paginator,
            'accounts' => Account::orderBy('name')->get(),
            'healthLabels' => LabelBucket::where('metric', LabelBucket::METRIC_HEALTH)
                ->orderByDesc('min_score')
                ->pluck('label'),
            'availableYears' => $availableYears,
            'summary' => [
                'total' => $matching->count(),
                'avg_health_rate' => $matching->isEmpty() ? null : round($matching->avg('scores.health_rate'), 2),
                'healthy_count' => $matching->where('scores.health_label', 'SIP')->count(),
                'at_risk_count' => $matching->whereIn('scores.health_label', ['KURANG', 'PARAH'])->count(),
            ],
            'filters' => [
                'search' => $request->string('search')->trim()->toString() ?: null,
                'account_id' => $request->integer('account_id') ?: null,
                'health_label' => $healthLabel,
                'month_from' => $monthFrom,
                'month_to' => $monthTo,
            ],
            'defaultAiProvider' => config('services.ai_summary.provider', 'groq'),
        ]);
    }

    public function pdf(Request $request, MetricCalculator $calculator): HttpResponse
    {
        $scoreBuckets = ScoreBucket::all();
        $labelBuckets = LabelBucket::all();
        $formulaWeights = FormulaWeight::all();

        $healthLabel = $request->string('health_label')->trim()->toString() ?: null;
        $monthFrom = $request->string('month_from')->trim()->toString() ?: null;
        $monthTo = $request->string('month_to')->trim()->toString() ?: null;

        $cycles = Cycle::with('account')
            ->when($request->integer('account_id'), fn ($query, $accountId) => $query->where('account_id', $accountId))
            ->when($request->string('search')->trim()->toString(), function ($query, $search) {
                $query->whereHas('account', fn ($accountQuery) => $accountQuery->where('name', 'like', "%{$search}%"));
            })
            ->when($monthFrom, fn ($query, $monthFrom) => $this->applyMonthRangeFilter($query, $monthFrom, $monthTo))
            ->orderByDesc('cycle_start_date')
            ->get()
            ->map(function (Cycle $cycle) use ($calculator, $scoreBuckets, $labelBuckets, $formulaWeights) {
                $scores = $calculator->calculate($cycle, $scoreBuckets, $labelBuckets, $formulaWeights);
                $scores['growth_rate'] = round($scores['growth_rate'], 2);
                $scores['visibility_rate'] = round($scores['visibility_rate'], 2);
                $scores['engagement_score'] = round($scores['engagement_score'], 2);
                $scores['health_rate'] = round($scores['health_rate'], 2);

                return [
                    ...$cycle->toArray(),
                    'cycle_start_date_formatted' => $cycle->cycle_start_date->format('M j, Y'),
                    'cycle_end_date_formatted' => $cycle->cycle_end_date->format('M j, Y'),
                    'scores' => $scores,
                ];
            });

        if ($healthLabel) {
            $cycles = $cycles->filter(fn ($cycle) => $cycle['scores']['health_label'] === $healthLabel)->values();
        }

        $filterParts = [];
        if ($search = $request->string('search')->trim()->toString()) {
            $filterParts[] = "search: \"{$search}\"";
        }
        if ($healthLabel) {
            $filterParts[] = "health: {$healthLabel}";
        }
        if ($monthFrom) {
            $filterParts[] = 'period: '.$this->formatMonthRange($monthFrom, $monthTo);
        }

        $pdf = Pdf::loadView('pdf.cycles-list', [
            'cycles' => $cycles,
            'generatedAt' => now()->format('M j, Y g:i A'),
            'filterSummary' => $filterParts ? implode(', ', $filterParts) : 'none',
            'aiSummary' => $request->string('ai_summary')->trim()->toString() ?: null,
        ])->setPaper('a4', 'landscape');

        return $pdf->download('performance-cycles-'.now()->format('Y-m-d').'.pdf');
    }

    public function pdfSingle(Cycle $cycle, MetricCalculator $calculator): HttpResponse
    {
        $scores = $calculator->calculate(
            $cycle->load('account'),
            ScoreBucket::all(),
            LabelBucket::all(),
            FormulaWeight::all(),
        );

        foreach (['growth_rate', 'reach_rate', 'view_rate', 'er_reach_rate', 'er_follower_rate', 'growth_score', 'reach_score', 'view_score', 'er_reach_score', 'er_follower_score', 'visibility_rate', 'engagement_score', 'health_rate'] as $key) {
            $scores[$key] = round($scores[$key], 2);
        }

        $pdf = Pdf::loadView('pdf.cycle-detail', [
            'cycle' => $cycle,
            'scores' => $scores,
        ])->setPaper('a4', 'portrait');

        $filename = sprintf(
            '%s-%s.pdf',
            Str::slug($cycle->account->name),
            $cycle->cycle_start_date->format('Y-m-d'),
        );

        return $pdf->download($filename);
    }

    public function summarize(Request $request, Cycle $cycle, MetricCalculator $calculator, SummaryProviderResolver $resolver): JsonResponse
    {
        $data = $request->validate([
            'prompt' => ['nullable', 'string', 'max:500'],
            'provider' => ['nullable', 'string', 'in:'.implode(',', SummaryProviderResolver::PROVIDERS)],
        ]);

        $scores = $calculator->calculate(
            $cycle->load('account'),
            ScoreBucket::all(),
            LabelBucket::all(),
            FormulaWeight::all(),
        );

        try {
            $summary = $resolver->resolve($data['provider'] ?? null)->summarize($cycle, $scores, $data['prompt'] ?? null);
        } catch (\Throwable $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        $cycle->forceFill([
            'ai_summary' => $summary,
            'ai_summary_generated_at' => now(),
        ])->save();

        return response()->json([
            'ai_summary' => $summary,
            'ai_summary_generated_at' => $cycle->ai_summary_generated_at->toIso8601String(),
        ]);
    }

    public function neighboring(Request $request, Account $account): JsonResponse
    {
        $data = $request->validate([
            'start_date' => ['nullable', 'date'],
            'end_date' => ['nullable', 'date'],
        ]);

        $response = [];

        if ($startDate = $data['start_date'] ?? null) {
            $response['start_follower'] = $this->resolveInstagramFollowerNear($account, $startDate)
                ?? $this->resolveStartFollower($account, $startDate);
        }

        if ($endDate = $data['end_date'] ?? null) {
            $response['end_follower'] = $this->resolveInstagramFollowerNear($account, $endDate)
                ?? $this->resolveEndFollower($account, $endDate);
        }

        if ($startDate && $endDate) {
            $totals = $this->resolveInstagramTotals($account, $startDate, $endDate);

            if ($totals) {
                $response['reach'] = $totals['reach'];
                $response['views'] = $totals['views'];
                $response['engagement'] = $totals['engagement'];
            }
        }

        return response()->json($response);
    }

    /**
     * Uses the closest captured daily snapshot on or before the given date as a
     * point-in-time follower count — falls back to null so the caller can use
     * the manual-entry neighboring-cycle logic instead.
     */
    private function resolveInstagramFollowerNear(Account $account, string $date): ?int
    {
        if (! $account->ig_business_id) {
            return null;
        }

        $snapshot = $account->instagramDailySnapshots()
            ->whereNotNull('followers_count')
            ->where('captured_date', '<=', $date)
            ->orderByDesc('captured_date')
            ->first();

        return $snapshot?->followers_count;
    }

    /**
     * Sums captured daily snapshots within [start, end] for the period-total fields.
     * Returns null (not zeros) when no snapshots exist in range, so the frontend
     * can distinguish "no Instagram data" from "genuinely zero activity."
     */
    private function resolveInstagramTotals(Account $account, string $startDate, string $endDate): ?array
    {
        if (! $account->ig_business_id) {
            return null;
        }

        $snapshots = $account->instagramDailySnapshots()
            ->whereBetween('captured_date', [$startDate, $endDate])
            ->get();

        if ($snapshots->isEmpty()) {
            return null;
        }

        return [
            'reach' => (int) $snapshots->sum('reach'),
            'views' => (int) $snapshots->sum('views'),
            'engagement' => (int) $snapshots->sum('total_interactions'),
        ];
    }

    private function resolveStartFollower(Account $account, string $startDate): ?int
    {
        $previous = $account->cycles()
            ->where('cycle_end_date', '<=', $startDate)
            ->orderByDesc('cycle_end_date')
            ->first();

        if ($previous) {
            return $previous->end_follower;
        }

        $next = $account->cycles()
            ->where('cycle_start_date', '>', $startDate)
            ->orderBy('cycle_start_date')
            ->first();

        return $next?->start_follower;
    }

    private function resolveEndFollower(Account $account, string $endDate): ?int
    {
        $next = $account->cycles()
            ->where('cycle_start_date', '>=', $endDate)
            ->orderBy('cycle_start_date')
            ->first();

        return $next?->start_follower;
    }

    public function store(Request $request): RedirectResponse
    {
        $data = $this->validated($request);

        Cycle::create($data);

        return back();
    }

    public function update(Request $request, Cycle $cycle): RedirectResponse
    {
        $data = $this->validated($request);

        $cycle->update($data);

        return back();
    }

    public function destroy(Cycle $cycle): RedirectResponse
    {
        $cycle->delete();

        return back();
    }

    private function applyMonthRangeFilter($query, string $monthFrom, ?string $monthTo)
    {
        $start = Carbon::createFromFormat('Y-m', $monthFrom)->startOfMonth();
        $end = $monthTo
            ? Carbon::createFromFormat('Y-m', $monthTo)->endOfMonth()
            : $start->copy()->endOfMonth();

        return $query->whereBetween('cycle_start_date', [$start->toDateString(), $end->toDateString()]);
    }

    private function formatMonthRange(string $monthFrom, ?string $monthTo): string
    {
        $from = Carbon::createFromFormat('Y-m', $monthFrom);

        if (! $monthTo || $monthTo === $monthFrom) {
            return $from->format('F Y');
        }

        $to = Carbon::createFromFormat('Y-m', $monthTo);

        return $from->year === $to->year
            ? $from->format('F').' - '.$to->format('F Y')
            : $from->format('F Y').' - '.$to->format('F Y');
    }

    /**
     * Cycles matching the current request's filters, each paired with its computed scores.
     * Shared by index(), pdf(), and summarizeFiltered() so all three stay in lockstep.
     */
    private function filteredCycles(Request $request, MetricCalculator $calculator): Collection
    {
        $scoreBuckets = ScoreBucket::all();
        $labelBuckets = LabelBucket::all();
        $formulaWeights = FormulaWeight::all();

        $healthLabel = $request->string('health_label')->trim()->toString() ?: null;
        $monthFrom = $request->string('month_from')->trim()->toString() ?: null;
        $monthTo = $request->string('month_to')->trim()->toString() ?: null;

        $cycles = Cycle::with('account')
            ->when($request->integer('account_id'), fn ($query, $accountId) => $query->where('account_id', $accountId))
            ->when($request->string('search')->trim()->toString(), function ($query, $search) {
                $query->whereHas('account', fn ($accountQuery) => $accountQuery->where('name', 'like', "%{$search}%"));
            })
            ->when($monthFrom, fn ($query, $monthFrom) => $this->applyMonthRangeFilter($query, $monthFrom, $monthTo))
            ->orderBy('cycle_start_date')
            ->get()
            ->map(fn (Cycle $cycle) => [
                'cycle' => $cycle,
                'scores' => $calculator->calculate($cycle, $scoreBuckets, $labelBuckets, $formulaWeights),
            ]);

        if ($healthLabel) {
            $cycles = $cycles->filter(fn ($entry) => $entry['scores']['health_label'] === $healthLabel)->values();
        }

        return $cycles;
    }

    private function filterDescription(Request $request): array
    {
        $healthLabel = $request->string('health_label')->trim()->toString() ?: null;
        $monthFrom = $request->string('month_from')->trim()->toString() ?: null;
        $monthTo = $request->string('month_to')->trim()->toString() ?: null;
        $search = $request->string('search')->trim()->toString() ?: null;
        $accountId = $request->integer('account_id') ?: null;

        $parts = [];
        if ($accountId) {
            $account = Account::find($accountId);
            $parts[] = 'account: '.($account->name ?? "#{$accountId}");
        }
        if ($search) {
            $parts[] = "search: \"{$search}\"";
        }
        if ($healthLabel) {
            $parts[] = "health: {$healthLabel}";
        }
        if ($monthFrom) {
            $parts[] = 'period: '.$this->formatMonthRange($monthFrom, $monthTo);
        }

        return [
            'filters' => [
                'search' => $search,
                'account_id' => $accountId,
                'health_label' => $healthLabel,
                'month_from' => $monthFrom,
                'month_to' => $monthTo,
            ],
            'summary' => $parts ? implode(', ', $parts) : 'none (all cycles)',
        ];
    }

    public function summarizeFiltered(Request $request, MetricCalculator $calculator, SummaryProviderResolver $resolver): JsonResponse
    {
        $data = $request->validate([
            'prompt' => ['nullable', 'string', 'max:500'],
            'provider' => ['nullable', 'string', 'in:'.implode(',', SummaryProviderResolver::PROVIDERS)],
            'search' => ['nullable', 'string'],
            'account_id' => ['nullable', 'integer'],
            'health_label' => ['nullable', 'string'],
            'month_from' => ['nullable', 'string'],
            'month_to' => ['nullable', 'string'],
        ]);

        $cycles = $this->filteredCycles($request, $calculator);

        if ($cycles->isEmpty()) {
            return response()->json(['message' => 'No cycles match the current filters.'], 422);
        }

        $filterDescription = $this->filterDescription($request);
        $provider = $data['provider'] ?? config('services.ai_summary.provider', 'groq');

        try {
            $summary = $resolver->resolve($data['provider'] ?? null)
                ->summarizeFiltered($cycles, $filterDescription, $data['prompt'] ?? null);
        } catch (\Throwable $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        $record = FilterSummary::create([
            'filters' => $filterDescription['filters'],
            'provider' => $provider,
            'custom_prompt' => $data['prompt'] ?? null,
            'summary' => $summary,
            'cycle_count' => $cycles->count(),
        ]);

        return response()->json([
            'id' => $record->id,
            'summary' => $summary,
            'cycle_count' => $cycles->count(),
            'filter_summary' => $filterDescription['summary'],
            'generated_at' => $record->created_at->toIso8601String(),
        ]);
    }

    private function validated(Request $request): array
    {
        return $request->validate([
            'account_id' => ['required', 'exists:accounts,id'],
            'cycle_start_date' => ['required', 'date'],
            'cycle_end_date' => ['required', 'date', 'after_or_equal:cycle_start_date'],
            'start_follower' => ['required', 'integer', 'min:0'],
            'end_follower' => ['required', 'integer', 'min:0'],
            'reach' => ['required', 'integer', 'min:0'],
            'views' => ['required', 'integer', 'min:0'],
            'engagement' => ['required', 'integer', 'min:0'],
        ]);
    }
}
