<?php

namespace App\Http\Controllers;

use App\Models\Account;
use App\Models\Employee;
use App\Models\FilterSummary;
use App\Models\LabelBucket;
use App\Models\Performance;
use App\Services\PerformanceIgSnapshotService;
use App\Services\ScoreBucketResolver;
use App\Services\SummaryProviderResolver;
use App\Services\VideoLinkThumbnailResolver;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response as HttpResponse;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Inertia\Inertia;
use Inertia\Response;

class PerformanceController extends Controller
{
    public function index(Request $request, ScoreBucketResolver $resolver): Response
    {
        $viewsBuckets = LabelBucket::where('metric', LabelBucket::METRIC_VIEWS)->get();
        $followerBuckets = LabelBucket::where('metric', LabelBucket::METRIC_FOLLOWERS)->get();

        $matching = $this->filteredPerformances($request, $resolver, $viewsBuckets, $followerBuckets);

        // Views labels are user-configurable (LabelBucket), so tier names/order/casing
        // aren't fixed strings like Cycles' health labels — always derive them from the
        // buckets themselves rather than hardcoding label text.
        $viewsLabelOrder = $viewsBuckets->sortByDesc('min_score')->pluck('label')->values();
        $topTierCount = (int) ceil($viewsLabelOrder->count() / 2);
        $topTierLabels = $viewsLabelOrder->take($topTierCount);
        $bottomTierLabels = $viewsLabelOrder->skip($topTierCount);

        $viewsWithValue = $matching->filter(fn ($performance) => $performance->total_views_h7 !== null);

        $summary = [
            'total' => $matching->count(),
            'avg_views' => $viewsWithValue->isEmpty() ? null : round($viewsWithValue->avg('total_views_h7')),
            'top_performing_count' => $matching->whereIn('views_status', $topTierLabels)->count(),
            'at_risk_count' => $matching->whereIn('views_status', $bottomTierLabels)->count(),
        ];

        $statusDistribution = $this->buildStatusDistribution($matching, $viewsLabelOrder);

        $matching = $this->applySort($request, $matching);

        $page = $request->integer('page', 1);
        $perPage = 15;

        $paginator = new LengthAwarePaginator(
            $matching->forPage($page, $perPage)->values(),
            $matching->count(),
            $perPage,
            $page,
            ['path' => $request->url(), 'query' => $request->query()],
        );

        return Inertia::render('Performance/Index', [
            'performances' => $paginator,
            'accounts' => Account::orderBy('name')->get(['id', 'name', 'ig_connected_at']),
            'employees' => Employee::orderBy('name')->get(['id', 'name']),
            'accountDepartmentEmployees' => Employee::whereHas(
                'department',
                fn ($query) => $query->where('name', 'Account')
            )->orderBy('name')->get(['id', 'name']),
            'viewsStatusOptions' => LabelBucket::where('metric', LabelBucket::METRIC_VIEWS)
                ->orderByDesc('min_score')
                ->pluck('label'),
            'noteOptions' => Performance::NOTE_OPTIONS,
            'viewsBuckets' => $viewsBuckets->sortByDesc('min_score')->values(),
            'followerBuckets' => $followerBuckets->sortByDesc('min_score')->values(),
            'summary' => $summary,
            'statusDistribution' => $statusDistribution,
            'filters' => $this->filterDescription($request)['filters'],
            'defaultAiProvider' => config('services.ai_summary.provider', 'groq'),
        ]);
    }

    public function store(Request $request, VideoLinkThumbnailResolver $resolver, PerformanceIgSnapshotService $snapshots): RedirectResponse
    {
        $data = $this->validated($request);

        $performance = Performance::create($this->tableData($data));

        $this->storeProof($request, $performance);
        $this->syncVideoLinks($performance, $data['video_links'] ?? [], $resolver);

        $igMediaId = $data['ig_media_id'] ?? null;

        if ($igMediaId && $performance->account->ig_business_id && $performance->account->ig_access_token) {
            $performance->forceFill([
                'ig_media_id' => $igMediaId,
                'ig_media_product_type' => $data['ig_media_product_type'] ?? null,
            ])->save();

            try {
                $this->syncInstagramLink($performance, $snapshots);
            } catch (\Throwable $e) {
                report($e);
            }
        }

        return back();
    }

