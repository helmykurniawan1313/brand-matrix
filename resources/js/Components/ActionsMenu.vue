<script setup>
import { nextTick, onBeforeUnmount, ref } from 'vue';

defineProps({
    items: {
        type: Array,
        required: true,
        // [{ label, onClick, danger }]
    },
});

// Module-scoped so only one ActionsMenu instance across the whole page can be open at a time —
// otherwise opening a second row's menu leaves the first row's panel open too, and since both are
// Teleported to <body> and positioned independently, they can visually overlap.
let activeMenuId = null;
const menuId = Symbol('actions-menu');

const open = ref(false);
const buttonRef = ref(null);
const menuStyle = ref({});

const closeOnScrollOrResize = () => {
    open.value = false;
};

const toggleOpen = async () => {
    if (open.value) {
        open.value = false;
        activeMenuId = null;
        return;
    }

    await nextTick();
    const rect = buttonRef.value.getBoundingClientRect();
    menuStyle.value = {
        top: `${rect.bottom + 4}px`,
        left: `${rect.right - 160}px`,
    };
    activeMenuId = menuId;
    open.value = true;
    document.dispatchEvent(new Event('actions-menu-opened'));
};

const runItem = (item) => {
    open.value = false;
    activeMenuId = null;
    item.onClick();
};

const onClickOutside = (event) => {
    if (buttonRef.value && !buttonRef.value.contains(event.target) && !event.target.closest('[data-actions-menu-panel]')) {
        open.value = false;
    }
};

const closeIfNotActive = () => {
    if (activeMenuId !== menuId) {
        open.value = false;
    }
};

document.addEventListener('click', onClickOutside);
document.addEventListener('actions-menu-opened', closeIfNotActive);
window.addEventListener('scroll', closeOnScrollOrResize, true);
window.addEventListener('resize', closeOnScrollOrResize);

onBeforeUnmount(() => {
    document.removeEventListener('click', onClickOutside);
    document.removeEventListener('actions-menu-opened', closeIfNotActive);
    window.removeEventListener('scroll', closeOnScrollOrResize, true);
    window.removeEventListener('resize', closeOnScrollOrResize);
});
</script>

<template>
    <div class="relative inline-block" @click.stop>
        <button
            ref="buttonRef"
            type="button"
            class="flex h-8 w-8 items-center justify-center rounded-md transition-colors hover:opacity-70"
            style="color: var(--ink-muted)"
            aria-label="Actions"
            @click="toggleOpen"
        >
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="h-4.5 w-4.5">
                <circle cx="12" cy="5" r="1.75" />
                <circle cx="12" cy="12" r="1.75" />
                <circle cx="12" cy="19" r="1.75" />
            </svg>
        </button>

        <Teleport to="body">
            <div
                v-if="open"
                data-actions-menu-panel
                class="fixed z-50 w-40 overflow-hidden rounded-md border py-1 shadow-lg"
                :style="{ ...menuStyle, borderColor: 'var(--border)', backgroundColor: 'var(--surface-raised)' }"
                @click.stop
            >
                <button
                    v-for="item in items"
                    :key="item.label"
                    type="button"
                    class="block w-full px-3.5 py-2 text-left text-sm font-medium transition-colors hover:opacity-70"
                    :style="item.danger ? 'color: var(--status-parah-ink)' : 'color: var(--ink)'"
                    @click="runItem(item)"
                >
                    {{ item.label }}
                </button>
            </div>
        </Teleport>
    </div>
</template>
