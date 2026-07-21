<script setup>
import { ref } from 'vue';
import { useForm, router, usePage } from '@inertiajs/vue3';
import AppLayout from '../../Layouts/AppLayout.vue';
import AccountGrowthModal from '../../Components/AccountGrowthModal.vue';
import EditNameModal from '../../Components/EditNameModal.vue';
import InstagramDataModal from '../../Components/InstagramDataModal.vue';
import ActionsMenu from '../../Components/ActionsMenu.vue';
import ConfirmDialog from '../../Components/ConfirmDialog.vue';
import { useToast } from '../../composables/useToast';

const toast = useToast();

const props = defineProps({
    accounts: {
        type: Object,
        required: true,
    },
    defaultAiProvider: {
        type: String,
        default: 'groq',
    },
});

const flash = usePage().props.flash;

const goToPage = (url) => {
    if (!url) return;
    router.visit(url, { preserveScroll: true, preserveState: true });
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

const editingAccount = ref(null);

const startEdit = (account) => {
    editingAccount.value = account;
};

const cancelEdit = () => {
    editingAccount.value = null;
};

const onEditSaved = () => {
    editingAccount.value = null;
    toast.success('Account updated.');
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

const instagramAccount = ref(null);

const openInstagram = (account) => {
    instagramAccount.value = account;
};

const closeInstagram = () => {
    instagramAccount.value = null;
};
</script>

<template>
    <AppLayout>
        <h1 class="font-display text-2xl font-bold tracking-tight" style="color: var(--ink)">Accounts</h1>
        <p class="mt-1 text-sm" style="color: var(--ink-muted)">
            Manage the brand accounts being tracked across cycles.
        </p>

        <div
            v-if="flash?.ig_success"
            class="mt-4 rounded-md border px-4 py-3 text-sm"
            style="border-color: var(--accent); color: var(--ink)"
        >
            {{ flash.ig_success }}
        </div>
        <div
            v-if="flash?.ig_error"
            class="mt-4 rounded-md border px-4 py-3 text-sm"
            style="border-color: var(--status-parah-ink); color: var(--status-parah-ink)"
        >
            {{ flash.ig_error }}
        </div>

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

        <div
            class="mt-8 overflow-hidden rounded-lg border"
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
                        @click="openGrowth(account)"
                    >
                        <td class="px-4 py-3.5 text-sm font-medium" style="color: var(--ink)">
                            {{ account.name }}
                        </td>
                        <td class="px-4 py-3.5 text-right text-sm" @click.stop>
                            <ActionsMenu
                                :items="[
                                    { label: account.ig_business_id ? 'Instagram ✓' : 'Connect Instagram', onClick: () => openInstagram(account) },
                                    { label: 'Edit', onClick: () => startEdit(account) },
                                    { label: 'Delete', danger: true, onClick: () => confirmDestroy(account) },
                                ]"
                            />
                        </td>
                    </tr>
                    <tr v-if="accounts.data.length === 0">
                        <td colspan="2" class="px-4 py-12 text-center text-sm" style="color: var(--ink-faint)">
                            No accounts yet. Add one to start tracking cycles.
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

        <InstagramDataModal
            v-if="instagramAccount"
            :account="instagramAccount"
            @close="closeInstagram"
        />

        <EditNameModal
            v-if="editingAccount"
            :item="editingAccount"
            :url="`/accounts/${editingAccount.id}`"
            title="Edit Account"
            label="Account name"
            @close="cancelEdit"
            @saved="onEditSaved"
        />

        <ConfirmDialog
            :open="!!deletingAccount"
            title="Delete this account?"
            :message="deletingAccount ? `This will permanently remove “${deletingAccount.name}” and all its cycles. This cannot be undone.` : ''"
            checkbox-label="I understand this will also delete all cycles for this account."
            :processing="deleting"
            @confirm="destroy"
            @cancel="cancelDestroy"
        />
    </AppLayout>
</template>
