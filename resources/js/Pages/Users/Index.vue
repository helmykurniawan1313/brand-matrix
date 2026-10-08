<script setup>
import { ref } from 'vue';
import { router, useForm } from '@inertiajs/vue3';
import AppLayout from '../../Layouts/AppLayout.vue';

import ActionsMenu from '../../Components/ActionsMenu.vue';
import ConfirmDialog from '../../Components/ConfirmDialog.vue';
import { useAuth } from '../../composables/useAuth';
import { useToast } from '../../composables/useToast';

defineOptions({ layout: AppLayout });

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
    // { pageKey: label } — every page a user's visibility can be individually
    // restricted to, same list the backend's User::PAGES defines.
    pages: {
        type: Object,
        required: true,
    },
});

const pageKeys = Object.keys(props.pages);

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
        { role, page_access: user.page_access },
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

// --- Page access modal — click a user's "Pages" cell to open a checklist of
// which pages they can see. null/all-checked = unrestricted (the default);
// unchecking any box restricts them to just what's left checked. A modal
// (rather than an inline popover) avoids the table's own overflow/scroll
// clipping the control, and gives 8 checkboxes room to lay out cleanly. ---

const pageAccessTarget = ref(null); // the user object currently being edited, or null
const pageAccessDraft = ref([]);

const isUnrestricted = (user) => user.page_access === null || user.page_access === undefined;

const openPageAccess = (user) => {
    pageAccessDraft.value = isUnrestricted(user) ? [...pageKeys] : [...user.page_access];
    pageAccessTarget.value = user;
};

const closePageAccess = () => {
    pageAccessTarget.value = null;
};

const togglePageDraft = (key) => {
    const index = pageAccessDraft.value.indexOf(key);
    if (index === -1) {
        pageAccessDraft.value.push(key);
    } else {
        pageAccessDraft.value.splice(index, 1);
    }
};

const saveFullAccess = (user) => {
    router.put(
        `/users/${user.id}`,
        { role: user.role, page_access: null },
        {
            preserveScroll: true,
            onSuccess: () => toast.success(`${user.name} now sees every page.`),
            onError: () => toast.error('Failed to update page access.'),
            onFinish: closePageAccess,
        },
    );
};

const savePageAccess = (user) => {
    // All boxes checked is functionally the same as unrestricted — save it as
    // null rather than a full explicit list, so a newly added page in the
    // future doesn't silently stay hidden from someone who meant "everything."
    const value = pageAccessDraft.value.length === pageKeys.length ? null : [...pageAccessDraft.value];

    router.put(
        `/users/${user.id}`,
        { role: user.role, page_access: value },
        {
            preserveScroll: true,
            onSuccess: () => toast.success(`${user.name}'s page access updated.`),
            onError: () => toast.error('Failed to update page access.'),
            onFinish: closePageAccess,
        },
    );
};

// Create user

const createForm = useForm({ name: '', email: '', password: '', role: 'viewer', page_access: null });
const createFullAccess = ref(true);
const createPageAccessDraft = ref([...pageKeys]);

