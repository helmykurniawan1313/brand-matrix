<?php

namespace App\Http\Controllers;

use App\Models\FormulaWeight;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;

class FormulaWeightController extends Controller
{
    public function update(Request $request, string $aggregate): RedirectResponse
    {
        if (! in_array($aggregate, FormulaWeight::AGGREGATES, true)) {
            abort(404);
        }

        $components = FormulaWeight::COMPONENTS[$aggregate];

        $data = $request->validate([
            'weights' => ['required', 'array'],
            'weights.*' => ['required', 'numeric', 'min:0'],
        ]);

        $weights = collect($data['weights'])->only($components);

        if ($weights->count() !== count($components) || $weights->sum() <= 0) {
            return back()->withErrors([
                'weights' => 'A positive weight is required for every component.',
            ]);
        }

        foreach ($components as $component) {
            FormulaWeight::updateOrCreate(
                ['aggregate' => $aggregate, 'component' => $component],
                ['weight' => $weights->get($component)],
            );
        }

        return back();
    }
}
