<script setup>
import { ref } from 'vue';
import { useForm, router } from '@inertiajs/vue3';
import AppLayout from '../../Layouts/AppLayout.vue';
import AccountGrowthModal from '../../Components/AccountGrowthModal.vue';
import ActionsMenu from '../../Components/ActionsMenu.vue';
import ConfirmDialog from '../../Components/ConfirmDialog.vue';
import { useToast } from '../../composables/useToast';

const toast = useToast();

const props = defineProps({
    accounts: {
        type: Object,
        required: true,
    },
    filters: {
        type: Object,
        default: () => ({}),
    },
    defaultAiProvider: {
        type: String,
        default: 'groq',
    },
});

const goToPage = (url) => {
    if (!url) return;
    router.visit(url, { preserveScroll: true, preserveState: true });
};

const search = ref(props.filters.search ?? '');
let searchTimeout = null;

const applySearch = () => {
    router.get('/accounts', { search: search.value || undefined }, { preserveScroll: true, preserveState: true, replace: true });
};

const onSearchInput = () => {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(applySearch, 300);
};

const clearSearch = () => {
    search.value = '';
    applySearch();
};

const createForm = useForm({ name: '' });

const submitCreate = () => {
    createForm.post('/accounts', {
        preserveScroll: true,
        onSuccess: () => {
            createForm.reset();
            toast.success('Account added.');
        },
        onError: () => toast.error('Failed to add account.'),
    });
};

const editingId = ref(null);
const editForm = useForm({ name: '' });

const startEdit = (account) => {
    editingId.value = account.id;
    editForm.name = account.name;
};

const cancelEdit = () => {
    editingId.value = null;
};

const submitEdit = (account) => {
    editForm.put(`/accounts/${account.id}`, {
        preserveScroll: true,
        onSuccess: () => {
            editingId.value = null;
            toast.success('Account updated.');
        },
        onError: () => toast.error('Failed to update account.'),
    });
};

// Delete confirmation

const deletingAccount = ref(null);
const deleting = ref(false);

const confirmDestroy = (account) => {
    deletingAccount.value = account;
};

const cancelDestroy = () => {
    deletingAccount.value = null;
};

const destroy = () => {
    if (!deletingAccount.value) return;
    deleting.value = true;

    router.delete(`/accounts/${deletingAccount.value.id}`, {
        preserveScroll: true,
        onSuccess: () => {
            toast.success('Account deleted.');
            deletingAccount.value = null;
        },
        onError: () => toast.error('Failed to delete account.'),
        onFinish: () => {
            deleting.value = false;
        },
    });
};

const viewingAccount = ref(null);

const openGrowth = (account) => {
    viewingAccount.value = account;
};

const closeGrowth = () => {
    viewingAccount.value = null;
};
</script>

