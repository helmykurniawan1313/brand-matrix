<?php

namespace App\Http\Controllers;

use App\Models\LabelBucket;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;

class LabelBucketController extends Controller
{
    public function store(Request $request): RedirectResponse
    {
        $data = $this->validated($request);

        LabelBucket::create($data);

        return back();
    }

    public function update(Request $request, LabelBucket $labelBucket): RedirectResponse
    {
        $data = $this->validated($request, requireMetric: false);

        $labelBucket->update($data);

        return back();
    }

    public function destroy(LabelBucket $labelBucket): RedirectResponse
    {
        $labelBucket->delete();

        return back();
    }

    private function validated(Request $request, bool $requireMetric = true): array
    {
        return $request->validate([
            'metric' => [$requireMetric ? 'required' : 'sometimes', 'string', 'in:'.implode(',', LabelBucket::METRICS)],
            'min_score' => ['nullable', 'numeric'],
            'label' => ['required', 'string', 'max:50'],
            'color' => ['nullable', 'string', 'max:20'],
            'custom_color_bg' => ['nullable', 'string', 'max:20'],
            'custom_color_ink' => ['nullable', 'string', 'max:20'],
        ]);
    }
}
