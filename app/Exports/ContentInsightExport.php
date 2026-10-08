<?php

namespace App\Exports;

use App\Exports\Concerns\SanitizesForSpreadsheet;
use Illuminate\Support\Collection;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithMapping;
use Maatwebsite\Excel\Concerns\WithStyles;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;

/**
 * Same filtered/sorted rows as the Content Insights page and its PDF export —
 * one row per account, with each content type's Weighted Content Score.
 */
class ContentInsightExport implements FromCollection, WithHeadings, WithMapping, WithStyles
{
    use SanitizesForSpreadsheet;

    public function __construct(private Collection $rows)
    {
    }

    public function collection(): Collection
    {
        return $this->rows;
    }

    private const TREND_LABELS = [
        'up' => 'Trending up',
        'flat' => 'Flat',
        'down' => 'Trending down',
        'no_data' => 'No prior cycle',
    ];

    public function headings(): array
    {
        return [
            'Account',
            'Platform',
            'Project Manager',
            'Trend',
            'Posts Score (%)',
            'Reels Score (%)',
            'Story Score (%)',
            'Cycle',
        ];
    }

    public function map($row): array
    {
        $scoreFor = fn ($type) => collect($row['weightedScores'] ?? [])->firstWhere('key', $type)['score'] ?? null;

        return [
            $this->sanitizeForSpreadsheet($row['current']['account_name']),
            $row['current']['platform'] === 'tiktok' ? 'TikTok' : 'Instagram',
            $this->sanitizeForSpreadsheet($row['current']['project_manager_name'] ?? '—'),
            self::TREND_LABELS[$row['overall_trend']] ?? $row['overall_trend'],
            $scoreFor('posts') !== null ? round($scoreFor('posts'), 1) : 'N/A',
            $scoreFor('reels') !== null ? round($scoreFor('reels'), 1) : 'N/A',
            $scoreFor('story') !== null ? round($scoreFor('story'), 1) : 'N/A',
            $row['current']['cycle_start_date'].' – '.$row['current']['cycle_end_date'],
        ];
    }

    public function styles(Worksheet $sheet): array
    {
        return [
            1 => ['font' => ['bold' => true]],
        ];
    }
}
