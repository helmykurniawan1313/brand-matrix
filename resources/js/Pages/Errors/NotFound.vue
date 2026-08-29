<script setup>
import { Link } from '@inertiajs/vue3';
import '@lottiefiles/dotlottie-wc';
</script>

<template>
    <div class="flex min-h-screen flex-col items-center justify-center px-6 text-center" style="background-color: var(--bg)">
        <div class="w-full max-w-2xl">
            <dotlottie-wc
                src="https://lottie.host/97b38f25-dfa4-44b0-a38c-c62312f8acc6/3ClENa0xgt.lottie"
                :autoplay="true"
                :loop="true"
                style="width: 100%; height: auto; display: block"
            ></dotlottie-wc>
        </div>

        <h1 class="mt-2 font-display text-2xl font-bold tracking-tight" style="color: var(--ink)">
            Page not found
        </h1>
        <p class="mt-2 max-w-md text-sm" style="color: var(--ink-muted)">
            The page you're looking for doesn't exist or may have been moved.
        </p>

        <Link
            href="/"
            class="mt-6 inline-flex items-center gap-2 rounded-md px-4 py-2 text-sm font-semibold transition-opacity hover:opacity-90"
            style="background-color: var(--accent); color: var(--accent-ink)"
        >
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4">
                <path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" />
                <path d="M9 22V12h6v10" />
            </svg>
            Back to Home
        </Link>
    </div>
</template>
