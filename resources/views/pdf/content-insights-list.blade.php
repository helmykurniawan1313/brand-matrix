<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <style>
        body { font-family: 'DejaVu Sans', sans-serif; font-size: 11px; color: #12181a; }
        h1 { font-size: 16px; margin: 0; }
        .meta { color: #566469; font-size: 10px; margin-top: 4px; }
        table { width: 100%; border-collapse: collapse; margin-top: 16px; }
        th { text-align: left; border-bottom: 1.5px solid #12181a; padding: 6px 4px; font-size: 10px; text-transform: uppercase; }
        td { padding: 5px 4px; border-bottom: 1px solid #d8dedc; }
        .num { text-align: right; }
        .header { border-bottom: 2px solid #12181a; padding-bottom: 10px; }
        .empty { text-align: center; color: #8b979b; padding: 24px 0; }
        .pos { color: #146c48; font-weight: bold; }
        .neg { color: #a1282a; font-weight: bold; }
        .na { color: #8b979b; }
    </style>
</head>
<body>
    <div class="header">
        <h1>Brand Matrix — Content Insights</h1>
        <p class="meta">
            Generated {{ $generatedAt }} &middot; Filters: {{ $filterSummary }} &middot;
            {{ count($rows) }} {{ Str::plural('account', count($rows)) }}
        </p>
    </div>

    <table>
        <thead>
            <tr>
                <th>Account</th>
                <th>Platform</th>
                <th class="num">Posts Score</th>
                <th class="num">Reels Score</th>
                <th class="num">Story Score</th>
                <th>Cycle</th>
            </tr>
        </thead>
        <tbody>
            @forelse ($rows as $row)
                @php
                    $scoreFor = fn ($type) => collect($row['weightedScores'] ?? [])->firstWhere('key', $type)['score'] ?? null;
                    $fmt = fn ($v) => $v === null ? null : (($v > 0 ? '+' : '').number_format($v, 1).'%');
                @endphp
                <tr>
                    <td>{{ $row['current']['account_name'] }}</td>
                    <td>{{ $row['current']['platform'] === 'tiktok' ? 'TikTok' : 'Instagram' }}</td>
                    @foreach (['posts', 'reels', 'story'] as $type)
                        @php $score = $scoreFor($type); @endphp
                        <td class="num {{ $score === null ? 'na' : ($score >= 0 ? 'pos' : 'neg') }}">
                            {{ $fmt($score) ?? 'N/A' }}
                        </td>
                    @endforeach
                    <td>{{ $row['current']['cycle_start_date'] }} – {{ $row['current']['cycle_end_date'] }}</td>
                </tr>
            @empty
                <tr>
                    <td colspan="6" class="empty">No accounts match the current filters.</td>
                </tr>
            @endforelse
        </tbody>
    </table>
</body>
</html>
