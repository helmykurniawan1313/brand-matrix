<script setup>
import { ref } from 'vue';
import { router, useForm } from '@inertiajs/vue3';
import AppLayout from '../../Layouts/AppLayout.vue';
import ActionsMenu from '../../Components/ActionsMenu.vue';
import ConfirmDialog from '../../Components/ConfirmDialog.vue';
import { useAuth } from '../../composables/useAuth';
import { useToast } from '../../composables/useToast';

const toast = useToast();
const { user: currentUser } = useAuth();

const props = defineProps({
    users: {
        type: Object,
        required: true,
    },
    roles: {
        type: Array,
        required: true,
    },
});

const roleLabels = {
    viewer: 'Viewer',
    editor: 'Editor',
    super_admin: 'Super Admin',
};

const goToPage = (url) => {
    if (!url) return;
    router.visit(url, { preserveScroll: true, preserveState: true });
};

const changeRole = (user, event) => {
    const role = event.target.value;

    router.put(
        `/users/${user.id}`,
        { role },
        {
            preserveScroll: true,
            onSuccess: () => toast.success(`${user.name}'s role updated to ${roleLabels[role] ?? role}.`),
            onError: (errors) => {
                event.target.value = user.role;
                toast.error(errors.role ?? 'Failed to update role.');
            },
        },
    );
};

// Create user

const createForm = useForm({ name: '', email: '', password: '', role: 'viewer' });

const submitCreate = () => {
    createForm.post('/users', {
        preserveScroll: true,
        onSuccess: () => {
            createForm.reset();
            toast.success('User added.');
        },
        onError: () => toast.error('Failed to add user.'),
    });
};

// Delete confirmation

const deletingUser = ref(null);
const deleting = ref(false);

const confirmDestroy = (user) => {
    deletingUser.value = user;
};

const cancelDestroy = () => {
    deletingUser.value = null;
};

const destroy = () => {
    if (!deletingUser.value) return;
    deleting.value = true;

    router.delete(`/users/${deletingUser.value.id}`, {
        preserveScroll: true,
        onSuccess: () => {
            toast.success('User deleted.');
            deletingUser.value = null;
        },
        onError: (errors) => toast.error(errors.role ?? 'Failed to delete user.'),
        onFinish: () => {
            deleting.value = false;
        },
    });
};
</script>

<template>
    <AppLayout>
        <h1 class="font-display text-2xl font-bold tracking-tight" style="color: var(--ink)">Users</h1>
        <p class="mt-1 text-sm" style="color: var(--ink-muted)">
            Manage who can view, edit, or administer Brand Matrix.
        </p>

        <form @submit.prevent="submitCreate" class="mt-6 grid grid-cols-1 gap-3 sm:grid-cols-5">
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
                    v-model="createForm.password"
                    type="password"
                    placeholder="Password"
                    class="w-full rounded-md border px-3 py-2 text-sm transition-colors focus:outline-none"
                    style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                />
                <p v-if="createForm.errors.password" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                    {{ createForm.errors.password }}
                </p>
            </div>
            <div>
                <select
                    v-model="createForm.role"
                    class="w-full rounded-md border px-3 py-2 text-sm transition-colors focus:outline-none"
                    style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                >
                    <option v-for="role in roles" :key="role" :value="role">{{ roleLabels[role] ?? role }}</option>
                </select>
                <p v-if="createForm.errors.role" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                    {{ createForm.errors.role }}
                </p>
            </div>
            <button
                type="submit"
                :disabled="createForm.processing"
                class="shrink-0 rounded-md px-4 py-2 text-sm font-semibold transition-opacity hover:opacity-90 disabled:opacity-50"
                style="background-color: var(--accent); color: var(--accent-ink)"
            >
                + Add User
            </button>
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
                        <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Role</th>
                        <th class="px-4 py-3 text-right text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <tr
                        v-for="user in users.data"
                        :key="user.id"
                        style="border-bottom: 1px solid var(--border)"
                    >
                        <td class="px-4 py-3.5 text-sm font-medium" style="color: var(--ink)">
                            {{ user.name }}
                            <span v-if="user.id === currentUser?.id" class="ml-1.5 text-xs font-normal" style="color: var(--ink-faint)">(you)</span>
                        </td>
                        <td class="px-4 py-3.5 text-sm" style="color: var(--ink-muted)">{{ user.email }}</td>
                        <td class="px-4 py-3.5 text-sm">
                            <select
                                v-if="user.id !== currentUser?.id"
                                :value="user.role"
                                class="rounded-md border px-2.5 py-1.5 text-sm transition-colors focus:outline-none"
                                style="border-color: var(--border); background-color: var(--surface); color: var(--ink)"
                                @change="changeRole(user, $event)"
                            >
                                <option v-for="role in roles" :key="role" :value="role">{{ roleLabels[role] ?? role }}</option>
                            </select>
                            <span v-else style="color: var(--ink-muted)">
                                {{ roleLabels[user.role] ?? user.role }}
                                <span class="ml-1 text-xs" style="color: var(--ink-faint)">(can't change your own role)</span>
                            </span>
                        </td>
                        <td class="px-4 py-3.5 text-right text-sm">
                            <ActionsMenu
                                v-if="user.id !== currentUser?.id"
                                :items="[{ label: 'Delete', danger: true, onClick: () => confirmDestroy(user) }]"
                            />
                        </td>
                    </tr>
                    <tr v-if="users.data.length === 0">
                        <td colspan="4" class="px-4 py-12 text-center text-sm" style="color: var(--ink-faint)">
                            No users found.
                        </td>
                    </tr>
                </tbody>
            </table>

            <div
                v-if="users.last_page > 1"
                class="flex items-center justify-between border-t px-4 py-3"
                style="border-color: var(--border)"
            >
                <p class="text-sm" style="color: var(--ink-muted)">
                    Showing <span class="font-medium tabular-nums" style="color: var(--ink)">{{ users.from }}–{{ users.to }}</span>
                    of <span class="font-medium tabular-nums" style="color: var(--ink)">{{ users.total }}</span>
                </p>
                <div class="flex items-center gap-1">
                    <button
                        v-for="link in users.links"
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

        <ConfirmDialog
            :open="!!deletingUser"
            title="Delete this user?"
            :message="deletingUser ? `This will permanently remove “${deletingUser.name}” (${deletingUser.email}). This cannot be undone.` : ''"
            :processing="deleting"
            @confirm="destroy"
            @cancel="cancelDestroy"
        />
    </AppLayout>
</template>
