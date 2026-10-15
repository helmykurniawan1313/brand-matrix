<?php

namespace App\Http\Middleware;

use App\Models\LabelBucket;
use Illuminate\Http\Request;
use Inertia\Middleware;

class HandleInertiaRequests extends Middleware
{
    /**
     * The root template that's loaded on the first page visit.
     *
     * @see https://inertiajs.com/server-side-setup#root-template
     *
     * @var string
     */
    protected $rootView = 'app';

    /**
     * Determines the current asset version.
     *
     * @see https://inertiajs.com/asset-versioning
     */
    public function version(Request $request): ?string
    {
        return parent::version($request);
    }

    /**
     * Define the props that are shared by default.
     *
     * @see https://inertiajs.com/shared-data
     *
     * @return array<string, mixed>
     */
    public function share(Request $request): array
    {
        return [
            ...parent::share($request),
            'auth' => [
                'user' => $request->user()?->only('id', 'name', 'email', 'role', 'page_access'),
            ],
            'flash' => [
                'ig_success' => $request->session()->get('ig_success'),
                'ig_error' => $request->session()->get('ig_error'),
            ],
            // Shared app-wide (not just Settings/Buckets) so StatusBadge.vue can
            // resolve a label's stored color by matching the status text it's
            // given against each LabelBucket's own `label`, instead of a
            // hardcoded text→color map that silently breaks if a user renames
            // or recolors a label in Settings.
            'labelBuckets' => fn () => $request->user()
                ? LabelBucket::select(['id', 'metric', 'min_score', 'label', 'color', 'custom_color_bg', 'custom_color_ink'])->get()
                : [],
        ];
    }
}
