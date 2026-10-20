<?php

namespace App\Http\Controllers;

use App\Models\ContentInsight;
use App\Models\Cycle;
use App\Models\Employee;
use App\Models\FormulaWeight;
use App\Models\LabelBucket;
use App\Models\Performance;
use App\Models\ScoreBucket;
use App\Services\MetricCalculator;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Inertia\Response;

/**
 * Report Prompt Generator — super admin only. Lets the admin pick a scope
 * (month + optional PM) and which data sources to include (Cycles, Reels/
 * Video, Content Insights, Employees), then builds one big text prompt
 * carrying the real numbers in a structured, labeled format — meant to be
 * pasted into an AI chat (Claude/ChatGPT/etc.) to generate a PPTX report
 * with illustrations/graphs, WITHOUT this app making any AI API call itself.
 * Deliberately just text generation: no AI spend, no chart/image rendering
 * here — the admin runs it manually wherever they want.
 */
class ReportPromptController extends Controller
{
    public function index(): Response
    {
        return Inertia::render('ReportPrompt/Index', [
            'accountDepartmentEmployees' => Employee::whereHas(
                'department',
                fn ($query) => $query->where('name', 'Account')
            )->orderBy('name')->get(['id', 'name']),
            // Portable distinct-months list (no DATE_FORMAT — not supported by
            // the SQLite connection the test suite runs on).
            'months' => Cycle::query()
                ->pluck('cycle_start_date')
                ->map(fn ($date) => $date->format('Y-m'))
                ->unique()
                ->sort()
                ->values(),
        ]);
    }

    public function generate(Request $request, MetricCalculator $calculator): JsonResponse
    {
        $data = $request->validate([
            'month_from' => ['required', 'string', 'regex:/^\d{4}-\d{2}$/'],
            'month_to' => ['nullable', 'string', 'regex:/^\d{4}-\d{2}$/'],
            'project_manager_id' => ['nullable', 'integer', 'exists:employees,id'],
            'sources' => ['required', 'array', 'min:1'],
            'sources.*' => ['string', 'in:cycles,performances,content_insights,employees'],
        ]);

        $monthFrom = $data['month_from'];
        $monthTo = $data['month_to'] ?? $monthFrom;
        if ($monthTo < $monthFrom) {
            [$monthFrom, $monthTo] = [$monthTo, $monthFrom];
        }
        $pmId = $data['project_manager_id'] ?? null;
        $sources = $data['sources'];
        $pm = $pmId ? Employee::find($pmId) : null;

        $sections = [];

        if (in_array('cycles', $sources, true)) {
            $sections['cycles'] = $this->cyclesSection($monthFrom, $monthTo, $pmId, $calculator);
        }
        if (in_array('performances', $sources, true)) {
            $sections['performances'] = $this->performancesSection($monthFrom, $monthTo, $pmId);
        }
        if (in_array('content_insights', $sources, true)) {
            $sections['content_insights'] = $this->contentInsightsSection($monthFrom, $monthTo, $pmId);
        }
        if (in_array('employees', $sources, true)) {
            $sections['employees'] = $this->employeesSection($pmId);
        }

        $prompt = $this->buildPrompt($monthFrom, $monthTo, $pm, $sections);

        return response()->json(['prompt' => $prompt]);
    }

    private function cyclesSection(string $monthFrom, string $monthTo, ?int $pmId, MetricCalculator $calculator): array
    {
        $scoreBuckets = ScoreBucket::all();
        $labelBuckets = LabelBucket::all();
        $formulaWeights = FormulaWeight::all();

        $cycles = Cycle::with('account', 'projectManager')
            ->when($pmId, fn ($query) => $query->where('project_manager_id', $pmId))
            ->get()
            ->filter(function (Cycle $cycle) use ($monthFrom, $monthTo) {
                $month = $cycle->cycle_start_date->format('Y-m');

                return $month >= $monthFrom && $month <= $monthTo;
            })
            ->map(function (Cycle $cycle) use ($calculator, $scoreBuckets, $labelBuckets, $formulaWeights) {
                $scores = $calculator->calculate($cycle, $scoreBuckets, $labelBuckets, $formulaWeights);

                return [
                    'account' => $cycle->account->name ?? '—',
                    'platform' => $cycle->platform === 'tiktok' ? 'TikTok' : 'Instagram',
                    'pm' => $cycle->projectManager->name ?? '—',
                    'period' => $cycle->cycle_start_date->format('M j').' – '.$cycle->cycle_end_date->format('M j, Y'),
                    'start_follower' => $cycle->start_follower,
                    'end_follower' => $cycle->end_follower,
                    'reach' => $cycle->reach,
                    'views' => $cycle->views,
                    'engagement' => $cycle->engagement,
                    'reach_views_ads_spend' => (float) $cycle->reach_views_ads_spend,
                    'engagement_ads_spend' => (float) $cycle->engagement_ads_spend,
                    'growth_rate' => round($scores['growth_rate'], 2),
                    'visibility_rate' => round($scores['visibility_rate'], 2),
                    'engagement_score' => round($scores['engagement_score'], 2),
                    'health_rate' => round($scores['health_rate'], 2),
                    'health_label' => $scores['health_label'],
                ];
            })
            ->values();

        return [
            'title' => 'Cycles (Growth / Visibility / Engagement / Health)',
            'rows' => $cycles->all(),
        ];
    }

