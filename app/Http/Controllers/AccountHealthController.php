<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Concerns\ComputesAccountHealthAndDelta;
use App\Models\Account;
use App\Models\Cycle;
use App\Models\Employee;
use App\Services\MetricCalculator;
use Illuminate\Http\Request;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Collection;
use Inertia\Inertia;
use Inertia\Response;

/**
 * Account Health page — an account's current absolute LEVEL (0-100 health
 * score → SIP/BAGUS/CUKUP/KURANG/PARAH), from its latest cycle. Deliberately
 * kept as its own sidebar item/page, separate from Account Growth (trend vs.
 * the previous cycle), so neither axis is mistaken for the other — an
 * account can legitimately show poor Health but an improving Growth trend.
 * See ComputesAccountHealthAndDelta for the shared computation both pages read.
 */
class AccountHealthController extends Controller
{
    use ComputesAccountHealthAndDelta;

    public function index(Request $request, MetricCalculator $calculator): Response
    {
        $search = $request->string('search')->trim()->toString() ?: null;
        $pmId = $request->integer('project_manager_id') ?: null;
        $page = $request->integer('page', 1);
        $perPage = 15;

        $accounts = Account::withCount('cycles')
            ->when($search, fn ($query, $search) => $query->where('name', 'like', "%{$search}%"))
            ->orderBy('name')
            ->get();

        $pmByAccount = $this->currentPmByAccount($accounts->pluck('id'));
        $pmNames = Employee::whereIn('id', $pmByAccount->filter()->unique()->values())->get(['id', 'name'])->keyBy('id');

        if ($pmId) {
            $accounts = $accounts->filter(fn (Account $account) => $pmByAccount->get($account->id) === $pmId)->values();
        }

        $healthByAccount = $this->latestCycleHealthByAccount($accounts->pluck('id'), $calculator);

        $rows = $accounts->map(fn (Account $account) => $this->presentAccount(
            $account,
            $healthByAccount->get($account->id),
            $pmByAccount->get($account->id),
            $pmNames,
        ))
            ->values();

        $paginator = new LengthAwarePaginator(
            $rows->forPage($page, $perPage)->values(),
            $rows->count(),
            $perPage,
            $page,
            ['path' => $request->url(), 'query' => $request->query()],
        );

        return Inertia::render('AccountHealth/Index', [
            'accounts' => $paginator,
            'summary' => [
                'total' => $accounts->count(),
                'at_risk' => $rows->filter(fn ($row) => in_array($row['health_label'], ['KURANG', 'PARAH'], true))->count(),
            ],
            'filters' => [
                'search' => $search,
                'project_manager_id' => $pmId,
            ],
            'accountDepartmentEmployees' => Employee::whereHas(
                'department',
                fn ($query) => $query->where('name', 'Account')
            )->orderBy('name')->get(['id', 'name']),
            'defaultAiProvider' => config('services.ai_summary.provider', 'groq'),
        ]);
    }

    /**
     * One entry per platform the account has cycles on (Instagram/TikTok),
     * each carrying its own Health score/label — grouped under the account
     * on the frontend instead of collapsing to a single "primary platform"
     * row, since an account's Instagram and TikTok health can differ.
     */
    /**
     * Each account's current PM, derived from its single most-recently-started
     * cycle (same convention as AccountController::currentPmByAccount()).
     *
     * @return Collection<int, ?int> account_id => project_manager_id (or null)
     */
    private function currentPmByAccount(Collection $accountIds): Collection
    {
        if ($accountIds->isEmpty()) {
            return collect();
        }

        return Cycle::whereIn('account_id', $accountIds)
            ->orderByDesc('cycle_start_date')
            ->orderByDesc('id')
            ->get(['account_id', 'project_manager_id'])
            ->unique('account_id')
            ->pluck('project_manager_id', 'account_id');
    }

    private function presentAccount(Account $account, ?array $scores, ?int $pmId = null, ?Collection $pmNames = null): array
    {
        $byPlatform = collect($scores['by_platform'] ?? [])
            ->map(fn (array $platformScores, string $platform) => [
                'platform' => $platform,
                'latest_cycle_label' => $platformScores['latest_cycle_label'] ?? null,
                'health_score' => $platformScores['health_score'] ?? null,
                'health_label' => $platformScores['health_label'] ?? null,
                'visibility_rate' => $platformScores['visibility_rate'] ?? null,
                'engagement_score' => $platformScores['engagement_score'] ?? null,
            ])
            ->values()
            ->all();

        return [
            'id' => $account->id,
            'name' => $account->name,
            'project_manager_id' => $pmId,
            'project_manager' => $pmId && $pmNames ? $pmNames->get($pmId) : null,
            'cycles_count' => $account->cycles_count,
            'platforms' => $byPlatform,
            'health_label' => $scores['health_label'] ?? null,
        ];
    }
}
