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
        $data = $this->validated($request);

        $labelBucket->update($data);

        return back();
    }

    public function destroy(LabelBucket $labelBucket): RedirectResponse
    {
        $labelBucket->delete();

        return back();
    }

    private function validated(Request $request): array
    {
        return $request->validate([
            'metric' => ['required', 'string', 'in:'.implode(',', LabelBucket::METRICS)],
            'min_score' => ['nullable', 'numeric'],
            'label' => ['required', 'string', 'max:50'],
        ]);
    }
}
