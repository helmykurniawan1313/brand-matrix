<?php

namespace App\Http\Controllers;

use App\Models\Account;
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
use Illuminate\Support\Str;
use Inertia\Inertia;
use Inertia\Response;

class AccountController extends Controller
{
    public function index(Request $request): Response
    {
        $search = $request->string('search')->trim()->toString() ?: null;
        $pmId = $request->integer('project_manager_id') ?: null;

        $sortColumns = [
            'name' => 'accounts.name',
            'pm' => 'employees.name',
            'cycles' => 'cycles_count',
        ];
        $sort = $sortColumns[$request->string('sort')->toString()] ?? 'accounts.name';
        $direction = $request->string('direction')->toString() === 'desc' ? 'desc' : 'asc';

        return Inertia::render('Accounts/Index', [
            'accounts' => Account::with('projectManager:id,name')
                ->leftJoin('employees', 'employees.id', '=', 'accounts.project_manager_id')
                ->withCount('cycles')
                ->when($search, fn ($query, $search) => $query->where('accounts.name', 'like', "%{$search}%"))
                ->when($pmId, fn ($query, $pmId) => $query->where('accounts.project_manager_id', $pmId))
                ->orderBy($sort, $direction)
                ->orderBy('accounts.name')
                ->paginate(15)
                ->withQueryString()
                ->through(fn (Account $account) => [
                    'id' => $account->id,
                    'name' => $account->name,
                    'project_manager_id' => $account->project_manager_id,
                    'project_manager' => $account->projectManager,
                    'cycles_count' => $account->cycles_count,
                    'ig_business_id' => $account->ig_business_id,
                    'ig_username' => $account->ig_username,
                    'ig_connected_at' => $account->ig_connected_at?->toIso8601String(),
                ]),
            'filters' => [
                'search' => $search,
                'project_manager_id' => $pmId,
                'sort' => array_search($sort, $sortColumns) ?: 'name',
                'direction' => $direction,
            ],
            'accountDepartmentEmployees' => Employee::whereHas(
                'department',
                fn ($query) => $query->where('name', 'Account')
            )->orderBy('name')->get(['id', 'name']),
            'defaultAiProvider' => config('services.ai_summary.provider', 'groq'),
        ]);
    }

    public function growth(Account $account, MetricCalculator $calculator): JsonResponse
    {
        $scoreBuckets = ScoreBucket::all();
        $labelBuckets = LabelBucket::all();
        $formulaWeights = FormulaWeight::all();

        $cycles = $account->cycles()
            ->orderBy('cycle_start_date')
            ->get()
            ->map(function ($cycle) use ($calculator, $scoreBuckets, $labelBuckets, $formulaWeights) {
                $scores = $calculator->calculate($cycle, $scoreBuckets, $labelBuckets, $formulaWeights);

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
                    'er_reach_rate' => round($scores['er_reach_rate'], 2),
                    'er_follower_rate' => round($scores['er_follower_rate'], 2),
                ];
            });

        return response()->json([
            'account' => ['id' => $account->id, 'name' => $account->name],
            'cycles' => $cycles,
            'ai_summary' => $account->ai_summary,
            'ai_summary_generated_at' => $account->ai_summary_generated_at?->toIso8601String(),
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
        ]);

        $pdf = Pdf::loadView('pdf.account-growth', [
            'account' => $account,
            'charts' => $data['charts'],
            'aiSummary' => $data['ai_summary'] ?? null,
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
