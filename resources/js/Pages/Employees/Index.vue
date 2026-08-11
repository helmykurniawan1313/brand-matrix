<script setup>
import { ref } from 'vue';
import { useForm, router } from '@inertiajs/vue3';
import AppLayout from '../../Layouts/AppLayout.vue';

import SearchableSelect from '../../Components/SearchableSelect.vue';
import EditEmployeeModal from '../../Components/EditEmployeeModal.vue';
import ActionsMenu from '../../Components/ActionsMenu.vue';
import ConfirmDialog from '../../Components/ConfirmDialog.vue';
import { useToast } from '../../composables/useToast';
import { useAuth } from '../../composables/useAuth';

defineOptions({ layout: AppLayout });

const toast = useToast();
const { canEdit } = useAuth();

const props = defineProps({
    employees: {
        type: Object,
        required: true,
    },
    departments: {
        type: Array,
        required: true,
    },
});

const goToPage = (url) => {
    if (!url) return;
    router.visit(url, { preserveScroll: true, preserveState: true });
};

const createForm = useForm({ name: '', email: '', position: '', department_id: '' });

const submitCreate = () => {
    createForm.post('/employees', {
        preserveScroll: true,
        onSuccess: () => {
            createForm.reset();
            toast.success('Employee added.');
        },
        onError: () => toast.error('Failed to add employee.'),
    });
};

const editingEmployee = ref(null);

const startEdit = (employee) => {
    editingEmployee.value = employee;
};

const cancelEdit = () => {
    editingEmployee.value = null;
};

const onEditSaved = () => {
    editingEmployee.value = null;
    toast.success('Employee updated.');
};

// Delete confirmation

const deletingEmployee = ref(null);
const deleting = ref(false);

const confirmDestroy = (employee) => {
    deletingEmployee.value = employee;
};

const cancelDestroy = () => {
    deletingEmployee.value = null;
};

const destroy = () => {
    if (!deletingEmployee.value) return;
    deleting.value = true;

    router.delete(`/employees/${deletingEmployee.value.id}`, {
        preserveScroll: true,
        onSuccess: () => {
            toast.success('Employee deleted.');
            deletingEmployee.value = null;
        },
        onError: () => toast.error('Failed to delete employee.'),
        onFinish: () => {
            deleting.value = false;
        },
    });
};
</script>

<template>
        <h1 class="font-display text-2xl font-bold tracking-tight" style="color: var(--ink)">Employees</h1>
        <p class="mt-1 text-sm" style="color: var(--ink-muted)">
            Manage employees and their department assignments.
        </p>

        <form v-if="canEdit" @submit.prevent="submitCreate" class="mt-6 grid grid-cols-1 gap-3 sm:grid-cols-4">
            <div>
                <input
                    v-model="createForm.name"
                    type="text"
                    placeholder="Name"
                    class="w-full rounded-md border px-3 py-2 text-sm transition-colors focus:outline-none"
                    style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                />
                <p v-if="createForm.errors.name" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                    {{ createForm.errors.name }}
                </p>
            </div>
            <div>
                <input
                    v-model="createForm.email"
                    type="email"
                    placeholder="Email"
                    class="w-full rounded-md border px-3 py-2 text-sm transition-colors focus:outline-none"
                    style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                />
                <p v-if="createForm.errors.email" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                    {{ createForm.errors.email }}
                </p>
            </div>
            <div>
                <input
                    v-model="createForm.position"
                    type="text"
                    placeholder="Position"
                    class="w-full rounded-md border px-3 py-2 text-sm transition-colors focus:outline-none"
                    style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                />
                <p v-if="createForm.errors.position" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                    {{ createForm.errors.position }}
                </p>
            </div>
            <div class="flex items-start gap-3">
                <div class="flex-1">
                    <SearchableSelect
                        v-model="createForm.department_id"
                        :options="departments"
                        placeholder="Department"
                    />
                    <p v-if="createForm.errors.department_id" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                        {{ createForm.errors.department_id }}
                    </p>
                </div>
                <button
                    type="submit"
                    :disabled="createForm.processing"
                    class="shrink-0 rounded-md px-4 py-2 text-sm font-semibold transition-opacity hover:opacity-90 disabled:opacity-50"
                    style="background-color: var(--accent); color: var(--accent-ink)"
                >
                    + Add
                </button>
            </div>
        </form>

        <div
            class="mt-8 overflow-hidden rounded-lg border"
            style="border-color: var(--border); background-color: var(--surface)"
        >
            <table class="min-w-full">
                <thead>
                    <tr style="border-bottom: 1px solid var(--border)">
                        <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Name</th>
                        <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Email</th>
                        <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Position</th>
                        <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Department</th>
                        <th class="px-4 py-3 text-right text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <tr
                        v-for="employee in employees.data"
                        :key="employee.id"
                        style="border-bottom: 1px solid var(--border)"
                    >
                        <td class="px-4 py-3.5 text-sm font-medium" style="color: var(--ink)">{{ employee.name }}</td>
                        <td class="px-4 py-3.5 text-sm" style="color: var(--ink-muted)">{{ employee.email || '—' }}</td>
                        <td class="px-4 py-3.5 text-sm" style="color: var(--ink-muted)">{{ employee.position || '—' }}</td>
                        <td class="px-4 py-3.5 text-sm" style="color: var(--ink-muted)">{{ employee.department?.name || '—' }}</td>
                        <td class="px-4 py-3.5 text-right text-sm">
                            <ActionsMenu
                                v-if="canEdit"
                                :items="[
                                    { label: 'Edit', onClick: () => startEdit(employee) },
                                    { label: 'Delete', danger: true, onClick: () => confirmDestroy(employee) },
                                ]"
                            />
                        </td>
                    </tr>
                    <tr v-if="employees.data.length === 0">
                        <td colspan="5" class="px-4 py-12 text-center text-sm" style="color: var(--ink-faint)">
                            No employees yet. Add one to get started.
                        </td>
                    </tr>
                </tbody>
            </table>

            <div
                v-if="employees.last_page > 1"
                class="flex items-center justify-between border-t px-4 py-3"
                style="border-color: var(--border)"
            >
                <p class="text-sm" style="color: var(--ink-muted)">
                    Showing <span class="font-medium tabular-nums" style="color: var(--ink)">{{ employees.from }}–{{ employees.to }}</span>
                    of <span class="font-medium tabular-nums" style="color: var(--ink)">{{ employees.total }}</span>
                </p>
                <div class="flex items-center gap-1">
                    <button
                        v-for="link in employees.links"
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

        <EditEmployeeModal
            v-if="editingEmployee"
            :employee="editingEmployee"
            :departments="departments"
            @close="cancelEdit"
            @saved="onEditSaved"
        />

        <ConfirmDialog
            :open="!!deletingEmployee"
            title="Delete this employee?"
            :message="deletingEmployee ? `This will permanently remove “${deletingEmployee.name}”. This cannot be undone.` : ''"
            :processing="deleting"
            @confirm="destroy"
            @cancel="cancelDestroy"
        />
</template>
