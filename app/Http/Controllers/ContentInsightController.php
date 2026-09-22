<?php

namespace App\Http\Controllers;

use App\Models\Account;
use App\Models\ContentInsight;
use App\Models\Cycle;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Inertia\Inertia;
use Inertia\Response;

class ContentInsightController extends Controller
{
    public function index(Request $request): Response
    {
        // The page renders one row per account (its latest cycle vs. the one
        // before it, or — with a From→To month picked — that account's cycle
        // in each of the two picked months), all computed client-side from
        // this one lightweight set. end_follower rides along so the account's
        // own follower Growth % can be derived too, for the Weighted Content
        // Score (Views/Interactions/Growth blend).
        $all = ContentInsight::with([
            'account:id,name',
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

        return Inertia::render('ContentInsights/Index', [
            'allInsights' => $all->values(),
            'months' => $all->pluck('month')->filter()->unique()->sort()->values(),
            'accounts' => Account::orderBy('name')->get(['id', 'name']),
        ]);
    }

    /**
     * Cycles for a given account, for the dependent "cycle" select box.
     */
    public function cycles(Account $account): JsonResponse
    {
        return response()->json(
            $account->cycles()
                ->orderByDesc('cycle_start_date')
                ->get(['id', 'cycle_start_date', 'cycle_end_date', 'platform'])
                ->map(fn (Cycle $cycle) => [
                    'id' => $cycle->id,
                    'platform' => $cycle->platform,
                    'cycle_start_date' => $cycle->cycle_start_date->toDateString(),
                    'cycle_end_date' => $cycle->cycle_end_date->toDateString(),
                    'label' => $this->cycleLabel($cycle),
                ])
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
