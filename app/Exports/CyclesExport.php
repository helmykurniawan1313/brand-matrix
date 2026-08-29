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
 * Same filtered/scored dataset as the Cycles PDF export (pdf.cycles-list) —
 * one row per cycle, same columns, just as a downloadable spreadsheet instead
 * of a formatted document.
 */
class CyclesExport implements FromCollection, WithHeadings, WithMapping, WithStyles
{
    use SanitizesForSpreadsheet;

    public function __construct(private Collection $cycles)
    {
    }

    public function collection(): Collection
    {
        return $this->cycles;
    }

    public function headings(): array
    {
        return [
            'Account',
            'Platform',
            'Period Start',
            'Period End',
            'PM Name',
            'Growth Rate (%)',
            'Visibility',
            'Engagement',
            'Health Rate',
            'Health',
        ];
    }

    public function map($cycle): array
    {
        return [
            $this->sanitizeForSpreadsheet($cycle['account']['name'] ?? '—'),
            $cycle['platform'] === 'tiktok' ? 'TikTok' : 'Instagram',
            $cycle['cycle_start_date_formatted'],
            $cycle['cycle_end_date_formatted'],
            $this->sanitizeForSpreadsheet($cycle['project_manager']['name'] ?? '—'),
            $cycle['scores']['growth_rate'],
            $cycle['scores']['visibility_rate'],
            $cycle['scores']['engagement_score'],
            $cycle['scores']['health_rate'],
            $cycle['scores']['health_label'],
        ];
    }

    public function styles(Worksheet $sheet): array
    {
        return [
            1 => ['font' => ['bold' => true]],
        ];
    }
}
