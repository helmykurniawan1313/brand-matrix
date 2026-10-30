<?php

namespace App\Http\Controllers;

use App\Models\Account;
use App\Models\WeeklyReport;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class WeeklyReportController extends Controller
{
    public function index(Request $request): Response
    {
        $reports = WeeklyReport::with('account')
            ->when($request->integer('account_id'), fn ($query, $accountId) => $query->where('account_id', $accountId))
            ->when($request->string('platform')->trim()->toString(), fn ($query, $platform) => $query->where('platform', $platform))
            ->when($request->string('search')->trim()->toString(), function ($query, $search) {
                $query->whereHas('account', fn ($accountQuery) => $accountQuery->where('name', 'like', "%{$search}%"));
            })
            ->orderByDesc('week_start_date')
            ->paginate(15)
            ->withQueryString();

        return Inertia::render('WeeklyReports/Index', [
            'reports' => $reports,
            'accounts' => Account::orderBy('name')->get(['id', 'name']),
            'filters' => [
                'search' => $request->string('search')->trim()->toString() ?: null,
                'account_id' => $request->integer('account_id') ?: null,
                'platform' => $request->string('platform')->trim()->toString() ?: null,
            ],
        ]);
    }

    /**
     * Auto-fills a new weekly report's numbers from instagram_daily_snapshots
     * for the given Monday–Sunday range — same role as CycleController::neighboring,
     * but summed over a fixed week instead of resolved from neighboring cycles.
     */
    public function neighboring(Request $request, Account $account): JsonResponse
    {
        $data = $request->validate([
            'week_start_date' => ['required', 'date'],
            'week_end_date' => ['required', 'date', 'after_or_equal:week_start_date'],
            'platform' => ['nullable', 'string', 'in:instagram,tiktok'],
        ]);

        if (($data['platform'] ?? 'instagram') !== 'instagram') {
            return response()->json([]);
        }

        $snapshots = $account->instagramDailySnapshots()
            ->whereBetween('captured_date', [$data['week_start_date'], $data['week_end_date']])
            ->get();

        if ($snapshots->isEmpty()) {
            return response()->json([]);
        }

        $lastSnapshot = $snapshots->sortByDesc('captured_date')->first(fn ($snapshot) => $snapshot->followers_count !== null);

        return response()->json([
            'follower_count' => $lastSnapshot?->followers_count,
            'reach' => (int) $snapshots->sum('reach'),
            'views' => (int) $snapshots->sum('views'),
            'profile_visits' => (int) $snapshots->sum('profile_visits'),
            'link_clicks' => (int) $snapshots->sum('link_clicks'),
            'engagement' => (int) $snapshots->sum('total_interactions'),
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        WeeklyReport::create($this->validated($request));

        return back();
    }

    public function update(Request $request, WeeklyReport $weeklyReport): RedirectResponse
    {
        $weeklyReport->update($this->validated($request));

        return back();
    }

    public function destroy(WeeklyReport $weeklyReport): RedirectResponse
    {
        $weeklyReport->delete();

        return back();
    }

    private function validated(Request $request): array
    {
        $data = $request->validate([
            'account_id' => ['required', 'exists:accounts,id'],
            'platform' => ['required', 'string', 'in:instagram,tiktok'],
            'week_start_date' => ['required', 'date'],
            'follower_count' => ['nullable', 'integer', 'min:0'],
            'reach' => ['nullable', 'integer', 'min:0'],
            'views' => ['nullable', 'integer', 'min:0'],
            'profile_visits' => ['nullable', 'integer', 'min:0'],
            'link_clicks' => ['nullable', 'integer', 'min:0'],
            'engagement' => ['nullable', 'integer'],
        ]);

        // week_end_date is always derived (Monday + 6 days) rather than taken
        // from the client, so a week can never be anything other than a full
        // Monday–Sunday span.
        $data['week_end_date'] = Carbon::parse($data['week_start_date'])->addDays(6)->toDateString();

        return $data;
    }
}
