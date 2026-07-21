<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <style>
        body { font-family: 'DejaVu Sans', sans-serif; font-size: 11px; color: #12181a; }
        h1 { font-size: 18px; margin: 0; }
        .meta { color: #566469; font-size: 11px; margin-top: 4px; }
        .header { border-bottom: 2px solid #12181a; padding-bottom: 10px; margin-bottom: 16px; }
        .section-title { font-size: 10px; text-transform: uppercase; color: #8b979b; margin: 18px 0 6px; letter-spacing: 0.5px; }
        .chart-block { margin-bottom: 18px; page-break-inside: avoid; }
        .chart-block img { width: 100%; max-height: 260px; object-fit: contain; }
        .ai-summary { margin-top: 6px; padding: 12px 14px; background: #f2f6f5; border-left: 3px solid #0f766e; }
        .ai-summary h2 { font-size: 11px; text-transform: uppercase; letter-spacing: 0.04em; color: #0f766e; margin: 0 0 6px; }
        .ai-summary p { margin: 0; line-height: 1.5; }
    </style>
</head>
<body>
    <div class="header">
        <h1>{{ $account->name }} — Growth Report</h1>
        <p class="meta">Generated {{ $generatedAt }}</p>
    </div>

    @if ($aiSummary)
        <div class="ai-summary">
            <h2>AI Summary</h2>
            <p>{{ $aiSummary }}</p>
        </div>
    @endif

    <p class="section-title">Charts</p>
    @foreach ($charts as $chart)
        <div class="chart-block">
            <p style="font-weight: bold; margin: 0 0 4px;">{{ $chart['label'] }}</p>
            <img src="{{ $chart['image'] }}" alt="{{ $chart['label'] }}">
        </div>
    @endforeach
</body>
</html>
