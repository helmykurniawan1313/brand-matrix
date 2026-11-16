<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title inertia>{{ config('app.name', 'Brand Matrix') }}</title>

    @if ($faviconPath = \App\Models\Setting::get(\App\Models\Setting::FAVICON_PATH))
        <link rel="icon" href="{{ \Illuminate\Support\Facades\Storage::disk('public')->url($faviconPath) }}">
    @endif

    <script>
        (function () {
            var stored = localStorage.getItem('theme');
            var prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
            document.documentElement.dataset.theme = stored ? stored : (prefersDark ? 'dark' : 'light');
        })();
    </script>

    @vite(['resources/css/app.css', 'resources/js/app.js'])
    @inertiaHead
</head>
<body class="antialiased">
    @inertia
</body>
</html>
