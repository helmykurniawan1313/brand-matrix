<script setup>
import { Link, usePage } from '@inertiajs/vue3';
import { computed, onMounted, ref, watch } from 'vue';
import ProfileDropdown from '../Components/ProfileDropdown.vue';
import ToastContainer from '../Components/ToastContainer.vue';
import { useAuth } from '../composables/useAuth';

const { isSuperAdmin } = useAuth();

// path data for a 24x24 viewBox, stroke-based icon (matches the theme-toggle/menu icons already in this layout)
const icons = {
    dashboard: 'M3 13h8V3H3v10zM13 21h8V11h-8v10zM13 3v6h8V3h-8zM3 21h8v-6H3v6z',
    cycles: 'M17 2.1l4 4-4 4M3 12.2v-2a4 4 0 0 1 4-4h14M7 21.9l-4-4 4-4M21 11.8v2a4 4 0 0 1-4 4H3',
    performance: 'M3 3v18h18M7 15l4-4 4 4 5-6',
    accounts: 'M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2M9 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8zM23 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75',
    employees: 'M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2M9 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8zM22 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75',
    departments: 'M3 21h18M5 21V7l7-4 7 4v14M9 9h1M9 13h1M14 9h1M14 13h1M9 21v-4h6v4',
    buckets: 'M4 4h16l-6.5 8v6l-3 2v-8L4 4z',
    viewsTrend: 'M22 12h-4l-3 9L9 3l-3 9H2',
    users: 'M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2M12 11a4 4 0 1 0 0-8 4 4 0 0 0 0 8z',
    siteSettings: 'M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6zM19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z',
    instagram: 'M17 2H7a5 5 0 0 0-5 5v10a5 5 0 0 0 5 5h10a5 5 0 0 0 5-5V7a5 5 0 0 0-5-5zM12 8a4 4 0 1 0 0 8 4 4 0 0 0 0-8zM17.5 6.5h.01',
    tiktok: 'M9 12a4 4 0 1 0 4 4V4a5 5 0 0 0 5 5',
};

const baseNavItems = [
    { label: 'Dashboard', href: '/dashboard', icon: icons.dashboard },
    {
        label: 'Cycles',
        href: '/cycles',
        icon: icons.cycles,
        group: true,
        children: [
            { label: 'Instagram', href: '/cycles?platform=instagram', icon: icons.instagram },
            { label: 'TikTok', href: '/cycles?platform=tiktok', icon: icons.tiktok },
            { label: 'All Cycles', href: '/cycles', icon: icons.cycles },
        ],
    },
    {
        label: 'Performance',
        href: '/performances',
        icon: icons.performance,
        group: true,
        children: [
            { label: 'Instagram', href: '/performances?platform=instagram', icon: icons.instagram },
            { label: 'TikTok', href: '/performances?platform=tiktok', icon: icons.tiktok },
            { label: 'All Performance', href: '/performances', icon: icons.performance },
        ],
    },
    { label: 'Accounts', href: '/accounts', icon: icons.accounts },
    { label: 'Views Trend', href: '/views-trend', icon: icons.viewsTrend },
    { label: 'Employees', href: '/employees', icon: icons.employees },
    { label: 'Departments', href: '/departments', icon: icons.departments },
    { label: 'Scoring Buckets', href: '/score-buckets', icon: icons.buckets },
];

const navItems = computed(() =>
    isSuperAdmin.value
        ? [
              ...baseNavItems,
              { label: 'Users', href: '/users', icon: icons.users },
              { label: 'Site Settings', href: '/settings/site', icon: icons.siteSettings },
          ]
        : baseNavItems,
);

const page = usePage();
const currentPath = () => page.url.split('?')[0];

const queryParam = (url, key) => {
    const query = url.split('?')[1] ?? '';
    const match = query.split('&').find((pair) => pair.split('=')[0] === key);
    return match ? decodeURIComponent(match.split('=')[1] ?? '') : null;
};

const currentPlatform = () => queryParam(page.url, 'platform');
const childPlatform = (href) => queryParam(href, 'platform');
const user = page.props.auth?.user;

const isChildActive = (item, child) =>
    currentPath().startsWith(item.href) && currentPlatform() === childPlatform(child.href);

// Expanded/collapsed state per group label — a group starts expanded when
// the current page belongs to it, so navigating there doesn't hide the very
// sub-link you're on.
const expandedGroups = ref({});

const isGroupExpanded = (item) => expandedGroups.value[item.label] ?? currentPath().startsWith(item.href);

const toggleGroup = (item) => {
    expandedGroups.value = {
        ...expandedGroups.value,
        [item.label]: !isGroupExpanded(item),
    };
};

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

const sidebarCollapsed = ref(false);
const hoveredItem = ref(null);
const flyoutStyle = ref({});
let closeFlyoutTimeout = null;

const openFlyout = (item, event) => {
    if (!sidebarCollapsed.value) return;
    clearTimeout(closeFlyoutTimeout);
    const rect = event.currentTarget.getBoundingClientRect();
    flyoutStyle.value = {
        top: `${rect.top + rect.height / 2}px`,
        left: `${rect.right + 8}px`,
        transform: 'translateY(-50%)',
    };
    hoveredItem.value = item;
};