const submitCreate = () => {
    createForm.page_access = createFullAccess.value ? null : [...createPageAccessDraft.value];

    createForm.post('/users', {
        preserveScroll: true,
        onSuccess: () => {
            createForm.reset();
            createFullAccess.value = true;
            createPageAccessDraft.value = [...pageKeys];
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
        <h1 class="font-display text-2xl font-bold tracking-tight" style="color: var(--ink)">Users</h1>
        <p class="mt-1 text-sm" style="color: var(--ink-muted)">
            Manage who can view, edit, or administer Brand Matrix.
        </p>

        <form
            @submit.prevent="submitCreate"
            class="mt-6 rounded-xl border p-5"
            style="border-color: var(--border); background-color: var(--surface)"
        >
            <h2 class="text-sm font-semibold" style="color: var(--ink)">Add a user</h2>

            <div class="mt-4 grid grid-cols-1 gap-3 sm:grid-cols-2 lg:grid-cols-4">
                <div>
                    <input
                        v-model="createForm.name"
                        type="text"
                        placeholder="Name"
                        class="w-full rounded-md border px-3 py-2 text-sm transition-colors focus:outline-none"
                        style="border-color: var(--border); background-color: var(--surface-raised); color: var(--ink)"
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
                        style="border-color: var(--border); background-color: var(--surface-raised); color: var(--ink)"
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
                        style="border-color: var(--border); background-color: var(--surface-raised); color: var(--ink)"
                    />
                    <p v-if="createForm.errors.password" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                        {{ createForm.errors.password }}
                    </p>
                </div>
                <div>
                    <select
                        v-model="createForm.role"
                        class="w-full rounded-md border px-3 py-2 text-sm transition-colors focus:outline-none"
                        style="border-color: var(--border); background-color: var(--surface-raised); color: var(--ink)"
                    >
                        <option v-for="role in roles" :key="role" :value="role">{{ roleLabels[role] ?? role }}</option>
                    </select>
                    <p v-if="createForm.errors.role" class="mt-1 text-sm" style="color: var(--status-parah-ink)">
                        {{ createForm.errors.role }}
                    </p>
                </div>
            </div>

            <div class="mt-4 border-t pt-4" style="border-color: var(--border)">
                <label class="flex items-center gap-2 text-sm font-medium" style="color: var(--ink)">
                    <input v-model="createFullAccess" type="checkbox" class="rounded" />
                    Full access (sees every page)
                </label>
                <div v-if="!createFullAccess" class="mt-3 grid grid-cols-2 gap-x-4 gap-y-2 sm:grid-cols-4">
                    <label
                        v-for="key in pageKeys"
                        :key="key"
                        class="flex items-center gap-1.5 text-sm"
                        style="color: var(--ink-muted)"
                    >
                        <input
                            type="checkbox"
                            class="rounded"
                            :checked="createPageAccessDraft.includes(key)"
                            @change="
                                createPageAccessDraft.includes(key)
                                    ? (createPageAccessDraft = createPageAccessDraft.filter((k) => k !== key))
                                    : createPageAccessDraft.push(key)
                            "
                        />
                        {{ pages[key] }}
                    </label>
                </div>
            </div>

            <button
                type="submit"
                :disabled="createForm.processing"
                class="mt-4 rounded-md px-4 py-2 text-sm font-semibold transition-opacity hover:opacity-90 disabled:opacity-50"
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
                        <th class="px-4 py-3 text-left text-xs font-semibold uppercase tracking-wide" style="color: var(--ink-faint)">Pages</th>
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
                        <td class="px-4 py-3.5 text-sm">
                            <span v-if="user.role === 'super_admin'" class="text-xs" style="color: var(--ink-faint)">All (Super Admin)</span>
                            <button
                                v-else
                                type="button"
                                class="inline-flex items-center gap-1.5 rounded-md border px-2.5 py-1.5 text-xs font-medium transition-colors hover:opacity-80"
                                :style="
                                    isUnrestricted(user)
                                        ? 'border-color: var(--border); background-color: var(--surface); color: var(--ink-muted)'
                                        : 'border-color: var(--accent); background-color: var(--accent-soft); color: var(--accent)'
                                "
                                @click="openPageAccess(user)"
                            >
                                {{ isUnrestricted(user) ? 'All pages' : `${user.page_access.length} of ${pageKeys.length}` }}
                            </button>
                        </td>
                        <td class="px-4 py-3.5 text-right text-sm">
                            <ActionsMenu
                                v-if="user.id !== currentUser?.id"
                                :items="[{ label: 'Delete', danger: true, onClick: () => confirmDestroy(user) }]"
                            />
                        </td>
                    </tr>
                    <tr v-if="users.data.length === 0">
                        <td colspan="5" class="px-4 py-12 text-center text-sm" style="color: var(--ink-faint)">
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

        <!-- Page access modal -->
        <div
            v-if="pageAccessTarget"
            class="fixed inset-0 z-10 flex items-center justify-center bg-black/50 px-4 backdrop-blur-sm"
        >
            <div
                class="flex max-h-[85vh] w-full max-w-md flex-col overflow-hidden rounded-lg border shadow-2xl"
                style="background-color: var(--surface-raised); border-color: var(--border)"
            >
                <div class="flex shrink-0 items-start justify-between gap-4 border-b px-6 py-5" style="border-color: var(--border)">
                    <div>
                        <h2 class="font-display text-lg font-bold" style="color: var(--ink)">Page access</h2>
                        <p class="mt-0.5 text-sm" style="color: var(--ink-muted)">{{ pageAccessTarget.name }}</p>
                    </div>
                    <button
                        type="button"
                        class="flex h-8 w-8 shrink-0 items-center justify-center rounded-md transition-colors hover:opacity-70"
                        style="color: var(--ink-muted)"
                        aria-label="Close"
                        @click="closePageAccess"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="h-5 w-5">
                            <path d="M18 6 6 18M6 6l12 12" />
                        </svg>
                    </button>
                </div>

                <div class="min-h-0 flex-1 overflow-y-auto px-6 py-5">
                    <p class="text-sm" style="color: var(--ink-muted)">Choose which pages this user can see.</p>
                    <div class="mt-4 grid grid-cols-2 gap-x-4 gap-y-3">
                        <label v-for="key in pageKeys" :key="key" class="flex items-center gap-2 text-sm" style="color: var(--ink)">
                            <input
                                type="checkbox"
                                class="rounded"
                                :checked="pageAccessDraft.includes(key)"
                                @change="togglePageDraft(key)"
                            />
                            {{ pages[key] }}
                        </label>
                    </div>
                </div>

                <div class="flex shrink-0 items-center justify-between border-t px-6 py-4" style="border-color: var(--border)">
                    <button
                        type="button"
                        class="text-sm font-medium transition-opacity hover:opacity-70"
                        style="color: var(--ink-muted)"
                        @click="saveFullAccess(pageAccessTarget)"
                    >
                        Grant all pages
                    </button>
                    <button
                        type="button"
                        class="rounded-md px-4 py-2 text-sm font-semibold transition-opacity hover:opacity-90"
                        style="background-color: var(--accent); color: var(--accent-ink)"
                        @click="savePageAccess(pageAccessTarget)"
                    >
                        Save
                    </button>
                </div>
            </div>
        </div>
</template>
