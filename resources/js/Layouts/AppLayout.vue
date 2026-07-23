<script setup>
import { Link, usePage } from '@inertiajs/vue3';
import { onMounted, ref, watch } from 'vue';
import ProfileDropdown from '../Components/ProfileDropdown.vue';
import ToastContainer from '../Components/ToastContainer.vue';

const navItems = [
    { label: 'Cycles', href: '/cycles' },
    { label: 'Performance', href: '/performances' },
    { label: 'Accounts', href: '/accounts' },
    { label: 'Employees', href: '/employees' },
    { label: 'Departments', href: '/departments' },
    { label: 'Scoring Buckets', href: '/score-buckets' },
];

const page = usePage();
const currentPath = () => page.url.split('?')[0];
const user = page.props.auth?.user;

const isDark = ref(false);

const applyTheme = (dark) => {
    isDark.value = dark;
    document.documentElement.dataset.theme = dark ? 'dark' : 'light';
    localStorage.setItem('theme', dark ? 'dark' : 'light');
};

const toggleTheme = () => applyTheme(!isDark.value);

onMounted(() => {
    const stored = localStorage.getItem('theme');
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    applyTheme(stored ? stored === 'dark' : prefersDark);
});

const mobileMenuOpen = ref(false);

const toggleMobileMenu = () => {
    mobileMenuOpen.value = !mobileMenuOpen.value;
};

const closeMobileMenu = () => {
    mobileMenuOpen.value = false;
};

// Close the mobile menu automatically whenever navigation actually happens.
watch(() => page.url, closeMobileMenu);
</script>

<template>
    <div class="min-h-screen" style="background-color: var(--bg)">
        <header class="border-b" style="border-color: var(--border); background-color: var(--surface)">
            <div class="mx-auto flex max-w-6xl items-center justify-between px-4 py-4 sm:px-6">
                <div class="flex items-center gap-2.5">
                    <span
                        class="flex h-8 w-8 shrink-0 items-center justify-center rounded-md font-display text-sm font-bold"
                        style="background-color: var(--accent); color: var(--accent-ink)"
                    >
                        BM
                    </span>
                    <span class="font-display text-lg font-bold tracking-tight" style="color: var(--ink)">
                        Brand Matrix
                    </span>
                </div>

                <!-- Desktop nav -->
                <nav class="hidden items-center gap-1 lg:flex">
                    <Link
                        v-for="item in navItems"
                        :key="item.href"
                        :href="item.href"
                        class="rounded-md px-3 py-1.5 text-sm font-medium transition-colors"
                        :style="
                            currentPath().startsWith(item.href)
                                ? `background-color: var(--accent-soft); color: var(--accent)`
                                : `color: var(--ink-muted)`
                        "
                    >
                        {{ item.label }}
                    </Link>

                    <button
                        type="button"
                        class="ml-2 flex h-8 w-8 items-center justify-center rounded-md border transition-colors"
                        style="border-color: var(--border); color: var(--ink-muted)"
                        :aria-label="isDark ? 'Switch to light theme' : 'Switch to dark theme'"
                        @click="toggleTheme"
                    >
                        <svg
                            v-if="isDark"
                            xmlns="http://www.w3.org/2000/svg"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="2"
                            class="h-4 w-4"
                        >
                            <circle cx="12" cy="12" r="4" />
                            <path
                                d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M6.34 17.66l-1.41 1.41M19.07 4.93l-1.41 1.41"
                            />
                        </svg>
                        <svg
                            v-else
                            xmlns="http://www.w3.org/2000/svg"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="2"
                            class="h-4 w-4"
                        >
                            <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z" />
                        </svg>
                    </button>

                    <div v-if="user" class="ml-3 border-l pl-3" style="border-color: var(--border)">
                        <ProfileDropdown :user="user" />
                    </div>
                </nav>

                <!-- Mobile: theme toggle + hamburger -->
                <div class="flex items-center gap-2 lg:hidden">
                    <button
                        type="button"
                        class="flex h-8 w-8 items-center justify-center rounded-md border transition-colors"
                        style="border-color: var(--border); color: var(--ink-muted)"
                        :aria-label="isDark ? 'Switch to light theme' : 'Switch to dark theme'"
                        @click="toggleTheme"
                    >
                        <svg
                            v-if="isDark"
                            xmlns="http://www.w3.org/2000/svg"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="2"
                            class="h-4 w-4"
                        >
                            <circle cx="12" cy="12" r="4" />
                            <path
                                d="M12 2v2M12 20v2M4.93 4.93l1.41 1.41M17.66 17.66l1.41 1.41M2 12h2M20 12h2M6.34 17.66l-1.41 1.41M19.07 4.93l-1.41 1.41"
                            />
                        </svg>
                        <svg
                            v-else
                            xmlns="http://www.w3.org/2000/svg"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="2"
                            class="h-4 w-4"
                        >
                            <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z" />
                        </svg>
                    </button>

                    <button
                        type="button"
                        class="flex h-8 w-8 items-center justify-center rounded-md border transition-colors"
                        style="border-color: var(--border); color: var(--ink-muted)"
                        :aria-label="mobileMenuOpen ? 'Close menu' : 'Open menu'"
                        @click="toggleMobileMenu"
                    >
                        <svg v-if="!mobileMenuOpen" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4.5 w-4.5">
                            <path d="M3 6h18M3 12h18M3 18h18" />
                        </svg>
                        <svg v-else xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4.5 w-4.5">
                            <path d="M18 6 6 18M6 6l12 12" />
                        </svg>
                    </button>
                </div>
            </div>

            <!-- Mobile nav panel -->
            <div
                v-if="mobileMenuOpen"
                class="border-t px-4 py-3 lg:hidden"
                style="border-color: var(--border); background-color: var(--surface)"
            >
                <nav class="flex flex-col gap-1">
                    <Link
                        v-for="item in navItems"
                        :key="item.href"
                        :href="item.href"
                        class="rounded-md px-3 py-2 text-sm font-medium transition-colors"
                        :style="
                            currentPath().startsWith(item.href)
                                ? `background-color: var(--accent-soft); color: var(--accent)`
                                : `color: var(--ink-muted)`
                        "
                        @click="closeMobileMenu"
                    >
                        {{ item.label }}
                    </Link>
                </nav>

                <div v-if="user" class="mt-3 border-t pt-3" style="border-color: var(--border)">
                    <ProfileDropdown :user="user" />
                </div>
            </div>
        </header>

        <main class="mx-auto max-w-6xl px-4 py-10 sm:px-6">
            <slot />
        </main>

        <ToastContainer />
    </div>
</template>