    private function performancesSection(string $monthFrom, string $monthTo, ?int $pmId): array
    {
        $rows = Performance::with('account', 'projectManager')
            ->when($pmId, fn ($query) => $query->where('project_manager_id', $pmId))
            ->get()
            ->filter(function (Performance $p) use ($monthFrom, $monthTo) {
                if (! $p->post_date) {
                    return false;
                }
                $month = $p->post_date->format('Y-m');

                return $month >= $monthFrom && $month <= $monthTo;
            })
            ->map(fn (Performance $p) => [
                'account' => $p->account->name ?? '—',
                'platform' => $p->platform === 'tiktok' ? 'TikTok' : 'Instagram',
                'pm' => $p->projectManager->name ?? '—',
                'post_date' => $p->post_date?->format('M j, Y'),
                'followers' => $p->followers,
                'total_views_h7' => $p->total_views_h7,
                'ads' => $p->ads ? 'Yes' : 'No',
            ])
            ->values();

        return [
            'title' => 'Reels / Video Performance (Views H+7)',
            'rows' => $rows->all(),
        ];
    }

    private function contentInsightsSection(string $monthFrom, string $monthTo, ?int $pmId): array
    {
        $rows = ContentInsight::with('account', 'cycle.projectManager')
            ->get()
            ->filter(function (ContentInsight $ci) use ($monthFrom, $monthTo) {
                if (! $ci->cycle) {
                    return false;
                }
                $month = $ci->cycle->cycle_start_date->format('Y-m');

                return $month >= $monthFrom && $month <= $monthTo;
            })
            ->when($pmId, fn ($rows) => $rows->filter(fn (ContentInsight $ci) => $ci->cycle->project_manager_id === $pmId))
            ->map(fn (ContentInsight $ci) => [
                'account' => $ci->account->name ?? '—',
                'pm' => $ci->cycle->projectManager->name ?? '—',
                'viewers_posts' => $ci->viewers_posts,
                'viewers_reels' => $ci->viewers_reels,
                'viewers_story' => $ci->viewers_story,
                'interactions_posts' => $ci->interactions_posts,
                'interactions_reels' => $ci->interactions_reels,
                'interactions_story' => $ci->interactions_story,
            ])
            ->values();

        return [
            'title' => 'Content Insights (Viewers & Interactions by content type)',
            'rows' => $rows->all(),
        ];
    }

    private function employeesSection(?int $pmId): array
    {
        $employees = Employee::with('department')
            ->when($pmId, fn ($query) => $query->where('id', $pmId))
            ->orderBy('name')
            ->get()
            ->map(fn (Employee $e) => [
                'name' => $e->name,
                'position' => $e->position,
                'department' => $e->department->name ?? '—',
            ])
            ->values();

        return [
            'title' => 'Employees',
            'rows' => $employees->all(),
        ];
    }

    private function buildPrompt(string $monthFrom, string $monthTo, ?Employee $pm, array $sections): string
    {
        $fromLabel = \Carbon\Carbon::createFromFormat('Y-m', $monthFrom)->format('F Y');
        $periodLabel = $fromLabel;
        if ($monthTo !== $monthFrom) {
            $toLabel = \Carbon\Carbon::createFromFormat('Y-m', $monthTo)->format('F Y');
            $periodLabel = "{$fromLabel} – {$toLabel}";
        }

        $lines = [];
        $lines[] = 'You are building a PowerPoint (PPTX) performance report for a social media management agency, using the raw data below.';
        $lines[] = '';
        $lines[] = 'SCOPE';
        $lines[] = "- Reporting period: {$periodLabel}";
        $lines[] = '- Project Manager: '.($pm ? $pm->name : 'All PMs');
        $lines[] = '';
        $lines[] = 'INSTRUCTIONS';
        $lines[] = '- Create one slide deck summarizing the data below, grouped by account where applicable.';
        $lines[] = '- Use charts/graphs (bar or line) to visualize numeric trends (e.g. Health score, Growth rate, Views) rather than just listing numbers.';
        $lines[] = '- Add a short narrative/insight callout per section — not just raw numbers restated.';
        $lines[] = '- Use a clean, professional slide design with illustrations/icons where it helps communicate the data.';
        $lines[] = '- Health labels (SIP/BAGUS/CUKUP/KURANG/PARAH) are best-to-worst status tiers — color-code them consistently (e.g. green=SIP, red=PARAH) across all slides.';
        $lines[] = '';
        $lines[] = 'DATA';

        foreach ($sections as $key => $section) {
            $lines[] = '';
            $lines[] = '## '.$section['title'];

            if (empty($section['rows'])) {
                $lines[] = '(No data for this scope.)';

                continue;
            }

            $lines[] = json_encode($section['rows'], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
        }

        return implode("\n", $lines);
    }
}
