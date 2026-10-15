<?php

namespace App\Http\Controllers;

use App\Models\FormulaWeight;
use App\Models\LabelBucket;
use App\Models\ScoreBucket;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

class ScoreBucketController extends Controller
{
    public function index(): Response
    {
        return Inertia::render('Settings/Buckets', [
            'scoreBuckets' => ScoreBucket::orderBy('metric')->orderByDesc('min_rate')->get(),
            'labelBuckets' => LabelBucket::orderBy('metric')->orderByDesc('min_score')->get(),
            'scoreMetrics' => ScoreBucket::METRICS,
            'labelMetrics' => LabelBucket::METRICS,
            'formulaWeights' => FormulaWeight::all(),
            'formulaComponents' => FormulaWeight::COMPONENTS,
        ]);
    }

    public function store(Request $request): RedirectResponse
    {
        $data = $this->validated($request);

        ScoreBucket::create($data);

        return back();
    }

    public function update(Request $request, ScoreBucket $scoreBucket): RedirectResponse
    {
        $data = $this->validated($request, requireMetric: false);

        $scoreBucket->update($data);

        return back();
    }

    public function destroy(ScoreBucket $scoreBucket): RedirectResponse
    {
        $scoreBucket->delete();

        return back();
    }

    private function validated(Request $request, bool $requireMetric = true): array
    {
        return $request->validate([
            'metric' => [$requireMetric ? 'required' : 'sometimes', 'string', 'in:'.implode(',', ScoreBucket::METRICS)],
            'min_rate' => ['nullable', 'numeric'],
            'score' => ['required', 'numeric', 'min:0'],
            'color' => ['nullable', 'string', 'max:20'],
            'custom_color_bg' => ['nullable', 'string', 'max:20'],
            'custom_color_ink' => ['nullable', 'string', 'max:20'],
        ]);
    }
}