const scheduleCloseFlyout = () => {
    clearTimeout(closeFlyoutTimeout);
    closeFlyoutTimeout = setTimeout(() => {
        hoveredItem.value = null;
    }, 150);
};

const cancelCloseFlyout = () => {
    clearTimeout(closeFlyoutTimeout);
};

const toggleSidebar = () => {
    sidebarCollapsed.value = !sidebarCollapsed.value;
    localStorage.setItem('sidebar-collapsed', sidebarCollapsed.value ? '1' : '0');
};

onMounted(() => {
    sidebarCollapsed.value = localStorage.getItem('sidebar-collapsed') === '1';
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
    <div class="min-h-screen lg:flex" style="background-color: var(--bg)">
        <!-- Mobile top bar -->
        <header
            class="flex items-center justify-between border-b px-4 py-4 sm:px-6 lg:hidden"
            style="border-color: var(--border); background-color: var(--surface)"
        >
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

            <div class="flex items-center gap-2">
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
        </header>

        <!-- Mobile nav panel -->
        <div
            v-if="mobileMenuOpen"
            class="border-b px-4 py-3 lg:hidden"
            style="border-color: var(--border); background-color: var(--surface)"
        >
            <nav class="flex flex-col gap-1">
                <template v-for="item in navItems" :key="item.href">
                    <Link
                        v-if="!item.group"
                        :href="item.href"
                        class="flex items-center gap-2.5 rounded-md px-3 py-2 text-sm font-medium transition-colors"
                        :style="
                            currentPath().startsWith(item.href)
                                ? `background-color: var(--accent-soft); color: var(--accent)`
                                : `color: var(--ink-muted)`
                        "
                        @click="closeMobileMenu"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4 shrink-0">
                            <path :d="item.icon" />
                        </svg>
                        {{ item.label }}
                    </Link>
                    <button
                        v-else
                        type="button"
                        class="flex items-center gap-2.5 rounded-md px-3 py-2 text-sm font-medium transition-colors"
                        style="color: var(--ink-muted)"
                        @click="toggleGroup(item)"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4 shrink-0">
                            <path :d="item.icon" />
                        </svg>
                        <span class="flex-1 text-left">{{ item.label }}</span>
                        <svg
                            xmlns="http://www.w3.org/2000/svg"
                            viewBox="0 0 24 24"
                            fill="none"
                            stroke="currentColor"
                            stroke-width="2"
                            class="h-3.5 w-3.5 shrink-0 transition-transform"
                            :class="{ 'rotate-90': isGroupExpanded(item) }"
                        >
                            <path d="m9 18 6-6-6-6" />
                        </svg>
                    </button>
                    <div
                        v-if="item.children && isGroupExpanded(item)"
                        class="ml-3 flex flex-col gap-0.5 border-l pl-2.5"
                        style="border-color: var(--border)"
                    >
                        <Link
                            v-for="child in item.children"
                            :key="child.href"
                            :href="child.href"
                            class="flex items-center gap-2.5 rounded-md px-3 py-1.5 text-sm font-medium transition-colors"
                            :style="
                                isChildActive(item, child)
                                    ? `background-color: var(--accent-soft); color: var(--accent)`
                                    : `color: var(--ink-muted)`
                            "
                            @click="closeMobileMenu"
                        >
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4 shrink-0">
                                <path :d="child.icon" />
                            </svg>
                            {{ child.label }}
                        </Link>
                    </div>
                </template>
            </nav>

            <div v-if="user" class="mt-3 border-t pt-3" style="border-color: var(--border)">
                <ProfileDropdown :user="user" />
            </div>
        </div>

        <!-- Desktop sidebar -->
        <aside
            class="hidden shrink-0 border-r transition-all duration-200 lg:sticky lg:top-0 lg:flex lg:h-screen lg:flex-col"
            :class="sidebarCollapsed ? 'lg:w-16' : 'lg:w-60'"
            style="border-color: var(--border); background-color: var(--surface)"
        >
            <div
                class="flex items-center gap-2.5 border-b px-5 py-5"
                :class="{ 'lg:justify-center lg:px-0': sidebarCollapsed }"
                style="border-color: var(--border)"
            >
                <span
                    class="flex h-8 w-8 shrink-0 items-center justify-center rounded-md font-display text-sm font-bold"
                    style="background-color: var(--accent); color: var(--accent-ink)"
                >
                    BM
                </span>
                <span v-if="!sidebarCollapsed" class="font-display text-lg font-bold tracking-tight" style="color: var(--ink)">
                    Brand Matrix
                </span>
            </div>

            <nav class="flex flex-1 flex-col gap-1 overflow-y-auto overflow-x-hidden p-3">
                <template v-for="item in navItems" :key="item.href">
                    <div
                        class="relative"
                        @mouseenter="openFlyout(item, $event)"
                        @mouseleave="scheduleCloseFlyout"
                    >
                        <Link
                            v-if="!item.group"
                            :href="item.href"
                            class="flex items-center gap-2.5 rounded-md px-3 py-2 text-sm font-medium whitespace-nowrap transition-colors"
                            :class="{ 'lg:justify-center lg:px-0': sidebarCollapsed }"
                            :style="
                                currentPath().startsWith(item.href)
                                    ? `background-color: var(--accent-soft); color: var(--accent)`
                                    : `color: var(--ink-muted)`
                            "
                        >
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4 shrink-0">
                                <path :d="item.icon" />
                            </svg>
                            <span v-if="!sidebarCollapsed">{{ item.label }}</span>
                        </Link>
                        <button
                            v-else
                            type="button"
                            class="flex w-full items-center gap-2.5 rounded-md px-3 py-2 text-sm font-medium whitespace-nowrap transition-colors"
                            :class="{ 'lg:justify-center lg:px-0': sidebarCollapsed }"
                            style="color: var(--ink-muted)"
                            @click="!sidebarCollapsed && toggleGroup(item)"
                        >
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4 shrink-0">
                                <path :d="item.icon" />
                            </svg>
                            <span v-if="!sidebarCollapsed" class="flex-1 text-left">{{ item.label }}</span>
                            <svg
                                v-if="!sidebarCollapsed"
                                xmlns="http://www.w3.org/2000/svg"
                                viewBox="0 0 24 24"
                                fill="none"
                                stroke="currentColor"
                                stroke-width="2"
                                class="h-3.5 w-3.5 shrink-0 transition-transform"
                                :class="{ 'rotate-90': isGroupExpanded(item) }"
                            >
                                <path d="m9 18 6-6-6-6" />
                            </svg>
                        </button>
                    </div>
                    <div
                        v-if="item.children && !sidebarCollapsed && isGroupExpanded(item)"
                        class="ml-3 flex flex-col gap-0.5 border-l pl-2.5"
                        style="border-color: var(--border)"
                    >
                        <Link
                            v-for="child in item.children"
                            :key="child.href"
                            :href="child.href"
                            class="flex items-center gap-2.5 rounded-md px-3 py-1.5 text-sm font-medium transition-colors"
                            :style="
                                isChildActive(item, child)
                                    ? `background-color: var(--accent-soft); color: var(--accent)`
                                    : `color: var(--ink-muted)`
                            "
                        >
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4 shrink-0">
                                <path :d="child.icon" />
                            </svg>
                            {{ child.label }}
                        </Link>
                    </div>
                </template>
            </nav>

            <Teleport to="body">
                <div
                    v-if="hoveredItem"
                    class="fixed z-50 overflow-hidden whitespace-nowrap rounded-md shadow-lg"
                    :style="{ ...flyoutStyle, backgroundColor: 'var(--surface-raised)', border: '1px solid var(--border)' }"
                    @mouseenter="cancelCloseFlyout"
                    @mouseleave="scheduleCloseFlyout"
                >
                    <template v-if="hoveredItem.children">
                        <p class="px-3 pt-2.5 pb-1 text-[11px] font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                            {{ hoveredItem.label }}
                        </p>
                        <Link
                            v-for="child in hoveredItem.children"
                            :key="child.href"
                            :href="child.href"
                            class="flex items-center gap-2 px-3 py-2 text-sm font-medium transition-colors"
                            :style="
                                isChildActive(hoveredItem, child)
                                    ? `background-color: var(--accent-soft); color: var(--accent)`
                                    : `color: var(--ink-muted)`
                            "
                        >
                            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4 shrink-0">
                                <path :d="child.icon" />
                            </svg>
                            {{ child.label }}
                        </Link>
                    </template>
                    <p v-else class="px-2.5 py-1.5 text-xs font-medium" style="color: var(--ink)">
                        {{ hoveredItem.label }}
                    </p>
                </div>
            </Teleport>

            <div class="border-t p-3" style="border-color: var(--border)">
                <button
                    type="button"
                    class="flex h-8 w-full items-center justify-center rounded-md border transition-colors hover:opacity-70"
                    style="border-color: var(--border); color: var(--ink-muted)"
                    :aria-label="sidebarCollapsed ? 'Expand navbar' : 'Collapse navbar'"
                    @click="toggleSidebar"
                >
                    <svg
                        xmlns="http://www.w3.org/2000/svg"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        stroke-width="2"
                        class="h-4 w-4 transition-transform"
                        :class="{ 'rotate-180': sidebarCollapsed }"
                    >
                        <path d="M11 19l-7-7 7-7M19 19l-7-7 7-7" />
                    </svg>
                </button>
            </div>
        </aside>

        <div class="min-w-0 flex-1">
            <!-- Desktop top bar -->
            <header
                class="hidden items-center justify-end gap-2 border-b px-6 py-3 lg:flex"
                style="border-color: var(--border); background-color: var(--surface)"
            >
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

                <ProfileDropdown v-if="user" :user="user" />
            </header>

            <main class="px-4 py-10 sm:px-6 lg:px-10">
                <div class="mx-auto max-w-6xl">
                    <slot />
                </div>
            </main>
        </div>

        <ToastContainer />
    </div>
</template>
