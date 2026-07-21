<?php

namespace App\Http\Controllers;

use App\Models\Account;
use App\Models\Employee;
use App\Models\LabelBucket;
use App\Models\Performance;
use App\Services\ScoreBucketResolver;
use App\Services\VideoLinkThumbnailResolver;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\Storage;
use Inertia\Inertia;
use Inertia\Response;

class PerformanceController extends Controller
{
    public function index(Request $request, ScoreBucketResolver $resolver): Response
    {
        $viewsBuckets = LabelBucket::where('metric', LabelBucket::METRIC_VIEWS)->get();
        $followerBuckets = LabelBucket::where('metric', LabelBucket::METRIC_FOLLOWERS)->get();

        $postDateFrom = $request->string('post_date_from')->trim()->toString() ?: null;
        $postDateTo = $request->string('post_date_to')->trim()->toString() ?: null;
        $viewsStatus = $request->string('views_status')->trim()->toString() ?: null;
        $ads = $request->string('ads')->trim()->toString();
        $ads = $ads === '' ? null : $ads === '1';

        $search = $request->string('search')->trim()->toString() ?: null;

        $matching = Performance::with(['client', 'projectManager', 'conceptor', 'editor', 'videoLinks'])
            ->when($search, function ($query, $search) {
                $query->whereHas('client', fn ($clientQuery) => $clientQuery->where('name', 'like', "%{$search}%"));
            })
            ->when($request->integer('client_id'), fn ($query, $clientId) => $query->where('client_id', $clientId))
            ->when($request->integer('project_manager_id'), fn ($query, $id) => $query->where('project_manager_id', $id))
            ->when($request->integer('conceptor_id'), fn ($query, $id) => $query->where('conceptor_id', $id))
            ->when($request->integer('editor_id'), fn ($query, $id) => $query->where('editor_id', $id))
            ->when($ads !== null, fn ($query) => $query->where('ads', $ads))
            ->when($postDateFrom, fn ($query) => $query->whereDate('post_date', '>=', $postDateFrom))
            ->when($postDateTo, fn ($query) => $query->whereDate('post_date', '<=', $postDateTo))
            ->orderByDesc('post_date')
            ->get()
            ->map(function (Performance $performance) use ($resolver, $viewsBuckets, $followerBuckets) {
                $performance->views_status = $performance->total_views_h7 === null
                    ? null
                    : $resolver->resolve($viewsBuckets, (float) $performance->total_views_h7, 'min_score', 'label');

                $performance->follower_category = $performance->followers === null
                    ? null
                    : $resolver->resolve($followerBuckets, (float) $performance->followers, 'min_score', 'label');

                return $performance;
            });

        if ($viewsStatus) {
            $matching = $matching->filter(fn ($performance) => $performance->views_status === $viewsStatus)->values();
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

        return Inertia::render('Performance/Index', [
            'performances' => $paginator,
            'clients' => Account::orderBy('name')->get(['id', 'name']),
            'employees' => Employee::orderBy('name')->get(['id', 'name']),
            'accountDepartmentEmployees' => Employee::whereHas(
                'department',
                fn ($query) => $query->where('name', 'Account')
            )->orderBy('name')->get(['id', 'name']),
            'viewsStatusOptions' => LabelBucket::where('metric', LabelBucket::METRIC_VIEWS)
                ->orderByDesc('min_score')
                ->pluck('label'),
            'filters' => [
                'search' => $search,
                'client_id' => $request->integer('client_id') ?: null,
                'project_manager_id' => $request->integer('project_manager_id') ?: null,
                'conceptor_id' => $request->integer('conceptor_id') ?: null,
                'editor_id' => $request->integer('editor_id') ?: null,
                'ads' => $ads,
                'post_date_from' => $postDateFrom,
                'post_date_to' => $postDateTo,
                'views_status' => $viewsStatus,
            ],
        ]);
    }

    public function store(Request $request, VideoLinkThumbnailResolver $resolver): RedirectResponse
    {
        $data = $this->validated($request);

        $performance = Performance::create($this->tableData($data));

        $this->storeProof($request, $performance);
        $this->syncVideoLinks($performance, $data['video_links'] ?? [], $resolver);

        return back();
    }

    public function update(Request $request, Performance $performance, VideoLinkThumbnailResolver $resolver): RedirectResponse
    {
        $data = $this->validated($request);

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

    private function validated(Request $request): array
    {
        return $request->validate([
            'client_id' => ['required', 'exists:accounts,id'],
            'post_date' => ['required', 'date'],
            'preview_date' => ['nullable', 'date'],
            'ads' => ['required', 'boolean'],
            'project_manager_id' => ['nullable', 'exists:employees,id'],
            'conceptor_id' => ['nullable', 'exists:employees,id'],
            'editor_id' => ['nullable', 'exists:employees,id'],
            'followers' => ['nullable', 'integer', 'min:0'],
            'total_views_h7' => ['nullable', 'integer', 'min:0'],
            'proof' => ['nullable', 'image', 'mimes:jpg,jpeg,png,webp', 'max:700'],
            'video_links' => ['nullable', 'array'],
            'video_links.*' => ['nullable', 'url', 'max:2048'],
        ]);
    }

    private function tableData(array $data): array
    {
        return array_diff_key($data, array_flip(['proof', 'video_links']));
    }

    private function storeProof(Request $request, Performance $performance): void
    {
        if (! $request->hasFile('proof')) {
            return;
        }

        if ($performance->proof_path) {
            Storage::disk('public')->delete($performance->proof_path);
        }

        $path = $request->file('proof')->store('performance-proofs', 'public');
        $performance->update(['proof_path' => $path]);
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