    public function update(Request $request, Performance $performance, VideoLinkThumbnailResolver $resolver): RedirectResponse
    {
        $data = $this->validated($request);

        // ig_media_id/ig_media_product_type are intentionally excluded from tableData()
        // here — linking/unlinking only ever happens through the dedicated endpoints,
        // never as a side effect of a generic edit-form save.
        $performance->update($this->tableData($data));

        $this->storeProof($request, $performance);
        $this->syncVideoLinks($performance, $data['video_links'] ?? [], $resolver);

        return back();
    }

    public function destroy(Performance $performance): RedirectResponse
    {
        if ($performance->proof_path) {
            Storage::disk('public')->delete($performance->proof_path);
        }

        $performance->delete();

        return back();
    }

    public function pdf(Performance $performance, ScoreBucketResolver $resolver): HttpResponse
    {
        $performance->load(['account', 'projectManager', 'conceptor', 'igSnapshots' => fn ($query) => $query->limit(1)]);

        $viewsBuckets = LabelBucket::where('metric', LabelBucket::METRIC_VIEWS)->get();
        $followerBuckets = LabelBucket::where('metric', LabelBucket::METRIC_FOLLOWERS)->get();

        $performance = $this->resolveStatuses($performance, $resolver, $viewsBuckets, $followerBuckets);

        $pdf = Pdf::loadView('pdf.performance-detail', [
            'performance' => $performance,
        ])->setPaper('a4', 'portrait');

        $filename = sprintf(
            '%s-%s.pdf',
            Str::slug($performance->account->name),
            $performance->post_date->format('Y-m-d'),
        );

        return $pdf->download($filename);
    }

    public function pdfFiltered(Request $request, ScoreBucketResolver $resolver): HttpResponse
    {
        $viewsBuckets = LabelBucket::where('metric', LabelBucket::METRIC_VIEWS)->get();
        $followerBuckets = LabelBucket::where('metric', LabelBucket::METRIC_FOLLOWERS)->get();

        $performances = $this->filteredPerformances($request, $resolver, $viewsBuckets, $followerBuckets)
            ->map(fn (Performance $performance) => [
                ...$performance->toArray(),
                'post_date_formatted' => $performance->post_date->format('M j, Y'),
            ]);

        $filterDescription = $this->filterDescription($request);

        $pdf = Pdf::loadView('pdf.performances-list', [
            'performances' => $performances,
            'generatedAt' => now()->format('M j, Y g:i A'),
            'filterSummary' => $filterDescription['summary'],
            'aiSummary' => $request->string('ai_summary')->trim()->toString() ?: null,
        ])->setPaper('a4', 'landscape');

        return $pdf->download('performance-'.now()->format('Y-m-d').'.pdf');
    }

