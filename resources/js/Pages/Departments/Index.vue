<script setup>
import { ref } from 'vue';
import { useForm, router } from '@inertiajs/vue3';
import AppLayout from '../../Layouts/AppLayout.vue';

import EditNameModal from '../../Components/EditNameModal.vue';
import ActionsMenu from '../../Components/ActionsMenu.vue';
import ConfirmDialog from '../../Components/ConfirmDialog.vue';
import { useToast } from '../../composables/useToast';
import { useAuth } from '../../composables/useAuth';

defineOptions({ layout: AppLayout });

const toast = useToast();
const { canEdit } = useAuth();

const props = defineProps({
    departments: {
        type: Object,
        required: true,
    },
});

const goToPage = (url) => {
    if (!url) return;
    router.visit(url, { preserveScroll: true, preserveState: true });
};

const createForm = useForm({ name: '' });

const submitCreate = () => {
    createForm.post('/departments', {
        preserveScroll: true,
        onSuccess: () => {
            createForm.reset();
            toast.success('Department added.');
        },
        onError: () => toast.error('Failed to add department.'),
    });
};

const editingDepartment = ref(null);

const startEdit = (department) => {
    editingDepartment.value = department;
};

const cancelEdit = () => {
    editingDepartment.value = null;
};

const onEditSaved = () => {
    editingDepartment.value = null;
    toast.success('Department updated.');
};

// Delete confirmation

const deletingDepartment = ref(null);
const deleting = ref(false);

const confirmDestroy = (department) => {
    deletingDepartment.value = department;
};

const cancelDestroy = () => {
    deletingDepartment.value = null;
};

const destroy = () => {
    if (!deletingDepartment.value) return;
    deleting.value = true;

    router.delete(`/departments/${deletingDepartment.value.id}`, {
        preserveScroll: true,
        onSuccess: () => {
            toast.success('Department deleted.');
            deletingDepartment.value = null;
        },
        onError: () => toast.error('Failed to delete department.'),
        onFinish: () => {
            deleting.value = false;
        },
    });
};
</script>

<template>
        <h1 class="font-display text-2xl font-bold tracking-tight" style="color: var(--ink)">Departments</h1>
        <p class="mt-1 text-sm" style="color: var(--ink-muted)">
            Manage the departments employees can be assigned to.
        </p>

        <form v-if="canEdit" @submit.prevent="submitCreate" class="mt-6 flex items-start gap-3">
            <div class="flex-1">
                <input
                    v-model="createForm.name"
                    type="text"
                    placeholder="Department name"
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
                + Add Department
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
                        v-for="department in departments.data"
                        :key="department.id"
                        style="border-bottom: 1px solid var(--border)"
                    >
                        <td class="px-4 py-3.5 text-sm font-medium" style="color: var(--ink)">
                            {{ department.name }}
                        </td>
                        <td class="px-4 py-3.5 text-right text-sm">
                            <ActionsMenu
                                v-if="canEdit"
                                :items="[
                                    { label: 'Edit', onClick: () => startEdit(department) },
                                    { label: 'Delete', danger: true, onClick: () => confirmDestroy(department) },
                                ]"
                            />
                        </td>
                    </tr>
                    <tr v-if="departments.data.length === 0">
                        <td colspan="2" class="px-4 py-12 text-center text-sm" style="color: var(--ink-faint)">
                            No departments yet. Add one to start assigning employees.
                        </td>
                    </tr>
                </tbody>
            </table>

            <div
                v-if="departments.last_page > 1"
                class="flex items-center justify-between border-t px-4 py-3"
                style="border-color: var(--border)"
            >
                <p class="text-sm" style="color: var(--ink-muted)">
                    Showing <span class="font-medium tabular-nums" style="color: var(--ink)">{{ departments.from }}–{{ departments.to }}</span>
                    of <span class="font-medium tabular-nums" style="color: var(--ink)">{{ departments.total }}</span>
                </p>
                <div class="flex items-center gap-1">
                    <button
                        v-for="link in departments.links"
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

        <EditNameModal
            v-if="editingDepartment"
            :item="editingDepartment"
            :url="`/departments/${editingDepartment.id}`"
            title="Edit Department"
            label="Department name"
            @close="cancelEdit"
            @saved="onEditSaved"
        />

        <ConfirmDialog
            :open="!!deletingDepartment"
            title="Delete this department?"
            :message="deletingDepartment ? `This will unassign any employees in “${deletingDepartment.name}”. This cannot be undone.` : ''"
            :processing="deleting"
            @confirm="destroy"
            @cancel="cancelDestroy"
        />
</template>
