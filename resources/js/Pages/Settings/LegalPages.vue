<script setup>
import { ref } from 'vue';
import { useForm } from '@inertiajs/vue3';
import AppLayout from '../../Layouts/AppLayout.vue';

import RichTextEditor from '../../Components/RichTextEditor.vue';
import { useToast } from '../../composables/useToast';
import { useAuth } from '../../composables/useAuth';

defineOptions({ layout: AppLayout });

const toast = useToast();
const { canEdit } = useAuth();

const props = defineProps({
    pages: {
        type: Array,
        required: true,
    },
});

const activeSlug = ref(props.pages[0]?.slug ?? null);
const activePage = () => props.pages.find((page) => page.slug === activeSlug.value);

const forms = Object.fromEntries(
    props.pages.map((page) => [page.slug, useForm({ content_html: page.content_html })])
);

const save = () => {
    const page = activePage();
    if (!page) return;

    forms[page.slug].put(`/settings/legal-pages/${page.id}`, {
        preserveScroll: true,
        onSuccess: () => toast.success(`${page.title} updated.`),
        onError: () => toast.error(`Failed to update ${page.title}.`),
    });
};
</script>

<template>
        <div>
            <h1 class="font-display text-2xl font-bold tracking-tight" style="color: var(--ink)">Legal Pages</h1>
            <p class="mt-1 text-sm" style="color: var(--ink-muted)">
                Edit the public Privacy Policy and Data Deletion Instructions pages.
            </p>
        </div>

        <div class="mt-6 flex gap-1 border-b" style="border-color: var(--border)">
            <button
                v-for="page in pages"
                :key="page.slug"
                type="button"
                class="border-b-2 px-3 py-2.5 text-sm font-medium transition-colors"
                :style="
                    activeSlug === page.slug
                        ? 'border-color: var(--accent); color: var(--accent)'
                        : 'border-color: transparent; color: var(--ink-muted)'
                "
                @click="activeSlug = page.slug"
            >
                {{ page.title }}
            </button>
        </div>

        <div v-if="activePage()" class="mt-5 max-w-3xl">
            <a
                :href="`/${activePage().slug}`"
                target="_blank"
                rel="noopener noreferrer"
                class="text-sm font-medium hover:opacity-70"
                style="color: var(--accent)"
            >
                View live page →
            </a>

            <div v-if="canEdit" class="mt-3">
                <RichTextEditor v-model="forms[activePage().slug].content_html" />
            </div>
            <div v-else class="mt-3 rounded-md border p-4 text-sm" style="border-color: var(--border); color: var(--ink-muted)" v-html="forms[activePage().slug].content_html" />

            <div v-if="canEdit" class="mt-4 flex justify-end">
                <button
                    type="button"
                    :disabled="forms[activePage().slug].processing"
                    class="rounded-md px-4 py-2 text-sm font-semibold transition-opacity hover:opacity-90 disabled:opacity-50"
                    style="background-color: var(--accent); color: var(--accent-ink)"
                    @click="save"
                >
                    Save Changes
                </button>
            </div>
        </div>
</template>
