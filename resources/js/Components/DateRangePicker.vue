<script setup>
import { computed, nextTick, onBeforeUnmount, onMounted, ref, watch } from 'vue';

// The popover is teleported to <body> and positioned with fixed coordinates
// computed from the trigger button's own bounding rect — otherwise, when this
// component sits inside a scrolling container (e.g. a modal body with
// overflow-y-auto), the popover gets visually clipped at that container's
// edge instead of floating freely above everything, which was cutting the
// calendar grid off mid-render.

// Single-field day-range picker — presents a 'YYYY-MM-DD'..'YYYY-MM-DD' pair
// as one button showing the formatted range, opening a single-month calendar
// grid (prev/next month navigation) where the first click sets the start day
// and the second sets the end day, mirroring MonthRangePicker's click-twice
// selection model but at day granularity instead of month granularity.
const props = defineProps({
    modelFrom: {
        type: String,
        default: '',
    },
    modelTo: {
        type: String,
        default: '',
    },
    placeholder: {
        type: String,
        default: 'Select date range',
    },
});

const emit = defineEmits(['update:modelFrom', 'update:modelTo']);

const containerRef = ref(null);
const triggerRef = ref(null);
const popoverRef = ref(null);
const open = ref(false);
const popoverStyle = ref({});

const updatePosition = () => {
    if (!triggerRef.value) return;
    const rect = triggerRef.value.getBoundingClientRect();
    const popoverWidth = 288; // w-72
    // Flip to align right edge when the popover would overflow the viewport.
    const left = rect.left + popoverWidth > window.innerWidth
        ? Math.max(8, rect.right - popoverWidth)
        : rect.left;

    popoverStyle.value = {
        position: 'fixed',
        top: `${rect.bottom + 4}px`,
        left: `${left}px`,
    };
};

const monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
const weekdayLabels = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

const pad2 = (n) => String(n).padStart(2, '0');
const toKey = (y, m, d) => `${y}-${pad2(m)}-${pad2(d)}`;

const initialView = () => {
    const base = props.modelFrom || props.modelTo;
    if (base) {
        const [y, m] = base.split('-').map(Number);
        return { year: y, month: m };
    }
    const now = new Date();
    return { year: now.getFullYear(), month: now.getMonth() + 1 };
};

const viewYear = ref(initialView().year);
const viewMonth = ref(initialView().month);

watch(open, (isOpen) => {
    if (!isOpen) return;
    const view = initialView();
    viewYear.value = view.year;
    viewMonth.value = view.month;
});

const prevMonth = () => {
    if (viewMonth.value === 1) {
        viewMonth.value = 12;
        viewYear.value -= 1;
    } else {
        viewMonth.value -= 1;
    }
};

const nextMonth = () => {
    if (viewMonth.value === 12) {
        viewMonth.value = 1;
        viewYear.value += 1;
    } else {
        viewMonth.value += 1;
    }
};

// Calendar grid: leading blanks for days-before-the-1st, then every day of
// the month, padded to a multiple of 7 with trailing blanks.
const calendarCells = computed(() => {
    const firstWeekday = new Date(viewYear.value, viewMonth.value - 1, 1).getDay();
    const daysInMonth = new Date(viewYear.value, viewMonth.value, 0).getDate();

    const cells = [];
    for (let i = 0; i < firstWeekday; i++) cells.push(null);
    for (let day = 1; day <= daysInMonth; day++) cells.push(day);
    while (cells.length % 7 !== 0) cells.push(null);

    return cells;
});

const keyFor = (day) => toKey(viewYear.value, viewMonth.value, day);

const isSelected = (day) => {
    const key = keyFor(day);
    return key === props.modelFrom || key === props.modelTo;
};

const isInRange = (day) => {
    if (!props.modelFrom || !props.modelTo) return false;
    const key = keyFor(day);
    return key > props.modelFrom && key < props.modelTo;
};

const selectDay = (day) => {
    if (!day) return;
    const key = keyFor(day);

    if (!props.modelFrom || (props.modelFrom && props.modelTo)) {
        // Start a fresh selection.
        emit('update:modelFrom', key);
        emit('update:modelTo', '');
        return;
    }

    // One endpoint already picked — set the second, ordering low/high.
    if (key === props.modelFrom) {
        emit('update:modelFrom', '');
        emit('update:modelTo', '');
        return;
    }

    if (key < props.modelFrom) {
        emit('update:modelTo', props.modelFrom);
        emit('update:modelFrom', key);
    } else {
        emit('update:modelTo', key);
    }
};

const formatDate = (value) => {
    if (!value) return null;
    const date = new Date(`${value}T00:00:00`);
    return date.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
};

