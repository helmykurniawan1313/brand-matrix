<script setup>
import '@lottiefiles/dotlottie-wc';
</script>

<template>
    <div class="flex min-h-screen flex-col items-center justify-center px-6 text-center" style="background-color: var(--bg)">
        <div class="w-full max-w-2xl">
            <dotlottie-wc
                src="https://lottie.host/2c1b805d-d781-4c36-9ba9-23f285ea6e1c/Tomp6wJIFX.lottie"
                :autoplay="true"
                :loop="true"
                style="width: 100%; height: auto; display: block"
            ></dotlottie-wc>
        </div>

        <h1 class="mt-2 font-display text-2xl font-bold tracking-tight" style="color: var(--ink)">
            We'll be right back
        </h1>
        <p class="mt-2 max-w-md text-sm" style="color: var(--ink-muted)">
            Brand Matrix is currently undergoing maintenance. Thanks for your patience — please check back shortly.
        </p>
    </div>
</template>