<template>
    <AppLayout>
        <h1 class="font-display text-2xl font-bold tracking-tight" style="color: var(--ink)">Accounts</h1>
        <p class="mt-1 text-sm" style="color: var(--ink-muted)">
            Manage the brand accounts being tracked across cycles.
        </p>

        <form @submit.prevent="submitCreate" class="mt-6 flex items-start gap-3">
            <div class="flex-1">
                <input
                    v-model="createForm.name"
                    type="text"
                    placeholder="Account name"
                    class="w-full rounded-md border px-3 py-2 text-sm transition-colors focus:outline-none"
                    style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                />
                <p v-if="createForm.errors.name" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                    {{ createForm.errors.name }}
                </p>
            </div>
            <button
                type="submit"
                :disabled="createForm.processing"
                class="shrink-0 rounded-md px-4 py-2 text-sm font-semibold transition-opacity hover:opacity-90 disabled:opacity-50"
                style="background-color: var(--accent); color: var(--accent-ink)"
            >
                + Add Account
            </button>
        </form>

        <div class="mt-8 relative max-w-xs">
            <svg
                xmlns="http://www.w3.org/2000/svg"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                class="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2"
                style="color: var(--ink-faint)"
            >
                <circle cx="11" cy="11" r="8" />
                <path d="m21 21-4.3-4.3" />
            </svg>
            <input
                v-model="search"
                type="text"
                placeholder="Search accounts…"
                class="w-full rounded-md border py-2 pl-9 pr-8 text-sm transition-colors focus:outline-none"
                style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                @input="onSearchInput"
            />
            <button
                v-if="search"
                type="button"
                class="absolute right-2.5 top-1/2 -translate-y-1/2 transition-colors hover:opacity-70"
                style="color: var(--ink-faint)"
                aria-label="Clear search"
                @click="clearSearch"
            >
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-4 w-4">
                    <path d="M18 6 6 18M6 6l12 12" />
                </svg>
            </button>
        </div>

        <div
            class="mt-3 overflow-hidden rounded-lg border"
            style="border-color: var(--border); background-color: var(--surface)"
        >
            <table class="min-w-full">
                <thead>
                    <tr style="border-bottom: 1px solid var(--border)">
                        <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                            Name
                        </th>
                        <th class="px-4 py-3 text-right text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">
                            Actions
                        </th>
                    </tr>
                </thead>
                <tbody>
                    <tr
                        v-for="account in accounts.data"
                        :key="account.id"
                        class="cursor-pointer transition-colors hover:opacity-80"
                        style="border-bottom: 1px solid var(--border)"
                        @click="editingId !== account.id && openGrowth(account)"
                    >
                        <td class="px-4 py-3.5 text-sm font-medium" style="color: var(--ink)" @click="editingId === account.id && $event.stopPropagation()">
                            <template v-if="editingId === account.id">
                                <input
                                    v-model="editForm.name"
                                    type="text"
                                    class="w-full rounded-md border px-2 py-1 text-sm focus:outline-none"
                                    style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                                    @click.stop
                                    @keyup.enter="submitEdit(account)"
                                    @keyup.escape="cancelEdit"
                                />
                                <p v-if="editForm.errors.name" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                                    {{ editForm.errors.name }}
                                </p>
                            </template>
                            <template v-else>
                                {{ account.name }}
                            </template>
                        </td>
                        <td class="px-4 py-3.5 text-right text-sm" @click.stop>
                            <template v-if="editingId === account.id">
                                <button
                                    class="mr-3 font-medium transition-colors hover:opacity-70"
                                    style="color: var(--accent)"
                                    :disabled="editForm.processing"
                                    @click="submitEdit(account)"
                                >
                                    Save
                                </button>
                                <button
                                    class="font-medium transition-colors hover:opacity-70"
                                    style="color: var(--ink-muted)"
                                    @click="cancelEdit"
                                >
                                    Cancel
                                </button>
                            </template>
                            <template v-else>
                                <ActionsMenu
                                    :items="[
                                        { label: 'Edit', onClick: () => startEdit(account) },
                                        { label: 'Delete', danger: true, onClick: () => confirmDestroy(account) },
                                    ]"
                                />
                            </template>
                        </td>
                    </tr>
                    <tr v-if="accounts.data.length === 0">
                        <td colspan="2" class="px-4 py-12 text-center text-sm" style="color: var(--ink-faint)">
                            <template v-if="search">No accounts match "{{ search }}".</template>
                            <template v-else>No accounts yet. Add one to start tracking cycles.</template>
                        </td>
                    </tr>
                </tbody>
            </table>

            <div
                v-if="accounts.last_page > 1"
                class="flex items-center justify-between border-t px-4 py-3"
                style="border-color: var(--border)"
            >
                <p class="text-sm" style="color: var(--ink-muted)">
                    Showing <span class="font-medium tabular-nums" style="color: var(--ink)">{{ accounts.from }}–{{ accounts.to }}</span>
                    of <span class="font-medium tabular-nums" style="color: var(--ink)">{{ accounts.total }}</span>
                </p>
                <div class="flex items-center gap-1">
                    <button
                        v-for="link in accounts.links"
                        :key="link.label"
                        type="button"
                        class="min-w-[2.25rem] rounded-md px-2.5 py-1.5 text-sm font-medium transition-colors"
                        :class="{ 'cursor-not-allowed opacity-40': !link.url }"
                        :style="
                            link.active
                                ? 'background-color: var(--accent); color: var(--accent-ink)'
                                : 'color: var(--ink-muted)'
                        "
                        :disabled="!link.url"
                        v-html="link.label"
                        @click="goToPage(link.url)"
                    />
                </div>
            </div>
        </div>

        <AccountGrowthModal
            v-if="viewingAccount"
            :account="viewingAccount"
            :default-ai-provider="defaultAiProvider"
            @close="closeGrowth"
        />

        <ConfirmDialog
            :open="!!deletingAccount"
            title="Delete this account?"
            :message="deletingAccount ? `This will permanently remove “${deletingAccount.name}” and all ${deletingAccount.cycles_count} cycle${deletingAccount.cycles_count === 1 ? '' : 's'} recorded for it. This cannot be undone.` : ''"
            checkbox-label="I understand this will also delete all cycles for this account."
            :processing="deleting"
            @confirm="destroy"
            @cancel="cancelDestroy"
        />
    </AppLayout>
</template>