const displayLabel = computed(() => {
    if (!props.modelFrom && !props.modelTo) return null;
    if (props.modelFrom && props.modelTo) return `${formatDate(props.modelFrom)} – ${formatDate(props.modelTo)}`;
    if (props.modelFrom) return `From ${formatDate(props.modelFrom)}`;
    return `Until ${formatDate(props.modelTo)}`;
});

const toggleOpen = async () => {
    open.value = !open.value;
    if (open.value) {
        await nextTick();
        updatePosition();
    }
};

// Keep the popover aligned to its trigger if the page scrolls or the
// viewport resizes while it's open (e.g. scrolling the modal body itself).
onMounted(() => {
    window.addEventListener('scroll', updatePosition, true);
    window.addEventListener('resize', updatePosition);
});
onBeforeUnmount(() => {
    window.removeEventListener('scroll', updatePosition, true);
    window.removeEventListener('resize', updatePosition);
});

const clear = () => {
    emit('update:modelFrom', '');
    emit('update:modelTo', '');
    open.value = false;
};

const onClickOutside = (event) => {
    const inTrigger = containerRef.value?.contains(event.target);
    const inPopover = popoverRef.value?.contains(event.target);
    if (!inTrigger && !inPopover) {
        open.value = false;
    }
};

onMounted(() => document.addEventListener('click', onClickOutside));
onBeforeUnmount(() => document.removeEventListener('click', onClickOutside));
</script>

<template>
    <div ref="containerRef" class="relative">
        <button
            ref="triggerRef"
            type="button"
            class="flex w-full items-center justify-between rounded-md border px-3 py-2 text-left text-sm transition-colors focus:outline-none focus:ring-2"
            style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
            @click="toggleOpen"
        >
            <span class="truncate" :style="displayLabel ? '' : 'color: var(--ink-faint)'">
                {{ displayLabel ?? placeholder }}
            </span>
            <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4 shrink-0" style="color: var(--ink-faint)">
                <path d="M8 2v4M16 2v4M3 10h18M5 4h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2Z" />
            </svg>
        </button>
    </div>

    <Teleport to="body">
        <div
            v-if="open"
            ref="popoverRef"
            class="z-50 w-72 overflow-hidden rounded-lg border p-3 shadow-lg"
            :style="{ ...popoverStyle, borderColor: 'var(--border)', backgroundColor: 'var(--surface-raised)' }"
        >
            <div class="flex items-center justify-between">
                <button
                    type="button"
                    class="flex h-7 w-7 items-center justify-center rounded-md transition-colors hover:opacity-70"
                    style="color: var(--ink-muted)"
                    aria-label="Previous month"
                    @click="prevMonth"
                >
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4">
                        <path d="m15 18-6-6 6-6" />
                    </svg>
                </button>
                <p class="font-display text-sm font-bold" style="color: var(--ink)">{{ monthNames[viewMonth - 1] }} {{ viewYear }}</p>
                <button
                    type="button"
                    class="flex h-7 w-7 items-center justify-center rounded-md transition-colors hover:opacity-70"
                    style="color: var(--ink-muted)"
                    aria-label="Next month"
                    @click="nextMonth"
                >
                    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4">
                        <path d="m9 18 6-6-6-6" />
                    </svg>
                </button>
            </div>

            <div class="mt-3 grid grid-cols-7 gap-1 text-center text-[11px] font-semibold" style="color: var(--ink-faint)">
                <span v-for="label in weekdayLabels" :key="label">{{ label }}</span>
            </div>

            <div class="mt-1 grid grid-cols-7 gap-1">
                <button
                    v-for="(day, i) in calendarCells"
                    :key="i"
                    type="button"
                    class="flex h-8 w-8 items-center justify-center rounded-md text-sm font-medium transition-colors"
                    :class="{ invisible: !day }"
                    :style="
                        day && isSelected(day)
                            ? 'background-color: var(--accent); color: var(--accent-ink)'
                            : day && isInRange(day)
                              ? 'background-color: var(--accent-soft); color: var(--accent)'
                              : 'color: var(--ink)'
                    "
                    @click="selectDay(day)"
                >
                    {{ day }}
                </button>
            </div>

            <div class="mt-3 flex items-center justify-between border-t pt-2" style="border-color: var(--border)">
                <p class="text-xs" style="color: var(--ink-faint)">
                    {{ modelFrom ? formatDate(modelFrom) : 'Start' }} – {{ modelTo ? formatDate(modelTo) : 'End' }}
                </p>
                <button
                    type="button"
                    class="text-xs font-medium transition-colors hover:opacity-70"
                    style="color: var(--ink-faint)"
                    @click="clear"
                >
                    Clear
                </button>
            </div>
        </div>
    </Teleport>
</template>