    public function summarize(Request $request, Performance $performance, ScoreBucketResolver $resolver, SummaryProviderResolver $providerResolver): JsonResponse
    {
        $data = $request->validate([
            'prompt' => ['nullable', 'string', 'max:500'],
            'provider' => ['nullable', 'string', 'in:'.implode(',', SummaryProviderResolver::PROVIDERS)],
        ]);

        $performance->load(['account', 'igSnapshots' => fn ($query) => $query->limit(1)]);

        $viewsBuckets = LabelBucket::where('metric', LabelBucket::METRIC_VIEWS)->get();
        $followerBuckets = LabelBucket::where('metric', LabelBucket::METRIC_FOLLOWERS)->get();

        $performance = $this->resolveStatuses($performance, $resolver, $viewsBuckets, $followerBuckets);

        try {
            $summary = $providerResolver->resolve($data['provider'] ?? null)
                ->summarizePerformance($performance, $data['prompt'] ?? null);
        } catch (\Throwable $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        // resolveStatuses() decorates $performance with non-column attributes
        // (ig_snapshot, views_status, follower_category) for prompt-building —
        // save through a fresh instance so those don't get sent to the DB.
        $generatedAt = now();

        Performance::whereKey($performance->id)->update([
            'ai_summary' => $summary,
            'ai_summary_generated_at' => $generatedAt,
        ]);

        return response()->json([
            'ai_summary' => $summary,
            'ai_summary_generated_at' => $generatedAt->toIso8601String(),
        ]);
    }

    public function summarizeFiltered(Request $request, ScoreBucketResolver $resolver, SummaryProviderResolver $providerResolver): JsonResponse
    {
        $data = $request->validate([
            'prompt' => ['nullable', 'string', 'max:500'],
            'provider' => ['nullable', 'string', 'in:'.implode(',', SummaryProviderResolver::PROVIDERS)],
            'search' => ['nullable', 'string'],
            'account_id' => ['nullable', 'integer'],
            'project_manager_id' => ['nullable', 'integer'],
            'conceptor_id' => ['nullable', 'integer'],
            'views_status' => ['nullable', 'string'],
            'ads' => ['nullable', 'string'],
            'post_date_from' => ['nullable', 'string'],
            'post_date_to' => ['nullable', 'string'],
            'views_h7' => ['nullable', 'string'],
            'platform' => ['nullable', 'string', 'in:instagram,tiktok'],
            'sort' => ['nullable', 'string'],
            'direction' => ['nullable', 'string'],
        ]);

        $viewsBuckets = LabelBucket::where('metric', LabelBucket::METRIC_VIEWS)->get();
        $followerBuckets = LabelBucket::where('metric', LabelBucket::METRIC_FOLLOWERS)->get();

        $performances = $this->filteredPerformances($request, $resolver, $viewsBuckets, $followerBuckets);

        if ($performances->isEmpty()) {
            return response()->json(['message' => 'No performance records match the current filters.'], 422);
        }

        $filterDescription = $this->filterDescription($request);
        $provider = $data['provider'] ?? config('services.ai_summary.provider', 'groq');

        try {
            $summary = $providerResolver->resolve($data['provider'] ?? null)
                ->summarizeFilteredPerformances($performances, $filterDescription, $data['prompt'] ?? null);
        } catch (\Throwable $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        $record = FilterSummary::create([
            'filters' => $filterDescription['filters'],
            'provider' => $provider,
            'custom_prompt' => $data['prompt'] ?? null,
            'summary' => $summary,
            'cycle_count' => $performances->count(),
        ]);

        return response()->json([
            'id' => $record->id,
            'summary' => $summary,
            'performance_count' => $performances->count(),
            'filter_summary' => $filterDescription['summary'],
            'generated_at' => $record->created_at->toIso8601String(),
        ]);
    }

    public function linkInstagram(Request $request, Performance $performance, PerformanceIgSnapshotService $snapshots): JsonResponse
    {
        $data = $request->validate([
            'ig_media_id' => ['required', 'string'],
            'ig_media_product_type' => ['required', 'string'],
        ]);

        if (! $performance->account->ig_business_id || ! $performance->account->ig_access_token) {
            return response()->json(['message' => 'This account is not connected to Instagram yet.'], 422);
        }

        $performance->forceFill($data)->save();

        try {
            $performance = $this->syncInstagramLink($performance, $snapshots);
        } catch (\Throwable $e) {
            return response()->json(['message' => 'Instagram API error: '.$e->getMessage()], 422);
        }

        return response()->json([
            'message' => 'Linked to Instagram post.',
            'followers' => $performance->followers,
            'followers_captured_date' => $performance->followers_captured_date?->toDateString(),
        ]);
    }

    /**
     * Fetches the initial insights snapshot and resolves Followers for a
     * newly linked Performance — shared by store() (link-on-create) and
     * linkInstagram() (link-after-save) so both paths stay in sync.
     */
    private function syncInstagramLink(Performance $performance, PerformanceIgSnapshotService $snapshots): Performance
    {
        $performance = $performance->fresh('account');
        $snapshots->capture($performance);
        $snapshots->fillFollowersForPostDate($performance);

        return $performance->fresh();
    }

    public function unlinkInstagram(Performance $performance): JsonResponse
    {
        $performance->forceFill([
            'ig_media_id' => null,
            'ig_media_product_type' => null,
        ])->save();

        $performance->igSnapshots()->delete();

        return response()->json(['message' => 'Unlinked from Instagram post.']);
    }

    /**
     * Performance records matching the current request's filters, each with
     * views_status/follower_category resolved. Shared by index(), pdfFiltered(),
     * and summarizeFiltered() so all three stay in lockstep.
     */
    private function filteredPerformances(Request $request, ScoreBucketResolver $resolver, Collection $viewsBuckets, Collection $followerBuckets): Collection
    {
        $postDateFrom = $request->string('post_date_from')->trim()->toString() ?: null;
        $postDateTo = $request->string('post_date_to')->trim()->toString() ?: null;
        $viewsStatuses = $this->parseListFilter($request, 'views_status');
        $ads = $this->parseAdsFilter($request);
        $search = $request->string('search')->trim()->toString() ?: null;
        $viewsH7 = $this->parseNullableFilter($request, 'views_h7');

        $matching = Performance::with(['account', 'projectManager', 'conceptor', 'editor', 'videoLinks', 'igSnapshots' => fn ($query) => $query->limit(1)])
            ->when($search, function ($query, $search) {
                $query->whereHas('account', fn ($accountQuery) => $accountQuery->where('name', 'like', "%{$search}%"));
            })
            ->when($request->integer('account_id'), fn ($query, $accountId) => $query->where('account_id', $accountId))
            ->when($request->integer('project_manager_id'), fn ($query, $id) => $query->where('project_manager_id', $id))
            ->when($request->integer('conceptor_id'), fn ($query, $id) => $query->where('conceptor_id', $id))
            ->when($request->integer('editor_id'), fn ($query, $id) => $query->where('editor_id', $id))
            ->when($request->string('platform')->trim()->toString(), fn ($query, $platform) => $query->where('platform', $platform))
            ->when($ads === 'null', fn ($query) => $query->whereNull('ads'))
            ->when(is_bool($ads), fn ($query) => $query->where('ads', $ads))
            ->when($postDateFrom, fn ($query) => $query->whereDate('post_date', '>=', $postDateFrom))
            ->when($postDateTo, fn ($query) => $query->whereDate('post_date', '<=', $postDateTo))
            ->orderByDesc('post_date')
            ->get()
            ->map(fn (Performance $performance) => $this->resolveStatuses($performance, $resolver, $viewsBuckets, $followerBuckets));

        if ($viewsStatuses) {
            $matching = $matching->filter(fn ($performance) => in_array($performance->views_status, $viewsStatuses, true))->values();
        }

        // total_views_h7 can be overlaid live from an Instagram snapshot in
        // resolveStatuses(), so this null/not-null filter must run after that
        // overlay rather than as a DB WHERE clause on the raw column.
        if ($viewsH7 === 'null') {
            $matching = $matching->filter(fn ($performance) => $performance->total_views_h7 === null)->values();
        } elseif ($viewsH7 === 'not_null') {
            $matching = $matching->filter(fn ($performance) => $performance->total_views_h7 !== null)->values();
        }

        return $matching;
    }

    private function filterDescription(Request $request): array
    {
        $postDateFrom = $request->string('post_date_from')->trim()->toString() ?: null;
        $postDateTo = $request->string('post_date_to')->trim()->toString() ?: null;
        $viewsStatuses = $this->parseListFilter($request, 'views_status');
        $ads = $this->parseAdsFilter($request);
        $search = $request->string('search')->trim()->toString() ?: null;
        $accountId = $request->integer('account_id') ?: null;
        $viewsH7 = $this->parseNullableFilter($request, 'views_h7');
        $platform = $request->string('platform')->trim()->toString() ?: null;

        $parts = [];
        if ($accountId) {
            $account = Account::find($accountId);
            $parts[] = 'account: '.($account->name ?? "#{$accountId}");
        }
        if ($search) {
            $parts[] = "search: \"{$search}\"";
        }
        if ($platform) {
            $parts[] = 'platform: '.ucfirst($platform);
        }
        if ($viewsStatuses) {
            $parts[] = 'status: '.implode(', ', $viewsStatuses);
        }
        if ($ads !== null) {
            $parts[] = 'ads: '.($ads === 'null' ? '-' : ($ads ? 'Yes' : 'No'));
        }
        if ($postDateFrom) {
            $parts[] = 'post date: '.$postDateFrom.($postDateTo ? " to {$postDateTo}" : '+');
        }
        if ($viewsH7) {
            $parts[] = 'views H+7: '.($viewsH7 === 'null' ? 'empty' : 'not empty');
        }

        return [
            'filters' => [
                'search' => $search,
                'account_id' => $accountId,
                'project_manager_id' => $request->integer('project_manager_id') ?: null,
                'conceptor_id' => $request->integer('conceptor_id') ?: null,
                'editor_id' => $request->integer('editor_id') ?: null,
                'platform' => $platform,
                'ads' => $ads,
                'post_date_from' => $postDateFrom,
                'post_date_to' => $postDateTo,
                'views_status' => $viewsStatuses ? implode(',', $viewsStatuses) : null,
                'views_h7' => $viewsH7,
                'sort' => $request->string('sort')->toString() ?: null,
                'direction' => $request->string('direction')->toString() ?: null,
            ],
            'summary' => $parts ? implode(', ', $parts) : 'none (all records)',
        ];
    }

    /**
     * ads is tri-state (true/false/null — "-", meaning unknown/not recorded),
     * so the filter needs a third wire value beyond '1'/'0': 'null' explicitly
     * requests rows where ads IS NULL. Empty/absent means "no filter" (mixed).
     * Returns true|false|'null'|null.
     */
    private function parseAdsFilter(Request $request): bool|string|null
    {
        $raw = $request->string('ads')->trim()->toString();

        return match ($raw) {
            '' => null,
            'null' => 'null',
            '1' => true,
            '0' => false,
            default => null,
        };
    }

    /**
     * Generic tri-state "is this field null or not" filter, used for
     * total_views_h7. Returns 'null'|'not_null'|null (no filter).
     */
    private function parseNullableFilter(Request $request, string $key): ?string
    {
        $raw = $request->string($key)->trim()->toString();

        return match ($raw) {
            'null' => 'null',
            'not_null' => 'not_null',
            default => null,
        };
    }

    /**
     * Comma-separated multi-select filter (e.g. views_status=SIP,BAGUS).
     * Returns null when no values were given (no filter applied).
     */
    private function parseListFilter(Request $request, string $key): ?array
    {
        $raw = $request->string($key)->trim()->toString();

        if ($raw === '') {
            return null;
        }

        $values = array_values(array_filter(array_map('trim', explode(',', $raw)), fn ($v) => $v !== ''));

        return $values ?: null;
    }

    /**
     * Sorts the already-materialized, status-resolved Collection by a
     * user-clicked table header. Sorting happens in PHP (not SQL) because
     * views_status/follower_category/total_views_h7 (IG-overlay) are only
     * known after resolveStatuses() runs.
     */
    private function applySort(Request $request, Collection $matching): Collection
    {
        $sortColumns = [
            'account' => fn ($performance) => $performance->account->name ?? '',
            'post_date' => fn ($performance) => $performance->post_date,
            'views_h7' => fn ($performance) => $performance->total_views_h7,
            'followers' => fn ($performance) => $performance->followers,
            'views_status' => fn ($performance) => $performance->views_status ?? '',
        ];

        $sort = $request->string('sort')->toString();

        if (! isset($sortColumns[$sort])) {
            return $matching;
        }

        $direction = $request->string('direction')->toString() === 'desc' ? 'desc' : 'asc';
        $sorted = $matching->sortBy($sortColumns[$sort], SORT_REGULAR, $direction === 'desc');

        return $sorted->values();
    }

    /**
     * Overlays live snapshot data onto total_views_h7 and resolves
     * views_status/follower_category — shared by index()'s listing map,
     * pdf(), and summarize() so all three stay in lockstep.
     */
    private function resolveStatuses(Performance $performance, ScoreBucketResolver $resolver, Collection $viewsBuckets, Collection $followerBuckets): Performance
    {
        $snapshot = $performance->igSnapshots->first();

        // For IG-linked posts, views/followers are overlaid live from the latest
        // snapshot rather than the manually-typed columns — same field names,
        // source just switches based on whether ig_media_id is set.
        if ($snapshot) {
            $performance->total_views_h7 = $snapshot->views ?? $snapshot->total_interactions;
        }

        $performance->ig_snapshot = $snapshot;

        $performance->views_status = $performance->total_views_h7 === null
            ? null
            : $resolver->resolve($viewsBuckets, (float) $performance->total_views_h7, 'min_score', 'label');

        $performance->follower_category = $performance->followers === null
            ? null
            : $resolver->resolve($followerBuckets, (float) $performance->followers, 'min_score', 'label');

        return $performance;
    }

    /**
     * Counts how many matching records resolved to each Views H+7 status
     * label — mirrors CycleController::buildScoreDistribution() but keyed
     * on the single views_status metric Performance actually has. Tiers are
     * passed in (highest min_score first) rather than hardcoded, since
     * Views labels are user-configurable text, not fixed strings.
     */
    private function buildStatusDistribution(Collection $matching, Collection $labelOrder): array
    {
        $labelOrder = $labelOrder->reverse()->values(); // chart reads low-to-high, left to right
        $counts = array_fill_keys($labelOrder->all(), 0);

        foreach ($matching as $performance) {
            $status = $performance->views_status;

            if ($status !== null && array_key_exists($status, $counts)) {
                $counts[$status]++;
            }
        }

        return [
            'tiers' => $labelOrder,
            'counts' => $counts,
        ];
    }

    private function validated(Request $request): array
    {
        return $request->validate([
            'account_id' => ['required', 'exists:accounts,id'],
            'platform' => ['nullable', 'string', 'in:instagram,tiktok'],
            'post_date' => ['required', 'date'],
            'preview_date' => ['nullable', 'date'],
            'ads' => ['nullable', 'boolean'],
            'notes' => ['nullable', 'array'],
            'notes.*' => ['string', 'in:'.implode(',', Performance::NOTE_OPTIONS)],
            'project_manager_id' => ['nullable', 'exists:employees,id'],
            'conceptor_id' => ['nullable', 'exists:employees,id'],
            'editor_id' => ['nullable', 'exists:employees,id'],
            'followers' => ['nullable', 'integer', 'min:0'],
            'total_views_h7' => ['nullable', 'integer', 'min:0'],
            'proof' => ['nullable', 'image', 'mimes:jpg,jpeg,png,webp', 'max:700'],
            'video_links' => ['nullable', 'array'],
            'video_links.*' => ['nullable', 'url', 'max:2048'],
            'ig_media_id' => ['nullable', 'string'],
            'ig_media_product_type' => ['nullable', 'string'],
        ]);
    }

    private function tableData(array $data): array
    {
        return array_diff_key($data, array_flip(['proof', 'video_links', 'ig_media_id', 'ig_media_product_type']));
    }

    private function storeProof(Request $request, Performance $performance): void
    {
        if ($request->hasFile('proof')) {
            if ($performance->proof_path) {
                Storage::disk('public')->delete($performance->proof_path);
            }

            $path = $request->file('proof')->store('performance-proofs', 'public');
            $performance->update(['proof_path' => $path]);

            return;
        }

        if ($request->boolean('remove_proof') && $performance->proof_path) {
            Storage::disk('public')->delete($performance->proof_path);
            $performance->update(['proof_path' => null]);
        }
    }

    private function syncVideoLinks(Performance $performance, array $urls, VideoLinkThumbnailResolver $resolver): void
    {
        $urls = array_values(array_filter($urls, fn ($url) => filled($url)));

        $performance->videoLinks()->delete();

        foreach ($urls as $index => $url) {
            $platform = $resolver->detectPlatform($url);

            $performance->videoLinks()->create([
                'url' => $url,
                'platform' => $platform,
                'thumbnail_url' => $resolver->resolveThumbnail($url, $platform),
                'embed_html' => $resolver->resolveEmbedHtml($url, $platform),
                'order' => $index,
            ]);
        }
    }
}
