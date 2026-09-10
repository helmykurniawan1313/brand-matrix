<?php

namespace App\Exports;

use App\Exports\Concerns\SanitizesForSpreadsheet;
use Illuminate\Support\Collection;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithStyles;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;

/**
 * Best PM & Best Conceptor leaderboards on one sheet — the same data the
 * ranking modal shows, respecting its platform + month-range filters.
 * PM rows first, a blank spacer, then a "CONCEPTORS" header row, then
 * Conceptor rows. Each person ranked best-to-worst by median views per post.
 */
class PmConceptorRankingExport implements FromCollection, WithHeadings, WithStyles
{
    use SanitizesForSpreadsheet;

    public function __construct(
        private Collection $projectManagers,
        private Collection $conceptors,
    ) {
    }

    public function headings(): array
    {
        return ['Rank', 'Name', 'Median Views', 'Total Views', 'Posts'];
    }

    public function collection(): Collection
    {
        $rows = collect();

        $rows->push(['PROJECT MANAGERS', '', '', '', '']);
        $this->appendPeople($rows, $this->projectManagers);

        $rows->push(['', '', '', '', '']);
        $rows->push(['CONCEPTORS', '', '', '', '']);
        $this->appendPeople($rows, $this->conceptors);

        return $rows;
    }

    private function appendPeople(Collection $rows, Collection $people): void
    {
        if ($people->isEmpty()) {
            $rows->push(['—', 'No one with recorded views for these filters', '', '', '']);

            return;
        }

        foreach ($people->values() as $index => $person) {
            $rows->push([
                $index + 1,
                $this->sanitizeForSpreadsheet($person['employee_name']),
                $person['avg_views'],
                $person['total_views'],
                $person['post_count'],
            ]);
        }
    }

    public function styles(Worksheet $sheet): array
    {
        // Row 1 is the column header. The two section-title rows ("PROJECT
        // MANAGERS" / "CONCEPTORS") are found and bolded by value rather than a
        // fixed index, since the PM list length isn't known up front.
        $styles = [1 => ['font' => ['bold' => true]]];

        foreach ($sheet->getRowIterator() as $row) {
            $cell = $sheet->getCell('A'.$row->getRowIndex())->getValue();
            if (in_array($cell, ['PROJECT MANAGERS', 'CONCEPTORS'], true)) {
                $styles[$row->getRowIndex()] = ['font' => ['bold' => true]];
            }
        }

        return $styles;
    }
}
